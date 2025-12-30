library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// ObserveLedRecordStateUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record state observation:
/// - LedRecordActivity: observes record changes and updates chart
/// - LedInformation records are updated via BLE callbacks
/// - LiveData pattern in Android replaced by Stream in Flutter
/// - UI reacts to record changes (add, update, delete operations)
class ObserveLedRecordStateUseCase {
  const ObserveLedRecordStateUseCase({required this.repository});

  final LedRecordRepository repository;

  Stream<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.observeState(deviceId);
  }
}
