import 'package:get/get.dart';

import '../../../../shared/models/payout.dart';
import '../../domain/payout_repository.dart';

class PayoutDetailController extends GetxController {
  final PayoutRepository _repository;
  final int payoutId;

  PayoutDetailController(this._repository, this.payoutId);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final Rxn<Payout> payout = Rxn<Payout>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getPayout(payoutId);
    result.when(
      success: (p) => payout.value = p,
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }
}
