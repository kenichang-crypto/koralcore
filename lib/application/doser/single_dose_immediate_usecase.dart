import 'dart:typed_data';

import '../../domain/device/device_context.dart';
import '../../domain/doser_dosing/single_dose_immediate.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/encoder/doser/immediate_single_dose_encoder.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

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
  final BleWriteOptions writeOptions;
  final ImmediateSingleDoseEncoder immediateSingleDoseEncoder;

  SingleDoseImmediateUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.bleAdapter,
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
            'Fractional mL doses require doserDecimalMl capability; round the '
            'dose before invoking this use case.',
      );
    }

    final Uint8List payload = Uint8List.fromList(
      immediateSingleDoseEncoder.encode(dose),
    );

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
