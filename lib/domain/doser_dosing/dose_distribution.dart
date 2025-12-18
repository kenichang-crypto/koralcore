/// DoseDistribution
///
/// Represents how a total dose is distributed (number of times per period).
///
/// TODO(BLE-MAPPING): Map `times` to the appropriate BLE field for
/// 24h/custom schedules when building payloads.
class DoseDistribution {
  final int times;

  const DoseDistribution({required this.times});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseDistribution && other.times == times;

  @override
  int get hashCode => times.hashCode;

  @override
  String toString() => 'DoseDistribution(times: $times)';
}
