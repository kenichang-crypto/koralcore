import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../controllers/pump_head_schedule_controller.dart';
import '../models/pump_head_schedule_entry.dart';
import 'schedule_edit_page.dart';
import 'pump_head_record_setting_page.dart';

const _dosingIconAsset = 'assets/icons/dosing_main.png';

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
        // Show error if any
        final AppErrorCode? errorCode = controller.lastErrorCode;
        if (errorCode != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              showErrorSnackBar(context, errorCode);
              controller.clearError();
            }
          });
        }

        return Scaffold(
          appBar: ReefAppBar(title: Text(l10n.dosingScheduleOverviewTitle)),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // PARITY: General settings page layout - padding 16/12/16/40dp
              padding: EdgeInsets.only(
                left: AppSpacing.md, // dp_16 paddingStart
                top: AppSpacing.sm, // dp_12 paddingTop
                right: AppSpacing.md, // dp_16 paddingEnd
                bottom: 40, // dp_40 paddingBottom
              ),
              children: [
                Text(
                  l10n.dosingPumpHeadSummaryTitle(headId.toUpperCase()),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.dosingScheduleOverviewSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: isConnected
                      ? () {
                          // Navigate to PumpHeadRecordSettingPage for new schedule
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PumpHeadRecordSettingPage(headId: headId),
                            ),
                          );
                        }
                      : null,
                  icon: CommonIconHelper.getAddIcon(size: 24),
                  label: Text(l10n.dosingScheduleAddButton),
                ),
                const SizedBox(height: AppSpacing.xs),
                FilledButton(
                  onPressed: isConnected
                      ? () => _openScheduleEditor(
                          context,
                          templateType: PumpHeadScheduleType.dailyAverage,
                        )
                      : null,
                  child: Text(l10n.dosingScheduleEditTemplateDaily),
                ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(
                  onPressed: isConnected
                      ? () => _openScheduleEditor(
                          context,
                          templateType: PumpHeadScheduleType.customWindow,
                        )
                      : null,
                  child: Text(l10n.dosingScheduleEditTemplateCustom),
                ),
                const SizedBox(height: AppSpacing.md),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (controller.isLoading)
                  const LoadingStateWidget.center()
                else if (entries.isEmpty)
                  _ScheduleEmptyState(l10n: l10n)
                else
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
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
    return EmptyStateCard(
      title: l10n.dosingScheduleEmptyTitle,
      subtitle: l10n.dosingScheduleEmptySubtitle,
      imageAsset: _dosingIconAsset,
      iconSize: 32,
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
    final statusColor = entry.isEnabled ? AppColors.textSecondary : AppColors.warning;
    final Color chipColor = entry.isEnabled
        ? AppColors.primary
        : AppColors.textTertiary;
    final Color chipBackground = entry.isEnabled
        ? AppColors.primary.withOpacity(0.12)
        : AppColors.surfaceMuted;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: isConnected ? onTap : () => showBleGuardDialog(context),
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
                      color: chipBackground,
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
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
                  CommonIconHelper.getNextIcon(size: 24),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(_headline(entry), style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxxs),
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
              const SizedBox(height: AppSpacing.xxxs),
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
