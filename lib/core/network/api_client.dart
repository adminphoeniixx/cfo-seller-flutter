import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import 'api_config.dart';
import 'api_exception_mapper.dart';
import 'api_interceptor.dart';
import 'network_result.dart';

/// Thin wrapper around [Dio] returning [NetworkResult] instead of raising.
/// Repositories depend on this, never on Dio directly — swapping HTTP
/// clients or backends later touches only this file.
class ApiClient {
  final Dio _dio;

  ApiClient({required ApiInterceptor interceptor})
    : _dio = Dio(
        BaseOptions(
          // Every seller endpoint lives under this prefix, so repository
          // paths match the API docs verbatim: '/login', '/me', '/orders'.
          baseUrl: '${ApiConfig.baseUrl}${ApiConfig.sellerPrefix}',
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      )..interceptors.add(interceptor);

  Future<NetworkResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.get(path, queryParameters: query), parse);

  Future<NetworkResult<T>> post<T>(
    String path, {
    dynamic body,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.post(path, data: body), parse);

  Future<NetworkResult<T>> put<T>(
    String path, {
    dynamic body,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.put(path, data: body), parse);

  Future<NetworkResult<T>> patch<T>(
    String path, {
    dynamic body,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.patch(path, data: body), parse);

  Future<NetworkResult<T>> delete<T>(
    String path, {
    dynamic body,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.delete(path, data: body), parse);

  /// Multipart upload — `fields` become additional form fields (e.g.
  /// `folder`) alongside the file.
  Future<NetworkResult<T>> upload<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, String> fields = const {},
    required T Function(dynamic json) parse,
  }) async {
    final formData = FormData.fromMap({
      ...fields,
      fileFieldName: await MultipartFile.fromFile(filePath),
    });
    return _request(() => _dio.post(path, data: formData), parse);
  }

  Future<NetworkResult<T>> _request<T>(
    Future<Response> Function() call,
    T Function(dynamic json) parse,
  ) async {
    try {
      final response = await call();
      return Success(parse(response.data));
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (_) {
      return const Failure(UnknownException());
    }
  }
}
