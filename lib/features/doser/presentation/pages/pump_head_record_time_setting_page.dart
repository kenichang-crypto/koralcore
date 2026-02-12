// PARITY: activity_drop_head_record_time_setting.xml
// DropHeadRecordTimeSettingActivity.kt - Feature mode with CTA parity

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../controllers/pump_head_record_time_setting_controller.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';

/// PumpHeadRecordTimeSettingPage - PARITY with DropHeadRecordTimeSettingActivity
/// Add/edit a custom time slot. Returns PumpHeadRecordDetail on save.
class PumpHeadRecordTimeSettingPage extends StatelessWidget {
  final String headId;
  final List<PumpHeadRecordDetail> existingDetails;
  final PumpHeadRecordDetail? initialDetail;

  const PumpHeadRecordTimeSettingPage({
    super.key,
    required this.headId,
    this.existingDetails = const [],
    this.initialDetail,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    return ChangeNotifierProvider(
      create: (_) => PumpHeadRecordTimeSettingController(
        headId: headId,
        session: session,
        existingDetails: existingDetails,
        initialDetail: initialDetail,
      ),
      child: const _PumpHeadRecordTimeSettingContent(),
    );
  }
}

class _PumpHeadRecordTimeSettingContent extends StatelessWidget {
  const _PumpHeadRecordTimeSettingContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<PumpHeadRecordTimeSettingController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: Stack(
        children: [
          Column(
            children: [
              _ToolbarTwoAction(
                l10n: l10n,
                onBack: () => Navigator.of(context).pop(),
                onSave: () => _onSave(context, controller, l10n),
              ),
              // UX A3: reef activity_drop_head_record_time_setting 無 ScrollView → 單頁固定
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16, top: 12, right: 16, bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          l10n.dosingStartTime,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _TimePickerButton(
                          label: _formatTime(controller.startTime),
                          onPressed: () => _showTimePicker(
                            context,
                            controller.startTime ?? const TimeOfDay(hour: 8, minute: 0),
                            (t) => controller.setStartTime(t),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.dosingEndTime,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _TimePickerButton(
                          label: _formatTime(controller.endTime),
                          onPressed: () => _showTimePicker(
                            context,
                            controller.endTime ?? const TimeOfDay(hour: 10, minute: 0),
                            (t) => controller.setEndTime(t),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.dosingFrequency,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _DropTimesPicker(
                          controller: controller,
                          l10n: l10n,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.dosingVolume,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _VolumeTextField(
                          controller: controller,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.pumpHeadSpeed,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textDisabled),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _SpeedPicker(controller: controller, l10n: l10n),
                    ],
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

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '08:00';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    TimeOfDay initial,
    void Function(TimeOfDay) onSelected,
  ) async {
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) onSelected(t);
  }

  void _onSave(
    BuildContext context,
    PumpHeadRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) {
    final detail = controller.save(
      onDropVolumeTooLittle: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorVolumeTooLittleNew,
      ),
      onDropVolumeTooMuch: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorVolumeTooMuch,
      ),
      onTimeExists: () => showErrorSnackBar(
        context,
        null,
        customMessage: l10n.dosingScheduleEditErrorTimeExists,
      ),
    );
    if (detail != null && context.mounted) {
      Navigator.of(context).pop(detail);
    }
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
            icon: CommonIconHelper.getCloseIcon(size: 24, color: AppColors.onPrimary),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              l10n.pumpHeadRecordTimeSettingsTitle,
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

class _TimePickerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _TimePickerButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: onPressed,
        color: AppColors.surfaceMuted,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, textAlign: TextAlign.start, style: AppTextStyles.body),
            LedRecordIconHelper.getDownIcon(width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}

class _DropTimesPicker extends StatelessWidget {
  final PumpHeadRecordTimeSettingController controller;
  final AppLocalizations l10n;

  const _DropTimesPicker({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final range = controller.dropTimesRange;
    return PopupMenuButton<int>(
      onSelected: controller.setDropTimes,
      offset: Offset.zero,
      child: SizedBox(
        width: double.infinity,
        child: MaterialButton(
          onPressed: null,
          color: AppColors.surfaceMuted,
          textColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.dropTimes.toString(),
                textAlign: TextAlign.start,
                style: AppTextStyles.body,
              ),
              LedRecordIconHelper.getDownIcon(width: 20, height: 20),
            ],
          ),
        ),
      ),
      itemBuilder: (ctx) => range.map((v) => PopupMenuItem(
        value: v,
        child: Text('$v'),
      )).toList(),
    );
  }
}

class _VolumeTextField extends StatefulWidget {
  final PumpHeadRecordTimeSettingController controller;

  const _VolumeTextField({required this.controller});

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
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: l10n.dosingVolumeRangeHint,
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

class _SpeedPicker extends StatelessWidget {
  final PumpHeadRecordTimeSettingController controller;
  final AppLocalizations l10n;

  const _SpeedPicker({required this.controller, required this.l10n});

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
    return PopupMenuButton<int>(
      onSelected: controller.setRotatingSpeed,
      offset: Offset.zero,
      child: SizedBox(
        width: double.infinity,
        child: MaterialButton(
          onPressed: null,
          color: AppColors.surfaceMuted,
          textColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _speedLabel(controller.rotatingSpeed),
                textAlign: TextAlign.start,
                style: AppTextStyles.body,
              ),
              LedRecordIconHelper.getDownIcon(width: 20, height: 20),
            ],
          ),
        ),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(value: 1, child: Text(l10n.pumpHeadSpeedLow)),
        PopupMenuItem(value: 2, child: Text(l10n.pumpHeadSpeedMedium)),
        PopupMenuItem(value: 3, child: Text(l10n.pumpHeadSpeedHigh)),
      ],
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
