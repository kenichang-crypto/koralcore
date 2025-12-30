import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';
import '../controllers/pump_head_adjust_controller.dart';

/// Rotating speed selection section for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's tv_rotating_speed_title and btn_rotating_speed.
class PumpHeadAdjustRotatingSpeedSection extends StatelessWidget {
  final PumpHeadAdjustController controller;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback onSpeedPickerTap;

  const PumpHeadAdjustRotatingSpeedSection({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.l10n,
    required this.onSpeedPickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_rotating_speed_title - marginTop 24dp, caption1, text_aaaa
        Text(
          l10n.dosingRotatingSpeedTitle,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        // PARITY: btn_rotating_speed - marginTop 4dp, BackgroundMaterialButton style
        const SizedBox(height: AppSpacing.xs),
        MaterialButton(
          onPressed: controller.isCalibrating || !isConnected
              ? null
              : onSpeedPickerTap,
          // PARITY: BackgroundMaterialButton style
          color: AppColors.surfaceMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textColor: AppColors.textPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getSpeedLabel(controller.selectedSpeed, l10n),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              LedRecordIconHelper.getDownIcon(
                width: 20,
                height: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSpeedLabel(int speed, AppLocalizations l10n) {
    switch (speed) {
      case 1:
        return l10n.dosingRotatingSpeedLow;
      case 2:
        return l10n.dosingRotatingSpeedMedium;
      case 3:
        return l10n.dosingRotatingSpeedHigh;
      default:
        return l10n.dosingRotatingSpeedLow;
    }
  }
}

