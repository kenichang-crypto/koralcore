import 'package:flutter/material.dart';

/// Typography primitives derived from reef-b styles.xml.
class ReefTextStyles {
  const ReefTextStyles._();

  static const TextStyle headline = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 36 / 30,
    letterSpacing: -0.2,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 26 / 20,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  static const TextStyle subheader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 24 / 18,
  );

  static const TextStyle subheaderAccent = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24 / 18,
  );

  static const TextStyle subheader1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
  );

  static const TextStyle bodyAccent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 22 / 16,
  );

  static const TextStyle body1 = body;
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle caption1Accent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  static const TextStyle caption2Accent = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );

  static TextTheme get textTheme => const TextTheme(
    displayLarge: headline,
    headlineMedium: title1,
    headlineSmall: title2,
    titleMedium: subheader,
    titleSmall: subheaderAccent,
    bodyLarge: body,
    bodyMedium: bodyAccent,
    bodySmall: caption1,
    labelLarge: caption1Accent,
    labelMedium: caption2,
    labelSmall: caption2Accent,
  );
}
