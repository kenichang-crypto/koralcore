library;

import '../../domain/led_lighting/led_record_state.dart';
import '../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

class ObserveLedRecordStateUseCase {
  const ObserveLedRecordStateUseCase({required this.repository});

  final LedRecordRepository repository;

  Stream<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.observeState(deviceId);
  }
}
