import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// App theme configuration.
///
/// PARITY: Maps to reef-b-app's res/values/styles.xml AppTheme
class AppTheme {
  const AppTheme._();

  /// Base theme matching reef-b-app's AppTheme
  static ThemeData base() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

    final colorScheme = base.colorScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.info,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.onError,
    );

    final textTheme = base.textTheme
        .copyWith(
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.bodyAccent,
          bodySmall: AppTextStyles.caption1,
          labelLarge: AppTextStyles.caption1Accent,
          labelMedium: AppTextStyles.caption2,
          labelSmall: AppTextStyles.caption2Accent,
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    final buttonPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 5.0, // dp_5 (PARITY: cardElevation)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md), // dp_10
        ),
        margin: const EdgeInsets.all(AppSpacing.xxs), // dp_6
      ),
      // FilledButton theme (Primary buttons)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceMutedOverlay, // bg_aaa_60
          disabledForegroundColor: AppColors.textDisabled,
          textStyle: AppTextStyles.bodyAccent,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      // OutlinedButton theme (Secondary buttons)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.body,
          side: const BorderSide(color: AppColors.primary),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      // TextButton theme (Text buttons)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryStrong,
          textStyle: AppTextStyles.body,
          padding: buttonPadding,
        ),
      ),
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface, // white
        foregroundColor: AppColors.textPrimary, // text_aaaa
        elevation: 0,
        centerTitle: false,
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, // text_a
        thickness: 2.0, // dp_2 (PARITY: MaterialDivider)
        space: 1.0,
      ),
      // InputDecorationTheme (TextField styling)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs), // dp_4
          borderSide: BorderSide.none, // No border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Legacy alias for backward compatibility
@Deprecated('Use AppTheme instead')
typedef ReefTheme = AppTheme;
