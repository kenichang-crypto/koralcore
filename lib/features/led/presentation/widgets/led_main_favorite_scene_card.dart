import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';
import '../helpers/support/scene_display_text.dart';
import '../helpers/support/scene_icon_helper.dart';
import '../models/led_scene_summary.dart';

/// Favorite scene card matching adapter_favorite_scene.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_favorite_scene.xml structure:
/// - MaterialButton (ElevatedButton style, but elevation=0)
/// - cornerRadius: 8dp
/// - padding: 8dp (start/end), 0dp (top/bottom)
/// - icon: ic_none (or scene icon)
/// - iconPadding: 8dp
/// - textAppearance: body
class LedMainFavoriteSceneCard extends StatelessWidget {
  final LedSceneSummary scene;
  final AppLocalizations l10n;
  final bool isConnected;
  final bool featuresEnabled;
  final LedSceneListController controller;

  const LedMainFavoriteSceneCard({
    super.key,
    required this.scene,
    required this.l10n,
    required this.isConnected,
    required this.featuresEnabled,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final bool isActive = scene.isActive;
    final bool isEnabled = featuresEnabled && !isActive;

    // PARITY: adapter_favorite_scene.xml - MaterialButton with elevation=0
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs), // dp_8 marginStart/End
      child: ElevatedButton.icon(
        onPressed: isEnabled
            ? () => controller.applyScene(scene.id)
            : null,
        style: ElevatedButton.styleFrom(
          elevation: 0, // dp_0 (PARITY: app:elevation="@dimen/dp_0")
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, // dp_8 paddingStart/End
            vertical: 0, // dp_0 paddingTop/Bottom
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs), // dp_8 cornerRadius
          ),
          backgroundColor: isActive
              ? AppColors.primary
              : AppColors.surface,
          foregroundColor: isActive
              ? AppColors.onPrimary
              : AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textSecondary,
        ),
        // PARITY: reef-b-app uses ic_none or scene-specific icon
        // Use SceneIconHelper to get the actual scene icon
        icon: scene.iconKey != null
            ? SceneIconHelper.getSceneIconByKey(
                iconKey: scene.iconKey,
                width: 20,
                height: 20,
              )
            : SceneIconHelper.getSceneIcon(
                iconId: 5, // ic_none
                width: 20,
                height: 20,
              ),
        label: Text(
          sceneName.isEmpty ? l10n.ledSceneNoSetting : sceneName,
          style: AppTextStyles.body.copyWith(
            color: isActive
                ? AppColors.onPrimary
                : isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
          ),
        ),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}

