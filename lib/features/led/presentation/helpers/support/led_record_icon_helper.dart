library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../shared/theme/app_colors.dart';

/// Helper class for LED Record Setting page icons.
///
/// PARITY: Mirrors reef-b-app's drawable resources for LED record setting.
class LedRecordIconHelper {
  const LedRecordIconHelper._();

  /// Get sun icon (ic_sun)
  static Widget getSunIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_sun.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get sunrise icon (ic_sunrise)
  static Widget getSunriseIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_sunrise.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get sunset icon (ic_sunset)
  static Widget getSunsetIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_sunset.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get slow start icon (ic_slow_start)
  static Widget getSlowStartIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_slow_start.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get moon light icon (ic_moon_round)
  static Widget getMoonLightIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_moon_round.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get down arrow icon (ic_down)
  static Widget getDownIcon({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_down.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
    );
  }

  /// Get strength thumb icon (ic_strength_thumb)
  static Widget getStrengthThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_strength_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get default thumb icon (ic_default_thumb)
  static Widget getDefaultThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_default_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get moon light thumb icon (ic_moon_light_thumb)
  static Widget getMoonLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_moon_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get blue light thumb icon (PARITY: ic_blue_light_thumb.xml from reef-b-app)
  /// 16×16dp blue light thumb icon
  static Widget getBlueLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_blue_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get green light thumb icon (PARITY: ic_green_light_thumb.xml from reef-b-app)
  /// 16×16dp green light thumb icon
  static Widget getGreenLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_green_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get cold white light thumb icon (PARITY: ic_cold_white_light_thumb.xml from reef-b-app)
  /// 16×16dp cold white light thumb icon
  static Widget getColdWhiteLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_cold_white_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get purple light thumb icon (PARITY: ic_purple_light_thumb.xml from reef-b-app)
  /// 16×16dp purple light thumb icon
  static Widget getPurpleLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_purple_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get red light thumb icon (PARITY: ic_red_light_thumb.xml from reef-b-app)
  /// 16×16dp red light thumb icon
  static Widget getRedLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_red_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }

  /// Get royal blue light thumb icon (PARITY: ic_royal_blue_light_thumb.xml from reef-b-app)
  /// 16×16dp royal blue light thumb icon
  static Widget getRoyalBlueLightThumbIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      'assets/icons/ic_royal_blue_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }
}

