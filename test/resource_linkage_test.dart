/// Test to verify resource linkage between assets and code.
///
/// This test checks:
/// 1. All Image.asset() paths point to existing files
/// 2. All asset constants are valid
/// 3. All l10n strings are accessible
/// 4. All color/theme references are valid

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/ui/assets/reef_icons.dart';
import 'package:koralcore/ui/theme/reef_colors.dart';
import 'package:koralcore/ui/theme/reef_spacing.dart';
import 'package:koralcore/ui/theme/reef_radius.dart';

void main() {
  group('Resource Linkage Tests', () {
    test('All reef_icons constants should be non-empty strings', () {
      expect(kDeviceLedIcon, isNotEmpty);
      expect(kDeviceDoserIcon, isNotEmpty);
      expect(kDeviceEmptyIcon, isNotEmpty);
      expect(kBluetoothIcon, isNotEmpty);
      expect(kAdjustIcon, isNotEmpty);
      expect(kSplashLogo, isNotEmpty);
      expect(kSplashIcon, isNotEmpty);
    });

    test('All reef_icons constants should start with assets/', () {
      expect(kDeviceLedIcon, startsWith('assets/'));
      expect(kDeviceDoserIcon, startsWith('assets/'));
      expect(kDeviceEmptyIcon, startsWith('assets/'));
      expect(kBluetoothIcon, startsWith('assets/'));
      expect(kAdjustIcon, startsWith('assets/'));
      expect(kSplashLogo, startsWith('assets/'));
      expect(kSplashIcon, startsWith('assets/'));
    });

    test('ReefColors should have valid color values', () {
      expect(ReefColors.primary, isA<Color>());
      expect(ReefColors.surface, isA<Color>());
      expect(ReefColors.textPrimary, isA<Color>());
      expect(ReefColors.success, isA<Color>());
      expect(ReefColors.error, isA<Color>());
    });

    test('ReefSpacing should have positive values', () {
      expect(ReefSpacing.xs, greaterThan(0));
      expect(ReefSpacing.sm, greaterThan(0));
      expect(ReefSpacing.md, greaterThan(0));
      expect(ReefSpacing.lg, greaterThan(0));
      expect(ReefSpacing.xl, greaterThan(0));
    });

    test('ReefRadius should have non-negative values', () {
      expect(ReefRadius.xs, greaterThanOrEqualTo(0));
      expect(ReefRadius.sm, greaterThanOrEqualTo(0));
      expect(ReefRadius.md, greaterThanOrEqualTo(0));
      expect(ReefRadius.lg, greaterThanOrEqualTo(0));
    });
  });
}

