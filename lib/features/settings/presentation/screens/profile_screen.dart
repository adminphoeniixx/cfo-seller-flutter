import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/seller.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = Get.find<AuthController>();

  int? _formForSellerId;
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;

  void _ensureFormFor(Seller seller) {
    if (_formForSellerId == seller.id) return;
    _formForSellerId = seller.id;
    _name = TextEditingController(text: seller.name);
    _email = TextEditingController(text: seller.email);
    _phone = TextEditingController(text: seller.phone ?? '');
  }

  Future<void> _save() async {
    final ok = await controller.updateProfile(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
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
      final seller = controller.seller.value;
      if (seller != null) _ensureFormFor(seller);

      return Scaffold(
        appBar: AppAppBar(
          title: 'Your profile',
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
          showSave: seller != null && !controller.isLoading.value,
          onSave: seller == null ? null : _save,
        ),
        body: seller == null
            ? const AppLoading()
            : AppScreen(
                children: [
                  AppTextField(label: 'Name', controller: _name),
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AppTextField(
                    label: 'Phone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  Text(
                    'This email is what you sign in with.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.ink3,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
