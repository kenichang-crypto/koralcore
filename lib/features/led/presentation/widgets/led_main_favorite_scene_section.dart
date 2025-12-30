import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';
import 'led_main_favorite_scene_card.dart';

/// Favorite scene section for LED main page.
///
/// PARITY: Mirrors reef-b-app's rv_favorite_scene RecyclerView.
class LedMainFavoriteSceneSection extends StatelessWidget {
  final LedSceneListController controller;
  final bool isConnected;
  final bool featuresEnabled;
  final AppLocalizations l10n;

  const LedMainFavoriteSceneSection({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.featuresEnabled,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteScenes = controller.scenes.where((scene) => scene.isFavorite).toList();

    if (favoriteScenes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.ledFavoriteScenesTitle,
          subtitle: l10n.ledFavoriteScenesSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < favoriteScenes.length; i++) ...[
                LedMainFavoriteSceneCard(
                  scene: favoriteScenes[i],
                  l10n: l10n,
                  isConnected: isConnected,
                  featuresEnabled: featuresEnabled,
                  controller: controller,
                ),
                if (i < favoriteScenes.length - 1)
                  const SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            color: AppColors.surface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

