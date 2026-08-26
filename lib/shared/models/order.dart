/// Matches `GET /orders`, `GET /orders/{id}` and `POST /orders/{id}/fulfill`
/// row/response shapes — verified via curl against the live QA order #161
/// on 2026-08-22. Replaces the earlier flat prototype shape (`buyer`,
/// `phone`, `date`, `pay`, `address` as bare strings) with the real nested
/// API shape.
///
/// Discrepancies vs the docs found while integrating:
/// - The docs don't mention a "shared basket" concept, and no field on the
///   order carries it. The old prototype UI's shared-basket banner (driven
///   by a fake `sharedBasket` bool) is dropped — [Order] has no such field.
///   The docs' "Fulfilment only moves your own lines" note implies baskets
///   *can* be multi-seller, but the API gives sellers no per-order signal
///   for that, only that fulfilment/notes always act on the caller's own
///   lines.
/// - Order items carry no image/emoji field (`image_url` was `null` on the
///   captured sample); [OrderItem.emoji] is a fixed placeholder so the
///   existing `AppThumb(emoji: …)` widget still has something to show.
library;

/// Order-level fulfilment state, derived from the API's `fulfillment_status`
/// string (`unfulfilled` / `partially_fulfilled` / `fulfilled`).
enum FulfillmentStatus { unfulfilled, partial, fulfilled }

FulfillmentStatus fulfillmentStatusFromString(String? s) {
  switch (s) {
    case 'fulfilled':
      return FulfillmentStatus.fulfilled;
    case 'partially_fulfilled':
    case 'partial':
      return FulfillmentStatus.partial;
    default:
      return FulfillmentStatus.unfulfilled;
  }
}

class OrderCustomer {
  final String name;
  final String phone;

  const OrderCustomer({required this.name, required this.phone});

  factory OrderCustomer.fromJson(Map<String, dynamic> json) => OrderCustomer(
    name: (json['name'] as String?) ?? '',
    phone: (json['phone'] as String?) ?? '',
  );
}

class ShippingAddress {
  final String firstName;
  final String lastName;
  final String line1;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String phone;

  const ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.line1,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        firstName: (json['first_name'] as String?) ?? '',
        lastName: (json['last_name'] as String?) ?? '',
        line1: (json['address_line1'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        state: (json['state'] as String?) ?? '',
        postcode: (json['postcode'] as String?) ?? '',
        country: (json['country'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();

  String get formatted => '$line1\n$city, $state $postcode';
}

class OrderTotals {
  final double items;
  final double tax;
  final double commission;
  final double earning;

  const OrderTotals({
    required this.items,
    required this.tax,
    required this.commission,
    required this.earning,
  });

  factory OrderTotals.fromJson(Map<String, dynamic> json) => OrderTotals(
    items: ((json['items'] as num?) ?? 0).toDouble(),
    tax: ((json['tax'] as num?) ?? 0).toDouble(),
    commission: ((json['commission'] as num?) ?? 0).toDouble(),
    earning: ((json['earning'] as num?) ?? 0).toDouble(),
  );
}

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final String sku;
  final double unitPrice;
  final int quantity;
  final int quantityCancelled;
  final int quantityRefunded;
  final int quantityFulfilled;
  final String fulfillmentStatus;
  final double taxAmount;
  final double total;
  final double commissionRate;
  final double commissionAmount;
  final double earning;

  /// No image/emoji field is returned by the API — fixed placeholder so
  /// `AppThumb` still has something to render.
  final String emoji;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
    required this.quantityCancelled,
    required this.quantityRefunded,
    required this.quantityFulfilled,
    required this.fulfillmentStatus,
    required this.taxAmount,
    required this.total,
    required this.commissionRate,
    required this.commissionAmount,
    required this.earning,
    this.emoji = '📦',
  });

  /// Outstanding quantity this seller still needs to pack.
  int get remaining =>
      (quantity - quantityFulfilled - quantityCancelled - quantityRefunded)
          .clamp(0, quantity);

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as int,
    productId: json['product_id'] as int? ?? 0,
    name: (json['name'] as String?) ?? '',
    sku: (json['sku'] as String?) ?? '',
    unitPrice: ((json['unit_price'] as num?) ?? 0).toDouble(),
    quantity: json['quantity'] as int? ?? 0,
    quantityCancelled: json['quantity_cancelled'] as int? ?? 0,
    quantityRefunded: json['quantity_refunded'] as int? ?? 0,
    quantityFulfilled: json['quantity_fulfilled'] as int? ?? 0,
    fulfillmentStatus: (json['fulfillment_status'] as String?) ?? 'unfulfilled',
    taxAmount: ((json['tax_amount'] as num?) ?? 0).toDouble(),
    total: ((json['total'] as num?) ?? 0).toDouble(),
    commissionRate: ((json['commission_rate'] as num?) ?? 0).toDouble(),
    commissionAmount: ((json['commission_amount'] as num?) ?? 0).toDouble(),
    earning: ((json['earning'] as num?) ?? 0).toDouble(),
  );
}

