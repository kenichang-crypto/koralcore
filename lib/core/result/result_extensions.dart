import 'result.dart';
import 'success.dart';
import 'failure.dart';

extension ResultX<T> on Result<T> {
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  Failure<T>? get failureOrNull =>
      this is Failure<T> ? this as Failure<T> : null;
}
