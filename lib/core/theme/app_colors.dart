import 'package:flutter/material.dart';

/// Semantic color tokens lifted 1:1 from the HTML prototype's CSS custom
/// properties (`:root` / `prefers-color-scheme: dark` / `[data-theme]`).
/// Values must not drift from the prototype without re-checking the source.
class AppColors {
  const AppColors._();

  // -------------------------------------------------------------- light
  static const Color lightGround = Color(0xFFEEF0EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF7F9F7);
  static const Color lightLine = Color(0xFFDFE3DF);
  static const Color lightLineSoft = Color(0xFFEBEEEB);
  static const Color lightInk = Color(0xFF2C302C);
  static const Color lightInk2 = Color(0xFF5D635D);
  static const Color lightInk3 = Color(0xFF8A908A);
  static const Color lightPage = Color(0xFFD7DCD8);
  static const Color lightOkBg = Color(0xFFCDFEE1);
  static const Color lightOkInk = Color(0xFF0C5132);
  static const Color lightWarnBg = Color(0xFFFFD6A4);
  static const Color lightWarnInk = Color(0xFF5E4200);
  static const Color lightInfoBg = Color(0xFFEBF5FF);
  static const Color lightInfoInk = Color(0xFF00527C);
  static const Color lightCritBg = Color(0xFFFFE5E2);
  static const Color lightCritInk = Color(0xFF8E1F00);

  // --------------------------------------------------------------- dark
  static const Color darkGround = Color(0xFF0D0F0D);
  static const Color darkSurface = Color(0xFF171A17);
  static const Color darkSurface2 = Color(0xFF1F231F);
  static const Color darkLine = Color(0xFF2F342F);
  static const Color darkLineSoft = Color(0xFF232823);
  static const Color darkInk = Color(0xFFE2E6E2);
  static const Color darkInk2 = Color(0xFFB0B6B0);
  static const Color darkInk3 = Color(0xFF848A84);
  static const Color darkPage = Color(0xFF050605);
  static const Color darkOkBg = Color(0xFF0C5132);
  static const Color darkOkInk = Color(0xFFCDFEE1);
  static const Color darkWarnBg = Color(0xFF5E4200);
  static const Color darkWarnInk = Color(0xFFFFD6A4);
  static const Color darkInfoBg = Color(0xFF002D47);
  static const Color darkInfoInk = Color(0xFFA5D3FF);
  static const Color darkCritBg = Color(0xFF5C1400);
  static const Color darkCritInk = Color(0xFFFFD6CF);

  // ---------------------------------------------------------- app bar
  // The prototype's chrome bar is always near-black regardless of theme.
  // Per product direction this now follows the active theme instead: a
  // dark bar with light text in dark mode, a light bar with dark text in
  // light mode — matching how the rest of each palette behaves.
  static const Color lightChrome = Color(0xFFFFFFFF);
  static const Color lightChromeFg = lightInk;
  static const Color darkChrome = Color(0xFF171917);
  static const Color darkChromeFg = Color(0xFFFFFFFF);

  // ------------------------------------------------- theme-invariant
  static const Color accent = Color(0xFF36FBA1);
  static const Color accentInk = Color(0xFF0C5132);
  static const Color action = Color(0xFF005BD3);
  static const Color critical = Color(0xFFE51C00);
  static const Color pillMuteLight = lightLine;
  static const Color pillMuteDark = darkLine;
}

