import 'package:flutter/material.dart';

import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Entry tile for dosing main page navigation.
///
/// Used for Schedule, Manual, Calibration, and History entries.
class DosingMainEntryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTapWhenEnabled;

  const DosingMainEntryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTapWhenEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: enabled
            ? () {
                if (onTapWhenEnabled != null) {
                  onTapWhenEnabled!();
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(subtitle)));
                }
              }
            : () {
                showBleGuardDialog(context);
              },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subheaderAccent.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              CommonIconHelper.getNextIcon(
                size: 16,
                color: AppColors.surface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

