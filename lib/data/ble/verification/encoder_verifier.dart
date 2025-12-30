import 'golden_payloads.dart';

class EncoderVerificationResult {
  final String name;
  final bool isPass;
  final int? mismatchIndex;
  final int? expectedByte;
  final int? actualByte;

  const EncoderVerificationResult._({
    required this.name,
    required this.isPass,
    this.mismatchIndex,
    this.expectedByte,
    this.actualByte,
  });

  factory EncoderVerificationResult.pass(String name) {
    return EncoderVerificationResult._(name: name, isPass: true);
  }

  factory EncoderVerificationResult.fail({
    required String name,
    required int mismatchIndex,
    int? expectedByte,
    int? actualByte,
  }) {
    return EncoderVerificationResult._(
      name: name,
      isPass: false,
      mismatchIndex: mismatchIndex,
      expectedByte: expectedByte,
      actualByte: actualByte,
    );
  }
}

class EncoderVerifier {
  const EncoderVerifier();

  EncoderVerificationResult verify({
    required String name,
    required List<int> expectedPayload,
    required List<int> actualPayload,
  }) {
    final int minLength = expectedPayload.length < actualPayload.length
        ? expectedPayload.length
        : actualPayload.length;

    for (int i = 0; i < minLength; i++) {
      if (expectedPayload[i] != actualPayload[i]) {
        return EncoderVerificationResult.fail(
          name: name,
          mismatchIndex: i,
          expectedByte: expectedPayload[i],
          actualByte: actualPayload[i],
        );
      }
    }

    if (expectedPayload.length != actualPayload.length) {
      final int mismatchIndex = minLength;
      final int? expectedByte = expectedPayload.length > mismatchIndex
          ? expectedPayload[mismatchIndex]
          : null;
      final int? actualByte = actualPayload.length > mismatchIndex
          ? actualPayload[mismatchIndex]
          : null;
      return EncoderVerificationResult.fail(
        name: name,
        mismatchIndex: mismatchIndex,
        expectedByte: expectedByte,
        actualByte: actualByte,
      );
    }

    return EncoderVerificationResult.pass(name);
  }
}

class EncoderVerificationReport {
  final String name;
  final List<int> expectedOpcodes;
  final int actualOpcode;
  final bool opcodeMatches;
  final String fieldOrderDescription;
  final String endiannessDescription;
  final String scaleDescription;
  final EncoderVerificationResult payloadResult;

  const EncoderVerificationReport({
    required this.name,
    required this.expectedOpcodes,
    required this.actualOpcode,
    required this.opcodeMatches,
    required this.fieldOrderDescription,
    required this.endiannessDescription,
    required this.scaleDescription,
    required this.payloadResult,
  });

  bool get isPass => opcodeMatches && payloadResult.isPass;
}

const EncoderVerifier _verifier = EncoderVerifier();

// TODO(phase-2-4): Replace this placeholder with the exact payload captured
// from reef-b-app (Immediate Single Dose, opcode 0x6E) via BleRecorder.
const List<int> _immediateSingleDoseGoldenPayloadPlaceholder = <int>[];

const List<int> _dailyAverageScheduleGoldenPayload =
    kDailyAverageScheduleGoldenPayload;

const Map<int, List<int>> _customScheduleGoldenPayloads = <int, List<int>>{
  0x72: kCustomScheduleGoldenPayload0x72,
  0x73: kCustomScheduleGoldenPayload0x73,
  0x74: kCustomScheduleGoldenPayload0x74,
};

