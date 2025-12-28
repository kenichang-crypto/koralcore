import 'dart:typed_data';

import '../../../domain/doser_dosing/custom_window_schedule_definition.dart';
import '../encoder/schedule/custom_schedule_encoder_0x74.dart';
import '../verification/encoder_verifier.dart';
import '../verification/golden_payloads.dart';
import 'custom_schedule_debug_samples.dart';

EncoderVerificationReport runCustomScheduleEncoder0x74SelfTest({
  bool compareAgainstGolden = false,
}) {
  final CustomWindowScheduleDefinition schedule =
      buildSampleCustomWindowSchedule();
  final CustomScheduleEncoder0x74 encoder = CustomScheduleEncoder0x74();
  final Uint8List payload = encoder.encode(schedule);

  final List<int> expectedPayload = compareAgainstGolden
      ? _requireGoldenPayload()
      : payload;

  return verifyScheduleCustom_0x72_73_74(
    expectedPayload: expectedPayload,
    actualPayload: payload,
  );
}

List<int> _requireGoldenPayload() {
  if (kCustomScheduleGoldenPayload0x74.isEmpty) {
    throw StateError(
      'kCustomScheduleGoldenPayload0x74 is empty. Capture reef-b-app bytes '
      'before running compareAgainstGolden=true.',
    );
  }
  return kCustomScheduleGoldenPayload0x74;
}
