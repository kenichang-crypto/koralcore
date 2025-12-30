library;

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../domain/drop_type/drop_type.dart';
import '../../data/database/database_helper.dart';
import '../../platform/contracts/drop_type_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';

/// SQLite-backed repository for drop type management.
class DropTypeRepositoryImpl implements DropTypeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PumpHeadRepository? _pumpHeadRepository;
  final StreamController<List<DropType>> _controller =
      StreamController<List<DropType>>.broadcast();

  DropTypeRepositoryImpl({PumpHeadRepository? pumpHeadRepository})
      : _pumpHeadRepository = pumpHeadRepository;

  @override
  Stream<List<DropType>> observeDropTypes() {
    _emit();
    return _controller.stream;
  }

  @override
  Future<List<DropType>> getAllDropTypes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drop_type',
      orderBy: 'name ASC',
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<DropType?> getDropTypeById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drop_type',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return _fromMap(maps.first);
  }

  @override
  Future<int> addDropType(DropType dropType) async {
    final db = await _dbHelper.database;
    try {
      final int id = await db.insert(
        'drop_type',
        {
          'name': dropType.name,
          'is_preset': dropType.isPreset ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (id > 0) {
        _emit();
      }
      return id > 0 ? id : -1;
    } catch (e) {
      // Unique constraint violation or other error
      return -1;
    }
  }

  @override
  Future<int> updateDropType(DropType dropType) async {
    final db = await _dbHelper.database;
    try {
      final int count = await db.update(
        'drop_type',
        {
          'name': dropType.name,
          'is_preset': dropType.isPreset ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [dropType.id],
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (count > 0) {
        _emit();
      }
      return count;
    } catch (e) {
      // Unique constraint violation or other error
      return 0;
    }
  }

  @override
  Future<void> deleteDropType(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'drop_type',
      where: 'id = ?',
      whereArgs: [id],
    );
    _emit();
  }

  @override
  Future<bool> isDropTypeUsed(int dropTypeId) async {
    // Check if any pump head is using this drop type
    if (_pumpHeadRepository == null) {
      return false;
    }
    // TODO: Implement check against pump head repository
    // This requires checking if any pump head has dropTypeId == dropTypeId
    // For now, return false as placeholder
    return false;
  }

  void _emit() {
    getAllDropTypes().then((dropTypes) {
      _controller.add(dropTypes);
    });
  }

  DropType _fromMap(Map<String, dynamic> map) {
    return DropType(
      id: map['id'] as int,
      name: map['name'] as String,
      isPreset: (map['is_preset'] as int) != 0,
    );
  }
}

