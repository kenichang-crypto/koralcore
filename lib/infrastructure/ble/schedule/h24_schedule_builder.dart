import '../../../domain/doser_dosing/doser_schedule.dart';

/// Builds the BLE payload for a 24h schedule.
List<int> buildH24ScheduleCommand(DoserSchedule schedule) {
  // TODO: Append BLE opcode for 24h schedule command.
  // TODO: Include pump index extracted from schedule metadata.
  // TODO: Encode total daily dose for the selected pump.
  // TODO: Encode repeat weekdays bitmask per specification.
  // TODO: Encode pump speed for h24 schedule.
  // TODO: Finalize payload ordering based on BLE protocol.
  return <int>[];
}
