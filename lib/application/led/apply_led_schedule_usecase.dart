import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_schedule_type.dart';
import '../../platform/contracts/device_repository.dart';

import '../../infrastructure/ble/schedule/led/led_schedule_command_builder.dart';
import '../../infrastructure/ble/schedule/led/led_schedule_payload.dart';

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
  final LedScheduleCommandBuilder ledScheduleCommandBuilder;

  const ApplyLedScheduleUseCase({
    required this.deviceRepository,
    required this.ledScheduleCapabilityGuard,
    required this.ledScheduleResultMapper,
    required this.ledScheduleCommandBuilder,
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

    // 4) Branch by schedule type to ensure the correct builder path runs.
    late final LedSchedulePayload payload;
    switch (schedule.type) {
      case LedScheduleType.daily:
        payload = ledScheduleCommandBuilder.build(schedule);
        break;
      case LedScheduleType.custom:
        payload = ledScheduleCommandBuilder.build(schedule);
        break;
      case LedScheduleType.scene:
        payload = ledScheduleCommandBuilder.build(schedule);
        break;
    }

    assert(payload is LedSchedulePayload, 'LED builder must return payload');

    // TODO: Send payload via LED schedule sender abstraction.
    // TODO: Map BLE response to result once transport layer is wired up.
    // TODO: Remove placeholder failure once wiring is complete.
    return LedScheduleResult.failure(
      errorCode: ledScheduleResultMapper.unknownFailure(),
    );
  }
}
