/// Central place for backend endpoint config. Swap [baseUrl] per
/// environment via `--dart-define=API_BASE_URL=...` in production; defaults
/// to the QA/staging server from the Postman collection.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://projects-cfo-marketplace-laravel.rmsiry.easypanel.host',
  );

  /// Every seller endpoint lives under this prefix — repositories build
  /// paths as `${ApiConfig.sellerPrefix}/orders` etc.
  static const String sellerPrefix = '/api/seller';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
