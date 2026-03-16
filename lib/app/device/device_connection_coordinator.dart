import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../data/ble/ble_adapter.dart';
import '../../data/ble/dosing/dosing_command_builder.dart';
import '../../data/ble/transport/ble_transport_models.dart';
import '../../data/ble/ble_notify_bus.dart';
import '../../data/ble/platform_channels/ble_notify_packet.dart';
import '../../debug/runtime_logger.dart';
import '../../platform/contracts/device_repository.dart';
import 'initialize_device_usecase.dart';

/// Coordinator that enforces the "Reconnect => Reinitialize" semantic rule.
///
/// Responsibilities:
/// 1. Listen to native connection state changes.
/// 2. On transition to Connected: Force trigger InitializeDeviceUseCase.
/// 3. Prevent re-entrancy (ignore if init is already in flight).
/// 4. On Init failure: Ensure device returns to Disconnected state.
/// ## KC-A-FINAL: Lifecycle Invariant Documentation
/// This coordinator enforces a critical lifecycle invariant: device initialization
/// is SOLELY triggered by a state transition from `Disconnected` to `Connected`.
///
/// ### Why is this the sole trigger?
/// 1.  **Guarantees Freshness**: Initialization involves reading device-side state
///     (capabilities, product info). Tying it to the connection event ensures
///     this data is fresh at the start of every session.
/// 2.  **Enforces Reconnect Semantics**: A `Disconnected` -> `Connected` edge IS a
///     reconnect event. Forcing re-initialization prevents the app from using
///     stale context from a previous session.
/// 3.  **Prevents Bypass**: There is no other public entry point to trigger
///     initialization. This prevents other parts of the app from accidentally
///     or intentionally creating a "ready" state without going through the
///     canonical connection flow.
///
/// Any future refactoring (e.g., moving to a native-managed lifecycle) MUST
/// preserve this invariant.
class DeviceConnectionCoordinator {
  final Stream<BleConnectionState> connectionStream;
  final InitializeDeviceUseCase initializeDeviceUseCase;
  final DeviceRepository deviceRepository;
  final BleAdapter bleAdapter;
  final DosingCommandBuilder dosingCommandBuilder;

  StreamSubscription<BleConnectionState>? _subscription;
  final Map<String, bool> _lastConnectionState = {};
  final Set<String> _initInFlight = {};
  final Map<String, bool> _lifecycleStarted = {};
  final Map<String, StreamSubscription<BleNotifyPacket>>
  _pendingNotificationSubscriptions = {};
  static const Duration _notificationReadyTimeout = Duration(seconds: 8);

  DeviceConnectionCoordinator({
    required this.connectionStream,
    required this.initializeDeviceUseCase,
    required this.deviceRepository,
    required this.bleAdapter,
    required this.dosingCommandBuilder,
  });

  void start() {
    _subscription?.cancel();
    _subscription = connectionStream.listen(_handleConnectionState);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleConnectionState(BleConnectionState state) async {
    final String? deviceId = state.deviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }

    final bool isConnected = state.isConnected;
    final bool wasConnected = _lastConnectionState[deviceId] ?? false;
    _lastConnectionState[deviceId] = isConnected;

    // KC-A3-Final-2: Define reconnect condition
    // if previousState == Disconnected (false/null)
    //    and newState == Connected
    // then this is a RECONNECT (or fresh connect)
    if (isConnected && !wasConnected) {
      if (_lifecycleStarted[deviceId] == true) {
        return;
      }
      _log('BLE_LIFECYCLE_START', 'Starting lifecycle for $deviceId');
      // #region agent log
      unawaited(
        appendRuntimeLog(
          hypothesisId: 'H1',
          location: 'DeviceConnectionCoordinator._handleConnectionState',
          message: 'connection_state_change',
          data: {'deviceId': deviceId, 'wasConnected': wasConnected},
        ),
      );
      // #endregion
      await deviceRepository.updateDeviceState(deviceId, 'connected');
      if (bleAdapter.isNotificationReady(deviceId)) {
        await _onDeviceConnected(deviceId);
      } else {
        _awaitNotificationReady(deviceId);
      }
    } else if (!isConnected) {
      _pendingNotificationSubscriptions.remove(deviceId)?.cancel();
      _lifecycleStarted[deviceId] = false;
      if (wasConnected) {
        bleAdapter.clearQueue(deviceId: deviceId);
      }
      // Handle disconnect if needed (clearing in-flight is handled in _onDeviceConnected's finally,
      // but we should also ensure we don't hold stale state if a disconnect happens externally)
      // However, the critical path is the Reconnect -> Init.
      // We let the init process finish or fail naturally, but strictly speaking,
      // if we disconnect during init, the init will likely fail.
    }
  }

