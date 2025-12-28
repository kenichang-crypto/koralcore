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
}

