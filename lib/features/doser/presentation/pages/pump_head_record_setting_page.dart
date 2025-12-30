import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../domain/doser_dosing/pump_head_record_type.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/pump_head_record_setting_controller.dart';
import 'pump_head_record_time_setting_page.dart';

/// Pump head record setting page.
///
/// PARITY: Mirrors reef-b-app's DropHeadRecordSettingActivity.
class PumpHeadRecordSettingPage extends StatelessWidget {
  final String headId;

  const PumpHeadRecordSettingPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadRecordSettingController>(
      create: (_) => PumpHeadRecordSettingController(
        headId: headId,
        session: session,
        pumpHeadRepository: appContext.pumpHeadRepository,
        applyScheduleUseCase: appContext.applyScheduleUseCase,
      )..initialize(),
      child: _PumpHeadRecordSettingView(headId: headId),
    );
  }
}

class _PumpHeadRecordSettingView extends StatefulWidget {
  final String headId;

  const _PumpHeadRecordSettingView({required this.headId});

  @override
  State<_PumpHeadRecordSettingView> createState() =>
      _PumpHeadRecordSettingViewState();
}

class _PumpHeadRecordSettingViewState
    extends State<_PumpHeadRecordSettingView> {
  final TextEditingController _dropVolumeController = TextEditingController();

  @override
  void dispose() {
    _dropVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<PumpHeadRecordSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getCloseIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.dosingScheduleEditTitle),
        actions: [
          TextButton(
            onPressed: controller.isLoading || !isConnected
                ? null
                : () => _handleSave(context, controller, l10n),
            child: Text(
              l10n.actionSave,
              style: TextStyle(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              // PARITY: activity_drop_head_record_setting.xml ScrollView + ConstraintLayout
              // No padding - sections handle their own margins (16/12/16 for cards)
              padding: EdgeInsets.zero,
              children: [
                if (!isConnected) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: const BleGuardBanner(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                // PARITY: layout_drop_type_info margin 16/12/16
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md, // dp_16 marginStart
                    top: AppSpacing.sm, // dp_12 marginTop
                    right: AppSpacing.md, // dp_16 marginEnd
                  ),
                  child: _buildRecordTypeSelector(context, controller, l10n),
                ),
                // PARITY: tv_record_type_title marginTop 16dp
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md, // dp_16 marginStart
                    top: AppSpacing.md, // dp_16 marginTop
                    right: AppSpacing.md, // dp_16 marginEnd
                  ),
                  child: _buildRecordTypeButton(context, controller, l10n),
                ),
                if (controller.selectedRecordType != PumpHeadRecordType.none) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _buildVolumeSection(context, controller, l10n),
                  ),
                ],
                if (controller.selectedRecordType == PumpHeadRecordType.h24 ||
                    controller.selectedRecordType == PumpHeadRecordType.custom) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _buildTimeRangeSection(context, controller, l10n),
                  ),
                ],
                if (controller.selectedRecordType == PumpHeadRecordType.single) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _buildTimePointSection(context, controller, l10n),
                  ),
                ],
                if (controller.selectedRecordType ==
                    PumpHeadRecordType.custom) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _buildCustomDetailsSection(
                      context,
                      controller,
                      l10n,
                      isConnected,
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _buildRotatingSpeedSection(context, controller, l10n),
                ),
              ],
            ),
    );
  }

  Widget _buildRecordTypeSelector(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleTypeLabel,
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<PumpHeadRecordType>(
              initialValue: controller.selectedRecordType,
              decoration: const InputDecoration(),
              items: [
                DropdownMenuItem(
                  value: PumpHeadRecordType.none,
                  child: Text(l10n.dosingScheduleTypeNone),
                ),
                DropdownMenuItem(
                  value: PumpHeadRecordType.h24,
                  child: Text(l10n.dosingScheduleType24h),
                ),
                DropdownMenuItem(
                  value: PumpHeadRecordType.single,
                  child: Text(l10n.dosingScheduleTypeSingle),
                ),
                DropdownMenuItem(
                  value: PumpHeadRecordType.custom,
                  child: Text(l10n.dosingScheduleTypeCustom),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setSelectedRecordType(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTypeButton(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: tv_record_type_title caption1, marginTop 16dp
    // PARITY: btn_record_type BackgroundMaterialButton, marginTop 4dp
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dosingScheduleTypeLabel, // PARITY: @string/drop_record_type
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxs), // dp_4 marginTop
        MaterialButton(
          onPressed: () => _showRecordTypeDialog(context, controller, l10n),
          // PARITY: BackgroundMaterialButton style
          color: AppColors.surfaceMuted, // bg_aaa background
          textColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // dp_4 cornerRadius
          ),
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getRecordTypeText(controller.selectedRecordType, l10n),
                textAlign: TextAlign.start,
              ),
              LedRecordIconHelper.getDownIcon(width: 20, height: 20),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecordTypeText(PumpHeadRecordType type, AppLocalizations l10n) {
    switch (type) {
      case PumpHeadRecordType.none:
        return l10n.dosingScheduleTypeNone;
      case PumpHeadRecordType.h24:
        return l10n.dosingScheduleType24h;
      case PumpHeadRecordType.single:
        return l10n.dosingScheduleTypeSingle;
      case PumpHeadRecordType.custom:
        return l10n.dosingScheduleTypeCustom;
    }
  }

  Future<void> _showRecordTypeDialog(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) async {
    // TODO: Implement record type selection dialog
    // For now, use a simple dropdown
    final PumpHeadRecordType? result = await showDialog<PumpHeadRecordType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dosingScheduleTypeLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.dosingScheduleTypeNone),
              onTap: () => Navigator.of(context).pop(PumpHeadRecordType.none),
            ),
            ListTile(
              title: Text(l10n.dosingScheduleType24h),
              onTap: () => Navigator.of(context).pop(PumpHeadRecordType.h24),
            ),
            ListTile(
              title: Text(l10n.dosingScheduleTypeSingle),
              onTap: () => Navigator.of(context).pop(PumpHeadRecordType.single),
            ),
            ListTile(
              title: Text(l10n.dosingScheduleTypeCustom),
              onTap: () => Navigator.of(context).pop(PumpHeadRecordType.custom),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      controller.setSelectedRecordType(result);
    }
  }

  Widget _buildVolumeSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Volume (ml)',
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _dropVolumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.dosingVolumeHint,
                suffixText: 'ml',
              ),
              onChanged: (value) {
                final int? volume = int.tryParse(value);
                controller.setDropVolume(volume);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditTimeRangeLabel,
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDateRange(context, controller),
                    child: Text(
                      controller.dateRange != null
                          ? '${DateFormat('yyyy-MM-dd').format(controller.dateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(controller.dateRange!.end)}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildWeekDaysSelector(context, controller, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePointSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditTimePointLabel,
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDateTime(context, controller),
                    child: Text(
                      controller.timeString ?? 'Select Date & Time',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaysSelector(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    final weekDayLabels = [
      l10n.weekdaySunday,
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(weekDayLabels[index]),
          selected: controller.weekDays[index],
          onSelected: (selected) {
            controller.setWeekDay(index, selected);
          },
        );
      }),
    );
  }

  Widget _buildCustomDetailsSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
    bool isConnected,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dosingScheduleEditCustomDetailsLabel,
                  style: AppTextStyles.title3,
                ),
                FilledButton.icon(
                  onPressed: isConnected
                      ? () => _addTimeSlot(context, controller)
                      : () => showBleGuardDialog(context),
                  icon: CommonIconHelper.getAddIcon(size: 24),
                  label: Text(l10n.actionAdd),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (controller.recordDetails.isEmpty)
              Text(
                l10n.dosingScheduleEditNoTimeSlots,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...controller.recordDetails.map(
                (detail) => _CustomRecordDetailTile(
                  detail: detail,
                  isConnected: isConnected,
                  l10n: l10n,
                  onDelete: isConnected
                      ? () => controller.deleteRecordDetail(detail)
                      : () => showBleGuardDialog(context),
                  onEdit: isConnected
                      ? () => _editTimeSlot(context, controller, detail)
                      : () => showBleGuardDialog(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingSpeedSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditRotatingSpeedLabel,
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 1,
                  label: Text(l10n.dosingScheduleEditSpeedLow),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text(l10n.dosingScheduleEditSpeedMedium),
                ),
                ButtonSegment(
                  value: 3,
                  label: Text(l10n.dosingScheduleEditSpeedHigh),
                ),
              ],
              selected: {controller.rotatingSpeed},
              onSelectionChanged: (Set<int> selection) {
                if (selection.isNotEmpty) {
                  controller.setRotatingSpeed(selection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    PumpHeadRecordSettingController controller,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: controller.dateRange,
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  Future<void> _selectDateTime(
    BuildContext context,
    PumpHeadRecordSettingController controller,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final DateTime selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    controller.setTimeString(DateFormat('yyyy-MM-dd HH:mm').format(selected));
  }

  Future<void> _addTimeSlot(
    BuildContext context,
    PumpHeadRecordSettingController controller,
  ) async {
    final PumpHeadRecordDetail? detail = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PumpHeadRecordTimeSettingPage(
          headId: widget.headId,
          existingDetails: controller.recordDetails,
        ),
      ),
    );
    if (detail != null) {
      controller.addRecordDetail(detail);
    }
  }

  Future<void> _editTimeSlot(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    PumpHeadRecordDetail detail,
  ) async {
    final PumpHeadRecordDetail? updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PumpHeadRecordTimeSettingPage(
          headId: widget.headId,
          existingDetails: controller.recordDetails,
          initialDetail: detail,
        ),
      ),
    );
    if (updated != null) {
      controller.deleteRecordDetail(detail);
      controller.addRecordDetail(updated);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) async {
    final bool success = await controller.saveSchedule(
      onDropVolumeEmpty: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorVolumeEmpty,
            ),
          ),
        );
      },
      onRunTimeEmpty: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorTimeEmpty,
            ),
          ),
        );
      },
      onDropVolumeTooLittle: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.isDecimalDose
                  ? l10n.dosingScheduleEditErrorVolumeTooLittleNew
                  : l10n.dosingScheduleEditErrorVolumeTooLittleOld,
            ),
          ),
        );
      },
      onDropOutOfTodayBound: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorVolumeOutOfRange,
            ),
          ),
        );
      },
      onDropVolumeTooMuch: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorVolumeTooMuch,
            ),
          ),
        );
      },
      onDetailsEmpty: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorDetailsEmpty,
            ),
          ),
        );
      },
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dosingScheduleEditSuccess),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      // Clear error after showing
    });
  }
}

