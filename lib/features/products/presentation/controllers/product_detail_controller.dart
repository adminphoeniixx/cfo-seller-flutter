import 'package:get/get.dart';

import '../../../../shared/models/product.dart';
import '../../domain/product_repository.dart';
import 'product_draft.dart';
import 'product_form_controller_base.dart';

class ProductDetailController extends ProductFormControllerBase {
  final ProductRepository _repository;
  final int productId;

  ProductDetailController(
    this._repository,
    this.productId,
    super.catalogRepository,
    super.uploadRepository,
  );

  final isLoading = true.obs;
  final isSaving = false.obs;
  final Rxn<Product> product = Rxn<Product>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final options = await loadOptions();
    final result = await _repository.getProduct(productId);
    result.when(
      success: (p) {
        product.value = p;
        draft.value = ProductDraft.fromProduct(p, options);
      },
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  @override
  Future<bool> save() async {
    final d = draft.value;
    if (d == null) return false;

    if (d.name.trim().isEmpty) {
      errorMessage.value = 'A title is needed.';
      return false;
    }
    if (double.tryParse(d.price) == null) {
      errorMessage.value = 'A valid price is needed.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = null;
    fieldErrors.value = null;

    final result = await _repository.updateProduct(productId, d.toPayload());

    isSaving.value = false;
    return result.when(
      success: (updated) {
        product.value = updated;
        refreshProductsList();
        return true;
      },
      failure: (e) {
        mapValidationError(e);
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
      success: (p) {
        product.value = p;
        refreshProductsList();
      },
      failure: (e) => errorMessage.value = e.message,
    );
  }

  Future<bool> delete() async {
    final result = await _repository.deleteProduct(productId);
    return result.when(
      success: (_) {
        refreshProductsList();
        return true;
      },
      failure: (_) => false,
    );
  }
}
