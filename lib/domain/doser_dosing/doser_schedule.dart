import 'doser_schedule_type.dart';
import 'schedule_time_models.dart';
import 'schedule_repeat.dart';
import 'dose_distribution.dart';

/// DoserSchedule
///
/// Pure domain model representing a dosing schedule for a pump.
///
/// References:
/// - docs/reef_b_app_behavior.md (initialize + schedule expectations)
/// - docs/ble_protocol_v1_11.md (system command purposes)
///
/// Manual / single-dose commands (BLE 15 / 16) are represented separately by
/// `SingleDoseImmediate` / `SingleDoseTimed`. `DoserSchedule` is strictly for
/// recurring or scheduled actions (24h/custom/oneshot_schedule).
///
/// TODO(BLE-MAPPING): Provide conversion helpers that translate this model into
/// BLE payloads for:
/// - 24h schedule command (h24 type)
/// - Custom schedule command (custom type)
/// - One-shot sequence (oneshotSchedule; BLE commands 32–34)
/// These helpers should live outside the domain layer (e.g., in application /
/// platform boundary) to keep this model pure.
class DoserSchedule {
  final int pumpId;
  final DoserScheduleType type;
  final ScheduleTime time;
  final ScheduleRepeat? repeat; // oneshotSchedule must have null repeat
  final DoseDistribution distribution;
  final double totalDoseMl;

  const DoserSchedule({
    required this.pumpId,
    required this.type,
    required this.time,
    this.repeat,
    required this.distribution,
    required this.totalDoseMl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoserSchedule &&
          other.pumpId == pumpId &&
          other.type == type &&
          other.time == time &&
          other.repeat == repeat &&
          other.distribution == distribution &&
          other.totalDoseMl == totalDoseMl;

  @override
  int get hashCode =>
      Object.hash(pumpId, type, time, repeat, distribution, totalDoseMl);

  @override
  String toString() =>
      'DoserSchedule(pumpId: $pumpId, type: $type, time: $time, repeat: $repeat, distribution: $distribution, totalDoseMl: $totalDoseMl)';
}
