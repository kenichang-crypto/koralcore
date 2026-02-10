import 'dart:typed_data';

import '../encoder/led/led_opcodes.dart';

const List<String> ledChannelOrder = <String>[
  'coldWhite',
  'royalBlue',
  'blue',
  'red',
  'green',
  'purple',
  'uv',
  'warmWhite',
  'moonLight',
];

class LedCommandBuilder {
  const LedCommandBuilder();

  Uint8List syncInformation() => _build(<int>[0x21, 0x00]);

  Uint8List preview({required bool start}) =>
      _build(<int>[0x2A, 0x01, start ? 0x01 : 0x00]);

  Uint8List deleteRecord({required int hour, required int minute}) =>
      _build(<int>[0x2F, 0x02, hour & 0xFF, minute & 0xFF]);

  Uint8List clearRecords() => _build(<int>[0x30, 0x00]);

  Uint8List usePresetScene(int sceneCode) =>
      _build(<int>[0x28, 0x01, sceneCode & 0xFF]);

  Uint8List useCustomScene(Map<String, int> channelLevels) {
    final List<int> ordered = <int>[
      for (final String key in ledChannelOrder)
        _channelValue(channelLevels, key),
    ];
    if (ordered.length != 9) {
      throw ArgumentError('Custom scene requires 9 channel values.');
    }
    return _build(<int>[0x29, 0x09, ...ordered]);
  }

  Uint8List startRecordPlayback() => _build(<int>[0x2B, 0x00]);

  Uint8List resetLed() => _build(<int>[0x2E, 0x00]);

  Uint8List setRecord({
    required int hour,
    required int minute,
    required List<int> channels,
  }) {
    assert(channels.length == 9, 'Expected 9 LED channel intensities.');
    return _build(<int>[
      0x27,
      0x0B,
      hour & 0xFF,
      minute & 0xFF,
      ...channels.take(9).map((value) => value & 0xFF),
    ]);
  }

  Uint8List applySchedule({
    required int scheduleCode,
    required bool enabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int recurrenceMask,
    required List<int> channels,
  }) {
    if (!LedOpcodes.enableNew5ChannelEncoders) {
      throw UnsupportedError(
        'New 5-channel LED schedule apply (0x82) is disabled for v1.0.',
      );
    }
    if (channels.length != 5) {
      throw ArgumentError('Schedule apply requires 5 channel values.');
    }
    return _build(<int>[
      LedOpcodes.customWindow, // 0x82
      0x00,
      0x01, // channel group (full spectrum)
      scheduleCode & 0xFF,
      enabled ? 0x01 : 0x00,
      startHour & 0xFF,
      startMinute & 0xFF,
      endHour & 0xFF,
      endMinute & 0xFF,
      ...channels.take(5).map((value) => value & 0xFF),
      recurrenceMask & 0xFF,
    ]);
  }

  Uint8List enterDimmingMode() => _build(<int>[0x32, 0x00]);

  Uint8List exitDimmingMode() => _build(<int>[0x34, 0x00]);

  Uint8List dimming(Map<String, int> channels) {
    final List<int> ordered = <int>[
      for (final String key in ledChannelOrder)
        (channels[key] ?? 0).clamp(0, 100),
    ];
    return _build(<int>[0x33, 0x09, ...ordered]);
  }

  Uint8List _build(List<int> payloadWithoutChecksum) {
    if (payloadWithoutChecksum.isEmpty) {
      throw ArgumentError('LED command payload cannot be empty.');
    }
    final List<int> buffer = List<int>.from(payloadWithoutChecksum);
    final int checksum = _checksum(buffer.sublist(2));
    buffer.add(checksum & 0xFF);
    return Uint8List.fromList(buffer);
  }

  int _checksum(List<int> data) {
    int sum = 0;
    for (final int value in data) {
      sum = (sum + (value & 0xFF)) & 0xFF;
    }
    return sum;
  }

  int _channelValue(Map<String, int> levels, String key) {
    int? value = levels[key];
    if (value == null && key == 'moonLight') {
      value = levels['moon'];
    }
    return (value ?? 0).clamp(0, 100);
  }
}
