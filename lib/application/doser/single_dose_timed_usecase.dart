import 'dart:typed_data';

import '../../domain/device/device_context.dart';
import '../../domain/doser/encoder/timed_single_dose_encoder.dart';
import '../../domain/doser_dosing/single_dose_timed.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

/// SingleDoseTimedUseCase
///
/// Application-level orchestration for scheduling a single timed dose (BLE cmd 16).
/// Responsibilities:
/// - Flow control
/// - Map domain model to BLE payload
/// - Send payload over the hardened BLE transport
class SingleDoseTimedUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;
  final BleAdapter bleAdapter;
  final BleWriteOptions writeOptions;
  final TimedSingleDoseEncoder timedSingleDoseEncoder;

  SingleDoseTimedUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.bleAdapter,
    BleWriteOptions? writeOptions,
    TimedSingleDoseEncoder? timedSingleDoseEncoder,
  }) : writeOptions = writeOptions ?? const BleWriteOptions(),
       timedSingleDoseEncoder =
           timedSingleDoseEncoder ?? TimedSingleDoseEncoder();

  /// Steps (execute):
  /// 1. Ensure the target device is the current device or specified by caller
  /// 2. Map `SingleDoseTimed` domain model into BLE payload (bytes)
  /// 3. Invoke the shared BLE transport to schedule the dose
  /// 4. Optionally persist scheduled event in repository (TODO)
  /// 5. Return control to caller
  Future<void> execute({
    required String deviceId,
    required SingleDoseTimed dose,
  }) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext();

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
            'Fractional mL doses require doserDecimalMl capability; adjust the '
            'requested dose or upgrade device firmware.',
      );
    }

    final Uint8List payload = timedSingleDoseEncoder.encode(dose);

    try {
      await bleAdapter.writeBytes(
        deviceId: deviceId,
        data: payload,
        options: writeOptions,
      );
    } on BleWriteTimeoutException catch (error) {
      throw AppError(code: AppErrorCode.transportError, message: error.message);
    } on BleWriteException catch (error) {
      throw AppError(code: AppErrorCode.transportError, message: error.message);
    }
  }

  bool _hasFractionalComponent(double value) {
    return value != value.truncateToDouble();
  }
}
