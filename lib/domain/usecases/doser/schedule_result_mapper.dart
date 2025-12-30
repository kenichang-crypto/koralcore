import '../../../data/ble/response/ble_response.dart';

import '../../../app/common/app_error_code.dart';
import '../../../app/common/app_error_mapper.dart';

/// ScheduleResultMapper
///
/// Produces canonical `AppErrorCode`s for scheduling flows.
///
/// PARITY: Corresponds to reef-b-app's error mapping:
/// - CommandManager.parseCommand() maps BLE response codes to COMMAND_STATUS
/// - COMMAND_STATUS: SUCCESS (0x01), FAILED (0x00), START (0x01), END (0x02)
/// - ViewModels convert status to user-facing messages via string resources
class ScheduleResultMapper {
  final AppErrorMapper appErrorMapper;

  const ScheduleResultMapper({required this.appErrorMapper});

  AppErrorCode fromBleResponse(BleResponse response) {
    return appErrorMapper.fromBleResponse(response);
  }

  AppErrorCode guardNotSupported() {
    return appErrorMapper.notSupported();
  }

  AppErrorCode transportFailure() {
    return appErrorMapper.transportFailure();
  }

  AppErrorCode unknownFailure() {
    return appErrorMapper.unknown();
  }
}
