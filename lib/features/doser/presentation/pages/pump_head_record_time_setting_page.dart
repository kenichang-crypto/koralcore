import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/pump_head_record_time_setting_controller.dart';

/// Pump head record time setting page.
///
/// PARITY: Mirrors reef-b-app's DropHeadRecordTimeSettingActivity.
class PumpHeadRecordTimeSettingPage extends StatelessWidget {
  final String headId;
  final List<PumpHeadRecordDetail> existingDetails;
  final PumpHeadRecordDetail? initialDetail;

  const PumpHeadRecordTimeSettingPage({
    super.key,
    required this.headId,
    required this.existingDetails,
    this.initialDetail,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadRecordTimeSettingController>(
      create: (_) => PumpHeadRecordTimeSettingController(
        headId: headId,
        session: session,
        existingDetails: existingDetails,
        initialDetail: initialDetail,
      ),
      child: _PumpHeadRecordTimeSettingView(),
    );
  }
}

class _PumpHeadRecordTimeSettingView extends StatefulWidget {
  const _PumpHeadRecordTimeSettingView();

  @override
  State<_PumpHeadRecordTimeSettingView> createState() =>
      _PumpHeadRecordTimeSettingViewState();
}

class _PumpHeadRecordTimeSettingViewState
    extends State<_PumpHeadRecordTimeSettingView> {
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
    final controller = context.watch<PumpHeadRecordTimeSettingController>();
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
        title: Text(
          l10n.dosingScheduleEditTimeSlotTitle,
        ),
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
              // PARITY: activity_drop_head_record_time_setting.xml padding 16/12/16/12dp
              padding: EdgeInsets.only(
                left: AppSpacing.md, // dp_16 paddingStart
                top: AppSpacing.sm, // dp_12 paddingTop
                right: AppSpacing.md, // dp_16 paddingEnd
                bottom: AppSpacing.sm, // dp_12 paddingBottom
              ),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildTimeRangeSection(context, controller, l10n),
                const SizedBox(height: AppSpacing.lg),
                _buildDropTimesSection(context, controller, l10n),
                const SizedBox(height: AppSpacing.lg),
                _buildVolumeSection(context, controller, l10n),
                const SizedBox(height: AppSpacing.lg),
                _buildRotatingSpeedSection(context, controller, l10n),
              ],
            ),
    );
  }

  Widget _buildTimeRangeSection(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
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
                    onPressed: () => _selectStartTime(context, controller),
                    child: Text(
                      controller.startTime != null
                          ? '${controller.startTime!.hour.toString().padLeft(2, '0')}:${controller.startTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.dosingScheduleEditSelectStartTime,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.timeRangeSeparator),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectEndTime(context, controller),
                    child: Text(
                      controller.endTime != null
                          ? '${controller.endTime!.hour.toString().padLeft(2, '0')}:${controller.endTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.dosingScheduleEditSelectEndTime,
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

  Widget _buildDropTimesSection(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditDropTimesLabel,
              style: AppTextStyles.title3,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: controller.dropTimes,
              decoration: const InputDecoration(),
              items: controller.dropTimesRange.map((value) {
                return DropdownMenuItem(value: value, child: Text('$value'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setDropTimes(value);
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
    PumpHeadRecordTimeSettingController controller,
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

  Widget _buildRotatingSpeedSection(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
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

  Future<void> _selectStartTime(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      controller.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      controller.setEndTime(picked);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) async {
    final PumpHeadRecordDetail? detail = controller.save(
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
      onDropVolumeTooMuch: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorVolumeTooMuch,
            ),
          ),
        );
      },
      onTimeExists: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorTimeExists,
            ),
          ),
        );
      },
    );

    if (detail != null && context.mounted) {
      Navigator.of(context).pop(detail);
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
    });
  }
}
