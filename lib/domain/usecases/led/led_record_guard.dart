library;

import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

void ensureDeviceId(String deviceId) {
  if (deviceId.isEmpty) {
    throw const AppError(
      code: AppErrorCode.noActiveDevice,
      message: 'LED records require an active device id.',
    );
  }
}

void ensureRecordId(String recordId) {
  if (recordId.isEmpty) {
    throw const AppError(
      code: AppErrorCode.invalidParam,
      message: 'A record id is required for this operation.',
    );
  }
}
