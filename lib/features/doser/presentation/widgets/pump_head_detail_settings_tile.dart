import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../pages/pump_head_settings_page.dart';

/// Settings tile for pump head detail page.
class PumpHeadDetailSettingsTile extends StatelessWidget {
  final String headId;
  final String initialName;
  final int initialDelaySeconds;
  final bool isConnected;
  final AppLocalizations l10n;

  const PumpHeadDetailSettingsTile({
    super.key,
    required this.headId,
    required this.initialName,
    required this.initialDelaySeconds,
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
          l10n.dosingPumpHeadSettingsTitle,
          style: AppTextStyles.subheaderAccent.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingPumpHeadSettingsSubtitle,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: CommonIconHelper.getNextIcon(size: 24, 
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
              builder: (_) => PumpHeadSettingsPage(
                headId: headId,
                initialName: initialName,
                initialDelaySeconds: initialDelaySeconds,
              ),
            ),
          );
        },
      ),
    );
  }
}

