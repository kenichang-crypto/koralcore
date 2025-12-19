import '../../../../domain/doser/encoder/single_dose_encoding_utils.dart';
import '../../../../domain/doser_dosing/single_dose_immediate.dart';

/// Encoder for BLE opcode 0x6E (Immediate Single Dose).
class ImmediateSingleDoseEncoder {
  static const int opcode = 0x6E;
  static const int _payloadLength = 0x04;

  List<int> encode(SingleDoseImmediate command) {
    final int pumpIdByte = SingleDoseEncodingUtils.requireByte(
      command.pumpId,
      'pumpId',
    );
    final int scaledDose = SingleDoseEncodingUtils.scaleDoseMlToTenths(
      command.doseMl,
    );
    final int volumeHigh = (scaledDose >> 8) & 0xFF;
    final int volumeLow = scaledDose & 0xFF;
    final int speedByte = SingleDoseEncodingUtils.mapPumpSpeedToByte(
      command.speed,
    );
    final int checksum = SingleDoseEncodingUtils.checksumFor(<int>[
      pumpIdByte,
      volumeHigh,
      volumeLow,
      speedByte,
    ]);

    return <int>[
      opcode,
      _payloadLength,
      pumpIdByte,
      volumeHigh,
      volumeLow,
      speedByte,
      checksum,
    ];
  }
}
