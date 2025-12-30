library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// StopLedPreviewUseCase
///
/// PARITY: Corresponds to reef-b-app's LED preview stop:
/// - LedMainViewModel.clickBtnPreview() -> bleStopPreview() (when preview active)
/// - LedRecordViewModel.clickBtnPreview() -> bleStopPreview() (when preview active)
/// - CommandManager.getLedStopPreviewCommand() -> BLE opcode (stops preview)
/// - On success: previewStateLiveData.postValue(false), stops timer, clears screen on flag
/// - Resets chart to current time position
class StopLedPreviewUseCase {
  const StopLedPreviewUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.stopPreview(deviceId);
  }
}
