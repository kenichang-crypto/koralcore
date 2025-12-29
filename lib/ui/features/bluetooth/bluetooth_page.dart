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
import '../device/controllers/device_list_controller.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BleReadinessController? _bleController;
  bool _wasReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bleController == null) {
      _bleController = context.read<BleReadinessController>();
      _wasReady = _bleController!.snapshot.isReady;
      _bleController!.addListener(_handleBleState);
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
      appBar: AppBar(
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
        icon: const Icon(Icons.lock_outline),
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
          : const Icon(Icons.bluetooth_searching),
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
            _BtDeviceTile(
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
    final l10n = AppLocalizations.of(context);
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReefSpacing.lg,
        vertical: ReefSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DeviceIcon(device: device),
              const SizedBox(width: ReefSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: ReefTextStyles.subheaderAccent.copyWith(
                        color: ReefColors.textPrimary,
                      ),
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
              _DeviceActionButton(
                isConnected: isConnected,
                isConnecting: isConnecting,
                onConnect: onConnect,
                onDisconnect: onDisconnect,
                l10n: l10n,
              ),
            ],
          ),
          if (device.rssi != null) ...[
            const SizedBox(height: ReefSpacing.sm),
            Text(
              'RSSI ${device.rssi} dBm',
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceIcon extends StatelessWidget {
  final DeviceSnapshot device;

  const _DeviceIcon({required this.device});

  @override
  Widget build(BuildContext context) {
    // parity: 優先用 type 判斷
    final type = device.type?.toLowerCase();
    final bool isLed =
        type == 'led' ||
        (type == null && device.name.toLowerCase().contains('led'));
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: ReefColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
      child: Center(
        child: Image.asset(
          isLed ? kDeviceLedIcon : kDeviceDoserIcon,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}

class _DeviceActionButton extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final AppLocalizations l10n;

  const _DeviceActionButton({
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    required this.onDisconnect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return OutlinedButton(
        onPressed: onDisconnect,
        child: Text(l10n.deviceActionDisconnect),
      );
    }
    return FilledButton(
      onPressed: isConnecting ? null : onConnect,
      child: Text(
        isConnecting ? l10n.deviceStateConnecting : l10n.bluetoothConnect,
      ),
    );
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
