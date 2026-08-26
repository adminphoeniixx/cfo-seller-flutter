import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controller = Get.find<AuthController>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _storeEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _storeNameCtrl.dispose();
    _storeEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmation = _passwordConfirmCtrl.text;
    final storeName = _storeNameCtrl.text.trim();

    if ([
      name,
      email,
      password,
      confirmation,
      storeName,
    ].any((v) => v.isEmpty)) {
      setState(() => _localError = 'Fill in all required fields.');
      return;
    }
    if (password != confirmation) {
      setState(() => _localError = 'Password and confirmation do not match.');
      return;
    }

    setState(() => _localError = null);
    final ok = await _controller.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: confirmation,
      storeName: storeName,
      phone: _optional(_phoneCtrl),
      storeEmail: _optional(_storeEmailCtrl),
      gstNumber: _optional(_gstCtrl),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store created. Waiting for approval.')),
      );
      context.go(AppRoutes.pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppAppBar(
        title: 'Open a store',
        subtitle: 'Your details',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: AppScreen(
        plain: true,
        children: [
          const AppSectionHeader(title: 'Your login'),
          Obx(() {
            final message = _localError ?? _controller.errorMessage.value;
            if (message == null) return const SizedBox.shrink();
            return AppBanner(text: message, variant: AppBannerVariant.critical);
          }),
          Obx(
            () => AppTextField(
              label: 'Your name',
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              errorText: _controller.fieldError('name'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _controller.fieldError('email'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Password',
              controller: _passwordCtrl,
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              placeholder: 'At least 8 characters',
              errorText: _controller.fieldError('password'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Confirm password',
              controller: _passwordConfirmCtrl,
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _controller.fieldError('password_confirmation'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          const AppSectionHeader(title: 'Your store'),
          Obx(
            () => AppTextField(
              label: 'Store name',
              controller: _storeNameCtrl,
              textInputAction: TextInputAction.next,
              errorText: _controller.fieldError('store_name'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Store email (optional)',
              controller: _storeEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _controller.fieldError('store_email'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Phone (optional)',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              errorText: _controller.fieldError('phone'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'GST number (optional)',
              controller: _gstCtrl,
              textInputAction: TextInputAction.done,
              placeholder: '27AAPFU0939F1ZV',
              errorText: _controller.fieldError('gst_number'),
              onChanged: (_) => setState(() => _localError = null),
              onSubmitted: (_) =>
                  _controller.isLoading.value ? null : _submit(),
            ),
          ),
          Text(
            'An admin reviews new stores before you can list products or take orders. You can fill in your details while you wait.',
            style: TextStyle(fontSize: 11.5, color: colors.ink3, height: 1.5),
          ),
          const SizedBox(height: 8),
          Obx(
            () => AppButton(
              label: _controller.isLoading.value
                  ? 'Creating...'
                  : 'Create my store',
              onPressed: _controller.isLoading.value ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
