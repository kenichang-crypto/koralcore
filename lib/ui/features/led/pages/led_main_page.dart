import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/sink/sink.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_backgrounds.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/error_state_widget.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';
import '../support/scene_display_text.dart';
import '../support/scene_icon_helper.dart';
import '../widgets/led_record_line_chart.dart';
import 'led_record_page.dart';
import 'led_record_setting_page.dart';
import 'led_scene_list_page.dart';
import '../../device/pages/device_settings_page.dart';
import '../../../assets/common_icon_helper.dart';


class LedMainPage extends StatelessWidget {
  const LedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedSceneListController>(
      create: (_) => LedSceneListController(
        session: session,
        readLedScenesUseCase: appContext.readLedScenesUseCase,
        applySceneUseCase: appContext.applySceneUseCase,
        observeLedStateUseCase: appContext.observeLedStateUseCase,
        readLedStateUseCase: appContext.readLedStateUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
        observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
        readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
        startLedPreviewUseCase: appContext.startLedPreviewUseCase,
        startLedRecordUseCase: appContext.startLedRecordUseCase,
      )..initialize(),
      child: const _LedMainScaffold(),
    );
  }
}

class _LedMainScaffold extends StatefulWidget {
  const _LedMainScaffold();

  @override
  State<_LedMainScaffold> createState() => _LedMainScaffoldState();
}

