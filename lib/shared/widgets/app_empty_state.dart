import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.empty`: centered muted big-emoji + message. Used when a
/// filtered list has no results.
class AppEmptyState extends StatelessWidget {
  final String emoji;
  final String message;

  const AppEmptyState({super.key, required this.emoji, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 30,
              color: colors.ink3.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.empty.copyWith(color: colors.ink3),
          ),
        ],
      ),
    );
  }
}
