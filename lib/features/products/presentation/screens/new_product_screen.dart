import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/product_form_controller_base.dart';
import '../widgets/product_form_body.dart';

/// One save action, not three — status is a form field (see
/// `ProductFormBody`'s Status section), so this screen only ever needs the
/// single top-right Save, matching `seller-app-product-form.md`'s "one save
/// action, not three" requirement.
class NewProductScreen extends StatelessWidget {
  final String tag;

  const NewProductScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormControllerBase>(tag: tag);

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
      child: Obx(
        () => Scaffold(
          appBar: AppAppBar(
            title: 'New product',
            showBack: true,
            closeStyle: true,
            onBack: () async {
              if (await confirmDiscard() && context.mounted) Navigator.of(context).pop();
            },
            showSave: true,
            onSave: controller.isSubmitting.value
                ? null
                : () async {
                    final ok = await controller.save();
                    if (ok && context.mounted) {
                      Navigator.of(context).pop();
                      final status = controller.draft.value?.status.name;
                      AppMessenger.show(status == 'active' ? 'Product published' : 'Saved as a draft');
                    } else if (controller.errorMessage.value != null) {
                      AppMessenger.show(
                        controller.errorMessage.value!,
                        title: 'Check your entries',
                      );
                    }
                  },
          ),
          body: controller.draft.value == null
              ? const Center(child: CircularProgressIndicator())
              : ProductFormBody(controller: controller),
        ),
      ),
    );
  }
}
