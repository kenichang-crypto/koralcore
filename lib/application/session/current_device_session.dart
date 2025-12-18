library;

import '../../domain/device/device_context.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

/// Holds the active device context for the application layer.
class CurrentDeviceSession {
  DeviceContext? _context;

  DeviceContext? get context => _context;

  DeviceContext get requireContext {
    final ctx = _context;
    if (ctx == null) {
      throw AppError(
        code: AppErrorCode.noActiveDevice,
        message:
            'No active device session. Initialize a device before using device features.',
      );
    }
    return ctx;
  }

  void start(DeviceContext context) {
    _context = context;
  }

  void clear() {
    _context = null;
  }
}
