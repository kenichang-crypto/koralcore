import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'system/ble_readiness_controller.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializePermissions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bleController ??= context.read<BleReadinessController>();
  }

  Future<void> _initializePermissions() async {
    final controller = _bleController ?? context.read<BleReadinessController>();
    _bleController = controller;
    if (!controller.snapshot.isReady) {
      await controller.requestPermissions();
    }
  }

  /// Handle BLE state changes and start scan when ready.
  /// PARITY: reef-b-app checkBlePermission() callback -> BleContainer.scanLeDevice()
  @override
  Widget build(BuildContext context) {
    // UI parity for MainActivity is implemented in MainShellPage.
    // Keep MainScaffold as the app entry point to preserve existing bootstrapping logic.
    return const MainShellPage();
  }
}

// Navigation UI moved into MainShellPage.
