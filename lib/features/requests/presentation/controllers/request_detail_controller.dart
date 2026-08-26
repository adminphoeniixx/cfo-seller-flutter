import 'package:get/get.dart';

import '../../../../shared/models/service_request.dart';
import '../../domain/request_repository.dart';

class RequestDetailController extends GetxController {
  final RequestRepository _repository;
  final int requestId;

  RequestDetailController(this._repository, this.requestId);

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final Rxn<ServiceRequest> request = Rxn<ServiceRequest>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getRequest(requestId);
    result.when(
      success: (r) => request.value = r,
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<bool> respond(String message) async {
    isSubmitting.value = true;
    final result = await _repository.respond(requestId, message);
    isSubmitting.value = false;
    return result.when(success: (_) => true, failure: (_) => false);
  }
}
