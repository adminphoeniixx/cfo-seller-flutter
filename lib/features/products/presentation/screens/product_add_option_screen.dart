import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductAddOptionScreen extends StatelessWidget {
  final String tag;

  const ProductAddOptionScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    return Obx(() {
      final options = controller.options.value;
      final draft = controller.draft.value;
      if (options == null || draft == null) return const AppLoading();

      final unused = options.variantAttributes
          .where((a) => !draft.attributeIds.contains(a.id))
          .toList();

      if (options.variantAttributes.isEmpty) {
        return const AppEmptyState(
          emoji: '🏷️',
          message: 'The marketplace has not set up any variant options yet.',
        );
      }
      if (unused.isEmpty) {
        return const AppEmptyState(
          emoji: '🏷️',
          message: 'Every option is already on this product.',
        );
      }

      return AppScreen(
        children: [
          const Text(
            'Options come from the marketplace — you pick which of their values you stock.',
            style: TextStyle(fontSize: 11.5, height: 1.5),
          ),
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < unused.length; i++)
                  AppListRow(
                    title: unused[i].name,
                    subtitle: unused[i].values.map((v) => v.value).join(' · '),
                    showChevron: true,
                    showDivider: i != unused.length - 1,
                    onTap: () {
                      controller.addOption(unused[i].id);
                      context.pushReplacement(
                        AppRoutes.productOptionPath(unused[i].id),
                        extra: tag,
                      );
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
