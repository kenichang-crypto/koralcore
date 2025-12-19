import 'dart:typed_data';

import '../../../../domain/doser_schedule/custom_window_schedule_definition.dart';
import 'custom_schedule_chunk_encoder.dart';

class CustomScheduleEncoder0x72 extends CustomScheduleChunkEncoder {
  CustomScheduleEncoder0x72() : super(opcode: 0x72, chunkIndex: 0);

  @override
  Uint8List encode(CustomWindowScheduleDefinition schedule) {
    return super.encode(schedule);
  }
}
