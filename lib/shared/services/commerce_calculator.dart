import '../models/order.dart';
import '../models/product.dart';

/// Central home for calculations the prototype repeated inline (order
/// totals, seller earnings after commission, to-pack / low-stock counts).
/// Any screen needing these must call through here rather than
/// recompute them locally.
class CommerceCalculator {
  const CommerceCalculator._();

  static double orderTotal(Order order) => order.total;

  static double commission(double total, num commissionPercent) =>
      (total * commissionPercent) / 100;

  static double orderEarnings(Order order, num commissionPercent) =>
      orderTotal(order) - commission(orderTotal(order), commissionPercent);

  static int ordersToPackCount(List<Order> orders) =>
      orders.where((o) => o.needsPacking).length;

  static int lowStockCount(List<Product> products) =>
      products.where((p) => p.isLowStock).length;
}
