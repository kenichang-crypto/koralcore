import '../../domain/led_lighting/led_schedule_type.dart';

/// Ensures LED schedule commands are only attempted on supported devices.
class LedScheduleCapabilityGuard {
  const LedScheduleCapabilityGuard();

  bool canProceed({
    required LedScheduleType scheduleType,
    required bool supportsDaily,
    required bool supportsCustom,
    required bool supportsScene,
  }) {
    switch (scheduleType) {
      case LedScheduleType.daily:
        return supportsDaily;
      case LedScheduleType.custom:
        return supportsCustom;
      case LedScheduleType.scene:
        return supportsScene;
    }
  }
}
