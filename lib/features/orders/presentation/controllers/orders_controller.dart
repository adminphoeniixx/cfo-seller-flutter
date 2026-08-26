import 'package:get/get.dart';

import '../../../../shared/models/order.dart';
import '../../domain/order_repository.dart';

enum OrdersFilter { unfulfilled, fulfilled, all }

/// Drives the Orders list screen: load, filter, and derived counts. Order
/// detail / fulfil screens read/write through the same repository so this
/// list refreshes after a "Mark as shipped" action.
class OrdersController extends GetxController {
  final OrderRepository _repository;

  OrdersController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final orders = <Order>[].obs;
  final filter = OrdersFilter.unfulfilled.obs;
  final summary = Rxn<OrdersSummary>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final ordersResult = await _repository.getOrders();
    ordersResult.when(
      success: (data) => orders.assignAll(data.data),
      failure: (e) => errorMessage.value = e.message,
    );

    final summaryResult = await _repository.getSummary();
    summaryResult.when(
      success: (data) => summary.value = data,
      failure: (_) {},
    );
    isLoading.value = false;
  }

  void setFilter(OrdersFilter f) => filter.value = f;

  List<Order> get filtered {
    switch (filter.value) {
      case OrdersFilter.unfulfilled:
        return orders
            .where((o) => o.fulfillmentStatus != FulfillmentStatus.fulfilled)
            .toList();
      case OrdersFilter.fulfilled:
        return orders
            .where((o) => o.fulfillmentStatus == FulfillmentStatus.fulfilled)
            .toList();
      case OrdersFilter.all:
        return orders.toList();
    }
  }

  int get toPackCount =>
      summary.value?.unfulfilled ?? orders.where((o) => o.needsPacking).length;
  int get fulfilledCount => orders
      .where((o) => o.fulfillmentStatus == FulfillmentStatus.fulfilled)
      .length;
}
