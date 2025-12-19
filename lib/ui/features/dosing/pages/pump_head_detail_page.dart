import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_schedule/dosing_schedule_summary.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/pump_head_detail_controller.dart';
import '../models/pump_head_summary.dart';
import 'pump_head_calibration_page.dart';
import 'pump_head_schedule_page.dart';
import 'pump_head_settings_page.dart';

class PumpHeadDetailPage extends StatelessWidget {
  final String headId;

  const PumpHeadDetailPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadDetailController>(
      create: (_) => PumpHeadDetailController(
        headId: headId,
        session: session,
        readTodayTotalUseCase: appContext.readTodayTotalUseCase,
        readDosingScheduleSummaryUseCase:
            appContext.readDosingScheduleSummaryUseCase,
        singleDoseImmediateUseCase: appContext.singleDoseImmediateUseCase,
        singleDoseTimedUseCase: appContext.singleDoseTimedUseCase,
      )..refresh(),
      child: _PumpHeadDetailView(headId: headId),
    );
  }
}

class _PumpHeadDetailView extends StatelessWidget {
  final String headId;

  const _PumpHeadDetailView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<AppSession, PumpHeadDetailController>(
      builder: (context, session, controller, _) {
        final summary = controller.summary;
        final deviceName = session.activeDeviceName ?? l10n.appTitle;
        final isConnected = session.isBleConnected;
        _maybeShowError(context, controller.lastErrorCode);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.dosingPumpHeadSummaryTitle(summary.headId)),
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
                _StatusCard(
                  summary: summary,
                  deviceName: deviceName,
                  isLoading: controller.isLoading,
                  l10n: l10n,
                ),
                const SizedBox(height: AppDimensions.spacingXL),
                _MetricsGrid(summary: summary, l10n: l10n),
                const SizedBox(height: AppDimensions.spacingXL),
                _TodayDoseCard(controller: controller, l10n: l10n),
                const SizedBox(height: AppDimensions.spacingXL),
                _ScheduleSummaryCard(controller: controller, l10n: l10n),
                const SizedBox(height: AppDimensions.spacingXL),
                _ScheduleOverviewTile(
                  headId: headId,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: AppDimensions.spacingXL),
                _CalibrationHistoryTile(
                  headId: headId,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: AppDimensions.spacingXL),
                _SettingsTile(
                  headId: headId,
                  initialName: summary.displayName,
                  initialDelaySeconds: 0,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: AppDimensions.spacingXL),
                _ActionButtons(
                  isConnected: isConnected,
                  l10n: l10n,
                  controller: controller,
                ),
                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final PumpHeadSummary summary;
  final String deviceName;
  final bool isLoading;
  final AppLocalizations l10n;

  const _StatusCard({
    required this.summary,
    required this.deviceName,
    required this.isLoading,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.displayName, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              summary.additiveName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Row(
              children: [
                Chip(
                  label: Text(_statusLabel(l10n, summary.statusKey)),
                  backgroundColor: AppColors.ocean500.withOpacity(0.1),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.ocean500,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: AppDimensions.spacingM),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              l10n.homeStatusConnected(deviceName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String statusKey) {
    switch (statusKey) {
      case 'ready':
        return l10n.dosingPumpHeadStatusReady;
      default:
        return l10n.dosingPumpHeadStatus;
    }
  }
}

class _MetricsGrid extends StatelessWidget {
  final PumpHeadSummary summary;
  final AppLocalizations l10n;

  const _MetricsGrid({required this.summary, required this.l10n});

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
            .max(160, (availableWidth - AppDimensions.spacingL) / 2)
            .toDouble();

        return Wrap(
          spacing: AppDimensions.spacingL,
          runSpacing: AppDimensions.spacingL,
          children: metricCards
              .map(
                (metric) => SizedBox(
                  width: cardWidth,
                  child: _MetricCard(label: metric.label, value: metric.value),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;

  const _MetricData({required this.label, required this.value});
}

class _TodayDoseCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final AppLocalizations l10n;

  const _TodayDoseCard({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content;
    if (controller.isTodayDoseLoading) {
      content = const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      final summary = controller.todayDoseSummary;
      if (summary == null) {
        content = Text(
          l10n.dosingTodayTotalEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
        );
      } else {
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TodayDoseValue(
                label: l10n.dosingTodayTotalTotal,
                value: summary.totalMl,
                emphasize: true,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TodayDoseValue(
                    label: l10n.dosingTodayTotalScheduled,
                    value: summary.scheduledMl,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _TodayDoseValue(
                    label: l10n.dosingTodayTotalManual,
                    value: summary.manualMl,
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingTodayTotalTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            content,
          ],
        ),
      ),
    );
  }
}

class _TodayDoseValue extends StatelessWidget {
  final String label;
  final double? value;
  final bool emphasize;

  const _TodayDoseValue({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.grey700,
    );
    final TextStyle? valueStyle = emphasize
        ? theme.textTheme.headlineMedium
        : theme.textTheme.titleMedium;

    final String valueText = value == null
        ? '—'
        : '${value!.toStringAsFixed(1)} ml';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(valueText, style: valueStyle),
      ],
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final AppLocalizations l10n;

  const _ScheduleSummaryCard({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content;
    if (controller.isScheduleSummaryLoading) {
      content = const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      final summary = controller.dosingScheduleSummary;
      if (summary == null || !summary.hasSchedule) {
        content = Text(
          l10n.dosingScheduleSummaryEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
        );
      } else {
        final List<String> countLabels = <String>[];
        if (summary.windowCount != null) {
          countLabels.add(
            l10n.dosingScheduleSummaryWindowCount(summary.windowCount!),
          );
        }
        if (summary.slotCount != null) {
          countLabels.add(
            l10n.dosingScheduleSummarySlotCount(summary.slotCount!),
          );
        }

        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimensions.spacingS,
              runSpacing: AppDimensions.spacingS,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ocean500.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Text(
                    _scheduleSummaryModeLabel(summary.mode, l10n),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.ocean500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            if (summary.totalMlPerDay != null)
              _ScheduleSummaryMetric(
                label: l10n.dosingScheduleSummaryTotalLabel,
                value: '${summary.totalMlPerDay!.toStringAsFixed(1)} ml',
              ),
            if (countLabels.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: countLabels
                    .map(
                      (label) => Chip(
                        label: Text(label),
                        backgroundColor: AppColors.grey100,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleSummaryTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            content,
          ],
        ),
      ),
    );
  }
}

class _ScheduleSummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ScheduleSummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey700),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

String _scheduleSummaryModeLabel(
  DosingScheduleMode mode,
  AppLocalizations l10n,
) {
  switch (mode) {
    case DosingScheduleMode.dailyAverage:
      return l10n.dosingScheduleTypeDaily;
    case DosingScheduleMode.customWindow:
      return l10n.dosingScheduleTypeCustom;
    case DosingScheduleMode.none:
      return l10n.dosingScheduleSummaryEmpty;
  }
}

class _ScheduleOverviewTile extends StatelessWidget {
  final String headId;
  final bool isConnected;
  final AppLocalizations l10n;

  const _ScheduleOverviewTile({
    required this.headId,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(l10n.dosingScheduleViewButton),
        subtitle: Text(l10n.dosingScheduleOverviewSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (!isConnected) {
            showBleGuardDialog(context);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PumpHeadSchedulePage(headId: headId),
            ),
          );
        },
      ),
    );
  }
}

class _CalibrationHistoryTile extends StatelessWidget {
  final String headId;
  final bool isConnected;
  final AppLocalizations l10n;

  const _CalibrationHistoryTile({
    required this.headId,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(l10n.dosingCalibrationHistoryViewButton),
        subtitle: Text(l10n.dosingCalibrationHistorySubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (!isConnected) {
            showBleGuardDialog(context);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PumpHeadCalibrationPage(headId: headId),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String headId;
  final String initialName;
  final int initialDelaySeconds;
  final bool isConnected;
  final AppLocalizations l10n;

  const _SettingsTile({
    required this.headId,
    required this.initialName,
    required this.initialDelaySeconds,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(l10n.dosingPumpHeadSettingsTitle),
        subtitle: Text(l10n.dosingPumpHeadSettingsSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (!isConnected) {
            showBleGuardDialog(context);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PumpHeadSettingsPage(
                headId: headId,
                initialName: initialName,
                initialDelaySeconds: initialDelaySeconds,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isConnected;
  final AppLocalizations l10n;
  final PumpHeadDetailController controller;

  const _ActionButtons({
    required this.isConnected,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBusy = controller.isManualDoseInFlight;
    final bool isTimedBusy = controller.isTimedDoseInFlight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isConnected && !isBusy
              ? () => _runManualDose(context)
              : null,
          child: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dosingPumpHeadManualDose),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        OutlinedButton(
          onPressed: isConnected && !isTimedBusy
              ? () => _scheduleTimedDose(context)
              : null,
          child: isTimedBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dosingPumpHeadTimedDose),
        ),
      ],
    );
  }

  Future<void> _runManualDose(BuildContext context) async {
    final bool success = await controller.sendManualDose();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dosingPumpHeadManualDoseSuccess)),
    );
  }

  Future<void> _scheduleTimedDose(BuildContext context) async {
    final bool success = await controller.scheduleTimedDose();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dosingPumpHeadTimedDoseSuccess)),
    );
  }
}

void _maybeShowError(BuildContext context, AppErrorCode? code) {
  if (code == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final controller = context.read<PumpHeadDetailController>();
    final l10n = AppLocalizations.of(context);
    final message = describeAppError(l10n, code);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    controller.clearError();
  });
}
