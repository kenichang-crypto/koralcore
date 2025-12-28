import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';

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
        const SizedBox(height: AppDimensions.spacingM),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXS),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.grey100,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _getIconForId(iconId),
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
      color: isSelected ? AppColors.primary : AppColors.grey700,
    );
  }
}

