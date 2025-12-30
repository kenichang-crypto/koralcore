import 'dart:typed_data';

import '../../domain/device/device_context.dart';
import '../../domain/doser_dosing/pump_head.dart';
import '../../domain/doser_dosing/single_dose_immediate.dart';
import '../../data/ble/ble_adapter.dart';
import '../../data/ble/encoder/doser/immediate_single_dose_encoder.dart';
import '../../data/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';
import 'read_today_total.dart';

/// SingleDoseImmediateUseCase
///
/// Application-level orchestration for sending an immediate single dose (BLE cmd 15).
/// Responsibilities:
/// - Flow control
/// - Map domain model to BLE payload
/// - Send payload over the hardened BLE transport
class SingleDoseImmediateUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;
  final BleAdapter bleAdapter;
  final PumpHeadRepository pumpHeadRepository;
  final BleWriteOptions writeOptions;
  final ImmediateSingleDoseEncoder immediateSingleDoseEncoder;
  final ReadTodayTotalUseCase readTodayTotalUseCase;

  static const double _defaultDailyLimitMl = 30.0;

  SingleDoseImmediateUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.bleAdapter,
    required this.pumpHeadRepository,
    required this.readTodayTotalUseCase,
    BleWriteOptions? writeOptions,
    ImmediateSingleDoseEncoder? immediateSingleDoseEncoder,
  }) : writeOptions = writeOptions ?? const BleWriteOptions(),
       immediateSingleDoseEncoder =
           immediateSingleDoseEncoder ?? ImmediateSingleDoseEncoder();

  /// Steps (execute):
  /// 1. Ensure the target device is the current device or specified by caller
  /// 2. Map `SingleDoseImmediate` domain model into BLE payload (bytes)
  /// 3. Invoke the shared BLE transport to send the payload
  /// 4. Optionally persist dosing event in repository (TODO)
  /// 5. Return control to caller
  Future<void> execute({
    required String deviceId,
    required SingleDoseImmediate dose,
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

    final bool hasFractionalDose = _hasFractionalComponent(dose.doseMl);
    if (hasFractionalDose && !deviceContext.supportsDecimalMl) {
      throw AppError(
        code: AppErrorCode.notSupported,
        message:
            'Fractional mL doses require doserDecimalMl capability; round the '
            'dose before invoking this use case.',
      );
    }

    final String headId = _headIdFromPumpId(dose.pumpId);
    final PumpHead? pumpHead = await _maybeLoadPumpHead(deviceId, headId);
    _validatePumpHeadState(pumpHead, dose);

    final Uint8List payload = Uint8List.fromList(
      immediateSingleDoseEncoder.encode(dose),
    );

    final bool shouldUpdateStatus = pumpHead != null;
    if (shouldUpdateStatus) {
      await _setPumpHeadStatus(
        deviceId: deviceId,
        headId: headId,
        status: PumpHeadStatus.running,
      );
    }

    try {
      await bleAdapter.writeBytes(
        deviceId: deviceId,
        data: payload,
        options: writeOptions,
      );
      await _refreshTodayTotals(deviceId: deviceId, headId: headId);
      if (shouldUpdateStatus) {
        await _setPumpHeadStatus(
          deviceId: deviceId,
          headId: headId,
          status: PumpHeadStatus.idle,
        );
      }
    } on BleWriteTimeoutException catch (error) {
      if (shouldUpdateStatus) {
        await _markPumpHeadErrored(deviceId: deviceId, headId: headId);
      }
      throw AppError(code: AppErrorCode.transportError, message: error.message);
    } on BleWriteException catch (error) {
      if (shouldUpdateStatus) {
        await _markPumpHeadErrored(deviceId: deviceId, headId: headId);
      }
      throw AppError(code: AppErrorCode.transportError, message: error.message);
    } catch (error) {
      if (shouldUpdateStatus) {
        await _markPumpHeadErrored(deviceId: deviceId, headId: headId);
      }
      rethrow;
    }
  }

  bool _hasFractionalComponent(double value) {
    return value != value.truncateToDouble();
  }

  Future<PumpHead?> _maybeLoadPumpHead(String deviceId, String headId) async {
    try {
      return await pumpHeadRepository.getPumpHead(deviceId, headId);
    } catch (_) {
      return null;
    }
  }

  void _validatePumpHeadState(PumpHead? pumpHead, SingleDoseImmediate dose) {
    if (pumpHead != null && pumpHead.status != PumpHeadStatus.idle) {
      throw const AppError(
        code: AppErrorCode.deviceBusy,
        message: 'Pump head is busy',
      );
    }

    final double currentTotal = pumpHead?.todayDispensedMl ?? 0;
    final double dailyLimit = _resolveDailyLimit(pumpHead);
    if (currentTotal + dose.doseMl > dailyLimit) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Manual dose exceeds daily allowance',
      );
    }
  }

  double _resolveDailyLimit(PumpHead? pumpHead) {
    final double target = pumpHead?.dailyTargetMl ?? 0;
    if (target > 0) {
      return target;
    }
    return _defaultDailyLimitMl;
  }

  Future<void> _setPumpHeadStatus({
    required String deviceId,
    required String headId,
    required PumpHeadStatus status,
  }) async {
    try {
      await pumpHeadRepository.updateStatus(
        deviceId: deviceId,
        headId: headId,
        status: status,
      );
    } catch (_) {
      // Intentionally swallow status update errors.
    }
  }

  Future<void> _refreshTodayTotals({
    required String deviceId,
    required String headId,
  }) async {
    try {
      await readTodayTotalUseCase.execute(deviceId: deviceId, headId: headId);
    } catch (_) {
      // Swallow refresh errors; manual dose already succeeded.
    }
  }

  Future<void> _markPumpHeadErrored({
    required String deviceId,
    required String headId,
  }) async {
    await _setPumpHeadStatus(
      deviceId: deviceId,
      headId: headId,
      status: PumpHeadStatus.error,
    );
    await _setPumpHeadStatus(
      deviceId: deviceId,
      headId: headId,
      status: PumpHeadStatus.idle,
    );
  }

  String _headIdFromPumpId(int pumpId) {
    final int index = pumpId.clamp(1, 26) - 1;
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}
