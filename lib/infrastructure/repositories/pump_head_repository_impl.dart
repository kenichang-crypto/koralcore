library;

import 'dart:async';

import '../../domain/doser_dosing/pump_head.dart';
import '../../platform/contracts/pump_head_repository.dart';

class PumpHeadRepositoryImpl extends PumpHeadRepository {
  final Map<String, _PumpHeadStore> _stores = {};

  PumpHeadRepositoryImpl();

  @override
  Future<List<PumpHead>> listHeads(String deviceId) async {
    return _ensureStore(deviceId).heads;
  }

  @override
  Stream<List<PumpHead>> observeHeads(String deviceId) {
    return _ensureStore(deviceId).stream;
  }

  @override
  Future<PumpHead?> getHead(String deviceId, int pumpId) async {
    return _ensureStore(deviceId).headByPumpId(pumpId);
  }

  @override
  Future<void> saveHeads(String deviceId, List<PumpHead> heads) async {
    final store = _ensureStore(deviceId);
    store.setHeads(heads);
  }

  @override
  Future<void> updateTodayTotal({
    required String deviceId,
    required int pumpId,
    double? totalMl,
    DateTime? lastDoseAt,
  }) async {
    final store = _ensureStore(deviceId);
    store.updateTotals(
      pumpId: pumpId,
      totalMl: totalMl,
      lastDoseAt: lastDoseAt,
    );
  }

  @override
  Future<void> updateStatus({
    required String deviceId,
    required int pumpId,
    required PumpHeadStatus status,
  }) async {
    final store = _ensureStore(deviceId);
    store.updateStatus(pumpId: pumpId, status: status);
  }

  _PumpHeadStore _ensureStore(String deviceId) {
    return _stores.putIfAbsent(deviceId, () => _PumpHeadStore(deviceId));
  }
}

class _PumpHeadStore {
  final String deviceId;
  final StreamController<List<PumpHead>> _controller;
  List<PumpHead> _heads = const [];

  _PumpHeadStore(this.deviceId)
    : _controller = StreamController<List<PumpHead>>.broadcast();

  List<PumpHead> get heads => _heads;
  Stream<List<PumpHead>> get stream => _controller.stream;

  PumpHead? headByPumpId(int pumpId) {
    try {
      return _heads.firstWhere((element) => element.pumpId == pumpId);
    } catch (_) {
      return null;
    }
  }

  void setHeads(List<PumpHead> next) {
    _heads = List.unmodifiable(next);
    _controller.add(_heads);
  }

  void updateTotals({
    required int pumpId,
    double? totalMl,
    DateTime? lastDoseAt,
  }) {
    bool changed = false;
    final List<PumpHead> updated = _heads
        .map((head) {
          if (head.pumpId != pumpId) {
            return head;
          }
          changed = true;
          return head.copyWith(
            todayDispensedMl: totalMl ?? head.todayDispensedMl,
            lastDoseAt: lastDoseAt ?? head.lastDoseAt,
          );
        })
        .toList(growable: false);

    if (changed) {
      setHeads(updated);
    }
  }

  void updateStatus({required int pumpId, required PumpHeadStatus status}) {
    bool changed = false;
    final List<PumpHead> updated = _heads
        .map((head) {
          if (head.pumpId != pumpId) {
            return head;
          }
          changed = head.status != status;
          return head.copyWith(status: status);
        })
        .toList(growable: false);

    if (changed) {
      setHeads(updated);
    }
  }
}
