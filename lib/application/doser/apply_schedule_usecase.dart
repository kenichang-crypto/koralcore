import 'dart:typed_data';

import '../../domain/device/device_context.dart';
import '../../domain/doser_dosing/doser_schedule.dart';
import '../../domain/doser_dosing/doser_schedule_type.dart';
import '../../domain/doser_dosing/pump_head.dart';
import '../../domain/doser_schedule/custom_window_schedule_definition.dart';
import '../../domain/doser_schedule/daily_average_schedule_definition.dart';
import '../../infrastructure/ble/encoder/schedule/custom_schedule_chunk_encoder.dart';
import '../../infrastructure/ble/encoder/schedule/custom_schedule_encoder_0x72.dart';
import '../../infrastructure/ble/encoder/schedule/custom_schedule_encoder_0x73.dart';
import '../../infrastructure/ble/encoder/schedule/custom_schedule_encoder_0x74.dart';
import '../../infrastructure/ble/encoder/schedule/daily_average_schedule_encoder.dart';
import '../../infrastructure/ble/schedule/schedule_sender.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
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
  final PumpHeadRepository pumpHeadRepository;
  final ScheduleCapabilityGuard scheduleCapabilityGuard;
  final ScheduleResultMapper scheduleResultMapper;
  final CurrentDeviceSession currentDeviceSession;
  final ScheduleSender scheduleSender;
  final DailyAverageScheduleEncoder dailyAverageScheduleEncoder;
  final Map<int, CustomScheduleChunkEncoder> _customChunkEncoders;
  final BleWriteOptions writeOptions;

  ApplyScheduleUseCase({
    required this.deviceRepository,
    required this.pumpHeadRepository,
    required this.scheduleCapabilityGuard,
    required this.scheduleResultMapper,
    required this.currentDeviceSession,
    required this.scheduleSender,
    DailyAverageScheduleEncoder? dailyAverageScheduleEncoder,
    CustomScheduleEncoder0x72? customScheduleEncoder0x72,
    CustomScheduleEncoder0x73? customScheduleEncoder0x73,
    CustomScheduleEncoder0x74? customScheduleEncoder0x74,
    BleWriteOptions? writeOptions,
  }) : dailyAverageScheduleEncoder =
           dailyAverageScheduleEncoder ?? DailyAverageScheduleEncoder(),
       _customChunkEncoders = <int, CustomScheduleChunkEncoder>{
         0: customScheduleEncoder0x72 ?? CustomScheduleEncoder0x72(),
         1: customScheduleEncoder0x73 ?? CustomScheduleEncoder0x73(),
         2: customScheduleEncoder0x74 ?? CustomScheduleEncoder0x74(),
       },
       writeOptions = writeOptions ?? const BleWriteOptions();

  /// Executes the scheduling flow.
  ///
  Future<ScheduleResult> execute({required DoserSchedule schedule}) async {
    final DeviceContext deviceContext;
    try {
      deviceContext = currentDeviceSession.requireContext;
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

    final ScheduleResult? busyFailure = await _ensurePumpHeadIdle(
      deviceId: deviceContext.deviceId,
      pumpId: schedule.pumpId,
    );
    if (busyFailure != null) {
      return busyFailure;
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

  Future<ScheduleResult> applyDailyAverageSchedule({
    required String deviceId,
    required DailyAverageScheduleDefinition schedule,
  }) async {
    ScheduleResult? failure;
    final DeviceContext? deviceContext = _requireDeviceContextOrNull(
      onFailure: (ScheduleResult result) => failure = result,
    );
    if (deviceContext == null) {
      return failure!;
    }

    final ScheduleResult? contextFailure = _validateDeviceTarget(
      deviceContext: deviceContext,
      deviceId: deviceId,
      scheduleType: DoserScheduleType.h24,
    );
    if (contextFailure != null) {
      return contextFailure;
    }

    final ScheduleResult? busyFailure = await _ensurePumpHeadIdle(
      deviceId: deviceId,
      pumpId: schedule.pumpId,
    );
    if (busyFailure != null) {
      return busyFailure;
    }

    final Uint8List payload = dailyAverageScheduleEncoder.encode(schedule);
    return _sendSchedulePayloads(
      deviceId: deviceId,
      payloads: <Uint8List>[payload],
    );
  }

  Future<ScheduleResult> applyCustomWindowSchedule({
    required String deviceId,
    required CustomWindowScheduleDefinition schedule,
  }) async {
    ScheduleResult? failure;
    final DeviceContext? deviceContext = _requireDeviceContextOrNull(
      onFailure: (ScheduleResult result) => failure = result,
    );
    if (deviceContext == null) {
      return failure!;
    }

    final ScheduleResult? contextFailure = _validateDeviceTarget(
      deviceContext: deviceContext,
      deviceId: deviceId,
      scheduleType: DoserScheduleType.custom,
    );
    if (contextFailure != null) {
      return contextFailure;
    }

    final ScheduleResult? busyFailure = await _ensurePumpHeadIdle(
      deviceId: deviceId,
      pumpId: schedule.pumpId,
    );
    if (busyFailure != null) {
      return busyFailure;
    }

    final List<int> chunkIndexes =
        schedule.chunks
            .map((ScheduleWindowChunk chunk) => chunk.chunkIndex)
            .toSet()
            .toList()
          ..sort();
    if (chunkIndexes.isEmpty) {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.unknownFailure(),
      );
    }

    final List<Uint8List> payloads = <Uint8List>[];
    for (final int chunkIndex in chunkIndexes) {
      final CustomScheduleChunkEncoder? encoder =
          _customChunkEncoders[chunkIndex];
      if (encoder == null) {
        return ScheduleResult.failure(
          errorCode: scheduleResultMapper.unknownFailure(),
        );
      }
      payloads.add(encoder.encode(schedule));
    }

    return _sendSchedulePayloads(deviceId: deviceId, payloads: payloads);
  }

  DeviceContext? _requireDeviceContextOrNull({
    required void Function(ScheduleResult failure) onFailure,
  }) {
    try {
      return currentDeviceSession.requireContext;
    } on AppError catch (error) {
      onFailure(ScheduleResult.failure(errorCode: error.code));
      return null;
    }
  }

  ScheduleResult? _validateDeviceTarget({
    required DeviceContext deviceContext,
    required String deviceId,
    required DoserScheduleType scheduleType,
  }) {
    if (deviceContext.deviceId != deviceId) {
      return ScheduleResult.failure(errorCode: AppErrorCode.invalidParam);
    }

    final bool guardAllows = scheduleCapabilityGuard.canProceed(
      scheduleType: scheduleType,
      isOneshotSupported: deviceContext.supportsOneshotSchedule,
    );
    if (!guardAllows) {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.guardNotSupported(),
      );
    }

    return null;
  }

  Future<ScheduleResult> _sendSchedulePayloads({
    required String deviceId,
    required List<Uint8List> payloads,
  }) async {
    try {
      for (final Uint8List payload in payloads) {
        await scheduleSender.sendBytes(
          deviceId: deviceId,
          payload: payload,
          options: writeOptions,
        );
      }
      return const ScheduleResult.success();
    } on BleWriteTimeoutException {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.transportFailure(),
      );
    } on BleWriteException {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.transportFailure(),
      );
    } catch (_) {
      return ScheduleResult.failure(
        errorCode: scheduleResultMapper.unknownFailure(),
      );
    }
  }

  Future<ScheduleResult?> _ensurePumpHeadIdle({
    required String deviceId,
    required int pumpId,
  }) async {
    try {
      final PumpHead? head = await pumpHeadRepository.getPumpHead(
        deviceId,
        PumpHeadRepository.headIdFromPumpId(pumpId),
      );
      if (head != null && head.status == PumpHeadStatus.running) {
        return ScheduleResult.failure(errorCode: AppErrorCode.deviceBusy);
      }
    } catch (_) {
      // Ignore lookup errors and allow operation to proceed.
    }
    return null;
  }
}
