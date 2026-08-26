import '../../../core/network/network_result.dart';
import '../../../shared/models/order.dart';

abstract class OrderRepository {
  Future<NetworkResult<OrdersPage>> getOrders({
    String? status,
    bool? needsPacking,
    String? search,
    int page = 1,
  });
  Future<NetworkResult<OrdersSummary>> getSummary();
  Future<NetworkResult<Order>> getOrder(int id);
  Future<NetworkResult<Order>> fulfilOrder(
    int id, {
    required Map<int, int> quantityByItemId,
    required String carrier,
    required String tracking,
  });
  Future<NetworkResult<void>> addNote(int id, String note);
  Future<NetworkResult<List<DeliveryPartner>>> getDeliveryPartners();
}
