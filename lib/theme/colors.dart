import 'package:flutter/material.dart';

import '../ui/theme/reef_colors.dart';

/// Legacy palette aliases that now point to the Reef design system.
class AppColors {
  AppColors._();

  // Brand core → map to Reef primaries so legacy callers inherit new hues.
  static const Color ocean600 = ReefColors.primaryStrong;
  static const Color ocean500 = ReefColors.primary;
  static const Color ocean300 = ReefColors.primaryOverlay;
  static const Color primary = ReefColors.primary;

  // Functional
  static const Color success = ReefColors.success;
  static const Color warning = ReefColors.warning;
  static const Color danger = ReefColors.danger;
  static const Color error = ReefColors.error;

  // Greyscale → reuse Reef text / surface roles.
  static const Color grey900 = ReefColors.textPrimary;
  static const Color grey800 = ReefColors.textSecondary;
  static const Color grey700 = ReefColors.textSecondary;
  static const Color grey600 = ReefColors.textSecondary;
  static const Color grey500 = ReefColors.textTertiary;
  static const Color grey400 = ReefColors.textTertiary;
  static const Color grey300 = ReefColors.textDisabled;
  static const Color grey200 = ReefColors.textTertiary;
  static const Color grey100 = ReefColors.surfaceMuted;
  static const Color grey050 = ReefColors.surfaceMutedOverlay;

  // Brand colors
  static const Color ocean100 = ReefColors.primaryOverlay;

  static const Color background = ReefColors.primaryStrong;
}
