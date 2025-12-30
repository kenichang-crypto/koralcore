import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:koralcore/shared/assets/reef_icons.dart'; // TODO: 確認 assets 路徑
import 'package:provider/provider.dart';

import '../../../../app/device/device_snapshot.dart';
import '../../../../core/ble/ble_readiness_controller.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../device/presentation/controllers/device_list_controller.dart';
import '../../../device/presentation/pages/add_device_page.dart';

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  BleReadinessController? _bleController;
  DeviceListController? _deviceListController;
  bool _wasReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bleController == null) {
      _bleController = context.read<BleReadinessController>();
      _wasReady = _bleController!.snapshot.isReady;
      _bleController!.addListener(_handleBleState);
    }
    if (_deviceListController == null) {
      _deviceListController = context.read<DeviceListController>();
      // Set up callback for new device connection (PARITY: reef-b-app's startAddDeviceLiveData)
      _deviceListController!.onNewDeviceConnected = () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddDevicePage(),
            ),
          );
        }
      };
    }
  }

  void _handleBleState() {
    final nextReady = _bleController!.snapshot.isReady;
    if (nextReady && !_wasReady && mounted) {
      context.read<DeviceListController>().refresh();
    }
    _wasReady = nextReady;
  }

  @override
  void dispose() {
    _bleController?.removeListener(_handleBleState);
    // Clear callback to prevent memory leaks
    _deviceListController?.onNewDeviceConnected = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    final readiness = context.watch<BleReadinessController>().snapshot;
    final l10n = AppLocalizations.of(context);
    final bool bleReady = readiness.isReady;

    // BLE parity: show error snackbar if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final error = controller.lastErrorCode;
      if (error != null) {
        showErrorSnackBar(context, error);
        controller.clearError();
      }
    });

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.bluetoothHeader,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ReefMainBackground(
        child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              l10n.bleDisconnectedWarning,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!bleReady) ...[
              const BleGuardBanner(),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.bleOnboardingDisabledHint,
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _ScanButton(controller: controller, bleReady: bleReady, l10n: l10n),
            const SizedBox(height: AppSpacing.xl),
            if (!bleReady)
              _BleBlockedState(l10n: l10n)
            else ...[
              _DeviceSections(controller: controller, l10n: l10n),
            ],
          ],
        ),
          ),
        ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final DeviceListController controller;
  final bool bleReady;
  final AppLocalizations l10n;

  const _ScanButton({
    required this.controller,
    required this.bleReady,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (!bleReady) {
      return FilledButton.icon(
        onPressed: () => showBleOnboardingSheet(context),
        icon: CommonIconHelper.getWarningIcon(size: 20),
        label: Text(l10n.bleOnboardingPermissionCta),
      );
    }

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryStrong,
      ),
      onPressed: controller.isScanning
          ? null
          : () {
              controller.refresh();
            },
      icon: controller.isScanning
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : CommonIconHelper.getBluetoothIcon(size: 18),
      label: Text(
        controller.isScanning ? l10n.bluetoothScanning : l10n.bluetoothScanCta,
      ),
    );
  }
}

class _DeviceSections extends StatelessWidget {
  final DeviceListController controller;
  final AppLocalizations l10n;

  const _DeviceSections({required this.controller, required this.l10n});

  /// Show disconnect confirmation dialog.
  /// PARITY: reef-b-app's createDisconnectBluetoothDialog(data)
  void _showDisconnectDialog(BuildContext context, String deviceId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        content: Text(l10n.bluetoothDisconnectDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.bluetoothDisconnectDialogNegative),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.disconnect(deviceId);
            },
            child: Text(l10n.bluetoothDisconnectDialogPositive),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedDevices = controller.savedDevices;
    final discoveredDevices = controller.discoveredDevices;
    final bool isScanning = controller.isScanning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: fragment_bluetooth.xml - rv_user_device with marginTop 12dp, marginBottom 12dp
        if (savedDevices.isNotEmpty) ...[
          for (int i = 0; i < savedDevices.length; i++) ...[
            _BtMyDeviceTile(
              device: savedDevices[i],
              onConnect: () => controller.connect(savedDevices[i].id),
              onDisconnect: () => _showDisconnectDialog(context, savedDevices[i].id),
            ),
            if (i != savedDevices.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
        // PARITY: fragment_bluetooth.xml - tv_other_device_title with marginTop 24dp, marginStart 16dp
        // Title changes based on savedDevices.isEmpty:
        // - If empty: "Device" (l10n.deviceHeader)
        // - If not empty: "Other Devices" (l10n.bluetoothOtherDevice)
        const SizedBox(height: AppSpacing.xl), // dp_24 marginTop
        _SectionHeaderWithScanButton(
          title: savedDevices.isEmpty ? l10n.deviceHeader : l10n.bluetoothOtherDevice,
          controller: controller,
          isScanning: isScanning,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DiscoveredSection(
          controller: controller,
          l10n: l10n,
          devices: discoveredDevices,
          isScanning: isScanning,
        ),
      ],
    );
  }
}

class _DiscoveredSection extends StatelessWidget {
  final DeviceListController controller;
  final AppLocalizations l10n;
  final List<DeviceSnapshot> devices;
  final bool isScanning;

