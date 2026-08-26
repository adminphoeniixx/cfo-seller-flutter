/// Shared shape for the four period-summary numbers the API repeats across
/// `dashboard.totals` and `analytics/sales.totals` — verified identical on
/// both endpoints via curl on 2026-08-22.
class PeriodTotals {
  final double sales;
  final double earning;
  final int orders;
  final int units;

  const PeriodTotals({
    required this.sales,
    required this.earning,
    required this.orders,
    required this.units,
  });

  factory PeriodTotals.fromJson(Map<String, dynamic> json) => PeriodTotals(
    sales: (json['sales'] as num).toDouble(),
    earning: (json['earning'] as num).toDouble(),
    orders: json['orders'] as int,
    units: json['units'] as int,
  );
}

class NeedsAttention {
  final int unfulfilledOrders;
  final int pendingCancellations;
  final int pendingRefunds;
  final int lowStockProducts;

  const NeedsAttention({
    required this.unfulfilledOrders,
    required this.pendingCancellations,
    required this.pendingRefunds,
    required this.lowStockProducts,
  });

  factory NeedsAttention.fromJson(Map<String, dynamic> json) => NeedsAttention(
    unfulfilledOrders: json['unfulfilled_orders'] as int,
    pendingCancellations: json['pending_cancellations'] as int,
    pendingRefunds: json['pending_refunds'] as int,
    lowStockProducts: json['low_stock_products'] as int,
  );
}

class TopProduct {
  final String name;
  final int units;
  final double revenue;

  const TopProduct({
    required this.name,
    required this.units,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
    name: json['name'] as String,
    units: json['units'] as int,
    revenue: (json['revenue'] as num).toDouble(),
  );
}

/// Matches `GET /dashboard?days=` — verified against the live API on
/// 2026-08-22.
class Dashboard {
  final int rangeDays;
  final PeriodTotals totals;
  final NeedsAttention needsAttention;
  final List<TopProduct> topProducts;

  const Dashboard({
    required this.rangeDays,
    required this.totals,
    required this.needsAttention,
    required this.topProducts,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
    rangeDays: json['range_days'] as int,
    totals: PeriodTotals.fromJson(json['totals'] as Map<String, dynamic>),
    needsAttention: NeedsAttention.fromJson(
      json['needs_attention'] as Map<String, dynamic>,
    ),
    topProducts: (json['top_products'] as List)
        .map((p) => TopProduct.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

class SalesSeriesPoint {
  final DateTime date;
  final double sales;
  final double earning;
  final int orders;
  final int units;

  const SalesSeriesPoint({
    required this.date,
    required this.sales,
    required this.earning,
    required this.orders,
    required this.units,
  });

  factory SalesSeriesPoint.fromJson(Map<String, dynamic> json) =>
      SalesSeriesPoint(
        date: DateTime.parse(json['date'] as String),
        sales: (json['sales'] as num).toDouble(),
        earning: (json['earning'] as num).toDouble(),
        orders: json['orders'] as int,
        units: json['units'] as int,
      );
}

/// Matches `GET /analytics/sales?days=` — the series is always exactly
/// `days` long, zero-filled on days with no sales, so a chart never
/// distorts its own shape. Verified against the live API on 2026-08-22.
class SalesSeries {
  final DateTime from;
  final DateTime to;
  final int days;
  final PeriodTotals totals;
  final List<SalesSeriesPoint> series;

  const SalesSeries({
    required this.from,
    required this.to,
    required this.days,
    required this.totals,
    required this.series,
  });

  factory SalesSeries.fromJson(Map<String, dynamic> json) => SalesSeries(
    from: DateTime.parse(json['from'] as String),
    to: DateTime.parse(json['to'] as String),
    days: json['days'] as int,
    totals: PeriodTotals.fromJson(json['totals'] as Map<String, dynamic>),
    series: (json['series'] as List)
        .map((p) => SalesSeriesPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}
