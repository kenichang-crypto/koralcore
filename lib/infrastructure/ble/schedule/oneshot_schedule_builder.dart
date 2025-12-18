import '../../../domain/doser_dosing/doser_schedule.dart';

/// Builds the BLE payload for oneshot schedules (BLE commands 32-34).
List<int> buildOneshotScheduleCommand(DoserSchedule schedule) {
  // TODO: Append BLE opcode for oneshot schedule (commands 0x32-0x34).
  // TODO: Encode pump index (0x00-0x03) from schedule context.
  // TODO: Encode scheduled year, month, day values.
  // TODO: Encode scheduled hour and minute values.
  // TODO: Encode total dose in big-endian format per protocol.
  // TODO: Encode pump speed for oneshot execution.
  // TODO: Finalize payload ordering based on BLE protocol requirements.
  return <int>[];
}
