import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppBannerVariant { info, warn, critical, success }

/// Reproduces `.banner` / `.banner.warn`.
class AppBanner extends StatelessWidget {
  final String text;
  final AppBannerVariant variant;

  const AppBanner({
    super.key,
    required this.text,
    this.variant = AppBannerVariant.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (variant) {
      AppBannerVariant.warn => (colors.warnBg, colors.warnInk),
      AppBannerVariant.critical => (colors.critBg, colors.critInk),
      AppBannerVariant.success => (colors.okBg, colors.okInk),
      AppBannerVariant.info => (colors.infoBg, colors.infoInk),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rMd),
      child: Text(text, style: AppTypography.banner.copyWith(color: fg)),
    );
  }
}
