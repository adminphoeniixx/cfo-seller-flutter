import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the light/dark [ThemeData] pair, carrying [AppPalette] as a
/// [ThemeExtension] so widgets read tokens via `context.colors` instead of
/// branching on `Theme.of(context).brightness`.
class AppTheme {
  const AppTheme._();

  static ThemeData light = _build(AppPalette.light, Brightness.light);
  static ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: AppColors.action,
            surface: palette.surface,
            error: AppColors.critical,
          )
        : ColorScheme.dark(
            primary: AppColors.action,
            surface: palette.surface,
            error: AppColors.critical,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.ground,
      canvasColor: palette.surface,
      dividerColor: palette.line,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [palette],
    );
  }
}
