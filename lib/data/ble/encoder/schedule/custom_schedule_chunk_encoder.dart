import 'dart:typed_data';

import '../../../../domain/doser_dosing/encoder/single_dose_encoding_utils.dart';
import '../../../../domain/doser_dosing/custom_window_schedule_definition.dart';
import '../../../../domain/doser_dosing/scheduled_dose_trigger.dart';
import '../../../../domain/doser_dosing/single_dose_plan.dart';

/// Shared chunk encoder used by the opcode-specific (0x72-0x74) wrappers.
abstract class CustomScheduleChunkEncoder {
  final int opcode;
  final int chunkIndex;

  const CustomScheduleChunkEncoder({
    required this.opcode,
    required this.chunkIndex,
  });

  Uint8List encode(CustomWindowScheduleDefinition schedule) {
    final List<SingleDosePlan> plans = schedule
        .buildPlans()
        .where((SingleDosePlan plan) => _chunkIndexOf(plan) == chunkIndex)
        .toList(growable: false);

    if (plans.isEmpty) {
      throw StateError(
        'Custom schedule ${schedule.scheduleId} has no plans for chunkIndex '
        '$chunkIndex required by opcode 0x${opcode.toRadixString(16)}.',
      );
    }

    final WindowedDoseTrigger anchorTrigger =
        plans.first.trigger as WindowedDoseTrigger;
    final int windowStart = anchorTrigger.windowStartMinute;
    final int windowEnd = anchorTrigger.windowEndMinute;

    _assertConsistentWindow(plans, windowStart, windowEnd);

    final List<int> payload = <int>[];
    payload.add(opcode);
    payload.add(schedule.pumpId & 0xFF);
    payload.add(chunkIndex & 0xFF);
    payload.add(windowStart & 0xFF);
    payload.add((windowStart >> 8) & 0xFF);
    payload.add(windowEnd & 0xFF);
    payload.add((windowEnd >> 8) & 0xFF);
    payload.add(plans.length & 0xFF);

    for (final SingleDosePlan plan in plans) {
      final WindowedDoseTrigger trigger = plan.trigger as WindowedDoseTrigger;
      final int minuteOffset = trigger.eventMinuteOffset;
      payload.add(minuteOffset & 0xFF);
      payload.add((minuteOffset >> 8) & 0xFF);

      final int dose = SingleDoseEncodingUtils.scaleDoseMlToTenths(plan.doseMl);
      payload.add((dose >> 8) & 0xFF);
      payload.add(dose & 0xFF);

      payload.add(SingleDoseEncodingUtils.mapPumpSpeedToByte(plan.speed));
    }

    final int checksum = SingleDoseEncodingUtils.checksumFor(
      payload.sublist(1),
    );
    payload.add(checksum);

    return Uint8List.fromList(payload);
  }

  void _assertConsistentWindow(
    List<SingleDosePlan> plans,
    int windowStart,
    int windowEnd,
  ) {
    for (final SingleDosePlan plan in plans) {
      final WindowedDoseTrigger trigger = plan.trigger as WindowedDoseTrigger;
      if (trigger.windowStartMinute != windowStart ||
          trigger.windowEndMinute != windowEnd) {
        throw StateError(
          'All events in chunk $chunkIndex must share the same window '
          'boundaries. Found mismatch for plan ${plan.trigger}.',
        );
      }
    }
  }

  int _chunkIndexOf(SingleDosePlan plan) {
    final ScheduledDoseTrigger trigger = plan.trigger;
    if (trigger is! WindowedDoseTrigger) {
      throw StateError(
        'Expected WindowedDoseTrigger but found ${trigger.runtimeType}.',
      );
    }
    return trigger.chunkIndex;
  }
}
