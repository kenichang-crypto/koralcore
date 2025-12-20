import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/device/device_snapshot.dart';
import '../../../application/system/ble_readiness_controller.dart';
import '../../../theme/dimensions.dart';
import '../../components/ble_guard.dart';
import '../device/controllers/device_list_controller.dart';
import 'package:koralcore/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final bool bleReady = readiness.isReady;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bluetoothHeader, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.bleDisconnectedWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            if (!bleReady) ...[
              const SizedBox(height: AppDimensions.spacingL),
              const BleGuardBanner(),
            ] else ...[
              const SizedBox(height: AppDimensions.spacingXL),
            ],
            _ScanButton(controller: controller, bleReady: bleReady, l10n: l10n),
            if (!bleReady) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                l10n.bleOnboardingDisabledHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ] else ...[
              const SizedBox(height: AppDimensions.spacingL),
            ],
            Expanded(
              child: bleReady
                  ? _DeviceList(controller: controller, l10n: l10n)
                  : _BleBlockedState(l10n: l10n),
            ),
          ],
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
    if (controller.devices.isEmpty) {
      return Center(
        child: Text(
          l10n.bluetoothEmptyState,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.black45),
        ),
      );
    }

    return ListView.separated(
      itemCount: controller.devices.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        final device = controller.devices[index];
        return _DeviceTile(
          device: device,
          onConnect: () => controller.connect(device.id),
          onDisconnect: () => controller.disconnect(device.id),
        );
      },
    );
  }
}

class _BleBlockedState extends StatelessWidget {
  final AppLocalizations l10n;

  const _BleBlockedState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth_disabled, size: 48, color: Colors.black38),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            l10n.bleOnboardingBlockedEmptyTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            l10n.bleOnboardingBlockedEmptyCopy,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          TextButton(
            onPressed: () => showBleOnboardingSheet(context),
            child: Text(l10n.bleOnboardingLearnMore),
          ),
        ],
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingS,
        ),
        title: Text(device.name),
        subtitle: Text(_subtitle(l10n)),
        trailing: device.isConnected
            ? TextButton(
                onPressed: onDisconnect,
                child: Text(l10n.deviceActionDisconnect),
              )
            : ElevatedButton(
                onPressed: device.isConnecting ? null : onConnect,
                child: Text(
                  device.isConnecting
                      ? l10n.deviceStateConnecting
                      : l10n.bluetoothConnect,
                ),
              ),
      ),
    );
  }

  String _subtitle(AppLocalizations l10n) {
    final buffer = StringBuffer();
    buffer.write(
      device.isConnected
          ? l10n.deviceStateConnected
          : l10n.deviceStateDisconnected,
    );
    if (device.rssi != null) {
      buffer.write(' • RSSI ${device.rssi} dBm');
    }
    return buffer.toString();
  }
}
