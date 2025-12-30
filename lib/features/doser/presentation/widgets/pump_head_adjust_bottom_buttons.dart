import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/pump_head_adjust_controller.dart';

/// Bottom action buttons for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's btn_prev, btn_next, and btn_complete.
class PumpHeadAdjustBottomButtons extends StatelessWidget {
  final PumpHeadAdjustController controller;
  final bool isConnected;
  final AppLocalizations l10n;

  const PumpHeadAdjustBottomButtons({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: btn_prev and btn_next - bottom buttons
    if (controller.isCalibrationComplete) {
      // Show "Complete Calibration" button
      // PARITY: btn_complete - MaterialButton style, padding 43dp horizontal
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: AppColors.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl + AppSpacing.xs, // 43dp = 40 + 3
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        onPressed: controller.isCalibrating || !isConnected
            ? null
            : () => controller.completeCalibration(context),
        child: Text(
          l10n.dosingCompleteAdjust,
          style: AppTextStyles.caption1Accent.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
      );
    }

    // Show "Cancel" and "Next" buttons
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // PARITY: btn_prev - TextViewCanClick style, padding 10dp horizontal
        TextButton(
          onPressed: controller.isCalibrating
              ? null
              : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs + AppSpacing.xxxs, // 10dp = 8 + 2
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            l10n.actionCancel,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // PARITY: btn_next - MaterialButton style, padding 43dp horizontal
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryStrong,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl + AppSpacing.xs, // 43dp = 40 + 3
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          onPressed: controller.isCalibrating || !isConnected
              ? null
              : () => controller.startCalibration(context),
          child: Text(
            l10n.actionNext,
            style: AppTextStyles.caption1Accent.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

