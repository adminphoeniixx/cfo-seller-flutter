import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _controller = Get.find<AuthController>();
  String? _localError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Enter your email and password.');
      return;
    }

    setState(() => _localError = null);
    final ok = await _controller.signIn(email: email, password: password);
    if (!mounted) return;
    if (ok) {
      context.go(_controller.isApproved ? AppRoutes.home : AppRoutes.pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: AppScreen(
          plain: true,
          children: [
            const SizedBox(height: 24),
            Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'C',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: colors.accentInk,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seller Centre',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your store on the go',
                  style: TextStyle(fontSize: 12.5, color: colors.ink3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() {
              final message = _localError ?? _controller.errorMessage.value;
              if (message == null) return const SizedBox.shrink();
              return AppBanner(
                text: message,
                variant: AppBannerVariant.critical,
              );
            }),
            Obx(
              () => AppTextField(
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                placeholder: 'you@store.test',
                errorText: _controller.fieldError('email'),
                onChanged: (_) => setState(() => _localError = null),
              ),
            ),
            Obx(
              () => AppTextField(
                label: 'Password',
                controller: _passwordCtrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                placeholder: 'Password',
                errorText: _controller.fieldError('password'),
                onChanged: (_) => setState(() => _localError = null),
                onSubmitted: (_) =>
                    _controller.isLoading.value ? null : _submit(),
              ),
            ),
            Obx(
              () => AppButton(
                label: _controller.isLoading.value
                    ? 'Signing in...'
                    : 'Sign in',
                onPressed: _controller.isLoading.value ? null : _submit,
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.action,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12.5, color: colors.ink3),
                  children: [
                    const TextSpan(text: 'New here? '),
                    TextSpan(
                      text: 'Open a store',
                      style: TextStyle(
                        color: colors.action,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push(AppRoutes.register),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
