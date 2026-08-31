import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductTaxClassScreen extends StatelessWidget {
  final String tag;

  const ProductTaxClassScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    return Obx(() {
      final options = controller.options.value;
      final draft = controller.draft.value;
      if (options == null || draft == null) return const AppLoading();

      return AppScreen(
        children: [
          AppCard(
            flat: true,
            child: Column(
              children: [
                AppListRow(
                  title: 'No tax class',
                  showDivider: options.taxClasses.isNotEmpty,
                  trailing: draft.taxClassId == null
                      ? Icon(Icons.check_rounded, color: context.colors.action, size: 18)
                      : null,
                  onTap: () {
                    controller.setField((d) => d.taxClassId = null);
                    Navigator.of(context).pop();
                  },
                ),
                for (var i = 0; i < options.taxClasses.length; i++)
                  AppListRow(
                    title: options.taxClasses[i].name,
                    showDivider: i != options.taxClasses.length - 1,
                    trailing: draft.taxClassId == options.taxClasses[i].id
                        ? Icon(Icons.check_rounded, color: context.colors.action, size: 18)
                        : null,
                    onTap: () {
                      controller.setField((d) => d.taxClassId = options.taxClasses[i].id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
