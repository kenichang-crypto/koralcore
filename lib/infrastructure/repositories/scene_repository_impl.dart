library;

import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Persistent repository for managing LED scenes locally using SQLite.
/// Mirrors reef-b-app's Scene table structure.
class SceneRepositoryImpl {
  static final SceneRepositoryImpl _instance = SceneRepositoryImpl._internal();
  factory SceneRepositoryImpl() => _instance;
  SceneRepositoryImpl._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add a new scene
  Future<int> addScene({
    required String deviceId,
    required String name,
    required int iconId,
    required Map<String, int> channelLevels,
  }) async {
    final db = await _dbHelper.database;

    // Check if scene limit reached (reef-b-app allows max 5 custom scenes)
    final int currentCount = await getSceneCount(deviceId);
    if (currentCount >= 5) {
      throw Exception('Maximum number of scenes (5) reached');
    }

    // Get next scene ID for this device
    final int nextSceneId = await _getNextSceneId(deviceId);

    // Insert scene
    final int id = await db.insert(
      'scenes',
      {
        'device_id': deviceId,
        'scene_id': nextSceneId,
        'name': name,
        'icon_id': iconId,
        'cold_white': channelLevels['coldWhite'] ?? 0,
        'royal_blue': channelLevels['royalBlue'] ?? 0,
        'blue': channelLevels['blue'] ?? 0,
        'red': channelLevels['red'] ?? 0,
        'green': channelLevels['green'] ?? 0,
        'purple': channelLevels['purple'] ?? 0,
        'uv': channelLevels['uv'] ?? 0,
        'warm_white': channelLevels['warmWhite'] ?? 0,
        'moon_light': channelLevels['moonLight'] ?? 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return nextSceneId;
  }

  /// Update an existing scene
  Future<void> updateScene({
    required String deviceId,
    required int sceneId,
    required String name,
    required int iconId,
    required Map<String, int> channelLevels,
  }) async {
    final db = await _dbHelper.database;

    final int rowsAffected = await db.update(
      'scenes',
      {
        'name': name,
        'icon_id': iconId,
        'cold_white': channelLevels['coldWhite'] ?? 0,
        'royal_blue': channelLevels['royalBlue'] ?? 0,
        'blue': channelLevels['blue'] ?? 0,
        'red': channelLevels['red'] ?? 0,
        'green': channelLevels['green'] ?? 0,
        'purple': channelLevels['purple'] ?? 0,
        'uv': channelLevels['uv'] ?? 0,
        'warm_white': channelLevels['warmWhite'] ?? 0,
        'moon_light': channelLevels['moonLight'] ?? 0,
      },
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, sceneId],
    );

    if (rowsAffected == 0) {
      throw Exception('Scene not found: $sceneId');
    }
  }

  /// Delete a scene
  Future<void> deleteScene({
    required String deviceId,
    required int sceneId,
  }) async {
    final db = await _dbHelper.database;

    await db.delete(
      'scenes',
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, sceneId],
    );

    // Also remove from favorites if exists
    await db.delete(
      'favorite_scenes',
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, 'local_scene_$sceneId'],
    );
  }

  /// Get all scenes for a device
  Future<List<_SceneRecord>> getScenes(String deviceId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'scenes',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'scene_id ASC',
    );

    return maps.map((map) => _SceneRecord.fromMap(map)).toList();
  }

  /// Get a scene by ID
  Future<_SceneRecord?> getSceneById({
    required String deviceId,
    required int sceneId,
  }) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'scenes',
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, sceneId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _SceneRecord.fromMap(maps.first);
  }

  /// Get scene count for a device
  Future<int> getSceneCount(String deviceId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM scenes WHERE device_id = ?',
      [deviceId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get next scene ID for a device
  Future<int> _getNextSceneId(String deviceId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(scene_id) as max_id FROM scenes WHERE device_id = ?',
      [deviceId],
    );

    final int? maxId = Sqflite.firstIntValue(result);
    return (maxId ?? 0) + 1;
  }
}

class _SceneRecord {
  final int id; // Database primary key
  final int sceneId; // Scene ID within device
  final String name;
  final int iconId;
  final Map<String, int> channelLevels;

  _SceneRecord({
    required this.id,
    required this.sceneId,
    required this.name,
    required this.iconId,
    required this.channelLevels,
  });

  factory _SceneRecord.fromMap(Map<String, dynamic> map) {
    return _SceneRecord(
      id: map['id'] as int,
      sceneId: map['scene_id'] as int,
      name: map['name'] as String,
      iconId: map['icon_id'] as int,
      channelLevels: {
        'coldWhite': map['cold_white'] as int,
        'royalBlue': map['royal_blue'] as int,
        'blue': map['blue'] as int,
        'red': map['red'] as int,
        'green': map['green'] as int,
        'purple': map['purple'] as int,
        'uv': map['uv'] as int,
        'warmWhite': map['warm_white'] as int,
        'moonLight': map['moon_light'] as int,
      },
    );
  }
}
