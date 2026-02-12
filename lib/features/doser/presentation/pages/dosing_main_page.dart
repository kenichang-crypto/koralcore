// PARITY: 100% Android activity_drop_main.xml + DropMainActivity.kt + DropMainViewModel.kt
// Mode: Feature Implementation (方案 B - 完整功能實現)
//
// Android 源碼對照:
// - Activity: reef-b-app/DropMainActivity.kt (314 lines)
// - ViewModel: reef-b-app/DropMainViewModel.kt (466 lines)
// - Layout: reef-b-app/res/layout/activity_drop_main.xml
//
// 功能實現:
// - BLE 連線/斷線
// - 手動滴液 (Play/Pause)
// - 裝置管理 (Favorite/Delete/Reset)
// - 泵頭詳細資訊導航
// - PopupMenu (Edit/Delete/Reset)
// - Dialogs (Delete/Reset/OutOfRange)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_session.dart';
import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/reef_icon_button.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../controllers/dosing_main_controller.dart';
import '../widgets/dosing_main_pump_head_list.dart';
import 'pump_head_detail_page.dart';
import 'drop_setting_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';

/// DosingMainPage - 100% Parity with Android DropMainActivity
///
/// PARITY RULES:
/// - 整頁 ScrollView（對齊 Android）
/// - 設備識別區（layout_device）
/// - Progress Overlay（visibility=gone）
/// - 完整功能實現（BLE/Manual Drop/Favorite/Delete/Reset）
class DosingMainPage extends StatelessWidget {
  const DosingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider(
      create: (_) => DosingMainController(
        session: session,
        dosingRepository: appContext.dosingRepository,
        deviceRepository: appContext.deviceRepository,
        sinkRepository: appContext.sinkRepository,
        pumpHeadRepository: appContext.pumpHeadRepository,
        bleAdapter: appContext.bleAdapter,
        connectDeviceUseCase: appContext.connectDeviceUseCase,
        disconnectDeviceUseCase: appContext.disconnectDeviceUseCase,
      ),
      child: const _DosingMainPageContent(),
    );
  }
}

/// Internal content widget that has access to DosingMainController
class _DosingMainPageContent extends StatefulWidget {
  const _DosingMainPageContent();

  @override
  State<_DosingMainPageContent> createState() => _DosingMainPageContentState();
}

class _DosingMainPageContentState extends State<_DosingMainPageContent> {
  @override
  void initState() {
    super.initState();
    // PARITY: DropMainActivity.onCreate() -> viewModel.setDeviceById()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<AppSession>();
      final deviceId = session.activeDeviceId;
      if (deviceId != null) {
        context.read<DosingMainController>().initialize(deviceId);
      } else {
        // No active device, return to previous page
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final controller = context.watch<DosingMainController>();
    final l10n = AppLocalizations.of(context);
    final deviceName = controller.deviceName ?? l10n.dosingHeader;
    final positionName = controller.sinkName ?? l10n.unassignedDevice;

    // KC-A-FINAL: Redirect when active device was deleted (e.g. from Device tab).
    if (session.activeDeviceId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const SizedBox.shrink();
    }

    // Handle errors
    if (controller.lastErrorCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorToast(context, controller.lastErrorCode!);
        controller.clearError();
      });
    }

