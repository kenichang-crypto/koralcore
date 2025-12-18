import '../../infrastructure/ble/response/ble_error_code.dart';
import '../../infrastructure/ble/response/ble_response.dart';

import 'app_error_code.dart';

/// Centralized translator from lower-level results to `AppErrorCode`s.
class AppErrorMapper {
  const AppErrorMapper();

  AppErrorCode fromBleResponse(BleResponse response) {
    if (response is BleFailure) {
      return fromBleError(response.error);
    }

    // Unexpected success path routed through error mapping.
    return AppErrorCode.unknownError;
  }

  AppErrorCode fromBleError(BleErrorCode code) {
    switch (code) {
      case BleErrorCode.busy:
        return AppErrorCode.deviceBusy;
      case BleErrorCode.notSupported:
        return AppErrorCode.notSupported;
      case BleErrorCode.invalidParam:
        return AppErrorCode.invalidParam;
      case BleErrorCode.checksumError:
        return AppErrorCode.transportError;
      case BleErrorCode.ok:
        return AppErrorCode.unknownError;
      case BleErrorCode.unknown:
        return AppErrorCode.unknownError;
    }
  }

  AppErrorCode notSupported() => AppErrorCode.notSupported;

  AppErrorCode unknown() => AppErrorCode.unknownError;
}
