import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../domain/led_lighting/led_record.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

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
    final l10n = AppLocalizations.of(context);
    if (records.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            l10n.noRecords,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surface.withValues(alpha: 0.2),
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
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
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
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.3),
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
              color: AppColors.coldWhite,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Royal Blue
            LineChartBarData(
              spots: royalBlueSpots,
              isCurved: false,
              color: AppColors.royalBlue,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Blue
            LineChartBarData(
              spots: blueSpots,
              isCurved: false,
              color: AppColors.blue,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Red
            LineChartBarData(
              spots: redSpots,
              isCurved: false,
              color: AppColors.red,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Green
            LineChartBarData(
              spots: greenSpots,
              isCurved: false,
              color: AppColors.green,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Purple
            LineChartBarData(
              spots: purpleSpots,
              isCurved: false,
              color: AppColors.purple,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // UV
            LineChartBarData(
              spots: uvSpots,
              isCurved: false,
              color: AppColors.ultraviolet,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Moon Light
            LineChartBarData(
              spots: moonLightSpots,
              isCurved: false,
              color: AppColors.moonLight,
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
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: AppColors.surface,
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
                    getTooltipColor: (touchedSpot) => AppColors.surface,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final hour = (touchedSpot.x ~/ 60).floor();
                        final minute = (touchedSpot.x % 60).floor();
                        return LineTooltipItem(
                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}\n${touchedSpot.y.toInt()}%',
                          AppTextStyles.caption1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
                    return indicators.map((int index) {
                      final flLine = FlLine(
                        color: AppColors.primary,
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
                      color: AppColors.primary,
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

