import 'app_error_code.dart';

/// Application-layer error wrapper for use cases.
class AppError implements Exception {
  final AppErrorCode code;
  final String message;

  const AppError({required this.code, required this.message});

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}
