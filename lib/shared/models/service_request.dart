/// Models backing the `/cancellations` and `/refunds` endpoints (docs'
/// "Cancellations and refunds (approved)" table). The app's UI calls this
/// combined feature "Requests" — a single screen lists both kinds, sourced
/// from two separate real endpoints and merged client-side.
///
/// VERIFICATION NOTE: `GET /cancellations` and `GET /refunds` were both
/// curl-verified for real against the live QA seller on 2026-08-22 — each
/// returned `{"data": [], "links": {...}, "meta": {...}}`, the same
/// paginated envelope used by `/orders` and `/payouts`, confirmed genuine
/// but empty (the QA account's one order, #161/item 395, is fully shipped
/// and fully fulfilled, so nothing on it is eligible to cancel — a real
/// attempt (`POST /cancellations` with `order_id: 161, items: [{
/// order_item_id: 395, quantity: 1}]`) correctly 422'd with
/// `"Nothing is left to cancel on QA TEST — Kanchipuram silk saree."`,
/// confirming the create endpoint, its validation, and its error shape are
/// real and wired). `GET /cancellations/999999` and `GET /refunds/999999`
/// were also verified for real, each producing a genuine 404
/// ("No query results for model [App\Models\Cancellation|Refund] 999999").
///
/// No real cancellation or refund resource body was ever returned to
/// inspect (same gap as `Payout` in the Money phase), so `ServiceRequest`
/// and `RequestItem` below are a best-effort inference, not a
/// curl-verified shape:
///  - `order_id`, `reason`, `items[].order_item_id`, `items[].quantity`,
///    `note`, `restock`, `refund_requested` reuse the exact field names the
///    docs give for the `POST /cancellations` request body, on the
///    assumption a Laravel API resource echoes the same vocabulary back.
///  - `status` values (`pending`, `approved`, `rejected`) come from the
///    docs ("lands as `pending`", "approves or rejects one") plus the
///    webhook table's `refund-decided` ("approved, rejected, or actually
///    paid out"), which is where `paid` comes from — refund-only, unused
///    for cancellations.
///  - `requested_by` is fixed `vendor` per the docs when *we* raise a
///    cancellation, but the docs also describe a `reason_label` pair and
///    imply buyer-raised refunds exist, so it's parsed as a free string
///    rather than an enum.
///  - Money/breakdown fields (`amount`, per-item `unit_price`) are not
///    documented at all for these resources; [RequestItem] borrows the
///    same money vocabulary as `OrderItem` (`unit_price`, `total`) on the
///    assumption line items are serialized consistently across the API,
///    parsed defensively with null-safe fallbacks.
///  - Neither resource carries an image/emoji field in the docs, matching
///    `OrderItem`/`Product` — [RequestItem.emoji] is a fixed placeholder.
/// Re-verify this model with a real `GET /cancellations/{id}` or
/// `GET /refunds/{id}` body the moment the QA account (or any seller) has
/// an actual cancellation or refund on record — ideally by finding (or
/// being given) an order with a still-unshipped line to raise a real
/// cancellation against.
library;

enum RequestKind { cancellation, refund }

/// `paid` only applies to refunds; cancellations only ever reach `pending`,
/// `approved` or `rejected` per the docs.
enum RequestStatus { pending, approved, rejected, paid }

RequestStatus _statusFromJson(dynamic value) {
  switch (value) {
    case 'approved':
      return RequestStatus.approved;
    case 'rejected':
      return RequestStatus.rejected;
    case 'paid':
      return RequestStatus.paid;
    default:
      return RequestStatus.pending;
  }
}

class RequestItem {
  final int orderItemId;
  final String name;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double amount;

  /// No image/emoji field is documented for this resource — fixed
  /// placeholder so `AppThumb` still has something to render (same pattern
  /// as `OrderItem.emoji`/`Product.emoji`).
  final String emoji;

  const RequestItem({
    required this.orderItemId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.emoji = '📦',
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as int? ?? 0;
    final unitPrice = ((json['unit_price'] as num?) ?? 0).toDouble();
    return RequestItem(
      orderItemId: json['order_item_id'] as int? ?? json['id'] as int? ?? 0,
      name: (json['name'] as String?) ?? '',
      sku: (json['sku'] as String?) ?? '',
      quantity: quantity,
      unitPrice: unitPrice,
      amount: ((json['total'] as num?) ?? (unitPrice * quantity)).toDouble(),
    );
  }
}

/// Inferred refund money breakdown — no documented shape, kept optional so
/// a real response missing it degrades to the plain amount/restock view
/// the detail screen already falls back to.
class RefundBreakdown {
  final double items;
  final double shipping;
  final double tax;
  final double adjustments;
  final double total;

