/// Central place for backend endpoint config. Swap [baseUrl] per
/// environment via `--dart-define=API_BASE_URL=...`; defaults to the
/// production server.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://callfororders.in',
  );

  /// Every seller endpoint lives under this prefix — repositories build
  /// paths as `${ApiConfig.sellerPrefix}/orders` etc.
  static const String sellerPrefix = '/api/seller';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
