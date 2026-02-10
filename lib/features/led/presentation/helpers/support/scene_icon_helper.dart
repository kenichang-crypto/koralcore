import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SceneIconHelper
///
/// Helper class for getting scene icons by ID.
/// PARITY: Mirrors reef-b-app's getSceneIconById() function.
///
/// Icon ID mapping:
/// - 0: ic_thunder (Thunder)
/// - 1: ic_cloudy (Cloudy)
/// - 2: ic_sunny (Sunny)
/// - 3: ic_rainy (Rainy)
/// - 4: ic_dizzle (Drizzle)
/// - 5: ic_none (None)
/// - 6: ic_moon (Moon)
/// - 7: ic_sunrise (Sunrise)
/// - 8: ic_sunset (Sunset)
/// - 9: ic_mist (Mist)
/// - 10: ic_light_off (Light Off)
class SceneIconHelper {
  SceneIconHelper._();

  /// Get the SVG asset path for a scene icon by ID.
  ///
  /// PARITY: Mirrors reef-b-app's getSceneIconById(id: Int): Int?
  /// Returns the drawable resource ID, which we map to SVG asset path.
  static String? getSceneIconAssetPath(int iconId) {
    switch (iconId) {
      case 0:
        return 'assets/icons/ic_thunder.svg';
      case 1:
        return 'assets/icons/ic_cloudy.svg';
      case 2:
        return 'assets/icons/ic_sunny.svg';
      case 3:
        return 'assets/icons/ic_rainy.svg';
      case 4:
        return 'assets/icons/ic_dizzle.svg';
      case 5:
        return 'assets/icons/ic_none.svg';
      case 6:
        return 'assets/icons/ic_moon.svg';
      case 7:
        return 'assets/icons/ic_sunrise.svg';
      case 8:
        return 'assets/icons/ic_sunset.svg';
      case 9:
        return 'assets/icons/ic_mist.svg';
      case 10:
        return 'assets/icons/ic_light_off.svg';
      default:
        return null;
    }
  }

  /// Get a Widget for a scene icon by ID.
  ///
  /// Returns an SvgPicture widget if the icon exists, or a placeholder Icon if not.
  static Widget getSceneIcon({
    required int iconId,
    double? width,
    double? height,
    Color? color,
  }) {
    final assetPath = getSceneIconAssetPath(iconId);
    if (assetPath == null) {
      // Fallback to default icon if iconId is invalid
      // TODO(L3): Icons.circle_outlined is fallback when scene icon is not found
      // Android uses R.drawable.ic_scene_0 as default fallback
      // VIOLATION: Material Icon not in Android (as fallback)
      return Icon(
        Icons.circle_outlined,
        size: width ?? height ?? 24,
        color: color,
      );
    }

    // PARITY: All scene icons should exist, no placeholder needed
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get a scene icon by iconKey (string format like "ic_thunder").
  ///
  /// This is used when the icon is stored as a string key rather than an ID.
  static Widget getSceneIconByKey({
    required String? iconKey,
    double? width,
    double? height,
    Color? color,
  }) {
    if (iconKey == null) {
      // TODO(L3): Icons.circle_outlined is fallback when scene iconKey is null
      // Android uses R.drawable.ic_scene_0 as default fallback
      // VIOLATION: Material Icon not in Android (as fallback)
      return Icon(
        Icons.circle_outlined,
        size: width ?? height ?? 24,
        color: color,
      );
    }

    // Map iconKey to iconId
    int? iconId;
    switch (iconKey) {
      case 'ic_thunder':
        iconId = 0;
        break;
      case 'ic_cloudy':
        iconId = 1;
        break;
      case 'ic_sunny':
        iconId = 2;
        break;
      case 'ic_rainy':
        iconId = 3;
        break;
      case 'ic_dizzle':
        iconId = 4;
        break;
      case 'ic_none':
        iconId = 5;
        break;
      case 'ic_moon':
        iconId = 6;
        break;
      case 'ic_sunrise':
        iconId = 7;
        break;
      case 'ic_sunset':
        iconId = 8;
        break;
      case 'ic_mist':
        iconId = 9;
        break;
      case 'ic_light_off':
        iconId = 10;
        break;
      default:
        // Try to extract iconId from iconKey if it's in format "ic_xxx"
        // For custom icons, use default
        // TODO(L3): Icons.circle_outlined is fallback for unmapped custom scene icons
        // Android returns R.drawable.ic_scene_0 as default
        // VIOLATION: Material Icon not in Android (as fallback)
        return Icon(
          Icons.circle_outlined,
          size: width ?? height ?? 24,
          color: color,
        );
    }

    return getSceneIcon(
      iconId: iconId,
      width: width,
      height: height,
      color: color,
    );
  }
}
