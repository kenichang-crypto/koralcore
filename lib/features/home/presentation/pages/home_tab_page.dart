import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/device/device_snapshot.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_device_card.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';
import '../../../device/presentation/controllers/device_list_controller.dart';
import '../controllers/home_controller.dart';
import '../../../led/presentation/pages/led_main_page.dart';
import '../../../doser/presentation/pages/dosing_main_page.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

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

    return Scaffold(
      body: ReefMainBackground(
        child: SafeArea(
          child: _HomeFixedHeaderLayout(
            header: _SinkSelectorBar(
              controller: controller,
              // TODO: Navigate to SinkManagerPage (第二階段實現)
              onManagerTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('功能開發中 / Feature under development'),
                  ),
                );
              },
              l10n: l10n,
            ),
            body: controller.selectionType == SinkSelectionType.allSinks
                ? _buildAllSinksView(context, controller, l10n)
                : devices.isEmpty
                ? _EmptyState(l10n: l10n)
                : _buildGridView(devices, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(List<DeviceSnapshot> devices, AppLocalizations l10n) {
    // PARITY: fragment_home.xml - RecyclerView paddingStart 10dp, paddingTop 8dp, paddingEnd 10dp
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 10.0, // dp_10 paddingStart
        right: 10.0, // dp_10 paddingEnd
        top: AppSpacing.xs, // dp_8 paddingTop
        bottom: AppSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75, // Adjusted for card height
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _HomeDeviceGridTile(device: devices[index], l10n: l10n);
      },
    );
  }

  /// Build "All Sinks" view (PARITY: SinkWithDevicesAdapter + LinearLayoutManager)
  ///
  /// Each sink displays its devices in a 2-column grid (GridLayoutManager)
  Widget _buildAllSinksView(
    BuildContext context,
    HomeController controller,
    AppLocalizations l10n,
  ) {
    final sinks = controller.sinks;
    final allDevices = controller.filteredDevices;
    final devicesBySink = _groupDevicesBySink(allDevices);

    // Filter sinks that have devices
    final sinksWithDevices = sinks.where((sink) {
      final devices = devicesBySink[sink.id] ?? [];
      return devices.isNotEmpty;
    }).toList();

    if (sinksWithDevices.isEmpty) {
      return _EmptyState(l10n: l10n);
    }

    // PARITY: fragment_home.xml - RecyclerView paddingStart 10dp, paddingTop 8dp, paddingEnd 10dp
    // PARITY: adapter_sink_with_devices.xml - paddingBottom 12dp
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 10.0, // dp_10 paddingStart
        right: 10.0, // dp_10 paddingEnd
        top: AppSpacing.xs, // dp_8 paddingTop
        bottom: AppSpacing.xl,
      ),
      itemCount: sinksWithDevices.length,
      itemBuilder: (context, index) {
        final sink = sinksWithDevices[index];
        final sinkDevices = devicesBySink[sink.id] ?? [];

        return _SinkWithDevicesTile(
          sink: sink,
          devices: sinkDevices,
          l10n: l10n,
        );
      },
    );
  }

  /// Group devices by sink ID
  Map<String, List<DeviceSnapshot>> _groupDevicesBySink(
    List<DeviceSnapshot> devices,
  ) {
    final Map<String, List<DeviceSnapshot>> devicesBySink = {};

    for (final device in devices) {
      final String? sinkId = device.sinkId;
      if (sinkId != null && sinkId.isNotEmpty) {
        devicesBySink.putIfAbsent(sinkId, () => []).add(device);
      }
    }

    return devicesBySink;
  }
}

/// Layout helper: fixed header + independent scrollable body.
///
/// PARITY intent: HomeTabPage 本身不可捲動；只有「裝置列表區」可捲動。
/// Also avoids full-page scroll containers and keeps header pinned.
class _HomeFixedHeaderLayout extends StatefulWidget {
  final Widget header;
  final Widget body;

  const _HomeFixedHeaderLayout({required this.header, required this.body});

  @override
  State<_HomeFixedHeaderLayout> createState() => _HomeFixedHeaderLayoutState();
}