  const _DiscoveredSection({
    required this.controller,
    required this.l10n,
    required this.devices,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isScanning) const _ScanningRow(),
        if (!isScanning && devices.isEmpty)
          _DiscoveredEmptyCard(l10n: l10n)
        else ...[
          for (int i = 0; i < devices.length; i++) ...[
            _BtDeviceTile(
              device: devices[i],
              onConnect: () => controller.connect(devices[i].id),
              onDisconnect: () => controller.disconnect(devices[i].id),
            ),
            if (i != devices.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _ScanningRow extends StatelessWidget {
  const _ScanningRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            l10n.bluetoothScanning,
            style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _BleBlockedState extends StatelessWidget {
  final AppLocalizations l10n;

  const _BleBlockedState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(kBluetoothIcon, width: 48, height: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.bleOnboardingBlockedEmptyTitle,
                style: AppTextStyles.subheaderAccent.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.bleOnboardingBlockedEmptyCopy,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => showBleOnboardingSheet(context),
                child: Text(l10n.bleOnboardingLearnMore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bluetooth device tile matching adapter_ble_scan.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_ble_scan.xml structure:
/// - Outer ConstraintLayout with selectableItemBackground
/// - Inner ConstraintLayout with bg_aaaa background, padding 16/8dp
/// - tv_ble_type: caption2_accent, text_aa
/// - tv_ble_name: body_accent, text_aaaa
/// - MaterialDivider: 1dp, bg_press
class _BtDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _BtDeviceTile({
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final String deviceType = kind == _DeviceKind.led
        ? 'LED' // TODO: Use l10n.led when available
        : 'DROP'; // TODO: Use l10n.drop when available

    // PARITY: adapter_ble_scan.xml structure
    return InkWell(
      onTap: device.isConnected ? onDisconnect : onConnect,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (bg_aaaa background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16
              top: AppSpacing.xs, // dp_8
              right: AppSpacing.md, // dp_16
              bottom: AppSpacing.xs, // dp_8
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // bg_aaaa
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Device type (tv_ble_type)
                // PARITY: caption2_accent, text_aa
                Text(
                  deviceType,
                  style: AppTextStyles.caption2Accent.copyWith(
                    color: AppColors.textSecondary, // text_aa
                  ),
                ),
                // Device name (tv_ble_name)
                // PARITY: body_accent, text_aaaa
                Text(
                  device.name,
                  style: AppTextStyles.bodyAccent.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Divider (MaterialDivider)
          // PARITY: 1dp height, bg_press color
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

enum _DeviceKind { led, doser }

/// BLE My Device tile matching adapter_ble_my_device.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_ble_my_device.xml structure:
/// - ConstraintLayout: selectableItemBackground
/// - Inner: white background, padding 16/8/16/8dp
/// - tv_ble_type: caption2_accent, text_aa
/// - tv_name: body_accent, text_aa
/// - tv_position: caption2, text_aa
/// - tv_group: caption2, text_aa (visibility gone by default)
/// - img_led_master: 12×12dp (ic_master)
/// - img_ble: 48×32dp (ic_disconnect_background or ic_connect_background)
/// - Divider: bg_press
class _BtMyDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _BtMyDeviceTile({
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final String deviceType = kind == _DeviceKind.led
        ? l10n.sectionLedTitle
        : l10n.sectionDosingTitle;
    
    // TODO: Get position and group from DeviceSnapshot when available
    final String? positionName = null; // TODO: Get from device.sinkId
    final String? groupName = null; // TODO: Get from device.group
    final bool isMaster = device.isMaster;
    final bool isConnected = device.isConnected;

    // PARITY: adapter_ble_my_device.xml structure
    return InkWell(
      onTap: isConnected ? onDisconnect : onConnect,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (white background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16 paddingStart
              top: AppSpacing.xs, // dp_8 paddingTop
              right: AppSpacing.md, // dp_16 paddingEnd
              bottom: AppSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // white background
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column (texts)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Device type (tv_ble_type) - caption2_accent, text_aa
                      Text(
                        deviceType,
                        style: AppTextStyles.caption2Accent.copyWith(
                          color: AppColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Device name (tv_name) - body_accent, text_aa or text_aaaa
                      // PARITY: adapter_ble_my_device.xml - textColor changes based on connection state
                      // - Connected: text_aaaa (AppColors.textPrimary)
                      // - Disconnected: text_aa (AppColors.textSecondary)
                      Text(
                        device.name,
                        style: AppTextStyles.bodyAccent.copyWith(
                          color: isConnected
                              ? AppColors.textPrimary // text_aaaa when connected
                              : AppColors.textSecondary, // text_aa when disconnected
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Position and group row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Position (tv_position) - caption2, text_aa
                          if (positionName != null) ...[
                            Text(
                              positionName,
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                          // Group (tv_group) - caption2, text_aa (visibility gone by default)
                          if (groupName != null) ...[
                            Text(
                              groupName,
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                          ],
                          // Master icon (img_led_master) - 12×12dp
                          // PARITY: adapter_ble_my_device.xml - ic_master
                          if (isMaster)
                            CommonIconHelper.getMasterIcon(size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs), // dp_4 marginEnd
                // BLE status icon (img_ble) - 48×32dp
                // PARITY: adapter_ble_my_device.xml - ic_connect_background or ic_disconnect_background
                isConnected
                    ? CommonIconHelper.getConnectBackgroundIcon(width: 48, height: 32)
                    : CommonIconHelper.getDisconnectBackgroundIcon(width: 48, height: 32),
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

class _DeviceKindHelper {
  static _DeviceKind fromName(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}


/// Section header with scan button on the right.
/// PARITY: fragment_bluetooth.xml - tv_other_device_title + btn_refresh + progress_scan
class _SectionHeaderWithScanButton extends StatelessWidget {
  final String title;
  final DeviceListController controller;
  final bool isScanning;
  final AppLocalizations l10n;

  const _SectionHeaderWithScanButton({
    required this.title,
    required this.controller,
    required this.isScanning,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_bluetooth.xml structure
    // - tv_other_device_title: marginStart 16dp, marginTop 24dp, subheader_accent
    // - btn_refresh: marginEnd 16dp, padding 5/3/5/3dp, caption1, bg_primary color
    // - progress_scan: covers btn_refresh when scanning
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md, // dp_16 marginStart
        right: AppSpacing.md, // dp_16 marginEnd
      ),
      child: Row(
        children: [
          // Title (tv_other_device_title)
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.subheaderAccent.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
          // Scan button (btn_refresh) with progress indicator overlay
          Stack(
            alignment: Alignment.center,
            children: [
              // Button (btn_refresh) - PARITY: TextViewCanClick style
              TextButton(
                onPressed: isScanning
                    ? null
                    : () {
                        controller.refresh();
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0, // dp_5 paddingStart/End
                    vertical: 3.0, // dp_3 paddingTop/Bottom
                  ),
                  foregroundColor: AppColors.primaryStrong, // bg_primary color
                ),
                child: Text(
                  l10n.bluetoothRearrangement,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.primaryStrong,
                  ),
                ),
              ),
              // Progress indicator (progress_scan) - PARITY: covers btn_refresh when scanning
              if (isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscoveredEmptyCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _DiscoveredEmptyCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_bluetooth.xml - layout_no_other_device
    // - marginTop 55dp, marginBottom 55dp
    // - text_no_other_device_title: subheader_accent, text_aaaa
    // - text_no_other_device_content: body, text_aaa, marginTop 8dp
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55.0), // dp_55 marginTop/Bottom
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.bluetoothNoOtherDeviceTitle,
            style: AppTextStyles.subheaderAccent.copyWith(
              color: AppColors.textPrimary, // text_aaaa
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs), // dp_8 marginTop
          Text(
            l10n.bluetoothNoOtherDeviceContent,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary, // text_aaa
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
