import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_context.dart';
import '../../../application/common/app_session.dart';
import '../../../application/device/device_snapshot.dart';
import '../../../domain/sink/sink.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../../widgets/reef_backgrounds.dart';
import '../../widgets/reef_device_card.dart';
import '../../components/empty_state_widget.dart';
import '../../assets/common_icon_helper.dart';
import '../led/support/led_record_icon_helper.dart';
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
    // PARITY: fragment_home.xml - RecyclerView paddingStart 10dp, paddingTop 8dp, paddingEnd 10dp
    // NOTE: Even for "all sinks" mode, we use GridView with the same card layout as other modes
    // This matches user requirement: "所有都要一樣" (all should be the same)
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 10.0, // dp_10 paddingStart
        right: 10.0, // dp_10 paddingEnd
        top: ReefSpacing.xs, // dp_8 paddingTop
        bottom: ReefSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ReefSpacing.md,
        mainAxisSpacing: ReefSpacing.md,
        childAspectRatio: 0.75, // Adjusted for card height
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _HomeDeviceGridTile(device: devices[index], l10n: l10n);
      },
    );
  }

  Widget _buildGridView(List<DeviceSnapshot> devices, AppLocalizations l10n) {
    // PARITY: fragment_home.xml - RecyclerView paddingStart 10dp, paddingTop 8dp, paddingEnd 10dp
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 10.0, // dp_10 paddingStart
        right: 10.0, // dp_10 paddingEnd
        top: ReefSpacing.xs, // dp_8 paddingTop
        bottom: ReefSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ReefSpacing.md,
        mainAxisSpacing: ReefSpacing.md,
        childAspectRatio: 0.75, // Adjusted for card height
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
    // PARITY: fragment_home.xml - btn_add_sink and btn_warning are visibility="gone"
    // So this bar should be empty/invisible, but we keep it for structure
    return const SizedBox.shrink();
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

    // PARITY: fragment_home.xml layout structure:
    // - Spinner (sp_sink_type): 101×26dp, marginStart 16dp, marginTop 10dp, transparent background
    // - ImageView (img_down): 24×24dp, aligned with spinner and manager button
    // - ImageView (btn_sink_manager): 30×30dp, marginEnd 16dp
    // All three elements are on the same horizontal line
    return Padding(
      padding: EdgeInsets.only(
        left: ReefSpacing.md, // dp_16 marginStart for spinner
        right: ReefSpacing.md, // dp_16 marginEnd for manager button
        top: ReefSpacing.xs, // dp_10 marginTop
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sink 選擇器 (Spinner) with dropdown icon
          // PARITY: Spinner width 101dp, height 26dp, transparent background
          // Icon (img_down) 24×24dp, aligned with spinner
          // Clicking icon should trigger dropdown (same as reef-b-app's imgDown.setOnClickListener)
          // Use PopupMenuButton to make entire area (including icon) clickable
          PopupMenuButton<String>(
            initialValue: selectedValue,
            offset: const Offset(0, 26), // Position below the button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              width: 125, // dp_101 + dp_24 for icon
              height: 26, // dp_26
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 101, // dp_101
                    child: Text(
                      selectedValue,
                      style: ReefTextStyles.body.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  LedRecordIconHelper.getDownIcon(
                    width: 24,
                    height: 24,
                    color: ReefColors.textPrimary,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) {
              return options.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
            onSelected: (value) {
              final index = options.indexOf(value);
              if (index >= 0) {
                controller.selectSinkOption(index, l10n);
              }
            },
          ),
          const Spacer(),
          // Sink 管理按鈕 (btn_sink_manager)
          // PARITY: ImageView 30×30dp, marginEnd 16dp
          IconButton(
            icon: CommonIconHelper.getMenuIcon(
              size: 24,
              color: ReefColors.textPrimary,
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
    final bool isMaster = device.isMaster;
    final AppContext appContext = context.read<AppContext>();

    // PARITY: adapter_device_led.xml structure
    // Layout: Stack with device icon and top-right icons (Master, Favorite, BLE state)
    // Icon order from left to right: Master -> Favorite -> BLE State (all aligned top-right)
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        appContext.deviceRepository.isDeviceFavorite(device.id),
        appContext.deviceRepository.getDevice(device.id),
      ]).then((results) => {
        'isFavorite': results[0] as bool,
        'deviceMap': results[1] as Map<String, dynamic>?,
      }),
      builder: (context, snapshot) {
        final bool isFavorite = snapshot.data?['isFavorite'] ?? false;
        
        // Find sink that contains this device
        final sinks = appContext.sinkRepository.getCurrentSinks();
        Sink? deviceSink;
        try {
          deviceSink = sinks.firstWhere(
            (sink) => sink.deviceIds.contains(device.id),
          );
        } catch (_) {
          // Device not found in any sink, will show unassigned
          deviceSink = null;
        }
        final String? positionName = deviceSink?.name;
        
        return ReefDeviceCard(
              onTap: () => _navigate(context, kind, device.id),
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
                    // Top row: Device icon with overlaid icons (Master, Favorite, BLE state)
                    // PARITY: img_led height 50dp, constraintTop_toTopOf="parent", constraintBottom_toTopOf="@id/tv_name"
                    Stack(
                      children: [
                        // Device icon (img_led/img_drop)
                        // PARITY: 50dp height, starts from parent top
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            kind == _DeviceKind.led
                                ? 'assets/icons/device/device_led.png'
                                : 'assets/icons/device/device_doser.png',
                            width: double.infinity,
                            height: 50, // dp_50
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        // Top-right icons row (aligned to top-right corner)
                        // PARITY: img_ble_state marginTop 12dp, constraintEnd_toEndOf="parent", constraintTop_toTopOf="parent"
                        // img_favorite: constraintBottom_toBottomOf="@id/img_ble_state", constraintEnd_toStartOf="@id/img_ble_state"
                        // img_led_master: marginStart 32dp (from parent start), marginEnd 4dp, constraintEnd_toStartOf="@id/img_favorite"
                        Positioned(
                          top: ReefSpacing.sm, // dp_12 marginTop for img_ble_state
                          right: 0, // constraintEnd_toEndOf="parent"
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Master icon (img_led_master) - only if isMaster
                              // PARITY: marginStart 32dp from parent start, marginEnd 4dp before favorite
                              // Note: marginStart 32dp is from parent start, not from device icon edge
                              if (isMaster)
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: ReefSpacing.xxxs, // dp_4 marginEnd before favorite
                                  ),
                                  child: Image.asset(
                                    'assets/icons/ic_master.png',
                                    width: 12, // dp_12
                                    height: 12, // dp_12
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => CommonIconHelper.getFavoriteSelectIcon(
                                      size: 12,
                                      color: ReefColors.primary,
                                    ),
                                  ),
                                ),
                              // Favorite icon (img_favorite) - 14×14dp
                              // PARITY: constraintEnd_toStartOf="@id/img_ble_state" (no margin between favorite and BLE)
                              Image.asset(
                                _getFavoriteIcon(isFavorite),
                                width: 14, // dp_14
                                height: 14, // dp_14
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => isFavorite
                                    ? CommonIconHelper.getFavoriteSelectIcon(
                                        size: 14,
                                        color: ReefColors.danger,
                                      )
                                    : CommonIconHelper.getFavoriteUnselectIcon(
                                        size: 14,
                                        color: ReefColors.textSecondary,
                                      ),
                              ),
                              // BLE state icon (img_ble_state) - 14×14dp, rightmost
                              Image.asset(
                                isConnected
                                    ? 'assets/icons/bluetooth/ic_connect.png'
                                    : 'assets/icons/bluetooth/ic_disconnect.png',
                                width: 14, // dp_14
                                height: 14, // dp_14
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => CommonIconHelper.getBluetoothIcon(
                                  size: 14,
                                  color: isConnected ? ReefColors.success : ReefColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Device name (tv_name)
                    // PARITY: constraintTop_toBottomOf="@id/img_led" (no spacing), marginEnd 4dp, constraintBottom_toTopOf="@id/tv_position"
                    Padding(
                      padding: EdgeInsets.only(
                        right: ReefSpacing.xxxs, // dp_4 marginEnd
                        top: 0, // No spacing between img_led and tv_name
                      ),
                      child: Text(
                        device.name,
                        style: ReefTextStyles.caption1Accent.copyWith(
                          color: isConnected ? ReefColors.textPrimary : ReefColors.textSecondary, // text_aaaa if connected, text_aa if disconnected
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Position (tv_position)
                    // PARITY: constraintTop_toBottomOf="@id/tv_name" (no spacing), marginBottom 2dp, constraintBottom_toBottomOf="parent"
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 2, // dp_2 marginBottom
                        top: 0, // No spacing between tv_name and tv_position
                      ),
                      child: Text(
                        positionName ?? l10n.unassignedDevice,
                        style: ReefTextStyles.caption2.copyWith(
                          color: ReefColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }

  void _navigate(BuildContext context, _DeviceKind kind, String deviceId) {
    // PARITY: reef-b-app passes device_id via Intent
    // Set activeDeviceId before navigation to ensure it's available in the target page
    final session = context.read<AppSession>();
    session.setActiveDevice(deviceId);
    
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
