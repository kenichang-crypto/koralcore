import 'package:flutter/material.dart';

import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
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
        horizontal: compact ? ReefSpacing.sm : ReefSpacing.md,
        vertical: compact ? ReefSpacing.sm : ReefSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ReefColors.surface.withValues(alpha: compact ? 0.35 : 0.5),
        borderRadius: BorderRadius.circular(ReefSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _samples
            .map(
              (sample) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.xs,
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
      padding: const EdgeInsets.all(ReefSpacing.md),
      decoration: BoxDecoration(
        color: ReefColors.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(ReefSpacing.md),
      ),
      child: Center(
        child: Text(
          emptyLabel ?? 'No spectrum data',
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
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
        (compact ? ReefTextStyles.caption1 : ReefTextStyles.caption1Accent)
            .copyWith(color: ReefColors.textSecondary);

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
                  color: ReefColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ReefSpacing.xs),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: fillHeight,
                decoration: BoxDecoration(
                  color: sample.color,
                  borderRadius: BorderRadius.circular(ReefSpacing.xs),
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
        const SizedBox(height: ReefSpacing.xs),
        Text(
          sample.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: captionStyle,
        ),
        Text(
          '${sample.percentage}%',
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textPrimary,
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
      return ReefColors.red;
    case 'green':
      return ReefColors.green;
    case 'blue':
      return ReefColors.blue;
    case 'royalBlue':
      return ReefColors.royalBlue;
    case 'purple':
      return ReefColors.purple;
    case 'uv':
    case 'ultraviolet':
      return ReefColors.ultraviolet;
    case 'warmWhite':
      return ReefColors.warmWhite;
    case 'coldWhite':
    case 'white':
      return ReefColors.coldWhite;
    case 'moonLight':
    case 'moon':
      return ReefColors.moonLight;
    default:
      return ReefColors.primary;
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
