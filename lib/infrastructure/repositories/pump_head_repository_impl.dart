library;

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../domain/doser_dosing/pump_head.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../platform/contracts/pump_head_repository.dart';

class PumpHeadRepositoryImpl extends PumpHeadRepository {
  static const double _defaultDailyLimitMl = 30.0;
  static const double _defaultFlowRateMlPerMin = 1.0;
  static const List<String> _defaultHeadIds = <String>['A', 'B', 'C', 'D'];

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<String, _PumpHeadStore> _stores = <String, _PumpHeadStore>{};

  PumpHeadRepositoryImpl();

  @override
  Future<List<PumpHead>> listPumpHeads(String deviceId) async {
    await _loadPumpHeadsFromDatabase(deviceId);
    return _ensureStore(deviceId).heads;
  }

  @override
  Stream<List<PumpHead>> observePumpHeads(String deviceId) {
    // Load from database when stream is first listened to
    _loadPumpHeadsFromDatabase(deviceId);
    return _ensureStore(deviceId).stream;
  }

  @override
  Future<PumpHead?> getPumpHead(String deviceId, String headId) async {
    await _loadPumpHeadsFromDatabase(deviceId);
    return _ensureStore(deviceId).headByHeadId(headId);
  }

  @override
  Future<void> savePumpHeads(String deviceId, List<PumpHead> heads) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    final List<PumpHead> normalizedHeads =
        heads.map(_normalizeHead).toList(growable: false);
    store.setHeads(normalizedHeads);
    await _savePumpHeadsToDatabase(deviceId, normalizedHeads);
  }

  @override
  Future<void> updateTotals({
    required String deviceId,
    required String headId,
    double? totalMl,
    DateTime? lastDoseAt,
  }) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    store.updateTotals(
      headId: headId,
      totalMl: totalMl,
      lastDoseAt: lastDoseAt,
    );
    final PumpHead? updatedHead = store.headByHeadId(headId);
    if (updatedHead != null) {
      await _savePumpHeadToDatabase(deviceId, updatedHead);
    }
  }

  @override
  Future<void> updateStatus({
    required String deviceId,
    required String headId,
    required PumpHeadStatus status,
  }) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    store.updateStatus(headId: headId, status: status);
    final PumpHead? updatedHead = store.headByHeadId(headId);
    if (updatedHead != null) {
      await _savePumpHeadToDatabase(deviceId, updatedHead);
    }
  }

  @override
  Future<void> resetDailyIfNeeded({
    required String deviceId,
    required DateTime now,
  }) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    store.resetDailyIfNeeded(now);
    // Save all heads after daily reset
    await _savePumpHeadsToDatabase(deviceId, store.heads);
  }

  Future<void> _loadPumpHeadsFromDatabase(String deviceId) async {
    // Check if already loaded for this device
    if (_stores.containsKey(deviceId)) {
      final store = _stores[deviceId]!;
      if (store.heads.isNotEmpty) {
        // Already have heads, check if we should reload from DB
        // For now, we'll reload to ensure consistency
      }
    }

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drop_head',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );

    final _PumpHeadStore store = _ensureStore(deviceId);

    if (maps.isEmpty) {
      // No heads in database, use defaults if store is empty
      if (store.heads.isEmpty) {
        // Store already has defaults from _ensureStore
        return;
      }
      return;
    }

    final List<PumpHead> heads = maps.map((map) => _pumpHeadFromMap(map)).toList();
    store.setHeads(heads);
  }

  Future<void> _savePumpHeadsToDatabase(
      String deviceId, List<PumpHead> heads) async {
    final db = await _dbHelper.database;
    // ignore: unused_local_variable
    final now = DateTime.now().millisecondsSinceEpoch;

    // Delete existing heads for this device
    await db.delete(
      'drop_head',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );

    // Insert all heads
    for (final head in heads) {
      await _savePumpHeadToDatabase(deviceId, head);
    }
  }

  Future<void> _savePumpHeadToDatabase(String deviceId, PumpHead head) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'drop_head',
      {
        'device_id': deviceId,
        'head_id': head.headId,
        'pump_id': head.pumpId,
        'additive_name': head.additiveName.isEmpty ? null : head.additiveName,
        'daily_target_ml': head.dailyTargetMl,
        'today_dispensed_ml': head.todayDispensedMl,
        'flow_rate_ml_per_min': head.flowRateMlPerMin,
        'last_dose_at': head.lastDoseAt?.millisecondsSinceEpoch,
        'status_key': head.statusKey,
        'status': head.status.name,
        'drop_type_id': null, // TODO: Map from additiveName to dropTypeId
        'max_drop': head.maxDrop,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  PumpHead _pumpHeadFromMap(Map<String, dynamic> map) {
    return PumpHead(
      headId: map['head_id'] as String,
      pumpId: map['pump_id'] as int,
      additiveName: map['additive_name'] as String? ?? '',
      dailyTargetMl: (map['daily_target_ml'] as num?)?.toDouble() ?? _defaultDailyLimitMl,
      todayDispensedMl: (map['today_dispensed_ml'] as num?)?.toDouble() ?? 0.0,
      flowRateMlPerMin: (map['flow_rate_ml_per_min'] as num?)?.toDouble() ?? _defaultFlowRateMlPerMin,
      lastDoseAt: map['last_dose_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_dose_at'] as int)
          : null,
      statusKey: map['status_key'] as String? ?? 'idle',
      status: _statusFromString(map['status'] as String? ?? 'idle'),
      maxDrop: map['max_drop'] as int?,
    );
  }

  PumpHeadStatus _statusFromString(String status) {
    switch (status) {
      case 'running':
        return PumpHeadStatus.running;
      case 'error':
        return PumpHeadStatus.error;
      case 'idle':
      default:
        return PumpHeadStatus.idle;
    }
  }

  _PumpHeadStore _ensureStore(String deviceId) {
    return _stores.putIfAbsent(
      deviceId,
      () => _PumpHeadStore(
        deviceId: deviceId,
        seedHeads: _defaultHeadIds
            .map(_createDefaultHead)
            .toList(growable: false),
        createDefaultHead: _createDefaultHead,
      ),
    );
  }

  PumpHead _normalizeHead(PumpHead head) {
    final String normalizedId = head.headId.trim().toUpperCase();
    final double dailyLimit = head.dailyTargetMl > 0
        ? head.dailyTargetMl
        : _defaultDailyLimitMl;
    final double flowRate = head.flowRateMlPerMin > 0
        ? head.flowRateMlPerMin
        : _defaultFlowRateMlPerMin;
    final PumpHeadStatus status = head.status;
    final String statusKey = head.statusKey.isEmpty
        ? status.name
        : head.statusKey;
    return head.copyWith(
      headId: normalizedId,
      pumpId: PumpHeadRepository.pumpIdFromHeadId(normalizedId),
      dailyTargetMl: dailyLimit,
      flowRateMlPerMin: flowRate,
      status: status,
      statusKey: statusKey,
    );
  }

  PumpHead _createDefaultHead(String headId) {
    final String normalizedId = headId.trim().toUpperCase();
    return PumpHead(
      headId: normalizedId,
      pumpId: PumpHeadRepository.pumpIdFromHeadId(normalizedId),
      additiveName: '',
      dailyTargetMl: _defaultDailyLimitMl,
      todayDispensedMl: 0,
      flowRateMlPerMin: _defaultFlowRateMlPerMin,
      lastDoseAt: null,
      statusKey: PumpHeadStatus.idle.name,
      status: PumpHeadStatus.idle,
    );
  }
}

