import 'package:get/get.dart';

import '../../../../shared/models/product.dart';
import '../../../../shared/services/commerce_calculator.dart';
import '../../domain/product_repository.dart';

enum ProductsFilter { all, active, draft, low }

class ProductsController extends GetxController {
  final ProductRepository _repository;

  ProductsController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final products = <Product>[].obs;
  final filter = ProductsFilter.all.obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    // The list endpoint is paginated server-side; loading up to the max
    // `per_page` (100) keeps the existing "load everything, filter
    // client-side" UI behaviour working without a full pagination rebuild.
    final result = await _repository.getProducts();
    result.when(
      success: (page) {
        products.assignAll(page.data);
        totalCount.value = page.total;
      },
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  void setFilter(ProductsFilter f) => filter.value = f;

  List<Product> get filtered {
    switch (filter.value) {
      case ProductsFilter.all:
        return products.toList();
      case ProductsFilter.active:
        return products.where((p) => p.status == ProductStatus.active).toList();
      case ProductsFilter.draft:
        return products.where((p) => p.status == ProductStatus.draft).toList();
      case ProductsFilter.low:
        return products.where((p) => p.isLowStock).toList();
    }
  }

  int get activeCount =>
      products.where((p) => p.status == ProductStatus.active).length;
  int get draftCount =>
      products.where((p) => p.status == ProductStatus.draft).length;
  int get lowStockCount => CommerceCalculator.lowStockCount(products);

  Future<void> toggleStatus(int id) async {
    final index0 = products.indexWhere((p) => p.id == id);
    if (index0 == -1) return;
    final current = products[index0];
    final result = await _repository.toggleStatus(
      id,
      active: current.status != ProductStatus.active,
    );
    result.when(
      success: (updated) {
        final index = products.indexWhere((p) => p.id == id);
        if (index != -1) products[index] = updated;
      },
      failure: (e) => errorMessage.value = e.message,
    );
  }

  Future<bool> deleteProduct(int id) async {
    final result = await _repository.deleteProduct(id);
    return result.when(
      success: (_) {
        products.removeWhere((p) => p.id == id);
        return true;
      },
      failure: (_) => false,
    );
  }
}
