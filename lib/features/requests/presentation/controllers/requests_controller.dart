import 'package:get/get.dart';

import '../../../../shared/models/service_request.dart';
import '../../domain/request_repository.dart';

class RequestsController extends GetxController {
  final RequestRepository _repository;

  RequestsController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final requests = <ServiceRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getRequests();
    result.when(
      success: (data) => requests.assignAll(data),
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  int get pendingCount =>
      requests.where((r) => r.status == RequestStatus.pending).length;
}
