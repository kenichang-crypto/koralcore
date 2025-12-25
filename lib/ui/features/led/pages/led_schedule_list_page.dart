import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_schedule_list_controller.dart';
import '../models/led_schedule_summary.dart';
import '../widgets/led_schedule_timeline.dart';
import '../widgets/led_spectrum_chart.dart';

const _ledIconAsset = 'assets/icons/led/led_main.png';

class LedScheduleListPage extends StatelessWidget {
  const LedScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    final appContext = context.read<AppContext>();
    return ChangeNotifierProvider<LedScheduleListController>(
      create: (_) => LedScheduleListController(
        session: session,
        readLedScheduleUseCase: appContext.readLedScheduleUseCase,
        applyLedScheduleUseCase: appContext.applyLedScheduleUseCase,
        observeLedStateUseCase: appContext.observeLedStateUseCase,
        readLedStateUseCase: appContext.readLedStateUseCase,
        observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
        readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
      )..initialize(),
      child: const _LedScheduleListView(),
    );
  }
}

class _LedScheduleListView extends StatefulWidget {
  const _LedScheduleListView();

  @override
  State<_LedScheduleListView> createState() => _LedScheduleListViewState();
}

class _LedScheduleListViewState extends State<_LedScheduleListView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedScheduleListController>(
      builder: (context, session, controller, _) {
        final isConnected = session.isBleConnected;
        final theme = Theme.of(context);
        _maybeShowError(context, controller);
        _maybeShowEvent(context, controller);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.ledScheduleListTitle)),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              children: [
                Text(
                  l10n.ledScheduleListSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
                if (controller.isBusy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.spacingM),
                    child: LinearProgressIndicator(),
                  ),
                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingXXL,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.schedules.isEmpty)
                  _ScheduleEmptyState(l10n: l10n)
                else
                  ...controller.schedules.map(
                    (schedule) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      child: _ScheduleCard(
                        schedule: schedule,
                        l10n: l10n,
                        previewMinutes: controller.previewMinutes,
                        onApply:
                            isConnected &&
                                !controller.isBusy &&
                                schedule.isEnabled &&
                                !schedule.isActive
                            ? () => controller.applySchedule(schedule.id)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _ScheduleEmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_ledIconAsset, width: 32, height: 32),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              l10n.ledScheduleEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.ledScheduleEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final LedScheduleSummary schedule;
  final AppLocalizations l10n;
  final VoidCallback? onApply;
  final int? previewMinutes;

  const _ScheduleCard({
    required this.schedule,
    required this.l10n,
    this.onApply,
    this.previewMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = schedule.isActive
        ? l10n.ledScheduleStatusActive
        : schedule.isEnabled
        ? l10n.ledScheduleStatusEnabled
        : l10n.ledScheduleStatusDisabled;
    final statusColor = schedule.isActive
        ? AppColors.success
        : schedule.isEnabled
        ? AppColors.success
        : AppColors.warning;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ocean500.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Text(
                    _typeLabel(schedule, l10n),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.ocean500,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _recurrenceLabel(schedule.recurrence, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(schedule.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              _windowLabel(schedule.startTime, schedule.endTime),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              l10n.ledScheduleSceneSummary(schedule.sceneName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey700,
              ),
            ),
            if (schedule.channels.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingXS,
                children: schedule.channels
                    .map(
                      (channel) => Chip(
                        label: Text('${channel.label} ${channel.percentage}%'),
                        backgroundColor: AppColors.ocean500.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (schedule.isDerived) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Chip(
                label: Text(l10n.ledScheduleDerivedLabel),
                avatar: const Icon(Icons.auto_mode, size: 16),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingS),
            LedSpectrumChart.fromScheduleChannels(
              schedule.channels,
              height: 64,
              emptyLabel: l10n.ledControlEmptyState,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            LedScheduleTimeline(
              start: schedule.startTime,
              end: schedule.endTime,
              isActive: schedule.isActive,
              previewMinutes: previewMinutes,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onApply,
                icon: Icon(schedule.isActive ? Icons.check : Icons.play_arrow),
                label: Text(
                  schedule.isActive
                      ? l10n.ledScheduleStatusActive
                      : l10n.actionApply,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(LedScheduleSummary schedule, AppLocalizations l10n) {
    switch (schedule.type) {
      case LedScheduleType.dailyProgram:
        return l10n.ledScheduleDaily;
      case LedScheduleType.customWindow:
      case LedScheduleType.sceneBased:
        return l10n.ledScheduleWindow;
    }
  }

  String _recurrenceLabel(
    LedScheduleRecurrence recurrence,
    AppLocalizations l10n,
  ) {
    switch (recurrence) {
      case LedScheduleRecurrence.everyday:
        return l10n.ledScheduleRecurrenceDaily;
      case LedScheduleRecurrence.weekdays:
        return l10n.ledScheduleRecurrenceWeekdays;
      case LedScheduleRecurrence.weekends:
        return l10n.ledScheduleRecurrenceWeekends;
    }
  }

  String _windowLabel(TimeOfDay start, TimeOfDay end) {
    final formatter = DateFormat('h:mm a');
    final startDate = DateTime(2020, 1, 1, start.hour, start.minute);
    final endDate = DateTime(2020, 1, 1, end.hour, end.minute);
    return '${formatter.format(startDate)} – ${formatter.format(endDate)}';
  }
}

void _maybeShowError(
  BuildContext context,
  LedScheduleListController controller,
) {
  final code = controller.lastErrorCode;
  if (code == null) {
    return;
  }

  final message = describeAppError(AppLocalizations.of(context), code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  controller.clearError();
}

void _maybeShowEvent(
  BuildContext context,
  LedScheduleListController controller,
) {
  final event = controller.consumeEvent();
  if (event == null) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  late final String message;
  switch (event.type) {
    case LedScheduleEventType.applySuccess:
      message = l10n.ledScheduleSnackApplied;
      break;
    case LedScheduleEventType.applyFailure:
      final code = event.errorCode ?? AppErrorCode.unknownError;
      message = describeAppError(l10n, code);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
