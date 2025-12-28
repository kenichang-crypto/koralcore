enum DosingScheduleMode { none, dailyAverage, customWindow }

class DosingScheduleSummary {
  final DosingScheduleMode mode;
  final double? totalMlPerDay;
  final int? windowCount;
  final int? slotCount;

  const DosingScheduleSummary({
    required this.mode,
    this.totalMlPerDay,
    this.windowCount,
    this.slotCount,
  });

  bool get hasSchedule => mode != DosingScheduleMode.none;
}

