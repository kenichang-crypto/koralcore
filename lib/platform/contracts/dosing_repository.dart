library;

import '../../domain/doser_dosing/dosing_state.dart';

/// Repository interface for Dosing state management.
///
/// PARITY: Mirrors LedRepository interface pattern.
abstract class DosingRepository {
  const DosingRepository();

  /// Observes Dosing state changes for a device.
  Stream<DosingState> observeDosingState(String deviceId);

  /// Gets the current Dosing state for a device.
  Future<DosingState?> getDosingState(String deviceId);

  /// Reset device to default settings.
  Future<DosingState> resetToDefault(String deviceId);

  /// Clear a single pump head's schedule (BLE 0x79).
  /// headNo: 1-based pump index (A=1, B=2, C=3, D=4).
  Future<void> clearRecord(String deviceId, int headNo);
}

