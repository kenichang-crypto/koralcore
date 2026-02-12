import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../controllers/led_record_controller.dart';
import '../controllers/led_record_time_setting_controller.dart';
import 'led_record_setting_page.dart';
import 'led_record_time_setting_page.dart';

/// LedRecordPage
///
/// Parity with reef-b-app LedRecordActivity (activity_led_record.xml)
/// Correction Mode: UI structure only, no behavior
class LedRecordPage extends StatelessWidget {
  const LedRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedRecordView();
  }
}

class _LedRecordView extends StatelessWidget {
  const _LedRecordView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedRecordController>();
    _maybeShowError(context, controller);
    _maybeShowEvent(context, controller);

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(
              l10n: l10n,
              controller: controller,
            ),

            // B–D. Content area (B+C fixed, D scrollable)
            Expanded(
              child: Container(
                color: AppColors.surfaceMuted, // bg_aaa
                child: Column(
                  children: [
                    // B. Record overview card (fixed, non-scrollable)
                    _RecordOverviewCard(l10n: l10n, controller: controller),

                    // C. Record list header (fixed, non-scrollable)
                    _RecordListHeader(l10n: l10n, controller: controller),

                    // D. Record list (only scrollable region)
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.records.length,
                        itemBuilder: (context, index) {
                          final record = controller.records[index];
                          final timeText = _formatRecordTime(record.minutesFromMidnight);
                          return _RecordTile(
                            timeText: timeText,
                            onTap: () => _openRecordTimeSetting(context, record),
                            onLongPress: () => _showDeleteRecordDialog(context, controller, record),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // E. Progress overlay ↔ progress.xml
        if (controller.isLoading) const _ProgressOverlay(),
      ],
    );
  }
}

String _formatRecordTime(int minutesFromMidnight) {
  final hour = (minutesFromMidnight ~/ 60) % 24;
  final minute = minutesFromMidnight % 60;
  return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')}';
}

Future<void> _openRecordTimeSetting(
  BuildContext context,
  LedRecord? record, {
  int? hour,
  int? minute,
}) async {
  final appContext = context.read<AppContext>();
  final session = context.read<AppSession>();
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<LedRecordTimeSettingController>(
        create: (_) => LedRecordTimeSettingController(
          session: session,
          ledRecordRepository: appContext.ledRecordRepository,
          initialRecord: record,
          initialHour: record?.hour ?? hour,
          initialMinute: record?.minute ?? minute,
        ),
        child: const LedRecordTimeSettingPage(),
      ),
    ),
  );
  if (context.mounted) {
    final recordController = context.read<LedRecordController>();
    await recordController.refresh();
  }
}

Future<void> _openAddTimeSetting(BuildContext context) async {
  final controller = context.read<LedRecordController>();
  final (hour, minute) = controller.selectedHourMinute;
  final appContext = context.read<AppContext>();
  final session = context.read<AppSession>();
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<LedRecordTimeSettingController>(
        create: (_) => LedRecordTimeSettingController(
          session: session,
          ledRecordRepository: appContext.ledRecordRepository,
          initialHour: hour,
          initialMinute: minute,
        ),
        child: const LedRecordTimeSettingPage(),
      ),
    ),
  );
  if (context.mounted) {
    final recordController = context.read<LedRecordController>();
    await recordController.refresh();
  }
}

Future<void> _showDeleteRecordDialog(
  BuildContext context,
  LedRecordController controller,
  LedRecord record,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await ConfirmationDialog.show(
    context: context,
    title: l10n.ledRecordsDeleteConfirmTitle,
    content: l10n.ledRecordsDeleteConfirmMessage,
    confirmText: l10n.actionDelete,
    cancelText: l10n.actionCancel,
  );
  if (confirmed == true && context.mounted) {
    await controller.deleteRecord(record.id);
  }
}

void _maybeShowError(
  BuildContext context,
  LedRecordController controller,
) {
  final code = controller.lastErrorCode;
  if (code == null) return;
  showErrorSnackBar(context, code);
  controller.clearError();
}

void _maybeShowEvent(
  BuildContext context,
  LedRecordController controller,
) {
  final event = controller.consumeEvent();
  if (event == null) return;

  final l10n = AppLocalizations.of(context);
  switch (event.type) {
    case LedRecordEventType.deleteSuccess:
      showSuccessSnackBar(context, l10n.ledRecordsSnackDeleted);
      break;
    case LedRecordEventType.deleteFailure:
      showErrorSnackBar(
        context,
        event.errorCode ?? AppErrorCode.unknownError,
      );
      break;
    case LedRecordEventType.clearSuccess:
      showSuccessSnackBar(context, l10n.ledRecordsSnackCleared);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LedRecordSettingPage(),
            ),
          );
        }
      });
      break;
    case LedRecordEventType.clearFailure:
      showErrorSnackBar(
        context,
        event.errorCode ?? AppErrorCode.unknownError,
      );
      break;
    case LedRecordEventType.missingSelection:
      showErrorSnackBar(
        context,
        null,
        customMessage: l10n.ledRecordsSnackMissingSelection,
      );
      break;
    case LedRecordEventType.previewStarted:
      showSuccessSnackBar(context, l10n.ledRecordsSnackPreviewStarted);
      break;
    case LedRecordEventType.previewStopped:
      showSuccessSnackBar(context, l10n.ledRecordsSnackPreviewStopped);
      break;
    case LedRecordEventType.previewFailed:
      showErrorSnackBar(
        context,
        event.errorCode ?? AppErrorCode.unknownError,
      );
      break;
  }
}

