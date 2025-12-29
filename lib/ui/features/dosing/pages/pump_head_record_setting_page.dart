import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../domain/doser_dosing/pump_head_record_type.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
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
      backgroundColor: ReefColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(ReefSpacing.lg),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.lg),
                ],
                _buildRecordTypeSelector(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                if (controller.selectedRecordType != PumpHeadRecordType.none)
                  _buildVolumeSection(context, controller, l10n),
                if (controller.selectedRecordType == PumpHeadRecordType.h24 ||
                    controller.selectedRecordType == PumpHeadRecordType.custom)
                  _buildTimeRangeSection(context, controller, l10n),
                if (controller.selectedRecordType == PumpHeadRecordType.single)
                  _buildTimePointSection(context, controller, l10n),
                if (controller.selectedRecordType ==
                    PumpHeadRecordType.custom) ...[
                  const SizedBox(height: ReefSpacing.lg),
                  _buildCustomDetailsSection(
                    context,
                    controller,
                    l10n,
                    isConnected,
                  ),
                ],
                const SizedBox(height: ReefSpacing.lg),
                _buildRotatingSpeedSection(context, controller, l10n),
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleTypeLabel,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
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

  Widget _buildVolumeSection(
    BuildContext context,
    PumpHeadRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Volume (ml)',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            TextField(
              controller: _dropVolumeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter volume',
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditTimeRangeLabel,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
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
            const SizedBox(height: ReefSpacing.sm),
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditTimePointLabel,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
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
      spacing: ReefSpacing.sm,
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dosingScheduleEditCustomDetailsLabel,
                  style: ReefTextStyles.title3,
                ),
                FilledButton.icon(
                  onPressed: isConnected
                      ? () => _addTimeSlot(context, controller)
                      : () => showBleGuardDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.actionAdd),
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.sm),
            if (controller.recordDetails.isEmpty)
              Text(
                l10n.dosingScheduleEditNoTimeSlots,
                style: ReefTextStyles.body2.copyWith(
                  color: ReefColors.textSecondary,
                ),
              )
            else
              ...controller.recordDetails.map(
                (detail) => ListTile(
                  title: Text(detail.timeString ?? ''),
                  subtitle: Text('${detail.dropTime}x • ${detail.totalDrop}ml'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: isConnected
                        ? () {
                            controller.deleteRecordDetail(detail);
                          }
                        : () => showBleGuardDialog(context),
                  ),
                  onLongPress: isConnected
                      ? () {
                          // Edit detail
                          _editTimeSlot(context, controller, detail);
                        }
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditRotatingSpeedLabel,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
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
