import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../pages/pump_head_schedule_page.dart';

/// Schedule overview tile for pump head detail page.
class PumpHeadDetailScheduleOverviewTile extends StatelessWidget {
  final String headId;
  final bool isConnected;
  final AppLocalizations l10n;

  const PumpHeadDetailScheduleOverviewTile({
    super.key,
    required this.headId,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        title: Text(
          l10n.dosingScheduleViewButton,
          style: AppTextStyles.subheaderAccent.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingScheduleOverviewSubtitle,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: CommonIconHelper.getNextIcon(
          size: 24,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          if (!isConnected) {
            showBleGuardDialog(context);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PumpHeadSchedulePage(headId: headId),
            ),
          );
        },
      ),
    );
  }
}

