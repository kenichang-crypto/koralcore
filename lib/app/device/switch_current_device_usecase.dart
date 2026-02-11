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
    // 1) Validate device exists in the repository.
    // If not, this will throw, which is the desired behavior.
    await deviceRepository.getDevice(deviceId);

    // 2) KC-A-FINAL: Set application current device to a "selected-not-ready" state.
    // This clears any prior "ready" state and establishes a partial context
    // containing only the device ID. It prevents downstream use cases from
    // accessing a full (but stale) context before initialization completes.
    currentDeviceSession.switchTo(deviceId);

    // 3) Persist the new current device ID.
    await deviceRepository.setCurrentDevice(deviceId);

    // Downstream steps (like loading cached state or light sync) are intentionally
    // omitted. The lifecycle contract dictates that a full 'InitializeDeviceUseCase'
    // MUST run after a switch to bring the device to a "ready" state.
  }
}
