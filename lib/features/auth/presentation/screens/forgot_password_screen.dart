import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _controller = Get.find<AuthController>();
  String? _localError;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _localError = 'Enter the email linked to your store.');
      return;
    }

    setState(() {
      _localError = null;
      _sent = false;
    });
    final ok = await _controller.forgotPassword(email: email);
    if (!mounted) return;
    setState(() => _sent = ok);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppAppBar(
        title: 'Reset password',
        subtitle: 'Email reset link',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: AppScreen(
        plain: true,
        children: [
          Text(
            'Enter your seller account email. If it exists, the marketplace will send password reset instructions.',
            style: AppTypography.note.copyWith(color: colors.ink2),
          ),
          if (_sent)
            const AppBanner(
              text:
                  'If that email is registered, reset instructions have been sent.',
              variant: AppBannerVariant.success,
            ),
          Obx(() {
            final message = _localError ?? _controller.errorMessage.value;
            if (message == null) return const SizedBox.shrink();
            return AppBanner(text: message, variant: AppBannerVariant.critical);
          }),
          Obx(
            () => AppTextField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              placeholder: 'you@store.test',
              errorText: _controller.fieldError('email'),
              onChanged: (_) => setState(() {
                _localError = null;
                _sent = false;
              }),
              onSubmitted: (_) =>
                  _controller.isLoading.value ? null : _submit(),
            ),
          ),
          Obx(
            () => AppButton(
              label: _controller.isLoading.value
                  ? 'Sending...'
                  : 'Send reset link',
              onPressed: _controller.isLoading.value ? null : _submit,
            ),
          ),
          AppButton.ghost(
            label: 'I have a reset token',
            onPressed: () => context.push(AppRoutes.resetPassword),
          ),
        ],
      ),
    );
  }
}
