import 'dart:typed_data';

import '../../../../domain/led_lighting/led_scene_schedule.dart';
import 'led_encoding_utils.dart';
import 'led_opcodes.dart';

class LedSceneScheduleEncoder {
  const LedSceneScheduleEncoder();

  Uint8List encode(LedSceneSchedule schedule) {
    final List<int> bytes = <int>[
      LedOpcodes.sceneWindow,
      0x00,
      LedEncodingUtils.requireByte(schedule.scene.presetId, 'sceneId'),
    ];

    bytes.addAll(LedEncodingUtils.encodeTime(schedule.start));
    bytes.addAll(LedEncodingUtils.encodeTime(schedule.end));
    bytes.add(LedEncodingUtils.encodeRepeatMask(schedule.repeatOn));
    bytes.addAll(LedEncodingUtils.encodeSpectrum(schedule.scene.spectrum));

    LedEncodingUtils.finalizePacket(bytes);
    return Uint8List.fromList(bytes);
  }
}
