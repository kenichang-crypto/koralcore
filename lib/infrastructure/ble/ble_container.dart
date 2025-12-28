library;

import 'dart:async';

import 'ble_adapter.dart';
import 'transport/ble_transport_models.dart';

/// Container for managing multiple BLE device connections.
/// 
/// PARITY: Similar to reef-b-app's BleContainer, which manages
/// multiple BLEManager instances (one per device MAC address).
/// 
/// In koralcore, we use a single BleAdapter instance that supports
/// multiple devices via deviceId, but this container provides a unified
/// interface for device lifecycle management.
class BleContainer {
  BleContainer._();

  static BleContainer? _instance;

  /// Get the singleton instance of BleContainer.
  static BleContainer getInstance() {
    _instance ??= BleContainer._();
    return _instance!;
  }

  final Map<String, _DeviceConnection> _connections = <String, _DeviceConnection>{};
  BleAdapter? _defaultAdapter;

  /// Set the default BLE adapter for the container.
  /// This adapter will be used for all device operations.
  void setDefaultAdapter(BleAdapter adapter) {
    _defaultAdapter = adapter;
  }

  /// Get the default BLE adapter.
  BleAdapter? getDefaultAdapter() => _defaultAdapter;

  /// Check if a device connection exists.
  /// 
  /// PARITY: Matches reef-b-app's `isExistBleManager(macAddress: String)`.
  bool exists(String deviceId) {
    return _connections.containsKey(deviceId);
  }

  /// Check if a device is connected.
  /// 
  /// PARITY: Matches reef-b-app's `isConnected(macAddress: String)`.
  Future<bool> isConnected(String deviceId) async {
    final connection = _connections[deviceId];
    if (connection == null) {
      return false;
    }
    // Check connection state via adapter
    final adapter = _defaultAdapter;
    if (adapter == null) {
      return false;
    }
    // Note: This is a simplified check. In a full implementation,
    // we would track connection state more explicitly.
    return true;
  }

  /// Register a new device connection.
  /// 
  /// PARITY: Matches reef-b-app's `new(macAddress: String)`.
  void registerDevice(String deviceId) {
    if (_connections.containsKey(deviceId)) {
      return; // Already registered
    }
    _connections[deviceId] = _DeviceConnection(deviceId: deviceId);
  }

  /// Unregister a device connection.
  /// 
  /// PARITY: Matches reef-b-app's `delete(macAddress: String)`.
  void unregisterDevice(String deviceId) {
    final connection = _connections.remove(deviceId);
    connection?.dispose();
  }

  /// Get the BLE adapter for a specific device.
  /// 
  /// PARITY: Matches reef-b-app's `getBleManager(macAddress: String)`.
  /// In koralcore, we return the default adapter since we use a single
  /// adapter instance for all devices.
  BleAdapter? getAdapter(String deviceId) {
    if (!_connections.containsKey(deviceId)) {
      return null;
    }
    return _defaultAdapter;
  }

  /// Disconnect all devices.
  /// 
  /// PARITY: Matches reef-b-app's `disconnectAll()`.
  Future<void> disconnectAll() async {
    final adapter = _defaultAdapter;
    if (adapter == null) {
      return;
    }

    // Disconnect all registered devices
    final deviceIds = List<String>.from(_connections.keys);
    for (final deviceId in deviceIds) {
      try {
        // Note: In a full implementation, we would call adapter.disconnect(deviceId)
        // For now, we just clear the connection tracking
        _connections.remove(deviceId);
      } catch (e) {
        // Ignore errors during disconnect
      }
    }
  }

  /// Get all registered device IDs.
  List<String> getRegisteredDevices() {
    return List<String>.unmodifiable(_connections.keys);
  }

  /// Clear all connections (for cleanup).
  void clear() {
    for (final connection in _connections.values) {
      connection.dispose();
    }
    _connections.clear();
  }
}

/// Internal class to track device connection state.
class _DeviceConnection {
  _DeviceConnection({required this.deviceId});

  final String deviceId;
  StreamSubscription<BleConnectionState>? _connectionSubscription;

  void dispose() {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }
}

