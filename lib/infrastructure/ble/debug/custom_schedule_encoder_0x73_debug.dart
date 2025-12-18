import 'dart:typed_data';

import '../../../domain/doser_schedule/custom_window_schedule_definition.dart';
import '../encoder/schedule/custom_schedule_encoder_0x73.dart';
import '../verification/encoder_verifier.dart';
import '../verification/golden_payloads.dart';
import 'custom_schedule_debug_samples.dart';

EncoderVerificationReport runCustomScheduleEncoder0x73SelfTest({
  bool compareAgainstGolden = false,
}) {
  final CustomWindowScheduleDefinition schedule =
      buildSampleCustomWindowSchedule();
  final CustomScheduleEncoder0x73 encoder = CustomScheduleEncoder0x73();
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
  if (kCustomScheduleGoldenPayload0x73.isEmpty) {
    throw StateError(
      'kCustomScheduleGoldenPayload0x73 is empty. Capture reef-b-app bytes '
      'before running compareAgainstGolden=true.',
    );
  }
  return kCustomScheduleGoldenPayload0x73;
}
