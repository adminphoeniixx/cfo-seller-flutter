import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.money`: dashed-bottom label/value line, and `.money.total`
/// (solid top border, bold, larger).
class AppMoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool total;

  const AppMoneyRow({
    super.key,
    required this.label,
    required this.value,
    this.total = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final row = Padding(
      padding: EdgeInsets.only(top: total ? 9 : 5, bottom: total ? 0 : 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (total ? AppTypography.body : AppTypography.bodySmall)
                .copyWith(
                  color: colors.ink,
                  fontWeight: total ? FontWeight.w700 : FontWeight.normal,
                  fontSize: total ? 15 : 12.5,
                ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: total ? 15 : 12.5,
              fontWeight: FontWeight.w600,
              color: colors.ink,
            ),
          ),
        ],
      ),
    );

    if (total) {
      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.line)),
        ),
        child: row,
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineSoft)),
      ),
      child: row,
    );
  }
}
