library;

import 'dart:convert';

import '../database/database_helper.dart';
import '../../domain/usecases/led/read_led_schedules.dart';

/// Local persistence for LED schedules.
/// BLE schedule sync is firmware-dependent; this provides local create/edit UX.
class ScheduleRepositoryImpl {
  static final ScheduleRepositoryImpl _instance = ScheduleRepositoryImpl._internal();
  factory ScheduleRepositoryImpl() => _instance;
  ScheduleRepositoryImpl._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> addSchedule({
    required String deviceId,
    required String title,
    required ReadLedScheduleType type,
    required ReadLedScheduleRecurrence recurrence,
    required int startMinutesFromMidnight,
    required int endMinutesFromMidnight,
    required bool isEnabled,
    required List<ReadLedScheduleChannelSnapshot> channels,
    String? sceneName,
  }) async {
    final db = await _dbHelper.database;
    final scheduleId = 'local_schedule_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('led_schedules', {
      'device_id': deviceId,
      'schedule_id': scheduleId,
      'title': title,
      'type': type.name,
      'recurrence': recurrence.name,
      'start_minutes': startMinutesFromMidnight,
      'end_minutes': endMinutesFromMidnight,
      'is_enabled': isEnabled ? 1 : 0,
      'channels_json': jsonEncode(channels.map((c) => {'id': c.id, 'label': c.label, 'percentage': c.percentage}).toList()),
      'scene_name': sceneName ?? '',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return scheduleId;
  }

  Future<void> updateSchedule({
    required String deviceId,
    required String scheduleId,
    required String title,
    required ReadLedScheduleType type,
    required ReadLedScheduleRecurrence recurrence,
    required int startMinutesFromMidnight,
    required int endMinutesFromMidnight,
    required bool isEnabled,
    required List<ReadLedScheduleChannelSnapshot> channels,
    String? sceneName,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.update(
      'led_schedules',
      {
        'title': title,
        'type': type.name,
        'recurrence': recurrence.name,
        'start_minutes': startMinutesFromMidnight,
        'end_minutes': endMinutesFromMidnight,
        'is_enabled': isEnabled ? 1 : 0,
        'channels_json': jsonEncode(channels.map((c) => {'id': c.id, 'label': c.label, 'percentage': c.percentage}).toList()),
        'scene_name': sceneName ?? '',
      },
      where: 'device_id = ? AND schedule_id = ?',
      whereArgs: [deviceId, scheduleId],
    );
    if (rows == 0) {
      throw Exception('Schedule not found: $scheduleId');
    }
  }

  Future<List<_ScheduleRecord>> getSchedules(String deviceId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'led_schedules',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => _ScheduleRecord.fromMap(m)).toList();
  }
}

class _ScheduleRecord {
  final String scheduleId;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final bool isEnabled;
  final List<ReadLedScheduleChannelSnapshot> channels;
  final String sceneName;

  _ScheduleRecord({
    required this.scheduleId,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.isEnabled,
    required this.channels,
    required this.sceneName,
  });

  factory _ScheduleRecord.fromMap(Map<String, dynamic> m) {
    List<ReadLedScheduleChannelSnapshot> channels = [];
    final json = m['channels_json'] as String?;
    if (json != null && json.isNotEmpty) {
      final list = jsonDecode(json) as List<dynamic>?;
      if (list != null) {
        channels = list.map((e) {
          final map = e as Map<String, dynamic>;
          return ReadLedScheduleChannelSnapshot(
            id: map['id'] as String? ?? '',
            label: map['label'] as String? ?? '',
            percentage: (map['percentage'] as num?)?.toInt() ?? 0,
          );
        }).toList();
      }
    }
    return _ScheduleRecord(
      scheduleId: m['schedule_id'] as String,
      title: m['title'] as String,
      type: ReadLedScheduleType.values.firstWhere((e) => e.name == m['type'], orElse: () => ReadLedScheduleType.customWindow),
      recurrence: ReadLedScheduleRecurrence.values.firstWhere((e) => e.name == m['recurrence'], orElse: () => ReadLedScheduleRecurrence.everyDay),
      startMinutesFromMidnight: m['start_minutes'] as int? ?? 0,
      endMinutesFromMidnight: m['end_minutes'] as int? ?? 0,
      isEnabled: (m['is_enabled'] as int? ?? 1) == 1,
      channels: channels,
      sceneName: m['scene_name'] as String? ?? '',
    );
  }
}
