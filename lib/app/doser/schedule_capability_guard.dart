import '../../domain/doser_dosing/doser_schedule_type.dart';

/// Ensures schedule commands only proceed when the device capability allows
/// them (currently only guards oneshot schedule support).
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
