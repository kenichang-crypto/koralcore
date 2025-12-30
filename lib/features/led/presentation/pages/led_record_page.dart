import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../controllers/led_record_controller.dart';
import '../widgets/led_record_line_chart.dart';
import 'led_record_time_setting_page.dart';
import 'led_record_setting_page.dart';
import '../../../../shared/assets/common_icon_helper.dart';

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
                icon: CommonIconHelper.getBackIcon(size: 24),
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
                  icon: CommonIconHelper.getResetIcon(size: 24),
                  tooltip: l10n.actionRetry,
                  onPressed: controller.isBusy ? null : controller.refresh,
                ),
                IconButton(
                  icon: CommonIconHelper.getDeleteIcon(
                    size: 24,
                    color: !session.isBleConnected || !controller.canClear
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
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
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: const LoadingStateWidget.inline(),
                    )
                  else if (controller.records.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: _LedRecordsEmptyState(l10n: l10n),
                    )
                  else ...[
                    // PARITY: layout_chart margin 16/12/16
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.md, // dp_16 marginStart
                        top: AppSpacing.sm, // dp_12 marginTop
                        right: AppSpacing.md, // dp_16 marginEnd
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
                        left: AppSpacing.md, // dp_16 marginStart
                        top: AppSpacing.xl, // dp_24 marginTop
                        right: AppSpacing.md, // dp_16 marginEnd
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
                        top: AppSpacing.xs, // dp_8 marginTop
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
    
    // PARITY: reef-b-app navigates to LedRecordSettingActivity on clear success
    if (event.type == LedRecordEventType.clearSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LedRecordSettingPage()),
        );
      });
      return;
    }
    
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

  static Future<void> _handleAddRecord(
    BuildContext context,
    LedRecordController controller,
    AppSession session,
    AppLocalizations l10n,
  ) async {
    // PARITY: reef-b-app checks preview state
    if (controller.isPreviewing) {
      await controller.togglePreview();
    }
    
    // Check record count limit
    if (controller.records.length >= 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ledRecordsSnackRecordsFull),
        ),
      );
      return;
    }
    
    final (hour, minute) = controller.selectedHourMinute;
    
    // Check if can add at this time
    if (!controller.canAdd) {
      // Check if time already exists
      try {
        controller.records.firstWhere(
          (r) => r.hour == hour && r.minute == minute,
        );
        // Time exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ledRecordsSnackTimeExists),
          ),
        );
      } catch (_) {
        // Time error (too close to existing records)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ledRecordsSnackTimeError),
          ),
        );
      }
      return;
    }
    
    // Navigate to time setting page with pre-filled time
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LedRecordTimeSettingPage(
          initialHour: hour,
          initialMinute: minute,
        ),
      ),
    );
  }

  static Future<void> _handleDeleteSelectedRecord(
    BuildContext context,
    LedRecordController controller,
    AppLocalizations l10n,
  ) async {
    final record = controller.selectedRecord;
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ledRecordsSnackMissingSelection),
        ),
      );
      return;
    }
    
    await _confirmDeleteRecord(context, controller, record);
  }

  static Future<void> _confirmDeleteRecord(
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
              child: Text(l10n.ledRecordsActionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await controller.deleteRecord(record.id);
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.md, // dp_16 paddingTop
        bottom: 24, // dp_24 paddingBottom (not standard spacing)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PARITY: tv_clock headline, text_aaaa
          // Display selected time or current time
          Text(
            controller.selectedTimeLabel,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary, // text_aaaa
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          // PARITY: line_chart margin 8dp
          Padding(
            padding: EdgeInsets.all(AppSpacing.xs), // dp_8 margin
            child: LedRecordLineChart(
              records: controller.records,
              selectedMinutes: controller.selectedMinutes,
              onTap: (minutes) {
                controller.selectTime(minutes);
              },
              height: 242, // dp_242 height
              showLegend: true,
              interactive: session.isBleConnected && !controller.isBusy && !controller.isPreviewing,
            ),
          ),
          // PARITY: layout_btn marginTop 16dp
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.md, // dp_16 marginTop
              left: AppSpacing.xs, // dp_8 marginStart (from line_chart)
              right: AppSpacing.xs, // dp_8 marginEnd (from line_chart)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PARITY: btn_add, btn_minus, btn_prev, btn_next, btn_preview
                // IconButton 24×24dp, marginEnd 12dp
                IconButton(
                  icon: CommonIconHelper.getAddIcon(
                    size: 24,
                    color: session.isBleConnected && controller.canAdd
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canAdd
                      ? () => _LedRecordViewState._handleAddRecord(context, controller, session, l10n)
                      : null,
                ),
                SizedBox(width: AppSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: CommonIconHelper.getMinusIcon(
                    size: 24,
                    color: session.isBleConnected && controller.canDeleteSelected
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canDeleteSelected
                      ? () => _LedRecordViewState._handleDeleteSelectedRecord(context, controller, l10n)
                      : null,
                ),
                SizedBox(width: AppSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: CommonIconHelper.getBackIcon(
                    size: 24,
                    color: session.isBleConnected && controller.canNavigate
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToPreviousRecord
                      : null,
                ),
                SizedBox(width: AppSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: CommonIconHelper.getNextIcon(
                    size: 24,
                    color: session.isBleConnected && controller.canNavigate
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  iconSize: 24,
                  onPressed: session.isBleConnected && controller.canNavigate
                      ? controller.goToNextRecord
                      : null,
                ),
                SizedBox(width: AppSpacing.sm), // dp_12 marginEnd
                IconButton(
                  icon: controller.isPreviewing
                      ? CommonIconHelper.getStopIcon(size: 24)
                      : CommonIconHelper.getPreviewIcon(size: 24),
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
          style: AppTextStyles.bodyAccent.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        IconButton(
          icon: CommonIconHelper.getAddIcon(size: 24),
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ledRecordsEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.ledRecordsEmptySubtitle,
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
      color: AppColors.surface, // bg_aaaa
      child: InkWell(
        onTap: () {
          // PARITY: reef-b-app checks preview state before navigation
          if (controller.isPreviewing) {
            controller.togglePreview();
            return;
          }
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
        onLongPress: session.isBleConnected && !controller.isBusy && !controller.isPreviewing
            ? () => _confirmDeleteRecord(context, controller, record)
            : null,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md, // dp_16 paddingStart
            top: AppSpacing.md, // dp_12 paddingTop
            right: AppSpacing.md, // dp_16 paddingEnd
            bottom: AppSpacing.md, // dp_12 paddingBottom
          ),
          child: Row(
            children: [
              // Time (tv_time) - body, text_aaaa
              Expanded(
                child: Text(
                  _formatMinutes(record.minutesFromMidnight),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs), // dp_8 marginStart
              // More button (img_next) - 24×24dp
              // PARITY: Using CommonIconHelper.getMoreEnableIcon() for 100% parity
              CommonIconHelper.getMoreEnableIcon(
                size: 24,
                color: AppColors.textTertiary,
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
    // PARITY: reef-b-app format "HH : mm" (with spaces around colon)
    return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')}';
  }

  static Future<void> _confirmDeleteRecord(
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
