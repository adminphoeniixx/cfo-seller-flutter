/// Models backing the `/payouts`, `/payouts/{id}` and `/payouts/earnings`
/// endpoints (see docs' "Dashboard and money" table).
///
/// IMPORTANT VERIFICATION NOTE: `Earnings` was verified for real via curl
/// against the live QA seller on 2026-08-22 — its shape below is the exact
/// JSON returned. `Payout`, however, could NOT be verified against a real
/// payout object: `GET /payouts` returned `{"data": [], ...}` (an empty,
/// correctly-paginated list) for the QA seller — the account has one
/// lifetime order (₹9,998 gross) but the marketplace has not yet raised a
/// payout for it (`payouts.paid`/`in_progress` are both 0, the whole amount
/// sits in `unsettled`). `GET /payouts/1` correctly 404s
/// ("No query results for model [App\Models\VendorPayout] 1"), confirming
/// the endpoint and its error shape are real and wired, but no example
/// payout resource body was ever returned to inspect.
///
/// Given that, `Payout.fromJson` below is a best-effort inference, not a
/// curl-verified shape:
///  - money fields (`gross_sales`, `commission`, `earning`) reuse the exact
///    key names confirmed real by `/payouts/earnings`, since a payout is
///    presumably serialized with the same money vocabulary as the earnings
///    summary that rolls it up.
///  - `status` values (`paid`, `processing`, `failed`) come from the docs'
///    webhook section: "`payout-status-changed` | It is paid, fails, or
///    goes for processing."
///  - `period_start`/`period_end`/`orders_count`/`reference`/`refunded` are
///    unconfirmed guesses at conventional Laravel field names; all are
///    parsed defensively with null-safe fallbacks so a real payout with a
///    different shape degrades gracefully instead of throwing.
/// Re-verify this model with a real `GET /payouts/{id}` body the moment the
/// QA account (or any seller) has an actual payout on record.
enum PayoutStatus { paid, processing, failed }

PayoutStatus _statusFromJson(dynamic value) {
  switch (value) {
    case 'paid':
      return PayoutStatus.paid;
    case 'failed':
      return PayoutStatus.failed;
    default:
      return PayoutStatus.processing;
  }
}

class Payout {
  final int id;
  final String reference;
  final PayoutStatus status;
  final String? periodStart;
  final String? periodEnd;
  final int ordersCount;
  final double grossSales;
  final double commission;
  final double refunded;
  final double earning;

  const Payout({
    required this.id,
    required this.reference,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    required this.ordersCount,
    required this.grossSales,
    required this.commission,
    required this.refunded,
    required this.earning,
  });

  /// Net payout amount. Same value as [earning] — kept as a distinct getter
  /// so callers read intent ("net payout") rather than the raw API field.
  double get net => earning;

  factory Payout.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Payout(
      id: id,
      reference:
          (json['reference'] as String?) ??
          'PAY-${id.toString().padLeft(5, '0')}',
      status: _statusFromJson(json['status']),
      periodStart: json['period_start'] as String?,
      periodEnd: json['period_end'] as String?,
      ordersCount: json['orders_count'] as int? ?? 0,
      grossSales: (json['gross_sales'] as num?)?.toDouble() ?? 0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0,
      refunded: (json['refunded'] as num?)?.toDouble() ?? 0,
      earning: (json['earning'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// `GET /payouts` — paginated the same way as `/orders`
/// (`data`/`links`/`meta`), confirmed for real via curl (empty page, but
/// the pagination envelope itself is genuine).
class PayoutsPage {
  final List<Payout> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const PayoutsPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PayoutsPage.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PayoutsPage(
      data: (json['data'] as List? ?? const [])
          .map((p) => Payout.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }
}

/// `GET /payouts/earnings` — CURL-VERIFIED shape against the live QA
/// seller on 2026-08-22:
/// ```json
/// {
///   "lifetime": {"gross_sales": 9998, "commission": 999.8, "earning": 8998.2, "orders": 1},
///   "payouts": {"paid": 0, "in_progress": 0, "unsettled": 8998.2},
///   "commission_rate": 10
/// }
/// ```
class Earnings {
  final double lifetimeGrossSales;
  final double lifetimeCommission;
  final double lifetimeEarning;
  final int lifetimeOrders;
  final double paid;
  final double inProgress;
  final double unsettled;
  final double commissionRate;

  const Earnings({
    required this.lifetimeGrossSales,
    required this.lifetimeCommission,
    required this.lifetimeEarning,
    required this.lifetimeOrders,
    required this.paid,
    required this.inProgress,
    required this.unsettled,
    required this.commissionRate,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) {
    final lifetime =
        (json['lifetime'] as Map?)?.cast<String, dynamic>() ?? const {};
    final payouts =
        (json['payouts'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Earnings(
      lifetimeGrossSales: (lifetime['gross_sales'] as num?)?.toDouble() ?? 0,
      lifetimeCommission: (lifetime['commission'] as num?)?.toDouble() ?? 0,
      lifetimeEarning: (lifetime['earning'] as num?)?.toDouble() ?? 0,
      lifetimeOrders: lifetime['orders'] as int? ?? 0,
      paid: (payouts['paid'] as num?)?.toDouble() ?? 0,
      inProgress: (payouts['in_progress'] as num?)?.toDouble() ?? 0,
      unsettled: (payouts['unsettled'] as num?)?.toDouble() ?? 0,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0,
    );
  }
}
