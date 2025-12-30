import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/semi_circle_dashboard.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/led_record_setting_controller.dart';
import '../helpers/support/led_record_icon_helper.dart';
import '../../../../shared/assets/common_icon_helper.dart';
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
        initLedRecordUseCase: appContext.initLedRecordUseCase,
      ),
      child: const _LedRecordSettingView(),
    );
  }
}

class _LedRecordSettingView extends StatefulWidget {
  const _LedRecordSettingView();

  @override
  State<_LedRecordSettingView> createState() => _LedRecordSettingViewState();
}

class _LedRecordSettingViewState extends State<_LedRecordSettingView> {
  bool _previousBleConnected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // PARITY: reef-b-app disconnectLiveData.observe() → finish()
    // Monitor BLE connection state and close page on disconnect
    final session = context.watch<AppSession>();
    final isBleConnected = session.isBleConnected;
    
    // If BLE was connected but now disconnected, close page
    if (_previousBleConnected && !isBleConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
    
    _previousBleConnected = isBleConnected;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedRecordSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_led_record_setting_background_color
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getCloseIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.ledRecordSettingTitle,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
          ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16, // dp_16
                vertical: 12, // dp_12
              ),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppSpacing.lg),
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
            LedRecordIconHelper.getSunIcon(
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 4), // dp_4
            Text(
              l10n.ledRecordSettingInitStrength,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary, // text_aaaa
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
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0, // dp_2
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8.0, // dp_8 (16dp / 2)
            ),
            thumbColor: const Color(0xFF5599FF), // Strength thumb color from SVG
          ),
          child: Slider(
            value: controller.initStrength.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '${controller.initStrength}%',
            activeColor: AppColors.dashboardProgress, // dashboard_progress
            inactiveColor: AppColors.textTertiary, // text_aa
            onChanged: (value) {
              controller.setInitStrength(value.toInt());
            },
          ),
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
        color: AppColors.surface, // white
        borderRadius: BorderRadius.circular(10.0), // dp_10 (background_white_radius)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sunrise row
          Row(
            children: [
              LedRecordIconHelper.getSunriseIcon(
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSunrise,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
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
                icon: LedRecordIconHelper.getDownIcon(
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  '${controller.sunriseHour.toString().padLeft(2, '0')} : ${controller.sunriseMinute.toString().padLeft(2, '0')}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted, // bg_aaa
                  foregroundColor: AppColors.textPrimary, // text_aaaa
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
              LedRecordIconHelper.getSunsetIcon(
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSunset,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
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
                icon: LedRecordIconHelper.getDownIcon(
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  '${controller.sunsetHour.toString().padLeft(2, '0')} : ${controller.sunsetMinute.toString().padLeft(2, '0')}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted, // bg_aaa
                  foregroundColor: AppColors.textPrimary, // text_aaaa
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
        color: AppColors.surface, // white
        borderRadius: BorderRadius.circular(10.0), // dp_10 (background_white_radius)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft Start section
          Row(
            children: [
              LedRecordIconHelper.getSlowStartIcon(
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4), // dp_4
              Expanded(
                child: Text(
                  l10n.ledRecordSettingSlowStart,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              Text(
                '${controller.slowStart} ${l10n.minute}',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // dp_8
          // Slider (10-60, step 10)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0, // dp_2
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0, // dp_8 (16dp / 2)
              ),
              thumbColor: const Color(0xFF6F916F), // Default thumb color from SVG
            ),
            child: Slider(
              value: controller.slowStart.clamp(10, 60).toDouble(),
              min: 10,
              max: 60,
              divisions: 5, // (60-10)/10 = 5 steps
              label: '${controller.slowStart} ${l10n.minute}',
              activeColor: AppColors.primary, // bg_primary
              inactiveColor: AppColors.surfacePressed, // bg_press
              onChanged: (value) {
                // Round to nearest 10
                final rounded = ((value / 10).round() * 10).toInt();
                controller.setSlowStart(rounded.clamp(10, 60));
              },
            ),
          ),
          // Scale labels (10, 20, 30, 40, 50, 60)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '20',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '30',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '40',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '50',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '60',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // dp_16
          // Moonlight section
          Row(
            children: [
              LedRecordIconHelper.getMoonLightIcon(
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6), // dp_6
              Expanded(
                child: Text(
                  l10n.ledRecordSettingMoonlight,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                ),
              ),
              Text(
                '${controller.moonlight} %',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // dp_8
          // Moonlight slider (0-100)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0, // dp_2
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0, // dp_8 (16dp / 2)
              ),
              thumbColor: const Color(0xFFFF9955), // Moon light thumb color from SVG
            ),
            child: Slider(
              value: controller.moonlight.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '${controller.moonlight}%',
              activeColor: AppColors.moonLight, // moon_light_color
              inactiveColor: AppColors.surfacePressed, // bg_press
              onChanged: (value) {
                controller.setMoonlight(value.toInt());
              },
            ),
          ),
          // Scale labels (0, 100)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
                ),
              ),
              Text(
                '100',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary, // text_aa
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
