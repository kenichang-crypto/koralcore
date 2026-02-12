// PARITY: 100% Android activity_drop_head_record_setting.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_setting.xml
// Mode: Feature Implementation (完整功能實現)
//
// PARITY: DropHeadRecordSettingActivity.kt + DropHeadRecordSettingViewModel.kt

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../domain/doser_dosing/pump_head_record_type.dart';
import '../controllers/pump_head_record_setting_controller.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';
import 'pump_head_record_time_setting_page.dart';

/// PumpHeadRecordSettingPage - PARITY with reef-b-app DropHeadRecordSettingActivity
class PumpHeadRecordSettingPage extends StatelessWidget {
  final String headId;

  const PumpHeadRecordSettingPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider(
      create: (_) => PumpHeadRecordSettingController(
        headId: headId,
        session: session,
        pumpHeadRepository: appContext.pumpHeadRepository,
        applyScheduleUseCase: appContext.applyScheduleUseCase,
      )..initialize(),
      child: const _PumpHeadRecordSettingContent(),
    );
  }
}

class _PumpHeadRecordSettingContent extends StatelessWidget {
  const _PumpHeadRecordSettingContent();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final controller = context.watch<PumpHeadRecordSettingController>();
    final l10n = AppLocalizations.of(context);
    final isReady = session.isReady;
    final isSaving = controller.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: Stack(
        children: [
          Column(
            children: [
              _ToolbarTwoAction(
                l10n: l10n,
                onBack: isSaving ? null : () => Navigator.of(context).pop(),
                onSave: isSaving || !isReady
                    ? null
                    : () => _onSave(context, controller, l10n),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _DropTypeInfoCard(
                          l10n: l10n,
                          dropTypeName: controller.pumpHead?.additiveName ??
                              l10n.dosingTypeNamePlaceholder,
                        ),
                        _RecordTypeSection(
                          l10n: l10n,
                          controller: controller,
                          isSaving: isSaving,
                        ),
                        _VolumeSection(
                          l10n: l10n,
                          controller: controller,
                          isSaving: isSaving,
                          isReady: isReady,
                        ),
                        _RunTimeSection(
                          l10n: l10n,
                          controller: controller,
                          isSaving: isSaving,
                          isReady: isReady,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _ProgressOverlay(visible: controller.isLoading),
        ],
      ),
    );
  }

  Future<void> _onSave(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) async {
    final success = await controller.saveSchedule(
      onDropVolumeEmpty: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorVolumeEmpty,
      ),
      onRunTimeEmpty: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorTimeEmpty,
      ),
      onDropVolumeTooLittle: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorVolumeTooLittleNew,
      ),
      onDropOutOfTodayBound: () => _showDropOutOfRangeDialog(context, l10n),
      onDropVolumeTooMuch: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorVolumeTooMuch,
      ),
      onDetailsEmpty: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorDetailsEmpty,
      ),
    );
    if (!context.mounted) return;
    if (success) {
      showSuccessSnackBar(context, l10n.dosingScheduleEditSuccess);
      Navigator.of(context).pop();
    } else if (controller.lastErrorCode != null) {
      showErrorSnackBar(context, controller.lastErrorCode);
      controller.clearError();
    }
  }

  void _showDropOutOfRangeDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dosingTodayDropOutOfRangeTitle),
        content: Text(l10n.dosingTodayDropOutOfRangeContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.deviceDeleteLedMasterPositive),
          ),
        ],
      ),
    );
  }
}

