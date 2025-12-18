import 'dart:typed_data';

import '../../../domain/doser_dosing/pump_speed.dart';
import '../../../domain/doser_schedule/daily_average_schedule_definition.dart';
import '../../../domain/doser_schedule/schedule_weekday.dart';
import '../verification/encoder_verifier.dart';
import '../verification/golden_payloads.dart';
import '../encoder/schedule/daily_average_schedule_encoder.dart';

/// Runs opcode 0x70 encoder/verifier.
///
/// Set [compareAgainstGolden] to true to validate against the reef-b-app
/// capture stored in `kDailyAverageScheduleGoldenPayload`.
EncoderVerificationReport runDailyAverageScheduleEncoderSelfTest({
  bool compareAgainstGolden = false,
}) {
  final DailyAverageScheduleDefinition schedule =
      DailyAverageScheduleDefinition(
        scheduleId: 'sample-24h',
        pumpId: 0x01,
        repeatDays: ScheduleWeekday.values.toSet(),
        slots: const <DailyDoseSlot>[
          DailyDoseSlot(hour: 8, minute: 0, doseMl: 12.0, speed: PumpSpeed.low),
          DailyDoseSlot(
            hour: 20,
            minute: 30,
            doseMl: 8.0,
            speed: PumpSpeed.medium,
          ),
        ],
      );

  final DailyAverageScheduleEncoder encoder = DailyAverageScheduleEncoder();
  final Uint8List payload = encoder.encode(schedule);
  final List<int> expectedPayload = compareAgainstGolden
      ? _requireDailyAverageGoldenPayload()
      : payload;

  return verifySchedule24h_0x70(
    expectedPayload: expectedPayload,
    actualPayload: payload,
  );
}

List<int> _requireDailyAverageGoldenPayload() {
  if (kDailyAverageScheduleGoldenPayload.isEmpty) {
    throw StateError(
      'kDailyAverageScheduleGoldenPayload is empty; record a reef-b-app '
      'capture before running compareAgainstGolden=true.',
    );
  }
  return kDailyAverageScheduleGoldenPayload;
}
