import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../domain/led_lighting/led_record.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';

/// Line chart widget for displaying LED records over 24 hours.
/// 
/// PARITY: Matches reef-b-app's LedMainActivity and LedRecordActivity line chart.
/// Displays channel levels (coldWhite, royalBlue, blue, red, green, purple, uv, moonLight)
/// as separate lines over a 24-hour period (0-1440 minutes).
class LedRecordLineChart extends StatelessWidget {
  const LedRecordLineChart({
    super.key,
    required this.records,
    this.selectedMinutes,
    this.onTap,
    this.height = 200,
    this.showLegend = true,
    this.interactive = false,
  });

  final List<LedRecord> records;
  final int? selectedMinutes;
  final void Function(int minutes)? onTap;
  final double height;
  final bool showLegend;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No records',
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Sort records by time
    final sortedRecords = List<LedRecord>.from(records)
      ..sort((a, b) => a.minutesFromMidnight.compareTo(b.minutesFromMidnight));

    // Build data sets for each channel
    final coldWhiteSpots = <FlSpot>[];
    final royalBlueSpots = <FlSpot>[];
    final blueSpots = <FlSpot>[];
    final redSpots = <FlSpot>[];
    final greenSpots = <FlSpot>[];
    final purpleSpots = <FlSpot>[];
    final uvSpots = <FlSpot>[];
    final moonLightSpots = <FlSpot>[];

    for (final record in sortedRecords) {
      final x = record.minutesFromMidnight.toDouble();
      coldWhiteSpots.add(FlSpot(x, (record.channelLevels['coldWhite'] ?? 0).toDouble()));
      royalBlueSpots.add(FlSpot(x, (record.channelLevels['royalBlue'] ?? 0).toDouble()));
      blueSpots.add(FlSpot(x, (record.channelLevels['blue'] ?? 0).toDouble()));
      redSpots.add(FlSpot(x, (record.channelLevels['red'] ?? 0).toDouble()));
      greenSpots.add(FlSpot(x, (record.channelLevels['green'] ?? 0).toDouble()));
      purpleSpots.add(FlSpot(x, (record.channelLevels['purple'] ?? 0).toDouble()));
      uvSpots.add(FlSpot(x, (record.channelLevels['uv'] ?? 0).toDouble()));
      moonLightSpots.add(FlSpot(x, (record.channelLevels['moonLight'] ?? 0).toDouble()));
    }

    // Add final point at 1440 (end of day) using last record values
    if (sortedRecords.isNotEmpty) {
      final lastRecord = sortedRecords.last;
      final x = 1440.0;
      coldWhiteSpots.add(FlSpot(x, (lastRecord.channelLevels['coldWhite'] ?? 0).toDouble()));
      royalBlueSpots.add(FlSpot(x, (lastRecord.channelLevels['royalBlue'] ?? 0).toDouble()));
      blueSpots.add(FlSpot(x, (lastRecord.channelLevels['blue'] ?? 0).toDouble()));
      redSpots.add(FlSpot(x, (lastRecord.channelLevels['red'] ?? 0).toDouble()));
      greenSpots.add(FlSpot(x, (lastRecord.channelLevels['green'] ?? 0).toDouble()));
      purpleSpots.add(FlSpot(x, (lastRecord.channelLevels['purple'] ?? 0).toDouble()));
      uvSpots.add(FlSpot(x, (lastRecord.channelLevels['uv'] ?? 0).toDouble()));
      moonLightSpots.add(FlSpot(x, (lastRecord.channelLevels['moonLight'] ?? 0).toDouble()));
    }

    // Build highlight spot if selected
    FlSpot? highlightSpot;
    if (selectedMinutes != null) {
      highlightSpot = FlSpot(selectedMinutes!.toDouble(), 0);
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(ReefSpacing.md),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: ReefColors.surface.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 240, // Every 4 hours
                getTitlesWidget: (value, meta) {
                  final hour = (value ~/ 60) % 24;
                  return Text(
                    '$hour:00',
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: ReefColors.surface.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          minX: 0,
          maxX: 1440,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Cold White
            LineChartBarData(
              spots: coldWhiteSpots,
              isCurved: false,
              color: ReefColors.coldWhite,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Royal Blue
            LineChartBarData(
              spots: royalBlueSpots,
              isCurved: false,
              color: ReefColors.royalBlue,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Blue
            LineChartBarData(
              spots: blueSpots,
              isCurved: false,
              color: ReefColors.blue,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Red
            LineChartBarData(
              spots: redSpots,
              isCurved: false,
              color: ReefColors.red,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Green
            LineChartBarData(
              spots: greenSpots,
              isCurved: false,
              color: ReefColors.green,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Purple
            LineChartBarData(
              spots: purpleSpots,
              isCurved: false,
              color: ReefColors.purple,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // UV
            LineChartBarData(
              spots: uvSpots,
              isCurved: false,
              color: ReefColors.ultraviolet,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Moon Light
            LineChartBarData(
              spots: moonLightSpots,
              isCurved: false,
              color: ReefColors.moonLight,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Highlight line (invisible, for touch interaction)
            if (highlightSpot != null)
              LineChartBarData(
                spots: [highlightSpot],
                isCurved: false,
                color: Colors.transparent,
                barWidth: 0,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: ReefColors.primary,
                      strokeWidth: 2,
                      strokeColor: ReefColors.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
          ],
          lineTouchData: interactive
              ? LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => ReefColors.surface,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final hour = (touchedSpot.x ~/ 60).floor();
                        final minute = (touchedSpot.x % 60).floor();
                        return LineTooltipItem(
                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}\n${touchedSpot.y.toInt()}%',
                          ReefTextStyles.caption1.copyWith(
                            color: ReefColors.textPrimary,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
                    return indicators.map((int index) {
                      final flLine = FlLine(
                        color: ReefColors.primary,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      );
                      return TouchedSpotIndicatorData(flLine, const FlDotData(show: false));
                    }).toList();
                  },
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent && touchResponse != null) {
                      final spots = touchResponse.lineBarSpots;
                      if (spots != null && spots.isNotEmpty && onTap != null) {
                        final spot = spots.first;
                        onTap!(spot.x.toInt());
                      }
                    }
                  },
                )
              : const LineTouchData(enabled: false),
          extraLinesData: ExtraLinesData(
            verticalLines: selectedMinutes != null
                ? [
                    VerticalLine(
                      x: selectedMinutes!.toDouble(),
                      color: ReefColors.primary,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}

