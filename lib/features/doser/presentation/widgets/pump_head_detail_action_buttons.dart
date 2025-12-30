import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/pump_head_detail_controller.dart';

/// Action buttons for pump head detail page.
class PumpHeadDetailActionButtons extends StatelessWidget {
  final bool isConnected;
  final AppLocalizations l10n;
  final PumpHeadDetailController controller;

  const PumpHeadDetailActionButtons({
    super.key,
    required this.isConnected,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBusy = controller.isManualDoseInFlight;
    final bool isTimedBusy = controller.isTimedDoseInFlight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryStrong,
            foregroundColor: AppColors.onPrimary,
            textStyle: AppTextStyles.bodyAccent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          onPressed: isConnected && !isBusy
              ? () => _runManualDose(context)
              : null,
          child: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dosingPumpHeadManualDose),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryStrong,
            textStyle: AppTextStyles.bodyAccent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            side: const BorderSide(color: AppColors.primaryStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          onPressed: isConnected && !isTimedBusy
              ? () => _scheduleTimedDose(context)
              : null,
          child: isTimedBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dosingPumpHeadTimedDose),
        ),
      ],
    );
  }

  Future<void> _runManualDose(BuildContext context) async {
    final bool success = await controller.sendManualDose();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dosingPumpHeadManualDoseSuccess)),
    );
  }

  Future<void> _scheduleTimedDose(BuildContext context) async {
    final bool success = await controller.scheduleTimedDose();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dosingPumpHeadTimedDoseSuccess)),
    );
  }
}

