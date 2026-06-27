import 'package:family_care_scheduler/core/errors/failures.dart';

/// Result of an operation that may fail with a [Failure].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final failure) => failure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  @override
  final Failure failure;
}
