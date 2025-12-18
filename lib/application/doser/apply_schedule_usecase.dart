import '../../domain/device/device_context.dart';
import '../../domain/doser_dosing/doser_schedule.dart';
import '../../domain/doser_dosing/doser_schedule_type.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../session/current_device_session.dart';

import 'schedule_capability_guard.dart';
import 'schedule_result.dart';
import 'schedule_result_mapper.dart';

/// ApplyScheduleUseCase
///
/// Application orchestration for applying a `DoserSchedule` to the current
/// device. Manual / single commands (BLE 15/16) are **not** handled here.
class ApplyScheduleUseCase {
  final DeviceRepository deviceRepository;
  final ScheduleCapabilityGuard scheduleCapabilityGuard;
  final ScheduleResultMapper scheduleResultMapper;
  final CurrentDeviceSession currentDeviceSession;

  const ApplyScheduleUseCase({
    required this.deviceRepository,
    required this.scheduleCapabilityGuard,
    required this.scheduleResultMapper,
    required this.currentDeviceSession,
  });

  /// Executes the scheduling flow.
  ///
  Future<ScheduleResult> execute({required DoserSchedule schedule}) async {
    final DeviceContext deviceContext;
    try {
      deviceContext = currentDeviceSession.requireContext();
    } on AppError catch (error) {
      return ScheduleResult.failure(errorCode: error.code);
    }

    // 2) NOTE: Schedule is assumed valid; caller must invoke
    //    DoserScheduleValidator beforehand (Application layer does not repeat
    //    domain validation).

    final bool guardAllows = scheduleCapabilityGuard.canProceed(
      scheduleType: schedule.type,
      isOneshotSupported: deviceContext.supportsOneshotSchedule,
    );
    if (!guardAllows) {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.guardNotSupported(),
      );
    }

    // 4) TODO: Branch based on schedule.type (manual / BLE 15 / BLE 16 are
    //    intentionally excluded from this UseCase).
    switch (schedule.type) {
      case DoserScheduleType.h24:
      case DoserScheduleType.custom:
        // TODO: Invoke existing schedule BLE flow for 24h/custom via
        //    deviceRepository.applySchedule(...) or equivalent adapter call.
        // TODO: Build payload via schedule_command_builder + branch-specific
        //    builder implementations.
        // TODO: Send payload via infrastructure ScheduleSender (no BLE logic
        //    embedded in the use case).
        // TODO: Map BLE response to ScheduleResult using ScheduleResultMapper.
        // TODO: Return ScheduleResult.success() once BLE command finishes.
        return ScheduleResult.failure(
          errorCode: scheduleResultMapper.unknownFailure(),
        );

      case DoserScheduleType.oneshotSchedule:
        // TODO: Build oneshot payload via schedule_command_builder ->
        //    buildOneshotScheduleCommand.
        // TODO: Send payload via ScheduleSender to the BLE adapter.
        // TODO: Map BLE response to ScheduleResult via ScheduleResultMapper.
        // TODO: Return ScheduleResult.success() once BLE chain finishes.
        return ScheduleResult.failure(
          errorCode: scheduleResultMapper.unknownFailure(),
        );
    }
  }
}
