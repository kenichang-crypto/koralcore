import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/device_repository.dart';
import 'initialize_device_usecase.dart';

/// Coordinator that enforces the "Reconnect => Reinitialize" semantic rule.
///
/// Responsibilities:
/// 1. Listen to native connection state changes.
/// 2. On transition to Connected: Force trigger InitializeDeviceUseCase.
/// 3. Prevent re-entrancy (ignore if init is already in flight).
/// 4. On Init failure: Ensure device returns to Disconnected state.
class DeviceConnectionCoordinator {
  final Stream<BleConnectionState> connectionStream;
  final InitializeDeviceUseCase initializeDeviceUseCase;
  final DeviceRepository deviceRepository;

  StreamSubscription<BleConnectionState>? _subscription;
  final Map<String, bool> _lastConnectionState = {};
  final Set<String> _initInFlight = {};

  DeviceConnectionCoordinator({
    required this.connectionStream,
    required this.initializeDeviceUseCase,
    required this.deviceRepository,
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
      await _onDeviceConnected(deviceId);
    } else if (!isConnected) {
       // Handle disconnect if needed (clearing in-flight is handled in _onDeviceConnected's finally,
       // but we should also ensure we don't hold stale state if a disconnect happens externally)
       // However, the critical path is the Reconnect -> Init.
       // We let the init process finish or fail naturally, but strictly speaking,
       // if we disconnect during init, the init will likely fail.
    }
  }

  Future<void> _onDeviceConnected(String deviceId) async {
    // KC-A3-Final-5: Prevent re-entrancy
    if (_initInFlight.contains(deviceId)) {
      debugPrint('[DeviceConnectionCoordinator] Init already in flight for $deviceId. Ignoring.');
      return;
    }

    try {
      _initInFlight.add(deviceId);
      debugPrint('[DeviceConnectionCoordinator] Triggering initialization for $deviceId');

      // KC-A3-Final-3: Force trigger InitializeDeviceUseCase
      await initializeDeviceUseCase.execute(deviceId: deviceId);
      
      debugPrint('[DeviceConnectionCoordinator] Initialization successful for $deviceId');
    } catch (e) {
      debugPrint('[DeviceConnectionCoordinator] Initialization failed for $deviceId: $e');
      
      // KC-A3-Final-4: Initialization failure handling
      // Must return to Disconnected.
      try {
        // We disconnect the BLE link to ensure state consistency.
        // If we just set the app state to disconnected, the native layer might still be connected.
        // Calling disconnect() on the repository should trigger the native disconnect.
        await deviceRepository.disconnect(deviceId);
        await deviceRepository.updateDeviceState(deviceId, 'disconnected');
      } catch (disconnectError) {
        debugPrint('[DeviceConnectionCoordinator] Failed to disconnect after init failure: $disconnectError');
      }
    } finally {
      _initInFlight.remove(deviceId);
    }
  }
}
