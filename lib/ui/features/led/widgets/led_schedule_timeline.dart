import 'package:flutter/material.dart';

import '../../../assets/common_icon_helper.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';

/// Simple 24h placeholder timeline used to visualize LED schedule windows.
class LedScheduleTimeline extends StatelessWidget {
  const LedScheduleTimeline({
    super.key,
    required this.start,
    required this.end,
    this.isActive = false,
    this.previewMinutes,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final bool isActive;
  final int? previewMinutes;

  static const double _trackHeight = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('00:00'),
            _label('06:00'),
            _label('12:00'),
            _label('18:00'),
            _label('24:00'),
          ],
        ),
        const SizedBox(height: ReefSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final Segment segment = _segmentForWindow(start, end);
            final double left = width * segment.startRatio;
            final double right = width * segment.endRatio;
            final double segmentWidth = segment.wraps
                ? width - left + right
                : (right - left).clamp(0.0, width);

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: ReefColors.textSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ReefRadius.pill),
                  ),
                ),
                Positioned(
                  left: left,
                  child: Container(
                    height: _trackHeight,
                    width: segment.wraps ? width - left : segmentWidth,
                    decoration: BoxDecoration(
                      color: _activeColor,
                      borderRadius: BorderRadius.circular(ReefRadius.pill),
                    ),
                  ),
                ),
                if (segment.wraps)
                  Positioned(
                    left: 0,
                    child: Container(
                      height: _trackHeight,
                      width: right,
                      decoration: BoxDecoration(
                        color: _activeColor,
                        borderRadius: BorderRadius.circular(ReefRadius.pill),
                      ),
                    ),
                  ),
                if (previewMinutes != null)
                  Positioned(
                    left: width * (previewMinutes!.clamp(0, 1439) / 1440.0) - 8,
                    child: CommonIconHelper.getPreviewIcon(
                      size: 16,
                      color: ReefColors.info,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: ReefSpacing.xs),
        Text(
          _windowLabel(context, start, end),
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color get _activeColor =>
      isActive ? ReefColors.success.withValues(alpha: 0.7) : ReefColors.primary;

  Widget _label(String text) {
    return Text(
      text,
      style: ReefTextStyles.caption1.copyWith(
        color: ReefColors.textSecondary.withValues(alpha: 0.8),
      ),
    );
  }
}

class Segment {
  const Segment({
    required this.startRatio,
    required this.endRatio,
    required this.wraps,
  });

  final double startRatio;
  final double endRatio;
  final bool wraps;
}

Segment _segmentForWindow(TimeOfDay start, TimeOfDay end) {
  final double startRatio = _ratio(start);
  final double endRatio = _ratio(end);
  final bool wraps = endRatio <= startRatio;
  return Segment(startRatio: startRatio, endRatio: endRatio, wraps: wraps);
}

double _ratio(TimeOfDay time) {
  final int total = time.hour * 60 + time.minute;
  return total.clamp(0, 1439) / 1440.0;
}

String _windowLabel(BuildContext context, TimeOfDay start, TimeOfDay end) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final bool use24h =
      MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false;
  final String startLabel = localizations.formatTimeOfDay(
    start,
    alwaysUse24HourFormat: use24h,
  );
  final String endLabel = localizations.formatTimeOfDay(
    end,
    alwaysUse24HourFormat: use24h,
  );
  return '$startLabel – $endLabel';
}
