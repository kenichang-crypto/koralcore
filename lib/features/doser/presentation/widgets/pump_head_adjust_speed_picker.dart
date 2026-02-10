import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../controllers/pump_head_adjust_controller.dart';

/// Speed picker bottom sheet for pump head adjustment.
///
/// PARITY: Mirrors reef-b-app's PopupMenu for rotating speed selection.
class PumpHeadAdjustSpeedPicker {
  static void show(
    BuildContext context,
    PumpHeadAdjustController controller,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.dosingRotatingSpeedTitle,
                style: AppTextStyles.subheader1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.dosingRotatingSpeedLow),
              trailing: controller.selectedSpeed == 1
                  ? CommonIconHelper.getCheckIcon(size: 20, 
                      size: 24,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                controller.setSpeed(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.dosingRotatingSpeedMedium),
              trailing: controller.selectedSpeed == 2
                  ? CommonIconHelper.getCheckIcon(size: 20, 
                      size: 24,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                controller.setSpeed(2);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.dosingRotatingSpeedHigh),
              trailing: controller.selectedSpeed == 3
                  ? CommonIconHelper.getCheckIcon(size: 20, 
                      size: 24,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                controller.setSpeed(3);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

