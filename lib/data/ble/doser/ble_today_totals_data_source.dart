library;

import 'dart:typed_data';

import '../../../platform/contracts/dosing_port.dart';
import '../../ble/response/ble_error_code.dart';
import '../../ble/transport/ble_read_transport.dart';
import '../../ble/transport/ble_transport_models.dart';
import 'today_totals_data_source.dart';

/// Executes BLE read opcodes (0x7E / 0x7A) via the hardened adapter queue and
/// returns the raw payload for repository-level parsing.
class BleTodayTotalsDataSource implements TodayTotalsDataSource {
  final BleReadTransport _transport;
  final BleWriteOptions readOptions;

  const BleTodayTotalsDataSource({
    required BleReadTransport transport,
    BleWriteOptions? readOptions,
  }) : _transport = transport,
       readOptions = readOptions ?? const BleWriteOptions();

  @override
  Future<TodayTotalsPacket?> read({
    required String deviceId,
    required int pumpId,
    required TodayDoseReadOpcode opcode,
  }) async {
    final Uint8List request = _buildRequest(opcode: opcode, pumpId: pumpId);
    final int opcodeByte = request.isNotEmpty ? request.first : 0;

    Uint8List? payload;
    try {
      payload = await _transport.read(
        deviceId: deviceId,
        opcode: opcodeByte,
        payload: request,
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
    // PARITY: reef-b-app CommandManager.getDropGetTotalDropCommand() and
    // getDropGetTotalDropDecimalCommand() both use dataSum() for checksum.
    // Format: [opcode, length, pumpId, checksum]
    // Template: [0x7A, 0x01, 0x00, 0x00] or [0x7E, 0x01, 0x00, 0x00]
    final int opcodeByte = opcode == TodayDoseReadOpcode.modern0x7E
        ? 0x7E
        : 0x7A;
    final int length = 0x01; // Payload length (1 byte: pumpId)
    final int normalizedPumpId = pumpId.clamp(0, 0xFF).toInt();
    
    // PARITY: dataSum() calculates: sum of bytes from index 2 to array.size
    // For command template [0x7A, 0x01, 0x00, 0x00]:
    //   After setting command[2] = pumpId, we have [0x7A, 0x01, pumpId, 0x00]
    //   dataSum() = copyOfRange(2, 4) = [pumpId, 0x00]
    //   sum = pumpId + 0 = pumpId
    final int checksum = normalizedPumpId & 0xFF;
    
    return Uint8List.fromList(<int>[
      opcodeByte,
      length,
      normalizedPumpId,
      checksum,
    ]);
  }
}
