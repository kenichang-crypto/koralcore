import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../theme/colors.dart';
import '../features/bluetooth/bluetooth_page.dart';
import '../features/device/device_page.dart';
import '../features/home/home_page.dart';
import 'navigation_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

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
        children: const [HomePage(), BluetoothPage(), DevicePage()],
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
    final color = active ? AppColors.ocean500 : AppColors.grey500;
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
