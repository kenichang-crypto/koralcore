import '../../data/ble/response/ble_response.dart';

import '../common/app_error_code.dart';
import '../common/app_error_mapper.dart';

/// Produces canonical `AppErrorCode`s for scheduling flows.
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
