/// A user-safe application error. Technical causes stay in logs and are never
/// rendered directly in the UI.
class AppFailure implements Exception {
  const AppFailure(this.userMessage, {this.code});

  final String userMessage;
  final String? code;

  @override
  String toString() => userMessage;
}

/// Lightweight result type for boundaries where exceptions should not cross a
/// feature interface.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get value => switch (this) {
        Success<T>(value: final value) => value,
        Failure<T>() => null,
      };

  AppFailure? get failure => switch (this) {
        Success<T>() => null,
        Failure<T>(error: final error) => error,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppFailure error;
}
