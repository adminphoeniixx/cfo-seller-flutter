import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/shipping_rate.dart';
import '../domain/shipping_repository.dart';

/// Talks to the real `/shipping/zones` and `/shipping/rates` endpoints.
/// Shapes verified via curl against live QA store (id 13) on 2026-08-22 —
/// see `shipping_rate.dart`'s doc comment for the zones/rates join and the
/// discrepancy found (the two endpoints are independent lists, joined here
/// client-side by zone id, matching the docs' description).
///
/// The docs also list `POST/PUT/DELETE /shipping/rates/{id}` for a seller to
/// price their own delivery. The existing shipping screen (prototype) is
/// read-only — its "Add a rate" button and per-row taps are explicit
/// placeholders ("Not part of this preview yet") with no create/edit form in
/// the design to wire to. Per instructions to wire, not redesign, those
/// mutation endpoints are implemented here (available for a future screen)
/// but intentionally left unwired from the UI; see the final report for this
/// flagged as a gap to confirm with the user.
class ApiShippingRepository implements ShippingRepository {
  final ApiClient _client;

  ApiShippingRepository(this._client);

  @override
  Future<NetworkResult<List<ShippingZone>>> getZones() async {
    final zonesResult = await _client.get(
      '/shipping/zones',
      parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
          .map((e) => ShippingZone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (zonesResult is! Success<List<ShippingZone>>) {
      return zonesResult;
    }

    final ratesResult = await _client.get(
      '/shipping/rates',
      parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
          .map((e) => ShippingRate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (ratesResult is! Success<List<ShippingRate>>) {
      return ratesResult as NetworkResult<List<ShippingZone>>;
    }

    return Success(ShippingZone.merge(zonesResult.data, ratesResult.data));
  }

  /// `shipping_zone_id, name, type, rate` plus optional bounds. Not
  /// currently wired to any screen — see class doc comment.
  Future<NetworkResult<void>> createRate({
    required int zoneId,
    required String name,
    required String type,
    required double rate,
    double? minOrderAmount,
    double? maxOrderAmount,
    double? freeAboveAmount,
    double? perItemRate,
    double? perKgRate,
  }) {
    return _client.post(
      '/shipping/rates',
      body: {
        'shipping_zone_id': zoneId,
        'name': name,
        'type': type,
        'rate': rate,
        'min_order_amount': ?minOrderAmount,
        'max_order_amount': ?maxOrderAmount,
        'free_above_amount': ?freeAboveAmount,
        'per_item_rate': ?perItemRate,
        'per_kg_rate': ?perKgRate,
      },
      parse: (_) {},
    );
  }

  /// Not currently wired to any screen — see class doc comment.
  Future<NetworkResult<void>> deleteRate(int id) {
    return _client.delete('/shipping/rates/$id', parse: (_) {});
  }
}
