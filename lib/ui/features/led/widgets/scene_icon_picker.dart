import 'package:flutter/material.dart';

import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scene Icon',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ReefSpacing.sm),
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
      padding: EdgeInsets.symmetric(horizontal: ReefSpacing.xs), // dp_8 marginStart/End
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // dp_24 cornerRadius
        child: Card(
          color: ReefColors.surfaceMuted, // bg_aaa
          elevation: 0, // dp_0
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // dp_24 cornerRadius
          ),
          child: Padding(
            padding: EdgeInsets.all(ReefSpacing.xs), // dp_8 padding
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
    // Map icon IDs to Material Icons
    // This is a placeholder - in full version, should use custom icon assets
    final IconData iconData;
    switch (id) {
      case 0:
        iconData = Icons.flash_on; // Thunder
        break;
      case 1:
        iconData = Icons.wb_cloudy; // Cloudy
        break;
      case 2:
        iconData = Icons.wb_sunny; // Sunny
        break;
      case 3:
        iconData = Icons.water_drop; // Water
        break;
      case 4:
        iconData = Icons.nightlight; // Moonlight
        break;
      case 5:
        iconData = Icons.circle_outlined; // None
        break;
      case 6:
        iconData = Icons.palette; // Palette
        break;
      case 7:
        iconData = Icons.color_lens; // Color lens
        break;
      case 8:
        iconData = Icons.auto_awesome; // Auto
        break;
      case 9:
        iconData = Icons.star; // Star
        break;
      case 10:
        iconData = Icons.favorite; // Favorite
        break;
      default:
        iconData = Icons.circle_outlined;
    }

    return Icon(
      iconData,
      size: 32,
      color: isSelected ? ReefColors.primary : ReefColors.textSecondary,
    );
  }
}

