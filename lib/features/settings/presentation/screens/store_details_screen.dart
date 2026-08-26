import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/store.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/store_controller.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({super.key});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  final controller = Get.find<StoreController>();

  // Built once the store loads, keyed off its id, so later `Obx` rebuilds
  // (e.g. right after save) don't discard whatever the seller is mid-typing.
  int? _formForStoreId;
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _storeEmail;
  late TextEditingController _phone;
  late TextEditingController _addressLine1;
  late TextEditingController _city;
  late TextEditingController _state;
  late TextEditingController _postcode;
  late TextEditingController _gstNumber;
  late TextEditingController _bankAccountName;
  late TextEditingController _bankAccountNumber;
  late TextEditingController _bankIfsc;

  void _ensureFormFor(Store store) {
    if (_formForStoreId == store.id) return;
    _formForStoreId = store.id;
    _name = TextEditingController(text: store.name);
    _description = TextEditingController(text: store.description ?? '');
    _storeEmail = TextEditingController(text: store.email ?? '');
    _phone = TextEditingController(text: store.phone ?? '');
    _addressLine1 = TextEditingController(text: store.address.line1 ?? '');
    _city = TextEditingController(text: store.address.city ?? '');
    _state = TextEditingController(text: store.address.state ?? '');
    _postcode = TextEditingController(text: store.address.postcode ?? '');
    _gstNumber = TextEditingController(text: store.gstNumber ?? '');
    _bankAccountName = TextEditingController(
      text: store.payout.accountName ?? '',
    );
    _bankAccountNumber = TextEditingController(
      text: store.payout.accountNumber ?? '',
    );
    _bankIfsc = TextEditingController(text: store.payout.ifsc ?? '');
  }

  Future<void> _save() async {
    final ok = await controller.save(
      name: _name.text,
      storeEmail: _storeEmail.text,
      phone: _phone.text,
      description: _description.text,
      addressLine1: _addressLine1.text,
      city: _city.text,
      state: _state.text,
      postcode: _postcode.text,
      gstNumber: _gstNumber.text,
      bankAccountName: _bankAccountName.text,
      bankAccountNumber: _bankAccountNumber.text,
      bankIfsc: _bankIfsc.text,
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
          title: 'Store details',
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
          showSave: store != null && !controller.isSaving.value,
          onSave: store == null ? null : _save,
        ),
        body: _body(context, store),
      );
    });
  }

  Widget _body(BuildContext context, Store? store) {
    if (controller.isLoading.value) return const AppLoading();
    if (store == null) {
      return AppErrorState(
        message: controller.errorMessage.value ?? 'Not found',
        onRetry: controller.load,
      );
    }

    final colors = context.colors;

    return AppScreen(
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text('🧵', style: TextStyle(fontSize: 23)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store logo',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                  Text(
                    'Square, at least 400×400',
                    style: TextStyle(fontSize: 11.5, color: colors.ink3),
                  ),
                ],
              ),
            ),
            const AppStatusPill(label: 'Change', variant: AppPillVariant.info),
          ],
        ),
        AppTextField(label: 'Store name', controller: _name),
        AppTextField(label: 'Description', controller: _description),
        AppTextField(
          label: 'Store email',
          controller: _storeEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        AppTextField(
          label: 'Phone',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        const AppSectionHeader(title: 'Pickup address'),
        AppTextField(label: 'Address line 1', controller: _addressLine1),
        Row(
          children: [
            Expanded(
              child: AppTextField(label: 'City', controller: _city),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: AppTextField(label: 'State', controller: _state),
            ),
          ],
        ),
        AppTextField(label: 'Postcode', controller: _postcode),
        AppTextField(label: 'GST number', controller: _gstNumber),
        const AppSectionHeader(title: 'Payout account'),
        AppTextField(label: 'Account holder', controller: _bankAccountName),
        AppTextField(label: 'Account number', controller: _bankAccountNumber),
        AppTextField(label: 'IFSC', controller: _bankIfsc),
      ],
    );
  }
}
