import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/payout.dart';
import '../domain/payout_repository.dart';

/// Talks to the real `/payouts`, `/payouts/{id}` and `/payouts/earnings`
/// endpoints. `/payouts/earnings` was curl-verified against a live QA
/// seller on 2026-08-22 and its shape is exact — see `Earnings.fromJson`'s
/// doc comment. `/payouts` and `/payouts/{id}` were also exercised for
/// real (empty list + a genuine 404), but the QA account has no payout
/// on record, so the individual `Payout` resource shape is inferred rather
/// than curl-verified — see `Payout.fromJson`'s doc comment for the full
/// discrepancy note and what to re-check once a real payout exists.
class ApiPayoutRepository implements PayoutRepository {
  final ApiClient _client;

  ApiPayoutRepository(this._client);

  @override
  Future<NetworkResult<List<Payout>>> getPayouts({String? status}) {
    return _client.get(
      '/payouts',
      query: {'status': ?status},
      parse: (json) => PayoutsPage.fromJson(json as Map<String, dynamic>).data,
    );
  }

  @override
  Future<NetworkResult<Payout>> getPayout(int id) {
    return _client.get(
      '/payouts/$id',
      parse: (json) => Payout.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? json,
      ),
    );
  }

  @override
  Future<NetworkResult<Earnings>> getEarnings() {
    return _client.get(
      '/payouts/earnings',
      parse: (json) => Earnings.fromJson(json as Map<String, dynamic>),
    );
  }
}
