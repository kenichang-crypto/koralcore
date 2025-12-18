/// DisconnectDeviceUseCase
///
/// Gracefully closes BLE connection and updates state.
///
/// Execution order:
/// 1. Request BLE adapter to disconnect
/// 2. Update local state -> disconnected
/// 3. Optionally attempt reconnection (outside scope)
///
library;

import '../../platform/contracts/device_repository.dart';
import '../session/current_device_session.dart';

class DisconnectDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  DisconnectDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Call BLE adapter to disconnect
    // TODO: await bleAdapter.disconnect(deviceId)

    // 2) Update device state in repository
    // TODO: deviceRepository.updateState(deviceId, DeviceState.disconnected)
    await deviceRepository.updateDeviceState(deviceId, 'disconnected');

    // Ensure downstream use cases can't act on a disconnected device.
    currentDeviceSession.clear();

    // 3) Notify presentation
    // TODO: notify UI that device is disconnected
  }
}
