import 'package:flutter/material.dart';

/// Centralized icon tokens.
///
/// The bottom-nav glyphs and the bell are lifted VERBATIM from the HTML
/// prototype's inline `<svg>` `path` data into `assets/icons/*.svg` (see
/// `AppSvgIcon`) — Material Icons only approximated these shapes and didn't
/// match. Chrome/generic glyphs the prototype renders as plain text (back
/// `‹`, close `×`, account) have no SVG source to lift, so they still map
/// to the closest Material icon.
///
/// Never reference `Icons.*` or an asset path directly in a screen — add a
/// token here instead so a mismatch only needs fixing once.
class AppIcons {
  const AppIcons._();

  // ---------------------------------------------------- bottom nav (SVG)
  static const String homeAsset = 'assets/icons/nav_home.svg';
  static const String ordersAsset = 'assets/icons/nav_orders.svg';
  static const String productsAsset = 'assets/icons/nav_products.svg';
  static const String moneyAsset = 'assets/icons/nav_money.svg';
  static const String bellAsset = 'assets/icons/bell.svg';

  // -------------------------------------------------------------- chrome
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData account = Icons.account_circle_outlined;
  static const IconData chevronRight = Icons.chevron_right_rounded;

  // ------------------------------------------------------------- generic
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData more = Icons.more_horiz_rounded;
}
