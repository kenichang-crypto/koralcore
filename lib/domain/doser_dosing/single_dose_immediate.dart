import 'pump_speed.dart';

/// SingleDoseImmediate
///
/// Domain data model corresponding to BLE command 15 (single dose, immediate).
/// Pure data holder — contains only fields, no business logic.
class SingleDoseImmediate {
  final int pumpId;
  final double doseMl;
  final PumpSpeed speed;

  const SingleDoseImmediate({
    required this.pumpId,
    required this.doseMl,
    required this.speed,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleDoseImmediate &&
          other.pumpId == pumpId &&
          other.doseMl == doseMl &&
          other.speed == speed;

  @override
  int get hashCode => Object.hash(pumpId, doseMl, speed);

  @override
  String toString() =>
      'SingleDoseImmediate(pumpId: $pumpId, doseMl: $doseMl, speed: $speed)';
}
