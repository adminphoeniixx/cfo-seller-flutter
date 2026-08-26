import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../orders/presentation/controllers/orders_controller.dart';
import '../../../products/presentation/controllers/products_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/sales_spark_chart.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      if (controller.isLoading.value) return const AppLoading();
      if (controller.errorMessage.value != null) {
        return AppErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.load,
        );
      }

      final commissionPercent = auth.store?.commissionRate ?? 0;
      final commissionLabel = commissionPercent % 1 == 0
          ? commissionPercent.toInt().toString()
          : commissionPercent.toString();
      final totals = controller.dashboard.value?.totals;
      final top = controller.bestSellers;

      return AppScreen(
        children: [
          AppKpiGrid(
            children: [
              AppKpiCard(
                label: 'Sales',
                value: CurrencyFormatter.short(totals?.sales ?? 0),
                detail: '${totals?.orders ?? 0} orders',
              ),
              AppKpiCard(
                label: 'You earned',
                value: CurrencyFormatter.short(totals?.earning ?? 0),
                detail: 'after $commissionLabel% fee',
              ),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(title: 'Sales this month'),
                const SizedBox(height: 9),
                SalesSparkChart(heightsPercent: controller.sparkBarHeights),
              ],
            ),
          ),
          const AppSectionHeader(title: 'Needs attention'),
          AppCard(
            flat: true,
            child: Column(
              children: [
                AppListRow(
                  title: 'Orders to pack',
                  trailing: AppStatusPill(
                    label: '${controller.toPackCount}',
                    variant: AppPillVariant.warn,
                  ),
                  showChevron: true,
                  onTap: () {
                    if (Get.isRegistered<OrdersController>()) {
                      Get.find<OrdersController>().setFilter(
                        OrdersFilter.unfulfilled,
                      );
                    }
                    context.go(AppRoutes.orders);
                  },
                ),
                AppListRow(
                  title: 'Cancellation & refund requests',
                  trailing: AppStatusPill(
                    label: '${controller.pendingRequestsCount}',
                    variant: AppPillVariant.crit,
                  ),
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.requests),
                ),
                AppListRow(
                  title: 'Products running low',
                  trailing: AppStatusPill(
                    label: '${controller.lowStockCount}',
                    variant: AppPillVariant.warn,
                  ),
                  showChevron: true,
                  showDivider: false,
                  onTap: () {
                    if (Get.isRegistered<ProductsController>()) {
                      Get.find<ProductsController>().setFilter(
                        ProductsFilter.low,
                      );
                    }
                    context.go(AppRoutes.products);
                  },
                ),
              ],
            ),
          ),
          AppSectionHeader(
            title: 'Best sellers',
            actionLabel: 'All products',
            onAction: () => context.go(AppRoutes.products),
          ),
          if (top.isEmpty)
            const AppEmptyState(
              emoji: '📦',
              message: 'No sales in this period yet.',
            )
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  // The dashboard endpoint returns only name/units/revenue
                  // for top products — no id, so unlike the rest of the app
                  // this row can't deep-link to a product detail screen.
                  for (var i = 0; i < top.length; i++)
                    AppListRow(
                      leading: const AppThumb(emoji: '🏷️'),
                      title: top[i].name,
                      subtitle: '${top[i].units} sold',
                      amount: CurrencyFormatter.short(top[i].revenue),
                      showDivider: i != top.length - 1,
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
