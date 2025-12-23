import 'dart:typed_data';

import '../../domain/device/device_context.dart';
import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_state.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/schedule/led/led_schedule_command_builder.dart';
import '../../infrastructure/ble/schedule/led/led_schedule_payload.dart';
import '../../infrastructure/ble/schedule/led/led_schedule_encoder.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

import 'led_schedule_capability_guard.dart';
import 'led_schedule_result.dart';
import 'led_schedule_result_mapper.dart';

/// ApplyLedScheduleUseCase
///
/// Mirrors the dosing schedule orchestration but targets LED schedules.
class ApplyLedScheduleUseCase {
  final LedRepository ledRepository;
  final LedScheduleCapabilityGuard ledScheduleCapabilityGuard;
  final LedScheduleResultMapper ledScheduleResultMapper;
  final LedScheduleCommandBuilder ledScheduleCommandBuilder;
  final CurrentDeviceSession currentDeviceSession;
  final BleAdapter bleAdapter;
  final BleWriteOptions writeOptions;

  const ApplyLedScheduleUseCase({
    required this.ledRepository,
    required this.ledScheduleCapabilityGuard,
    required this.ledScheduleResultMapper,
    required this.ledScheduleCommandBuilder,
    required this.currentDeviceSession,
    required this.bleAdapter,
    BleWriteOptions? writeOptions,
  }) : writeOptions = writeOptions ?? const BleWriteOptions();

  Future<LedScheduleResult> execute({
    required String deviceId,
    required String scheduleId,
    required LedSchedule schedule,
  }) async {
    final DeviceContext deviceContext;
    try {
      deviceContext = currentDeviceSession.requireContext;
    } on AppError catch (error) {
      return LedScheduleResult.failure(errorCode: error.code);
    }

    if (deviceContext.deviceId != deviceId) {
      return LedScheduleResult.failure(errorCode: AppErrorCode.invalidParam);
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

    final LedState? ledState = await ledRepository.getLedState(deviceId);
    if (ledState != null && ledState.status != LedStatus.idle) {
      return LedScheduleResult.failure(errorCode: AppErrorCode.deviceBusy);
    }

    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.applying,
    );

    // 4) Branch by schedule type to ensure the correct builder path runs.
    try {
      final LedSchedulePayload payload = ledScheduleCommandBuilder.build(
        schedule,
      );
      final Uint8List bytes = encodeLedSchedulePayload(payload);
      final LedScheduleResult result = await _sendPayload(
        deviceId: deviceId,
        payload: bytes,
      );
      if (!result.isSuccess) {
        await _markError(deviceId);
        return result;
      }
      await ledRepository.applySchedule(
        deviceId: deviceId,
        scheduleId: scheduleId,
      );
      return result;
    } on StateError {
      await _markError(deviceId);
      return LedScheduleResult.failure(errorCode: AppErrorCode.invalidParam);
    } catch (_) {
      await _markError(deviceId);
      return LedScheduleResult.failure(
        errorCode: ledScheduleResultMapper.unknownFailure(),
      );
    }
  }

  Future<LedScheduleResult> _sendPayload({
    required String deviceId,
    required Uint8List payload,
  }) async {
    try {
      await bleAdapter.writeBytes(
        deviceId: deviceId,
        data: payload,
        options: writeOptions,
      );
      return const LedScheduleResult.success();
    } on BleWriteTimeoutException {
      return LedScheduleResult.failure(
        errorCode: ledScheduleResultMapper.transportFailure(),
      );
    } on BleWriteException {
      return LedScheduleResult.failure(
        errorCode: ledScheduleResultMapper.transportFailure(),
      );
    } catch (_) {
      return LedScheduleResult.failure(
        errorCode: ledScheduleResultMapper.unknownFailure(),
      );
    }
  }

  Future<void> _markError(String deviceId) async {
    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.error,
    );
    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.idle,
    );
  }
}
