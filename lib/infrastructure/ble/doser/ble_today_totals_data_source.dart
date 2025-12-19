library;

import 'dart:typed_data';

import '../../../platform/contracts/dosing_port.dart';
import '../../ble/ble_adapter.dart';
import '../../ble/response/ble_error_code.dart';
import '../../ble/transport/ble_transport_models.dart';
import 'today_totals_data_source.dart';

/// Executes BLE read opcodes (0x7E / 0x7A) via the hardened adapter queue and
/// returns the raw payload for repository-level parsing.
class BleTodayTotalsDataSource implements TodayTotalsDataSource {
  final BleAdapter bleAdapter;
  final BleWriteOptions readOptions;

  const BleTodayTotalsDataSource({
    required this.bleAdapter,
    BleWriteOptions? readOptions,
  }) : readOptions = readOptions ?? const BleWriteOptions();

  @override
  Future<TodayTotalsPacket?> read({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  }) async {
    final Uint8List request = _buildRequest(opcode: opcode, pumpId: pumpId);

    List<int>? payload;
    try {
      payload = await bleAdapter.readBytes(
        deviceId: deviceId,
        data: request,
        options: readOptions,
      );
    } on BleCommandRejectedException catch (error) {
      if (error.errorCode == BleErrorCode.notSupported) {
        throw const TodayTotalsDataSourceException(
          TodayTotalsDataSourceError.notSupported,
          'Firmware rejected opcode with not-supported response.',
        );
      }
      throw TodayTotalsDataSourceException(
        TodayTotalsDataSourceError.transport,
        error.message,
      );
    } on BleWriteTimeoutException catch (error) {
      throw TodayTotalsDataSourceException(
        TodayTotalsDataSourceError.transport,
        error.message,
      );
    } on BleWriteException catch (error) {
      throw TodayTotalsDataSourceException(
        TodayTotalsDataSourceError.transport,
        error.message,
      );
    } catch (error) {
      throw TodayTotalsDataSourceException(
        TodayTotalsDataSourceError.unknown,
        'BLE read failed: $error',
      );
    }

    if (payload == null || payload.isEmpty) {
      return null;
    }

    return TodayTotalsPacket(payload: payload);
  }

  Uint8List _buildRequest({
    required TodayDoseReadOpcode opcode,
    required int pumpId,
  }) {
    final int opcodeByte = opcode == TodayDoseReadOpcode.modern0x7E
        ? 0x7E
        : 0x7A;
    final int normalizedPumpId = pumpId.clamp(0, 0xFF).toInt();
    // Firmware expects opcode + 1-byte payload (pump id). If additional bytes
    // such as checksum become required, extend this builder accordingly.
    return Uint8List.fromList(<int>[opcodeByte, normalizedPumpId]);
  }
}
