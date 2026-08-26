import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/models/store.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/store_controller.dart';

class PayoutAccountScreen extends StatefulWidget {
  const PayoutAccountScreen({super.key});

  @override
  State<PayoutAccountScreen> createState() => _PayoutAccountScreenState();
}

class _PayoutAccountScreenState extends State<PayoutAccountScreen> {
  final controller = Get.find<StoreController>();

  int? _formForStoreId;
  late TextEditingController _accountName;
  late TextEditingController _accountNumber;
  late TextEditingController _ifsc;

  void _ensureFormFor(Store store) {
    if (_formForStoreId == store.id) return;
    _formForStoreId = store.id;
    _accountName = TextEditingController(text: store.payout.accountName ?? '');
    _accountNumber = TextEditingController(
      text: store.payout.accountNumber ?? '',
    );
    _ifsc = TextEditingController(text: store.payout.ifsc ?? '');
  }

  Future<void> _save() async {
    final store = controller.store.value;
    if (store == null) return;
    final ok = await controller.save(
      name: store.name,
      payoutMethod: store.payout.method ?? 'bank',
      bankAccountName: _accountName.text,
      bankAccountNumber: _accountNumber.text,
      bankIfsc: _ifsc.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      AppMessenger.show('Saved');
    } else if (controller.errorMessage.value != null) {
      AppMessenger.show(
        controller.errorMessage.value!,
        title: 'Could not save',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final store = controller.store.value;
      if (store != null) _ensureFormFor(store);

      return Scaffold(
        appBar: AppAppBar(
          title: 'Payout account',
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
          showSave: store != null && !controller.isSaving.value,
          onSave: store == null ? null : _save,
        ),
        body: _body(store),
      );
    });
  }

  Widget _body(Store? store) {
    if (controller.isLoading.value) return const AppLoading();
    if (store == null) {
      return AppErrorState(
        message: controller.errorMessage.value ?? 'Not found',
        onRetry: controller.load,
      );
    }

    return AppScreen(
      children: [
        const AppBanner(
          text:
              "This is where the marketplace sends your earnings. Double-check it — a wrong IFSC delays payment by days.",
        ),
        AppTapField(
          label: 'Method',
          value: store.payout.method == 'bank'
              ? 'Bank transfer'
              : (store.payout.method ?? 'Not set'),
          onTap: () => AppMessenger.show('Not part of this preview yet'),
        ),
        AppTextField(label: 'Account holder', controller: _accountName),
        AppTextField(
          label: 'Account number',
          controller: _accountNumber,
          keyboardType: TextInputType.number,
        ),
        AppTextField(label: 'IFSC', controller: _ifsc),
      ],
    );
  }
}
