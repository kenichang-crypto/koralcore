import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../models/pump_head_summary.dart';

/// Status card for pump head detail page.
///
/// PARITY: Mirrors reef-b-app's layout_drop_head_info CardView.
class PumpHeadDetailStatusCard extends StatelessWidget {
  final PumpHeadSummary summary;
  final String deviceName;
  final bool isLoading;
  final AppLocalizations l10n;

  const PumpHeadDetailStatusCard({
    super.key,
    required this.summary,
    required this.deviceName,
    required this.isLoading,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.displayName,
              style: AppTextStyles.title1.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary.additiveName,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onPrimary.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Chip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  side: BorderSide.none,
                  label: Text(_statusLabel(l10n, summary.statusKey)),
                  backgroundColor: AppColors.surface.withOpacity(0.2),
                  labelStyle: AppTextStyles.caption1Accent.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: AppSpacing.md),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.homeStatusConnected(deviceName),
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String statusKey) {
    switch (statusKey) {
      case 'ready':
        return l10n.dosingPumpHeadStatusReady;
      default:
        return l10n.dosingPumpHeadStatus;
    }
  }
}

