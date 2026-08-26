import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final priceCtrl = TextEditingController();
    final compareCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final lowCtrl = TextEditingController();
    var seeded = false;

    return Obx(() {
      final product = controller.product.value;
      if (product != null && !seeded) {
        seeded = true;
        priceCtrl.text = product.price.toStringAsFixed(0);
        compareCtrl.text = product.compareAt?.toStringAsFixed(0) ?? '';
        nameCtrl.text = product.name;
        stockCtrl.text = '${product.stock}';
        lowCtrl.text = '${product.lowStockThreshold}';
      }

      return Scaffold(
        appBar: AppAppBar(
          title: product?.name ?? 'Product',
          subtitle: product?.sku,
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
          showSave: true,
          onSave: controller.isSaving.value
              ? null
              : () async {
                  final price = double.tryParse(priceCtrl.text);
                  if (price == null) {
                    AppMessenger.show(
                      'Enter a valid price.',
                      title: 'Check your entries',
                    );
                    return;
                  }
                  final ok = await controller.save(
                    name: nameCtrl.text.trim(),
                    price: price,
                    compareAt: double.tryParse(compareCtrl.text),
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                    lowStockThreshold: int.tryParse(lowCtrl.text) ?? 0,
                  );
                  if (ok && context.mounted) {
                    Navigator.of(context).pop();
                    AppMessenger.show('Saved');
                  } else if (controller.errorMessage.value != null) {
                    AppMessenger.show(
                      controller.errorMessage.value!,
                      title: 'Could not save',
                    );
                  }
                },
        ),
        body: _body(
          context,
          product,
          nameCtrl,
          priceCtrl,
          compareCtrl,
          stockCtrl,
          lowCtrl,
        ),
      );
    });
  }

  Widget _body(
    BuildContext context,
    Product? product,
    TextEditingController nameCtrl,
    TextEditingController priceCtrl,
    TextEditingController compareCtrl,
    TextEditingController stockCtrl,
    TextEditingController lowCtrl,
  ) {
    if (controller.isLoading.value) return const AppLoading();
    if (product == null) {
      return AppErrorState(
        message: controller.errorMessage.value ?? 'Not found',
        onRetry: controller.load,
      );
    }

    return AppScreen(
      children: [
        Row(
          children: [
            AppThumb(emoji: product.emoji, size: 62),
            const SizedBox(width: 9),
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(AppIcons.add, color: context.colors.ink3, size: 22),
            ),
          ],
        ),
        AppTextField(label: 'Name', controller: nameCtrl),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Price',
                controller: priceCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: AppTextField(
                label: 'Compare at',
                placeholder: '—',
                controller: compareCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        if (product.type == ProductType.variable) ...[
          const AppBanner(
            text:
                'Stock for a variable product is the sum of its variants. Edit the variants to change it.',
            variant: AppBannerVariant.warn,
          ),
          AppListRow(
            title: '3 variants',
            subtitle: 'S · M · L',
            showChevron: true,
            onTap: () => AppMessenger.show('Not part of this preview yet'),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Stock',
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AppTextField(
                  label: 'Low at',
                  controller: lowCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        AppTapField(
          label: 'Category',
          value: product.category,
          onTap: () => AppMessenger.show('Not part of this preview yet'),
        ),
        AppTapField(
          label: 'Type',
          value: product.type == ProductType.variable ? 'Variable' : 'Simple',
          onTap: () => AppMessenger.show('Not part of this preview yet'),
        ),
        AppTapField(
          label: 'Status',
          value: product.status == ProductStatus.active ? 'Active' : 'Draft',
          onTap: () async {
            await controller.toggleStatus();
            final updated = controller.product.value;
            if (updated != null) {
              AppMessenger.show(
                updated.status == ProductStatus.active
                    ? 'Product is live'
                    : 'Moved to draft',
              );
            }
          },
        ),
        AppButton.danger(
          label: 'Delete this product',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete this product?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
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
      ],
    );
  }
}
