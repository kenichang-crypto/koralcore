import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/led_record_time_setting_controller.dart';
import '../widgets/led_spectrum_chart.dart';

/// LED record time setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordTimeSettingActivity.
class LedRecordTimeSettingPage extends StatelessWidget {
  final LedRecord? initialRecord;

  const LedRecordTimeSettingPage({super.key, this.initialRecord});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<LedRecordTimeSettingController>(
      create: (_) => LedRecordTimeSettingController(
        session: session,
        ledRecordRepository: appContext.ledRecordRepository,
        initialRecord: initialRecord,
      )..enterDimmingMode(),
      child: _LedRecordTimeSettingView(),
    );
  }
}

class _LedRecordTimeSettingView extends StatefulWidget {
  @override
  State<_LedRecordTimeSettingView> createState() =>
      _LedRecordTimeSettingViewState();
}

class _LedRecordTimeSettingViewState extends State<_LedRecordTimeSettingView> {
  @override
  void dispose() {
    final controller = context.read<LedRecordTimeSettingController>();
    controller.exitDimmingMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedRecordTimeSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await controller.exitDimmingMode();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: ReefColors.surfaceMuted,
        appBar: ReefAppBar(
          backgroundColor: ReefColors.primary,
          foregroundColor: ReefColors.onPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await controller.exitDimmingMode();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            l10n.ledRecordTimeSettingTitle,
            style: ReefTextStyles.title2.copyWith(
              color: ReefColors.onPrimary,
            ),
          ),
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
                // PARITY: activity_led_record_time_setting.xml padding 16/12/16/40dp
                padding: EdgeInsets.only(
                  left: ReefSpacing.md, // dp_16 paddingStart
                  top: ReefSpacing.sm, // dp_12 paddingTop
                  right: ReefSpacing.md, // dp_16 paddingEnd
                  bottom: 40, // dp_40 paddingBottom (not standard spacing)
                ),
                children: [
                  if (!isConnected) ...[
                    const BleGuardBanner(),
                    const SizedBox(height: ReefSpacing.lg),
                  ],
                  _buildTimeSection(context, controller, l10n),
                  const SizedBox(height: 24), // dp_24 marginTop (from chart_spectrum)
                  _buildSpectrumChart(context, controller),
                  const SizedBox(height: 24), // dp_24 marginTop (from tv_uv_light_title)
                  _buildChannelSliders(context, controller, l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    LedRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: activity_led_record_time_setting.xml
    // tv_time_title: caption1, text_aaaa
    // btn_time: BackgroundMaterialButton, marginTop 4dp
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.time, // PARITY: @string/time
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textPrimary, // text_aaaa
          ),
        ),
        const SizedBox(height: ReefSpacing.xxxs), // dp_4 marginTop
        MaterialButton(
          onPressed: controller.isEditMode
              ? null
              : () => _selectTime(context, controller),
          // PARITY: BackgroundMaterialButton style
          color: ReefColors.surfaceMuted, // bg_aaa background
          textColor: ReefColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // dp_4 cornerRadius
          ),
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.timeHour.toString().padLeft(2, '0')} : ${controller.timeMinute.toString().padLeft(2, '0')}',
                textAlign: TextAlign.start,
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpectrumChart(
    BuildContext context,
    LedRecordTimeSettingController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ledRecordTimeSettingSpectrumLabel, style: ReefTextStyles.title3),
            const SizedBox(height: ReefSpacing.sm),
            LedSpectrumChart.fromChannelMap(
              controller.channelLevels,
              height: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSliders(
    BuildContext context,
    LedRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) {
    final channels = [
      _ChannelInfo('uv', 'UV'),
      _ChannelInfo('purple', 'Purple'),
      _ChannelInfo('blue', 'Blue'),
      _ChannelInfo('royalBlue', 'Royal Blue'),
      _ChannelInfo('green', 'Green'),
      _ChannelInfo('red', 'Red'),
      _ChannelInfo('coldWhite', 'Cold White'),
      _ChannelInfo('warmWhite', 'Warm White'),
      _ChannelInfo('moonlight', 'Moonlight'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledRecordTimeSettingChannelsLabel,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.md),
            ...channels.map(
              (channel) => Padding(
                padding: const EdgeInsets.only(bottom: ReefSpacing.md),
                child: _buildChannelSlider(
                  context,
                  controller,
                  channel.id,
                  channel.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSlider(
    BuildContext context,
    LedRecordTimeSettingController controller,
    String channelId,
    String label,
  ) {
    final int value = controller.getChannelLevel(channelId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: ReefTextStyles.body1),
            Text('$value', style: ReefTextStyles.title3),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '$value',
          onChanged: (newValue) {
            controller.setChannelLevel(channelId, newValue.toInt());
          },
        ),
      ],
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    LedRecordTimeSettingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.timeHour,
        minute: controller.timeMinute,
      ),
    );
    if (picked != null) {
      controller.setTime(picked.hour, picked.minute);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    LedRecordTimeSettingController controller,
    AppLocalizations l10n,
  ) async {
    final LedRecord? record = await controller.saveRecord(
      onTimeError: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledRecordTimeSettingErrorTime,
            ),
          ),
        );
      },
      onTimeExists: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledRecordTimeSettingErrorTimeExists,
            ),
          ),
        );
      },
    );

    if (record != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ledRecordTimeSettingSuccess),
        ),
      );
      Navigator.of(context).pop(record);
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

class _ChannelInfo {
  final String id;
  final String label;

  const _ChannelInfo(this.id, this.label);
}
