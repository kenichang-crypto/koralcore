import '../../platform/contracts/device_repository.dart';
import '../../domain/doser_dosing/single_dose_timed.dart';

/// SingleDoseTimedUseCase
///
/// Application-level orchestration for scheduling a single timed dose (BLE cmd 16).
/// Responsibilities:
/// - Flow control only
/// - Map domain model to adapter call (TODO)
/// - Call adapter/repository as TODO (no BLE implementation here)
class SingleDoseTimedUseCase {
  final DeviceRepository deviceRepository;

  /// Adapter responsible for sending dosing schedule commands to device.
  /// TODO: Replace `dynamic` with a concrete dosing adapter interface.
  final dynamic dosingAdapter;

  SingleDoseTimedUseCase({
    required this.deviceRepository,
    required this.dosingAdapter,
  });

  /// Steps (execute):
  /// 1. Ensure the target device is the current device or specified by caller
  /// 2. Map `SingleDoseTimed` domain model into BLE payload (bytes)
  /// 3. Invoke adapter to schedule single timed dose on device
  ///    (e.g. dosingAdapter.scheduleSingleDose(deviceId, payload))
  /// 4. Optionally persist scheduled event in repository (TODO)
  /// 5. Return control to caller
  Future<void> execute({
    required String deviceId,
    required SingleDoseTimed dose,
  }) async {
    // 1) Ensure device context
    // TODO: final current = await deviceRepository.getCurrentDevice();

    // 2) Map domain model -> BLE payload
    // TODO: final payload = mapSingleDoseTimedToPayload(dose);

    // 3) Send BLE schedule command via adapter
    // TODO: await dosingAdapter.scheduleSingleDose(deviceId, payload);

    // 4) Persist or log the scheduled dosing action
    // TODO: await deviceRepository.saveScheduledDosing(deviceId, ...)

    // 5) Return (no further action)
  }
}
