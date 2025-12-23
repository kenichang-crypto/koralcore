import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/application/led/led_record_store.dart';
import 'package:koralcore/domain/led_lighting/led_record.dart';
import 'package:koralcore/domain/led_lighting/led_record_state.dart';
import 'package:koralcore/infrastructure/repositories/led_record_repository_impl.dart';
import 'package:koralcore/platform/contracts/led_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String deviceId = 'test-device';
  late LedRecordRepository repository;

  LedRecord record(String id, int hour, int minute, Map<String, int> channels) {
    return LedRecord(
      id: id,
      minutesFromMidnight: hour * 60 + minute,
      channelLevels: channels,
    );
  }

  setUp(() {
    repository = LedRecordRepositoryImpl(
      store: LedRecordMemoryStore(
        seedRecordsOverride: <String, List<LedRecord>>{
          deviceId: <LedRecord>[
            record('dawn', 6, 0, <String, int>{'coldWhite': 20, 'blue': 15}),
            record('noon', 12, 0, <String, int>{'coldWhite': 75, 'blue': 80}),
            record('dusk', 18, 30, <String, int>{'coldWhite': 35, 'blue': 40}),
          ],
        },
      ),
    );
  });

  test('getState returns seeded records', () async {
    final LedRecordState state = await repository.getState(deviceId);
    expect(state.records.length, 3);
    expect(state.records.first.id, 'dawn');
    expect(state.status, LedRecordStatus.idle);
  });

  test('refresh resets records to the seed set', () async {
    await repository.deleteRecord(deviceId: deviceId, recordId: 'dawn');
    final LedRecordState refreshed = await repository.refresh(deviceId);
    expect(refreshed.records.length, 3);
    expect(refreshed.status, LedRecordStatus.idle);
  });

  test('deleteRecord removes matching record and notifies observers', () async {
    final List<LedRecordState> emissions = <LedRecordState>[];
    final StreamSubscription<LedRecordState> sub = repository
        .observeState(deviceId)
        .listen(emissions.add);
    await Future<void>.delayed(Duration.zero);

    final LedRecordState deleted = await repository.deleteRecord(
      deviceId: deviceId,
      recordId: 'noon',
    );
    expect(deleted.records.length, 2);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(emissions.last.records.length, 2);
    await sub.cancel();
  });

  test('clearRecords empties the schedule', () async {
    final LedRecordState cleared = await repository.clearRecords(deviceId);
    expect(cleared.records, isEmpty);
    expect(cleared.status, LedRecordStatus.idle);
  });

  test('start and stop preview update state status', () async {
    final LedRecordState preview = await repository.startPreview(
      deviceId: deviceId,
    );
    expect(preview.status, LedRecordStatus.previewing);
    expect(preview.previewingRecordId, isNotNull);

    final LedRecordState stopped = await repository.stopPreview(deviceId);
    expect(stopped.status, LedRecordStatus.idle);
    expect(stopped.previewingRecordId, isNull);
  });
}