    // PARITY: Android activity_drop_main.xml structure
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // PARITY: DropMainActivity.onDestroy() cleanup
        // Controller will be disposed automatically
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted, // bg_aaa
        body: Stack(
          children: [
            // Main content (Toolbar + ScrollView)
            Column(
              children: [
                // Toolbar (toolbar_device)
                _ToolbarDevice(
                  deviceName: deviceName,
                  isFavorite: controller.isFavorite,
                  onBack: () => Navigator.of(context).pop(),
                  onFavorite: () => controller.toggleFavorite(),
                  onMenu: () => _showPopupMenu(context, controller),
                ),
                // ScrollView (整頁可捲動)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // layout_device (設備識別區)
                        _DeviceIdentificationSection(
                          deviceName: deviceName,
                          positionName: positionName,
                          isConnected: controller.isConnected,
                          onBle: () => controller.toggleBleConnection(),
                        ),
                        // rv_drop_head (泵頭列表)
                        DosingMainPumpHeadList(
                          isConnected: controller.isConnected,
                          session: session,
                          onHeadTap: (headId) {
                            // PARITY: DropMainActivity.onClickDropHead() -> navigate to DropHeadMainActivity
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PumpHeadDetailPage(
                                  headId: headId,
                                ),
                              ),
                            );
                          },
                          onHeadPlay: session.isReady
                              ? (headId) {
                                  // KC-A-FINAL: Only when ready
                                  // PARITY: DropMainViewModel.clickPlayDropHead() - check maxDrop before start
                                  final matches = session.pumpHeads
                                      .where(
                                        (h) =>
                                            h.headId.toUpperCase() ==
                                            headId.toUpperCase(),
                                      );
                                  final pumpHead = matches.isNotEmpty
                                      ? matches.first
                                      : null;
                                  if (pumpHead != null &&
                                      pumpHead.maxDrop != null &&
                                      pumpHead.todayDispensedMl >=
                                          pumpHead.maxDrop!) {
                                    _showDropOutOfRangeDialog(context);
                                    return;
                                  }
                                  final int index = _headIdToIndex(headId);
                                  controller.toggleManualDrop(index);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Progress Overlay (visibility based on controller.isLoading)
            _ProgressOverlay(visible: controller.isLoading),
          ],
        ),
      ),
    );
  }

  /// Show PopupMenu
  /// PARITY: DropMainActivity Line 95-120
  void _showPopupMenu(BuildContext context, DosingMainController controller) {
    final l10n = AppLocalizations.of(context);
    final session = context.read<AppSession>();

    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            ListTile(
              leading: CommonIconHelper.getEditIcon(
                size: 24,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.actionEdit),
              onTap: () async {
                Navigator.of(context).pop();
                // PARITY: Navigate to DropSettingActivity
                final deviceId = controller.deviceId;
                if (deviceId != null) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DropSettingPage(deviceId: deviceId),
                    ),
                  );
                }
              },
            ),
            // Delete
            ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CommonIconHelper.getDeleteIcon(
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              title: Text(l10n.actionDelete),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteDialog(context, controller);
              },
            ),
            // Reset
            ListTile(
              leading: CommonIconHelper.getResetIcon(
                size: 24,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.actionReset),
              onTap: () {
                Navigator.of(modalContext).pop();
                if (controller.isConnected && session.isReady) {
                  _showResetDialog(context, controller);
                } else {
                  showErrorSnackBar(
                    context,
                    null,
                    customMessage: l10n.deviceNotConnected,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show Delete Confirmation Dialog
  /// PARITY: DropMainActivity.createDeleteDropDialog() Line 272-282
  void _showDeleteDialog(
    BuildContext context,
    DosingMainController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.dosingDeleteDeviceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await controller.deleteDevice();
              if (!context.mounted) return;

              if (success) {
                showSuccessSnackBar(context, l10n.dosingDeleteDeviceSuccess);
                Navigator.of(context).pop(); // Return to previous page
              } else {
                showErrorSnackBar(
                  context,
                  null,
                  customMessage: l10n.dosingDeleteDeviceFailed,
                );
              }
            },
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  /// Show Drop Out Of Range Dialog
  /// PARITY: DropMainActivity.createDropOutOfRangeDialog() Line 270-278
  void _showDropOutOfRangeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dosingTodayDropOutOfRangeTitle),
        content: Text(l10n.dosingTodayDropOutOfRangeContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.deviceDeleteLedMasterPositive),
          ),
        ],
      ),
    );
  }

  /// Show Reset Confirmation Dialog
  /// PARITY: DropMainActivity.createResetDropDialog() Line 285-296
  void _showResetDialog(BuildContext context, DosingMainController controller) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dosingResetDevice),
        content: Text(l10n.dosingResetDeviceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await controller.resetDevice();
              if (!context.mounted) return;

              if (success) {
                showSuccessSnackBar(context, l10n.dosingResetDeviceSuccess);
                Navigator.of(context).pop(); // Return to previous page
              } else {
                showErrorSnackBar(
                  context,
                  null,
                  customMessage: l10n.dosingResetDeviceFailed,
                );
              }
            },
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
  }

  /// Show error toast
  void _showErrorToast(BuildContext context, AppErrorCode errorCode) {
    showErrorSnackBar(context, errorCode);
  }

  /// Convert head ID (A/B/C/D) to index (0/1/2/3)
  int _headIdToIndex(String headId) {
    final String normalized = headId.trim().toUpperCase();
    if (normalized.isEmpty) return 0;
    final int index = normalized.codeUnitAt(0) - 'A'.codeUnitAt(0);
    return index.clamp(0, 3);
  }
}

