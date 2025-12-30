import 'package:flutter/material.dart';

/// Schedule types supported by the read-only overview.
enum PumpHeadScheduleType { dailyAverage, singleDose, customWindow }

/// Recurrence summary used for quick localization.
enum PumpHeadScheduleRecurrence { daily, weekdays, weekends }

class PumpHeadScheduleEntry {
  final String id;
  final PumpHeadScheduleType type;
  final double doseMlPerEvent;
  final int eventsPerDay;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final PumpHeadScheduleRecurrence recurrence;
  final bool isEnabled;

  const PumpHeadScheduleEntry({
    required this.id,
    required this.type,
    required this.doseMlPerEvent,
    required this.eventsPerDay,
    required this.startTime,
    this.endTime,
    required this.recurrence,
    this.isEnabled = true,
  }) : assert(eventsPerDay >= 1, 'eventsPerDay must be positive');

  bool get isWindow => endTime != null;

  double get totalDailyMl => doseMlPerEvent * eventsPerDay;
}
