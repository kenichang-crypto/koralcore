import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_context.dart';
import '../../../application/device/device_snapshot.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../../widgets/reef_backgrounds.dart';
import '../../widgets/reef_device_card.dart';
import '../../assets/reef_material_icons.dart';
import '../../components/empty_state_widget.dart';
import '../device/controllers/device_list_controller.dart';
import 'controllers/home_controller.dart';
import '../dosing/pages/dosing_main_page.dart';
import '../led/pages/led_main_page.dart';
import '../warning/pages/warning_page.dart';
import '../sink/pages/sink_manager_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final deviceListController = context.watch<DeviceListController>();

    return ChangeNotifierProvider<HomeController>(
      create: (_) => HomeController(
        sinkRepository: appContext.sinkRepository,
        deviceRepository: appContext.deviceRepository,
        deviceListController: deviceListController,
      ),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<HomeController>();
    final devices = controller.filteredDevices;
    final useGridLayout = controller.useGridLayout;

    return Scaffold(
      body: ReefMainBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 頂部按鈕區域
              _TopButtonBar(
                onWarningTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WarningPage(),
                    ),
                  );
                },
                l10n: l10n,
              ),
              // Sink 選擇器區域
              _SinkSelectorBar(
                controller: controller,
                onManagerTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SinkManagerPage(),
                    ),
                  );
                },
                l10n: l10n,
              ),
              // 設備列表區域
              Expanded(
                child: devices.isEmpty
                    ? _EmptyState(l10n: l10n)
                    : useGridLayout
                        ? _buildGridView(devices, l10n)
                        : _buildListView(devices, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<DeviceSnapshot> devices, AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.only(
        left: ReefSpacing.sm,
        right: ReefSpacing.sm,
        top: ReefSpacing.xs,
        bottom: ReefSpacing.xl,
      ),
      children: [
        for (int i = 0; i < devices.length; i++) ...[
          _HomeDeviceTile(device: devices[i], l10n: l10n),
          if (i != devices.length - 1)
            const SizedBox(height: ReefSpacing.md),
        ],
      ],
    );
  }

  Widget _buildGridView(List<DeviceSnapshot> devices, AppLocalizations l10n) {
    return GridView.builder(
      padding: EdgeInsets.only(
        left: ReefSpacing.sm,
        right: ReefSpacing.sm,
        top: ReefSpacing.xs,
        bottom: ReefSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ReefSpacing.md,
        mainAxisSpacing: ReefSpacing.md,
        childAspectRatio: 0.85, // Adjusted for vertical layout matching adapter_device_led.xml
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _HomeDeviceGridTile(device: devices[index], l10n: l10n);
      },
    );
  }
}

class _TopButtonBar extends StatelessWidget {
  final VoidCallback onWarningTap;
  final AppLocalizations l10n;