class Order {
  final int id;
  final String number;
  final String status;
  final String paymentStatus;
  final FulfillmentStatus fulfillmentStatus;
  final String? paymentMethod;
  final String? shippingMethod;
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final OrderCustomer customer;
  final ShippingAddress shippingAddress;
  final String? customerNote;
  final List<OrderItem> items;
  final OrderTotals totals;
  final DateTime? placedAt;
  final DateTime? shippedAt;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    this.paymentMethod,
    this.shippingMethod,
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    required this.customer,
    required this.shippingAddress,
    this.customerNote,
    required this.items,
    required this.totals,
    this.placedAt,
    this.shippedAt,
    this.createdAt,
  });

  double get total => totals.items;

  /// Whether this order still has any of the caller's own lines to pack —
  /// mirrors the API's `needs_packing` filter semantics.
  bool get needsPacking => items.any((i) => i.remaining > 0);

  Order copyWith({
    String? status,
    FulfillmentStatus? fulfillmentStatus,
    List<OrderItem>? items,
    String? trackingNumber,
    String? carrier,
    DateTime? shippedAt,
  }) {
    return Order(
      id: id,
      number: number,
      status: status ?? this.status,
      paymentStatus: paymentStatus,
      fulfillmentStatus: fulfillmentStatus ?? this.fulfillmentStatus,
      paymentMethod: paymentMethod,
      shippingMethod: shippingMethod,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      trackingUrl: trackingUrl,
      customer: customer,
      shippingAddress: shippingAddress,
      customerNote: customerNote,
      items: items ?? this.items,
      totals: totals,
      placedAt: placedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      createdAt: createdAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int,
    number: (json['number'] as String?) ?? '#${json['id']}',
    status: (json['status'] as String?) ?? 'pending',
    paymentStatus: (json['payment_status'] as String?) ?? '',
    fulfillmentStatus: fulfillmentStatusFromString(
      json['fulfillment_status'] as String?,
    ),
    paymentMethod: json['payment_method'] as String?,
    shippingMethod: json['shipping_method'] as String?,
    carrier: json['carrier'] as String?,
    trackingNumber: json['tracking_number'] as String?,
    trackingUrl: json['tracking_url'] as String?,
    customer: OrderCustomer.fromJson(
      (json['customer'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    shippingAddress: ShippingAddress.fromJson(
      (json['shipping_address'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    customerNote: json['customer_note'] as String?,
    items: (json['items'] as List? ?? const [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    totals: OrderTotals.fromJson(
      (json['totals'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    placedAt: json['placed_at'] != null
        ? DateTime.tryParse(json['placed_at'] as String)
        : null,
    shippedAt: json['shipped_at'] != null
        ? DateTime.tryParse(json['shipped_at'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );
}

/// `{data, links, meta}` paginator envelope `GET /orders` returns.
class OrdersPage {
  final List<Order> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const OrdersPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return OrdersPage(
      data: (json['data'] as List? ?? const [])
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }
}

/// `GET /orders/summary` response — counts per status plus `unfulfilled`.
class OrdersSummary {
  final Map<String, int> statuses;
  final int unfulfilled;

  const OrdersSummary({required this.statuses, required this.unfulfilled});

  factory OrdersSummary.fromJson(Map<String, dynamic> json) => OrdersSummary(
    statuses: ((json['statuses'] as Map?) ?? const {}).map(
      (k, v) => MapEntry(k as String, v as int),
    ),
    unfulfilled: json['unfulfilled'] as int? ?? 0,
  );
}

/// `GET /delivery-partners` row — feeds the carrier picker on the fulfil
/// screen. `carrier` sent to `/orders/{id}/fulfill` must be this `name`
/// verbatim, or the order's `tracking_url` comes back `null`.
class DeliveryPartner {
  final int id;
  final String name;
  final bool hasTracking;

  const DeliveryPartner({
    required this.id,
    required this.name,
    required this.hasTracking,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) =>
      DeliveryPartner(
        id: json['id'] as int,
        name: (json['name'] as String?) ?? '',
        hasTracking: json['has_tracking'] as bool? ?? false,
      );
}
