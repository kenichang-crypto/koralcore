import 'dart:typed_data';

import '../../../../domain/doser_dosing/encoder/single_dose_encoding_utils.dart';
import '../../../../domain/doser_dosing/daily_average_schedule_definition.dart';
import '../../../../domain/doser_dosing/scheduled_dose_trigger.dart';
import '../../../../domain/doser_dosing/single_dose_plan.dart';
import '../../../../domain/doser_dosing/schedule_weekday.dart';

/// Encoder for BLE opcode 0x70 (Daily Average / 24h schedule).
class DailyAverageScheduleEncoder {
  static const int opcode = 0x70;

  Uint8List encode(DailyAverageScheduleDefinition schedule) {
    final List<SingleDosePlan> plans = schedule.buildPlans();
    final List<int> payload = <int>[];

    payload.add(opcode);
    payload.add(schedule.pumpId & 0xFF);
    payload.add(_repeatMask(schedule.repeatDays));
    payload.add(plans.length & 0xFF);

    for (final SingleDosePlan plan in plans) {
      final DailyTimeTrigger trigger = plan.trigger as DailyTimeTrigger;
      payload.add(trigger.hour & 0xFF);
      payload.add(trigger.minute & 0xFF);

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

  int _repeatMask(Set<ScheduleWeekday> repeatDays) {
    int mask = 0;
    for (final ScheduleWeekday day in repeatDays) {
      mask |= 1 << day.index;
    }
    return mask & 0xFF;
  }
}
