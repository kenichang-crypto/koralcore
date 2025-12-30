library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// ReadLedRecordStateUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record state reading:
/// - LedRecordActivity: displays record state from LedInformation
/// - LedInformation.getRecords() returns list of LedRecord entries
/// - Records are populated via BLE sync: ledSyncInformation callback
/// - Record state includes time points and channel levels
class ReadLedRecordStateUseCase {
  const ReadLedRecordStateUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.getState(deviceId);
  }
}
