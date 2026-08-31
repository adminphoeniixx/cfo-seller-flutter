import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/product_payload.dart';

abstract class ProductRepository {
  Future<NetworkResult<ProductsPage>> getProducts({
    String? status,
    String? search,
    bool? lowStock,
    int page = 1,
  });
  Future<NetworkResult<Product>> getProduct(int id);
  Future<NetworkResult<Product>> toggleStatus(int id, {required bool active});
  Future<NetworkResult<void>> deleteProduct(int id);
  Future<NetworkResult<Product>> createProduct(ProductPayload payload);
  Future<NetworkResult<Product>> updateProduct(int id, ProductPayload payload);
  Future<NetworkResult<Product>> updateStock(
    int id, {
    required int stock,
    int? lowStockThreshold,
  });
}
