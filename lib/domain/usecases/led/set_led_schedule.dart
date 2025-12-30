/// ⚠️ LEGACY USE CASE — DO NOT EXTEND
///
/// This file is kept ONLY for backward compatibility with
/// existing UI / code paths.
///
/// New scheduling logic MUST use:
/// - ApplyLedScheduleUseCase
/// - LedScheduleCapabilityGuard
/// - LED Schedule Command Builders
///
/// This legacy use case:
/// - MUST NOT be extended
/// - MUST NOT support new schedule types beyond existing behavior
/// - MUST NOT contain BLE logic
///
/// Planned for removal after UI migration is completed.
library;

import '../../device/device_context.dart';
import '../../led_lighting/led_schedule.dart';
import '../../led_lighting/led_schedule_type.dart';
import '../../../platform/contracts/device_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../app/session/current_device_session.dart';

/// SetLedScheduleUseCase
///
/// ⚠️ LEGACY USE CASE — DO NOT EXTEND
///
/// Legacy orchestration for LED schedules kept for backward compatibility.
///
/// PARITY: Legacy use case - replaced by ApplyLedScheduleUseCase
/// - Original behavior: LedScheduleEditActivity applies schedules via BLE commands
/// - New implementation uses ApplyLedScheduleUseCase with proper BLE encoding
/// - BLE opcodes: 0x41 (set record), 0x2B (start record)
class SetLedScheduleUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  /// Adapter responsible for sending LED commands; left as dynamic placeholder.
  final dynamic ledAdapter;

  SetLedScheduleUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.ledAdapter,
  });

  Future<void> execute({
    required String deviceId,
    required LedSchedule schedule,
  }) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext;

    if (deviceContext.deviceId != deviceId) {
      throw AppError(
        code: AppErrorCode.invalidParam,
        message:
            'DeviceContext.deviceId (${deviceContext.deviceId}) must match '
            'target deviceId ($deviceId).',
      );
    }

    final bool supportsRequestedType = _supportsScheduleType(
      deviceContext: deviceContext,
      scheduleType: schedule.type,
    );
    if (!supportsRequestedType) {
      throw AppError(
        code: AppErrorCode.notSupported,
        message:
            'Device does not expose capability for ${schedule.type} schedules.',
      );
    }

    // 1) Receive schedule (already provided)

    // 2) TODO: Validate LED schedule invariants via domain validator once
    //    available.

    // 3) Dispatch based on schedule type
    switch (schedule.type) {
      case LedScheduleType.daily:
        // TODO: build LED payload for daily schedule
        // TODO: await ledAdapter.sendDailySchedule(deviceId, payload);
        break;

      case LedScheduleType.custom:
        // TODO: build LED payload for custom schedule
        // TODO: await ledAdapter.sendCustomLedSchedule(deviceId, payload);
        break;

      case LedScheduleType.scene:
        // TODO: build LED payload for scene schedule
        // TODO: await ledAdapter.sendSceneSchedule(deviceId, payload);
        break;
    }

    // 4) On success: persist or mark schedule as set (application responsibility)
    // TODO: await deviceRepository.updateDeviceState(deviceId, 'led_schedule_set');
  }

  bool _supportsScheduleType({
    required DeviceContext deviceContext,
    required LedScheduleType scheduleType,
  }) {
    switch (scheduleType) {
      case LedScheduleType.daily:
        return deviceContext.supportsLedScheduleDaily;
      case LedScheduleType.custom:
        return deviceContext.supportsLedScheduleCustom;
      case LedScheduleType.scene:
        return deviceContext.supportsLedScheduleScene;
    }
  }
}
