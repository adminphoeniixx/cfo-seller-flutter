import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/catalog.dart';
import '../domain/catalog_repository.dart';

/// `GET /catalog/options` — per `seller-app-product-form.md` §5, cached for
/// the session once fetched.
///
/// **Curl-verified against the live QA server on 2026-08-26** — the
/// response is the bare `{ categories, attributes, tax_classes, statuses }`
/// object with no `data` wrapper (the `parse` below still tolerates a
/// wrapped shape defensively, in case that ever changes).
class ApiCatalogRepository implements CatalogRepository {
  final ApiClient _client;
  CatalogOptions? _cached;

  ApiCatalogRepository(this._client);

  @override
  Future<NetworkResult<CatalogOptions>> getOptions() async {
    final cached = _cached;
    if (cached != null) return Success(cached);

    final result = await _client.get(
      '/catalog/options',
      parse: (json) => CatalogOptions.fromJson(
        (json is Map && json['data'] is Map)
            ? (json as Map<String, dynamic>)['data'] as Map<String, dynamic>
            : json as Map<String, dynamic>,
      ),
    );

    return result.when(
      success: (options) {
        _cached = options;
        return Success(options);
      },
      failure: (e) => Failure(e),
    );
  }
}
