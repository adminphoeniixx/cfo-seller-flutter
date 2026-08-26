/// Real shapes verified via curl against live QA store (id 13) on 2026-08-22:
/// `GET /shipping/zones` and `GET /shipping/rates`.
///
/// Discrepancy vs docs: the docs describe `/shipping/zones` and
/// `/shipping/rates` as independent lists that the client joins by zone id.
/// That's exactly how they behave — `/shipping/rates` embeds a `zone: {id,
/// name}` object per rate, while `/shipping/zones` additionally carries
/// `description`, `countries` and `states` that `/shipping/rates` does not.
/// [ShippingZone.fromRatesList] merges the two responses into one view model.
///
/// The QA store had configured no rates of its own — every rate returned is
/// `is_marketplace: true, editable: false` (the marketplace's fallback).
class ShippingRate {
  final int id;
  final int zoneId;
  final String name;
  final String type;
  final double rate;
  final double perItemRate;
  final double perKgRate;
  final double? minOrderAmount;
  final double? maxOrderAmount;
  final double? freeAboveAmount;
  final int deliveryDaysMin;
  final int deliveryDaysMax;
  final bool isActive;
  final bool isMarketplace;
  final bool editable;

  const ShippingRate({
    required this.id,
    required this.zoneId,
    required this.name,
    required this.type,
    required this.rate,
    required this.perItemRate,
    required this.perKgRate,
    this.minOrderAmount,
    this.maxOrderAmount,
    this.freeAboveAmount,
    required this.deliveryDaysMin,
    required this.deliveryDaysMax,
    required this.isActive,
    required this.isMarketplace,
    required this.editable,
  });

  /// Short human summary, e.g. "4–7 days" or "1–2 days · free above ₹999".
  String get detail {
    final days = deliveryDaysMin == deliveryDaysMax
        ? '$deliveryDaysMin day${deliveryDaysMax == 1 ? '' : 's'}'
        : '$deliveryDaysMin–$deliveryDaysMax days';
    if (freeAboveAmount != null) {
      return '$days · free above ₹${freeAboveAmount!.toStringAsFixed(0)}';
    }
    if (minOrderAmount != null) {
      return '$days · orders above ₹${minOrderAmount!.toStringAsFixed(0)}';
    }
    return days;
  }

  factory ShippingRate.fromJson(Map<String, dynamic> json) => ShippingRate(
    id: json['id'] as int,
    zoneId: (json['zone'] as Map<String, dynamic>)['id'] as int,
    name: json['name'] as String,
    type: json['type'] as String,
    rate: (json['rate'] as num).toDouble(),
    perItemRate: (json['per_item_rate'] as num?)?.toDouble() ?? 0,
    perKgRate: (json['per_kg_rate'] as num?)?.toDouble() ?? 0,
    minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
    maxOrderAmount: (json['max_order_amount'] as num?)?.toDouble(),
    freeAboveAmount: (json['free_above_amount'] as num?)?.toDouble(),
    deliveryDaysMin:
        (json['delivery_days'] as Map<String, dynamic>?)?['min'] as int? ?? 0,
    deliveryDaysMax:
        (json['delivery_days'] as Map<String, dynamic>?)?['max'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    isMarketplace: json['is_marketplace'] as bool? ?? false,
    editable: json['editable'] as bool? ?? false,
  );
}

class ShippingZone {
  final int id;
  final String zone;
  final String description;
  final List<String> countries;
  final List<String> states;
  final List<ShippingRate> rates;

  const ShippingZone({
    required this.id,
    required this.zone,
    required this.description,
    required this.countries,
    required this.states,
    required this.rates,
  });

  factory ShippingZone.fromJson(Map<String, dynamic> json) => ShippingZone(
    id: json['id'] as int,
    zone: json['name'] as String,
    description: json['description'] as String? ?? '',
    countries: (json['countries'] as List? ?? [])
        .map((e) => e as String)
        .toList(),
    states: (json['states'] as List? ?? []).map((e) => e as String).toList(),
    rates: const [],
  );

  ShippingZone copyWithRates(List<ShippingRate> rates) => ShippingZone(
    id: id,
    zone: zone,
    description: description,
    countries: countries,
    states: states,
    rates: rates,
  );

  /// Joins `GET /shipping/zones` results with `GET /shipping/rates` results
  /// by zone id, since the two endpoints are independent lists (see the file
  /// doc comment).
  static List<ShippingZone> merge(
    List<ShippingZone> zones,
    List<ShippingRate> rates,
  ) {
    return zones
        .map(
          (z) => z.copyWithRates(rates.where((r) => r.zoneId == z.id).toList()),
        )
        .toList();
  }
}
