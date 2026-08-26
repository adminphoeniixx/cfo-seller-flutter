import 'package:flutter/widgets.dart';

/// Border-radius scale lifted from the prototype's CSS (9-46px family).
class AppRadius {
  const AppRadius._();

  static const double xs = 9;
  static const double sm = 10;
  static const double md = 11;
  static const double lg = 13;
  static const double xl = 14;
  static const double pill = 20;
  static const double screen = 36;
  static const double device = 46;

  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}
