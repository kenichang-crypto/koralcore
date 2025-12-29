library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/reef_colors.dart';

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
      'assets/icons/led_record/ic_sun.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/scene/ic_sunrise.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/scene/ic_sunset.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/led_record/ic_slow_start.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/led_record/ic_moon_round.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/led_record/ic_down.svg',
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : const ColorFilter.mode(
              ReefColors.textPrimary,
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
      'assets/icons/led_record/ic_strength_thumb.svg',
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
      'assets/icons/led_record/ic_default_thumb.svg',
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
      'assets/icons/led_record/ic_moon_light_thumb.svg',
      width: width ?? 16,
      height: height ?? 16,
    );
  }
}

