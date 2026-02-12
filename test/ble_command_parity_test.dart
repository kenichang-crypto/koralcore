import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/data/ble/dosing/dosing_command_builder.dart';
import 'package:koralcore/data/ble/led/led_command_builder.dart';

/// BLE command parity tests. Expected bytes match reef-b-app format.
void main() {
  late DosingCommandBuilder dosingBuilder;
  late LedCommandBuilder ledBuilder;

  setUp(() {
    dosingBuilder = const DosingCommandBuilder();
    ledBuilder = const LedCommandBuilder();
  });

  group('0x71 Drop 24h Range', () {
    test('matches reef byte format', () {
      final Uint8List actual = dosingBuilder.h24DropRange(
        headNo: 0,
        startYear: 2026,
        startMonth: 1,
        startDay: 15,
        endYear: 2026,
        endMonth: 12,
        endDay: 31,
        volume: 1000,
        speed: 1,
      );
      // reef: [0x71, 0x0A, headNo, startYear-2000, startMonth, startDay, endYear-2000, endMonth, endDay, volume_H, volume_L, speed, checksum]
      const List<int> expected = <int>[
        0x71,
        0x0A,
        0,
        26, // 2026 - 2000
        1,
        15,
        26, // 2026 - 2000
        12,
        31,
        0x03,
        0xE8, // 1000
        1,
        0x65, // checksum
      ];
      expect(actual.length, equals(expected.length));
      expect(actual, equals(Uint8List.fromList(expected)));
    });
  });

  group('0x73 Drop Custom Range', () {
    test('matches reef byte format', () {
      final Uint8List actual = dosingBuilder.customDropRange(
        headNo: 0,
        startYear: 2026,
        startMonth: 1,
        startDay: 1,
        endYear: 2026,
        endMonth: 12,
        endDay: 31,
        count: 3,
      );
      // reef: [0x73, 0x08, headNo, startYear-2000, startMonth, startDay, endYear-2000, endMonth, endDay, count, checksum]
      const List<int> expected = <int>[
        0x73,
        0x08,
        0,
        26, // 2026 - 2000
        1,
        1,
        26, // 2026 - 2000
        12,
        31,
        3,
        0x6C, // checksum
      ];
      expect(actual.length, equals(expected.length));
      expect(actual, equals(Uint8List.fromList(expected)));
    });
  });

  group('0x20 LED Time Correction', () {
    test('matches reef byte format', () {
      final DateTime now = DateTime(2026, 2, 11, 14, 30, 45);
      final Uint8List actual = ledBuilder.timeCorrection(now);
      // reef: [0x20, 0x06, year-2000, month, day, hour, minute, second, checksum]
      const List<int> expected = <int>[
        0x20,
        0x06,
        26, // 2026 - 2000
        2,
        11,
        14,
        30,
        45,
        0x86, // checksum
      ];
      expect(actual.length, equals(expected.length));
      expect(actual, equals(Uint8List.fromList(expected)));
    });
  });
}
