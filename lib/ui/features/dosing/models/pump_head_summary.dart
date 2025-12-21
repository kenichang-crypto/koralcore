import '../../../../domain/doser_dosing/pump_head.dart';

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

  factory PumpHeadSummary.empty(String headId) {
    final normalized = headId.toUpperCase();
    return PumpHeadSummary(
      headId: normalized,
      additiveName: '',
      dailyTargetMl: 0,
      todayDispensedMl: 0,
      flowRateMlPerMin: 0,
      lastDoseAt: null,
      statusKey: 'unknown',
    );
  }

  factory PumpHeadSummary.fromPumpHead(PumpHead head) {
    return PumpHeadSummary(
      headId: head.headId,
      additiveName: head.additiveName,
      dailyTargetMl: head.dailyTargetMl,
      todayDispensedMl: head.todayDispensedMl,
      flowRateMlPerMin: head.flowRateMlPerMin,
      lastDoseAt: head.lastDoseAt,
      statusKey: head.statusKey,
    );
  }

  @Deprecated('Use PumpHeadSummary.fromPumpHead or PumpHeadSummary.empty')
  factory PumpHeadSummary.demo(String headId) {
    return PumpHeadSummary.empty(headId);
  }
}
