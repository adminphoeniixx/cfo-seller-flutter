import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Reproduces `.screen`: scrollable column, 14px horizontal / 14px top /
/// 20px bottom padding, 11px gap between children. `plain` switches the
/// background to `--surface` (used by auth screens).
class AppScreen extends StatelessWidget {
  final List<Widget> children;
  final bool plain;
  final EdgeInsetsGeometry? padding;

  const AppScreen({
    super.key,
    required this.children,
    this.plain = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: plain ? colors.surface : colors.ground,
      child: SingleChildScrollView(
        padding:
            padding ??
            const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.screenTop,
              AppSpacing.screenH,
              AppSpacing.screenBottom,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.screenGap),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