class _PumpHeadStore {
  final String deviceId;
  final StreamController<List<PumpHead>> _controller;
  final PumpHead Function(String headId) createDefaultHead;
  List<PumpHead> _heads;
  DateTime? _lastResetDate;

  _PumpHeadStore({
    required this.deviceId,
    required List<PumpHead> seedHeads,
    required this.createDefaultHead,
  }) : _controller = StreamController<List<PumpHead>>.broadcast(),
       _heads = List.unmodifiable(seedHeads) {
    _controller.onListen = () {
      _controller.add(_heads);
    };
  }

  List<PumpHead> get heads => _heads;
  Stream<List<PumpHead>> get stream => _controller.stream;

  PumpHead? headByHeadId(String headId) {
    final String normalized = headId.trim().toUpperCase();
    for (final PumpHead head in _heads) {
      if (head.headId == normalized) {
        return head;
      }
    }
    return null;
  }

  void setHeads(List<PumpHead> next) {
    _heads = List.unmodifiable(next);
    _controller.add(_heads);
  }

  void updateTotals({
    required String headId,
    double? totalMl,
    DateTime? lastDoseAt,
  }) {
    final String normalized = headId.trim().toUpperCase();
    final PumpHead current =
        headByHeadId(normalized) ?? createDefaultHead(normalized);
    final PumpHead next = current.copyWith(
      todayDispensedMl: totalMl ?? current.todayDispensedMl,
      lastDoseAt: lastDoseAt ?? current.lastDoseAt,
    );
    if (_areEqual(current, next)) {
      return;
    }
    _replaceHead(normalized, next);
  }

  void updateStatus({required String headId, required PumpHeadStatus status}) {
    final String normalized = headId.trim().toUpperCase();
    final PumpHead current =
        headByHeadId(normalized) ?? createDefaultHead(normalized);
    if (current.status == status) {
      return;
    }
    final PumpHead next = current.copyWith(
      status: status,
      statusKey: status.name,
    );
    _replaceHead(normalized, next);
  }

  void resetDailyIfNeeded(DateTime now) {
    final DateTime normalizedDate = DateTime(now.year, now.month, now.day);
    if (_lastResetDate != null &&
        _lastResetDate!.year == normalizedDate.year &&
        _lastResetDate!.month == normalizedDate.month &&
        _lastResetDate!.day == normalizedDate.day) {
      return;
    }
    _lastResetDate = normalizedDate;
    bool changed = false;
    final List<PumpHead> updated = _heads
        .map((head) {
          if (head.todayDispensedMl == 0 && head.lastDoseAt == null) {
            return head;
          }
          changed = true;
          return head.copyWith(todayDispensedMl: 0, lastDoseAt: null);
        })
        .toList(growable: false);
    if (changed) {
      setHeads(updated);
    }
  }

  void _replaceHead(String headId, PumpHead next) {
    final int index = _heads.indexWhere((head) => head.headId == headId);
    final List<PumpHead> updated = List<PumpHead>.from(_heads);
    if (index == -1) {
      updated.add(next);
    } else {
      updated[index] = next;
    }
    setHeads(updated);
  }

  bool _areEqual(PumpHead a, PumpHead b) {
    return a.todayDispensedMl == b.todayDispensedMl &&
        a.lastDoseAt == b.lastDoseAt;
  }
}