class _ToolbarTwoAction extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback? onBack;
  final VoidCallback? onSave;

  const _ToolbarTwoAction({
    required this.l10n,
    this.onBack,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 40, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: CommonIconHelper.getCloseIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              l10n.pumpHeadRecordTitle,
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: Text(
              l10n.actionSave,
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_drop_type_info (Line 29-75)
/// CardView margin 16/12/16/0, padding 12dp
/// Shows current DropType
class _DropTypeInfoCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String dropTypeName;

  const _DropTypeInfoCard({required this.l10n, required this.dropTypeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 12, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(
            l10n.dosingType,
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dropTypeName,
              style: AppTextStyles.bodyAccent.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: tv_record_type_title + btn_record_type (Line 77-103)
class _RecordTypeSection extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RecordTypeSection({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  String _recordTypeLabel(PumpHeadRecordType type) {
    switch (type) {
      case PumpHeadRecordType.none:
        return l10n.dropRecordTypeNone;
      case PumpHeadRecordType.h24:
        return l10n.dosingScheduleType24h;
      case PumpHeadRecordType.single:
        return l10n.dosingScheduleTypeSingle;
      case PumpHeadRecordType.custom:
        return l10n.dosingScheduleTypeCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dosingScheduleType,
            style: AppTextStyles.caption1.copyWith(color: AppColors.textDisabled),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          PopupMenuButton<PumpHeadRecordType>(
            enabled: !isSaving,
            onSelected: controller.setSelectedRecordType,
            offset: Offset.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _recordTypeLabel(controller.selectedRecordType),
                    textAlign: TextAlign.start,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  ),
                  LedRecordIconHelper.getDownIcon(width: 20, height: 20),
                ],
              ),
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: PumpHeadRecordType.none,
                child: Text(l10n.dropRecordTypeNone),
              ),
              PopupMenuItem(
                value: PumpHeadRecordType.h24,
                child: Text(l10n.dosingScheduleType24h),
              ),
              PopupMenuItem(
                value: PumpHeadRecordType.single,
                child: Text(l10n.dosingScheduleTypeSingle),
              ),
              PopupMenuItem(
                value: PumpHeadRecordType.custom,
                child: Text(l10n.dosingScheduleTypeCustom),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_volume (Line 105-237)
/// Conditionally visible: NONE=hidden, CUSTOM=record time, 24HR/SINGLE=drop info
class _VolumeSection extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;
  final bool isReady;

  const _VolumeSection({
    required this.l10n,
    required this.controller,
    required this.isSaving,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    final type = controller.selectedRecordType;
    if (type == PumpHeadRecordType.none) return const SizedBox.shrink();
    return Column(
      children: [
        if (type == PumpHeadRecordType.custom)
          _RecordTimeSection(
            l10n: l10n,
            controller: controller,
            headId: controller.headId,
            isSaving: isSaving,
            isReady: isReady,
          ),
        if (type == PumpHeadRecordType.h24 || type == PumpHeadRecordType.single)
          _DropInfoSection(
            l10n: l10n,
            controller: controller,
            isSaving: isSaving,
          ),
      ],
    );
  }
}

/// PARITY: layout_record_time (Line 115-165)
/// For CUSTOM mode (RecyclerView of time slots)
class _RecordTimeSection extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final String headId;
  final bool isSaving;
  final bool isReady;

  const _RecordTimeSection({
    required this.l10n,
    required this.controller,
    required this.headId,
    required this.isSaving,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.dosingSchedulePeriod,
                    style: AppTextStyles.bodyAccent.copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: CommonIconHelper.getAddIcon(size: 24, color: AppColors.textPrimary),
                  onPressed: (isSaving || !isReady)
                      ? null
                      : () => _navigateToTimeSetting(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (controller.recordDetails.isEmpty)
            Container(
              color: AppColors.textDisabled,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.dosingScheduleEditNoTimeSlots,
                  style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            Container(
              color: AppColors.textDisabled,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                children: controller.recordDetails
                    .map((d) => _RecordDetailItem(
                          detail: d,
                          l10n: l10n,
                          controller: controller,
                          isSaving: isSaving,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToTimeSetting(BuildContext context) async {
    final detail = await Navigator.of(context).push<PumpHeadRecordDetail>(
      MaterialPageRoute(
        builder: (ctx) => PumpHeadRecordTimeSettingPage(
          headId: headId,
          existingDetails: controller.recordDetails,
        ),
      ),
    );
    if (detail != null) {
      controller.addRecordDetail(detail);
    }
  }
}

/// PARITY: adapter_drop_custom_record_detail.xml
/// RecyclerView item for time slots
class _RecordDetailItem extends StatelessWidget {
  final PumpHeadRecordDetail detail;
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RecordDetailItem({
    required this.detail,
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  String _speedLabel(int speed) {
    switch (speed) {
      case 1:
        return l10n.pumpHeadSpeedLow;
      case 3:
        return l10n.pumpHeadSpeedHigh;
      default:
        return l10n.pumpHeadSpeedMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = detail.timeString ?? l10n.dosingRecordTimePlaceholder;
    final volumeAndTimes = '${detail.totalDrop} ml / ${detail.dropTime} times';
    return InkWell(
      onTap: null,
      onLongPress: isSaving
          ? null
          : () => _showDeleteDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.surface,
        child: Row(
          children: [
            CommonIconHelper.getDropIcon(size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(width: 8),
            Text(
              volumeAndTimes,
              style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            Text(
              _speedLabel(detail.rotatingSpeed),
              style: AppTextStyles.caption1Accent.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dosingScheduleEditTimeSlotTitle),
        content: Text(l10n.dosingScheduleDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              controller.deleteRecordDetail(detail);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

/// TextField for drop volume, keeps local state in sync with controller.
class _VolumeTextField extends StatefulWidget {
  final PumpHeadRecordSettingController controller;
  final bool enabled;
  final String hintText;

  const _VolumeTextField({
    required this.controller,
    required this.enabled,
    required this.hintText,
  });

  @override
  State<_VolumeTextField> createState() => _VolumeTextFieldState();
}

class _VolumeTextFieldState extends State<_VolumeTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.dropVolume?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(_VolumeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _textController.text = widget.controller.dropVolume?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      controller: _textController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final n = int.tryParse(v);
        widget.controller.setDropVolume(n);
      },
    );
  }
}

/// PARITY: layout_drop_info (Line 167-236)
/// For 24HR / SINGLE mode (Volume + Rotating Speed)
class _DropInfoSection extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _DropInfoSection({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  String _speedLabel(int speed) {
    switch (speed) {
      case 1:
        return l10n.pumpHeadSpeedLow;
      case 3:
        return l10n.pumpHeadSpeedHigh;
      default:
        return l10n.pumpHeadSpeedMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dosingVolume,
            style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _VolumeTextField(
            controller: controller,
            enabled: !isSaving,
            hintText: l10n.dosingVolumeRangeHint,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.pumpHeadSpeed,
            style: AppTextStyles.caption1.copyWith(color: AppColors.textDisabled),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          PopupMenuButton<int>(
            enabled: !isSaving,
            onSelected: controller.setRotatingSpeed,
            offset: Offset.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _speedLabel(controller.rotatingSpeed),
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  ),
                  LedRecordIconHelper.getDownIcon(width: 20, height: 20),
                ],
              ),
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 1, child: Text(l10n.pumpHeadSpeedLow)),
              PopupMenuItem(value: 2, child: Text(l10n.pumpHeadSpeedMedium)),
              PopupMenuItem(value: 3, child: Text(l10n.pumpHeadSpeedHigh)),
            ],
          ),
        ],
      ),
    );
  }
}

/// PARITY: tv_run_time_title + layout_time (Line 239-494)
/// Run Time selection - visibility varies by record type.
/// SINGLE: Now + TimePoint | CUSTOM/24HR: Weekly + TimeRange
class _RunTimeSection extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;
  final bool isReady;

  const _RunTimeSection({
    required this.l10n,
    required this.controller,
    required this.isSaving,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    final type = controller.selectedRecordType;
    if (type == PumpHeadRecordType.none) return const SizedBox.shrink();

    final showNow = type == PumpHeadRecordType.single;
    final showWeekly = type == PumpHeadRecordType.h24 || type == PumpHeadRecordType.custom;
    final showTimeRange = showWeekly;
    final showTimePoint = type == PumpHeadRecordType.single;

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dosingExecutionTime,
            style: AppTextStyles.bodyAccent.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          if (showNow)
            _RunNowOption(
              l10n: l10n,
              controller: controller,
              isSaving: isSaving,
            ),
          if (showNow) const SizedBox(height: 4),
          if (showWeekly)
            _RunWeeklyOption(
              l10n: l10n,
              controller: controller,
              isSaving: isSaving,
            ),
          if (showWeekly) const SizedBox(height: 4),
          if (showTimeRange)
            _RunTimeRangeOption(
              l10n: l10n,
              controller: controller,
              isSaving: isSaving,
            ),
          if (showTimeRange) const SizedBox(height: 4),
          if (showTimePoint)
            _RunTimePointOption(
              l10n: l10n,
              controller: controller,
              isSaving: isSaving,
            ),
        ],
      ),
    );
  }
}

/// PARITY: layout_now (Line 265-293)
/// RadioButton: Run Immediately (selectRunTime=0)
class _RunNowOption extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RunNowOption({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSaving ? null : () => controller.setSelectRunTime(0),
      child: Row(
        children: [
          Radio<int>(
            value: 0,
            groupValue: controller.selectRunTime,
            onChanged: isSaving ? null : (_) => controller.setSelectRunTime(0),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              l10n.dosingExecuteNow,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_drop_days_a_week (Line 295-391)
/// RadioButton: Fixed days a week (selectRunTime=1) with weekday checkboxes
class _RunWeeklyOption extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RunWeeklyOption({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSaving ? null : () => controller.setSelectRunTime(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Radio<int>(
                value: 1,
                groupValue: controller.selectRunTime,
                onChanged: isSaving ? null : (_) => controller.setSelectRunTime(1),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.dosingWeeklyDays,
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) => _WeekdayCheckbox(
                label: _weekLabel(i),
                value: controller.weekDays[i],
                onChanged: isSaving ? null : (v) => controller.setWeekDay(i, v ?? false),
              )),
            ),
          ),
        ],
      ),
    );
  }

  String _weekLabel(int i) => ['S', 'M', 'T', 'W', 'T', 'F', 'S'][i];
}

class _WeekdayCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const _WeekdayCheckbox({
    required this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// PARITY: layout_time_range (Line 393-442)
/// RadioButton: Time Range (selectRunTime=2) with date range picker
class _RunTimeRangeOption extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RunTimeRangeOption({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  String _formatDateRange() {
    final r = controller.dateRange;
    if (r == null) return l10n.dosingRecordTimeRangePlaceholder;
    return '${r.start.year}-${r.start.month.toString().padLeft(2, '0')}-${r.start.day.toString().padLeft(2, '0')} ~ '
        '${r.end.year}-${r.end.month.toString().padLeft(2, '0')}-${r.end.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final initial = controller.dateRange ?? DateTimeRange(
      start: now,
      end: now.add(const Duration(days: 14)),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initial,
    );
    if (picked != null) controller.setDateRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSaving ? null : () async {
        controller.setSelectRunTime(2);
        await _showDateRangePicker(context);
      },
      child: Row(
        children: [
          Radio<int>(
            value: 2,
            groupValue: controller.selectRunTime,
            onChanged: isSaving ? null : (_) {
              controller.setSelectRunTime(2);
              _showDateRangePicker(context);
            },
          ),
          const SizedBox(width: 4),
          CommonIconHelper.getCalendarIcon(size: 24, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _formatDateRange(),
              style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
            ),
          ),
          CommonIconHelper.getNextIcon(size: 24, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

/// PARITY: layout_time_point (Line 444-493)
/// RadioButton: Time Point (selectRunTime=3) with date+time picker
class _RunTimePointOption extends StatelessWidget {
  final AppLocalizations l10n;
  final PumpHeadRecordSettingController controller;
  final bool isSaving;

  const _RunTimePointOption({
    required this.l10n,
    required this.controller,
    required this.isSaving,
  });

  String _formatTimeString() {
    return controller.timeString ?? l10n.dosingRecordTimePointPlaceholder;
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (pickedDate == null || !context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (pickedTime == null) return;
    final dt = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day,
      pickedTime.hour, pickedTime.minute,
    );
    controller.setTimeString(
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSaving ? null : () async {
        controller.setSelectRunTime(3);
        await _showDateTimePicker(context);
      },
      child: Row(
        children: [
          Radio<int>(
            value: 3,
            groupValue: controller.selectRunTime,
            onChanged: isSaving ? null : (_) {
              controller.setSelectRunTime(3);
              _showDateTimePicker(context);
            },
          ),
          const SizedBox(width: 4),
          CommonIconHelper.getCalendarIcon(size: 24, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _formatTimeString(),
              style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
            ),
          ),
          CommonIconHelper.getNextIcon(size: 24, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

/// PARITY: progress.xml (include layout)
/// Full-screen overlay with CircularProgressIndicator
class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3), // Semi-transparent overlay
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
