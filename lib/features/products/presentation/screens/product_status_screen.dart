import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductStatusScreen extends StatelessWidget {
  final String tag;

  const ProductStatusScreen({super.key, required this.tag});

  static const _blurb = {
    ProductStatus.draft: 'Only you can see it. Nothing sells.',
    ProductStatus.active: 'Live on the marketplace, ready to sell.',
    ProductStatus.archived: 'Hidden and out of the way, but not deleted.',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);
    return Obx(() {
      final draft = controller.draft.value;
      if (draft == null) return const AppLoading();

      return AppScreen(
        children: [
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < ProductStatus.values.length; i++)
                  AppListRow(
                    title: _label(ProductStatus.values[i]),
                    subtitle: _blurb[ProductStatus.values[i]],
                    showDivider: i != ProductStatus.values.length - 1,
                    trailing: draft.status == ProductStatus.values[i]
                        ? Icon(Icons.check_rounded, color: context.colors.action, size: 18)
                        : null,
                    onTap: () {
                      controller.setField((d) => d.status = ProductStatus.values[i]);
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

  String _label(ProductStatus s) => switch (s) {
    ProductStatus.draft => 'Draft',
    ProductStatus.active => 'Active',
    ProductStatus.archived => 'Archived',
  };
}
