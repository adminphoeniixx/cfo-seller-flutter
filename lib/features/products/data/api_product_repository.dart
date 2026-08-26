import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';
import '../domain/product_repository.dart';

/// Talks to the real `/products` endpoints. List, show, create, update,
/// status and stock shapes verified via curl against the live QA store on
/// 2026-08-22 (existing product #48, plus a scratch product #49 created,
/// updated, status-changed, stock-changed and deleted during verification).
/// See `product.dart`'s doc comment for the discrepancies found.
///
/// `POST /uploads` (multipart image upload, per the docs) returned a 502
/// from the live server on every attempt during this integration pass —
/// a platform-level "Service is not reachable" page, not a Laravel error,
/// so it looks like an outage of a separate upload microservice rather
/// than an API bug. No screen in this app currently exposes a working
/// image picker (both the create and detail screens show a static
/// placeholder icon), so there was nothing to wire it into regardless;
/// revisit `ApiClient.upload()` for this once the endpoint is reachable.
class ApiProductRepository implements ProductRepository {
  final ApiClient _client;

  ApiProductRepository(this._client);

  @override
  Future<NetworkResult<ProductsPage>> getProducts({
    String? status,
    String? search,
    bool? lowStock,
    int page = 1,
  }) {
    return _client.get(
      '/products',
      query: {
        'page': page,
        'status': ?status,
        'search': ?search,
        if (lowStock == true) 'low_stock': 1,
      },
      parse: (json) => ProductsPage.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<Product>> getProduct(int id) {
    return _client.get(
      '/products/$id',
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Product>> createProduct({
    required String name,
    required double price,
    double? compareAt,
    required int stock,
    required int lowStockThreshold,
    required bool asDraft,
  }) {
    return _client.post(
      '/products',
      body: {
        'name': name,
        'type': 'simple',
        'price': price,
        'compare_at_price': ?compareAt,
        'status': asDraft ? 'draft' : 'active',
        // The API only starts tracking stock when this is sent explicitly —
        // see the discrepancy note in `product.dart`.
        'track_inventory': true,
        'stock_quantity': stock,
        'low_stock_threshold': lowStockThreshold,
      },
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Product>> updateProduct(
    int id, {
    required String name,
    required double price,
    double? compareAt,
    required int stock,
    required int lowStockThreshold,
    required bool asDraft,
  }) {
    // PUT clears anything omitted (per the docs), so this always sends the
    // full payload rather than a partial diff.
    return _client.put(
      '/products/$id',
      body: {
        'name': name,
        'type': 'simple',
        'price': price,
        'compare_at_price': ?compareAt,
        'status': asDraft ? 'draft' : 'active',
        'track_inventory': true,
        'stock_quantity': stock,
        'low_stock_threshold': lowStockThreshold,
      },
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Product>> toggleStatus(int id, {required bool active}) {
    return _client.patch(
      '/products/$id/status',
      body: {'status': active ? 'active' : 'draft'},
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Product>> updateStock(
    int id, {
    required int stock,
    int? lowStockThreshold,
  }) {
    return _client.patch(
      '/products/$id/stock',
      body: {
        'stock_quantity': stock,
        'low_stock_threshold': ?lowStockThreshold,
      },
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<void>> deleteProduct(int id) {
    return _client.delete('/products/$id', parse: (_) {});
  }
}
