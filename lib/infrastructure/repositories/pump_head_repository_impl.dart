library;

import 'dart:async';

import '../../domain/doser_dosing/pump_head.dart';
import '../../platform/contracts/pump_head_repository.dart';

class PumpHeadRepositoryImpl extends PumpHeadRepository {
  static const double _defaultDailyLimitMl = 30.0;
  static const double _defaultFlowRateMlPerMin = 1.0;
  static const List<String> _defaultHeadIds = <String>['A', 'B', 'C', 'D'];

  final Map<String, _PumpHeadStore> _stores = <String, _PumpHeadStore>{};

  PumpHeadRepositoryImpl();

  @override
  Future<List<PumpHead>> listPumpHeads(String deviceId) async {
    return _ensureStore(deviceId).heads;
  }

  @override
  Stream<List<PumpHead>> observePumpHeads(String deviceId) {
    return _ensureStore(deviceId).stream;
  }

  @override
  Future<PumpHead?> getPumpHead(String deviceId, String headId) async {
    return _ensureStore(deviceId).headByHeadId(headId);
  }

  @override
  Future<void> savePumpHeads(String deviceId, List<PumpHead> heads) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    store.setHeads(heads.map(_normalizeHead).toList(growable: false));
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
  }

  @override
  Future<void> updateStatus({
    required String deviceId,
    required String headId,
    required PumpHeadStatus status,
  }) async {
    final _PumpHeadStore store = _ensureStore(deviceId);
    store.updateStatus(headId: headId, status: status);
  }

  @override
  Future<void> resetDailyIfNeeded({
    required String deviceId,
    required DateTime now,
  }) async {
    _ensureStore(deviceId).resetDailyIfNeeded(now);
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
