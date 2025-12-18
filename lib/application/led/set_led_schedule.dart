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

import '../../platform/contracts/device_repository.dart';
import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_schedule_type.dart';

/// SetLedScheduleUseCase
///
/// Legacy orchestration for LED schedules kept for backward compatibility.
class SetLedScheduleUseCase {
  final DeviceRepository deviceRepository;

  /// Adapter responsible for sending LED commands; left as dynamic placeholder.
  final dynamic ledAdapter;

  SetLedScheduleUseCase({
    required this.deviceRepository,
    required this.ledAdapter,
  });

  Future<void> execute({
    required String deviceId,
    required LedSchedule schedule,
  }) async {
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
}
