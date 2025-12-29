import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../widgets/semi_circle_dashboard.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/led_record_setting_controller.dart';
import 'led_record_page.dart';

/// LED record setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordSettingActivity.
class LedRecordSettingPage extends StatelessWidget {
  const LedRecordSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<LedRecordSettingController>(
      create: (_) => LedRecordSettingController(
        session: session,
        ledRecordRepository: appContext.ledRecordRepository,
        startLedRecordUseCase: appContext.startLedRecordUseCase,
      ),
      child: const _LedRecordSettingView(),
    );
  }
}

class _LedRecordSettingView extends StatelessWidget {
  const _LedRecordSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedRecordSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: ReefColors.surfaceMuted, // bg_led_record_setting_background_color
      appBar: ReefAppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.ledRecordSettingTitle,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16, // dp_16
                vertical: 12, // dp_12
              ),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.lg),
                ],
                _buildInitStrengthSection(context, controller, l10n),
                const SizedBox(height: 16), // dp_16
                _buildSunriseSection(context, controller, l10n),
                const SizedBox(height: 16), // dp_16
                _buildSlowStartSection(context, controller, l10n),
              ],
            ),
    );
  }

  Widget _buildInitStrengthSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: activity_led_record_setting.xml structure
    // - ImageView (img_sun) + TextView (tv_sun_title) "Initial Intensity"
    // - CustomDashBoard (db_strength) with TextView (tv_strength) showing percentage
    // - Slider (sl_strength)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with sun icon
        Row(
          children: [
            Icon(
              Icons.wb_sunny,
              size: 20, // dp_20
              color: ReefColors.textPrimary,
            ),
            const SizedBox(width: 4), // dp_4
            Text(
              l10n.ledRecordSettingInitStrength,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary, // text_aaaa
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // dp_8
        // Semi-circle dashboard
        SemiCircleDashboard(
          percentage: controller.initStrength,
        ),
        const SizedBox(height: 8), // dp_8
        // Slider
        Slider(
          value: controller.initStrength.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '${controller.initStrength}%',
          activeColor: ReefColors.dashboardProgress, // dashboard_progress
          inactiveColor: ReefColors.textTertiary, // text_aa
          onChanged: (value) {
            controller.setInitStrength(value.toInt());
          },
        ),
      ],
    );
  }

  Widget _buildSunriseSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: layout_sunrise_sunset - white rounded background container
    return Container(
      margin: const EdgeInsets.only(top: 16), // dp_16
      padding: const EdgeInsets.all(12), // dp_12
      decoration: BoxDecoration(
        color: ReefColors.surface, // white
        borderRadius: BorderRadius.circular(10.0), // dp_10 (background_white_radius)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sunrise row
          Row(
            children: [
              Icon(
                Icons.wb_twilight, // ic_sunrise
                size: 20, // dp_20
                color: ReefColors.textPrimary,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSunrise,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              // Time button with dropdown icon
              FilledButton.icon(
                onPressed: () => _selectTime(
                  context,
                  controller.sunriseHour,
                  controller.sunriseMinute,
                  (hour, minute) => controller.setSunrise(hour, minute),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                label: Text(
                  '${controller.sunriseHour.toString().padLeft(2, '0')} : ${controller.sunriseMinute.toString().padLeft(2, '0')}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: ReefColors.surfaceMuted, // bg_aaa
                  foregroundColor: ReefColors.textPrimary, // text_aaaa
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // dp_4
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // dp_8
          // Sunset row
          Row(
            children: [
              Icon(
                Icons.wb_twilight, // ic_sunset (using same icon for now)
                size: 20, // dp_20
                color: ReefColors.textPrimary,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSunset,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              // Time button with dropdown icon
              FilledButton.icon(
                onPressed: () => _selectTime(
                  context,
                  controller.sunsetHour,
                  controller.sunsetMinute,
                  (hour, minute) => controller.setSunset(hour, minute),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                label: Text(
                  '${controller.sunsetHour.toString().padLeft(2, '0')} : ${controller.sunsetMinute.toString().padLeft(2, '0')}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: ReefColors.surfaceMuted, // bg_aaa
                  foregroundColor: ReefColors.textPrimary, // text_aaaa
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // dp_4
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSlowStartSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: layout_slow_start_moon_light - white rounded background container
    // Contains both Soft Start and Moonlight sections
    return Container(
      margin: const EdgeInsets.only(top: 16), // dp_16
      padding: const EdgeInsets.all(12), // dp_12
      decoration: BoxDecoration(
        color: ReefColors.surface, // white
        borderRadius: BorderRadius.circular(10.0), // dp_10 (background_white_radius)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft Start section
          Row(
            children: [
              Icon(
                Icons.timer_outlined, // ic_slow_start
                size: 20, // dp_20
                color: ReefColors.textPrimary,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSlowStart,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              Text(
                '${controller.slowStart} ${l10n.minute}',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // dp_8
          // Slider (10-60, step 10)
          Slider(
            value: controller.slowStart.clamp(10, 60).toDouble(),
            min: 10,
            max: 60,
            divisions: 5, // (60-10)/10 = 5 steps
            label: '${controller.slowStart} ${l10n.minute}',
            activeColor: ReefColors.primary, // bg_primary
            inactiveColor: ReefColors.surfacePressed, // bg_press
            onChanged: (value) {
              // Round to nearest 10
              final rounded = ((value / 10).round() * 10).toInt();
              controller.setSlowStart(rounded.clamp(10, 60));
            },
          ),
          // Scale labels (10, 20, 30, 40, 50, 60)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '20',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '30',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '40',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '50',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '60',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // dp_16
          // Moonlight section
          Row(
            children: [
              Icon(
                Icons.nightlight_round, // ic_moon_round
                size: 20, // dp_20
                color: ReefColors.textPrimary,
              ),
              const SizedBox(width: 6), // dp_6
              Expanded(
                child: Text(
                  l10n.ledRecordSettingMoonlight,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              Text(
                '${controller.moonlight} %',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // dp_8
          // Moonlight slider (0-100)
          Slider(
            value: controller.moonlight.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '${controller.moonlight}%',
            activeColor: ReefColors.moonLight, // moon_light_color
            inactiveColor: ReefColors.surfacePressed, // bg_press
            onChanged: (value) {
              controller.setMoonlight(value.toInt());
            },
          ),
          // Scale labels (0, 100)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '100',
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textTertiary, // text_aa
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<void> _selectTime(
    BuildContext context,
    int initialHour,
    int initialMinute,
    void Function(int, int) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      onTimeSelected(picked.hour, picked.minute);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) async {
    final bool success = await controller.saveLedRecord(
      onTimeError: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledRecordSettingErrorSunTime,
            ),
          ),
        );
      },
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ledRecordSettingSuccess),
        ),
      );
      // Navigate to record page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LedRecordPage()),
      );
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
