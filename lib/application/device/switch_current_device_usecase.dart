/// SwitchCurrentDeviceUseCase
///
/// Orchestrates switching the current active device.
///
/// Execution order:
/// 1. Validate requested device exists in local repository
/// 2. Update application context currentDevice
/// 3. If necessary, load device state (cached) and notify presentation
/// 4. Optionally trigger quick sync (not full initialize)
///
library;

import '../../platform/contracts/device_repository.dart';
import '../session/current_device_session.dart';

class SwitchCurrentDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  SwitchCurrentDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Validate device exists
    // TODO: if not exists -> return error
    final existing = await deviceRepository.getDevice(deviceId);

    // 2) Set application currentDevice (context)
    // TODO: appContext.setCurrentDevice(deviceId)
    // Clearing prevents downstream use cases from reading stale context while
    // the new device awaits initialization.
    currentDeviceSession.clear();
    await deviceRepository.setCurrentDevice(deviceId);

    // 3) Load cached device state and notify presentation
    // TODO: final state = await deviceRepository.getState(deviceId)
    final state = await deviceRepository.getDeviceState(deviceId);
    // TODO: notify UI to load state

    // 4) Optionally: trigger a light sync
    // TODO: consider ReadDeviceInfoUseCase or ReadCapabilityUseCase
  }
}
