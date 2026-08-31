import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/models/product.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductVariantScreen extends StatefulWidget {
  final int index;
  final String tag;

  const ProductVariantScreen({super.key, required this.index, required this.tag});

  @override
  State<ProductVariantScreen> createState() => _ProductVariantScreenState();
}

class _ProductVariantScreenState extends State<ProductVariantScreen> {
  late final ProductFormControllerBase controller;
  late final TextEditingController price;
  late final TextEditingController stock;
  late final TextEditingController sku;
  late final TextEditingController compareAt;
  late final TextEditingController weight;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProductFormControllerBase>(tag: widget.tag);
    final v = controller.draft.value!.variants[widget.index];
    price = TextEditingController(text: _trim(v.price));
    stock = TextEditingController(text: '${v.stockQuantity}');
    sku = TextEditingController(text: v.sku ?? '');
    compareAt = TextEditingController(text: v.compareAtPrice == null ? '' : _trim(v.compareAtPrice!));
    weight = TextEditingController(text: _trim(v.weight));
  }

  String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    price.dispose();
    stock.dispose();
    sku.dispose();
    compareAt.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final draft = controller.draft.value;
      if (draft == null || widget.index >= draft.variants.length) return const AppLoading();
      final v = draft.variants[widget.index];
      final errors = controller.errorsForVariant(widget.index);

      return AppScreen(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Price',
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => _update((v) => v.copyWith(price: double.tryParse(val) ?? 0)),
                  errorText: errors['price']?.join(' '),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AppTextField(
                  label: 'Available',
                  controller: stock,
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      _update((v) => v.copyWith(stockQuantity: int.tryParse(val) ?? 0)),
                  errorText: errors['stock_quantity']?.join(' '),
                ),
              ),
            ],
          ),
          AppTextField(
            label: 'SKU',
            controller: sku,
            placeholder: 'Optional',
            onChanged: (val) => _update((v) => v.copyWith(sku: val)),
            errorText: errors['sku']?.join(' '),
          ),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Compare at',
                  controller: compareAt,
                  placeholder: '—',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) =>
                      _update((v) => v.copyWith(compareAtPrice: double.tryParse(val))),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AppTextField(
                  label: 'Weight (kg)',
                  controller: weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => _update((v) => v.copyWith(weight: double.tryParse(val) ?? 0)),
                ),
              ),
            ],
          ),
          AppSwitch(
            label: 'Available to buy',
            subLabel: 'Switch off to hide just this variant',
            value: v.isActive,
            onChanged: (_) => controller.toggleVariantActive(widget.index),
          ),
          AppButton.danger(
            label: 'Remove this variant',
            onPressed: () {
              controller.removeVariant(widget.index);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  void _update(ProductVariant Function(ProductVariant v) apply) {
    controller.updateVariant(widget.index, apply);
  }
}
