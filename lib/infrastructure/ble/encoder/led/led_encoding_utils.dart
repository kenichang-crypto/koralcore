import '../../../../domain/led_lighting/led_channel_group.dart';
import '../../../../domain/led_lighting/led_spectrum.dart';
import '../../../../domain/led_lighting/time_of_day.dart';
import '../../../../domain/led_lighting/weekday.dart';

/// Shared helpers for LED encoding math.
abstract class LedEncodingUtils {
  static int requireByte(int value, String label) {
    if (value < 0 || value > 0xFF) {
      throw RangeError.range(value, 0, 0xFF, label);
    }
    return value;
  }

  static int channelGroupByte(LedChannelGroup group) => group.id;

  static List<int> encodeTime(TimeOfDay time) {
    return <int>[
      requireByte(time.hour, 'hour'),
      requireByte(time.minute, 'minute'),
    ];
  }

  static int encodeRepeatMask(List<Weekday> repeatOn) {
    int mask = 0;
    for (final Weekday day in repeatOn) {
      switch (day) {
        case Weekday.mon:
          mask |= 1 << 0;
          break;
        case Weekday.tue:
          mask |= 1 << 1;
          break;
        case Weekday.wed:
          mask |= 1 << 2;
          break;
        case Weekday.thu:
          mask |= 1 << 3;
          break;
        case Weekday.fri:
          mask |= 1 << 4;
          break;
        case Weekday.sat:
          mask |= 1 << 5;
          break;
        case Weekday.sun:
          mask |= 1 << 6;
          break;
      }
    }
    return mask & 0x7F;
  }

  static List<int> encodeSpectrum(LedSpectrum spectrum) {
    return spectrum.channelGroup.channelOrder
        .map((channel) => spectrum.intensityOf(channel).value)
        .map((value) => requireByte(value, 'intensity'))
        .toList(growable: false);
  }

  static void finalizePacket(List<int> bytes) {
    final int payloadLength = requireByte(bytes.length - 2, 'payloadLength');
    bytes[1] = payloadLength;
    final int checksum = _checksum(bytes, 2, bytes.length);
    bytes.add(checksum);
  }

  static int _checksum(List<int> bytes, int start, int end) {
    int sum = 0;
    for (int i = start; i < end; i++) {
      sum = (sum + bytes[i]) & 0xFF;
    }
    return sum;
  }
}
