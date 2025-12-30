import 'ble_error_code.dart';
import 'ble_response.dart';

/// Stateless parser that converts raw BLE ack payloads into domain-neutral
/// success/failure responses.
class BleResponseParser {
  const BleResponseParser._();

  static BleResponse parse(List<int> data) {
    if (data.isEmpty) {
      return const BleFailure(BleErrorCode.unknown);
    }

    // TODO: Identify exact index of the status byte per BLE protocol.
    final int statusByte = data.first;

    // TODO: Map status byte values to semantic error codes.
    final BleErrorCode code = _mapStatusByte(statusByte);

    if (code == BleErrorCode.ok) {
      return const BleSuccess();
    }

    return BleFailure(code);
  }

  static BleErrorCode _mapStatusByte(int status) {
    switch (status) {
      // TODO: Replace placeholder mappings with real status values.
      case 0x00:
        return BleErrorCode.ok;
      case 0x01:
        return BleErrorCode.busy;
      case 0x02:
        return BleErrorCode.invalidParam;
      case 0x03:
        return BleErrorCode.notSupported;
      case 0x04:
        return BleErrorCode.checksumError;
      default:
        return BleErrorCode.unknown;
    }
  }
}