  Future<void> _awaitNotificationReady(String deviceId) {
    if (bleAdapter.isNotificationReady(deviceId)) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _pendingNotificationSubscriptions.remove(deviceId)?.cancel();
    Timer fallbackTimer = Timer(_notificationReadyTimeout, () {
      if (!completer.isCompleted) {
        _pendingNotificationSubscriptions.remove(deviceId)?.cancel();
        debugPrint(
          '[DeviceConnectionCoordinator] notification ready fallback triggered for $deviceId',
        );
        completer.complete();
      }
    });
    _pendingNotificationSubscriptions[deviceId] = BleNotifyBus.instance.stream
        .listen((BleNotifyPacket packet) {
          if (packet.deviceId != deviceId) {
            return;
          }
          _pendingNotificationSubscriptions.remove(deviceId)?.cancel();
          if (bleAdapter.isNotificationReady(deviceId)) {
            fallbackTimer.cancel();
            if (!completer.isCompleted) {
              completer.complete();
            }
            // #region agent log
            unawaited(
              appendRuntimeLog(
                hypothesisId: 'H1',
                location: 'DeviceConnectionCoordinator._awaitNotificationReady',
                message: 'notification_ready',
                data: {'deviceId': deviceId},
              ),
            );
            // #endregion
          }
        });
    return completer.future;
  }

  Future<void> _onDeviceConnected(String deviceId) async {
    _lifecycleStarted[deviceId] = true;
    // KC-A3-Final-5: Prevent re-entrancy
    if (_initInFlight.contains(deviceId)) {
      debugPrint(
        '[DeviceConnectionCoordinator] Init already in flight for $deviceId. Ignoring.',
      );
      return;
    }

    try {
      if (!bleAdapter.isNotificationReady(deviceId)) {
        // #region agent log
        unawaited(
          appendRuntimeLog(
            hypothesisId: 'H2',
            location: 'DeviceConnectionCoordinator._onDeviceConnected',
            message: 'waiting_for_notifications',
            data: {'deviceId': deviceId},
          ),
        );
        // #endregion
        await _awaitNotificationReady(deviceId);
      }
      _initInFlight.add(deviceId);
      debugPrint(
        '[DeviceConnectionCoordinator] Triggering initialization for $deviceId',
      );
      // #region agent log
      unawaited(
        appendRuntimeLog(
          hypothesisId: 'H3',
          location: 'DeviceConnectionCoordinator._onDeviceConnected',
          message: 'initialization_started',
          data: {'deviceId': deviceId},
        ),
      );
      // #endregion
      // KC-A3-Final-3: Send lifecycle time correction before initialization
      _log('SEND 0x60 TIME_CORRECTION', 'Device $deviceId');
      await _sendTimeCorrection(deviceId);

      // KC-A3-Final-3: Force trigger InitializeDeviceUseCase
      await initializeDeviceUseCase.execute(deviceId: deviceId);

      debugPrint(
        '[DeviceConnectionCoordinator] Initialization successful for $deviceId',
      );
    } catch (e) {
      debugPrint(
        '[DeviceConnectionCoordinator] Initialization failed for $deviceId: $e',
      );

      // KC-A3-Final-4: Initialization failure handling
      // Must return to Disconnected.
      try {
        // We disconnect the BLE link to ensure state consistency.
        // If we just set the app state to disconnected, the native layer might still be connected.
        // Calling disconnect() on the repository should trigger the native disconnect.
        await deviceRepository.disconnect(deviceId);
        await deviceRepository.updateDeviceState(deviceId, 'disconnected');
      } catch (disconnectError) {
        debugPrint(
          '[DeviceConnectionCoordinator] Failed to disconnect after init failure: $disconnectError',
        );
      }
    } finally {
      _initInFlight.remove(deviceId);
    }
  }

  Future<void> _sendTimeCorrection(String deviceId) async {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1 = Monday
    final Uint8List command = dosingCommandBuilder.timeCorrection(
      year: now.year,
      month: now.month,
      day: now.day,
      hour: now.hour,
      minute: now.minute,
      second: now.second,
      weekday: weekday,
    );
    try {
      await bleAdapter.writeBytes(deviceId: deviceId, data: command);
    } catch (error) {
      debugPrint(
        '[DeviceConnectionCoordinator] Time correction failed: $error',
      );
    }
  }

  void _log(String event, String message) {
    developer.log(message, name: 'DeviceConnectionCoordinator.$event');
  }
}
