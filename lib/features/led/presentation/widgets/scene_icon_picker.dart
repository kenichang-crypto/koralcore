import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../helpers/support/scene_icon_helper.dart';

/// SceneIconPicker
///
/// Widget for selecting an icon for a LED scene.
/// Supports 11 icon types (0-10) as defined in reef-b-app.
class SceneIconPicker extends StatelessWidget {
  const SceneIconPicker({
    super.key,
    required this.selectedIconId,
    required this.onIconSelected,
  });

  final int selectedIconId;
  final ValueChanged<int> onIconSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ledSceneIcon,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 11, // Icons 0-10
            itemBuilder: (context, index) {
              return _IconItem(
                iconId: index,
                isSelected: selectedIconId == index,
                onTap: () => onIconSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Scene icon item matching adapter_scene_icon.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_scene_icon.xml structure:
/// - MaterialCardView: bg_aaa, cornerRadius 24dp, elevation 0
/// - margin: 8dp (start/end)
/// - ShapeableImageView: 40×40dp, padding 8dp
class _IconItem extends StatelessWidget {
  const _IconItem({
    required this.iconId,
    required this.isSelected,
    required this.onTap,
  });

  final int iconId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_scene_icon.xml structure
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs), // dp_8 marginStart/End
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // dp_24 cornerRadius
        child: Card(
          color: AppColors.surfaceMuted, // bg_aaa
          elevation: 0, // dp_0
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // dp_24 cornerRadius
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs), // dp_8 padding
            child: SizedBox(
              width: 40, // dp_40
              height: 40, // dp_40
              child: _getIconForId(iconId),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIconForId(int id) {
    // PARITY: Use SceneIconHelper to get scene icons from SVG assets
    // This matches reef-b-app's getSceneIconById() behavior
    return SceneIconHelper.getSceneIcon(
      iconId: id,
      width: 32,
      height: 32,
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
    );
  }
}

