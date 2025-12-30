import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Semi-circle dashboard widget matching reef-b-app's CustomDashBoard.
///
/// PARITY: Mirrors CustomDashBoard.kt which draws a semi-circle progress indicator.
/// - Height: 123dp
/// - Stroke width: 12dp
/// - Background: white arc (180 degrees)
/// - Progress: blue arc (dashboard_progress color, 0-180 degrees based on percentage)
/// - Label: percentage text centered in the semi-circle
class SemiCircleDashboard extends StatelessWidget {
  final int percentage; // 0-100
  final Color? progressColor;
  final Color? backgroundColor;
  final double? height;
  final double? strokeWidth;

  const SemiCircleDashboard({
    super.key,
    required this.percentage,
    this.progressColor,
    this.backgroundColor,
    this.height,
    this.strokeWidth,
  }) : assert(percentage >= 0 && percentage <= 100);

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 123.0; // dp_123
    final effectiveStrokeWidth = strokeWidth ?? 12.0; // dp_12
    final effectiveProgressColor =
        progressColor ?? AppColors.dashboardProgress; // dashboard_progress
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.surface; // white

    return SizedBox(
      height: effectiveHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(double.infinity, effectiveHeight),
            painter: _SemiCircleDashboardPainter(
              percentage: percentage,
              progressColor: effectiveProgressColor,
              backgroundColor: effectiveBackgroundColor,
              strokeWidth: effectiveStrokeWidth,
            ),
          ),
          // Center label showing percentage
          Text(
            '$percentage %',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textSecondary, // text_aaa
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCircleDashboardPainter extends CustomPainter {
  final int percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _SemiCircleDashboardPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // PARITY: CustomDashBoard.kt logic
    // - Translate to center bottom: canvas.translate(width / 2f, height/1f)
    // - Draw arc from 180 degrees, 180 degrees (semi-circle)
    // - Progress arc: 180 degrees + percentage * 180 / 100

    final paint = Paint()
      ..isAntiAlias = true // 消除鋸齒
      ..strokeJoin = StrokeJoin.bevel
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Calculate arc bounds
    // PARITY: mRectF.set(height*-0.9f, height*-0.9f, height*0.9f, height*0.9f)
    final arcRadius = size.height * 0.9;
    final rect = Rect.fromLTRB(
      -arcRadius,
      -arcRadius,
      arcRadius,
      arcRadius,
    );

    // Translate to center bottom
    canvas.save();
    canvas.translate(size.width / 2, size.height);

    // Draw background arc (white, 180 degrees)
    paint.color = backgroundColor;
    canvas.drawArc(
      rect,
      _degreesToRadians(180), // Start at 180 degrees (left)
      _degreesToRadians(180), // 180 degrees (semi-circle)
      false, // useCenter = false
      paint,
    );

    // Draw progress arc (blue, based on percentage)
    paint.color = progressColor;
    final progressAngle = percentage * 180.0 / 100.0; // Convert percentage to degrees
    canvas.drawArc(
      rect,
      _degreesToRadians(180), // Start at 180 degrees (left)
      _degreesToRadians(progressAngle), // Progress angle
      false, // useCenter = false
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SemiCircleDashboardPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }

  static const _pi = 3.141592653589793;

  static double _degreesToRadians(double degrees) {
    return degrees * _pi / 180.0;
  }
}

