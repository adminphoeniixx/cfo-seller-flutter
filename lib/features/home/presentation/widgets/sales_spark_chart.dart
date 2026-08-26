import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Reproduces `.spark`: bar-chart-ish sparkline of flex bars, last one
/// highlighted full opacity.
class SalesSparkChart extends StatelessWidget {
  final List<double> heightsPercent;

  const SalesSparkChart({super.key, required this.heightsPercent});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heightsPercent.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: FractionallySizedBox(
                heightFactor: heightsPercent[i] / 100,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.action.withValues(
                      alpha: i == heightsPercent.length - 1 ? 1 : 0.3,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
