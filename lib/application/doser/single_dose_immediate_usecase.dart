import '../../domain/device/device_context.dart';
import '../../domain/doser_dosing/single_dose_immediate.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

/// SingleDoseImmediateUseCase
///
/// Application-level orchestration for sending an immediate single dose (BLE cmd 15).
/// Responsibilities:
/// - Flow control only
/// - Map domain model to adapter call (TODO)
/// - Call adapter/repository as TODO (no BLE implementation here)
class SingleDoseImmediateUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  /// Adapter responsible for sending dosing commands to device.
  /// TODO: Replace `dynamic` with a concrete dosing adapter interface.
  final dynamic dosingAdapter;

  SingleDoseImmediateUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.dosingAdapter,
  });

  /// Steps (execute):
  /// 1. Ensure the target device is the current device or specified by caller
  /// 2. Map `SingleDoseImmediate` domain model into BLE payload (bytes)
  /// 3. Invoke adapter to send BLE command for immediate single dose
  ///    (e.g. dosingAdapter.sendSingleDoseImmediate(deviceId, payload))
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

    // 2) Map domain model -> BLE payload
    // TODO: final payload = mapSingleDoseImmediateToPayload(dose);

    // 3) Send BLE command via adapter
    // TODO: await dosingAdapter.sendSingleDoseImmediate(deviceId, payload);

    // 4) Persist or log the dosing action
    // TODO: await deviceRepository.saveDosingEvent(deviceId, ...)

    // 5) Return (no further action)
  }

  bool _hasFractionalComponent(double value) {
    return value != value.truncateToDouble();
  }
}
