/// DisconnectDeviceUseCase
///
/// Gracefully closes BLE connection and updates state.
///
/// Execution order:
/// 1. Request BLE adapter to disconnect
/// 2. Update local state -> disconnected
/// 3. Optionally attempt reconnection (outside scope)
///
import '../../platform/contracts/device_repository.dart';

class DisconnectDeviceUseCase {
  final DeviceRepository deviceRepository;

  DisconnectDeviceUseCase({required this.deviceRepository});

  Future<void> execute({required String deviceId}) async {
    // 1) Call BLE adapter to disconnect
    // TODO: await bleAdapter.disconnect(deviceId)

    // 2) Update device state in repository
    // TODO: deviceRepository.updateState(deviceId, DeviceState.disconnected)
    await deviceRepository.updateDeviceState(deviceId, 'disconnected');

    // 3) Notify presentation
    // TODO: notify UI that device is disconnected
  }
}
