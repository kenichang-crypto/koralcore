import 'success.dart';
import 'failure.dart';

/// Base type for all platform results.
class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}
