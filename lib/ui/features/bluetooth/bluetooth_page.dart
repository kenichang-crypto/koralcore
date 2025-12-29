import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:koralcore/ui/assets/reef_icons.dart';
import 'package:provider/provider.dart';

import '../../../application/device/device_snapshot.dart';
import '../../../application/system/ble_readiness_controller.dart';
import '../../components/ble_guard.dart';
import '../../components/error_state_widget.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../../widgets/reef_backgrounds.dart';
import '../../widgets/reef_app_bar.dart';
import '../../assets/common_icon_helper.dart';
import '../device/controllers/device_list_controller.dart';
import '../device/pages/add_device_page.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
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
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.bluetoothHeader,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ReefMainBackground(
        child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          children: [
            Text(
              l10n.bleDisconnectedWarning,
              style: ReefTextStyles.body.copyWith(color: ReefColors.textPrimary),
            ),
            const SizedBox(height: ReefSpacing.md),
            if (!bleReady) ...[
              const BleGuardBanner(),
              const SizedBox(height: ReefSpacing.md),
              Text(
                l10n.bleOnboardingDisabledHint,
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textPrimary,
                ),
              ),
              const SizedBox(height: ReefSpacing.md),
            ],
            _ScanButton(controller: controller, bleReady: bleReady, l10n: l10n),
            const SizedBox(height: ReefSpacing.xl),
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
        backgroundColor: ReefColors.surface,
        foregroundColor: ReefColors.primaryStrong,
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

  @override
  Widget build(BuildContext context) {
    final savedDevices = controller.savedDevices;
    final discoveredDevices = controller.discoveredDevices;
    final bool isScanning = controller.isScanning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.deviceHeader),
        const SizedBox(height: ReefSpacing.sm),
        if (savedDevices.isEmpty)
          const _SavedEmptyCard()
        else ...[
          for (int i = 0; i < savedDevices.length; i++) ...[
            _BtMyDeviceTile(
              device: savedDevices[i],
              onConnect: () => controller.connect(savedDevices[i].id),
              onDisconnect: () => controller.disconnect(savedDevices[i].id),
            ),
            if (i != savedDevices.length - 1)
              const SizedBox(height: ReefSpacing.md),
          ],
        ],
        const SizedBox(height: ReefSpacing.xl),
        _SectionHeader(title: l10n.bluetoothHeader),
        const SizedBox(height: ReefSpacing.sm),
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
            if (i != devices.length - 1) const SizedBox(height: ReefSpacing.md),
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
      padding: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: ReefSpacing.md),
          Text(
            l10n.bluetoothScanning,
            style: ReefTextStyles.caption1.copyWith(color: ReefColors.textPrimary),
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
        color: ReefColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReefRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ReefSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(kBluetoothIcon, width: 48, height: 48),
              const SizedBox(height: ReefSpacing.md),
              Text(
                l10n.bleOnboardingBlockedEmptyTitle,
                style: ReefTextStyles.subheaderAccent.copyWith(
                  color: ReefColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ReefSpacing.sm),
              Text(
                l10n.bleOnboardingBlockedEmptyCopy,
                style: ReefTextStyles.body.copyWith(
                  color: ReefColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ReefSpacing.lg),
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
              left: ReefSpacing.md, // dp_16
              top: ReefSpacing.xs, // dp_8
              right: ReefSpacing.md, // dp_16
              bottom: ReefSpacing.xs, // dp_8
            ),
            decoration: BoxDecoration(
              color: ReefColors.surface, // bg_aaaa
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Device type (tv_ble_type)
                // PARITY: caption2_accent, text_aa
                Text(
                  deviceType,
                  style: ReefTextStyles.caption2Accent.copyWith(
                    color: ReefColors.textSecondary, // text_aa
                  ),
                ),
                // Device name (tv_ble_name)
                // PARITY: body_accent, text_aaaa
                Text(
                  device.name,
                  style: ReefTextStyles.bodyAccent.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
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
            color: ReefColors.surfacePressed, // bg_press
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
              left: ReefSpacing.md, // dp_16 paddingStart
              top: ReefSpacing.xs, // dp_8 paddingTop
              right: ReefSpacing.md, // dp_16 paddingEnd
              bottom: ReefSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: ReefColors.surface, // white background
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
                        style: ReefTextStyles.caption2Accent.copyWith(
                          color: ReefColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Device name (tv_name) - body_accent, text_aa
                      Text(
                        device.name,
                        style: ReefTextStyles.bodyAccent.copyWith(
                          color: ReefColors.textSecondary, // text_aa
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
                              style: ReefTextStyles.caption2.copyWith(
                                color: ReefColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
                          // Group (tv_group) - caption2, text_aa (visibility gone by default)
                          if (groupName != null) ...[
                            Text(
                              groupName,
                              style: ReefTextStyles.caption2.copyWith(
                                color: ReefColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
                          ],
                          // Master icon (img_led_master) - 12×12dp
                          if (isMaster)
                            Image.asset(
                              'assets/icons/ic_master.png', // TODO: Add icon asset
                              width: 12, // dp_12
                              height: 12, // dp_12
                              errorBuilder: (context, error, stackTrace) => CommonIconHelper.getFavoriteSelectIcon(
                                size: 12,
                                color: ReefColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ReefSpacing.xs), // dp_4 marginEnd
                // BLE status icon (img_ble) - 48×32dp
                Image.asset(
                  isConnected
                      ? 'assets/icons/ic_connect_background.png' // TODO: Add icon asset
                      : 'assets/icons/ic_disconnect_background.png', // TODO: Add icon asset
                  width: 48, // dp_48
                  height: 32, // dp_32
                  errorBuilder: (context, error, stackTrace) => CommonIconHelper.getBluetoothIcon(
                    size: 32,
                    color: isConnected ? ReefColors.success : ReefColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: ReefColors.surfacePressed, // bg_press
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


class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: Text(
        title,
        style: ReefTextStyles.subheaderAccent.copyWith(
          color: ReefColors.surface,
        ),
      ),
    );
  }
}

class _SavedEmptyCard extends StatelessWidget {
  const _SavedEmptyCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.deviceEmptyTitle,
              style: ReefTextStyles.subheaderAccent.copyWith(
                color: ReefColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              l10n.deviceEmptySubtitle,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveredEmptyCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _DiscoveredEmptyCard({required this.l10n});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(kDeviceEmptyIcon, width: 40, height: 40),
            const SizedBox(height: ReefSpacing.md),
            Text(
              l10n.bluetoothEmptyState,
              style: ReefTextStyles.subheaderAccent.copyWith(
                color: ReefColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              l10n.bluetoothScanCta,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
