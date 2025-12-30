library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// StartLedPreviewUseCase
///
/// PARITY: Corresponds to reef-b-app's LED preview start:
/// - LedMainViewModel.clickBtnPreview() -> bleStartPreview()
/// - LedRecordViewModel.clickBtnPreview() -> bleStartPreview()
/// - CommandManager.getLedPreviewCommand() -> BLE opcode 0x2A
/// - On success: previewStateLiveData.postValue(true), starts timer, keeps screen on
/// - Preview shows schedule progression in real-time on chart
class StartLedPreviewUseCase {
  const StartLedPreviewUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId, String? recordId}) {
    ensureDeviceId(deviceId);
    if (recordId != null) {
      ensureRecordId(recordId);
    }
    return repository.startPreview(deviceId: deviceId, recordId: recordId);
  }
}
