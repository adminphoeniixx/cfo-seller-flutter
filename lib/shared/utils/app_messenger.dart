import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppMessageTone { info, success, warning, critical }

class AppMessenger {
  const AppMessenger._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {String? title, AppMessageTone? tone}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final context = messenger.context;
    final colors = context.colors;
    final resolvedTone = tone ?? _inferTone(message, title);
    final (bg, fg) = switch (resolvedTone) {
      AppMessageTone.success => (colors.okBg, colors.okInk),
      AppMessageTone.warning => (colors.warnBg, colors.warnInk),
      AppMessageTone.critical => (colors.critBg, colors.critInk),
      AppMessageTone.info => (colors.infoBg, colors.infoInk),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.rMd,
              border: Border.all(color: fg.withValues(alpha: 0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    style: AppTypography.rowTitle.copyWith(color: fg),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(message, style: AppTypography.banner.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      );
  }

  static AppMessageTone _inferTone(String message, String? title) {
    final text = '${title ?? ''} $message'.toLowerCase();
    if (text.contains('could not') ||
        text.contains('failed') ||
        text.contains('required') ||
        text.contains('do not match') ||
        text.contains('valid')) {
      return AppMessageTone.critical;
    }
    if (text.contains('not part')) return AppMessageTone.warning;
    if (text.contains('saved') ||
        text.contains('created') ||
        text.contains('published') ||
        text.contains('changed') ||
        text.contains('deleted') ||
        text.contains('sent') ||
        text.contains('shipped')) {
      return AppMessageTone.success;
    }
    return AppMessageTone.info;
  }
}
