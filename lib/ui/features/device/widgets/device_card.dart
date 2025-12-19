import 'package:flutter/material.dart';

import '../../../../application/device/device_snapshot.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class DeviceCard extends StatelessWidget {
  final DeviceSnapshot device;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  const DeviceCard({
    super.key,
    required this.device,
    required this.selectionMode,
    required this.isSelected,
    this.onSelect,
    this.onConnect,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stateLabel = _stateLabel(l10n);
    final theme = Theme.of(context);

    Widget actionButton;
    if (device.isConnected) {
      actionButton = OutlinedButton(
        onPressed: selectionMode ? null : onDisconnect,
        child: Text(l10n.deviceActionDisconnect),
      );
    } else {
      actionButton = FilledButton(
        onPressed: selectionMode || device.isConnecting ? null : onConnect,
        child: Text(
          device.isConnecting
              ? l10n.deviceStateConnecting
              : l10n.deviceActionConnect,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isSelected ? AppColors.ocean500 : AppColors.grey100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  device.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectionMode)
                IconButton(
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? AppColors.ocean500 : AppColors.grey300,
                  ),
                  onPressed: onSelect,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Chip(
            label: Text(stateLabel),
            backgroundColor: device.isConnected
                ? AppColors.success.withOpacity(.12)
                : AppColors.grey050,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: device.isConnected ? AppColors.success : AppColors.grey700,
            ),
            side: BorderSide.none,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          if (device.rssi != null)
            Text(
              'RSSI ${device.rssi} dBm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          const Spacer(),
          actionButton,
        ],
      ),
    );
  }

  String _stateLabel(AppLocalizations l10n) {
    switch (device.state) {
      case DeviceConnectionState.connected:
        return l10n.deviceStateConnected;
      case DeviceConnectionState.connecting:
        return l10n.deviceStateConnecting;
      case DeviceConnectionState.disconnected:
      default:
        return l10n.deviceStateDisconnected;
    }
  }
}
