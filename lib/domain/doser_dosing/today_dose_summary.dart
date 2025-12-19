class TodayDoseSummary {
  final double totalMl;
  final double scheduledMl;
  final double manualMl;

  const TodayDoseSummary({
    required this.totalMl,
    required this.scheduledMl,
    required this.manualMl,
  });

  bool get hasData => totalMl > 0 || scheduledMl > 0 || manualMl > 0;
}
