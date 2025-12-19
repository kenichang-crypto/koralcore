class PumpHeadSummary {
  final String headId;
  final String additiveName;
  final double dailyTargetMl;
  final double todayDispensedMl;
  final double flowRateMlPerMin;
  final DateTime? lastDoseAt;
  final String statusKey;

  const PumpHeadSummary({
    required this.headId,
    required this.additiveName,
    required this.dailyTargetMl,
    required this.todayDispensedMl,
    required this.flowRateMlPerMin,
    required this.lastDoseAt,
    required this.statusKey,
  });

  String get displayName => 'Head $headId';

  PumpHeadSummary copyWith({
    String? headId,
    String? additiveName,
    double? dailyTargetMl,
    double? todayDispensedMl,
    double? flowRateMlPerMin,
    DateTime? lastDoseAt,
    String? statusKey,
  }) {
    return PumpHeadSummary(
      headId: headId ?? this.headId,
      additiveName: additiveName ?? this.additiveName,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      todayDispensedMl: todayDispensedMl ?? this.todayDispensedMl,
      flowRateMlPerMin: flowRateMlPerMin ?? this.flowRateMlPerMin,
      lastDoseAt: lastDoseAt ?? this.lastDoseAt,
      statusKey: statusKey ?? this.statusKey,
    );
  }

  factory PumpHeadSummary.demo(String headId) {
    final normalized = headId.toUpperCase();
    final index = _headIds.indexOf(normalized);
    final now = DateTime.now();
    final resolvedIndex = index == -1 ? 0 : index;

    return PumpHeadSummary(
      headId: normalized,
      additiveName: _additives[resolvedIndex % _additives.length],
      dailyTargetMl: 10 + (resolvedIndex * 2),
      todayDispensedMl: 3.5 + (resolvedIndex * 1.2),
      flowRateMlPerMin: 28 + (resolvedIndex * 1.5),
      lastDoseAt: now.subtract(Duration(hours: resolvedIndex + 1)),
      statusKey: 'ready',
    );
  }
}

const List<String> _headIds = ['A', 'B', 'C', 'D'];
const List<String> _additives = [
  'Alkalinity',
  'Calcium',
  'Magnesium',
  'Trace Elements',
];
