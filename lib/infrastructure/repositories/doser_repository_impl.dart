library;

import '../../platform/contracts/dosing_port.dart';

/// Temporary repository placeholder until platform-specific BLE wiring lands.
class DoserRepositoryImpl implements DosingPort {
  const DoserRepositoryImpl();

  @override
  Future<TodayDoseSummary?> readTodayTotals({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  }) async {
    return null;
  }

  @override
  Future<DosingScheduleSummary?> readScheduleSummary({
    required String deviceId,
    required int pumpId,
  }) async {
    return null;
  }
}
