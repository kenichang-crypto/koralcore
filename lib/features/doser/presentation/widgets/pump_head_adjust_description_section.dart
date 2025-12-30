import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Description section for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's tv_adjust_description_title and tv_adjust_step.
class PumpHeadAdjustDescriptionSection extends StatelessWidget {
  final AppLocalizations l10n;

  const PumpHeadAdjustDescriptionSection({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_adjust_description_title - title2, text_aaaa
        Text(
          l10n.dosingAdjustDescription,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        // PARITY: tv_adjust_step - marginTop 4dp, body, text_aaa
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.dosingAdjustStep,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

