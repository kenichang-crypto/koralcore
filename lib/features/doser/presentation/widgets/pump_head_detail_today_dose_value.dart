import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Today dose value widget for displaying a single dose metric.
class PumpHeadDetailTodayDoseValue extends StatelessWidget {
  final String label;
  final double? value;
  final bool emphasize;

  const PumpHeadDetailTodayDoseValue({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = AppTextStyles.caption1.copyWith(
      color: AppColors.textSecondary,
    );
    final TextStyle valueStyle = emphasize
        ? AppTextStyles.title1
        : AppTextStyles.subheaderAccent;

    final String valueText = value == null
        ? '—'
        : '${value!.toStringAsFixed(1)} ml';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: AppSpacing.xs),
        Text(valueText, style: valueStyle),
      ],
    );
  }
}

