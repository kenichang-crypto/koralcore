import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimensions.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.ocean500,
      onPrimary: Colors.white,
      secondary: AppColors.ocean300,
      surface: Colors.white,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: AppColors.ocean600,
      centerTitle: false,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.grey900,
      displayColor: AppColors.grey900,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: const TextStyle(color: AppColors.ocean600),
      side: const BorderSide(color: AppColors.ocean300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