class _HomeFixedHeaderLayoutState extends State<_HomeFixedHeaderLayout> {
  double _headerHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _MeasureSize(
          onChange: (size) {
            if (!mounted) return;
            final next = size.height;
            if (next != _headerHeight) {
              setState(() => _headerHeight = next);
            }
          },
          child: Align(alignment: Alignment.topCenter, child: widget.header),
        ),
        Positioned(
          top: _headerHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: widget.body,
        ),
      ],
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.onChange, required Widget child})
    : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
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
        : options.isNotEmpty
        ? options[0]
        : '';

    // PARITY: fragment_home.xml layout structure:
    // - Spinner (sp_sink_type): 101×26dp, marginStart 16dp, marginTop 10dp, transparent background
    // - ImageView (img_down): 24×24dp, aligned with spinner and manager button
    // - ImageView (btn_sink_manager): 30×30dp, marginEnd 16dp
    // All three elements are on the same horizontal line
    // Note: btn_add_sink is visibility="gone" in fragment_home.xml, so its height is 0.
    // This means sp_sink_type effectively sits near the top with marginTop=10dp.
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md, // dp_16 marginStart for spinner
        right: AppSpacing.md, // dp_16 marginEnd for manager button
        top: 10.0, // dp_10 marginTop (not AppSpacing.xs which is 8dp)
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
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  LedRecordIconHelper.getDownIcon(
                    width: 24,
                    height: 24,
                    color: AppColors.textPrimary,
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
          // PARITY: ImageView 30×30dp, marginEnd 16dp, ic_manager (not ic_menu)
          IconButton(
            icon: CommonIconHelper.getManagerIcon(
              size: 30, // dp_30 (PARITY: ic_manager is 30×30dp)
              color: AppColors.textPrimary,
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
    // PARITY: fragment_home.xml - layout_no_device_in_sink
    // Uses text_no_device_in_sink_title and text_no_device_in_sink_content
    // IMPORTANT: Do not add extra empty-state visuals not present in fragment_home.xml.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.deviceInSinkEmptyTitle,
            style: AppTextStyles.subheaderAccent,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs), // dp_8
          Text(
            l10n.deviceInSinkEmptyContent,
            style: AppTextStyles.body.copyWith(color: const Color(0xFFAAAAAA)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    final AppContext appContext = context.read<AppContext>();

    // PARITY: adapter_device_led.xml structure
    // Layout: Stack with device icon and top-right icons (Master, Favorite, BLE state)
    // Icon order from left to right: Master -> Favorite -> BLE State (all aligned top-right)

    // PARITY: Data source optimization - use DeviceSnapshot fields directly for 100% parity
    // reef-b-app: Device.favorite, Device.sinkId, Device.group, Device.master
    // koralcore: DeviceSnapshot.favorite, DeviceSnapshot.sinkId, DeviceSnapshot.group, DeviceSnapshot.isMaster
    final bool isFavorite = device
        .favorite; // PARITY: data.favorite in reef-b-app DeviceAdapter.bind()
    final String? deviceSinkId =
        device.sinkId; // PARITY: data.sinkId in reef-b-app
    final String? deviceGroup =
        device.group; // PARITY: data.group in reef-b-app (LedGroup enum)
    // NOTE: device.isMaster is available but master icon is intentionally not displayed in Flutter

    // PARITY: Optimized sink name lookup - reef-b-app uses dbSink.getSinkById(sinkId)
    // Create a Map for O(1) lookup instead of O(n) traversal, but result is 100% the same
    final sinks = appContext.sinkRepository.getCurrentSinks();
    final sinkMap = <String, Sink>{};
    for (final sink in sinks) {
      sinkMap[sink.id] = sink;
    }
    final String positionName = deviceSinkId != null
        ? sinkMap[deviceSinkId]?.name ?? l10n.unassignedDevice
        : l10n.unassignedDevice;

    // PARITY: Group label (tv_group) - reef-b-app shows "｜群組 A" format
    // NOTE: In Flutter, we do NOT display the group label (tv_group) as per design requirements
    // The group data is available and processed for 100% data parity, but intentionally not rendered
    // Processing the group label ensures data parity even though it's not displayed
    // ignore: unused_local_variable
    final String? groupLabel = _getGroupLabel(deviceGroup, l10n);
    // groupLabel is computed for data parity but intentionally not used in UI (disabled in Flutter)

    return ReefDeviceCard(
      // Navigate to device main page based on device type
      onTap: () => _navigateToDeviceMainPage(context, device),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_12 paddingStart
          right: AppSpacing.md, // dp_12 paddingEnd
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
                        ? 'assets/icons/device_led.png'
                        : 'assets/icons/device_doser.png',
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
                  top: AppSpacing.sm, // dp_12 marginTop for img_ble_state
                  right: 0, // constraintEnd_toEndOf="parent"
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Master icon (img_led_master) - PARITY: reef-b-app DeviceAdapter sets visibility based on data.master
                      // NOTE: In Flutter, we do NOT display the master icon (img_led_master) as per design requirements
                      // The master data is available (device.isMaster) but intentionally not rendered
                      // reef-b-app code: binding.imgLedMaster.visibility = View.GONE (commented code shows it should be based on data.master)
                      // if (isMaster) { ... } // Intentionally disabled in Flutter
                      // Favorite icon (img_favorite) - 14×14dp
                      // PARITY: reef-b-app uses @drawable/ic_favorite_select or @drawable/ic_favorite_unselect
                      // Using CommonIconHelper which loads SVG from assets/icons/ic_favorite_*.svg
                      isFavorite
                          ? CommonIconHelper.getFavoriteSelectIcon(
                              size: 14,
                              color: const Color(
                                0xFFC00100,
                              ), // PARITY: ic_favorite_select uses #C00100 (red)
                            )
                          : CommonIconHelper.getFavoriteUnselectIcon(
                              size: 14,
                              color: const Color(
                                0xFFC4C4C4,
                              ), // PARITY: ic_favorite_unselect uses #C4C4C4 (grey)
                            ),
                      // BLE state icon (img_ble_state) - 14×14dp, rightmost
                      // PARITY: reef-b-app uses @drawable/ic_connect or @drawable/ic_disconnect
                      // Using CommonIconHelper.getConnectIcon() / getDisconnectIcon() for 100% parity
                      isConnected
                          ? CommonIconHelper.getConnectIcon(
                              size: 14,
                              color: AppColors
                                  .textPrimary, // PARITY: ic_connect uses #000000 (black)
                            )
                          : CommonIconHelper.getDisconnectIcon(
                              size: 14,
                              color: AppColors
                                  .textPrimary, // PARITY: ic_disconnect uses #000000 (black)
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
                right: AppSpacing.xxxs, // dp_4 marginEnd
                top: 0, // No spacing between img_led and tv_name
              ),
              child: Text(
                device.name,
                style: AppTextStyles.caption1Accent.copyWith(
                  // PARITY: text_aaaa if connected (#000000), text_aa if disconnected (#80000000)
                  color: isConnected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    positionName,
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.textTertiary, // text_aa (#80000000)
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Group label (tv_group) - PARITY: reef-b-app shows "｜群組 A" format
                  // NOTE: In Flutter, we do NOT display the group label (tv_group) as per design requirements
                  // The group data is available (device.group) but intentionally not rendered
                  // reef-b-app: binding.tvGroup.text = "｜${context.getString(R.string.group)} A" (when group is set)
                  // if (groupLabel != null) { ... } // Intentionally disabled in Flutter
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get group label in reef-b-app format: "｜群組 A" (Traditional Chinese) or "｜Group A" (English)
  /// PARITY: reef-b-app DeviceAdapter.bind() - "｜${context.getString(R.string.group)} A"
  /// NOTE: This method is implemented for 100% data parity but the result is NOT displayed in Flutter
  /// The group data is processed exactly as in reef-b-app, but rendering is intentionally disabled
  String? _getGroupLabel(String? group, AppLocalizations l10n) {
    if (group == null || group.isEmpty) {
      return null;
    }

    // PARITY: reef-b-app uses LedGroup enum (A, B, C, D, E)
    // koralcore uses String ('A', 'B', 'C', 'D', 'E')
    final groupLetter = group.toUpperCase();
    if (!['A', 'B', 'C', 'D', 'E'].contains(groupLetter)) {
      return null;
    }

    // PARITY: reef-b-app format: "｜${context.getString(R.string.group)} A"
    // Full format: "｜群組 A" (Traditional Chinese) or "｜Group A" (English)
    // Result is computed for data parity but not displayed (intentionally disabled in Flutter)
    return '｜${l10n.group} $groupLetter';
  }

  // NOTE: _getFavoriteIcon method removed - now using CommonIconHelper.getFavoriteSelectIcon() / getFavoriteUnselectIcon()
  // PARITY: reef-b-app uses @drawable/ic_favorite_select / @drawable/ic_favorite_unselect
  // koralcore uses CommonIconHelper which loads SVG from assets/icons/ic_favorite_*.svg

  /// Navigate to device main page based on device type
  /// PARITY: reef-b-app HomeFragment navigates to LedMainActivity or DropMainActivity
  void _navigateToDeviceMainPage(BuildContext context, DeviceSnapshot device) {
    final session = context.read<AppSession>();
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);

    // Set active device in session before navigation
    // PARITY: reef-b-app sets currentDevice via DeviceUtil.setCurrentDevice()
    session.setActiveDevice(device.id);

    if (kind == _DeviceKind.led) {
      // Navigate to LED main page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LedMainPage()),
      );
    } else {
      // Navigate to Dosing main page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DosingMainPage()),
      );
    }
  }
}

/// Sink with devices tile (PARITY: adapter_sink_with_devices.xml)
///
/// Displays a sink and its devices in a 2-column grid
class _SinkWithDevicesTile extends StatelessWidget {
  final Sink sink;
  final List<DeviceSnapshot> devices;
  final AppLocalizations l10n;

  const _SinkWithDevicesTile({
    required this.sink,
    required this.devices,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_sink_with_devices.xml - paddingBottom 12dp
    // PARITY: SinkWithDevicesAdapter uses GridLayoutManager(2) for devices
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // dp_12 paddingBottom
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Devices grid (2 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return _HomeDeviceGridTile(device: devices[index], l10n: l10n);
            },
          ),
        ],
      ),
    );
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
