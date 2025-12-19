enum LedScheduleMode { none, dailyProgram, customWindow, sceneBased }

class LedScheduleOverview {
  final LedScheduleMode mode;
  final bool isEnabled;
  final int? startMinute;
  final int? endMinute;
  final String? label;

  const LedScheduleOverview({
    required this.mode,
    required this.isEnabled,
    this.startMinute,
    this.endMinute,
    this.label,
  });

  bool get hasSchedule => mode != LedScheduleMode.none;
}
