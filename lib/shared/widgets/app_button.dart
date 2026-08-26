import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, ghost, dark, danger }

/// Reproduces `.btn` and its `.ghost` / `.dark` / `.danger` variants: full
/// width, 13px vertical padding, 11px radius, 14px/600 label.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.dark({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = AppButtonVariant.dark;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null;

    late final Color bg;
    late final Color fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = colors.action;
        fg = Colors.white;
        break;
      case AppButtonVariant.ghost:
        bg = colors.surface;
        fg = colors.ink;
        border = Border.all(color: colors.line);
        break;
      case AppButtonVariant.dark:
        bg = colors.ink;
        fg = colors.surface;
        break;
      case AppButtonVariant.danger:
        bg = Colors.transparent;
        fg = colors.critical;
        break;
    }

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: bg,
        borderRadius: AppRadius.rMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.rMd,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.rMd,
              border: border,
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            child: Text(label, style: AppTypography.button.copyWith(color: fg)),
          ),
        ),
      ),
    );
  }
}
