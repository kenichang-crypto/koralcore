import 'pump_speed.dart';
import 'scheduled_dose_trigger.dart';

/// Pure domain representation of one logical single-dose execution.
///
/// Encoders reuse this object to emit BLE payloads (0x6E/0x6F today, schedule
/// opcodes later). No opcode or byte knowledge leaks into this type.
class SingleDosePlan {
  final int pumpId;
  final double doseMl;
  final PumpSpeed speed;
  final ScheduledDoseTrigger trigger;

  const SingleDosePlan({
    required this.pumpId,
    required this.doseMl,
    required this.speed,
    required this.trigger,
  });
}

