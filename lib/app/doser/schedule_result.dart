import '../common/app_error_code.dart';

/// Lightweight success/failure result for scheduling operations.
class ScheduleResult {
  final bool isSuccess;
  final AppErrorCode? errorCode;

  const ScheduleResult._({required this.isSuccess, this.errorCode});

  const ScheduleResult.success() : this._(isSuccess: true);

  const ScheduleResult.failure({required AppErrorCode errorCode})
    : this._(isSuccess: false, errorCode: errorCode);
}
