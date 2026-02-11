library;

import 'dart:async';

import '../../domain/device/capability_set.dart';
import '../../domain/device/device_context.dart';
import '../../domain/device/device_product.dart';
import '../../domain/device/firmware_version.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

/// Holds the active device context for the application layer.
///
/// ## KC-A-FINAL: Lifecycle State
/// This session object manages the lifecycle state of the currently selected device.
/// A device can be "selected" but not "ready".
///
/// - **Selected (Switched)**: A device ID has been chosen, but its full context
///   (product, capabilities) has not been loaded. The state is `_isReady = false`.
///   Any attempt to access the full context will fail.
///
/// - **Ready (Started)**: The device has been fully initialized via
///   `InitializeDeviceUseCase`, and its complete `DeviceContext` is available.
///   The state is `_isReady = true`.
class CurrentDeviceSession {
  DeviceContext? _context;
  bool _isReady = false;

  final StreamController<bool> _isReadyController =
      StreamController<bool>.broadcast();

  Stream<bool> get isReadyStream => _isReadyController.stream;
  bool get isReady => _isReady;

  DeviceContext? get context => _context;

  DeviceContext get requireContext {
    final ctx = _context;
    if (ctx == null) {
      throw AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'No device selected. Switch to a device first.',
      );
    }
    if (!_isReady) {
      throw AppError(
        code: AppErrorCode.deviceNotReady,
        message:
            'Device is selected but not ready. Run InitializeDeviceUseCase first.',
      );
    }
    return ctx;
  }

  /// Switches to a new device, marking it as "selected but not ready".
  /// This creates a partial context containing only the device ID.
  void switchTo(String deviceId) {
    _context = DeviceContext(
      deviceId: deviceId,
      product: DeviceProduct.unknown, // Not yet resolved
      firmware: const FirmwareVersion(''), // Not yet resolved
      capabilities: const CapabilitySet.empty(), // Not yet resolved
    );
    _isReady = false;
    _isReadyController.add(false);
  }

  /// Promotes the current session to "ready" with a full device context.
  /// This should only be called by `InitializeDeviceUseCase`.
  void start(DeviceContext context) {
    // Ensure we are promoting the same device that was switched to.
    if (_context?.deviceId != context.deviceId && _context != null) {
      throw AppError(
        code: AppErrorCode.deviceMismatch,
        message:
            'Cannot start session for ${context.deviceId} because ${_context!.deviceId} is the one currently selected.',
      );
    }
    _context = context;
    _isReady = true;
    _isReadyController.add(true);
  }

  /// Clears the session entirely, typically on disconnect.
  void clear() {
    _context = null;
    _isReady = false;
    _isReadyController.add(false);
  }

  /// Dispose resources.
  void dispose() {
    _isReadyController.close();
  }
}
