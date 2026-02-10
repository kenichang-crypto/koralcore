import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// LedRecordSettingPage
///
/// Parity with reef-b-app LedRecordSettingActivity (activity_led_record_setting.xml)
/// Correction Mode: UI structure only, no behavior
class LedRecordSettingPage extends StatelessWidget {
  const LedRecordSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedRecordSettingView();
  }
}

class _LedRecordSettingView extends StatelessWidget {
  const _LedRecordSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

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
                    // C1. Init Strength Section
                    _InitStrengthSection(l10n: l10n),
                    const SizedBox(
                      height: 16,
                    ), // marginTop before sunrise/sunset
                    // C2. Sunrise/Sunset Section
                    _SunriseSunsetSection(l10n: l10n),
                    const SizedBox(height: 16), // marginTop before slow start
                    // C3. Slow Start & Moon Light Section
                    _SlowStartMoonLightSection(l10n: l10n),
                  ],
                ),
              ),
            ),
          ],
        ),

        // D. Progress overlay ↔ progress.xml
        // Note: In Correction Mode, no controller to trigger loading
        // Placeholder for structure only
        // if (isLoading) const _ProgressOverlay(),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({required this.l10n});

  final AppLocalizations l10n;

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
              // Left: Cancel / Back (text button, no behavior)
              TextButton(
                onPressed: null, // No behavior in Correction Mode
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              // Center: Title (@string/record_setting or similar)
              // TODO(android @string/record_setting → "Record Setting" / "記錄設定")
              Text(
                l10n.ledRecordSettingTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Save (text button, no behavior)
              TextButton(
                onPressed: null, // No behavior in Correction Mode
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
        // Divider (2dp ↔ toolbar_two_action.xml MaterialDivider)
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C1. Init Strength Section ↔ img_sun + tv_sun_title + db_strength + tv_strength + sl_strength
// ────────────────────────────────────────────────────────────────────────────

class _InitStrengthSection extends StatelessWidget {
  const _InitStrengthSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: img_sun + tv_sun_title
        Row(
          children: [
            // img_sun (20x20dp)
            // TODO(android @drawable/ic_sun)
            SvgPicture.asset('assets/icons/ic_sun.svg', width: 20, height: 20),
            const SizedBox(width: 4), // marginStart: dp_4
            // tv_sun_title (@string/init_strength)
            // TODO(android @string/init_strength → "Initial Intensity" / "初始強度")
            // Using closest available: ledRecordSettingTitle or placeholder
            Expanded(
              child: Text(
                'Initial Intensity', // TODO(android @string/init_strength)
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary, // text_aaaa
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // db_strength (CustomDashBoard, 123dp height) + tv_strength (centered)
        SizedBox(
          height: 123, // dp_123
          child: Stack(
            children: [
              // Dashboard placeholder (CustomDashBoard is a custom view)
              // TODO(android CustomDashBoard implementation)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors
                          .surfacePressed, // dashboard_progress as placeholder
                      width: 8,
                    ),
                  ),
                ),
              ),
              // tv_strength (centered, "50 %", headline, text_aaa)
              Center(
                child: Text(
                  '50 %',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textSecondary, // text_aaa
                  ),
                ),
              ),
            ],
          ),
        ),
        // sl_strength (Slider, 0-100, value=50)
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.surfacePressed, // dashboard_progress
            inactiveTrackColor: AppColors.textTertiary, // text_aa
            thumbColor: AppColors.surfacePressed,
            trackHeight: 2, // dp_2
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: 50,
            min: 0,
            max: 100,
            onChanged: null, // No behavior in Correction Mode
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C2. Sunrise/Sunset Section ↔ layout_sunrise_sunset
// ────────────────────────────────────────────────────────────────────────────

class _SunriseSunsetSection extends StatelessWidget {
  const _SunriseSunsetSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // background_white_radius
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12), // dp_12
      child: Column(
        children: [
          // Sunrise row
          Row(
            children: [
              // img_sunrise (20x20dp)
              // TODO(android @drawable/ic_sunrise)
              SvgPicture.asset(
                'assets/icons/ic_sunrise.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4), // marginStart: dp_4
              // tv_sunrise_title (@string/sunrise)
              // TODO(android @string/sunrise → "Sunrise" / "日出")
              Expanded(
                child: Text(
                  'Sunrise', // TODO(android @string/sunrise)
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // marginStart before button
              // btn_sunrise (MaterialButton, "06 : 00", icon ic_down)
              MaterialButton(
                onPressed: null, // No behavior in Correction Mode
                color: AppColors.surfaceMuted, // BackgroundMaterialButton
                textColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '06 : 00',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // ic_down
                    // TODO(android @drawable/ic_down)
                    const CommonIconHelper.getDownIcon(), size: 24),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // marginTop: dp_8
          // Sunset row
          Row(
            children: [
              // img_sunset (20x20dp)
              // TODO(android @drawable/ic_sunset)
              SvgPicture.asset(
                'assets/icons/ic_sunset.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4), // marginStart: dp_4
              // tv_sunset_title (@string/sunset)
              // TODO(android @string/sunset → "Sunset" / "日落")
              Expanded(
                child: Text(
                  'Sunset', // TODO(android @string/sunset)
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // marginStart before button
              // btn_sunset (MaterialButton, "18 : 00", icon ic_down)
              MaterialButton(
                onPressed: null, // No behavior in Correction Mode
                color: AppColors.surfaceMuted,
                textColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '18 : 00',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CommonIconHelper.getDownIcon(), size: 24),
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

class _SlowStartMoonLightSection extends StatelessWidget {
  const _SlowStartMoonLightSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12), // dp_12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slow Start row (icon + title + value)
          Row(
            children: [
              // img_slow_start (20x20dp)
              // TODO(android @drawable/ic_slow_start)
              CommonIconHelper.getSlowStartIcon(
                size: 20, // dp_20
                color: Colors.grey,
              ), // Placeholder
              const SizedBox(width: 4), // marginStart: dp_4
              // tv_slow_start_title (@string/slow_start)
              // TODO(android @string/slow_start → "Slow Start" / "緩啟動")
              Expanded(
                child: Text(
                  'Slow Start', // TODO(android @string/slow_start)
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // marginStart before value
              // tv_slow_start (@string/init_minute)
              // TODO(android @string/init_minute → "30 min" format)
              Text(
                '30 ${l10n.minute}', // Assuming l10n.minute exists for "min" / "分鐘"
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          // sl_slow_start (Slider, 10-60, stepSize 10, value=30)
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary, // bg_primary
              inactiveTrackColor: AppColors.surfacePressed, // bg_press
              thumbColor: AppColors.primary,
              trackHeight: 2, // dp_2
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: 30,
              min: 10,
              max: 60,
              divisions: 5, // stepSize 10 → 5 divisions (10,20,30,40,50,60)
              onChanged: null, // No behavior in Correction Mode
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
          // Moon Light row (icon + title + value)
          Row(
            children: [
              // img_moon_light (20x20dp)
              // TODO(android @drawable/ic_moon_round)
              const Icon(
                CommonIconHelper.getMoonRoundIcon(),
                size: 20,
                color: Colors.grey,
              ), // Placeholder
              const SizedBox(width: 6), // marginStart: dp_6
              // tv_moon_light_title (@string/moon_light)
              Expanded(
                child: Text(
                  l10n.lightMoon,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // marginStart before value
              // tv_moon_light ("0 %")
              Text(
                '0 %',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
              ),
            ],
          ),
          // sl_moon_light (Slider, 0-100, value=0)
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.moonLight, // moon_light_color
              inactiveTrackColor: AppColors.surfacePressed, // bg_press
              thumbColor: AppColors.moonLight,
              trackHeight: 2, // dp_2
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: 0,
              min: 0,
              max: 100,
              onChanged: null, // No behavior in Correction Mode
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
