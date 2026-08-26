/// Spacing scale distilled from the prototype's recurring gap/padding
/// values (screen padding 14px, card padding 13px, row gap 9-11px, etc).
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 6;
  static const double smd = 9;
  static const double md = 11;
  static const double lg = 13;
  static const double xl = 14;
  static const double xxl = 20;

  /// `.screen` padding: 14px 14px 20px, gap 11px between children.
  static const double screenH = 14;
  static const double screenTop = 14;
  static const double screenBottom = 20;
  static const double screenGap = 11;

  /// `.card` padding.
  static const double cardPad = 13;

  /// `.row` padding: 11px 12px.
  static const double rowV = 11;
  static const double rowH = 12;
  static const double rowGap = 10;

  /// `.kpis` grid gap.
  static const double kpiGap = 9;
}
