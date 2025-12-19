import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/device/device_snapshot.dart';
import '../../../theme/dimensions.dart';
import '../device/controllers/device_list_controller.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bluetoothHeader,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.bleDisconnectedWarning,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            FilledButton.icon(
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
                controller.isScanning
                    ? l10n.bluetoothScanning
                    : l10n.bluetoothScanCta,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Expanded(
              child: controller.devices.isEmpty
                  ? Center(
                      child: Text(
                        l10n.bluetoothEmptyState,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.black45),
                      ),
                    )
                  : ListView.separated(
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
                    ),
            ),
          ],
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
