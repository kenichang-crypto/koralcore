import '../../../domain/doser_dosing/doser_schedule.dart';

/// Builds the BLE payload for a custom schedule window.
List<int> buildCustomScheduleCommand(DoserSchedule schedule) {
  // TODO: Append BLE opcode for custom schedule command.
  // TODO: Encode schedule time range start/end from domain model.
  // TODO: Encode per-dose amount for each event in the range.
  // TODO: Encode repeat count or occurrences per protocol requirements.
  // TODO: Encode pump speed associated with this custom schedule.
  // TODO: Finalize payload ordering based on BLE protocol.
  return <int>[];
}
