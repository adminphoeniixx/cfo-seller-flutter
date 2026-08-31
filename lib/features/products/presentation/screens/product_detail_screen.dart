import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/product_form_controller_base.dart';
import '../widgets/product_form_body.dart';

class ProductDetailScreen extends StatelessWidget {
  final String tag;

  const ProductDetailScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    final detail = controller as ProductDetailController;

    Future<bool> confirmDiscard() async {
      if (controller.draft.value?.dirty != true) return true;
      final leave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave page with unsaved changes?'),
          content: const Text('Leaving this page will delete all unsaved changes.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave page')),
          ],
        ),
      );
      return leave ?? false;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Obx(() {
        final product = detail.product.value;
        return Scaffold(
          appBar: AppAppBar(
            title: product?.name ?? 'Product',
            subtitle: product?.sku,
            showBack: true,
            onBack: () async {
              if (await confirmDiscard() && context.mounted) Navigator.of(context).pop();
            },
            showSave: true,
            onSave: detail.isSaving.value
                ? null
                : () async {
                    final ok = await controller.save();
                    if (ok && context.mounted) {
                      Navigator.of(context).pop();
                      AppMessenger.show('Saved');
                    } else if (controller.errorMessage.value != null) {
                      AppMessenger.show(controller.errorMessage.value!, title: 'Could not save');
                    }
                  },
          ),
          body: _body(context, detail),
        );
      }),
    );
  }

  Widget _body(BuildContext context, ProductDetailController controller) {
    if (controller.isLoading.value) return const AppLoading();
    final product = controller.product.value;
    if (product == null) {
      return AppErrorState(
        message: controller.errorMessage.value ?? 'Not found',
        onRetry: controller.load,
      );
    }

    return Column(
      children: [
        if (product.sold != null || product.revenue != null || product.orderCount != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: AppKpiCard(
                    label: 'Sold',
                    value: '${product.sold ?? 0}',
                    valueFontSize: 16,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppKpiCard(
                    label: 'Revenue',
                    value: CurrencyFormatter.short(product.revenue ?? 0),
                    valueFontSize: 16,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppKpiCard(
                    label: 'Orders',
                    value: '${product.orderCount ?? 0}',
                    valueFontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: ProductFormBody(controller: controller)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: AppButton.danger(
            label: 'Delete this product',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete this product?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true) {
                final ok = await controller.delete();
                if (ok && context.mounted) {
                  Navigator.of(context).pop();
                  AppMessenger.show('Product deleted');
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
