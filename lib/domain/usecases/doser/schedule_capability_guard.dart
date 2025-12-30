import '../../doser_dosing/doser_schedule_type.dart';

/// ScheduleCapabilityGuard
///
/// Ensures schedule commands only proceed when the device capability allows
/// them (currently only guards oneshot schedule support).
///
/// PARITY: Corresponds to reef-b-app's capability checking:
/// - DropHeadRecordSettingViewModel: checks device capabilities before applying schedule
/// - DeviceContext.supportsOneshotSchedule checks firmware version/capability
/// - Prevents sending unsupported schedule types to device
class ScheduleCapabilityGuard {
  const ScheduleCapabilityGuard();

  /// Returns `true` when the schedule can proceed, `false` when blocked.
  bool canProceed({
    required DoserScheduleType scheduleType,
    required bool isOneshotSupported,
  }) {
    if (scheduleType != DoserScheduleType.oneshotSchedule) {
      return true;
    }

    return isOneshotSupported;
  }
}
