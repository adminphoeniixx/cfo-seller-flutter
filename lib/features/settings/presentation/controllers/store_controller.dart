import 'package:get/get.dart';

import '../../../../shared/models/store.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/store_repository.dart';

/// Owns the Store Details screen's own load/edit/save cycle — distinct
/// from `AuthController.store`, which only ever reflects the snapshot
/// returned by login/register/me. On successful save this also pushes the
/// fresh store back into `AuthController.seller` so the rest of the app
/// (app bar title, commission display, etc.) stays in sync without an
/// extra `/me` round trip.
class StoreController extends GetxController {
  final StoreRepository _repository;
  final AuthController _authController;

  StoreController(this._repository, this._authController);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final Rxn<Store> store = Rxn<Store>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getStore();
    result.when(
      success: (s) => store.value = s,
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<bool> save({
    required String name,
    String? storeEmail,
    String? phone,
    String? description,
    String? addressLine1,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? gstNumber,
    String? payoutMethod,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfsc,
  }) async {
    isSaving.value = true;
    errorMessage.value = null;
    final result = await _repository.updateStore(
      name: name,
      storeEmail: storeEmail,
      phone: phone,
      description: description,
      addressLine1: addressLine1,
      city: city,
      state: state,
      postcode: postcode,
      country: country,
      gstNumber: gstNumber,
      payoutMethod: payoutMethod,
      bankAccountName: bankAccountName,
      bankAccountNumber: bankAccountNumber,
      bankIfsc: bankIfsc,
    );
    isSaving.value = false;
    return result.when(
      success: (s) {
        store.value = s;
        _authController.refreshMe();
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }
}
