import 'dart:typed_data';

import '../../doser_dosing/single_dose_timed.dart';
import 'single_dose_encoding_utils.dart';

/// Encoder for BLE opcode 0x6F (Single Timed Dose).
class TimedSingleDoseEncoder {
  static const int opcode = 0x6F;
  static const int _payloadLength = 0x09;

  Uint8List encode(SingleDoseTimed command) {
    final int pumpIdByte = SingleDoseEncodingUtils.requireByte(
      command.pumpId,
      'pumpId',
    );
    final DateTime executeAt = command.executeAt;
    final int yearOffset = SingleDoseEncodingUtils.requireByte(
      executeAt.year - 2000,
      'yearOffset',
    );
    final int month = SingleDoseEncodingUtils.requireByte(
      executeAt.month,
      'month',
    );
    final int day = SingleDoseEncodingUtils.requireByte(executeAt.day, 'day');
    final int hour = SingleDoseEncodingUtils.requireByte(
      executeAt.hour,
      'hour',
    );
    final int minute = SingleDoseEncodingUtils.requireByte(
      executeAt.minute,
      'minute',
    );

    final int volume = SingleDoseEncodingUtils.requireRawDoseInt(
      command.doseMl,
    );
    final int volumeHigh = (volume >> 8) & 0xFF;
    final int volumeLow = volume & 0xFF;
    final int speedByte = SingleDoseEncodingUtils.mapPumpSpeedToByte(
      command.speed,
    );

    final int checksum = SingleDoseEncodingUtils.checksumFor(<int>[
      pumpIdByte,
      yearOffset,
      month,
      day,
      hour,
      minute,
      volumeHigh,
      volumeLow,
      speedByte,
    ]);

    return Uint8List.fromList(<int>[
      opcode,
      _payloadLength,
      pumpIdByte,
      yearOffset,
      month,
      day,
      hour,
      minute,
      volumeHigh,
      volumeLow,
      speedByte,
      checksum,
    ]);
  }
}
