import '../../../app/common/app_error_code.dart';
import '../../../app/common/app_error_mapper.dart';

/// LedScheduleResultMapper
///
/// Maps internal errors to canonical LED schedule result codes.
///
/// PARITY: Corresponds to reef-b-app's error mapping:
/// - CommandManager.parseCommand() maps BLE response codes to COMMAND_STATUS
/// - COMMAND_STATUS: SUCCESS (0x01), FAILED (0x00)
/// - ViewModels convert status to user-facing messages via string resources
class LedScheduleResultMapper {
  final AppErrorMapper appErrorMapper;

  const LedScheduleResultMapper({required this.appErrorMapper});

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
