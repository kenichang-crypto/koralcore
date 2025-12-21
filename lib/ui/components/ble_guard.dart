import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../application/system/ble_readiness_controller.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_radius.dart';
import '../theme/reef_spacing.dart';
import '../theme/reef_text.dart';

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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ReefSpacing.lg),
          decoration: BoxDecoration(
            color: model.accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(ReefRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: model.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(ReefRadius.md),
                    ),
                    child: Icon(model.icon, color: model.accentColor),
                  ),
                  const SizedBox(width: ReefSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.title,
                          style: ReefTextStyles.subheaderAccent.copyWith(
                            color: ReefColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: ReefSpacing.xs),
                        Text(
                          model.message,
                          style: ReefTextStyles.body.copyWith(
                            color: ReefColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ReefSpacing.md),
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
      spacing: ReefSpacing.sm,
      runSpacing: ReefSpacing.sm,
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
          accentColor: ReefColors.danger,
          title: l10n.bleOnboardingSettingsTitle,
          message: l10n.bleOnboardingSettingsCopy,
          primaryLabel: l10n.bleOnboardingSettingsCta,
          primaryAction: () => controller.openSystemSettings(),
        );
      case BleBlockingReason.locationRequired:
        return _BleBannerModel(
          icon: Icons.location_on_outlined,
          accentColor: ReefColors.warning,
          title: l10n.bleOnboardingLocationTitle,
          message: l10n.bleOnboardingLocationCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.permissionsNeeded:
        return _BleBannerModel(
          icon: Icons.bluetooth_searching,
          accentColor: ReefColors.info,
          title: l10n.bleOnboardingPermissionTitle,
          message: l10n.bleOnboardingPermissionCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.bluetoothOff:
        return _BleBannerModel(
          icon: Icons.bluetooth_disabled,
          accentColor: ReefColors.textSecondary,
          title: l10n.bleOnboardingBluetoothOffTitle,
          message: l10n.bleOnboardingBluetoothOffCopy,
          primaryLabel: l10n.bleOnboardingBluetoothCta,
          primaryAction: () => controller.openBluetoothSettings(),
        );
      case BleBlockingReason.bluetoothRestricted:
        return _BleBannerModel(
          icon: Icons.block,
          accentColor: ReefColors.textDisabled,
          title: l10n.bleOnboardingUnavailableTitle,
          message: l10n.bleOnboardingUnavailableCopy,
        );
      case BleBlockingReason.none:
        return _BleBannerModel(
          icon: Icons.info_outline,
          accentColor: ReefColors.info,
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
            left: ReefSpacing.xl,
            right: ReefSpacing.xl,
            top: ReefSpacing.lg,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + ReefSpacing.xl,
          ),
          child: Consumer<BleReadinessController>(
            builder: (context, controller, _) {
              final l10n = AppLocalizations.of(context);
              final snapshot = controller.snapshot;
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
                      style: ReefTextStyles.title1.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: ReefSpacing.sm),
                    Text(
                      l10n.bleOnboardingSheetDescription,
                      style: ReefTextStyles.body.copyWith(
                        color: ReefColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: ReefSpacing.xl),
                    _BleSheetStep(
                      icon: Icons.radar,
                      title: l10n.bleOnboardingSheetSearchTitle,
                      message: l10n.bleOnboardingSheetSearchCopy,
                    ),
                    const SizedBox(height: ReefSpacing.sm),
                    _BleSheetStep(
                      icon: Icons.settings_remote,
                      title: l10n.bleOnboardingSheetControlTitle,
                      message: l10n.bleOnboardingSheetControlCopy,
                    ),
                    const SizedBox(height: ReefSpacing.xl),
                    _BleGuardActions(
                      snapshot: snapshot,
                      controller: controller,
                      primaryLabel: model.primaryLabel,
                      primaryAction: model.primaryAction,
                      l10n: l10n,
                    ),
                    const SizedBox(height: ReefSpacing.md),
                    Text(
                      l10n.bleOnboardingSheetFooter,
                      style: ReefTextStyles.caption1.copyWith(
                        color: ReefColors.textTertiary,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ReefColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(ReefRadius.md),
          ),
          child: Icon(icon, color: ReefColors.primary),
        ),
        const SizedBox(width: ReefSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ReefTextStyles.subheaderAccent.copyWith(
                  color: ReefColors.textPrimary,
                ),
              ),
              const SizedBox(height: ReefSpacing.xs),
              Text(
                message,
                style: ReefTextStyles.body.copyWith(
                  color: ReefColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
