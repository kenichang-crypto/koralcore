library;

import '../../domain/doser_dosing/today_dose_summary.dart';
import '../../domain/doser_schedule/dosing_schedule_summary.dart';

export '../../domain/doser_dosing/today_dose_summary.dart';
export '../../domain/doser_schedule/dosing_schedule_summary.dart';

/// Identifiers for the legacy (0x7A) and modern (0x7E) dosing read opcodes.
enum TodayDoseReadOpcode { legacy0x7A, modern0x7E }

/// Platform port describing how the application layer fetches dosing data.
abstract class DosingPort {
  /// Reads the current-day dosing totals for a given pump head.
  Future<TodayDoseSummary?> readTodayTotals({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  });

  /// Reads a lightweight summary of the active dosing schedule for a head.
  Future<DosingScheduleSummary?> readScheduleSummary({
    required String deviceId,
    required int pumpId,
  });
}
