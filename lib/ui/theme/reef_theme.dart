import 'package:flutter/material.dart';

import 'reef_colors.dart';
import 'reef_radius.dart';
import 'reef_spacing.dart';
import 'reef_text.dart';

/// Minimal Reef base theme that only wires fundamental tokens into Material.
class ReefTheme {
  const ReefTheme._();

  static ThemeData base() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

    final colorScheme = base.colorScheme.copyWith(
      primary: ReefColors.primary,
      onPrimary: ReefColors.onPrimary,
      secondary: ReefColors.info,
      onSecondary: ReefColors.onPrimary,
      surface: ReefColors.surface,
      onSurface: ReefColors.textPrimary,
      error: ReefColors.danger,
      onError: ReefColors.onError,
    );

    final textTheme = base.textTheme
        .copyWith(
          bodyLarge: ReefTextStyles.body,
          bodyMedium: ReefTextStyles.bodyAccent,
          bodySmall: ReefTextStyles.caption1,
          labelLarge: ReefTextStyles.caption1Accent,
          labelMedium: ReefTextStyles.caption2,
          labelSmall: ReefTextStyles.caption2Accent,
        )
        .apply(
          bodyColor: ReefColors.textPrimary,
          displayColor: ReefColors.textPrimary,
        );

    final buttonPadding = const EdgeInsets.symmetric(
      horizontal: ReefSpacing.lg,
      vertical: ReefSpacing.sm,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ReefColors.primary,
          foregroundColor: ReefColors.onPrimary,
          textStyle: ReefTextStyles.bodyAccent,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReefRadius.lg),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ReefColors.primary,
          textStyle: ReefTextStyles.body,
          side: const BorderSide(color: ReefColors.primary),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReefRadius.lg),
          ),
        ),
      ),
    );
  }
}
