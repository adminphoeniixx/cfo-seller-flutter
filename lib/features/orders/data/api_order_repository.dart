import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/order.dart';
import '../domain/order_repository.dart';

/// Talks to the real `/orders` and `/delivery-partners` endpoints. List,
/// summary, show and delivery-partners shapes verified via curl against
/// live QA order #161 on 2026-08-22 (see `order.dart`'s doc comment for
/// discrepancies found). `fulfill`/`notes` mutation response shapes were
/// exercised for real against that same order.
///
/// Discrepancy found live: the docs describe `items[].quantity` for
/// `fulfill` without saying whether it's a delta or an absolute value.
/// Verified via curl it is ABSOLUTE — posting `quantity: 1` on a line
/// already fulfilled 2/2 set `quantity_fulfilled` back down to 1, and
/// posting `quantity: 2` again restored it to 2/2 (fulfilled). So callers
/// must always send the *target* fulfilled quantity per line, not "how
/// many more to pack". Also observed: the order-level `fulfillment_status`
/// can still read `partially_fulfilled` for one call even once every one
/// of the caller's own lines shows `quantity_fulfilled == quantity` — it
/// did not flip back to `fulfilled` on the very next `GET /orders/{id}` in
/// this test, which the docs' "recomputed from every line" description
/// doesn't fully explain (order #161 may simply have another seller's
/// unfulfilled line, per the docs' shared-basket note).
class ApiOrderRepository implements OrderRepository {
  final ApiClient _client;

  ApiOrderRepository(this._client);

  @override
  Future<NetworkResult<OrdersPage>> getOrders({
    String? status,
    bool? needsPacking,
    String? search,
    int page = 1,
  }) {
    return _client.get(
      '/orders',
      query: {
        'page': page,
        'status': ?status,
        'search': ?search,
        if (needsPacking == true) 'needs_packing': 1,
      },
      parse: (json) => OrdersPage.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<OrdersSummary>> getSummary() {
    return _client.get(
      '/orders/summary',
      parse: (json) => OrdersSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<Order>> getOrder(int id) {
    return _client.get(
      '/orders/$id',
      parse: (json) => Order.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Order>> fulfilOrder(
    int id, {
    required Map<int, int> quantityByItemId,
    required String carrier,
    required String tracking,
  }) {
    return _client.post(
      '/orders/$id/fulfill',
      body: {
        'items': [
          for (final entry in quantityByItemId.entries)
            if (entry.value > 0) {'id': entry.key, 'quantity': entry.value},
        ],
        if (tracking.isNotEmpty) 'tracking_number': tracking,
        if (carrier.isNotEmpty) 'carrier': carrier,
      },
      parse: (json) => Order.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<void>> addNote(int id, String note) {
    return _client.post(
      '/orders/$id/notes',
      body: {'note': note},
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<List<DeliveryPartner>>> getDeliveryPartners() {
    return _client.get(
      '/delivery-partners',
      parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
          .map((e) => DeliveryPartner.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
