import '../../../app/common/app_error_code.dart';

/// ScheduleResult
///
/// Lightweight success/failure result for scheduling operations.
///
/// PARITY: Corresponds to reef-b-app's schedule result handling:
/// - DropHeadRecordSettingViewModel: observes BLE command callbacks for success/failure
/// - BLE opcodes 0x70-0x74 return status: 0x00=failed, 0x01=success
/// - On success: updates DropInformation mode, shows toast, refreshes UI
/// - On failure: shows error toast, keeps current state
class ScheduleResult {
  final bool isSuccess;
  final AppErrorCode? errorCode;

  const ScheduleResult._({required this.isSuccess, this.errorCode});

  const ScheduleResult.success() : this._(isSuccess: true);

  const ScheduleResult.failure({required AppErrorCode errorCode})
    : this._(isSuccess: false, errorCode: errorCode);
}
