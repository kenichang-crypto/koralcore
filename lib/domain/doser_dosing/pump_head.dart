class PumpHead {
  final String headId;
  final int pumpId;
  final String additiveName;
  final double dailyTargetMl;
  final double todayDispensedMl;
  final double flowRateMlPerMin;
  final DateTime? lastDoseAt;
  final String statusKey;

  const PumpHead({
    required this.headId,
    required this.pumpId,
    required this.additiveName,
    required this.dailyTargetMl,
    required this.todayDispensedMl,
    required this.flowRateMlPerMin,
    required this.lastDoseAt,
    required this.statusKey,
  });

  PumpHead copyWith({
    String? headId,
    int? pumpId,
    String? additiveName,
    double? dailyTargetMl,
    double? todayDispensedMl,
    double? flowRateMlPerMin,
    DateTime? lastDoseAt,
    String? statusKey,
  }) {
    return PumpHead(
      headId: headId ?? this.headId,
      pumpId: pumpId ?? this.pumpId,
      additiveName: additiveName ?? this.additiveName,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      todayDispensedMl: todayDispensedMl ?? this.todayDispensedMl,
      flowRateMlPerMin: flowRateMlPerMin ?? this.flowRateMlPerMin,
      lastDoseAt: lastDoseAt ?? this.lastDoseAt,
      statusKey: statusKey ?? this.statusKey,
    );
  }
}
