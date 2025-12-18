import 'dart:typed_data';

import '../../../../domain/led_lighting/led_daily_schedule.dart';
import 'led_encoding_utils.dart';
import 'led_opcodes.dart';

class LedDailyScheduleEncoder {
  const LedDailyScheduleEncoder();

  Uint8List encode(LedDailySchedule schedule) {
    if (schedule.points.isEmpty) {
      throw ArgumentError('LED daily schedule requires at least one point.');
    }

    final List<int> bytes = <int>[
      LedOpcodes.dailySchedule,
      0x00, // placeholder for payload length
      LedEncodingUtils.channelGroupByte(schedule.channelGroup),
      LedEncodingUtils.encodeRepeatMask(schedule.repeatOn),
      LedEncodingUtils.requireByte(schedule.points.length, 'pointCount'),
    ];

    for (final LedDailyPoint point in schedule.points) {
      bytes.addAll(LedEncodingUtils.encodeTime(point.time));
      bytes.addAll(LedEncodingUtils.encodeSpectrum(point.spectrum));
    }

    LedEncodingUtils.finalizePacket(bytes);
    return Uint8List.fromList(bytes);
  }
}
