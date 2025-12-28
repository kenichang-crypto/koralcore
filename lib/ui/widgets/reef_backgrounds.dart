/// Background widgets converted from reef-b-app XML drawables.
///
/// This file provides Flutter Widget equivalents for reef-b-app's
/// background XML drawables.
library;

import 'package:flutter/material.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_radius.dart';
import '../theme/reef_spacing.dart';

/// Main activity background with gradient.
///
/// PARITY: Mirrors reef-b-app's background_main.xml
/// Gradient from #EFEFEF to transparent (225 degrees).
class ReefMainBackground extends StatelessWidget {
  const ReefMainBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReefColors.backgroundGradientStart, // #EFEFEF
            ReefColors.backgroundGradientEnd, // transparent
          ],
          transform: const GradientRotation(225 * 3.14159 / 180), // 225 degrees
        ),
      ),
      child: child,
    );
  }
}

/// Dialog background with rounded corners.
///
/// PARITY: Mirrors reef-b-app's dialog_background.xml
/// White background with 8dp corner radius.
class ReefDialogBackground extends StatelessWidget {
  const ReefDialogBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ReefColors.surface, // bg_aaaa (#FFFFFF)
        borderRadius: BorderRadius.circular(ReefSpacing.xs), // dp_8
      ),
      child: child,
    );
  }
}

/// White background with rounded corners.
///
/// PARITY: Mirrors reef-b-app's background_white_radius.xml
class ReefWhiteRoundedBackground extends StatelessWidget {
  const ReefWhiteRoundedBackground({
    super.key,
    required this.child,
    this.radius = ReefSpacing.xs, // dp_8
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Spinner background.
///
/// PARITY: Mirrors reef-b-app's background_spinner.xml
class ReefSpinnerBackground extends StatelessWidget {
  const ReefSpinnerBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.xs),
      ),
      child: child,
    );
  }
}

/// Sink spinner background.
///
/// PARITY: Mirrors reef-b-app's background_sink_spinner.xml
class ReefSinkSpinnerBackground extends StatelessWidget {
  const ReefSinkSpinnerBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.xs),
      ),
      child: child,
    );
  }
}

