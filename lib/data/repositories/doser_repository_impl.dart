library;

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../platform/contracts/dosing_port.dart';
import '../ble/doser/today_totals_data_source.dart';

/// Repository responsible for executing BLE read opcodes for dosing data.
class DoserRepositoryImpl implements DosingPort {
  final TodayTotalsDataSource todayTotalsDataSource;

  const DoserRepositoryImpl({TodayTotalsDataSource? todayTotalsDataSource})
    : todayTotalsDataSource =
          todayTotalsDataSource ?? const NoopTodayTotalsDataSource();

  @override
  Future<TodayDoseSummary?> readTodayTotals({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  }) async {
    TodayTotalsPacket? packet;
    try {
      packet = await todayTotalsDataSource.read(
        deviceId: deviceId,
        pumpId: pumpId,
        opcode: opcode,
      );
    } on TodayTotalsDataSourceException catch (error) {
      throw _mapDataSourceError(error);
    }

    if (packet == null || packet.bytes.isEmpty) {
      return null;
    }

    try {
      return _TodayTotalsParser.parse(packet.bytes, opcode);
    } on TodayTotalsParseException catch (error) {
      throw AppError(code: AppErrorCode.transportError, message: error.message);
    }
  }

  @override
  Future<DosingScheduleSummary?> readScheduleSummary({
    required String deviceId,
    required int pumpId,
  }) async {
    return null;
  }

  AppError _mapDataSourceError(TodayTotalsDataSourceException error) {
    switch (error.reason) {
      case TodayTotalsDataSourceError.notSupported:
        return AppError(
          code: AppErrorCode.notSupported,
          message: error.message,
        );
      case TodayTotalsDataSourceError.transport:
        return AppError(
          code: AppErrorCode.transportError,
          message: error.message,
        );
      case TodayTotalsDataSourceError.unknown:
        return AppError(
          code: AppErrorCode.unknownError,
          message: error.message,
        );
    }
  }
}

class _TodayTotalsParser {
  static const int _bytesPerField = 2;

  static TodayDoseSummary parse(List<int> payload, TodayDoseReadOpcode opcode) {
    if (payload.length < _bytesPerField) {
      throw TodayTotalsParseException('Payload missing total dose data.');
    }

    final double totalMl = _readValue(payload, 0, opcode, requiredField: true)!;
    final double? scheduledMl = _readValue(payload, 2, opcode);
    final double? manualMl = _readValue(payload, 4, opcode);

    return TodayDoseSummary(
      totalMl: totalMl,
      scheduledMl: scheduledMl,
      manualMl: manualMl,
    );
  }

  static double? _readValue(
    List<int> payload,
    int offset,
    TodayDoseReadOpcode opcode, {
    bool requiredField = false,
  }) {
    final int end = offset + _bytesPerField;
    if (payload.length < end) {
      if (requiredField) {
        throw TodayTotalsParseException('Missing bytes at offset $offset.');
      }
      return null;
    }

    final int raw = payload[offset] | (payload[offset + 1] << 8);
    final double value = opcode == TodayDoseReadOpcode.modern0x7E
        ? raw / 10.0
        : raw.toDouble();
    return value;
  }
}

class TodayTotalsParseException implements Exception {
  final String message;

  const TodayTotalsParseException(this.message);

  @override
  String toString() => 'TodayTotalsParseException: $message';
}
