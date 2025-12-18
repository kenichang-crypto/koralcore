import 'dart:typed_data';

import '../../../../domain/doser_schedule/custom_window_schedule_definition.dart';
import 'custom_schedule_chunk_encoder.dart';

class CustomScheduleEncoder0x73 extends CustomScheduleChunkEncoder {
  CustomScheduleEncoder0x73() : super(opcode: 0x73, chunkIndex: 1);

  Uint8List encode(CustomWindowScheduleDefinition schedule) {
    return super.encode(schedule);
  }
}
