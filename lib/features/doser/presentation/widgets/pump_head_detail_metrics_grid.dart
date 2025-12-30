import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../models/pump_head_summary.dart';
import 'pump_head_detail_metric_card.dart';

/// Metrics grid for pump head detail page.
class PumpHeadDetailMetricsGrid extends StatelessWidget {
  final PumpHeadSummary summary;
  final AppLocalizations l10n;

  const PumpHeadDetailMetricsGrid({
    super.key,
    required this.summary,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final metricCards = [
      _MetricData(
        label: l10n.dosingPumpHeadDailyTarget,
        value: '${summary.dailyTargetMl.toStringAsFixed(1)} ml',
      ),
      _MetricData(
        label: l10n.dosingPumpHeadTodayDispensed,
        value: '${summary.todayDispensedMl.toStringAsFixed(1)} ml',
      ),
      _MetricData(
        label: l10n.dosingPumpHeadFlowRate,
        value: '${summary.flowRateMlPerMin.toStringAsFixed(1)} ml/min',
      ),
      _MetricData(
        label: l10n.dosingPumpHeadLastDose,
        value: _formatLastDose(summary.lastDoseAt, l10n),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final double cardWidth = math
            .max(160, (availableWidth - AppSpacing.lg) / 2)
            .toDouble();

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: metricCards
              .map(
                (metric) => SizedBox(
                  width: cardWidth,
                  child: PumpHeadDetailMetricCard(
                    label: metric.label,
                    value: metric.value,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _formatLastDose(DateTime? timestamp, AppLocalizations l10n) {
    if (timestamp == null) {
      return l10n.dosingPumpHeadPlaceholder;
    }
    final formatter = DateFormat('MMM d • h:mm a');
    return formatter.format(timestamp);
  }
}

class _MetricData {
  final String label;
  final String value;

  const _MetricData({required this.label, required this.value});
}

