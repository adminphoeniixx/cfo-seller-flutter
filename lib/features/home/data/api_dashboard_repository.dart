import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/dashboard.dart';
import '../domain/dashboard_repository.dart';

/// Talks to the real `GET /dashboard` and `GET /analytics/sales`. Both
/// verified against the live server on 2026-08-22 — neither wraps its
/// response in a `data` key, unlike `/me` and `/store`.
class ApiDashboardRepository implements DashboardRepository {
  final ApiClient _client;

  ApiDashboardRepository(this._client);

  @override
  Future<NetworkResult<Dashboard>> getDashboard({int days = 30}) {
    return _client.get(
      '/dashboard',
      query: {'days': days},
      parse: (json) => Dashboard.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<SalesSeries>> getSalesSeries({int days = 30}) {
    return _client.get(
      '/analytics/sales',
      query: {'days': days},
      parse: (json) => SalesSeries.fromJson(json as Map<String, dynamic>),
    );
  }
}
