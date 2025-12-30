import '../record/ble_record.dart';

/// Represents a single grouped BLE record ready for golden comparison.
class BleGoldenCaptureEntry {
  final int opcode;
  final List<String> payloadHex;
  final int payloadLength;

  const BleGoldenCaptureEntry({
    required this.opcode,
    required this.payloadHex,
    required this.payloadLength,
  });
}

/// Aggregates BLE records grouped by opcode for verification tooling.
class BleGoldenCapture {
  final Map<int, List<BleGoldenCaptureEntry>> groups;

  const BleGoldenCapture._(this.groups);

  factory BleGoldenCapture.fromRecords(List<BleRecord> records) {
    final Map<int, List<BleGoldenCaptureEntry>> grouped =
        <int, List<BleGoldenCaptureEntry>>{};

    for (final BleRecord record in records) {
      final BleGoldenCaptureEntry entry = BleGoldenCaptureEntry(
        opcode: record.opcode,
        payloadHex: record.payload.map(_toHex).toList(growable: false),
        payloadLength: record.payload.length,
      );
      grouped
          .putIfAbsent(record.opcode, () => <BleGoldenCaptureEntry>[])
          .add(entry);
    }

    final Map<int, List<BleGoldenCaptureEntry>> immutableGroups = grouped.map(
      (int key, List<BleGoldenCaptureEntry> value) =>
          MapEntry(key, List<BleGoldenCaptureEntry>.unmodifiable(value)),
    );

    return BleGoldenCapture._(
      Map<int, List<BleGoldenCaptureEntry>>.unmodifiable(immutableGroups),
    );
  }

  List<BleGoldenCaptureEntry> entriesForOpcode(int opcode) {
    return groups[opcode] ?? const <BleGoldenCaptureEntry>[];
  }

  static String _toHex(int byte) =>
      '0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}
