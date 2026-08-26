import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.row`: leading slot (thumb/icon), title+subtitle, optional
/// trailing amount/pill, optional chevron, bottom divider. Powers every
/// list across Orders/Products/Requests/Payouts/Settings.
class AppListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget? titleTrailing;
  final String? subtitle;
  final String? amount;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool showDivider;

  const AppListRow({
    super.key,
    this.leading,
    required this.title,
    this.titleTrailing,
    this.subtitle,
    this.amount,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.lineSoft)),
            )
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.rowH,
        vertical: AppSpacing.rowV,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.rowGap),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.rowTitle.copyWith(
                          color: colors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (titleTrailing != null) ...[
                      const SizedBox(width: 6),
                      titleTrailing!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppTypography.rowSubtitle.copyWith(
                      color: colors.ink3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: 8),
            Text(
              amount!,
              style: AppTypography.rowAmount.copyWith(color: colors.ink),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(AppIcons.chevronRight, size: 17, color: colors.ink3),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: colors.surface,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

/// Reproduces the 40x40 `.thumb`: gradient placeholder tile for an emoji or
/// icon glyph.
class AppThumb extends StatelessWidget {
  final String emoji;
  final double size;

  const AppThumb({super.key, required this.emoji, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.line, colors.surface2],
        ),
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(size * 0.225),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}
