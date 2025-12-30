import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../domain/doser_dosing/dosing_schedule_summary.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/pump_head_detail_controller.dart';
import 'pump_head_detail_schedule_summary_metric.dart';

/// Schedule summary card for pump head detail page.
class PumpHeadDetailScheduleSummaryCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final AppLocalizations l10n;

  const PumpHeadDetailScheduleSummaryCard({
    super.key,
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (controller.isScheduleSummaryLoading) {
      content = const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      final summary = controller.dosingScheduleSummary;
      if (summary == null || !summary.hasSchedule) {
        content = Text(
          l10n.dosingScheduleSummaryEmpty,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        );
      } else {
        final List<String> countLabels = <String>[];
        if (summary.windowCount != null) {
          countLabels.add(
            l10n.dosingScheduleSummaryWindowCount(summary.windowCount!),
          );
        }
        if (summary.slotCount != null) {
          countLabels.add(
            l10n.dosingScheduleSummarySlotCount(summary.slotCount!),
          );
        }

        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    _scheduleSummaryModeLabel(summary.mode, l10n),
                    style: AppTextStyles.caption1Accent.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (summary.totalMlPerDay != null)
              PumpHeadDetailScheduleSummaryMetric(
                label: l10n.dosingScheduleSummaryTotalLabel,
                value: '${summary.totalMlPerDay!.toStringAsFixed(1)} ml',
              ),
            if (countLabels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: countLabels
                    .map(
                      (label) => Chip(
                        label: Text(
                          label,
                          style: AppTextStyles.caption2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        backgroundColor: AppColors.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
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
              l10n.dosingScheduleSummaryTitle,
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

String _scheduleSummaryModeLabel(
  DosingScheduleMode mode,
  AppLocalizations l10n,
) {
  switch (mode) {
    case DosingScheduleMode.dailyAverage:
      return l10n.dosingScheduleTypeDaily;
    case DosingScheduleMode.customWindow:
      return l10n.dosingScheduleTypeCustom;
    case DosingScheduleMode.none:
      return l10n.dosingScheduleSummaryEmpty;
  }
}

