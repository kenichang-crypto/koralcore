import 'dart:typed_data';

import '../../../domain/doser_dosing/encoder/timed_single_dose_encoder.dart';
import '../../../domain/doser_dosing/pump_speed.dart';
import '../../../domain/doser_dosing/single_dose_timed.dart';
import '../verification/encoder_verifier.dart';

/// Simple dev hook that exercises the TimedSingleDose encoder and verifier.
EncoderVerificationReport runTimedSingleDoseEncoderSelfTest() {
  final TimedSingleDoseEncoder encoder = TimedSingleDoseEncoder();
  final SingleDoseTimed sample = SingleDoseTimed(
    pumpId: 0x02,
    doseMl: 120.0,
    speed: PumpSpeed.medium,
    executeAt: DateTime(2025, 1, 2, 3, 4),
  );

  final Uint8List payload = encoder.encode(sample);

  return verifyTimedSingleDose_0x6F(
    expectedPayload: payload,
    actualPayload: payload,
  );
}
