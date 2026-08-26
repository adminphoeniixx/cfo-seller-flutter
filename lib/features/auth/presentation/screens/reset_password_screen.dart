import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialToken;

  const ResetPasswordScreen({super.key, this.initialEmail, this.initialToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _tokenCtrl;
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _controller = Get.find<AuthController>();
  String? _localError;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    _tokenCtrl = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _passwordConfirmCtrl.text;

    if ([email, token, password, confirm].any((value) => value.isEmpty)) {
      setState(
        () => _localError = 'Fill in every field to reset your password.',
      );
      return;
    }
    if (password != confirm) {
      setState(
        () => _localError = 'New password and confirmation do not match.',
      );
      return;
    }

    setState(() => _localError = null);
    final ok = await _controller.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: confirm,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset. Sign in with the new password.'),
        ),
      );
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppAppBar(
        title: 'New password',
        subtitle: 'Complete reset',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: AppScreen(
        plain: true,
        children: [
          Text(
            'Paste the reset token from your email and choose a new password.',
            style: AppTypography.note.copyWith(color: colors.ink2),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _controller.fieldError('email'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'Reset token',
              controller: _tokenCtrl,
              textInputAction: TextInputAction.next,
              errorText: _controller.fieldError('token'),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ),
          Obx(
            () => AppTextField(
              label: 'New password',
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _controller.fieldError('password_confirmation'),
              onChanged: (_) => setState(() => _localError = null),
              onSubmitted: (_) =>
                  _controller.isLoading.value ? null : _submit(),
            ),
          ),
          Obx(
            () => AppButton(
              label: _controller.isLoading.value
                  ? 'Resetting...'
                  : 'Reset password',
              onPressed: _controller.isLoading.value ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
