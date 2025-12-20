import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/pump_head_schedule_controller.dart';
import '../models/pump_head_schedule_entry.dart';
import 'schedule_edit_page.dart';

class PumpHeadSchedulePage extends StatelessWidget {
  final String headId;

  const PumpHeadSchedulePage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadScheduleController>(
      create: (_) => PumpHeadScheduleController(
        headId: headId,
        session: session,
        readScheduleUseCase: appContext.readScheduleUseCase,
        applyScheduleUseCase: appContext.applyScheduleUseCase,
      )..refresh(),
      child: _PumpHeadScheduleView(headId: headId),
    );
  }
}

class _PumpHeadScheduleView extends StatelessWidget {
  final String headId;

  const _PumpHeadScheduleView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, PumpHeadScheduleController>(
      builder: (context, session, controller, _) {
        final theme = Theme.of(context);
        final isConnected = session.isBleConnected;
        final entries = controller.entries;
        _maybeShowError(context, controller.lastErrorCode);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.dosingScheduleOverviewTitle)),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              children: [
                Text(
                  l10n.dosingPumpHeadSummaryTitle(headId.toUpperCase()),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  l10n.dosingScheduleOverviewSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                FilledButton.icon(
                  onPressed: isConnected
                      ? () => _openScheduleEditor(context)
                      : null,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dosingScheduleAddButton),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                FilledButton(
                  onPressed: isConnected
                      ? () => _openScheduleEditor(
                          context,
                          templateType: PumpHeadScheduleType.dailyAverage,
                        )
                      : null,
                  child: Text(l10n.dosingScheduleEditTemplateDaily),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                OutlinedButton(
                  onPressed: isConnected
                      ? () => _openScheduleEditor(
                          context,
                          templateType: PumpHeadScheduleType.customWindow,
                        )
                      : null,
                  child: Text(l10n.dosingScheduleEditTemplateCustom),
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
                else if (entries.isEmpty)
                  _ScheduleEmptyState(l10n: l10n)
                else
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      child: _ScheduleEntryCard(
                        entry: entry,
                        isConnected: isConnected,
                        l10n: l10n,
                        onTap: () => _openScheduleEditor(context, entry: entry),
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

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PumpHeadScheduleController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      controller.clearError();
    });
  }

  Future<void> _openScheduleEditor(
    BuildContext context, {
    PumpHeadScheduleType? templateType,
    PumpHeadScheduleEntry? entry,
  }) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScheduleEditPage(
          headId: headId,
          initialEntry: entry,
          initialType:
              templateType ?? entry?.type ?? PumpHeadScheduleType.dailyAverage,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dosingScheduleEditSuccess)));
    }
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
            const Icon(Icons.calendar_today_outlined, size: 32),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              l10n.dosingScheduleEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.dosingScheduleEmptySubtitle,
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

class _ScheduleEntryCard extends StatelessWidget {
  final PumpHeadScheduleEntry entry;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ScheduleEntryCard({
    required this.entry,
    required this.isConnected,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _typeLabel(entry.type, l10n);
    final recurrence = _recurrenceLabel(entry.recurrence, l10n);
    final statusLabel = entry.isEnabled
        ? l10n.dosingScheduleStatusEnabled
        : l10n.dosingScheduleStatusDisabled;
    final statusColor = entry.isEnabled ? AppColors.grey700 : AppColors.warning;
    final Color chipColor = entry.isEnabled
        ? AppColors.ocean500
        : AppColors.grey500;
    final Color chipBackground = entry.isEnabled
        ? AppColors.ocean500.withOpacity(0.12)
        : AppColors.grey100;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: isConnected ? onTap : () => showBleGuardDialog(context),
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
                      color: chipBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: chipColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(_headline(entry), style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDimensions.spacingXS),
              if (entry.isWindow)
                Text(
                  '${_formatTime(entry.startTime)} – ${_formatTime(entry.endTime!)}',
                  style: theme.textTheme.bodyMedium,
                )
              else
                Text(
                  _formatTime(entry.startTime),
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                '$recurrence • $statusLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: entry.isEnabled ? null : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headline(PumpHeadScheduleEntry entry) {
    switch (entry.type) {
      case PumpHeadScheduleType.dailyAverage:
        return '${entry.eventsPerDay}x • ${entry.totalDailyMl.toStringAsFixed(1)} ml/day';
      case PumpHeadScheduleType.customWindow:
        return '${entry.eventsPerDay}x • ${entry.doseMlPerEvent.toStringAsFixed(1)} ml each';
      case PumpHeadScheduleType.singleDose:
        return '${entry.doseMlPerEvent.toStringAsFixed(1)} ml';
    }
  }

  String _typeLabel(PumpHeadScheduleType type, AppLocalizations l10n) {
    switch (type) {
      case PumpHeadScheduleType.dailyAverage:
        return l10n.dosingScheduleTypeDaily;
      case PumpHeadScheduleType.singleDose:
        return l10n.dosingScheduleTypeSingle;
      case PumpHeadScheduleType.customWindow:
        return l10n.dosingScheduleTypeCustom;
    }
  }

  String _recurrenceLabel(
    PumpHeadScheduleRecurrence recurrence,
    AppLocalizations l10n,
  ) {
    switch (recurrence) {
      case PumpHeadScheduleRecurrence.daily:
        return l10n.dosingScheduleRecurrenceDaily;
      case PumpHeadScheduleRecurrence.weekdays:
        return l10n.dosingScheduleRecurrenceWeekdays;
      case PumpHeadScheduleRecurrence.weekends:
        return l10n.dosingScheduleRecurrenceWeekends;
    }
  }

  String _formatTime(TimeOfDay time) {
    final date = DateTime(2020, 1, 1, time.hour, time.minute);
    return DateFormat('h:mm a').format(date);
  }
}
