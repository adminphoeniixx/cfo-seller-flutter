import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppPillVariant { ok, warn, crit, info, mute }

/// Reproduces `.pill.{ok,warn,crit,info,mute}`.
class AppStatusPill extends StatelessWidget {
  final String label;
  final AppPillVariant variant;

  const AppStatusPill({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late final Color bg;
    late final Color fg;
    switch (variant) {
      case AppPillVariant.ok:
        bg = colors.okBg;
        fg = colors.okInk;
        break;
      case AppPillVariant.warn:
        bg = colors.warnBg;
        fg = colors.warnInk;
        break;
      case AppPillVariant.crit:
        bg = colors.critBg;
        fg = colors.critInk;
        break;
      case AppPillVariant.info:
        bg = colors.infoBg;
        fg = colors.infoInk;
        break;
      case AppPillVariant.mute:
        bg = colors.pillMute;
        fg = colors.ink2;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Text(label, style: AppTypography.pill.copyWith(color: fg)),
    );
  }
}