EncoderVerificationReport verifyImmediateSingleDose_0x6E({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : _immediateSingleDoseGoldenPayloadPlaceholder;

  return _buildReport(
    name: 'ImmediateSingleDose (0x6E)',
    expectedOpcodes: const <int>[0x6E],
    fieldOrderDescription:
        'opcode (0x6E) → pumpId → dose (little-endian, ml×10) → pumpSpeed → checksum/reserved byte',
    endiannessDescription:
        'Multi-byte dose fields use little-endian (LSB first); other fields are single-byte.',
    scaleDescription: 'Dose values are scaled by ×10 to represent 0.1 ml.',
    // TODO(phase-2-4): goldenPayload must come from reef-b-app BLE recording
    // of Immediate Single Dose before this verifier can pass.
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifyTimedSingleDose_0x6F({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  return _buildReport(
    name: 'TimedSingleDose (0x6F)',
    expectedOpcodes: const <int>[0x6F],
    fieldOrderDescription:
        'opcode (0x6F) → pumpId → executeAt (Unix time, little-endian 4 bytes) → dose (little-endian, ml×10) → pumpSpeed → checksum',
    endiannessDescription:
        'Timestamp and dose segments are little-endian; other control bytes follow capture order.',
    scaleDescription: 'Dose uses ml×10; timestamp uses seconds since epoch.',
    expectedPayload: expectedPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifySchedule24h_0x70({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : _dailyAverageScheduleGoldenPayload;

  return _buildReport(
    name: 'Schedule24h (0x70)',
    expectedOpcodes: const <int>[0x70],
    fieldOrderDescription:
        'opcode (0x70) → pumpId → repeatMask → slotCount → per-slot entries {hour, minute, dose little-endian} → pumpSpeed',
    endiannessDescription:
        'Dose bytes inside each slot are little-endian; temporal fields are single-byte HH/MM.',
    scaleDescription:
        'Dose per slot uses ml×10; repeat mask encoded as bitfield.',
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifyScheduleCustom_0x72_73_74({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : _customScheduleGoldenPayload(actualPayload);

  return _buildReport(
    name: 'ScheduleCustom (0x72/0x73/0x74)',
    expectedOpcodes: const <int>[0x72, 0x73, 0x74],
    fieldOrderDescription:
        'opcode (0x72-0x74) → pumpId → chunkIndex → windowStart (minute-of-day little-endian) → windowEnd → per-event dose little-endian → pumpSpeed',
    endiannessDescription:
        'All multi-byte ranges (minutes, doses) use little-endian; chunk metadata is single-byte.',
    scaleDescription:
        'Dose uses ml×10; minute-of-day uses absolute minutes to preserve ordering.',
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifyOneShotSchedule_32_33_34({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  return _buildReport(
    name: 'OneShotSchedule (0x32/0x33/0x34)',
    expectedOpcodes: const <int>[0x32, 0x33, 0x34],
    fieldOrderDescription:
        'opcode (0x32-0x34) → pumpId → stageId → scheduled date (YYYY/MM/DD) → time (HH/MM) → dose big-endian → pumpSpeed',
    endiannessDescription:
        'Protocol encodes date/time as single bytes while dose uses big-endian per PDF.',
    scaleDescription:
        'Dose uses ml×10; date/time fields are literal BCD bytes from reef-b-app.',
    expectedPayload: expectedPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifyLedDailySchedule({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : kLedDailyScheduleGoldenPayload;

  return _buildReport(
    name: 'LedDailySchedule (0x81)',
    expectedOpcodes: const <int>[0x81],
    fieldOrderDescription:
        'opcode (0x81) → channelGroup → repeatMask → pointCount → per-point {hour, minute, channel intensities} → checksum',
    endiannessDescription:
        'Time bytes are single-byte HH/MM; intensity values follow capture order (one byte per channel).',
    scaleDescription:
        'Channel intensities remain raw 0-255; repeat mask is a 7-bit weekday field.',
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport verifyLedCustomSchedule({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : kLedCustomScheduleGoldenPayload;

  return _buildReport(
    name: 'LedCustomSchedule (0x82)',
    expectedOpcodes: const <int>[0x82],
    fieldOrderDescription:
        'opcode (0x82) → channelGroup → startTime {hour, minute} → endTime {hour, minute} → channel intensities → repeatMask → checksum',
    endiannessDescription:
        'Start/end minutes are single-byte; remainder follows capture order.',
    scaleDescription:
        'Intensities 0-255; time stored as literal HH/MM bytes; checksum is sum(body) mod 256.',
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

List<int> _customScheduleGoldenPayload(List<int> actualPayload) {
  if (actualPayload.isEmpty) {
    return const <int>[];
  }
  final int opcode = actualPayload.first;
  return _customScheduleGoldenPayloads[opcode] ?? const <int>[];
}

EncoderVerificationReport verifyLedSceneSchedule({
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> goldenPayload = expectedPayload.isNotEmpty
      ? expectedPayload
      : kLedSceneScheduleGoldenPayload;

  return _buildReport(
    name: 'LedSceneSchedule (0x83)',
    expectedOpcodes: const <int>[0x83],
    fieldOrderDescription:
        'opcode (0x83) → sceneId → startTime {hour, minute} → endTime {hour, minute} → repeatMask → scene preset payload → checksum',
    endiannessDescription:
        'Times are HH/MM single-byte; scene payload preserves reef-b-app ordering.',
    scaleDescription:
        'Scene intensities are direct 0-255 bytes; repeat mask matches daily/custom commands.',
    expectedPayload: goldenPayload,
    actualPayload: actualPayload,
  );
}

EncoderVerificationReport _buildReport({
  required String name,
  required List<int> expectedOpcodes,
  required String fieldOrderDescription,
  required String endiannessDescription,
  required String scaleDescription,
  required List<int> expectedPayload,
  required List<int> actualPayload,
}) {
  final List<int> opcodeSet = expectedOpcodes.isEmpty
      ? _opcodeSetFrom(expectedPayload)
      : List<int>.unmodifiable(expectedOpcodes);
  final int actualOpcode = actualPayload.isNotEmpty ? actualPayload.first : -1;
  final bool opcodeMatches = opcodeSet.contains(actualOpcode);

  final EncoderVerificationResult payloadResult = _verifier.verify(
    name: name,
    expectedPayload: expectedPayload,
    actualPayload: actualPayload,
  );

  return EncoderVerificationReport(
    name: name,
    expectedOpcodes: opcodeSet,
    actualOpcode: actualOpcode,
    opcodeMatches: opcodeMatches,
    fieldOrderDescription: fieldOrderDescription,
    endiannessDescription: endiannessDescription,
    scaleDescription: scaleDescription,
    payloadResult: payloadResult,
  );
}

List<int> _opcodeSetFrom(List<int> payload) {
  if (payload.isEmpty) {
    return const <int>[];
  }
  return List<int>.unmodifiable(<int>[payload.first]);
}
