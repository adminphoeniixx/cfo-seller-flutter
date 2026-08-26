import 'package:get/get.dart';

import '../../../../shared/models/device.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../domain/device_repository.dart';

class DeviceController extends GetxController {
  final DeviceRepository _repository;

  DeviceController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final devices = <Device>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getDevices();
    result.when(
      success: (data) => devices.assignAll(data),
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<bool> revokeDevice(int id) async {
    final result = await _repository.revokeDevice(id);
    return result.when(
      success: (_) {
        devices.removeWhere((d) => d.id == id);
        return true;
      },
      failure: (e) {
        AppMessenger.show(e.message);
        return false;
      },
    );
  }
}
