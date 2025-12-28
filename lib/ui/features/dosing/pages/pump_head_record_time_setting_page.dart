import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
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
    final appContext = context.read<AppContext>();
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
        title: Text(
          l10n.dosingScheduleEditTimeSlotTitle ?? 'Time Slot Settings',
        ),
        actions: [
          TextButton(
            onPressed: controller.isLoading || !isConnected
                ? null
                : () => _handleSave(context, controller, l10n),
            child: Text(
              l10n.actionSave ?? 'Save',
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
                _buildTimeRangeSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildDropTimesSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildVolumeSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditTimeRangeLabel ?? 'Time Range',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectStartTime(context, controller),
                    child: Text(
                      controller.startTime != null
                          ? '${controller.startTime!.hour.toString().padLeft(2, '0')}:${controller.startTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.dosingScheduleEditSelectStartTime ??
                              'Start Time',
                    ),
                  ),
                ),
                const SizedBox(width: ReefSpacing.sm),
                const Text('~'),
                const SizedBox(width: ReefSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectEndTime(context, controller),
                    child: Text(
                      controller.endTime != null
                          ? '${controller.endTime!.hour.toString().padLeft(2, '0')}:${controller.endTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.dosingScheduleEditSelectEndTime ?? 'End Time',
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditDropTimesLabel ?? 'Drop Times',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            DropdownButtonFormField<int>(
              value: controller.dropTimes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: controller.dropTimesRange.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditDoseLabel ?? 'Total Volume (ml)',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            TextField(
              controller: _dropVolumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.dosingScheduleEditDoseHint ?? 'Enter volume',
                suffixText: 'ml',
                border: const OutlineInputBorder(),
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
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleEditRotatingSpeedLabel ?? 'Pump Speed',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 1,
                  label: Text(l10n.dosingScheduleEditSpeedLow ?? 'Low'),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text(l10n.dosingScheduleEditSpeedMedium ?? 'Medium'),
                ),
                ButtonSegment(
                  value: 3,
                  label: Text(l10n.dosingScheduleEditSpeedHigh ?? 'High'),
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
                  ? (l10n.dosingScheduleEditErrorVolumeTooLittleNew ??
                      'Volume too little (min: 0.4ml per drop)')
                  : (l10n.dosingScheduleEditErrorVolumeTooLittleOld ??
                      'Volume too little (min: 1.0ml per drop)'),
            ),
          ),
        );
      },
      onDropVolumeTooMuch: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorVolumeTooMuch ??
                  'Volume too much (max: 500ml)',
            ),
          ),
        );
      },
      onTimeExists: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingScheduleEditErrorTimeExists ??
                  'Time slot already exists',
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
      final controller = context.read<PumpHeadRecordTimeSettingController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}

