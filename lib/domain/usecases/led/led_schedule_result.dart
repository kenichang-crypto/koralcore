import '../../../app/common/app_error_code.dart';

/// LedScheduleResult
///
/// Lightweight result for LED scheduling flows.
///
/// PARITY: Corresponds to reef-b-app's LED schedule result handling:
/// - LedScheduleEditActivity: observes BLE command callbacks for success/failure
/// - BLE opcode 0x41 (set record) returns status: 0x00=failed, 0x01=success
/// - On success: updates LedInformation, shows toast, navigates back
/// - On failure: shows error toast, keeps current state
class LedScheduleResult {
  final bool isSuccess;
  final AppErrorCode? errorCode;

  const LedScheduleResult._({required this.isSuccess, this.errorCode});

  const LedScheduleResult.success() : this._(isSuccess: true);

  const LedScheduleResult.failure({required AppErrorCode errorCode})
    : this._(isSuccess: false, errorCode: errorCode);
}
