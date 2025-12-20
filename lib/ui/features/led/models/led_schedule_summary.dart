import 'package:flutter/material.dart';

enum LedScheduleType { dailyProgram, customWindow, sceneBased }

enum LedScheduleRecurrence { everyday, weekdays, weekends }

class LedScheduleChannelValue {
  final String id;
  final String label;
  final int percentage;

  const LedScheduleChannelValue({
    required this.id,
    required this.label,
    required this.percentage,
  });
}

class LedScheduleSummary {
  final String id;
  final String title;
  final LedScheduleType type;
  final LedScheduleRecurrence recurrence;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sceneName;
  final bool isEnabled;
  final List<LedScheduleChannelValue> channels;

  const LedScheduleSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startTime,
    required this.endTime,
    required this.sceneName,
    required this.isEnabled,
    this.channels = const [],
  });
}
