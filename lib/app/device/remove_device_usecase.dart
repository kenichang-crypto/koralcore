/// RemoveDeviceUseCase
///
/// Removes a device from local listing and ensures BLE connection closed.
///
/// Execution order:
/// 1. Ensure device disconnected (call DisconnectDeviceUseCase)
/// 2. Remove device from local repository
/// 3. Update state / notify UI
///
/// PARITY: Matches reef-b-app's DeviceViewModel.deleteDevice() behavior:
/// - Checks if device is connected (it.macAddress == bleManager.getConnectDeviceMacAddress())
/// - If connected, calls bleManager.disConnect() before deleting
///
library;

import 'package:flutter/foundation.dart';

import '../../platform/contracts/device_repository.dart';
import '../session/current_device_session.dart';
import 'disconnect_device_usecase.dart';

class RemoveDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;

  RemoveDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.disconnectDeviceUseCase,
  });

  Future<void> execute({required String deviceId}) async {
    // PARITY: reef-b-app checks if device is connected before deleting
    // reef-b-app: if (it.macAddress == bleManager.getConnectDeviceMacAddress()) { bleManager.disConnect() }
    final String? deviceState = await deviceRepository.getDeviceState(deviceId);
    if (deviceState == 'connected') {
      // Device is connected, disconnect first
      try {
        await disconnectDeviceUseCase.execute(deviceId: deviceId);
      } catch (e) {
        // Log error but continue with deletion
        // PARITY: reef-b-app BLEManager.onConnectionStateChange() -> Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 斷線")
        debugPrint('RemoveDeviceUseCase - 藍芽連線: 斷開設備 $deviceId 失敗: $e');
      }
    }

    final String? currentDeviceId = await deviceRepository.getCurrentDevice();
    if (currentDeviceId == deviceId ||
        currentDeviceSession.context?.deviceId == deviceId) {
      currentDeviceSession.clear();
    }
    await deviceRepository.removeDevice(deviceId);

    // Device list will auto-refresh via observeSavedDevices() stream
  }
}
