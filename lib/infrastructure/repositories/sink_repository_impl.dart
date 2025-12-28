library;

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../domain/sink/sink.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../platform/contracts/sink_repository.dart';

class SinkRepositoryImpl implements SinkRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final StreamController<List<Sink>> _controller =
      StreamController<List<Sink>>.broadcast();
  bool _initialized = false;
  List<Sink> _cachedSinks = <Sink>[];

  SinkRepositoryImpl({List<String>? initialDeviceIds}) {
    _initialize(initialDeviceIds);
  }

  Future<void> _initialize(List<String>? initialDeviceIds) async {
    if (_initialized) {
      return;
    }
    await _loadSinksFromDatabase(initialDeviceIds);
    _initialized = true;
    _emit();
  }

  Future<void> _loadSinksFromDatabase(List<String>? initialDeviceIds) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> sinkMaps = await db.query('sink');
    
    if (sinkMaps.isEmpty && initialDeviceIds != null) {
      // Create default sink if no sinks exist
      final defaultSink = Sink.defaultSink(initialDeviceIds);
      await _saveSinkToDatabase(defaultSink);
      _emit();
      return;
    }

    final List<Sink> sinks = <Sink>[];
    for (final sinkMap in sinkMaps) {
      final String sinkId = sinkMap['id'] as String;
      final List<String> deviceIds = await _loadDeviceIdsForSink(sinkId);
      sinks.add(_sinkFromMap(sinkMap, deviceIds));
    }
    
    // Ensure default sink exists
    final hasDefaultSink = sinks.any((s) => s.type == SinkType.defaultSink);
    if (!hasDefaultSink) {
      final defaultSink = Sink.defaultSink(initialDeviceIds ?? const []);
      await _saveSinkToDatabase(defaultSink);
      sinks.add(defaultSink);
    }
    
    _cachedSinks = sinks;
    _emit();
  }

  Future<List<String>> _loadDeviceIdsForSink(String sinkId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> relations = await db.query(
      'sink_device_relation',
      where: 'sink_id = ?',
      whereArgs: [sinkId],
    );
    return relations
        .map((map) => map['device_id'] as String)
        .toList(growable: false);
  }

  Future<void> _saveSinkToDatabase(Sink sink) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      'sink',
      {
        'id': sink.id,
        'name': sink.name,
        'type': sink.type.name,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save device relations
    await _saveDeviceRelations(sink.id, sink.deviceIds);
  }

  Future<void> _saveDeviceRelations(String sinkId, List<String> deviceIds) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Delete existing relations
    await db.delete(
      'sink_device_relation',
      where: 'sink_id = ?',
      whereArgs: [sinkId],
    );

    // Insert new relations
    for (final deviceId in deviceIds) {
      await db.insert(
        'sink_device_relation',
        {
          'sink_id': sinkId,
          'device_id': deviceId,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _updateSinkInDatabase(Sink sink) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      'sink',
      {
        'name': sink.name,
        'type': sink.type.name,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [sink.id],
    );

    // Update device relations
    await _saveDeviceRelations(sink.id, sink.deviceIds);
  }

  Future<void> _deleteSinkFromDatabase(String sinkId) async {
    final db = await _dbHelper.database;
    // Delete relations first (CASCADE will handle it, but explicit is better)
    await db.delete(
      'sink_device_relation',
      where: 'sink_id = ?',
      whereArgs: [sinkId],
    );
    // Delete sink
    await db.delete('sink', where: 'id = ?', whereArgs: [sinkId]);
  }

  Sink _sinkFromMap(Map<String, dynamic> map, List<String> deviceIds) {
    final String typeStr = map['type'] as String;
    final SinkType type = typeStr == 'defaultSink'
        ? SinkType.defaultSink
        : SinkType.custom;
    
    return Sink(
      id: map['id'] as String,
      name: map['name'] as String,
      type: type,
      deviceIds: deviceIds,
    );
  }

  @override
  Stream<List<Sink>> observeSinks() => _controller.stream;

  @override
  List<Sink> getCurrentSinks() {
    return List.unmodifiable(_cachedSinks);
  }

  Future<List<Sink>> _getAllSinks() async {
    await _initialize(null);
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> sinkMaps = await db.query('sink');
    final List<Sink> sinks = <Sink>[];
    for (final sinkMap in sinkMaps) {
      final String sinkId = sinkMap['id'] as String;
      final List<String> deviceIds = await _loadDeviceIdsForSink(sinkId);
      sinks.add(_sinkFromMap(sinkMap, deviceIds));
    }
    _cachedSinks = sinks;
    return sinks;
  }

  @override
  void upsertSink(Sink sink) {
    _upsertSinkAsync(sink);
  }

  Future<void> _upsertSinkAsync(Sink sink) async {
    await _initialize(null);
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> existing = await db.query(
      'sink',
      where: 'id = ?',
      whereArgs: [sink.id],
    );

    if (existing.isEmpty) {
      await _saveSinkToDatabase(sink);
    } else {
      await _updateSinkInDatabase(sink);
    }
    await _refreshCache();
    _emit();
  }

  @override
  void removeSink(SinkId sinkId) {
    _removeSinkAsync(sinkId);
  }

  Future<void> _removeSinkAsync(SinkId sinkId) async {
    await _initialize(null);
    
    // Don't allow deleting default sink
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> existing = await db.query(
      'sink',
      where: 'id = ?',
      whereArgs: [sinkId],
    );
    if (existing.isEmpty) {
      return;
    }
    final SinkType type = existing.first['type'] == 'defaultSink'
        ? SinkType.defaultSink
        : SinkType.custom;
    if (type == SinkType.defaultSink) {
      return;
    }

    await _deleteSinkFromDatabase(sinkId);
    await _refreshCache();
    _emit();
  }

  Future<void> _refreshCache() async {
    _cachedSinks = await _getAllSinks();
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List.unmodifiable(_cachedSinks));
  }
}