class _LedMainScaffoldState extends State<_LedMainScaffold> with WidgetsBindingObserver {
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PARITY: reef-b-app FLAG_KEEP_SCREEN_ON
    // Keep screen on while on LED main page
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Disable wakelock when leaving page
    WakelockPlus.disable();
    // Reset to portrait when leaving page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // PARITY: reef-b-app onResume() - refresh data when page becomes visible
    if (state == AppLifecycleState.resumed) {
      final controller = context.read<LedSceneListController>();
      // Refresh all data to ensure it's up to date
      // PARITY: reef-b-app onResume() calls:
      // - setDeviceById() → already handled by AppSession.setActiveDevice()
      // - getAllLedInfo() → _bootstrapLedState()
      // - getNowRecords() → _bootstrapRecordState()
      // - getAllFavoriteScene() → refresh() (includes favorite scenes)
      controller.refreshAll();
    }
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);
    final deviceName = session.activeDeviceName ?? l10n.ledDetailUnknownDevice;

    return Consumer<LedSceneListController>(
      builder: (context, controller, _) {
        final bool isConnected = session.isBleConnected;
        final bool writeLocked = controller.isWriteLocked;
        final bool featuresEnabled = isConnected && !writeLocked;

        return PopScope(
          canPop: !controller.isPreviewing,
          onPopInvoked: (didPop) async {
            if (!didPop && controller.isPreviewing) {
              // PARITY: reef-b-app clickBtnBack() - stop preview if active
              await controller.stopPreview();
              // After stopping preview, allow pop
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } else if (!didPop && _isLandscape) {
              // PARITY: reef-b-app onBackPressed - if landscape, switch to portrait first
              setState(() {
                _isLandscape = false;
              });
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            }
          },
          child: Scaffold(
            appBar: ReefAppBar(
              backgroundColor: ReefColors.primary,
              foregroundColor: ReefColors.onPrimary,
              elevation: 0,
              leading: IconButton(
                icon: CommonIconHelper.getBackIcon(
                  size: 24,
                  color: ReefColors.onPrimary,
                ),
                onPressed: () async {
                  // PARITY: reef-b-app clickBtnBack() - stop preview if active
                  if (controller.isPreviewing) {
                    await controller.stopPreview();
                  }
                  // If landscape, switch to portrait first
                  if (_isLandscape) {
                    setState(() {
                      _isLandscape = false;
                    });
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                  } else {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            title: Text(
              deviceName,
              style: ReefTextStyles.title2.copyWith(
                color: ReefColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              // Favorite button
              Builder(
                builder: (context) {
                  final appContext = context.read<AppContext>();
                  return FutureBuilder<bool>(
                    future: session.activeDeviceId != null
                        ? appContext.deviceRepository.isDeviceFavorite(session.activeDeviceId!)
                        : Future.value(false),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      final deviceId = session.activeDeviceId;
                      return IconButton(
                        icon: isFavorite
                            ? CommonIconHelper.getFavoriteSelectIcon(
                                size: 24,
                                color: ReefColors.error,
                              )
                            : CommonIconHelper.getFavoriteUnselectIcon(
                                size: 24,
                                color: ReefColors.onPrimary.withValues(alpha: 0.7),
                              ),
                        tooltip: isFavorite ? l10n.deviceActionUnfavorite : l10n.deviceActionFavorite,
                        onPressed: featuresEnabled && deviceId != null
                            ? () async {
                                // PARITY: reef-b-app clickBtnFavorite() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
                                try {
                                  await appContext.toggleFavoriteDeviceUseCase.execute(
                                    deviceId: deviceId,
                                  );
                                  if (context.mounted) {
                                    final l10n = AppLocalizations.of(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFavorite
                                              ? l10n.deviceUnfavorited
                                              : l10n.deviceFavorited,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    showErrorSnackBar(context, AppErrorCode.unknownError);
                                  }
                                }
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
              // Expand button (landscape/portrait toggle)
              // PARITY: reef-b-app uses ic_zoom_in for btnExpand
              IconButton(
                icon: CommonIconHelper.getZoomInIcon(
                  size: 24,
                  color: ReefColors.onPrimary,
                ),
                tooltip: _isLandscape ? l10n.ledOrientationPortrait : l10n.ledOrientationLandscape,
                onPressed: featuresEnabled
                    ? () async {
                        // PARITY: reef-b-app clickBtnExpand() - stop preview if active
                        if (controller.isPreviewing) {
                          await controller.stopPreview();
                        }
                        _toggleOrientation();
                      }
                    : null,
              ),
              // Menu button
              Builder(
                builder: (context) {
                  final appContext = context.read<AppContext>();
                  return PopupMenuButton<String>(
                    icon: CommonIconHelper.getMenuIcon(
                      size: 24,
                      color: ReefColors.onPrimary,
                    ),
                    enabled: featuresEnabled,
                    onSelected: (value) async {
                      // PARITY: reef-b-app clickBtnMenu() - stop preview if active
                      if (controller.isPreviewing) {
                        await controller.stopPreview();
                      }
                      switch (value) {
                        case 'edit':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DeviceSettingsPage(),
                            ),
                          );
                          break;
                        case 'delete':
                          _confirmDeleteDevice(context, session);
                          break;
                        case 'reset':
                          if (isConnected) {
                            _confirmResetDevice(context, session, appContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.deviceStateDisconnected)),
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            CommonIconHelper.getEditIcon(size: 20),
                            const SizedBox(width: ReefSpacing.sm),
                            Text(l10n.deviceActionEdit),
                          ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        CommonIconHelper.getDeleteIcon(
                          size: 20,
                          color: ReefColors.error,
                        ),
                        const SizedBox(width: ReefSpacing.sm),
                        Text(
                          l10n.deviceActionDelete,
                          style: const TextStyle(color: ReefColors.error),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        CommonIconHelper.getResetIcon(size: 20),
                        const SizedBox(width: ReefSpacing.sm),
                        Text(l10n.ledResetDevice),
                      ],
                    ),
                  ),
                ],
                  );
                },
              ),
            ],
          ),
          body: ReefMainBackground(
            child: SafeArea(
              child: ListView(
              // PARITY: activity_led_main.xml ConstraintLayout
              // No padding - sections handle their own margins
              padding: EdgeInsets.zero,
              children: [
                // PARITY: tv_name margin 16/8/4
                Padding(
                  padding: EdgeInsets.only(
                    left: ReefSpacing.md, // dp_16 marginStart
                    top: ReefSpacing.xs, // dp_8 marginTop
                    right: 4, // dp_4 marginEnd (not standard spacing)
                  ),
                  child: _DeviceInfoSection(
                    deviceName: deviceName,
                    isConnected: isConnected,
                    session: session,
                    l10n: l10n,
                  ),
                ),
                // PARITY: tv_record_title marginTop 20dp
                Padding(
                  padding: EdgeInsets.only(
                    left: ReefSpacing.md, // dp_16 marginStart (same as tv_name)
                    top: 20, // dp_20 marginTop (not standard spacing)
                    right: ReefSpacing.md, // dp_16 marginEnd (for btn_record_more)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.record, // PARITY: @string/record
                        style: ReefTextStyles.bodyAccent,
                      ),
                      IconButton(
                        // PARITY: reef-b-app uses ic_more_enable / ic_more_disable
                        icon: CommonIconHelper.getMoreEnableIcon(
                          size: 24,
                          color: featuresEnabled
                              ? ReefColors.textPrimary
                              : ReefColors.textPrimary.withValues(alpha: 0.5),
                        ),
                        iconSize: 24,
                        onPressed: featuresEnabled
                            ? () async {
                                // PARITY: reef-b-app clickBtnRecordMore() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
                                // PARITY: reef-b-app logic
                                // If records are empty, navigate to record setting page
                                // Otherwise, navigate to record list page
                                if (controller.hasRecords) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LedRecordPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LedRecordSettingPage(),
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                // PARITY: layout_record_background marginTop 4dp
                if (controller.hasRecords)
                  Padding(
                    padding: EdgeInsets.only(
                      left: ReefSpacing.md, // dp_16 marginStart
                      top: ReefSpacing.xxxs, // dp_4 marginTop
                      right: ReefSpacing.md, // dp_16 marginEnd
                    ),
                    child: _RecordChartSection(
                      controller: controller,
                      isConnected: isConnected,
                      featuresEnabled: featuresEnabled,
                      l10n: l10n,
                      onToggleOrientation: _toggleOrientation,
                      isLandscape: _isLandscape,
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(
                      left: ReefSpacing.md, // dp_16 marginStart
                      top: ReefSpacing.xxxs, // dp_4 marginTop
                      right: ReefSpacing.md, // dp_16 marginEnd
                    ),
                    child: Container(
                      padding: EdgeInsets.all(ReefSpacing.sm),
                      decoration: BoxDecoration(
                        color: ReefColors.surface,
                        borderRadius: BorderRadius.circular(ReefRadius.md),
                      ),
                      child: Text(
                        l10n.deviceStateDisconnected,
                        style: ReefTextStyles.bodyAccent.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                // PARITY: tv_scene_title marginTop 24dp
                Padding(
                  padding: EdgeInsets.only(
                    left: ReefSpacing.md, // dp_16 marginStart
                    top: ReefSpacing.xl, // dp_24 marginTop
                    right: ReefSpacing.md, // dp_16 marginEnd (for btn_scene_more)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.ledScene, // PARITY: @string/led_scene
                        style: ReefTextStyles.bodyAccent,
                      ),
                      IconButton(
                        // PARITY: reef-b-app uses ic_more_enable / ic_more_disable
                        icon: CommonIconHelper.getMoreEnableIcon(
                          size: 24,
                          color: featuresEnabled
                              ? ReefColors.textPrimary
                              : ReefColors.textPrimary.withValues(alpha: 0.5),
                        ),
                        iconSize: 24,
                        onPressed: featuresEnabled
                            ? () async {
                                // PARITY: reef-b-app clickBtnSceneMore() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LedSceneListPage(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                // PARITY: rv_favorite_scene marginTop 4dp, paddingStart/End 8dp
                // PARITY: constraintTop=tv_scene_title.bottom, constraintStart/End=parent
                Padding(
                  padding: EdgeInsets.only(
                    top: ReefSpacing.xxxs, // dp_4 marginTop
                    left: ReefSpacing.xs, // dp_8 paddingStart
                    right: ReefSpacing.xs, // dp_8 paddingEnd
                  ),
                  child: _FavoriteSceneSection(
                    controller: controller,
                    isConnected: isConnected,
                    featuresEnabled: featuresEnabled,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
        );
      },
    );
  }
}

/// Device info section matching activity_led_main.xml layout.
///
/// PARITY: Mirrors reef-b-app's activity_led_main.xml structure:
/// - tv_name: Device name (body_accent, text_aaaa)
/// - btn_ble: BLE state icon (48×32dp)
/// - tv_position: Position/Sink name (caption2, text_aaa)
/// - tv_group: Group (caption2, text_aa, optional)
class _DeviceInfoSection extends StatelessWidget {
  final String deviceName;
  final bool isConnected;
  final AppSession session;
  final AppLocalizations l10n;

  const _DeviceInfoSection({
    required this.deviceName,
    required this.isConnected,
    required this.session,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final deviceId = session.activeDeviceId;
    
    // Get device info from repository
    return FutureBuilder<Map<String, String?>>(
      future: _loadDeviceInfo(context, deviceId),
      builder: (context, snapshot) {
        final positionName = snapshot.data?['positionName'];
        final groupName = snapshot.data?['groupName'];
        
        final appContext = context.read<AppContext>();
        final controller = context.read<LedSceneListController>();
        return _buildDeviceInfo(
          context,
          appContext,
          controller,
          positionName,
          groupName,
        );
      },
    );
  }

  /// Load device info from repository.
  ///
  /// PARITY: Matches reef-b-app's LedMainActivity.setObserver() logic:
  /// - Gets sinkId from device, then gets sink name from sinkRepository
  /// - Gets group from device and formats as "群組${group}"
  Future<Map<String, String?>> _loadDeviceInfo(
    BuildContext context,
    String? deviceId,
  ) async {
    if (deviceId == null) {
      return {'positionName': null, 'groupName': null};
    }

    final appContext = context.read<AppContext>();
    final device = await appContext.deviceRepository.getDevice(deviceId);
    
    String? positionName;
    String? groupName;

    if (device != null) {
      // Get position name from sink
      final String? sinkId = device['sinkId']?.toString();
      if (sinkId != null && sinkId.isNotEmpty) {
        final sinks = appContext.sinkRepository.getCurrentSinks();
        final sink = sinks.firstWhere(
          (s) => s.id == sinkId,
          orElse: () => const Sink(
            id: '',
            name: '',
            type: SinkType.custom,
            deviceIds: [],
          ),
        );
        if (sink.id.isNotEmpty) {
          positionName = sink.name;
        }
      }

      // Get group name
      final String? group = device['group']?.toString();
      if (group != null && group.isNotEmpty) {
        // PARITY: reef-b-app format: "群組${group}"
        groupName = '${l10n.group}$group';
      }
    }

    return {
      'positionName': positionName,
      'groupName': groupName,
    };
  }

  Widget _buildDeviceInfo(
    BuildContext context,
    AppContext appContext,
    LedSceneListController controller,
    String? positionName,
    String? groupName,
  ) {
    // PARITY: activity_led_main.xml ConstraintLayout structure
    // Key constraints:
    // - btn_ble: constraintTop=tv_name.top, constraintBottom=tv_position.bottom (垂直居中於 tv_name 和 tv_position 之間)
    // - tv_group: constraintTop=tv_position.top, constraintBottom=tv_position.bottom (與 tv_position 垂直居中)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device name and BLE icon row (tv_name + btn_ble)
        // PARITY: btn_ble 與 tv_name 和 tv_position 垂直居中
        // 使用 Stack 來實現 btn_ble 跨越 tv_name 和 tv_position 的垂直居中
        Stack(
          children: [
            // Device name (tv_name)
            // PARITY: marginStart=16dp, marginTop=8dp, marginEnd=4dp, constraintEnd=btn_ble.start
            Padding(
              padding: EdgeInsets.only(
                left: ReefSpacing.md, // dp_16 marginStart
                top: ReefSpacing.xs, // dp_8 marginTop
                right: 4, // dp_4 marginEnd (not standard spacing)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: ReefTextStyles.subheaderAccent.copyWith(
                      color: isConnected 
                          ? ReefColors.textPrimary // text_aaaa when connected
                          : ReefColors.textSecondary, // text_aa when disconnected
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Position and Group row (tv_position + tv_group)
                  // PARITY: constraintTop=tv_name.bottom, constraintStart=tv_name.start
                  Padding(
                    padding: EdgeInsets.only(
                      top: ReefSpacing.xs, // dp_8 (spacing between name and position)
                    ),
                    child: Row(
                      children: [
                        // Position (tv_position)
                        // PARITY: caption2, text_aaa, constraintStart=tv_name.start
                        if (positionName != null)
                          Flexible(
                            child: Text(
                              positionName,
                              style: ReefTextStyles.caption2.copyWith(
                                color: ReefColors.textTertiary, // text_aaa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Text(
                            l10n.unassignedDevice,
                            style: ReefTextStyles.caption2.copyWith(
                              color: ReefColors.textTertiary, // text_aaa
                            ),
                          ),
                        // Group (tv_group)
                        // PARITY: caption2, text_aa, marginStart=4dp, constraintTop/Bottom=tv_position.top/bottom
                        if (groupName != null) ...[
                          SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
                          Text(
                            '｜$groupName', // PARITY: "｜群組 A" format
                            style: ReefTextStyles.caption2.copyWith(
                              color: ReefColors.textSecondary, // text_aa
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // BLE state icon (btn_ble)
            // PARITY: 48×32dp, marginEnd=16dp
            // PARITY: constraintTop=tv_name.top, constraintBottom=tv_position.bottom (垂直居中於 tv_name 和 tv_position 之間)
            // PARITY: reef-b-app clickBtnBle() - toggles connect/disconnect
            // 使用 Align 來實現垂直居中，因為 btn_ble 應該從 tv_name 頂部延伸到 tv_position 底部
            Positioned(
              right: ReefSpacing.md, // dp_16 marginEnd
              top: ReefSpacing.xs, // dp_8 (與 tv_name 頂部對齊)
              bottom: 0, // 與 tv_position 底部對齊（因為 tv_position 在 Column 的底部）
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _handleBleIconTap(context, appContext, controller),
                  child: SizedBox(
                    width: 48, // dp_48
                    height: 32, // dp_32
                    child: _buildBleStateIcon(isConnected),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build BLE state icon.
  ///
  /// PARITY: reef-b-app uses ic_connect_background (green) / ic_disconnect_background (grey).
  /// Falls back to Material Icons if custom icons don't exist.
  Widget _buildBleStateIcon(bool isConnected) {
    // Try to load custom icons first
    try {
      return Image.asset(
        isConnected
            ? 'assets/icons/bluetooth/ic_connect_background.png'
            : 'assets/icons/bluetooth/ic_disconnect_background.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to Material Icons if custom icons don't exist
          return _buildMaterialBleIcon(isConnected);
        },
      );
    } catch (e) {
      // Fallback to Material Icons if asset path is invalid
      return _buildMaterialBleIcon(isConnected);
    }
  }

  /// Build BLE state icon using Material Icons as fallback.
  Widget _buildMaterialBleIcon(bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        color: isConnected
            ? ReefColors.primary // #6F916F (green) when connected
            : ReefColors.surfaceMuted, // #F7F7F7 (grey) when disconnected
        borderRadius: BorderRadius.circular(16), // 16dp corner radius (48dp width / 3)
      ),
      child: Center(
        child: CommonIconHelper.getBluetoothIcon(
          size: 24,
          color: isConnected
              ? ReefColors.onPrimary // white when connected
              : ReefColors.textPrimary, // black when disconnected
        ),
      ),
    );
  }

  /// Handle BLE icon tap.
  ///
  /// PARITY: Matches reef-b-app's LedMainViewModel.clickBtnBle() logic:
  /// - If previewing, stop preview first
  /// - If connected, disconnect the device
  /// - If disconnected, connect to the device
  Future<void> _handleBleIconTap(
    BuildContext context,
    AppContext appContext,
    LedSceneListController controller,
  ) async {
    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    // PARITY: reef-b-app clickBtnBle() - stop preview if active
    if (controller.isPreviewing) {
      await controller.stopPreview();
    }

    final l10n = AppLocalizations.of(context);

    try {
      if (isConnected) {
        // Disconnect device
        await appContext.disconnectDeviceUseCase.execute(deviceId: deviceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackbarDeviceDisconnected)),
          );
        }
      } else {
        // Connect device
        // PARITY: reef-b-app checks BLE permission before connecting
        await appContext.connectDeviceUseCase.execute(deviceId: deviceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackbarDeviceConnected)),
          );
        }
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, error.code)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, AppErrorCode.unknownError)),
          ),
        );
      }
    }
  }
}

// Removed unused _RuntimeStatusCard class and its helper methods

class _FavoriteSceneSection extends StatelessWidget {
  final LedSceneListController controller;
  final bool isConnected;
  final bool featuresEnabled;
  final AppLocalizations l10n;

  const _FavoriteSceneSection({
    required this.controller,
    required this.isConnected,
    required this.featuresEnabled,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteScenes = controller.scenes.where((scene) => scene.isFavorite).toList();
    
    if (favoriteScenes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.ledFavoriteScenesTitle,
          subtitle: l10n.ledFavoriteScenesSubtitle,
        ),
        const SizedBox(height: ReefSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < favoriteScenes.length; i++) ...[
                _FavoriteSceneCard(
                  scene: favoriteScenes[i],
                  l10n: l10n,
                  isConnected: isConnected,
                  featuresEnabled: featuresEnabled,
                  controller: controller,
                ),
                if (i < favoriteScenes.length - 1)
                  const SizedBox(width: ReefSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Favorite scene card matching adapter_favorite_scene.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_favorite_scene.xml structure:
/// - MaterialButton (ElevatedButton style, but elevation=0)
/// - cornerRadius: 8dp
/// - padding: 8dp (start/end), 0dp (top/bottom)
/// - icon: ic_none (or scene icon)
/// - iconPadding: 8dp
/// - textAppearance: body
class _FavoriteSceneCard extends StatelessWidget {
  final LedSceneSummary scene;
  final AppLocalizations l10n;
  final bool isConnected;
  final bool featuresEnabled;
  final LedSceneListController controller;

  const _FavoriteSceneCard({
    required this.scene,
    required this.l10n,
    required this.isConnected,
    required this.featuresEnabled,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final bool isActive = scene.isActive;
    final bool isEnabled = featuresEnabled && !isActive;

    // PARITY: adapter_favorite_scene.xml - MaterialButton with elevation=0
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ReefSpacing.xs), // dp_8 marginStart/End
      child: ElevatedButton.icon(
        onPressed: isEnabled
            ? () => controller.applyScene(scene.id)
            : null,
        style: ElevatedButton.styleFrom(
          elevation: 0, // dp_0 (PARITY: app:elevation="@dimen/dp_0")
          padding: EdgeInsets.symmetric(
            horizontal: ReefSpacing.xs, // dp_8 paddingStart/End
            vertical: 0, // dp_0 paddingTop/Bottom
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReefSpacing.xs), // dp_8 cornerRadius
          ),
          backgroundColor: isActive
              ? ReefColors.primary
              : ReefColors.surface,
          foregroundColor: isActive
              ? ReefColors.onPrimary
              : ReefColors.textPrimary,
          disabledBackgroundColor: ReefColors.surface,
          disabledForegroundColor: ReefColors.textSecondary,
        ),
        // PARITY: reef-b-app uses ic_none or scene-specific icon
        // Use SceneIconHelper to get the actual scene icon
        icon: scene.iconKey != null
            ? SceneIconHelper.getSceneIconByKey(
                iconKey: scene.iconKey,
                width: 20,
                height: 20,
              )
            : SceneIconHelper.getSceneIcon(
                iconId: 5, // ic_none
                width: 20,
                height: 20,
              ),
        label: Text(
          sceneName.isEmpty ? l10n.ledSceneNoSetting : sceneName,
          style: ReefTextStyles.body.copyWith(
            color: isActive
                ? ReefColors.onPrimary
                : isEnabled
                    ? ReefColors.textPrimary
                    : ReefColors.textSecondary,
          ),
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}

// Removed _SceneListSection and _EntryTile - these components don't exist in reef-b-app's activity_led_main.xml

void _confirmDeleteDevice(
  BuildContext context,
  AppSession session,
) async {
  final l10n = AppLocalizations.of(context);
  final appContext = context.read<AppContext>();
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deviceDeleteConfirmTitle),
      content: Text(l10n.deviceDeleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.deviceDeleteConfirmPrimary),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.removeDeviceUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackbarDeviceRemoved)),
        );
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    }
  }
}

void _confirmResetDevice(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.ledResetDevice),
      content: Text(
        'Are you sure you want to reset this device to default settings? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: ReefColors.error,
          ),
          child: Text(l10n.ledResetDevice),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.resetLedStateUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        showSuccessSnackBar(context, l10n.deviceSettingsSaved);
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    }
  }
}

class _RecordChartSection extends StatelessWidget {
  final LedSceneListController controller;
  final bool isConnected;
  final bool featuresEnabled;
  final AppLocalizations l10n;
  final VoidCallback onToggleOrientation;
  final bool isLandscape;

  const _RecordChartSection({
    required this.controller,
    required this.isConnected,
    required this.featuresEnabled,
    required this.l10n,
    required this.onToggleOrientation,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ledEntryRecords,
                  style: ReefTextStyles.subheaderAccent.copyWith(
                    color: ReefColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (featuresEnabled && controller.hasRecords) ...[
                      // PARITY: reef-b-app btn_expand uses ic_zoom_in
                      IconButton(
                        icon: CommonIconHelper.getZoomInIcon(size: 24),
                        iconSize: 24,
                        tooltip: isLandscape ? l10n.ledOrientationPortrait : l10n.ledOrientationLandscape,
                        onPressed: featuresEnabled && !controller.isPreviewing
                            ? () async {
                                // PARITY: reef-b-app clickBtnExpand() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
                                // PARITY: reef-b-app btnExpand toggles landscape/portrait
                                onToggleOrientation();
                              }
                            : null,
                      ),
                      // PARITY: reef-b-app btn_preview uses ic_preview / ic_stop
                      IconButton(
                        icon: controller.isPreviewing
                            ? CommonIconHelper.getStopIcon(size: 24)
                            : CommonIconHelper.getPreviewIcon(size: 24),
                        tooltip: controller.isPreviewing
                            ? l10n.ledRecordsActionPreviewStop
                            : l10n.ledRecordsActionPreviewStart,
                        onPressed: controller.isBusy
                            ? null
                            : controller.togglePreview,
                      ),
                      // PARITY: reef-b-app btn_continue_record - MaterialButton with text
                      // Using IconButton for now, but should match the button style
                      IconButton(
                        icon: CommonIconHelper.getPlayUnselectIcon(size: 24),
                        tooltip: l10n.ledContinueRecord,
                        onPressed: controller.isBusy || controller.isPreviewing
                            ? null
                            : controller.startRecord,
                      ),
                    ],
                    IconButton(
                      // PARITY: reef-b-app uses ic_more_enable / ic_more_disable for btn_record_more
                      icon: CommonIconHelper.getMoreEnableIcon(
                        size: 24,
                        color: featuresEnabled
                            ? ReefColors.textPrimary
                            : ReefColors.textPrimary.withValues(alpha: 0.5),
                      ),
                      iconSize: 24,
                      tooltip: l10n.ledEntryRecords,
                      onPressed: featuresEnabled
                          ? () {
                              // PARITY: reef-b-app logic
                              // If records are empty, navigate to record setting page
                              // Otherwise, navigate to record list page
                              if (controller.hasRecords) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LedRecordPage(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LedRecordSettingPage(),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.md),
            LedRecordLineChart(
              records: controller.records,
              height: 200,
              showLegend: true,
              interactive: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.surface,
          ),
        ),
        const SizedBox(height: ReefSpacing.xs),
        Text(
          subtitle,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.surface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
