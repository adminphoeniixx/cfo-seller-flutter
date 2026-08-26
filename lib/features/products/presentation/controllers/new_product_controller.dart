import 'package:get/get.dart';

import '../../domain/product_repository.dart';

class NewProductController extends GetxController {
  final ProductRepository _repository;

  NewProductController(this._repository);

  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<bool> submit({
    required String name,
    required String price,
    required String compareAt,
    required String stock,
    required String lowAt,
    required bool asDraft,
  }) async {
    if (name.trim().isEmpty || double.tryParse(price) == null) {
      errorMessage.value = 'Enter a name and a valid price.';
      return false;
    }
    isSubmitting.value = true;
    errorMessage.value = null;
    final result = await _repository.createProduct(
      name: name.trim(),
      price: double.parse(price),
      compareAt: double.tryParse(compareAt),
      stock: int.tryParse(stock) ?? 0,
      lowStockThreshold: int.tryParse(lowAt) ?? 5,
      asDraft: asDraft,
    );
    isSubmitting.value = false;
    return result.when(
      success: (_) => true,
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }
}