  const RefundBreakdown({
    required this.items,
    required this.shipping,
    required this.tax,
    required this.adjustments,
    required this.total,
  });

  factory RefundBreakdown.fromJson(Map<String, dynamic> json) =>
      RefundBreakdown(
        items: ((json['items'] as num?) ?? 0).toDouble(),
        shipping: ((json['shipping'] as num?) ?? 0).toDouble(),
        tax: ((json['tax'] as num?) ?? 0).toDouble(),
        adjustments:
            (((json['adjustments'] as num?) ?? (json['adj'] as num?)) ?? 0)
                .toDouble(),
        total: ((json['total'] as num?) ?? 0).toDouble(),
      );
}

class ServiceRequest {
  final int id;

  /// Which endpoint this came from — the API has no shared `kind` field;
  /// the app tags it based on whether it was fetched from `/cancellations`
  /// or `/refunds`.
  final RequestKind kind;
  final RequestStatus status;
  final int orderId;
  final DateTime? createdAt;
  final String reason;
  final String? reasonLabel;
  final String requestedBy;
  final String note;
  final List<RequestItem> items;
  final bool refundRequested;
  final bool restock;
  final double amount;
  final RefundBreakdown? breakdown;

  const ServiceRequest({
    required this.id,
    required this.kind,
    required this.status,
    required this.orderId,
    this.createdAt,
    required this.reason,
    this.reasonLabel,
    required this.requestedBy,
    required this.note,
    required this.items,
    required this.refundRequested,
    required this.restock,
    required this.amount,
    this.breakdown,
  });

  /// A stable-looking human label, since the docs never mention a `number`
  /// field like the prototype's `CAN-00017`/`REF-00009` — synthesized from
  /// [kind] and [id] so the existing UI (built around a "number" string)
  /// still has something short to show.
  String get number =>
      '${kind == RequestKind.refund ? 'REF' : 'CAN'}-${id.toString().padLeft(5, '0')}';

  /// Cancellations and refunds are two separate ID namespaces on the
  /// backend (`Cancellation` and `Refund` are different models), but this
  /// app's single `/requests/request/:id` route only carries one int and
  /// the list screen merges both kinds. To keep routing/detail lookups
  /// unambiguous without changing the route shape, refund ids are offset
  /// by a fixed billion so they can never collide with a cancellation id
  /// — see [ServiceRequestKeyCodec] for the encode/decode used by the
  /// repository and router.
  int get routeId => ServiceRequestKeyCodec.encode(kind, id);

  factory ServiceRequest.fromJson(Map<String, dynamic> json, RequestKind kind) {
    final items = (json['items'] as List? ?? const [])
        .map((e) => RequestItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null;
    return ServiceRequest(
      id: json['id'] as int,
      kind: kind,
      status: _statusFromJson(json['status']),
      orderId: json['order_id'] as int? ?? 0,
      createdAt: createdAt,
      reason:
          (json['reason_label'] as String?) ??
          (json['reason'] as String?) ??
          '',
      reasonLabel: json['reason_label'] as String?,
      requestedBy: (json['requested_by'] as String?) ?? 'vendor',
      note: (json['note'] as String?) ?? '',
      items: items,
      refundRequested: json['refund_requested'] as bool? ?? false,
      restock: json['restock'] as bool? ?? false,
      amount:
          ((json['amount'] as num?) ??
                  items.fold<double>(0, (sum, i) => sum + i.amount))
              .toDouble(),
      breakdown: json['breakdown'] != null
          ? RefundBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Encodes/decodes the (kind, id) pair into the single int the app's
/// existing `/requests/request/:id` route and `RequestRepository` methods
/// carry — see [ServiceRequest.routeId] for why this exists.
class ServiceRequestKeyCodec {
  const ServiceRequestKeyCodec._();

  static const int _refundOffset = 1000000000;

  static int encode(RequestKind kind, int id) =>
      kind == RequestKind.refund ? _refundOffset + id : id;

  static (RequestKind, int) decode(int routeId) => routeId >= _refundOffset
      ? (RequestKind.refund, routeId - _refundOffset)
      : (RequestKind.cancellation, routeId);
}

/// `GET /cancellations` / `GET /refunds` — paginated the same way as
/// `/orders` and `/payouts` (`data`/`links`/`meta`), confirmed for real via
/// curl (both empty pages, but the pagination envelope itself is genuine).
class ServiceRequestsPage {
  final List<ServiceRequest> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const ServiceRequestsPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ServiceRequestsPage.fromJson(
    Map<String, dynamic> json,
    RequestKind kind,
  ) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ServiceRequestsPage(
      data: (json['data'] as List? ?? const [])
          .map((r) => ServiceRequest.fromJson(r as Map<String, dynamic>, kind))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }
}
