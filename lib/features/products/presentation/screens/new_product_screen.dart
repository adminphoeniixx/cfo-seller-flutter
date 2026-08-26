import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/new_product_controller.dart';

class NewProductScreen extends GetView<NewProductController> {
  const NewProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final compareCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final lowCtrl = TextEditingController(text: '5');

    Future<void> submit(bool asDraft) async {
      final ok = await controller.submit(
        name: nameCtrl.text,
        price: priceCtrl.text,
        compareAt: compareCtrl.text,
        stock: stockCtrl.text,
        lowAt: lowCtrl.text,
        asDraft: asDraft,
      );
      if (ok && context.mounted) {
        Navigator.of(context).pop();
        AppMessenger.show(asDraft ? 'Saved as a draft' : 'Product published');
      } else if (controller.errorMessage.value != null) {
        AppMessenger.show(
          controller.errorMessage.value!,
          title: 'Check your entries',
        );
      }
    }

    return AppScreen(
      children: [
        Row(
          children: [
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
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Add up to 10 photos. First one is the cover.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: context.colors.ink3,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        AppTextField(
          label: 'Name',
          controller: nameCtrl,
          placeholder: 'e.g. Chanderi cotton saree',
        ),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Price',
                controller: priceCtrl,
                placeholder: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: AppTextField(
                label: 'Compare at',
                controller: compareCtrl,
                placeholder: '—',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Stock',
                controller: stockCtrl,
                placeholder: '0',
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
          value: 'Choose',
          valueColor: context.colors.ink3,
          onTap: () => AppMessenger.show('Not part of this preview yet'),
        ),
        AppTapField(
          label: 'Type',
          value: 'Simple',
          onTap: () => AppMessenger.show('Not part of this preview yet'),
        ),
        Obx(
          () => AppButton(
            label: controller.isSubmitting.value
                ? 'Publishing…'
                : 'Publish product',
            onPressed: controller.isSubmitting.value
                ? null
                : () => submit(false),
          ),
        ),
        Obx(
          () => AppButton.ghost(
            label: 'Save as draft',
            onPressed: controller.isSubmitting.value
                ? null
                : () => submit(true),
          ),
        ),
      ],
    );
  }
}