/// Custom record detail tile matching adapter_drop_custom_record_detail.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_drop_custom_record_detail.xml structure:
/// - ConstraintLayout: bg_aaaa background, selectableItemBackground
/// - Inner: padding 16/12/16/12dp
/// - img_drop: 20×20dp (ic_drop)
/// - tv_time: caption1, text_aaa, marginStart 8dp
/// - tv_volume_and_times: caption1, text_aaaa, marginStart 8dp
/// - tv_speed: caption1_accent, bg_secondary, marginStart 12dp
/// - Divider: text_a color
class _CustomRecordDetailTile extends StatelessWidget {
  final PumpHeadRecordDetail detail;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CustomRecordDetailTile({
    required this.detail,
    required this.isConnected,
    required this.l10n,
    required this.onDelete,
    required this.onEdit,
  });

  String _getSpeedText(int speed, AppLocalizations l10n) {
    switch (speed) {
      case 1:
        return l10n.dosingRotatingSpeedLow;
      case 2:
        return l10n.dosingRotatingSpeedMedium;
      case 3:
        return l10n.dosingRotatingSpeedHigh;
      default:
        return l10n.dosingRotatingSpeedMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeText = detail.timeString ?? '';
    final String volumeAndTimesText = '${detail.totalDrop} ml / ${detail.dropTime}次';
    final String speedText = _getSpeedText(detail.rotatingSpeed, l10n);

    // PARITY: adapter_drop_custom_record_detail.xml structure
    return InkWell(
      onTap: onEdit,
      onLongPress: onDelete,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16 paddingStart
              top: AppSpacing.md, // dp_12 paddingTop
              right: AppSpacing.md, // dp_16 paddingEnd
              bottom: AppSpacing.md, // dp_12 paddingBottom
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // bg_aaaa background
            ),
            child: Row(
              children: [
                // Drop icon (img_drop) - 20×20dp
                // PARITY: Using SvgPicture for ic_drop.svg for 100% parity
                SvgPicture.asset(
                  'assets/icons/ic_drop.svg',
                  width: 20, // dp_20
                  height: 20, // dp_20
                  colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
                SizedBox(width: AppSpacing.xs), // dp_8 marginStart
                // Time (tv_time) - caption1, text_aaa
                Text(
                  timeText,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary, // text_aaa
                  ),
                ),
                SizedBox(width: AppSpacing.xs), // dp_8 marginStart
                // Volume and times (tv_volume_and_times) - caption1, text_aaaa
                Text(
                  volumeAndTimesText,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                ),
                SizedBox(width: AppSpacing.md), // dp_12 marginStart
                // Speed (tv_speed) - caption1_accent, bg_secondary
                Expanded(
                  child: Text(
                    speedText,
                    style: AppTextStyles.caption1Accent.copyWith(
                      color: AppColors.textSecondary, // bg_secondary (using textSecondary as fallback)
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          // Divider (text_a color)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.textDisabled, // text_a
          ),
        ],
      ),
    );
  }
}
