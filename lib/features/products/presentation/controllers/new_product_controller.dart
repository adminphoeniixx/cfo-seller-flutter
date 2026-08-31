import '../../domain/product_repository.dart';
import 'product_draft.dart';
import 'product_form_controller_base.dart';

class NewProductController extends ProductFormControllerBase {
  final ProductRepository _repository;

  NewProductController(
    this._repository,
    super.catalogRepository,
    super.uploadRepository,
  );

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await loadOptions();
    draft.value = ProductDraft.blank();
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

    isSubmitting.value = true;
    errorMessage.value = null;
    fieldErrors.value = null;

    final result = await _repository.createProduct(d.toPayload());

    isSubmitting.value = false;
    return result.when(
      success: (_) {
        refreshProductsList();
        return true;
      },
      failure: (e) {
        mapValidationError(e);
        return false;
      },
    );
  }
}
