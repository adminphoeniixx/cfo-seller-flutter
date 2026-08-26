import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Attaches the bearer token to every outgoing request. Centralized here so
/// no repository has to remember to do this itself.
class ApiInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  ApiInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }
}
