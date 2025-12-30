import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/system/ble_readiness_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: model.accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(model.icon, color: model.accentColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.title,
                          style: AppTextStyles.subheaderAccent.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          model.message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
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
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
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
          accentColor: AppColors.danger,
          title: l10n.bleOnboardingSettingsTitle,
          message: l10n.bleOnboardingSettingsCopy,
          primaryLabel: l10n.bleOnboardingSettingsCta,
          primaryAction: () => controller.openSystemSettings(),
        );
      case BleBlockingReason.locationRequired:
        return _BleBannerModel(
          icon: Icons.location_on_outlined,
          accentColor: AppColors.warning,
          title: l10n.bleOnboardingLocationTitle,
          message: l10n.bleOnboardingLocationCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.permissionsNeeded:
        return _BleBannerModel(
          icon: Icons.bluetooth_searching,
          accentColor: AppColors.info,
          title: l10n.bleOnboardingPermissionTitle,
          message: l10n.bleOnboardingPermissionCopy,
          primaryLabel: l10n.bleOnboardingPermissionCta,
          primaryAction: () => controller.requestPermissions(),
        );
      case BleBlockingReason.bluetoothOff:
        return _BleBannerModel(
          icon: Icons.bluetooth_disabled,
          accentColor: AppColors.textSecondary,
          title: l10n.bleOnboardingBluetoothOffTitle,
          message: l10n.bleOnboardingBluetoothOffCopy,
          primaryLabel: l10n.bleOnboardingBluetoothCta,
          primaryAction: () => controller.openBluetoothSettings(),
        );
      case BleBlockingReason.bluetoothRestricted:
        return _BleBannerModel(
          icon: Icons.block,
          accentColor: AppColors.textDisabled,
          title: l10n.bleOnboardingUnavailableTitle,
          message: l10n.bleOnboardingUnavailableCopy,
        );
      case BleBlockingReason.none:
        return _BleBannerModel(
          icon: Icons.info_outline,
          accentColor: AppColors.info,
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
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xl,
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
                      style: AppTextStyles.title1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.bleOnboardingSheetDescription,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BleSheetStep(
                      icon: Icons.radar,
                      title: l10n.bleOnboardingSheetSearchTitle,
                      message: l10n.bleOnboardingSheetSearchCopy,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BleSheetStep(
                      icon: Icons.settings_remote,
                      title: l10n.bleOnboardingSheetControlTitle,
                      message: l10n.bleOnboardingSheetControlCopy,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BleGuardActions(
                      snapshot: snapshot,
                      controller: controller,
                      primaryLabel: model.primaryLabel,
                      primaryAction: model.primaryAction,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.bleOnboardingSheetFooter,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textTertiary,
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
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subheaderAccent.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
