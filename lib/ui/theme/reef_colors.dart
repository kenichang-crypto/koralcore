import 'package:flutter/material.dart';

/// Centralized color roles extracted from reef-b Android resources.
/// Values follow the semantic names used across the new design system.
class ReefColors {
  const ReefColors._();

  // Brand & surfaces
  static const Color primary = Color(0xFF6F916F); // bg_primary
  static const Color primaryStrong = Color(0xFF517651); // bg_secondary
  static const Color primaryOverlay = Color(0x616F916F); // bg_primary_38

  static const Color surface = Color(0xFFFFFFFF); // bg_aaaa
  static const Color surfaceMuted = Color(0xFFF7F7F7); // bg_aaa
  static const Color surfaceMutedOverlay = Color(0x99F7F7F7); // bg_aaa_60
  static const Color surfacePressed = Color(0x0D000000); // bg_press

  static const Color outline = Color(0xFF808080); // ripple_color
  static const Color divider = Color(0x33000000); // text_a

  // Text hierarchy
  static const Color textPrimary = Color(0xFF000000); // text_aaaa
  static const Color textSecondary = Color(0xBF000000); // text_aaa
  static const Color textTertiary = Color(0x80000000); // text_aa
  static const Color textDisabled = Color(0x66000000); // text_aaaa_40

  // Functional states
  static const Color success = Color(0xFF52D175); // text_success
  static const Color info = Color(0xFF47A9FF); // text_info
  static const Color warning = Color(0xFFFFC10A); // text_waring
  static const Color danger = Color(0xFFFF7D4F); // text_danger

  // Lighting presets (reef LED controls)
  static const Color moonLight = Color(0xFFFF9955);
  static const Color warmWhite = Color(0xFFFFEEAA);
  static const Color coldWhite = Color(0xFF55DDFF);
  static const Color royalBlue = Color(0xFF00AAD4);
  static const Color blue = Color(0xFF0055D4);
  static const Color purple = Color(0xFF6600FF);
  static const Color ultraviolet = Color(0xFFAA00D4);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);

  // Gradients & dashboard accents
  static const Color dashboardTrack = Color(0xFFFFFFFF);
  static const Color dashboardProgress = Color(0xFF5599FF);
  static const Color backgroundGradientStart = Color(0xFFEFEFEF);
  static const Color backgroundGradientEnd = Color(0x00000000); // transparent

  // Convenience aliases for ColorScheme creation
  static const Color onPrimary = surface;
  static const Color onSecondary = surface;
  static const Color onSurface = textPrimary;
  static const Color onBackground = textPrimary;
  static const Color error = danger;
  static const Color onError = surface;
}
