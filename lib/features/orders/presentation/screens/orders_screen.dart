import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/orders_controller.dart';
import '../widgets/fulfillment_pill.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const AppLoading();
      if (controller.errorMessage.value != null) {
        return AppErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.load,
        );
      }

      final list = controller.filtered;

      return AppScreen(
        children: [
          AppChipRow(
            children: [
              AppChip(
                label: 'To pack ${controller.toPackCount}',
                selected: controller.filter.value == OrdersFilter.unfulfilled,
                onTap: () => controller.setFilter(OrdersFilter.unfulfilled),
              ),
              AppChip(
                label: 'Shipped ${controller.fulfilledCount}',
                selected: controller.filter.value == OrdersFilter.fulfilled,
                onTap: () => controller.setFilter(OrdersFilter.fulfilled),
              ),
              AppChip(
                label: 'All ${controller.orders.length}',
                selected: controller.filter.value == OrdersFilter.all,
                onTap: () => controller.setFilter(OrdersFilter.all),
              ),
            ],
          ),
          if (list.isEmpty)
            const AppEmptyState(
              emoji: '📦',
              message: 'Nothing here.\nNew orders land in this tab.',
            )
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    AppListRow(
                      title: list[i].number,
                      titleTrailing: FulfillmentPill(
                        status: list[i].fulfillmentStatus,
                      ),
                      subtitle:
                          '${list[i].items.length} item${list[i].items.length > 1 ? 's' : ''} · ${list[i].customer.name} · ${_dateLabel(list[i].placedAt)}',
                      amount: CurrencyFormatter.short(list[i].total),
                      showChevron: true,
                      showDivider: i != list.length - 1,
                      onTap: () =>
                          context.push(AppRoutes.orderDetailPath(list[i].id)),
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }

  static String _dateLabel(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
