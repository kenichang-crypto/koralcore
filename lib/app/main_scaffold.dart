import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/device/presentation/controllers/device_list_controller.dart';
import '../core/ble/ble_readiness_controller.dart';
import 'main_shell_page.dart';

/// Main scaffold matching reef-b-app's MainActivity.
///
/// PARITY: Mirrors reef-b-app's MainActivity.onCreate() behavior:
/// - Automatically requests BLE permissions on startup
/// - Starts BLE scanning when permissions are granted and BLE is ready
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  BleReadinessController? _bleController;
  DeviceListController? _deviceListController;
  bool _hasRequestedPermissions = false;
  bool _hasStartedScan = false;
  bool _wasReady = false;

  @override
  void initState() {
    super.initState();
    // PARITY: reef-b-app MainActivity.onCreate() calls checkBlePermission() immediately
    // Request permissions after first frame (similar to reef-b-app's onCreate flow)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeAndRequestPermissions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get controllers from context
    if (_bleController == null) {
      _bleController = context.read<BleReadinessController>();
      _wasReady = _bleController!.snapshot.isReady;
      _bleController!.addListener(_handleBleStateChange);
    }
    if (_deviceListController == null) {
      _deviceListController = context.read<DeviceListController>();
    }
  }

  @override
  void dispose() {
    _bleController?.removeListener(_handleBleStateChange);
    super.dispose();
  }

  /// Initialize and request BLE permissions.
  /// PARITY: reef-b-app MainActivity.onCreate() -> checkBlePermission()
  Future<void> _initializeAndRequestPermissions() async {
    if (_hasRequestedPermissions || _bleController == null) return;
    _hasRequestedPermissions = true;

    // PARITY: reef-b-app checkBlePermission() - requests permissions immediately
    // If permissions are not granted, request them
    if (!_bleController!.snapshot.isReady) {
      await _bleController!.requestPermissions();
    }

    // Check initial state (in case permissions were already granted)
    _checkAndStartScan();
  }

  /// Handle BLE state changes and start scan when ready.
  /// PARITY: reef-b-app checkBlePermission() callback -> BleContainer.scanLeDevice()
  void _handleBleStateChange() {
    if (!mounted || _bleController == null || _deviceListController == null)
      return;

    final nextReady = _bleController!.snapshot.isReady;

    // PARITY: reef-b-app only starts scan after permissions are granted and BLE is ready
    if (nextReady && !_wasReady) {
      // BLE just became ready, start scanning
      _checkAndStartScan();
    } else if (!nextReady) {
      // Reset scan flag if BLE becomes unavailable
      _hasStartedScan = false;
    }

    _wasReady = nextReady;
  }

  /// Check if BLE is ready and start scanning if not already started.
  /// PARITY: BleContainer.getInstance().getBleManager().scanLeDevice()
  void _checkAndStartScan() {
    if (_hasStartedScan ||
        _bleController == null ||
        _deviceListController == null)
      return;

    if (_bleController!.snapshot.isReady) {
      _hasStartedScan = true;
      // PARITY: BleContainer.getInstance().getBleManager().scanLeDevice()
      // Start BLE scanning automatically when ready
      _deviceListController!.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI parity for MainActivity is implemented in MainShellPage.
    // Keep MainScaffold as the app entry point to preserve existing bootstrapping logic.
    return const MainShellPage();
  }
}

// Navigation UI moved into MainShellPage.
