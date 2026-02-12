library;

import 'dart:typed_data';

/// BLE command builder for Dosing operations.
///
/// PARITY: Mirrors reef-b-app Android's CommandManager Dosing command methods.
/// All commands use dataSum() checksum algorithm (simple sum from index 2).
class DosingCommandBuilder {
  const DosingCommandBuilder();

  /// Time correction command (0x60).
  /// Format: [0x60, 0x07, year, month, day, hour, minute, second, weekday, checksum]
  Uint8List timeCorrection({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int second,
    required int weekday,
  }) {
    return _build(<int>[
      0x60,
      0x07,
      year & 0xFF,
      month & 0xFF,
      day & 0xFF,
      hour & 0xFF,
      minute & 0xFF,
      second & 0xFF,
      weekday & 0xFF,
    ]);
  }

  /// Sync information command (0x65).
  /// Format: [0x65, 0x00, checksum]
  Uint8List syncInformation() => _build(<int>[0x65, 0x00]);

  /// Set delay time command (0x61).
  /// Format: [0x61, 0x02, highBit, lowBit, checksum]
  Uint8List setDelayTime(int seconds) {
    final int highBit = (seconds >> 8) & 0xFF;
    final int lowBit = seconds & 0xFF;
    return _build(<int>[0x61, 0x02, highBit, lowBit]);
  }

  /// Set rotating speed command (0x62).
  /// Format: [0x62, 0x02, headNo, speed, checksum]
  Uint8List setRotatingSpeed({required int headNo, required int speed}) {
    return _build(<int>[
      0x62,
      0x02,
      headNo & 0xFF,
      speed & 0xFF,
    ]);
  }

  /// Manual drop start command (0x63).
  /// Format: [0x63, 0x01, headNo, checksum]
  Uint8List manualDropStart(int headNo) {
    return _build(<int>[0x63, 0x01, headNo & 0xFF]);
  }

  /// Manual drop end command (0x64).
  /// Format: [0x64, 0x01, headNo, checksum]
  Uint8List manualDropEnd(int headNo) {
    return _build(<int>[0x64, 0x01, headNo & 0xFF]);
  }

