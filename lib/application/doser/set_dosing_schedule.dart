/// ⚠️ LEGACY USE CASE — DO NOT EXTEND
///
/// This file is kept ONLY for backward compatibility with
/// existing UI / code paths.
///
/// New scheduling logic MUST use:
/// - ApplyScheduleUseCase
/// - ScheduleCapabilityGuard
/// - BLE Schedule Command Builders
///
/// This legacy use case:
/// - MUST NOT be extended
/// - MUST NOT support new schedule types (e.g. oneshot / 4K)
/// - MUST NOT contain BLE logic
///
/// Planned for removal after UI migration is completed.
library;

import '../../platform/contracts/device_repository.dart';
import '../../domain/doser_dosing/doser_schedule.dart';
import '../../domain/doser_dosing/doser_schedule_validator.dart';

/// SetDoserScheduleUseCase
///
/// Orchestrates setting a dosing schedule on a device.
/// Flow:
/// 1. Receive `DoserSchedule`
/// 2. Call `DoserScheduleValidator` to validate domain invariants
/// 3. Based on `schedule.type`:
///    - `h24` / `custom` -> TODO: call schedule BLE builder
///    - `oneshotSchedule` -> TODO: call BLE 32–34 builder
/// 4. On success, persist/mark schedule as set (TODO)
///
/// NOTE: BLE logic is intentionally left as TODOs.
class SetDoserScheduleUseCase {
  final DeviceRepository deviceRepository;

  /// Adapter responsible for sending dosing commands; left as dynamic placeholder
  final dynamic dosingAdapter;

  SetDoserScheduleUseCase({
    required this.deviceRepository,
    required this.dosingAdapter,
  });

  Future<void> execute({
    required String deviceId,
    required DoserSchedule schedule,
  }) async {
    // 1) Receive schedule (already provided)

    // 2) Validate schedule invariants via domain validator
    final errors = DoserScheduleValidator.validate(schedule);
    if (errors.isNotEmpty) {
      // TODO: Handle validation errors (return, throw, or convert to result type)
      return;
    }

    // 3) Dispatch based on schedule type
    switch (schedule.type) {
      case DoserScheduleType.h24:
        // TODO: build BLE payload for h24 (even distribution)
        // TODO: await dosingAdapter.sendH24Schedule(deviceId, payload);
        break;

      case DoserScheduleType.custom:
        // TODO: build BLE payload for custom schedule
        // TODO: await dosingAdapter.sendCustomSchedule(deviceId, payload);
        break;

      case DoserScheduleType.oneshotSchedule:
        // TODO: build BLE payload(s) for one-shot (BLE 32–34)
        // TODO: await dosingAdapter.sendOneShotSchedule(deviceId, payload);
        break;
    }

    // 4) On success: persist or mark schedule as set (application responsibility)
    // TODO: await deviceRepository.updateDeviceState(deviceId, 'schedule_set');
  }
}
