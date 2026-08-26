import 'package:get/get.dart';

import '../../../../core/network/network_result.dart';
import '../../../../shared/models/payout.dart';
import '../../domain/payout_repository.dart';

class MoneyController extends GetxController {
  final PayoutRepository _repository;

  MoneyController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final payouts = <Payout>[].obs;
  final Rxn<Earnings> earnings = Rxn<Earnings>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    final NetworkResult<List<Payout>> payoutsResult;
    final NetworkResult<Earnings> earningsResult;
    (payoutsResult, earningsResult) = (
      await _repository.getPayouts(),
      await _repository.getEarnings(),
    );

    payoutsResult.when(
      success: (data) => payouts.assignAll(data),
      failure: (e) => errorMessage.value = e.message,
    );
    earningsResult.when(
      success: (data) => earnings.value = data,
      failure: (e) => errorMessage.value ??= e.message,
    );

    isLoading.value = false;
  }

  double get paidTotal => earnings.value?.paid ?? 0;
  double get inProgressTotal => earnings.value?.inProgress ?? 0;
  double get unsettled => earnings.value?.unsettled ?? 0;
  double get lifetimeGrossSales => earnings.value?.lifetimeGrossSales ?? 0;
  double get lifetimeCommission => earnings.value?.lifetimeCommission ?? 0;
  double get lifetimeEarning => earnings.value?.lifetimeEarning ?? 0;
  double get commissionRate => earnings.value?.commissionRate ?? 0;
}
