import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Reproduces `.card` / `.card.flat` / `.card.pad0`: surface background,
/// 1px `--line` border, 13px radius. `flat` drops the padding so children
/// (typically [AppListRow]s) can manage their own edge-to-edge dividers.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool flat;
  final Color? borderColor;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.flat = false,
    this.borderColor,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding:
          padding ??
          (flat ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.cardPad)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: borderColor ?? colors.line),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
