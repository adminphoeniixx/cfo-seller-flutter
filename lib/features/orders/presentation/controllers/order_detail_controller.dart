import 'package:get/get.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../shared/models/order.dart';
import '../../domain/order_repository.dart';

class OrderDetailController extends GetxController {
  final OrderRepository _repository;
  final int orderId;

  OrderDetailController(this._repository, this.orderId);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final Rxn<Order> order = Rxn<Order>();

  /// Target `quantity_fulfilled` per item id — the API treats `fulfill`'s
  /// `items[].quantity` as an absolute value, not a delta (verified via
  /// curl, see `ApiOrderRepository`'s doc comment), so this map always
  /// holds "how many should be marked fulfilled after this call", seeded
  /// from each item's current `quantity_fulfilled`.
  final packedByItemId = <int, int>{}.obs;

  final deliveryPartners = <DeliveryPartner>[].obs;
  final carrier = ''.obs;
  final tracking = ''.obs;
  final isSubmitting = false.obs;
  final isAddingNote = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    _loadDeliveryPartners();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getOrder(orderId);
    result.when(
      success: (o) {
        order.value = o;
        packedByItemId.assignAll({
          for (final i in o.items) i.id: i.quantityFulfilled,
        });
        carrier.value = o.carrier ?? '';
        tracking.value = o.trackingNumber ?? '';
      },
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<void> _loadDeliveryPartners() async {
    final result = await _repository.getDeliveryPartners();
    result.when(
      success: (list) => deliveryPartners.assignAll(list),
      failure: (_) {},
    );
  }

  void setPacked(int itemId, int qty, int max) {
    packedByItemId[itemId] = qty.clamp(0, max);
  }

  Future<Order?> submitFulfilment() async {
    isSubmitting.value = true;
    final result = await _repository.fulfilOrder(
      orderId,
      quantityByItemId: Map.of(packedByItemId),
      carrier: carrier.value,
      tracking: tracking.value,
    );
    isSubmitting.value = false;
    return result.when(
      success: (o) {
        order.value = o;
        packedByItemId.assignAll({
          for (final i in o.items) i.id: i.quantityFulfilled,
        });
        if (o.fulfillmentStatus == FulfillmentStatus.fulfilled) {
          Get.find<AnalyticsService>().logOrderFulfilled(orderId: orderId);
        }
        return o;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return null;
      },
    );
  }

  Future<bool> submitNote(String note) async {
    if (note.trim().isEmpty) return false;
    isAddingNote.value = true;
    final result = await _repository.addNote(orderId, note.trim());
    isAddingNote.value = false;
    return result.when(
      success: (_) => true,
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }
}
