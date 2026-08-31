import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class ValueChipData {
  final int id;
  final String label;
  final Color? swatch;

  const ValueChipData({required this.id, required this.label, this.swatch});
}

/// Reproduces `.vals`: toggleable chip row for picking which values of a
/// variant option (size, colour, fabric…) the seller actually stocks.
class AppValueChips extends StatelessWidget {
  final List<ValueChipData> values;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  const AppValueChips({
    super.key,
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final v in values)
          _Chip(
            data: v,
            selected: selected.contains(v.id),
            onTap: () => onToggle(v.id),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final ValueChipData data;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.ink : colors.surface,
      borderRadius: AppRadius.rSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rSm,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? colors.ink : colors.line),
            borderRadius: AppRadius.rSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.swatch != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: data.swatch,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                data.label,
                style: (selected ? AppTypography.chipOn : AppTypography.chip)
                    .copyWith(color: selected ? colors.surface : colors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
