library;

import '../../../platform/contracts/dosing_port.dart';

/// Raw payload returned by firmware for a given today-totals opcode.
class TodayTotalsPacket {
  final List<int> bytes;

  TodayTotalsPacket({required List<int> payload})
    : bytes = List<int>.unmodifiable(payload);
}

/// Error reasons surfaced by the today-totals data source.
enum TodayTotalsDataSourceError { notSupported, transport, unknown }

class TodayTotalsDataSourceException implements Exception {
  final TodayTotalsDataSourceError reason;
  final String message;

  const TodayTotalsDataSourceException(
    this.reason, [
    this.message = 'Today totals read failed.',
  ]);

  @override
  String toString() =>
      'TodayTotalsDataSourceException(reason: ${reason.name}, message: $message)';
}

/// Abstraction responsible for executing BLE read commands and returning the
/// raw payload bytes for each opcode.
abstract class TodayTotalsDataSource {
  Future<TodayTotalsPacket?> read({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  });
}

/// Default implementation used until the platform adapters are wired. The
/// application treats a `null` packet as "no data / unsupported" and falls back
/// to the legacy opcode or displays placeholders.
class NoopTodayTotalsDataSource implements TodayTotalsDataSource {
  const NoopTodayTotalsDataSource();

  @override
  Future<TodayTotalsPacket?> read({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  }) async {
    return null;
  }
}
