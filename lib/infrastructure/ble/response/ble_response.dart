import 'ble_error_code.dart';

/// Represents parsed BLE acknowledgements.
sealed class BleResponse {
  const BleResponse();
}

class BleSuccess extends BleResponse {
  const BleSuccess();
}

class BleFailure extends BleResponse {
  final BleErrorCode error;

  const BleFailure(this.error);
}
