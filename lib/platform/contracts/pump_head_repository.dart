library;

import '../../domain/doser_dosing/pump_head.dart';

/// In-memory representation of pump head metadata per device.
abstract class PumpHeadRepository {
  const PumpHeadRepository();

  Future<List<PumpHead>> listHeads(String deviceId);

  Stream<List<PumpHead>> observeHeads(String deviceId);

  Future<void> saveHeads(String deviceId, List<PumpHead> heads);

  Future<void> updateTodayTotal({
    required String deviceId,
    required int pumpId,
    double? totalMl,
    DateTime? lastDoseAt,
  });
}
