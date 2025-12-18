import '../common/app_error_code.dart';
import '../common/app_error_mapper.dart';

/// Maps internal errors to canonical LED schedule result codes.
class LedScheduleResultMapper {
  final AppErrorMapper appErrorMapper;

  const LedScheduleResultMapper({required this.appErrorMapper});

  AppErrorCode guardNotSupported() {
    return appErrorMapper.notSupported();
  }

  AppErrorCode unknownFailure() {
    return appErrorMapper.unknown();
  }
}
