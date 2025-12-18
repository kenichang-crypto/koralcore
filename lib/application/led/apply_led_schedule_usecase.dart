import '../../domain/device/device_context.dart';
import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_schedule_type.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../session/current_device_session.dart';

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
  final CurrentDeviceSession currentDeviceSession;

  const ApplyLedScheduleUseCase({
    required this.deviceRepository,
    required this.ledScheduleCapabilityGuard,
    required this.ledScheduleResultMapper,
    required this.ledScheduleCommandBuilder,
    required this.currentDeviceSession,
  });

  Future<LedScheduleResult> execute({required LedSchedule schedule}) async {
    final DeviceContext deviceContext;
    try {
      deviceContext = currentDeviceSession.requireContext();
    } on AppError catch (error) {
      return LedScheduleResult.failure(errorCode: error.code);
    }

    // 2) NOTE: LED schedule is assumed to be validated upstream via the
    //    domain validator (no re-validation in Application layer).

    final bool supportsDailySchedules = deviceContext.supportsLedScheduleDaily;
    final bool supportsCustomSchedules =
        deviceContext.supportsLedScheduleCustom;
    final bool supportsSceneSchedules = deviceContext.supportsLedScheduleScene;

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

    // TODO: Send payload via LED schedule sender abstraction.
    // TODO: Map BLE response to result once transport layer is wired up.
    // TODO: Remove placeholder failure once wiring is complete.
    return LedScheduleResult.failure(
      errorCode: ledScheduleResultMapper.unknownFailure(),
    );
  }
}
