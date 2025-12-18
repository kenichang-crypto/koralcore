import 'dart:typed_data';

import '../../../../domain/led_lighting/led_custom_schedule.dart';
import 'led_encoding_utils.dart';
import 'led_opcodes.dart';

class LedCustomScheduleEncoder {
  const LedCustomScheduleEncoder();

  Uint8List encode(LedCustomSchedule schedule) {
    final List<int> bytes = <int>[
      LedOpcodes.customWindow,
      0x00,
      LedEncodingUtils.channelGroupByte(schedule.channelGroup),
    ];

    bytes.addAll(LedEncodingUtils.encodeTime(schedule.start));
    bytes.addAll(LedEncodingUtils.encodeTime(schedule.end));
    bytes.addAll(LedEncodingUtils.encodeSpectrum(schedule.spectrum));
    bytes.add(LedEncodingUtils.encodeRepeatMask(schedule.repeatOn));

    LedEncodingUtils.finalizePacket(bytes);
    return Uint8List.fromList(bytes);
  }
}
