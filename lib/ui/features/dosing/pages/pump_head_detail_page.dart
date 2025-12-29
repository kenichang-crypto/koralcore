import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/dosing_schedule_summary.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
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
          backgroundColor: ReefColors.surfaceMuted,
          appBar: ReefAppBar(
            backgroundColor: ReefColors.primary,
            foregroundColor: ReefColors.onPrimary,
            elevation: 0,
            title: Text(
              l10n.dosingPumpHeadSummaryTitle(summary.headId),
              style: ReefTextStyles.title2.copyWith(
                color: ReefColors.onPrimary,
              ),
            ),
            actions: [
              // Menu button (Edit settings)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: ReefColors.onPrimary),
                enabled: isConnected,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PumpHeadSettingsPage(
                            headId: headId,
                            initialName: summary.displayName,
                            initialDelaySeconds: 0,
                          ),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: ReefSpacing.sm),
                        Text(l10n.dosingPumpHeadSettingsTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // PARITY: General settings page layout - padding 16/12/16/40dp
              padding: EdgeInsets.only(
                left: ReefSpacing.md, // dp_16 paddingStart
                top: ReefSpacing.sm, // dp_12 paddingTop
                right: ReefSpacing.md, // dp_16 paddingEnd
                bottom: 40, // dp_40 paddingBottom
              ),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.xl),
                ],
                _StatusCard(
                  summary: summary,
                  deviceName: deviceName,
                  isLoading: controller.isLoading,
                  l10n: l10n,
                ),
                const SizedBox(height: ReefSpacing.xl),
                _MetricsGrid(summary: summary, l10n: l10n),
                const SizedBox(height: ReefSpacing.xl),
                _TodayDoseCard(controller: controller, l10n: l10n),
                const SizedBox(height: ReefSpacing.xl),
                _ScheduleSummaryCard(controller: controller, l10n: l10n),
                const SizedBox(height: ReefSpacing.xl),
                _ScheduleOverviewTile(
                  headId: headId,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: ReefSpacing.xl),
                _CalibrationHistoryTile(
                  headId: headId,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: ReefSpacing.xl),
                _SettingsTile(
                  headId: headId,
                  initialName: summary.displayName,
                  initialDelaySeconds: 0,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: ReefSpacing.xl),
                _ActionButtons(
                  isConnected: isConnected,
                  l10n: l10n,
                  controller: controller,
                ),
                const SizedBox(height: ReefSpacing.xxl),
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
    return Card(
      color: ReefColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.displayName,
              style: ReefTextStyles.title1.copyWith(
                color: ReefColors.onPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              summary.additiveName,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.onPrimary.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: ReefSpacing.lg),
            Row(
              children: [
                Chip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ReefRadius.xs),
                  ),
                  side: BorderSide.none,
                  label: Text(_statusLabel(l10n, summary.statusKey)),
                  backgroundColor: ReefColors.surface.withOpacity(0.2),
                  labelStyle: ReefTextStyles.caption1Accent.copyWith(
                    color: ReefColors.onPrimary,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: ReefSpacing.md),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: ReefSpacing.lg),
            Text(
              l10n.homeStatusConnected(deviceName),
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary.withOpacity(0.85),
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
            .max(160, (availableWidth - ReefSpacing.lg) / 2)
            .toDouble();

        return Wrap(
          spacing: ReefSpacing.lg,
          runSpacing: ReefSpacing.lg,
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
    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              value,
              style: ReefTextStyles.subheaderAccent.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
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
          style: ReefTextStyles.body.copyWith(color: ReefColors.textSecondary),
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
            const SizedBox(width: ReefSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TodayDoseValue(
                    label: l10n.dosingTodayTotalScheduled,
                    value: summary.scheduledMl,
                  ),
                  const SizedBox(height: ReefSpacing.md),
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
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingTodayTotalTitle,
              style: ReefTextStyles.title2.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.md),
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
    final TextStyle labelStyle = ReefTextStyles.caption1.copyWith(
      color: ReefColors.textSecondary,
    );
    final TextStyle valueStyle = emphasize
        ? ReefTextStyles.title1
        : ReefTextStyles.subheaderAccent;

    final String valueText = value == null
        ? '—'
        : '${value!.toStringAsFixed(1)} ml';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: ReefSpacing.xs),
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
          style: ReefTextStyles.body.copyWith(color: ReefColors.textSecondary),
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
              spacing: ReefSpacing.sm,
              runSpacing: ReefSpacing.sm,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.md,
                    vertical: ReefSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ReefColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ReefRadius.md),
                  ),
                  child: Text(
                    _scheduleSummaryModeLabel(summary.mode, l10n),
                    style: ReefTextStyles.caption1Accent.copyWith(
                      color: ReefColors.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.md),
            if (summary.totalMlPerDay != null)
              _ScheduleSummaryMetric(
                label: l10n.dosingScheduleSummaryTotalLabel,
                value: '${summary.totalMlPerDay!.toStringAsFixed(1)} ml',
              ),
            if (countLabels.isNotEmpty) ...[
              const SizedBox(height: ReefSpacing.md),
              Wrap(
                spacing: ReefSpacing.sm,
                runSpacing: ReefSpacing.sm,
                children: countLabels
                    .map(
                      (label) => Chip(
                        label: Text(
                          label,
                          style: ReefTextStyles.caption2.copyWith(
                            color: ReefColors.textSecondary,
                          ),
                        ),
                        backgroundColor: ReefColors.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ReefRadius.xs),
                        ),
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
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleSummaryTitle,
              style: ReefTextStyles.title2.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.md),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        const SizedBox(height: ReefSpacing.xs),
        Text(
          value,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.textPrimary,
          ),
        ),
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
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReefSpacing.lg,
          vertical: ReefSpacing.sm,
        ),
        title: Text(
          l10n.dosingScheduleViewButton,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingScheduleOverviewSubtitle,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: ReefColors.textSecondary,
        ),
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
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReefSpacing.lg,
          vertical: ReefSpacing.sm,
        ),
        title: Text(
          l10n.dosingCalibrationHistoryViewButton,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingCalibrationHistorySubtitle,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: ReefColors.textSecondary,
        ),
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
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReefSpacing.lg,
          vertical: ReefSpacing.sm,
        ),
        title: Text(
          l10n.dosingPumpHeadSettingsTitle,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingPumpHeadSettingsSubtitle,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: ReefColors.textSecondary,
        ),
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
          style: FilledButton.styleFrom(
            backgroundColor: ReefColors.primaryStrong,
            foregroundColor: ReefColors.onPrimary,
            textStyle: ReefTextStyles.bodyAccent,
            padding: const EdgeInsets.symmetric(vertical: ReefSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReefRadius.lg),
            ),
          ),
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
        const SizedBox(height: ReefSpacing.md),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: ReefColors.primaryStrong,
            textStyle: ReefTextStyles.bodyAccent,
            padding: const EdgeInsets.symmetric(vertical: ReefSpacing.sm),
            side: const BorderSide(color: ReefColors.primaryStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReefRadius.lg),
            ),
          ),
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
