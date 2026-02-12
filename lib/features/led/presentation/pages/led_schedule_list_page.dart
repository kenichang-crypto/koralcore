import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../../shared/theme/app_radius.dart';
import '../controllers/led_schedule_list_controller.dart';
import '../models/led_schedule_summary.dart';
import '../widgets/led_schedule_timeline.dart';
import '../widgets/led_spectrum_chart.dart';
import '../../../../shared/assets/common_icon_helper.dart';
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
          appBar: ReefAppBar(title: Text(l10n.ledScheduleListTitle)),
          floatingActionButton: session.isReady && !controller.isBusy
              ? FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const LedScheduleEditPage(),
                      ),
                    );
                    if (result == true && context.mounted) {
                      controller.refresh();
                    }
                  },
                  child: CommonIconHelper.getAddIcon(
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  l10n.ledScheduleListSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (controller.isBusy)
                  const LoadingStateWidget.linear(),
                if (controller.isLoading)
                  const LoadingStateWidget.inline()
                else if (controller.schedules.isEmpty)
                  _ScheduleEmptyState(l10n: l10n)
                else
                  ...controller.schedules.map(
                    (schedule) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
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
                        onTap: session.isReady && !controller.isBusy
                            ? () async {
                                final result = await Navigator.of(context)
                                    .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => LedScheduleEditPage(
                                      initialSchedule: schedule,
                                    ),
                                  ),
                                );
                                if (result == true && context.mounted) {
                                  controller.refresh();
                                }
                              }
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_ledIconAsset, width: 32, height: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ledScheduleEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.ledScheduleEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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
  final VoidCallback? onTap;
  final int? previewMinutes;

  const _ScheduleCard({
    required this.schedule,
    required this.l10n,
    this.onApply,
    this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    _typeLabel(schedule, l10n),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
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
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(schedule.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xxxs),
            Text(
              _windowLabel(schedule.startTime, schedule.endTime),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxxs),
            Text(
              l10n.ledScheduleSceneSummary(schedule.sceneName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (schedule.channels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxxs,
                children: schedule.channels
                    .map(
                      (channel) => Chip(
                        label: Text(
                          l10n.channelPercentageFormat(
                            channel.label,
                            channel.percentage,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (schedule.isDerived) ...[
              const SizedBox(height: AppSpacing.xs),
              Chip(
                label: Text(l10n.ledScheduleDerivedLabel),
                avatar: CommonIconHelper.getResetIcon(size: 16), // Using reset icon as placeholder for auto_mode
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            LedSpectrumChart.fromScheduleChannels(
              schedule.channels,
              height: 64,
              emptyLabel: l10n.ledControlEmptyState,
            ),
            const SizedBox(height: AppSpacing.xs),
            LedScheduleTimeline(
              start: schedule.startTime,
              end: schedule.endTime,
              isActive: schedule.isActive,
              previewMinutes: previewMinutes,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onApply,
                icon: schedule.isActive
                    ? CommonIconHelper.getCheckIcon(size: 20)
                    : CommonIconHelper.getPlayIcon(size: 20),
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

  showErrorSnackBar(context, code);
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
  switch (event.type) {
    case LedScheduleEventType.applySuccess:
      showSuccessSnackBar(context, l10n.ledScheduleSnackApplied);
      break;
    case LedScheduleEventType.applyFailure:
      final code = event.errorCode ?? AppErrorCode.unknownError;
      showErrorSnackBar(context, code);
      break;
  }
}
