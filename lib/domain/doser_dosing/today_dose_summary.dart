class TodayDoseSummary {
  final double totalMl;
  final double? scheduledMl;
  final double? manualMl;

  const TodayDoseSummary({
    required this.totalMl,
    this.scheduledMl,
    this.manualMl,
  });

  bool get hasData =>
      totalMl > 0 || (scheduledMl ?? 0) > 0 || (manualMl ?? 0) > 0;
}