/// PARITY: toolbar_device.xml
/// - 返回按鈕 (left)
/// - 標題 (center)
/// - 喜愛按鈕 (right)
/// - 選單按鈕 (right)
/// - MaterialDivider (bottom, 2dp)
class _ToolbarDevice extends StatelessWidget {
  final String deviceName;
  final bool isFavorite;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final VoidCallback? onMenu;

  const _ToolbarDevice({
    required this.deviceName,
    required this.isFavorite,
    this.onBack,
    this.onFavorite,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 2, // dp_2 MaterialDivider
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56, // Standard AppBar height
          child: Row(
            children: [
              // Back button
              ReefIconButton(
                icon: CommonIconHelper.getBackIcon(
                  size: 24,
                  color: AppColors.onPrimary,
                ),
                onPressed: onBack,
              ),
              // Title (device name)
              Expanded(
                child: Text(
                  deviceName,
                  style: AppTextStyles.title2.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              // Favorite button
              ReefIconButton(
                icon: isFavorite
                    ? CommonIconHelper.getFavoriteSelectIcon(
                        size: 24,
                        color: AppColors.onPrimary,
                      )
                    : CommonIconHelper.getFavoriteUnselectIcon(
                        size: 24,
                        color: AppColors.onPrimary,
                      ),
                onPressed: onFavorite,
              ),
              // Menu button
              ReefIconButton(
                icon: CommonIconHelper.getMenuIcon(
                  size: 24,
                  color: AppColors.onPrimary,
                ),
                onPressed: onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PARITY: layout_device (設備識別區)
/// android/ReefB_Android/app/src/main/res/layout/activity_drop_main.xml Line 30-82
class _DeviceIdentificationSection extends StatelessWidget {
  final String deviceName;
  final String positionName;
  final bool isConnected;
  final VoidCallback? onBle;

  const _DeviceIdentificationSection({
    required this.deviceName,
    required this.positionName,
    required this.isConnected,
    this.onBle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface, // bg_aaaa
      padding: const EdgeInsets.only(left: 16, top: 8, right: 4, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: tv_name + tv_position
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // tv_name (設備名稱)
                Text(
                  deviceName,
                  style: AppTextStyles.bodyAccent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // tv_position (位置名稱)
                if (positionName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 0, right: 4),
                    child: Text(
                      positionName,
                      style: AppTextStyles.caption2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // btn_ble (BLE 圖標, 48x32dp)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _BleButton(
              width: 48,
              height: 32,
              isConnected: isConnected,
              onPressed: onBle,
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: include progress (全畫面 Loading Overlay)
class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// PARITY: btn_ble (BLE 按鈕, 48x32dp)
class _BleButton extends StatelessWidget {
  final double width;
  final double height;
  final bool isConnected;
  final VoidCallback? onPressed;

  const _BleButton({
    required this.width,
    required this.height,
    required this.isConnected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // State-aware colors
    final backgroundColor = isConnected
        ? const Color(0xFF6F916F) // Connected
        : const Color(0xFFF7F7F7); // Disconnected

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isConnected
                  ? CommonIconHelper.getConnectBackgroundIcon(
                      width: 48,
                      height: 32,
                    )
                  : CommonIconHelper.getDisconnectBackgroundIcon(
                      width: 48,
                      height: 32,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
