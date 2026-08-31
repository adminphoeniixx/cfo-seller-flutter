import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductOptionScreen extends StatelessWidget {
  final int attributeId;
  final String tag;

  const ProductOptionScreen({super.key, required this.attributeId, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    return Obx(() {
      final options = controller.options.value;
      final draft = controller.draft.value;
      if (options == null || draft == null) return const AppLoading();

      final attribute = options.attribute(attributeId);
      if (attribute == null) return const AppLoading();

      final picked = (draft.chosen[attributeId] ?? const []).toSet();

      return AppScreen(
        children: [
          AppCard(
            child: AppValueChips(
              values: [
                for (final v in attribute.values)
                  ValueChipData(
                    id: v.id,
                    label: v.value,
                    swatch: v.colorHex != null ? _parseColor(v.colorHex!) : null,
                  ),
              ],
              selected: picked,
              onToggle: (valueId) => controller.toggleValue(attributeId, valueId),
            ),
          ),
          Text(
            'Every combination across your options becomes a variant with its own '
            'price, stock and SKU. Rows you have already edited are kept.',
            style: AppTypography.note.copyWith(color: context.colors.ink3),
          ),
          AppButton(
            label: 'Done',
            onPressed: () {
              controller.doneOption();
              Navigator.of(context).pop();
            },
          ),
          AppButton.danger(
            label: 'Remove this option',
            onPressed: () {
              controller.removeOption(attributeId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  Color? _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
    return value == null ? null : Color(value);
  }
}
