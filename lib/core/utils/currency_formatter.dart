import 'package:intl/intl.dart';

/// Central INR formatter — mirrors the prototype's `money()` (2 decimals)
/// and `short()` (0 decimals) helpers. All currency display must go through
/// here so grouping/rounding stays consistent across the app.
class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _full = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _short = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// e.g. ₹9,998.00
  static String money(num value) => _full.format(value);

  /// e.g. ₹9,998
  static String short(num value) => _short.format(value);
}
