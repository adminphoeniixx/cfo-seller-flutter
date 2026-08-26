import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Converts a raw [DioException] into a typed [AppException]. This is the
/// single place that knows about HTTP status codes.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    default:
      break;
  }

  final status = e.response?.statusCode;
  final data = e.response?.data;
  final serverMessage = data is Map && data['message'] is String
      ? data['message'] as String
      : null;
  final storeStatus = data is Map ? data['store_status']?.toString() : null;
  final section = data is Map ? data['section']?.toString() : null;

  switch (status) {
    case 401:
      return UnauthorizedException(serverMessage ?? 'Please sign in again.');
    case 403:
      if (storeStatus != null && storeStatus.isNotEmpty) {
        return ForbiddenException(
          serverMessage ?? _storeStatusMessage(storeStatus),
        );
      }
      if (section != null && section.isNotEmpty) {
        return ForbiddenException(
          serverMessage ?? 'This seller section is not enabled for your store.',
        );
      }
      return ForbiddenException(
        serverMessage ?? "You don't have permission to do that.",
      );
    case 404:
      return NotFoundException(serverMessage ?? "We couldn't find that.");
    case 422:
      final errors = <String, List<String>>{};
      if (data is Map && data['errors'] is Map) {
        (data['errors'] as Map).forEach((k, v) {
          errors[k.toString()] = switch (v) {
            final List values => values.map((e) => e.toString()).toList(),
            final String value => [value],
            _ => [v.toString()],
          };
        });
      }
      return ValidationException(
        serverMessage ?? 'Some fields need attention.',
        fieldErrors: errors,
      );
    case 429:
      return RateLimitException(
        serverMessage ??
            'Too many attempts. Please wait a minute and try again.',
      );
    case 500:
    case 502:
    case 503:
      return ServerException(
        serverMessage ?? 'Something went wrong on our end.',
      );
    default:
      return UnknownException(
        serverMessage ?? 'Something unexpected happened.',
      );
  }
}

String _storeStatusMessage(String status) {
  return switch (status) {
    'pending' => 'Your store is still waiting for approval.',
    'suspended' => 'Your store is suspended. Contact marketplace support.',
    'rejected' => 'Your store was not approved. Contact marketplace support.',
    _ => 'Your store cannot use this feature right now.',
  };
}
