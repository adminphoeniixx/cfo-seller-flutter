import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';

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
  Future<NetworkResult<Product>> createProduct({
    required String name,
    required double price,
    double? compareAt,
    required int stock,
    required int lowStockThreshold,
    required bool asDraft,
  });
  Future<NetworkResult<Product>> updateProduct(
    int id, {
    required String name,
    required double price,
    double? compareAt,
    required int stock,
    required int lowStockThreshold,
    required bool asDraft,
  });
  Future<NetworkResult<Product>> updateStock(
    int id, {
    required int stock,
    int? lowStockThreshold,
  });
}
