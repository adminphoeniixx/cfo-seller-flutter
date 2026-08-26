/// Typed exceptions the network layer normalizes raw HTTP/Dio errors into,
/// so repositories and UI never touch Dio-specific error shapes directly.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Check your connection and try again.',
  ]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Please sign in again.']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = "You don't have permission to do that.",
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = "We couldn't find that."]);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;
  const ValidationException(super.message, {this.fieldErrors = const {}});
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on our end.']);
}

class RateLimitException extends AppException {
  const RateLimitException([
    super.message = 'Too many attempts. Please wait a minute and try again.',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something unexpected happened.']);
}
