import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_schedule_type.dart';
import '../../platform/contracts/device_repository.dart';

import 'led_schedule_capability_guard.dart';
import 'led_schedule_result.dart';
import 'led_schedule_result_mapper.dart';

/// ApplyLedScheduleUseCase
///
/// Mirrors the dosing schedule orchestration but targets LED schedules.
class ApplyLedScheduleUseCase {
  final DeviceRepository deviceRepository;
  final LedScheduleCapabilityGuard ledScheduleCapabilityGuard;
  final LedScheduleResultMapper ledScheduleResultMapper;

  const ApplyLedScheduleUseCase({
    required this.deviceRepository,
    required this.ledScheduleCapabilityGuard,
    required this.ledScheduleResultMapper,
  });

  Future<LedScheduleResult> execute({required LedSchedule schedule}) async {
    // 1) TODO: deviceRepository.getCurrentDevice() to load product/capability
    //    metadata for the currently connected light.

    // 2) NOTE: LED schedule is assumed to be validated upstream via the
    //    domain validator (no re-validation in Application layer).

    // 3) TODO: Extract LED schedule capability flags (daily/custom/scene) from
    //    device metadata returned in step 1.
    final bool supportsDailySchedules = true;
    final bool supportsCustomSchedules = true;
    final bool supportsSceneSchedules = true;

    final bool canProceed = ledScheduleCapabilityGuard.canProceed(
      scheduleType: schedule.type,
      supportsDaily: supportsDailySchedules,
      supportsCustom: supportsCustomSchedules,
      supportsScene: supportsSceneSchedules,
    );
    if (!canProceed) {
      return LedScheduleResult.failure(
        errorCode: ledScheduleResultMapper.guardNotSupported(),
      );
    }

    // 4) TODO: Branch based on schedule.type to invoke the appropriate builder
    //    and sending flow (no BLE details within Application layer).
    switch (schedule.type) {
      case LedScheduleType.daily:
      case LedScheduleType.custom:
        // TODO: Build LED daily/custom schedule payload via upcoming builders.
        // TODO: Send payload via LED schedule sender abstraction.
        // TODO: Map BLE response to result once transport layer is wired up.
        return LedScheduleResult.failure(
          errorCode: ledScheduleResultMapper.unknownFailure(),
        );

      case LedScheduleType.scene:
        // TODO: Build scene payload via scene schedule builder.
        // TODO: Send payload via LED schedule sender abstraction.
        // TODO: Map BLE response to result once transport layer is wired up.
        return LedScheduleResult.failure(
          errorCode: ledScheduleResultMapper.unknownFailure(),
        );
    }
  }
}
