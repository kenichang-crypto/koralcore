import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/device/device_snapshot.dart';
import '../../../application/system/ble_readiness_controller.dart';
import '../../components/ble_guard.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
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

    return Scaffold(
      backgroundColor: ReefColors.primaryStrong,
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        title: Text(l10n.bluetoothHeader),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bleDisconnectedWarning,
                style: ReefTextStyles.body.copyWith(color: ReefColors.surface),
              ),
              const SizedBox(height: ReefSpacing.md),
              if (!bleReady) ...[
                const BleGuardBanner(),
                const SizedBox(height: ReefSpacing.lg),
              ],
              _ScanButton(
                controller: controller,
                bleReady: bleReady,
                l10n: l10n,
              ),
              if (!bleReady) ...[
                const SizedBox(height: ReefSpacing.sm),
                Text(
                  l10n.bleOnboardingDisabledHint,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.surface.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: ReefSpacing.lg),
              Expanded(
                child: bleReady
                    ? _DeviceList(controller: controller, l10n: l10n)
                    : _BleBlockedState(l10n: l10n),
              ),
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

class _DeviceList extends StatelessWidget {
  final DeviceListController controller;
  final AppLocalizations l10n;

  const _DeviceList({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final savedDevices = controller.savedDevices;
    final discoveredDevices = controller.discoveredDevices;

    return ListView(
      children: [
        _SectionHeader(title: l10n.deviceHeader),
        if (savedDevices.isEmpty)
          const _SavedEmptyCard()
        else ...[
          ...savedDevices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: ReefSpacing.md),
              child: _DeviceTile(
                device: device,
                onConnect: () => controller.connect(device.id),
                onDisconnect: () => controller.disconnect(device.id),
              ),
            ),
          ),
        ],
        const SizedBox(height: ReefSpacing.lg),
        _SectionHeader(title: l10n.bluetoothHeader),
        if (discoveredDevices.isEmpty)
          _DiscoveredEmptyCard(l10n: l10n)
        else ...[
          ...discoveredDevices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: ReefSpacing.md),
              child: _DeviceTile(
                device: device,
                onConnect: () => controller.connect(device.id),
                onDisconnect: () => controller.disconnect(device.id),
              ),
            ),
          ),
        ],
      ],
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
              Icon(
                Icons.bluetooth_disabled,
                size: 48,
                color: ReefColors.warning,
              ),
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

class _DeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceTile({
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: ReefTextStyles.subheaderAccent.copyWith(
                      color: ReefColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.md,
                    vertical: ReefSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ReefRadius.md),
                  ),
                  child: Text(
                    statusLabel,
                    style: ReefTextStyles.caption1.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            const SizedBox(height: ReefSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: isConnected
                  ? OutlinedButton(
                      onPressed: onDisconnect,
                      child: Text(l10n.deviceActionDisconnect),
                    )
                  : FilledButton(
                      onPressed: isConnecting ? null : onConnect,
                      child: Text(
                        isConnecting
                            ? l10n.deviceStateConnecting
                            : l10n.bluetoothConnect,
                      ),
                    ),
            ),
          ],
        ),
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
            Icon(
              Icons.devices_other,
              size: 40,
              color: ReefColors.textSecondary,
            ),
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