  /// Single drop immediately command (0x6E).
  /// Format: [0x6E, 0x04, headNo, volume_H, volume_L, speed, checksum]
  Uint8List singleDropImmediately({
    required int headNo,
    required int volume, // Pre-scaled (ml × 10)
    required int speed,
  }) {
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x6E,
      0x04,
      headNo & 0xFF,
      volumeHigh,
      volumeLow,
      speed & 0xFF,
    ]);
  }

  /// Single drop timely command (0x6F).
  /// Format: [0x6F, 0x09, headNo, year-2000, month, day, hour, minute, volume_H, volume_L, speed, checksum]
  Uint8List singleDropTimely({
    required int headNo,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int volume, // Pre-scaled (ml × 10)
    required int speed,
  }) {
    final int yearOffset = (year - 2000) & 0xFF;
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x6F,
      0x09,
      headNo & 0xFF,
      yearOffset,
      month & 0xFF,
      day & 0xFF,
      hour & 0xFF,
      minute & 0xFF,
      volumeHigh,
      volumeLow,
      speed & 0xFF,
    ]);
  }

  /// 24h drop weekly command (0x70).
  /// Format: [0x70, 0x0B, headNo, monday, tuesday, wednesday, thursday, friday, saturday, sunday, volume_H, volume_L, speed, checksum]
  Uint8List h24DropWeekly({
    required int headNo,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
    required int volume, // Pre-scaled (ml × 10)
    required int speed,
  }) {
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x70,
      0x0B,
      headNo & 0xFF,
      monday ? 1 : 0,
      tuesday ? 1 : 0,
      wednesday ? 1 : 0,
      thursday ? 1 : 0,
      friday ? 1 : 0,
      saturday ? 1 : 0,
      sunday ? 1 : 0,
      volumeHigh,
      volumeLow,
      speed & 0xFF,
    ]);
  }

  /// 24h drop range command (0x71).
  /// Format: [0x71, 0x0A, headNo, startYear-2000, startMonth, startDay, endYear-2000, endMonth, endDay, volume_H, volume_L, speed, checksum]
  /// PARITY: reef-b-app CommandManager.kt:101-105, getDrop24RangeCommand
  Uint8List h24DropRange({
    required int headNo,
    required int startYear,
    required int startMonth,
    required int startDay,
    required int endYear,
    required int endMonth,
    required int endDay,
    required int volume, // Pre-scaled (ml × 10)
    required int speed,
  }) {
    final int startYearByte = (startYear - 2000) & 0xFF;
    final int endYearByte = (endYear - 2000) & 0xFF;
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x71,
      0x0A,
      headNo & 0xFF,
      startYearByte,
      startMonth & 0xFF,
      startDay & 0xFF,
      endYearByte,
      endMonth & 0xFF,
      endDay & 0xFF,
      volumeHigh,
      volumeLow,
      speed & 0xFF,
    ]);
  }

  /// Custom drop weekly command (0x72).
  /// Format: [0x72, 0x09, headNo, monday, tuesday, wednesday, thursday, friday, saturday, sunday, count, checksum]
  Uint8List customDropWeekly({
    required int headNo,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
    required int count,
  }) {
    return _build(<int>[
      0x72,
      0x09,
      headNo & 0xFF,
      monday ? 1 : 0,
      tuesday ? 1 : 0,
      wednesday ? 1 : 0,
      thursday ? 1 : 0,
      friday ? 1 : 0,
      saturday ? 1 : 0,
      sunday ? 1 : 0,
      count & 0xFF,
    ]);
  }

  /// Custom drop range command (0x73).
  /// Format: [0x73, 0x08, headNo, startYear-2000, startMonth, startDay, endYear-2000, endMonth, endDay, count, checksum]
  /// PARITY: reef-b-app CommandManager.kt:112-116, getDropCustomRangeCommand
  Uint8List customDropRange({
    required int headNo,
    required int startYear,
    required int startMonth,
    required int startDay,
    required int endYear,
    required int endMonth,
    required int endDay,
    required int count,
  }) {
    final int startYearByte = (startYear - 2000) & 0xFF;
    final int endYearByte = (endYear - 2000) & 0xFF;
    return _build(<int>[
      0x73,
      0x08,
      headNo & 0xFF,
      startYearByte,
      startMonth & 0xFF,
      startDay & 0xFF,
      endYearByte,
      endMonth & 0xFF,
      endDay & 0xFF,
      count & 0xFF,
    ]);
  }

  /// Custom drop detail command (0x74).
  /// Format: [0x74, 0x09, headNo, startHour, startMinute, endHour, endMinute, times, volume_H, volume_L, speed, checksum]
  Uint8List customDropDetail({
    required int headNo,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int times,
    required int volume, // Pre-scaled (ml × 10)
    required int speed,
  }) {
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x74,
      0x09,
      headNo & 0xFF,
      startHour & 0xFF,
      startMinute & 0xFF,
      endHour & 0xFF,
      endMinute & 0xFF,
      times & 0xFF,
      volumeHigh,
      volumeLow,
      speed & 0xFF,
    ]);
  }

  /// Start adjust command (0x75).
  /// Format: [0x75, 0x02, headNo, speed, checksum]
  Uint8List startAdjust({required int headNo, required int speed}) {
    return _build(<int>[
      0x75,
      0x02,
      headNo & 0xFF,
      speed & 0xFF,
    ]);
  }

  /// Adjust result command (0x76).
  /// Format: [0x76, 0x04, headNo, speed, volume_H, volume_L, checksum]
  Uint8List adjustResult({
    required int headNo,
    required int speed,
    required int volume, // Pre-scaled (ml × 10)
  }) {
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    return _build(<int>[
      0x76,
      0x04,
      headNo & 0xFF,
      speed & 0xFF,
      volumeHigh,
      volumeLow,
    ]);
  }

  /// Get adjust history command (0x77).
  /// Format: [0x77, 0x01, headNo, checksum]
  Uint8List getAdjustHistory(int headNo) {
    return _build(<int>[0x77, 0x01, headNo & 0xFF]);
  }

  /// Clear record command (0x79).
  /// Format: [0x79, 0x01, headNo, checksum]
  Uint8List clearRecord(int headNo) {
    return _build(<int>[0x79, 0x01, headNo & 0xFF]);
  }

  /// Get today total volume command (0x7A).
  /// Format: [0x7A, 0x01, headNo, checksum]
  Uint8List getTodayTotalVolume(int headNo) {
    return _build(<int>[0x7A, 0x01, headNo & 0xFF]);
  }

  /// Get today total volume decimal command (0x7E).
  /// Format: [0x7E, 0x01, headNo, checksum]
  Uint8List getTodayTotalVolumeDecimal(int headNo) {
    return _build(<int>[0x7E, 0x01, headNo & 0xFF]);
  }

  /// Reset command (0x7D).
  /// Format: [0x7D, 0x00, checksum]
  Uint8List reset() => _build(<int>[0x7D, 0x00]);

  /// Builds a command with checksum.
  ///
  /// PARITY: Uses dataSum() algorithm (simple sum from index 2 to end).
  /// reef-b-app's dataSum() calculates: sum of bytes from index 2 to array.size
  Uint8List _build(List<int> payloadWithoutChecksum) {
    if (payloadWithoutChecksum.isEmpty) {
      throw ArgumentError('Dosing command payload cannot be empty.');
    }
    final List<int> buffer = List<int>.from(payloadWithoutChecksum);
    // PARITY: dataSum() calculates sum from index 2 to end (excluding checksum)
    // Since checksum position is 0 initially, we calculate sum of bytes from index 2
    final int checksum = _dataSum(buffer.sublist(2));
    buffer.add(checksum & 0xFF);
    return Uint8List.fromList(buffer);
  }

  /// Calculates dataSum checksum (simple sum).
  ///
  /// PARITY: Mirrors reef-b-app's dataSum() function:
  /// ```kotlin
  /// fun dataSum(array: ByteArray): Byte {
  ///     val data = array.copyOfRange(2, array.size)
  ///     return data.sum().toByte()
  /// }
  /// ```
  int _dataSum(List<int> data) {
    int sum = 0;
    for (final int value in data) {
      sum = (sum + (value & 0xFF)) & 0xFF;
    }
    return sum;
  }
}

