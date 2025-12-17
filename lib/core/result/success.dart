import 'result.dart';

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}
