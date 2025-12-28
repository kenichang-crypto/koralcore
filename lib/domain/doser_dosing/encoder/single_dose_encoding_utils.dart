import '../../doser_dosing/pump_speed.dart';

/// Shared helpers for Immediate/Timed Single Dose encoders.
abstract class SingleDoseEncodingUtils {
  static int requireByte(int value, String fieldName) {
    if (value < 0 || value > 0xFF) {
      throw ArgumentError.value(
        value,
        fieldName,
        'Value must be in 0-255 to fit a single byte.',
      );
    }
    return value;
  }

  static int scaleDoseMlToTenths(double doseMl) {
    final int scaled = (doseMl * 10).round();
    if (scaled < 0 || scaled > 0xFFFF) {
      throw ArgumentError.value(
        doseMl,
        'doseMl',
        'Scaled dose must fit in 16 bits (0x0000-0xFFFF).',
      );
    }
    return scaled;
  }

  static int requireRawDoseInt(double doseMl) {
    if (doseMl % 1 != 0) {
      throw ArgumentError.value(
        doseMl,
        'doseMl',
        'Volume must already be scaled to an integer (e.g. ml×10).',
      );
    }
    final int volume = doseMl.toInt();
    if (volume < 0 || volume > 0xFFFF) {
      throw ArgumentError.value(
        doseMl,
        'doseMl',
        'Volume must fit in 16 bits (0x0000-0xFFFF).',
      );
    }
    return volume;
  }

  static int mapPumpSpeedToByte(PumpSpeed speed) {
    switch (speed) {
      case PumpSpeed.low:
        return 0x01;
      case PumpSpeed.medium:
        return 0x02;
      case PumpSpeed.high:
        return 0x03;
    }
  }

  static int checksumFor(Iterable<int> bytes) {
    int sum = 0;
    for (final int byte in bytes) {
      sum = (sum + byte) & 0xFF;
    }
    return sum;
  }
}
