import '../../device/capability/capability_id.dart';
import '../../device/capability/capability_snapshot.dart';
import '../../led_lighting/led_schedule_type.dart';

/// LedScheduleCapabilityGuard
///
/// Ensures LED schedule commands are only attempted on supported devices.
///
/// PARITY: Corresponds to reef-b-app's capability checking:
/// - LedScheduleEditActivity: checks device capabilities before applying schedule
/// - DeviceContext checks firmware version/capability for schedule types
/// - Prevents sending unsupported schedule types to device
/// - Capabilities: ledScheduleDaily, ledScheduleCustom, ledScheduleScene
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
