import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Reproduces `.qty`: bordered stepper with -/+ buttons around a count.
class AppQuantitySelector extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const AppQuantitySelector({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            label: '−',
            color: colors.surface2,
            onTap: () => onChanged((value - 1).clamp(0, max)),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
          _StepButton(
            label: '+',
            color: colors.surface2,
            onTap: () => onChanged((value + 1).clamp(0, max)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: context.colors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
