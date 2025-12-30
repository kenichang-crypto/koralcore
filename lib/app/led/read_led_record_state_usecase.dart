library;

import '../../domain/led_lighting/led_record_state.dart';
import '../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

class ReadLedRecordStateUseCase {
  const ReadLedRecordStateUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.getState(deviceId);
  }
}
