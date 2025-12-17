import 'result.dart';
import 'failure_type.dart';
import 'error_code.dart';

class Failure<T> extends Result<T> {
  final FailureType type;
  final ErrorCode code;
  final String message;

  const Failure({
    required this.type,
    required this.code,
    required this.message,
  });
}

