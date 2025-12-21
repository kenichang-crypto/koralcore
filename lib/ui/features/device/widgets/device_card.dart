import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../application/device/device_snapshot.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';

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
    final bool isConnected = device.isConnected;
    final bool isConnecting = device.isConnecting;
    final Color statusColor = isConnected
        ? ReefColors.success
        : isConnecting
        ? ReefColors.warning
        : ReefColors.textSecondary;
    final borderColor = selectionMode && isSelected
        ? ReefColors.info
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(ReefSpacing.lg),
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.lg),
        border: Border.all(color: borderColor, width: 1.5),
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
                  style: ReefTextStyles.subheaderAccent.copyWith(
                    color: ReefColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectionMode)
                IconButton(
                  onPressed: onSelect,
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? ReefColors.info
                        : ReefColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: ReefSpacing.md),
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
              stateLabel,
              style: ReefTextStyles.caption1.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: ReefSpacing.md),
          if (device.rssi != null)
            Text(
              'RSSI ${device.rssi} dBm',
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
          const Spacer(),
          if (isConnected)
            OutlinedButton(
              onPressed: selectionMode ? null : onDisconnect,
              child: Text(l10n.deviceActionDisconnect),
            )
          else
            FilledButton(
              onPressed: selectionMode || isConnecting ? null : onConnect,
              child: Text(
                isConnecting
                    ? l10n.deviceStateConnecting
                    : l10n.deviceActionConnect,
              ),
            ),
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
        return l10n.deviceStateDisconnected;
    }
  }
}