  const _TopButtonBar({
    required this.onWarningTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ReefSpacing.sm,
        bottom: ReefSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              ReefMaterialIcons.warning,
              color: ReefColors.textPrimary,
            ),
            tooltip: l10n.warningTitle,
            onPressed: onWarningTap,
            padding: EdgeInsets.all(ReefSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: 56,
              minHeight: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _SinkSelectorBar extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onManagerTap;
  final AppLocalizations l10n;

  const _SinkSelectorBar({
    required this.controller,
    required this.onManagerTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final options = controller.getSinkOptions(l10n);
    final selectedIndex = controller.selectedSinkIndex;
    final selectedValue = selectedIndex < options.length 
        ? options[selectedIndex] 
        : options.isNotEmpty ? options[0] : '';

    // PARITY: fragment_home.xml - Spinner (101×26dp) with transparent background
    return Padding(
      padding: EdgeInsets.only(
        left: ReefSpacing.md, // dp_16
        right: ReefSpacing.md, // dp_16
        top: ReefSpacing.xs, // dp_10
        bottom: ReefSpacing.xs, // dp_10
      ),
      child: Row(
        children: [
          // Sink 選擇器 (DropdownButton)
          // PARITY: Spinner width 101dp, height 26dp
          SizedBox(
            width: 101, // dp_101
            height: 26, // dp_26
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              underline: const SizedBox.shrink(), // Remove default underline
              icon: const SizedBox.shrink(), // Remove default icon (we add custom one)
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary,
              ),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final index = options.indexOf(value);
                  if (index >= 0) {
                    controller.selectSinkOption(index, l10n);
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 4), // dp_4
          // Dropdown icon (img_down)
          Icon(
            ReefMaterialIcons.down,
            size: 24, // dp_24
            color: ReefColors.textPrimary,
          ),
          const Spacer(),
          // Sink 管理按鈕 (btn_sink_manager)
          // PARITY: ImageView 30×30dp
          IconButton(
            icon: Icon(
              ReefMaterialIcons.menu, // ic_manager
              color: ReefColors.textPrimary,
              size: 30, // dp_30
            ),
            onPressed: onManagerTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 30, // dp_30
              minHeight: 30, // dp_30
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: l10n.deviceEmptyTitle,
      subtitle: l10n.deviceEmptySubtitle,
    );
  }
}


/// Device tile for ListView layout (horizontal layout).
class _HomeDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final AppLocalizations l10n;

  const _HomeDeviceTile({required this.device, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final bool isConnected = device.isConnected;
    final bool isConnecting = device.isConnecting;
    final String statusLabel = isConnected
        ? l10n.deviceStateConnected
        : isConnecting
        ? l10n.deviceStateConnecting
        : l10n.deviceStateDisconnected;
    final Color statusColor = isConnected
        ? ReefColors.success
        : isConnecting
        ? ReefColors.warning
        : ReefColors.textSecondary;

    return ReefDeviceCard(
      onTap: () => _navigate(context, kind),
      child: SizedBox(
        height: 88,
        child: Padding(
          padding: EdgeInsets.zero, // Padding is handled by ReefDeviceCard
          child: Row(
            children: [
              Image.asset(
                kind == _DeviceKind.led
                    ? 'assets/icons/device/device_led.png'
                    : 'assets/icons/device/device_doser.png',
                width: 50, // PARITY: adapter_device_led.xml uses 50dp
                height: 50, // PARITY: adapter_device_led.xml uses 50dp
              ),
              const SizedBox(width: ReefSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      device.name,
                      style: ReefTextStyles.subheaderAccent.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ReefSpacing.xs),
                    Text(
                      statusLabel,
                      style: ReefTextStyles.caption1.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ReefColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, _DeviceKind kind) {
    final Widget page = kind == _DeviceKind.led
        ? const LedMainPage()
        : const DosingMainPage();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

/// Device tile for GridView layout (vertical layout matching adapter_device_led.xml).
///
/// PARITY: Mirrors reef-b-app's adapter_device_led.xml structure for GridView display.
class _HomeDeviceGridTile extends StatelessWidget {
  final DeviceSnapshot device;
  final AppLocalizations l10n;

  const _HomeDeviceGridTile({required this.device, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final bool isConnected = device.isConnected;
    final bool isFavorite = false; // TODO: Get from DeviceSnapshot when available
    final bool isMaster = device.isMaster;
    final String? positionName = null; // TODO: Get from DeviceSnapshot.sinkId when available
    final String? groupName = null; // TODO: Get from DeviceSnapshot.group when available

    // PARITY: adapter_device_led.xml / adapter_device_drop.xml structure
    // MaterialCardView: margin 6dp, cornerRadius 10dp, elevation 5dp, selectableItemBackground
    // Padding: 12/10/12/10dp
    // img_led/img_drop: 50dp height, 0dp width (constrained)
    // img_led_master: 12×12dp, marginStart 32dp, marginEnd 4dp, invisible if not master
    // img_favorite: 14×14dp
    // img_ble_state: 14×14dp, marginTop 12dp
    // tv_name: caption1_accent, text_aa, marginEnd 4dp
    // tv_position: caption2, text_aa, marginBottom 2dp, marginEnd 4dp
    // tv_group: caption2, text_aa, marginEnd 4dp, visibility gone if no group
    // img_check: 20×20dp, invisible (for selection mode)
    return ReefDeviceCard(
      onTap: () => _navigate(context, kind),
      child: Padding(
        padding: EdgeInsets.only(
          left: ReefSpacing.md, // dp_12 paddingStart
          right: ReefSpacing.md, // dp_12 paddingEnd
          top: 10, // dp_10 paddingTop
          bottom: 10, // dp_10 paddingBottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Device icon, Master icon, Favorite icon, BLE state icon
            Stack(
              children: [
                // Device icon (img_led/img_drop)
                // PARITY: 50dp height, 0dp width (constrained by parent)
                Padding(
                  padding: EdgeInsets.only(top: ReefSpacing.xs), // dp_12 marginTop
                  child: Image.asset(
                    kind == _DeviceKind.led
                        ? 'assets/icons/device/device_led.png'
                        : 'assets/icons/device/device_doser.png',
                    width: double.infinity, // 0dp (constrained)
                    height: 50, // dp_50
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // Top-right icons row
                Positioned(
                  top: ReefSpacing.xs, // dp_12 marginTop
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Master icon (img_led_master) - 12×12dp, marginStart 32dp, marginEnd 4dp
                      if (isMaster)
                        Padding(
                          padding: EdgeInsets.only(
                            left: ReefSpacing.xl * 2, // dp_32 marginStart
                            right: ReefSpacing.xs, // dp_4 marginEnd
                          ),
                          child: Image.asset(
                            'assets/icons/ic_master.png',
                            width: 12, // dp_12
                            height: 12, // dp_12
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.star,
                              size: 12,
                              color: ReefColors.primary,
                            ),
                          ),
                        ),
                      // Favorite icon (img_favorite) - 14×14dp
                      Image.asset(
                        _getFavoriteIcon(isFavorite),
                        width: 14, // dp_14
                        height: 14, // dp_14
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: isFavorite ? ReefColors.danger : ReefColors.textSecondary,
                        ),
                      ),
                      // BLE state icon (img_ble_state) - 14×14dp
                      Image.asset(
                        isConnected
                            ? 'assets/icons/bluetooth/ic_connect.png'
                            : 'assets/icons/bluetooth/ic_disconnect.png',
                        width: 14, // dp_14
                        height: 14, // dp_14
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          size: 14,
                          color: isConnected ? ReefColors.success : ReefColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.xs), // Spacing between icon and name
            // Device name (tv_name) - caption1_accent, text_aa, marginEnd 4dp
            Padding(
              padding: EdgeInsets.only(right: ReefSpacing.xs), // dp_4 marginEnd
              child: Text(
                device.name,
                style: ReefTextStyles.caption1Accent.copyWith(
                  color: ReefColors.textSecondary, // text_aa (always text_aa, not text_aaaa)
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Position and Group row (tv_position + tv_group)
            Row(
              children: [
                // Position (tv_position) - caption2, text_aa, marginBottom 2dp, marginEnd 4dp
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 2, // dp_2 marginBottom
                      right: ReefSpacing.xs, // dp_4 marginEnd
                    ),
                    child: Text(
                      positionName ?? 'Unassigned', // TODO: Use localization
                      style: ReefTextStyles.caption2.copyWith(
                        color: ReefColors.textSecondary, // text_aa
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Group (tv_group) - caption2, text_aa, marginEnd 4dp, visibility gone if no group
                if (groupName != null) ...[
                  Padding(
                    padding: EdgeInsets.only(right: ReefSpacing.xs), // dp_4 marginEnd
                    child: Text(
                      '｜$groupName', // PARITY: "｜群組 A" format
                      style: ReefTextStyles.caption2.copyWith(
                        color: ReefColors.textSecondary, // text_aa
                      ),
                    ),
                  ),
                ],
                // Check icon (img_check) - 20×20dp, invisible (for selection mode)
                // This is handled by ReefDeviceCard's selection mode if needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, _DeviceKind kind) {
    final Widget page = kind == _DeviceKind.led
        ? const LedMainPage()
        : const DosingMainPage();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  String _getFavoriteIcon(bool isFavorite) {
    return isFavorite
        ? 'assets/icons/ic_favorite_select.png'
        : 'assets/icons/ic_favorite_unselect.png';
  }
}


enum _DeviceKind { led, doser }

class _DeviceKindHelper {
  static _DeviceKind fromName(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}
