import 'package:get/get.dart';

import '../../../../shared/models/product.dart';
import '../../domain/product_repository.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _repository;
  final int productId;

  ProductDetailController(this._repository, this.productId);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final Rxn<Product> product = Rxn<Product>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getProduct(productId);
    result.when(
      success: (p) => product.value = p,
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<bool> save({
    required String name,
    required double price,
    double? compareAt,
    required int stock,
    required int lowStockThreshold,
  }) async {
    final current = product.value;
    if (current == null) return false;
    isSaving.value = true;
    final result = await _repository.updateProduct(
      productId,
      name: name,
      price: price,
      compareAt: compareAt,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      asDraft: current.status == ProductStatus.draft,
    );
    isSaving.value = false;
    return result.when(
      success: (updated) {
        product.value = updated;
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  Future<void> toggleStatus() async {
    final current = product.value;
    if (current == null) return;
    final result = await _repository.toggleStatus(
      productId,
      active: current.status != ProductStatus.active,
    );
    result.when(
      success: (p) => product.value = p,
      failure: (e) => errorMessage.value = e.message,
    );
  }

  Future<bool> delete() async {
    final result = await _repository.deleteProduct(productId);
    return result.when(success: (_) => true, failure: (_) => false);
  }
}
