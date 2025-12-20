import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/system/ble_readiness_controller.dart';
import '../../theme/dimensions.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class BleGuardBanner extends StatelessWidget {
  const BleGuardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleReadinessController>(
      builder: (context, controller, _) {
        final snapshot = controller.snapshot;
        if (snapshot.isReady) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);
        final _BleBannerModel model = _BleBannerModel.fromSnapshot(
          context,
          controller,
        );
        final theme = Theme.of(context);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          decoration: BoxDecoration(
            color: model.accentColor.withOpacity(.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(model.icon, color: model.accentColor),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppDimensions.spacingXS),
                        Text(model.message, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _BleGuardActions(
                snapshot: snapshot,
                controller: controller,
                primaryLabel: model.primaryLabel,
                primaryAction: model.primaryAction,
                l10n: l10n,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BleGuardActions extends StatelessWidget {
  final BleReadinessSnapshot snapshot;
  final BleReadinessController controller;
  final String? primaryLabel;
  final VoidCallback? primaryAction;
  final AppLocalizations l10n;

  const _BleGuardActions({
    required this.snapshot,
    required this.controller,
    required this.primaryLabel,
    required this.primaryAction,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPrimary = primaryLabel != null && primaryAction != null;
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      children: [
        if (showPrimary)
          FilledButton(
            onPressed: snapshot.isRequesting
                ? null
                : () => primaryAction!.call(),
            child: snapshot.isRequesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(primaryLabel!),
          ),
        OutlinedButton(
          onPressed: snapshot.isRequesting ? null : () => controller.refresh(),
          child: Text(l10n.bleOnboardingRetryCta),
        ),
        TextButton(
          onPressed: () => showBleOnboardingSheet(context),
          child: Text(l10n.bleOnboardingLearnMore),
        ),
      ],
    );
  }
}

class _BleBannerModel {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? primaryAction;

  const _BleBannerModel({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.primaryAction,
  });

  factory _BleBannerModel.fromSnapshot(
    BuildContext context,
    BleReadinessController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final snapshot = controller.snapshot;
    switch (snapshot.blockingReason) {
      case BleBlockingReason.permissionPermanentlyDenied:
        return _BleBannerModel(
          icon: Icons.settings_applications,
          accentColor: Colors.redAccent,
          title: l10n.bleOnboardingSettingsTitle,
          message: l10n.bleOnboardingSettingsCopy,
          primaryLabel: l10n.bleOnboardingSettingsCta,
          primaryAction: () => controller.openSystemSettings(),
        );
      case BleBlockingReason.locationRequired:
        return _BleBannerModel(
          icon: Icons.location_on_outlined,
          accentColor: Colors.orange,
          title: l10n.bleOnboardingLocationTitle,
          message: l10n.bleOnboardingLocationCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.permissionsNeeded:
        return _BleBannerModel(
          icon: Icons.bluetooth_searching,
          accentColor: Colors.orange,
          title: l10n.bleOnboardingPermissionTitle,
          message: l10n.bleOnboardingPermissionCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.bluetoothOff:
        return _BleBannerModel(
          icon: Icons.bluetooth_disabled,
          accentColor: Colors.blueGrey,
          title: l10n.bleOnboardingBluetoothOffTitle,
          message: l10n.bleOnboardingBluetoothOffCopy,
          primaryLabel: l10n.bleOnboardingBluetoothCta,
          primaryAction: () => controller.openBluetoothSettings(),
        );
      case BleBlockingReason.bluetoothRestricted:
        return _BleBannerModel(
          icon: Icons.block,
          accentColor: Colors.grey,
          title: l10n.bleOnboardingUnavailableTitle,
          message: l10n.bleOnboardingUnavailableCopy,
        );
      case BleBlockingReason.none:
        return _BleBannerModel(
          icon: Icons.info_outline,
          accentColor: Colors.orange,
          title: l10n.bleOnboardingPermissionTitle,
          message: l10n.bleOnboardingPermissionCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
    }
  }
}

Future<void> showBleOnboardingSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.spacingXL,
            right: AppDimensions.spacingXL,
            top: AppDimensions.spacingL,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom +
                AppDimensions.spacingXL,
          ),
          child: Consumer<BleReadinessController>(
            builder: (context, controller, _) {
              final l10n = AppLocalizations.of(context);
              final snapshot = controller.snapshot;
              final theme = Theme.of(context);
              final _BleBannerModel model = _BleBannerModel.fromSnapshot(
                context,
                controller,
              );

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bleOnboardingSheetTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      l10n.bleOnboardingSheetDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),
                    _BleSheetStep(
                      icon: Icons.radar,
                      title: l10n.bleOnboardingSheetSearchTitle,
                      message: l10n.bleOnboardingSheetSearchCopy,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _BleSheetStep(
                      icon: Icons.settings_remote,
                      title: l10n.bleOnboardingSheetControlTitle,
                      message: l10n.bleOnboardingSheetControlCopy,
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),
                    _BleGuardActions(
                      snapshot: snapshot,
                      controller: controller,
                      primaryLabel: model.primaryLabel,
                      primaryAction: model.primaryAction,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      l10n.bleOnboardingSheetFooter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Future<void> showBleGuardDialog(BuildContext context) {
  return showBleOnboardingSheet(context);
}

class _BleSheetStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _BleSheetStep({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
