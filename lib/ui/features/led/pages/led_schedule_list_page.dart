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
import 'led_schedule_edit_page.dart';

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
                const SizedBox(height: AppDimensions.spacingS),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : isConnected
                        ? () => _openEditor(controller: controller, l10n: l10n)
                        : () => showBleGuardDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.ledScheduleAddButton),
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
                        onTap: isConnected
                            ? () => _openEditor(
                                controller: controller,
                                l10n: l10n,
                                schedule: schedule,
                              )
                            : () => showBleGuardDialog(context),
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

  Future<void> _openEditor({
    required LedScheduleListController controller,
    required AppLocalizations l10n,
    LedScheduleSummary? schedule,
  }) async {
    await controller.ensurePreviewStopped();
    if (!mounted) {
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LedScheduleEditPage(initialSchedule: schedule),
      ),
    );
    if (result != true) {
      return;
    }
    await controller.refresh();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ledScheduleEditSuccess)));
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
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const _ScheduleCard({
    required this.schedule,
    required this.l10n,
    this.onTap,
    this.onApply,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: onTap,
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Text(
                      _typeLabel(schedule.type, l10n),
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
                  const SizedBox(width: AppDimensions.spacingS),
                  const Icon(Icons.chevron_right),
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
                          label: Text(
                            '${channel.label} ${channel.percentage}%',
                          ),
                          backgroundColor: AppColors.ocean500.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      )
                      .toList(growable: false),
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
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onApply,
                  icon: Icon(
                    schedule.isActive ? Icons.check : Icons.play_arrow,
                  ),
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
      ),
    );
  }

  String _typeLabel(LedScheduleType type, AppLocalizations l10n) {
    switch (type) {
      case LedScheduleType.dailyProgram:
        return l10n.ledScheduleTypeDaily;
      case LedScheduleType.customWindow:
        return l10n.ledScheduleTypeCustom;
      case LedScheduleType.sceneBased:
        return l10n.ledScheduleTypeScene;
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
