import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../shared/theme/app_colors.dart';
import '../features/device/presentation/pages/device_scan_page.dart';
import '../features/device/presentation/pages/device_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/device/presentation/controllers/device_list_controller.dart';
import '../core/ble/ble_readiness_controller.dart';
import 'navigation_controller.dart';
import 'package:koralcore/l10n/app_localizations.dart';

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
    if (!mounted || _bleController == null || _deviceListController == null) return;
    
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
    if (_hasStartedScan || _bleController == null || _deviceListController == null) return;
    
    if (_bleController!.snapshot.isReady) {
      _hasStartedScan = true;
      // PARITY: BleContainer.getInstance().getBleManager().scanLeDevice()
      // Start BLE scanning automatically when ready
      _deviceListController!.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NavigationController>();
    final l10n = AppLocalizations.of(context);
    final items = [
      _NavItem(label: l10n.tabHome, asset: 'assets/icons/icon_home.svg'),
      _NavItem(
        label: l10n.tabBluetooth,
        asset: 'assets/icons/icon_bluetooth.svg',
      ),
      _NavItem(label: l10n.tabDevice, asset: 'assets/icons/icon_device.svg'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: controller.index,
        children: const [HomePage(), DeviceScanPage(), DevicePage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.index,
        onDestinationSelected: context.read<NavigationController>().select,
        destinations: [
          for (final item in items)
            NavigationDestination(
              label: item.label,
              icon: _NavIcon(asset: item.asset, active: false),
              selectedIcon: _NavIcon(asset: item.asset, active: true),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String asset;

  const _NavItem({required this.label, required this.asset});
}

class _NavIcon extends StatelessWidget {
  final String asset;
  final bool active;

  const _NavIcon({required this.asset, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
