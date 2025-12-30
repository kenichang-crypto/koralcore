import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Schedule summary metric widget.
class PumpHeadDetailScheduleSummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const PumpHeadDetailScheduleSummaryMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.subheaderAccent.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

