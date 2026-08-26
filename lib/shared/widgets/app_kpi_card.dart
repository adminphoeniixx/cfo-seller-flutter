import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.kpi`: label/value/detail stack in a bordered card. Meant to
/// be laid out two-per-row via [AppKpiGrid].
class AppKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;
  final double valueFontSize;

  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.valueFontSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: AppRadius.rLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.kpiLabel.copyWith(color: colors.ink3),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.kpiValue.copyWith(
              color: colors.ink,
              fontSize: valueFontSize,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 1),
            Text(
              detail!,
              style: AppTypography.kpiDetail.copyWith(color: colors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reproduces `.kpis`: 2-column grid, 9px gap.
class AppKpiGrid extends StatelessWidget {
  final List<Widget> children;

  const AppKpiGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}
