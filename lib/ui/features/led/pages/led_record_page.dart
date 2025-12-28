import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../domain/led_lighting/led_record_state.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../theme/reef_colors.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/led_record_controller.dart';
import '../widgets/led_record_line_chart.dart';
import '../widgets/led_spectrum_chart.dart';
import 'led_record_time_setting_page.dart';

class LedRecordPage extends StatelessWidget {
  const LedRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedRecordController>(
      create: (_) => LedRecordController(
        session: session,
        observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
        readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
        refreshLedRecordStateUseCase: appContext.refreshLedRecordStateUseCase,
        deleteLedRecordUseCase: appContext.deleteLedRecordUseCase,
        clearLedRecordsUseCase: appContext.clearLedRecordsUseCase,
        startLedPreviewUseCase: appContext.startLedPreviewUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
      )..initialize(),
      child: const _LedRecordView(),
    );
  }
}

class _LedRecordView extends StatefulWidget {
  const _LedRecordView();

  @override
  State<_LedRecordView> createState() => _LedRecordViewState();
}

class _LedRecordViewState extends State<_LedRecordView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedRecordController>(
      builder: (context, session, controller, _) {
        _maybeShowError(context, controller);
        _maybeShowEvent(context, controller);

        return WillPopScope(
          onWillPop: () async {
            await controller.handleBackNavigation();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.ledRecordsTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await controller.handleBackNavigation();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.actionRetry,
                  onPressed: controller.isBusy ? null : controller.refresh,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: l10n.ledRecordsActionClear,
                  onPressed: !session.isBleConnected || !controller.canClear
                      ? null
                      : () => _confirmClear(context, controller),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spacingXL),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text(
                    l10n.ledRecordsSubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  if (!session.isBleConnected) ...[
                    const BleGuardBanner(),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                  if (controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingXXL,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.records.isEmpty)
                    _LedRecordsEmptyState(l10n: l10n)
                  else ...[
                    _LedRecordChartSection(
                      controller: controller,
                      session: session,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    _LedRecordTimeSelector(
                      controller: controller,
                      session: session,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    _LedRecordSelectionCard(
                      controller: controller,
                      session: session,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    ...controller.records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingM,
                        ),
                        child: _LedRecordTile(
                          record: record,
                          controller: controller,
                          session: session,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _maybeShowError(BuildContext context, LedRecordController controller) {
    final code = controller.lastErrorCode;
    if (code == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(describeAppError(AppLocalizations.of(context), code)),
        ),
      );
      controller.clearError();
    });
  }

  void _maybeShowEvent(BuildContext context, LedRecordController controller) {
    final event = controller.consumeEvent();
    if (event == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final String? message = _messageForEvent(l10n, event);
    if (message == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  String? _messageForEvent(AppLocalizations l10n, LedRecordEvent event) {
    switch (event.type) {
      case LedRecordEventType.deleteSuccess:
        return l10n.ledRecordsSnackDeleted;
      case LedRecordEventType.deleteFailure:
        return describeAppError(
          l10n,
          event.errorCode ?? AppErrorCode.unknownError,
        );
      case LedRecordEventType.clearSuccess:
        return l10n.ledRecordsSnackCleared;
      case LedRecordEventType.clearFailure:
        return describeAppError(
          l10n,
          event.errorCode ?? AppErrorCode.unknownError,
        );
      case LedRecordEventType.missingSelection:
        return l10n.ledRecordsSnackMissingSelection;
      case LedRecordEventType.previewStarted:
        return l10n.ledRecordsSnackPreviewStarted;
      case LedRecordEventType.previewStopped:
        return l10n.ledRecordsSnackPreviewStopped;
      case LedRecordEventType.previewFailed:
        return describeAppError(
          l10n,
          event.errorCode ?? AppErrorCode.unknownError,
        );
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    LedRecordController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.ledRecordsClearConfirmTitle),
          content: Text(l10n.ledRecordsClearConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.ledRecordsActionClear),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await controller.clearRecords();
    }
  }
}

class _LedRecordChartSection extends StatelessWidget {
  const _LedRecordChartSection({
    required this.controller,
    required this.session,
    required this.l10n,
  });

  final LedRecordController controller;
  final AppSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledRecordsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            LedRecordLineChart(
              records: controller.records,
              selectedMinutes: controller.selectedRecord?.minutesFromMidnight,
              onTap: (minutes) {
                controller.selectTime(minutes);
              },
              height: 250,
              showLegend: true,
              interactive: session.isBleConnected && !controller.isBusy,
            ),
          ],
        ),
      ),
    );
  }
}

class _LedRecordTimeSelector extends StatelessWidget {
  const _LedRecordTimeSelector({
    required this.controller,
    required this.session,
    required this.l10n,
  });

  final LedRecordController controller;
  final AppSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ledRecordsSelectedTimeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  currentTime,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.ledRecordsActionPrev,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToPreviousRecord
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.ledRecordsActionNext,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToNextRecord
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedRecordSelectionCard extends StatelessWidget {
  const _LedRecordSelectionCard({
    required this.controller,
    required this.session,
  });

  final LedRecordController controller;
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String statusLabel = _statusLabel(l10n, controller.status);
    final bool canTogglePreview =
        session.isBleConnected &&
        (controller.isPreviewing || controller.canPreview);
    final Map<String, int> spectrum =
        controller.selectedRecord?.channelLevels ??
        (controller.records.isNotEmpty
            ? controller.records.first.channelLevels
            : const <String, int>{});

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ledRecordsSelectedTimeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        controller.selectedTimeLabel,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Text(statusLabel, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            LedSpectrumChart.fromChannelMap(
              spectrum,
              height: 72,
              compact: true,
              emptyLabel: l10n.ledControlEmptyState,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Wrap(
              spacing: AppDimensions.spacingM,
              runSpacing: AppDimensions.spacingS,
              children: [
                OutlinedButton.icon(
                  onPressed: controller.canNavigate && session.isBleConnected
                      ? controller.goToPreviousRecord
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.ledRecordsActionPrev),
                ),
                OutlinedButton.icon(
                  onPressed: controller.canNavigate && session.isBleConnected
                      ? controller.goToNextRecord
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(l10n.ledRecordsActionNext),
                ),
                OutlinedButton.icon(
                  onPressed:
                      session.isBleConnected && controller.canDeleteSelected
                      ? () => _confirmDelete(context, controller)
                      : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.ledRecordsActionDelete),
                ),
                FilledButton.icon(
                  onPressed: canTogglePreview ? controller.togglePreview : null,
                  icon: Icon(
                    controller.isPreviewing ? Icons.stop : Icons.play_arrow,
                  ),
                  label: Text(
                    controller.isPreviewing
                        ? l10n.ledRecordsActionPreviewStop
                        : l10n.ledRecordsActionPreviewStart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, LedRecordStatus? status) {
    switch (status) {
      case LedRecordStatus.applying:
        return l10n.ledRecordsStatusApplying;
      case LedRecordStatus.previewing:
        return l10n.ledRecordsStatusPreview;
      case LedRecordStatus.idle:
      case LedRecordStatus.error:
      case null:
        return l10n.ledRecordsStatusIdle;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LedRecordController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.ledRecordsDeleteConfirmTitle),
          content: Text(l10n.ledRecordsDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await controller.deleteSelectedRecord();
    }
  }
}

class _LedRecordsEmptyState extends StatelessWidget {
  const _LedRecordsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ledRecordsEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.ledRecordsEmptySubtitle,
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

class _LedRecordTile extends StatelessWidget {
  const _LedRecordTile({
    required this.record,
    required this.controller,
    required this.session,
  });

  final LedRecord record;
  final LedRecordController controller;
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final bool selected = controller.selectedRecord?.id == record.id;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final String summary = _formatChannels(record.channelLevels, l10n);

    return Material(
      color: selected
          ? ReefColors.primary.withValues(alpha: 0.08)
          : ReefColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: () {
          controller.selectRecord(record.id);
          // Navigate to time setting page for editing
          if (session.isBleConnected && !controller.isBusy) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LedRecordTimeSettingPage(initialRecord: record),
              ),
            );
          }
        },
        onLongPress: session.isBleConnected && !controller.isBusy
            ? () => _confirmDeleteRecord(context, controller, record)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMinutes(record.minutesFromMidnight),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: ReefColors.primary)
              else
                const Icon(Icons.chevron_right, color: AppColors.grey500),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final int safe = minutes.clamp(0, 1439);
    final int hour = safe ~/ 60;
    final int minute = safe % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatChannels(Map<String, int> levels, AppLocalizations l10n) {
    if (levels.isEmpty) {
      return l10n.ledControlEmptyState;
    }
    final Iterable<String> parts = levels.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '${_channelLabel(entry.key, l10n)} ${entry.value}%');
    final String summary = parts.join(' / ');
    return summary.isEmpty ? l10n.ledControlEmptyState : summary;
  }

  Future<void> _confirmDeleteRecord(
    BuildContext context,
    LedRecordController controller,
    LedRecord record,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.ledRecordsDeleteConfirmTitle),
          content: Text(l10n.ledRecordsDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      // Select the record first, then delete it
      controller.selectRecord(record.id);
      await controller.deleteSelectedRecord();
    }
  }

  String _channelLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'coldWhite':
        return l10n.ledScheduleEditChannelWhite;
      case 'royalBlue':
        return l10n.ledScheduleEditChannelBlue;
      case 'blue':
        return l10n.ledChannelBlue;
      case 'green':
        return l10n.ledChannelGreen;
      case 'red':
        return l10n.ledChannelRed;
      case 'purple':
        return l10n.ledChannelPurple;
      case 'uv':
        return l10n.ledChannelUv;
      case 'warmWhite':
        return l10n.ledChannelWarmWhite;
      case 'moonLight':
        return l10n.ledChannelMoon;
      default:
        return key;
    }
  }
}
