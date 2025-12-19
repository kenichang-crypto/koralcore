import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_schedule_list_controller.dart';
import '../models/led_schedule_summary.dart';

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
      )..refresh(),
      child: const _LedScheduleListView(),
    );
  }
}

class _LedScheduleListView extends StatelessWidget {
  const _LedScheduleListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedScheduleListController>(
      builder: (context, session, controller, _) {
        final isConnected = session.isBleConnected;
        final theme = Theme.of(context);
        _maybeShowError(context, controller);

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
                        isConnected: isConnected,
                        l10n: l10n,
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
            const Icon(Icons.timeline_outlined, size: 32),
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
  final bool isConnected;
  final AppLocalizations l10n;

  const _ScheduleCard({
    required this.schedule,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = schedule.isEnabled
        ? l10n.ledScheduleStatusEnabled
        : l10n.ledScheduleStatusDisabled;
    final statusColor = schedule.isEnabled
        ? AppColors.success
        : AppColors.warning;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: isConnected
            ? () => _showComingSoon(context)
            : () => showBleGuardDialog(context),
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
                      color: AppColors.ocean500.withOpacity(0.12),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
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
