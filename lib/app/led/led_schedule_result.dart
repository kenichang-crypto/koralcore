import '../common/app_error_code.dart';

/// Lightweight result for LED scheduling flows.
class LedScheduleResult {
  final bool isSuccess;
  final AppErrorCode? errorCode;

  const LedScheduleResult._({required this.isSuccess, this.errorCode});

  const LedScheduleResult.success() : this._(isSuccess: true);

  const LedScheduleResult.failure({required AppErrorCode errorCode})
    : this._(isSuccess: false, errorCode: errorCode);
}
