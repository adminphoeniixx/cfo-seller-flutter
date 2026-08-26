import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.chip` / `.chip.on`: pill-shaped filter chip, dark/ink fill
/// when active. Used for the horizontally-scrolling filter rows on
/// Orders/Products.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? colors.ink : colors.surface,
            border: Border.all(color: selected ? colors.ink : colors.line),
            borderRadius: AppRadius.rPill,
          ),
          child: Text(
            label,
            style: (selected ? AppTypography.chipOn : AppTypography.chip)
                .copyWith(color: selected ? colors.surface : colors.ink2),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of [AppChip]s, mirrors `.chips` (no scrollbar,
/// 6px gap).
class AppChipRow extends StatelessWidget {
  final List<Widget> children;

  const AppChipRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            children[i],
          ],
        ],
      ),
    );
  }
}