Future<void> _onClearTap(
  BuildContext context,
  LedRecordController controller,
  AppLocalizations l10n,
) async {
  final confirmed = await ConfirmationDialog.show(
    context: context,
    title: l10n.ledRecordsClearConfirmTitle,
    content: l10n.ledRecordsClearConfirmMessage,
    confirmText: l10n.actionConfirm,
    cancelText: l10n.cancel,
  );
  if (confirmed == true && context.mounted) {
    await controller.clearRecords();
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({
    required this.l10n,
    required this.controller,
  });

  final AppLocalizations l10n;
  final LedRecordController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              // Left: Back
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: CommonIconHelper.getBackIcon(size: 24),
              ),
              const Spacer(),
              // Center: Title (activity_led_record_title → @string/led_record)
              Text(
                l10n.ledRecordsTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Clear button (PARITY: reef-b-app btnIcon / iOS resetBarButtonItem)
              IconButton(
                onPressed:
                    controller.canClear ? () => _onClearTap(context, controller, l10n) : null,
                icon: CommonIconHelper.getResetIcon(
                  size: 24,
                  color: controller.canClear
                      ? AppColors.textPrimary
                      : AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                tooltip: l10n.ledRecordsClearConfirmTitle,
              ),
            ],
          ),
        ),
        // Divider (2dp ↔ toolbar_two_action.xml MaterialDivider)
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B. Record overview card (fixed) ↔ layout_chart
// PARITY: reef btnAdd->add at clock time, btnMinus->delete selected, btnPrev/Next->navigate, btnPreview->preview
// ────────────────────────────────────────────────────────────────────────────

class _RecordOverviewCard extends StatelessWidget {
  const _RecordOverviewCard({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        top: 12,
        right: 16,
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            controller.selectedTimeLabel,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 242),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // PARITY: reef line_chart shows LineChart; no "Chart Placeholder" text
                  // P14: 禁止 stub；無數據時顯示空區塊
                  child: const SizedBox.shrink(),
                ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: CommonIconHelper.getAddIcon(size: 24),
                onPressed: controller.canAdd
                    ? () => _openRecordTimeSetting(
                          context,
                          null,
                          hour: controller.selectedHourMinute.$1,
                          minute: controller.selectedHourMinute.$2,
                        )
                    : null,
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: CommonIconHelper.getMinusIcon(size: 24),
                onPressed: controller.canDeleteSelected
                    ? () => _showDeleteRecordDialog(
                          context,
                          controller,
                          controller.selectedRecord!,
                        )
                    : null,
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: CommonIconHelper.getBackIcon(size: 24),
                onPressed: controller.canNavigate
                    ? () => controller.goToPreviousRecord()
                    : null,
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: CommonIconHelper.getNextIcon(size: 24),
                onPressed: controller.canNavigate
                    ? () => controller.goToNextRecord()
                    : null,
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: CommonIconHelper.getPlayIcon(size: 24),
                onPressed: controller.canPreview || controller.isPreviewing
                    ? () => controller.togglePreview()
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onPressed});

  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
        maxWidth: 24,
        maxHeight: 24,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Record list header (fixed) ↔ tv_time_title + btn_add_time
// PARITY: reef btnAddTime->LedRecordTimeSettingActivity (records < 24)
// ────────────────────────────────────────────────────────────────────────────

class _RecordListHeader extends StatelessWidget {
  const _RecordListHeader({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.time,
              style: AppTextStyles.bodyAccent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.canAddTime ? () => _openAddTimeSetting(context) : null,
            icon: CommonIconHelper.getAddBtnIcon(size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// D. Record list items ↔ adapter_led_record.xml
// PARITY: reef tap->edit, longPress->delete
// ────────────────────────────────────────────────────────────────────────────

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.timeText,
    this.onTap,
    this.onLongPress,
  });

  final String timeText;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16, // dp_16 paddingStart
              top: 12, // dp_12 paddingTop
              right: 16, // dp_16 paddingEnd
              bottom: 12, // dp_12 paddingBottom
            ),
            child: Row(
              children: [
                // Time text (tv_time) ↔ body, text_aaaa
                Expanded(
                  child: Text(
                    timeText,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // marginStart: dp_8
                // More icon (img_next → ic_more_enable, 24x24dp)
                // TODO(android @drawable/ic_more_enable)
                CommonIconHelper.getMoreEnableIcon(
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// E. Progress overlay ↔ progress.xml
// ────────────────────────────────────────────────────────────────────────────

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
