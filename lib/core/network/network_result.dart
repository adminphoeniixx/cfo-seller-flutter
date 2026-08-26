import '../errors/app_exception.dart';

/// Explicit success/failure wrapper returned by every repository method, so
/// controllers handle errors via pattern matching instead of try/catch
/// leaking into the UI layer.
sealed class NetworkResult<T> {
  const NetworkResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failure<T>) return failure(self.error);
    throw StateError('Unreachable');
  }
}

class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends NetworkResult<T> {
  final AppException error;
  const Failure(this.error);
}
