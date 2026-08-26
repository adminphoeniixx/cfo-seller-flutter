import 'package:flutter/widgets.dart';

/// Text styles matching the prototype's `--sans` / `--mono` stacks and its
/// per-component font sizes/weights/letter-spacing. Colors are NOT baked in
/// here — apply `AppPalette.ink` etc. at the call site via `.copyWith(color:)`.
class AppTypography {
  const AppTypography._();

  static const List<String> sansFamilyFallback = [
    '-apple-system',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];
  static const List<String> monoFamilyFallback = [
    'SF Mono',
    'Menlo',
    'Consolas',
    'monospace',
  ];

  static const TextStyle _base = TextStyle(
    fontFamilyFallback: sansFamilyFallback,
    height: 1.2,
  );

  // ---------------------------------------------------------- status bar
  static TextStyle statusBar = _base.copyWith(
    fontFamilyFallback: monoFamilyFallback,
    fontSize: 11,
  );

  // -------------------------------------------------------------- app bar
  static TextStyle barTitle = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  static TextStyle barSubtitle = _base.copyWith(fontSize: 11.5);

  // ---------------------------------------------------------------- brand
  static TextStyle brandTitle = _base.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle brandSubtitle = _base.copyWith(fontSize: 12.5);

  // ------------------------------------------------------------- section
  static TextStyle sectionHeading = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );
  static TextStyle sectionAction = _base.copyWith(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
  );

  // ------------------------------------------------------------------ kpi
  static TextStyle kpiLabel = _base.copyWith(
    fontSize: 9.5,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.7,
  );
  static TextStyle kpiValue = _base.copyWith(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
  static TextStyle kpiDetail = _base.copyWith(fontSize: 10);

  // ------------------------------------------------------------------ row
  static TextStyle rowTitle = _base.copyWith(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
  );
  static TextStyle rowSubtitle = _base.copyWith(fontSize: 11.5);
  static TextStyle rowAmount = _base.copyWith(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
  );

  // ---------------------------------------------------------------- pill
  static TextStyle pill = _base.copyWith(
    fontSize: 9.5,
    fontWeight: FontWeight.bold,
  );

  // ---------------------------------------------------------------- chip
  static TextStyle chip = _base.copyWith(fontSize: 11.5);
  static TextStyle chipOn = chip.copyWith(fontWeight: FontWeight.w600);

  // -------------------------------------------------------------- button
  static TextStyle button = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // --------------------------------------------------------------- field
  static TextStyle fieldLabel = _base.copyWith(
    fontSize: 9.5,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  );
  static TextStyle fieldValue = _base.copyWith(fontSize: 14);

  // ---------------------------------------------------------------- misc
  static TextStyle note = _base.copyWith(fontSize: 11.5, height: 1.5);
  static TextStyle banner = _base.copyWith(fontSize: 11.5, height: 1.5);
  static TextStyle bigNumber = _base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );
  static TextStyle empty = _base.copyWith(fontSize: 12.5);
  static TextStyle tabLabel = _base.copyWith(fontSize: 10);
  static TextStyle tabLabelOn = tabLabel.copyWith(fontWeight: FontWeight.w600);
  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static TextStyle body = _base.copyWith(fontSize: 13.5);
  static TextStyle bodySmall = _base.copyWith(fontSize: 12);
}
