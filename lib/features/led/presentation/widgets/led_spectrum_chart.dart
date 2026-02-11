import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../domain/led/spectrum/spectrum_calculator.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../models/led_schedule_summary.dart';

/// Spectrum chart using Domain SpectrumCalculator to render the full synthesis curve.
///
/// PARITY: Matches Android's SpectrumUtil full synthesis logic (380-699nm).
class LedSpectrumChart extends StatelessWidget {
  const LedSpectrumChart._({
    super.key,
    required this.channelLevels,
    required this.height,
    required this.compact,
    required this.emptyLabel,
  });

  factory LedSpectrumChart.fromChannelMap(
    Map<String, int> channelLevels, {
    Key? key,
    double height = 96,
    bool compact = false,
    String? emptyLabel,
  }) {
    return LedSpectrumChart._(
      key: key,
      channelLevels: channelLevels,
      height: height,
      compact: compact,
      emptyLabel: emptyLabel,
    );
  }

  factory LedSpectrumChart.fromScheduleChannels(
    List<LedScheduleChannelValue> channels, {
    Key? key,
    double height = 96,
    bool compact = true,
    String? emptyLabel,
  }) {
    final Map<String, int> series = <String, int>{
      for (final LedScheduleChannelValue channel in channels)
        channel.id: channel.percentage,
    };
    return LedSpectrumChart.fromChannelMap(
      series,
      key: key,
      height: height,
      compact: compact,
      emptyLabel: emptyLabel,
    );
  }

  final Map<String, int> channelLevels;
  final double height;
  final bool compact;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (channelLevels.isEmpty) {
      return _emptyState();
    }

    // 1. Calculate full spectrum using Domain Calculator
    final calculator = SpectrumCalculator();
    final spectrumData = calculator.calculateSpectrum(
      uv: _getInt('uv') ?? _getInt('ultraviolet') ?? 0,
      purple: _getInt('purple') ?? 0,
      blue: _getInt('blue') ?? 0,
      royalBlue: _getInt('royalBlue') ?? 0,
      green: _getInt('green') ?? 0,
      red: _getInt('red') ?? 0,
      coldWhite: _getInt('coldWhite') ?? _getInt('white') ?? 0,
      moonLight: _getInt('moonLight') ?? _getInt('moon') ?? 0,
    );

    // 2. Convert to FlSpots
    // SpectrumCalculator returns 320 points corresponding to 380nm - 699nm
    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < spectrumData.length; i++) {
      final x = 380.0 + i;
      final y = spectrumData[i];
      if (y > maxY) maxY = y;
      spots.add(FlSpot(x, y));
    }

    if (maxY == 0) maxY = 100; // Default range if all zero

    // 3. Render LineChart
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: compact ? 0.35 : 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 380,
          maxX: 699,
          minY: 0,
          // Add some padding to top
          maxY: maxY * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }

  int? _getInt(String key) => channelLevels[key];

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Center(
        child: Text(
          emptyLabel ?? 'No spectrum data',
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
