import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/products_controller.dart';

class ProductsScreen extends GetView<ProductsController> {
  const ProductsScreen({super.key});

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
                label: 'All ${controller.products.length}',
                selected: controller.filter.value == ProductsFilter.all,
                onTap: () => controller.setFilter(ProductsFilter.all),
              ),
              AppChip(
                label: 'Active ${controller.activeCount}',
                selected: controller.filter.value == ProductsFilter.active,
                onTap: () => controller.setFilter(ProductsFilter.active),
              ),
              AppChip(
                label: 'Draft ${controller.draftCount}',
                selected: controller.filter.value == ProductsFilter.draft,
                onTap: () => controller.setFilter(ProductsFilter.draft),
              ),
              AppChip(
                label: 'Low stock ${controller.lowStockCount}',
                selected: controller.filter.value == ProductsFilter.low,
                onTap: () => controller.setFilter(ProductsFilter.low),
              ),
            ],
          ),
          if (list.isEmpty)
            const AppEmptyState(
              emoji: '🏷️',
              message: 'Nothing matches that filter.',
            )
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    AppListRow(
                      leading: AppThumb(emoji: list[i].emoji),
                      title: list[i].name,
                      subtitle:
                          '${CurrencyFormatter.short(list[i].price)} · ${list[i].isOutOfStock ? "Out of stock" : "${list[i].stock} in stock"}',
                      trailing: _statusPill(list[i]),
                      showDivider: i != list.length - 1,
                      onTap: () =>
                          context.push(AppRoutes.productDetailPath(list[i].id)),
                    ),
                ],
              ),
            ),
          AppButton(
            label: 'Add a product',
            onPressed: () => context.push(AppRoutes.newProduct),
          ),
        ],
      );
    });
  }

  Widget _statusPill(Product product) {
    if (product.status.name == 'draft') {
      return const AppStatusPill(label: 'Draft', variant: AppPillVariant.mute);
    }
    if (product.isOutOfStock) {
      return const AppStatusPill(label: 'Out', variant: AppPillVariant.crit);
    }
    if (product.isLowStock) {
      return const AppStatusPill(label: 'Low', variant: AppPillVariant.warn);
    }
    return const AppStatusPill(label: 'Active', variant: AppPillVariant.ok);
  }
}
