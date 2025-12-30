library;

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Persistent repository for managing favorite scenes and devices using SQLite.
/// Mirrors reef-b-app's DeviceFavoriteScene table structure.
class FavoriteRepositoryImpl {
  static final FavoriteRepositoryImpl _instance = FavoriteRepositoryImpl._internal();
  factory FavoriteRepositoryImpl() => _instance;
  FavoriteRepositoryImpl._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Toggle favorite status for a scene
  Future<void> toggleFavoriteScene({
    required String deviceId,
    required String sceneId,
  }) async {
    final db = await _dbHelper.database;

    // Check if already favorite
    final List<Map<String, dynamic>> existing = await db.query(
      'favorite_scenes',
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, sceneId],
      limit: 1,
    );

    if (existing.isEmpty) {
      // Add to favorites
      await db.insert(
        'favorite_scenes',
        {
          'device_id': deviceId,
          'scene_id': sceneId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      // Remove from favorites
      await db.delete(
        'favorite_scenes',
        where: 'device_id = ? AND scene_id = ?',
        whereArgs: [deviceId, sceneId],
      );
    }
  }

  /// Check if a scene is favorite
  Future<bool> isSceneFavorite({
    required String deviceId,
    required String sceneId,
  }) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      'favorite_scenes',
      where: 'device_id = ? AND scene_id = ?',
      whereArgs: [deviceId, sceneId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Get all favorite scene IDs for a device
  Future<Set<String>> getFavoriteScenes(String deviceId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_scenes',
      columns: ['scene_id'],
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => map['scene_id'] as String).toSet();
  }

  /// Toggle favorite status for a device
  Future<void> toggleFavoriteDevice(String deviceId) async {
    final db = await _dbHelper.database;

    // Check if already favorite
    final List<Map<String, dynamic>> existing = await db.query(
      'favorite_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );

    if (existing.isEmpty) {
      // Add to favorites
      await db.insert(
        'favorite_devices',
        {
          'device_id': deviceId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Remove from favorites
      await db.delete(
        'favorite_devices',
        where: 'device_id = ?',
        whereArgs: [deviceId],
      );
    }
  }

  /// Check if a device is favorite
  Future<bool> isDeviceFavorite(String deviceId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      'favorite_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
