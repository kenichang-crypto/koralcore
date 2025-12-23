import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:koralcore/ui/assets/reef_icons.dart';

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
    final _DeviceKind deviceKind = _resolveKind(device.name);
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeviceIcon(kind: deviceKind),
              const SizedBox(width: ReefSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: ReefTextStyles.subheaderAccent.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ReefSpacing.xs),
                    _ChipLabel(
                      label: deviceKind == _DeviceKind.led
                          ? l10n.sectionLedTitle
                          : l10n.sectionDosingTitle,
                      foreground: ReefColors.primary,
                    ),
                  ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: ReefSpacing.sm),
              Text(
                stateLabel,
                style: ReefTextStyles.body.copyWith(color: statusColor),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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

  _DeviceKind _resolveKind(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}

enum _DeviceKind { led, doser }

class _ChipLabel extends StatelessWidget {
  final String label;
  final Color foreground;

  const _ChipLabel({required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReefSpacing.md,
        vertical: ReefSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Text(
        label,
        style: ReefTextStyles.caption1.copyWith(color: foreground),
      ),
    );
  }
}

class _DeviceIcon extends StatelessWidget {
  final _DeviceKind kind;

  const _DeviceIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: ReefColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Center(
        child: Image.asset(
          kind == _DeviceKind.led ? kDeviceLedIcon : kDeviceDoserIcon,
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
