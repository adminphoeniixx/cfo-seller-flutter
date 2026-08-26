import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final controller = Get.find<AuthController>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  Future<void> _submit() async {
    final ok = await controller.changePassword(
      currentPassword: _current.text,
      password: _next.text,
      passwordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      AppMessenger.show('Password changed. Other devices signed out.');
    } else if (controller.errorMessage.value != null) {
      AppMessenger.show(
        controller.errorMessage.value!,
        title: 'Could not change password',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScreen(
        children: [
          AppTextField(
            label: 'Current password',
            controller: _current,
            obscureText: true,
            placeholder: '••••••••',
          ),
          AppTextField(
            label: 'New password',
            controller: _next,
            obscureText: true,
            placeholder: 'At least 8 characters',
          ),
          AppTextField(
            label: 'Confirm new password',
            controller: _confirm,
            obscureText: true,
          ),
          const AppBanner(
            text:
                'Changing your password signs you out on every other device. This one stays signed in.',
            variant: AppBannerVariant.warn,
          ),
          AppButton(
            label: controller.isLoading.value ? 'Changing…' : 'Change password',
            onPressed: controller.isLoading.value ? null : _submit,
          ),
        ],
      ),
    );
  }
}
