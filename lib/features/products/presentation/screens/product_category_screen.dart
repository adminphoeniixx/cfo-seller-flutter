import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_form_controller_base.dart';

class ProductCategoryScreen extends StatefulWidget {
  final String tag;

  const ProductCategoryScreen({super.key, required this.tag});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: widget.tag);
    return Obx(() {
      final options = controller.options.value;
      final draft = controller.draft.value;
      if (options == null || draft == null) return const AppLoading();

      final matches = _query.isEmpty
          ? options.categories
          : options.categories
                .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();

      return AppScreen(
        children: [
          Text(
            "Sets the tax rate and where the product shows up in browse.",
            style: TextStyle(fontSize: 11.5, color: context.colors.ink3, height: 1.5),
          ),
          AppTextField(
            label: 'Search',
            controller: _searchCtrl,
            placeholder: 'Search categories',
            onChanged: (v) => setState(() => _query = v),
          ),
          if (matches.isEmpty)
            const AppEmptyState(emoji: '🔍', message: 'No categories match that search.')
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < matches.length; i++)
                    AppListRow(
                      leading: matches[i].parentId != null
                          ? const SizedBox(width: 16)
                          : null,
                      title: matches[i].name,
                      showDivider: i != matches.length - 1,
                      trailing: draft.categoryId == matches[i].id
                          ? Icon(Icons.check_rounded, color: context.colors.action, size: 18)
                          : null,
                      onTap: () {
                        controller.setField((d) => d.categoryId = matches[i].id);
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
