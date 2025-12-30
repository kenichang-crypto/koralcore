library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// RefreshLedRecordStateUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record state refresh:
/// - LedRecordActivity: refreshes record list after sync
/// - LedMainViewModel.getAllLedInfo() -> bleSyncInformation() -> updates records
/// - Refreshes after record operations (add, update, delete)
/// - Updates chart and record list display
class RefreshLedRecordStateUseCase {
  const RefreshLedRecordStateUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.refresh(deviceId);
  }
}
