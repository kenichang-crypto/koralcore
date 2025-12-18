import 'pump_speed.dart';

/// SingleDoseTimed
///
/// Domain data model corresponding to BLE command 16 (single dose, timed).
/// Pure data holder — contains only fields, no business logic.
class SingleDoseTimed {
  final int pumpId;
  final double doseMl;
  final PumpSpeed speed;
  final DateTime executeAt;

  const SingleDoseTimed({
    required this.pumpId,
    required this.doseMl,
    required this.speed,
    required this.executeAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleDoseTimed &&
          other.pumpId == pumpId &&
          other.doseMl == doseMl &&
          other.speed == speed &&
          other.executeAt == executeAt;

  @override
  int get hashCode => Object.hash(pumpId, doseMl, speed, executeAt);

  @override
  String toString() =>
      'SingleDoseTimed(pumpId: $pumpId, doseMl: $doseMl, speed: $speed, executeAt: $executeAt)';
}
