import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../shared/theme/app_colors.dart';
import '../features/home/presentation/pages/home_tab_page.dart';
import '../features/bluetooth/presentation/pages/bluetooth_tab_page.dart';
import '../features/device/presentation/pages/device_tab_page.dart';
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
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

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
          const _MainToolbarApp(),
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
        onTap: context.read<NavigationController>().select,
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

class _MainToolbarApp extends StatelessWidget {
  const _MainToolbarApp();

  @override
  Widget build(BuildContext context) {
    // PARITY: docs/reef_b_app_res/layout/toolbar_app.xml
    // - White toolbar background + 2dp bottom divider (bg_press)
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: const [
                // Intentionally empty: Android toolbar_app shows/uses optional controls
                // depending on the active fragment. Gate: do not invent UI here.
              ],
            ),
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
