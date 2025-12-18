import 'dart:typed_data';

import 'led_schedule_payload.dart';

/// Encodes LED schedule payload models into raw BLE bytes.
Uint8List encodeLedSchedulePayload(LedSchedulePayload payload) {
  // TODO: Insert BLE opcode for LED scheduling commands once specified.
  // TODO: Serialize payload fields (times, intensities, repeat days) into bytes.
  // TODO: Apply protocol-specific framing/checksum rules when available.
  return Uint8List(0);
}
