import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../models/led_schedule_summary.dart';

/// Lightweight multi-channel spectrum bar chart used across LED screens.
class LedSpectrumChart extends StatelessWidget {
  const LedSpectrumChart._({
    super.key,
    required List<_LedSpectrumSample> samples,
    required this.height,
    required this.compact,
    required this.emptyLabel,
  }) : _samples = samples;

  factory LedSpectrumChart.fromChannelMap(
    Map<String, int> channelLevels, {
    Key? key,
    double height = 96,
    bool compact = false,
    String? emptyLabel,
  }) {
    return LedSpectrumChart._(
      key: key,
      samples: _buildSamplesFromMap(channelLevels),
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

  final List<_LedSpectrumSample> _samples;
  final double height;
  final bool compact;
  final String? emptyLabel;

  static const double _barWidth = 18;

  @override
  Widget build(BuildContext context) {
    if (_samples.isEmpty) {
      return _emptyState();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: compact ? 0.35 : 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _samples
            .map(
              (sample) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: _SpectrumBar(
                    sample: sample,
                    maxHeight: height,
                    compact: compact,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

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

class _SpectrumBar extends StatelessWidget {
  const _SpectrumBar({
    required this.sample,
    required this.maxHeight,
    required this.compact,
  });

  final _LedSpectrumSample sample;
  final double maxHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double fillHeight =
        (sample.percentage.clamp(0, 100) / 100) * maxHeight;
    final TextStyle captionStyle =
        (compact ? AppTextStyles.caption1 : AppTextStyles.caption1Accent)
            .copyWith(color: AppColors.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxHeight,
          width: LedSpectrumChart._barWidth,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: fillHeight,
                decoration: BoxDecoration(
                  color: sample.color,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  boxShadow: [
                    BoxShadow(
                      color: sample.color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          sample.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: captionStyle,
        ),
        Text(
          '${sample.percentage}%',
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LedSpectrumSample {
  const _LedSpectrumSample({
    required this.id,
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String id;
  final String label;
  final int percentage;
  final Color color;
}

List<_LedSpectrumSample> _buildSamplesFromMap(Map<String, int> levels) {
  if (levels.isEmpty) {
    return const <_LedSpectrumSample>[];
  }

  final List<String> orderedKeys = <String>[];
  for (final String key in _channelOrder) {
    if (levels.containsKey(key)) {
      orderedKeys.add(key);
    }
  }
  for (final String key in levels.keys) {
    if (!orderedKeys.contains(key)) {
      orderedKeys.add(key);
    }
  }

  return orderedKeys
      .map(
        (key) => _LedSpectrumSample(
          id: key,
          label: _channelLabel(key),
          percentage: levels[key]?.clamp(0, 100) ?? 0,
          color: _channelColor(key),
        ),
      )
      .where((sample) => sample.percentage > 0)
      .toList(growable: false);
}

const List<String> _channelOrder = <String>[
  'red',
  'green',
  'blue',
  'royalBlue',
  'purple',
  'uv',
  'warmWhite',
  'coldWhite',
  'moonLight',
];

Color _channelColor(String id) {
  switch (id) {
    case 'red':
      return AppColors.red;
    case 'green':
      return AppColors.green;
    case 'blue':
      return AppColors.blue;
    case 'royalBlue':
      return AppColors.royalBlue;
    case 'purple':
      return AppColors.purple;
    case 'uv':
    case 'ultraviolet':
      return AppColors.ultraviolet;
    case 'warmWhite':
      return AppColors.warmWhite;
    case 'coldWhite':
    case 'white':
      return AppColors.coldWhite;
    case 'moonLight':
    case 'moon':
      return AppColors.moonLight;
    default:
      return AppColors.primary;
  }
}

String _channelLabel(String id) {
  switch (id) {
    case 'red':
      return 'Red';
    case 'green':
      return 'Green';
    case 'blue':
      return 'Blue';
    case 'royalBlue':
      return 'Royal';
    case 'purple':
      return 'Purple';
    case 'uv':
    case 'ultraviolet':
      return 'UV';
    case 'warmWhite':
      return 'Warm';
    case 'coldWhite':
    case 'white':
      return 'Cool';
    case 'moonLight':
      return 'Moon';
    default:
      return id;
  }
}
