import 'package:get/get.dart';

import '../../../../shared/models/shipping_rate.dart';
import '../../domain/shipping_repository.dart';

class ShippingController extends GetxController {
  final ShippingRepository _repository;

  ShippingController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final zones = <ShippingZone>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getZones();
    result.when(
      success: (data) => zones.assignAll(data),
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }
}
