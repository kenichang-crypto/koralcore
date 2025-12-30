import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/pump_head_detail_controller.dart';
import 'pump_head_detail_today_dose_value.dart';

/// Today dose card for pump head detail page.
class PumpHeadDetailTodayDoseCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final AppLocalizations l10n;

  const PumpHeadDetailTodayDoseCard({
    super.key,
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (controller.isTodayDoseLoading) {
      content = const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      final summary = controller.todayDoseSummary;
      if (summary == null) {
        content = Text(
          l10n.dosingTodayTotalEmpty,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        );
      } else {
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PumpHeadDetailTodayDoseValue(
                label: l10n.dosingTodayTotalTotal,
                value: summary.totalMl,
                emphasize: true,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PumpHeadDetailTodayDoseValue(
                    label: l10n.dosingTodayTotalScheduled,
                    value: summary.scheduledMl,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PumpHeadDetailTodayDoseValue(
                    label: l10n.dosingTodayTotalManual,
                    value: summary.manualMl,
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingTodayTotalTitle,
              style: AppTextStyles.title2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            content,
          ],
        ),
      ),
    );
  }
}

