import 'package:flutter/material.dart';

enum LedScheduleType { dailyProgram, customWindow, sceneBased }

enum LedScheduleRecurrence { everyday, weekdays, weekends }

class LedScheduleSummary {
  final String id;
  final String title;
  final LedScheduleType type;
  final LedScheduleRecurrence recurrence;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sceneName;
  final bool isEnabled;

  const LedScheduleSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startTime,
    required this.endTime,
    required this.sceneName,
    required this.isEnabled,
  });
}
