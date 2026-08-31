import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductMoreCategoriesScreen extends StatelessWidget {
  final String tag;

  const ProductMoreCategoriesScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    return Obx(() {
      final options = controller.options.value;
      final draft = controller.draft.value;
      if (options == null || draft == null) return const AppLoading();

      return AppScreen(
        children: [
          Text(
            'Extra places this product appears, on top of its main category.',
            style: TextStyle(fontSize: 11.5, color: context.colors.ink3, height: 1.5),
          ),
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < options.categories.length; i++)
                  AppListRow(
                    leading: options.categories[i].parentId != null
                        ? const SizedBox(width: 16)
                        : null,
                    title: options.categories[i].name,
                    showDivider: i != options.categories.length - 1,
                    trailing: draft.categoryIds.contains(options.categories[i].id)
                        ? Icon(Icons.check_rounded, color: context.colors.action, size: 18)
                        : null,
                    onTap: () => controller.setField((d) {
                      final id = options.categories[i].id;
                      if (d.categoryIds.contains(id)) {
                        d.categoryIds.remove(id);
                      } else {
                        d.categoryIds.add(id);
                      }
                    }),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
