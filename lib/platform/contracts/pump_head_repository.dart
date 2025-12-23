library;

import '../../domain/doser_dosing/pump_head.dart';

/// In-memory representation of pump head metadata per device.
abstract class PumpHeadRepository {
  const PumpHeadRepository();

  Future<List<PumpHead>> listPumpHeads(String deviceId);

  Stream<List<PumpHead>> observePumpHeads(String deviceId);

  @Deprecated('Use observePumpHeads')
  Stream<List<PumpHead>> observeHeads(String deviceId) =>
      observePumpHeads(deviceId);

  Future<PumpHead?> getPumpHead(String deviceId, String headId);

  @Deprecated('Use getPumpHead')
  Future<PumpHead?> getHead(String deviceId, int pumpId) =>
      getPumpHead(deviceId, headIdFromPumpId(pumpId));

  Future<void> savePumpHeads(String deviceId, List<PumpHead> heads);

  @Deprecated('Use savePumpHeads')
  Future<void> saveHeads(String deviceId, List<PumpHead> heads) =>
      savePumpHeads(deviceId, heads);

  Future<void> updateTotals({
    required String deviceId,
    required String headId,
    double? totalMl,
    DateTime? lastDoseAt,
  });

  Future<void> updateStatus({
    required String deviceId,
    required String headId,
    required PumpHeadStatus status,
  });

  Future<void> resetDailyIfNeeded({
    required String deviceId,
    required DateTime now,
  });

  static String headIdFromPumpId(int pumpId) {
    final int index = pumpId.clamp(1, 26) - 1;
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  static int pumpIdFromHeadId(String headId) {
    if (headId.isEmpty) {
      return 1;
    }
    final int value = headId.trim().toUpperCase().codeUnitAt(0) - 64;
    return value < 1 ? 1 : value;
  }
}
