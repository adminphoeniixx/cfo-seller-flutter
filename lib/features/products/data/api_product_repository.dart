import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/product_payload.dart';
import '../domain/product_repository.dart';

/// Matches `GET /products`, `GET /products/{id}`, `POST /products`,
/// `PUT /products/{id}`, `PATCH /products/{id}/status` and
/// `PATCH /products/{id}/stock` response shapes — verified via curl against
/// the live QA store on 2026-08-22 (existing product #48, plus a scratch
/// product #49 created, updated, status-changed, stock-changed and deleted
/// during verification) for the original 7-field payload. `createProduct`/
/// `updateProduct` now send the full `ProductPayload` (28 fields, see
/// `product_payload.dart`) — the extra fields follow the spec's documented
/// shape but are **not yet curl-verified**; see `product.dart`'s doc comment.
///
/// `POST /uploads` (multipart image upload) is now wired via
/// `ApiUploadRepository` — see that file for the 502 it returned from the
/// live server during the original integration pass.
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
  Future<NetworkResult<Product>> createProduct(ProductPayload payload) {
    return _client.post(
      '/products',
      body: payload.toJson(),
      parse: (json) => Product.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Product>> updateProduct(
    int id,
    ProductPayload payload,
  ) {
    // PUT clears anything omitted (per the docs), so this always sends the
    // full payload rather than a partial diff.
    return _client.put(
      '/products/$id',
      body: payload.toJson(),
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
    // Returns 422 on a variable product — edit its variants instead (see
    // `seller-app-product-form.md` §3 "Variants").
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