/// Resolves [AppColors] tokens against the active [Brightness] so widgets
/// never branch on brightness themselves.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color ground;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color lineSoft;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color page;
  final Color chrome;
  final Color chromeFg;
  final Color accent;
  final Color accentInk;
  final Color action;
  final Color critical;
  final Color okBg;
  final Color okInk;
  final Color warnBg;
  final Color warnInk;
  final Color infoBg;
  final Color infoInk;
  final Color critBg;
  final Color critInk;
  final Color pillMute;

  const AppPalette({
    required this.ground,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.lineSoft,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.page,
    required this.chrome,
    required this.chromeFg,
    required this.accent,
    required this.accentInk,
    required this.action,
    required this.critical,
    required this.okBg,
    required this.okInk,
    required this.warnBg,
    required this.warnInk,
    required this.infoBg,
    required this.infoInk,
    required this.critBg,
    required this.critInk,
    required this.pillMute,
  });

  static const AppPalette light = AppPalette(
    ground: AppColors.lightGround,
    surface: AppColors.lightSurface,
    surface2: AppColors.lightSurface2,
    line: AppColors.lightLine,
    lineSoft: AppColors.lightLineSoft,
    ink: AppColors.lightInk,
    ink2: AppColors.lightInk2,
    ink3: AppColors.lightInk3,
    page: AppColors.lightPage,
    chrome: AppColors.lightChrome,
    chromeFg: AppColors.lightChromeFg,
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    action: AppColors.action,
    critical: AppColors.critical,
    okBg: AppColors.lightOkBg,
    okInk: AppColors.lightOkInk,
    warnBg: AppColors.lightWarnBg,
    warnInk: AppColors.lightWarnInk,
    infoBg: AppColors.lightInfoBg,
    infoInk: AppColors.lightInfoInk,
    critBg: AppColors.lightCritBg,
    critInk: AppColors.lightCritInk,
    pillMute: AppColors.pillMuteLight,
  );

  static const AppPalette dark = AppPalette(
    ground: AppColors.darkGround,
    surface: AppColors.darkSurface,
    surface2: AppColors.darkSurface2,
    line: AppColors.darkLine,
    lineSoft: AppColors.darkLineSoft,
    ink: AppColors.darkInk,
    ink2: AppColors.darkInk2,
    ink3: AppColors.darkInk3,
    page: AppColors.darkPage,
    chrome: AppColors.darkChrome,
    chromeFg: AppColors.darkChromeFg,
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    action: AppColors.action,
    critical: AppColors.critical,
    okBg: AppColors.darkOkBg,
    okInk: AppColors.darkOkInk,
    warnBg: AppColors.darkWarnBg,
    warnInk: AppColors.darkWarnInk,
    infoBg: AppColors.darkInfoBg,
    infoInk: AppColors.darkInfoInk,
    critBg: AppColors.darkCritBg,
    critInk: AppColors.darkCritInk,
    pillMute: AppColors.pillMuteDark,
  );

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? lineSoft,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? page,
    Color? chrome,
    Color? chromeFg,
    Color? accent,
    Color? accentInk,
    Color? action,
    Color? critical,
    Color? okBg,
    Color? okInk,
    Color? warnBg,
    Color? warnInk,
    Color? infoBg,
    Color? infoInk,
    Color? critBg,
    Color? critInk,
    Color? pillMute,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      page: page ?? this.page,
      chrome: chrome ?? this.chrome,
      chromeFg: chromeFg ?? this.chromeFg,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      action: action ?? this.action,
      critical: critical ?? this.critical,
      okBg: okBg ?? this.okBg,
      okInk: okInk ?? this.okInk,
      warnBg: warnBg ?? this.warnBg,
      warnInk: warnInk ?? this.warnInk,
      infoBg: infoBg ?? this.infoBg,
      infoInk: infoInk ?? this.infoInk,
      critBg: critBg ?? this.critBg,
      critInk: critInk ?? this.critInk,
      pillMute: pillMute ?? this.pillMute,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ground: c(ground, other.ground),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      line: c(line, other.line),
      lineSoft: c(lineSoft, other.lineSoft),
      ink: c(ink, other.ink),
      ink2: c(ink2, other.ink2),
      ink3: c(ink3, other.ink3),
      page: c(page, other.page),
      chrome: c(chrome, other.chrome),
      chromeFg: c(chromeFg, other.chromeFg),
      accent: c(accent, other.accent),
      accentInk: c(accentInk, other.accentInk),
      action: c(action, other.action),
      critical: c(critical, other.critical),
      okBg: c(okBg, other.okBg),
      okInk: c(okInk, other.okInk),
      warnBg: c(warnBg, other.warnBg),
      warnInk: c(warnInk, other.warnInk),
      infoBg: c(infoBg, other.infoBg),
      infoInk: c(infoInk, other.infoInk),
      critBg: c(critBg, other.critBg),
      critInk: c(critInk, other.critInk),
      pillMute: c(pillMute, other.pillMute),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}
