import '../../domain/device/capability/capability_id.dart';
import '../../domain/device/capability/capability_snapshot.dart';
import '../../domain/led_lighting/led_schedule_type.dart';

/// Ensures LED schedule commands are only attempted on supported devices.
class LedScheduleCapabilityGuard {
  const LedScheduleCapabilityGuard();

  bool supportsDaily(CapabilitySnapshot snapshot) {
    return snapshot.supports(CapabilityId.ledScheduleDaily);
  }

  bool supportsCustom(CapabilitySnapshot snapshot) {
    return snapshot.supports(CapabilityId.ledScheduleCustom);
  }

  bool supportsScene(CapabilitySnapshot snapshot) {
    return snapshot.supports(CapabilityId.ledScheduleScene);
  }

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

  bool canProceedWithSnapshot({
    required LedScheduleType scheduleType,
    required CapabilitySnapshot snapshot,
  }) {
    switch (scheduleType) {
      case LedScheduleType.daily:
        return supportsDaily(snapshot);
      case LedScheduleType.custom:
        return supportsCustom(snapshot);
      case LedScheduleType.scene:
        return supportsScene(snapshot);
    }
  }
}
