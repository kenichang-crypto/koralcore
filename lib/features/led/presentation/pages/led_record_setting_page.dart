import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_record_controller.dart';
import '../controllers/led_record_setting_controller.dart';
import 'led_record_page.dart';

/// LedRecordSettingPage - PARITY with reef LedRecordSettingActivity
///
/// reef: Cancel->finish(), Save->viewModel.saveLedRecord(), on success->LedRecordActivity+finish
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

class _LedRecordSettingView extends StatelessWidget {
  const _LedRecordSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedRecordSettingController>();

    return Stack(
      children: [
        Column(
          children: [
            _ToolbarTwoAction(l10n: l10n, controller: controller),

            // B. Main content (fixed, non-scrollable) ↔ layout_led_record_setting
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors
                    .surfaceMuted, // bg_led_record_setting_background_color
                padding: const EdgeInsets.only(
                  left: 16, // dp_16
                  top: 12, // dp_12
                  right: 16, // dp_16
                  bottom: 12, // dp_12
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InitStrengthSection(l10n: l10n, controller: controller),
                    const SizedBox(height: 16),
                    _SunriseSunsetSection(l10n: l10n, controller: controller),
                    const SizedBox(height: 16),
                    _SlowStartMoonLightSection(l10n: l10n, controller: controller),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (controller.isLoading) const _ProgressOverlay(),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

/// PARITY: reef btnBack->finish, btnRight->saveLedRecord, success->LedRecordActivity+finish
class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordSettingController controller;

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
              TextButton(
                onPressed: controller.isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.ledRecordSettingTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () => _onSave(context, controller, l10n),
                child: Text(
                  l10n.actionSave,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

Future<void> _onSave(
  BuildContext context,
  LedRecordSettingController controller,
  AppLocalizations l10n,
) async {
  final success = await controller.saveLedRecord(
    onTimeError: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ledRecordSettingErrorSunTime)),
      );
    },
  );
  if (!context.mounted) return;
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.toastSettingSuccessful)),
    );
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<LedRecordController>(
          create: (_) => LedRecordController(
            session: session,
            observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
            readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
            refreshLedRecordStateUseCase: appContext.refreshLedRecordStateUseCase,
            deleteLedRecordUseCase: appContext.deleteLedRecordUseCase,
            clearLedRecordsUseCase: appContext.clearLedRecordsUseCase,
            startLedPreviewUseCase: appContext.startLedPreviewUseCase,
            stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
          )..initialize(),
          child: const LedRecordPage(),
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.toastSettingFailed)),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C1. Init Strength Section ↔ img_sun + tv_sun_title + db_strength + tv_strength + sl_strength
// ────────────────────────────────────────────────────────────────────────────

/// PARITY: reef slStrength, slSlowStart, slMoonLight onChange->viewModel.set*
class _InitStrengthSection extends StatelessWidget {
  const _InitStrengthSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/icons/ic_sun.svg', width: 20, height: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.ledInitialIntensity,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 123,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfacePressed,
                      width: 8,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${controller.initStrength} %',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.surfacePressed,
            inactiveTrackColor: AppColors.textTertiary,
            thumbColor: AppColors.surfacePressed,
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: controller.initStrength.toDouble(),
            min: 0,
            max: 100,
            onChanged: controller.isLoading ? null : (v) => controller.setInitStrength(v.round()),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C2. Sunrise/Sunset Section ↔ layout_sunrise_sunset
// ────────────────────────────────────────────────────────────────────────────

/// PARITY: reef btnSunrise/btnSunset->MaterialTimePicker
class _SunriseSunsetSection extends StatelessWidget {
  const _SunriseSunsetSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordSettingController controller;

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    int initialHour,
    int initialMinute,
    void Function(int, int) onSelected,
  ) async {
    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (result != null) {
      onSelected(result.hour, result.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_sunrise.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.ledSunrise,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              MaterialButton(
                onPressed: controller.isLoading
                    ? null
                    : () => _showTimePicker(
                          context,
                          controller.sunriseHour,
                          controller.sunriseMinute,
                          controller.setSunrise,
                        ),
                color: AppColors.surfaceMuted,
                textColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(controller.sunriseHour, controller.sunriseMinute),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CommonIconHelper.getDownIcon(size: 24),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_sunset.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.ledSunset,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              MaterialButton(
                onPressed: controller.isLoading
                    ? null
                    : () => _showTimePicker(
                          context,
                          controller.sunsetHour,
                          controller.sunsetMinute,
                          controller.setSunset,
                        ),
                color: AppColors.surfaceMuted,
                textColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(controller.sunsetHour, controller.sunsetMinute),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CommonIconHelper.getDownIcon(size: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C3. Slow Start & Moon Light Section ↔ layout_slow_start_moon_light
// ────────────────────────────────────────────────────────────────────────────

/// PARITY: reef slSlowStart, slMoonLight onChange->viewModel.set*
class _SlowStartMoonLightSection extends StatelessWidget {
  const _SlowStartMoonLightSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedRecordSettingController controller;

  @override
  Widget build(BuildContext context) {
    final slowStart = controller.slowStart.clamp(10, 60);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonIconHelper.getSlowStartIcon(
                size: 20,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.ledSlowStart,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$slowStart ${l10n.minute}',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfacePressed,
              thumbColor: AppColors.primary,
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: slowStart.toDouble(),
              min: 10,
              max: 60,
              divisions: 5,
              onChanged: controller.isLoading
                  ? null
                  : (v) => controller.setSlowStart(v.round()),
            ),
          ),
          // Progress labels (10, 20, 30, 40, 50, 60)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ), // marginStart 9 for first item
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ), // text_aa
                Text(
                  '20',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '30',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '40',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '50',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '60',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // marginTop: dp_16 before moon light
          Row(
            children: [
              CommonIconHelper.getMoonRoundIcon(size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.lightMoon,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${controller.moonlight} %',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.moonLight,
              inactiveTrackColor: AppColors.surfacePressed,
              thumbColor: AppColors.moonLight,
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: controller.moonlight.toDouble(),
              min: 0,
              max: 100,
              onChanged: controller.isLoading
                  ? null
                  : (v) => controller.setMoonlight(v.round()),
            ),
          ),
          // Progress labels (0, 100)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ), // marginStart 14 for first, marginEnd 7 for last
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ), // text_aa
                Text(
                  '100',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// D. Progress overlay ↔ progress.xml (placeholder)
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
