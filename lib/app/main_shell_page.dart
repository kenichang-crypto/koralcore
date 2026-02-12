import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/ble/ble_readiness_controller.dart';
import '../l10n/app_localizations.dart';
import '../shared/theme/app_colors.dart';
import '../shared/theme/app_text_styles.dart';
import '../shared/assets/common_icon_helper.dart';
import '../features/home/presentation/pages/home_tab_page.dart';
import '../features/bluetooth/presentation/pages/bluetooth_tab_page.dart';
import '../features/device/presentation/pages/device_tab_page.dart';
import '../app/device/device_snapshot.dart';
import '../features/device/presentation/controllers/device_list_controller.dart';
import 'navigation_controller.dart';

/// Main shell page mirroring reef-b-app's MainActivity layout structure.
///
/// PARITY: Android `activity_main.xml`
/// - Top: include `@layout/toolbar_app`
/// - Middle: FragmentContainerView (NavHostFragment) => Flutter tab content
/// - Bottom: BottomNavigationView with 3 destinations (Home/Bluetooth/Device)
/// - Overlay: include `@layout/progress` (handled by feature pages; shell does not invent loading UI)
///
/// Constraints (Gate):
/// - No scroll in shell (only tab pages may scroll)
/// - No Scaffold-in-Scaffold
/// - Avoid Material3 NavigationBar (use BottomNavigationBar)
/// - Preserve tab state (match Fragment behavior): IndexedStack + stable children
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  bool _hasAutoScanned = false;
  BleReadinessController? _bleController;
  VoidCallback? _bleListener;

  @override
  void initState() {
    super.initState();
    // PARITY: reef-b-app MainActivity.onCreate → scanLeDevice() when BLE ready
    // Auto-trigger device scan once when BLE permission + Bluetooth are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupBleAutoScan());
  }

  @override
  void dispose() {
    if (_bleController != null && _bleListener != null) {
      _bleController!.removeListener(_bleListener!);
    }
    super.dispose();
  }

  void _setupBleAutoScan() {
    if (!mounted) return;
    final bleController = context.read<BleReadinessController>();
    final deviceController = context.read<DeviceListController>();

    void listener() {
      if (!mounted) return;
      if (_hasAutoScanned) return;
      if (bleController.snapshot.isReady) {
        _hasAutoScanned = true;
        _bleController?.removeListener(_bleListener!);
        deviceController.refresh();
      }
    }

    _bleController = bleController;
    _bleListener = listener;
    bleController.addListener(listener);

    // Immediate check in case already ready
    if (!_hasAutoScanned && bleController.snapshot.isReady) {
      _hasAutoScanned = true;
      bleController.removeListener(listener);
      deviceController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NavigationController>();
    final l10n = AppLocalizations.of(context);

    final items = <_NavItem>[
      _NavItem(label: l10n.tabHome, asset: 'assets/icons/icon_home.svg'),
      _NavItem(
        label: l10n.tabBluetooth,
        asset: 'assets/icons/icon_bluetooth.svg',
      ),
      _NavItem(label: l10n.tabDevice, asset: 'assets/icons/icon_device.svg'),
    ];

    return Scaffold(
      // Top: toolbar_app (structural placeholder; actual buttons are fragment-specific on Android)
      body: Column(
        children: [
          _MainToolbarApp(navIndex: controller.index),
          Expanded(
            // Middle: fragment host => tab content
            child: IndexedStack(
              index: controller.index,
              children: const [
                // HomeFragment
                HomeTabPage(),
                // BluetoothFragment
                BluetoothTabPage(),
                // DeviceFragment
                DeviceTabPage(),
              ],
            ),
          ),
        ],
      ),
      // Bottom: BottomNavigationView
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.index,
        onTap: (index) {
          final nav = context.read<NavigationController>();
          final prevIndex = nav.index;
          nav.select(index);
          if (prevIndex == 2 && index != 2) {
            context.read<DeviceListController>().exitSelectionMode();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          for (final item in items)
            BottomNavigationBarItem(
              label: item.label,
              icon: _NavIcon(asset: item.asset, active: false),
              activeIcon: _NavIcon(asset: item.asset, active: true),
            ),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_app.xml - white toolbar, optional controls per fragment.
/// When Device tab active: btn_choose (Select) + btn_delete (when selection mode).
class _MainToolbarApp extends StatelessWidget {
  final int navIndex;

  const _MainToolbarApp({required this.navIndex});

  @override
  Widget build(BuildContext context) {
    // PARITY: reef-b-app hides toolbar for HomeFragment
    if (navIndex == 0) {
      return const SizedBox.shrink();
    }

    // PARITY: docs/reef_b_app_res/layout/toolbar_app.xml
    // - White toolbar background + 2dp bottom divider (bg_press)
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: _ToolbarContent(navIndex: navIndex),
          ),
          Container(
            height: 2,
            color: AppColors.surfacePressed, // PARITY: bg_press
          ),
        ],
      ),
    );
  }
}

class _ToolbarContent extends StatelessWidget {
  final int navIndex;

  const _ToolbarContent({required this.navIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Device tab (index 2): show Select + Delete when devices exist
    if (navIndex == 2) {
      final deviceListController = context.watch<DeviceListController>();
      final devices = deviceListController.savedDevices;
      final selectionMode = deviceListController.selectionMode;

      if (devices.isEmpty) {
        return _buildTitleRow(context, l10n.deviceHeader);
      }

      return Row(
        children: [
          // btn_choose: Select / Cancel - toggles selection mode
          TextButton(
            onPressed: () {
              if (selectionMode) {
                deviceListController.exitSelectionMode();
              } else {
                deviceListController.enterSelectionMode();
              }
            },
            child: Text(
              l10n.deviceSelectMode, // PARITY: btn_choose always shows fragment_device_select
              style: AppTextStyles.caption1.copyWith(color: AppColors.primaryStrong),
            ),
          ),
          if (selectionMode) ...[
            const SizedBox(width: 8),
            // btn_delete: delete icon - visible only in selection mode
            IconButton(
              icon: CommonIconHelper.getDeleteIcon(size: 24, color: AppColors.textPrimary),
              onPressed: deviceListController.selectedIds.isEmpty
                  ? null
                  : () => _onDeletePressed(context, deviceListController),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
          const Spacer(),
        ],
      );
    }

    // Bluetooth tab (index 1)
    return _buildTitleRow(context, l10n.bluetoothOtherDevice);
  }

  Widget _buildTitleRow(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Future<void> _onDeletePressed(BuildContext context, DeviceListController deviceListController) async {
    final l10n = AppLocalizations.of(context);
    final selectedIds = deviceListController.selectedIds.toList();
    if (selectedIds.isEmpty) return;

    final devices = deviceListController.savedDevices;
    for (final id in selectedIds) {
      DeviceSnapshot? device;
      for (final d in devices) {
        if (d.id == id) {
          device = d;
          break;
        }
      }
      if (device != null &&
          (device.type?.toLowerCase().contains('led') ?? false) &&
          !(await deviceListController.canDeleteDevice(id))) {
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.deviceDeleteLedMasterTitle),
              content: Text(l10n.deviceDeleteLedMasterContent),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.deviceDeleteLedMasterPositive),
                ),
              ],
            ),
          );
          deviceListController.exitSelectionMode();
        }
        return;
      }
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.deviceDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.deviceDeleteConfirmSecondary),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deviceDeleteConfirmPrimary),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await deviceListController.removeSelected();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackbarDeviceRemoved)),
        );
      }
    }
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
