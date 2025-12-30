import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../core/ble/ble_readiness_controller.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../app/device/device_snapshot.dart';
import '../../../led/presentation/pages/led_main_page.dart';
import '../../../doser/presentation/pages/dosing_main_page.dart';
import '../../../../app/navigation_controller.dart';
import '../controllers/device_list_controller.dart';
import '../widgets/device_card.dart';
import 'add_device_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Refresh BLE status and device list when page opens
      context.read<BleReadinessController>().refresh();
      context.read<DeviceListController>().refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh BLE status when app resumes (e.g., returning from settings)
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<BleReadinessController>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    _maybeShowError(controller.lastErrorCode);
    final l10n = AppLocalizations.of(context);

    final bool selectionMode = controller.selectionMode;
    return Scaffold(
      appBar: ReefAppBar(
        // PARITY: toolbar_app.xml - background="@color/white"
        backgroundColor: AppColors.surface, // white
        foregroundColor: AppColors.textPrimary, // text_aaaa
        elevation: 0,
        leading: selectionMode
            ? IconButton(
                icon: CommonIconHelper.getCloseIcon(
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                onPressed: controller.exitSelectionMode,
              )
            : controller.savedDevices.isEmpty
            ? null
            : // PARITY: toolbar_app.xml - btn_choose MaterialButton, layout_gravity="start", visibility GONE (default)
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // dp_8 marginEnd
                child: TextButton(
                  onPressed: controller.enterSelectionMode,
                  child: Text(
                    l10n.deviceSelectMode, // PARITY: fragment_device_select
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
        // PARITY: toolbar_app.xml - toolbar_title layout_gravity="center", textAppearance="@style/body", textColor="@color/text_aaaa"
        // PARITY: reef-b-app MainActivity keeps title as "設備" even in delete mode
        title: Text(
          l10n.deviceHeader, // PARITY: fragment_device_title = "設備"
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary, // text_aaaa
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          if (selectionMode)
            // PARITY: toolbar_app.xml - btn_delete ImageView 24x24dp, src="@drawable/ic_delete"
            IconButton(
              icon: CommonIconHelper.getDeleteIcon(
                size: 24,
                color: AppColors.textPrimary,
              ),
              onPressed: controller.selectedIds.isEmpty
                  ? null
                  : () => _confirmDelete(context, controller),
            )
          else
            // PARITY: toolbar_app.xml - btn_right ImageView 56x44dp, src="@drawable/ic_warning"
            IconButton(
              icon: CommonIconHelper.getWarningIcon(
                size: 24, // Will be adjusted to 56x44dp if needed
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                // TODO: Implement warning action
              },
            ),
        ],
      ),
      body: ReefMainBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer<BleReadinessController>(
                    builder: (context, bleController, _) {
                      if (bleController.snapshot.isReady) {
                        return const SizedBox.shrink();
                      }
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: BleGuardBanner(),
                      );
                    },
                  ),
                ),
                // PARITY: fragment_device.xml - No action bar, only RecyclerView or empty state
                // Action bar removed to match reef-b-app
                // PARITY: fragment_device.xml - No section header, only RecyclerView or empty state
                if (controller.savedDevices.isEmpty)
                  SliverToBoxAdapter(child: _EmptyState(l10n: l10n))
                else
                  // PARITY: fragment_device.xml - RecyclerView marginStart/End 10dp, marginTop/Bottom 8dp
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 10.0, // dp_10 marginStart
                      right: 10.0, // dp_10 marginEnd
                      top: 8.0, // dp_8 marginTop
                      bottom: 8.0, // dp_8 marginBottom
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing:
                                0, // Cards have their own margin (6dp)
                            crossAxisSpacing:
                                0, // Cards have their own margin (6dp)
                            childAspectRatio: 1.0, // Adjusted for card content
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final device = controller.savedDevices[index];
                        final isSelected = controller.selectedIds.contains(
                          device.id,
                        );
                        return _DeviceCardWithSink(
                          device: device,
                          selectionMode: controller.selectionMode,
                          isSelected: isSelected,
                          onSelect: () => controller.toggleSelection(device.id),
                          onTap: () =>
                              _navigateToDeviceMainPage(context, device),
                        );
                      }, childCount: controller.savedDevices.length),
                    ),
                  ),
                // PARITY: fragment_device.xml - Only shows saved devices (rv_user_device), no "Other Devices" section
                // Discovered devices section removed to match reef-b-app
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddDevicePage()));
        },
        icon: CommonIconHelper.getAddIcon(size: 24),
        label: Text(l10n.deviceActionAdd),
      ),
    );
  }

  /// Show delete confirmation dialog.
  /// PARITY: reef-b-app DeviceFragment.createDeleteLedDialog()
  Future<void> _confirmDelete(
    BuildContext context,
    DeviceListController controller,
  ) async {
    final l10n = AppLocalizations.of(context);

    // PARITY: reef-b-app checks LED master deletion restriction before showing dialog
    // reef-b-app: tmpList.forEach { if (it.type == DeviceType.LED && !viewModel.canDeleteDevice(it)) { createDeleteLedMasterDialog(); return } }
    final selectedDevices = controller.savedDevices
        .where((d) => controller.selectedIds.contains(d.id))
        .toList();

    for (final device in selectedDevices) {
      if (device.type?.toUpperCase() == 'LED') {
        final bool canDelete = await controller.canDeleteDevice(device.id);
        if (!canDelete) {
          // PARITY: reef-b-app createDeleteLedMasterDialog()
          await _showDeleteLedMasterDialog(context, controller, l10n);
          return;
        }
      }
    }

    // PARITY: reef-b-app createDeleteLedDialog() - no title, only content
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // PARITY: reef-b-app createDeleteLedDialog() has no title parameter
          // Only content is passed: content = getString(R.string.dialog_device_delete)
          content: Text(l10n.deviceDeleteConfirmMessage),
          actions: [
            // PARITY: dialog_device_delete_led_negative = "取消"
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.deviceDeleteConfirmSecondary),
            ),
            // PARITY: dialog_device_delete_led_positive = "刪除"
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deviceDeleteConfirmPrimary),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.removeSelected();
      if (!context.mounted) return;

      // PARITY: reef-b-app deleteDeviceLiveData.observe() - shows toast on success/failure
      final AppErrorCode? errorCode = controller.lastErrorCode;
      if (errorCode != null) {
        // PARITY: toast_delete_device_failed
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.toastDeleteDeviceFailed)));
        controller.clearError();
      } else {
        // PARITY: toast_delete_device_successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastDeleteDeviceSuccessful)),
        );
      }
    }
  }

  /// Show LED master deletion restriction dialog.
  /// PARITY: reef-b-app DeviceFragment.createDeleteLedMasterDialog()
  Future<void> _showDeleteLedMasterDialog(
    BuildContext context,
    DeviceListController controller,
    AppLocalizations l10n,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // PARITY: dialog_device_delete_led_master_title = "主從設定"
          title: Text(l10n.deviceDeleteLedMasterTitle),
          // PARITY: dialog_device_delete_led_master_content = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈"
          content: Text(l10n.deviceDeleteLedMasterContent),
          actions: [
            // PARITY: dialog_device_delete_led_master_positive = "我瞭解了"
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // PARITY: reef-b-app closes delete mode after clicking "我知道了"
                controller.exitSelectionMode();
              },
              child: Text(l10n.deviceDeleteLedMasterPositive),
            ),
          ],
        );
      },
    );
  }

  void _maybeShowError(AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<DeviceListController>();
      showErrorSnackBar(context, code);
      controller.clearError();
    });
  }

  /// Navigate to device main page (LED or Dosing).
  /// PARITY: reef-b-app DeviceFragment.onClickDevice()
  void _navigateToDeviceMainPage(BuildContext context, DeviceSnapshot device) {
    final session = context.read<AppSession>();

    // PARITY: reef-b-app sets active device before navigating
    session.setActiveDevice(device.id);

    // PARITY: reef-b-app navigates based on device type
    final deviceType = device.type?.toUpperCase();
    final Widget page;
    if (deviceType == 'LED') {
      page = const LedMainPage();
    } else {
      page = const DosingMainPage();
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

/// DeviceCard wrapper that loads sink name and passes to DeviceCard.
/// PARITY: reef-b-app DeviceAdapter.bind() gets sink name from dbSink.getSinkById()
class _DeviceCardWithSink extends StatelessWidget {
  final DeviceSnapshot device;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onTap;

  const _DeviceCardWithSink({
    required this.device,
    required this.selectionMode,
    required this.isSelected,
    this.onSelect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();

    // PARITY: reef-b-app DeviceAdapter.bind() - dbSink.getSinkById(it)?.name ?: unassigned_device
    String? sinkName;
    if (device.sinkId != null && device.sinkId!.isNotEmpty) {
      final sinks = appContext.sinkRepository.getCurrentSinks();
      final sink = sinks.firstWhere(
        (s) => s.id == device.sinkId,
        orElse: () =>
            const Sink(id: '', name: '', type: SinkType.custom, deviceIds: []),
      );
      if (sink.id.isNotEmpty) {
        sinkName = sink.name;
      }
    }

    return DeviceCard(
      device: device,
      selectionMode: selectionMode,
      isSelected: isSelected,
      onSelect: onSelect,
      onTap: onTap,
      sinkName: sinkName,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_device.xml - layout_no_device
    // ImageView: 172x199dp, marginTop 39dp
    // MaterialButton: marginTop 8dp, marginBottom 8dp
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PARITY: img_device_robot - 172x199dp
          // Note: img_device_robot.xml is a complex vector drawable, using placeholder for now
          // TODO: Convert img_device_robot.xml to SVG or PNG
          Container(
            width: 172.0, // dp_172
            height: 199.0, // dp_199
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.devices_other,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          // PARITY: TextView - text_no_device_title, marginTop 39dp
          Padding(
            padding: const EdgeInsets.only(top: 39.0), // dp_39 marginTop
            child: Text(
              l10n.deviceEmptyTitle, // PARITY: text_no_device_title
              style: AppTextStyles.subheaderAccent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // PARITY: MaterialButton - btn_add_device, marginTop 8dp, marginBottom 8dp
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0, // dp_8 marginTop
              bottom: 8.0, // dp_8 marginBottom
            ),
            child: FilledButton(
              // PARITY: onClick -> mainViewModel.navigateToBluetoothLiveData.value = Unit
              onPressed: () {
                // Navigate to Bluetooth page (second tab, index 1)
                final navController = context.read<NavigationController>();
                navController.select(1);
              },
              child: Text(l10n.deviceActionAdd), // PARITY: add_device
            ),
          ),
        ],
      ),
    );
  }
}
