import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.disc`: a row of small tag pills (e.g. "Compare-at · Cost ·
/// Tax · Margin") plus a chevron that flips open/closed — the fold-away row
/// for rarely-touched fields.
class AppDisclosureRow extends StatelessWidget {
  final List<String> tags;
  final String? lead;
  final bool open;
  final VoidCallback onTap;

  const AppDisclosureRow({
    super.key,
    this.tags = const [],
    this.lead,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rMd,
            border: Border.all(color: colors.line),
          ),
          child: Row(
            children: [
              if (lead != null)
                Expanded(
                  child: Text(
                    lead!,
                    style: AppTypography.bodySmall.copyWith(color: colors.ink2),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t,
                            style: AppTypography.bodySmall.copyWith(color: colors.ink2),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 18,
                color: colors.ink3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
