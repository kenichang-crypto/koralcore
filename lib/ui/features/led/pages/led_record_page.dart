import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/error_state_widget.dart';
import '../../../components/loading_state_widget.dart';
import '../controllers/led_record_controller.dart';
import '../widgets/led_record_line_chart.dart';
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
            appBar: ReefAppBar(
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
                // PARITY: activity_led_record.xml layout_led_record
                // No padding - sections handle their own margins
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (controller.isLoading)
                    Padding(
                      padding: EdgeInsets.all(ReefSpacing.md),
                      child: const LoadingStateWidget.inline(),
                    )
                  else if (controller.records.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(ReefSpacing.md),
                      child: _LedRecordsEmptyState(l10n: l10n),
                    )
                  else ...[
                    // PARITY: layout_chart margin 16/12/16
                    Padding(
                      padding: EdgeInsets.only(
                        left: ReefSpacing.md, // dp_16 marginStart
                        top: ReefSpacing.sm, // dp_12 marginTop
                        right: ReefSpacing.md, // dp_16 marginEnd
                      ),
                      child: _LedRecordChartSection(
                        controller: controller,
                        session: session,
                        l10n: l10n,
                      ),
                    ),
                    // PARITY: tv_time_title margin 16/24/16
                    Padding(
                      padding: EdgeInsets.only(
                        left: ReefSpacing.md, // dp_16 marginStart
                        top: ReefSpacing.xl, // dp_24 marginTop
                        right: ReefSpacing.md, // dp_16 marginEnd
                      ),
                      child: _LedRecordTimeSelector(
                        controller: controller,
                        session: session,
                        l10n: l10n,
                      ),
                    ),
                    // PARITY: rv_time marginTop 8dp
                    Padding(
                      padding: EdgeInsets.only(
                        top: ReefSpacing.xs, // dp_8 marginTop
                      ),
                      child: Column(
                        children: controller.records.map(
                          (record) => _LedRecordTile(
                            record: record,
                            controller: controller,
                            session: session,
                          ),
                        ).toList(),
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
      showErrorSnackBar(context, code);
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
    // PARITY: layout_chart background_white_radius, paddingTop 16dp, paddingBottom 24dp
    return Container(
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      padding: EdgeInsets.only(
        top: ReefSpacing.md, // dp_16 paddingTop
        bottom: 24, // dp_24 paddingBottom (not standard spacing)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PARITY: tv_clock headline, text_aaaa
          Text(
            '${DateTime.now().hour.toString().padLeft(2, '0')} : ${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: ReefTextStyles.headline.copyWith(
              color: ReefColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ReefSpacing.xs),
          // PARITY: line_chart margin 8dp
          Padding(
            padding: EdgeInsets.all(ReefSpacing.xs), // dp_8 margin
            child: LedRecordLineChart(
              records: controller.records,
              selectedMinutes: controller.selectedRecord?.minutesFromMidnight,
              onTap: (minutes) {
                controller.selectTime(minutes);
              },
              height: 242, // dp_242 height
              showLegend: true,
              interactive: session.isBleConnected && !controller.isBusy,
            ),
          ),
          // PARITY: layout_btn marginTop 16dp
          Padding(
            padding: EdgeInsets.only(
              top: ReefSpacing.md, // dp_16 marginTop
              left: ReefSpacing.xs, // dp_8 marginStart (from line_chart)
              right: ReefSpacing.xs, // dp_8 marginEnd (from line_chart)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PARITY: btn_add, btn_minus, btn_prev, btn_next, btn_preview
                // IconButton 24×24dp, marginEnd 12dp
                IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 24,
                  onPressed: null, // TODO: Implement add functionality
                ),
                SizedBox(width: ReefSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: const Icon(Icons.remove),
                  iconSize: 24,
                  onPressed: null, // TODO: Implement minus functionality
                ),
                SizedBox(width: ReefSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToPreviousRecord
                      : null,
                ),
                SizedBox(width: ReefSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToNextRecord
                      : null,
                ),
                SizedBox(width: ReefSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canPreview
                      ? controller.togglePreview
                      : null,
                ),
              ],
            ),
          ),
        ],
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
    // PARITY: tv_time_title body_accent, text_aaaa
    // PARITY: btn_add_time ImageviewButton 24×24dp, marginEnd 16dp
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.time, // PARITY: @string/time
          style: ReefTextStyles.bodyAccent.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 24,
          onPressed: session.isBleConnected
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LedRecordTimeSettingPage(),
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }
}

// Removed unused _LedRecordSelectionCard class

class _LedRecordsEmptyState extends StatelessWidget {
  const _LedRecordsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ledRecordsEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: ReefSpacing.xs),
            Text(
              l10n.ledRecordsEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ReefColors.textSecondary,
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
    // PARITY: adapter_led_record.xml structure
    // ConstraintLayout: bg_aaaa
    // padding: 16/12/16/12dp
    // Contains: time (body, text_aaaa), more button (24×24dp)
    return Container(
      color: ReefColors.surface, // bg_aaaa
      child: InkWell(
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
          padding: EdgeInsets.only(
            left: ReefSpacing.md, // dp_16 paddingStart
            top: ReefSpacing.md, // dp_12 paddingTop
            right: ReefSpacing.md, // dp_16 paddingEnd
            bottom: ReefSpacing.md, // dp_12 paddingBottom
          ),
          child: Row(
            children: [
              // Time (tv_time) - body, text_aaaa
              Expanded(
                child: Text(
                  _formatMinutes(record.minutesFromMidnight),
                  style: ReefTextStyles.body.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
              // More button (img_next) - 24×24dp
              Image.asset(
                'assets/icons/ic_more_enable.png', // TODO: Add icon asset
                width: 24, // dp_24
                height: 24, // dp_24
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: ReefColors.textTertiary,
                ),
              ),
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

// Removed unused _formatChannels method

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

// Removed unused _channelLabel method
}
