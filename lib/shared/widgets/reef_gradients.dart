/// Gradient widgets converted from reef-b-app XML drawables.
///
/// This file provides Flutter Widget equivalents for reef-b-app's
/// gradient XML drawables.
library;

import 'package:flutter/material.dart';

/// Rainbow gradient widget.
///
/// PARITY: Mirrors reef-b-app's rainbow_gradient.xml
/// Creates a horizontal rainbow gradient effect with specific color stops.
/// Gradient from left to right with 7 color stops matching reef-b-app.
class ReefRainbowGradient extends StatelessWidget {
  const ReefRainbowGradient({
    super.key,
    required this.child,
    this.height,
    this.width,
  });

  final Widget child;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.1615, 0.3281, 0.5, 0.6653, 0.8367, 1.0],
          colors: const [
            Color(0xFFFF0B00), // Red
            Color(0xFFFE7204), // Orange
            Color(0xFFF9FE10), // Yellow
            Color(0xFF37FF11), // Green
            Color(0xFF09FDFD), // Cyan
            Color(0xFF1823FF), // Blue
            Color(0xFF6310AD), // Purple
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Helper to create a gradient container.
Container createGradientContainer({
  required List<Color> colors,
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
  double? width,
  double? height,
  Widget? child,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: begin, end: end, colors: colors),
    ),
    child: child,
  );
}
