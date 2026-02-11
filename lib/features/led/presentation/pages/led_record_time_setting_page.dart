import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_record_time_setting_controller.dart';

/// LedRecordTimeSettingPage
///
/// Parity with reef-b-app LedRecordTimeSettingActivity (activity_led_record_time_setting.xml)
/// Correction Mode: UI structure only, no behavior
class LedRecordTimeSettingPage extends StatelessWidget {
  const LedRecordTimeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedRecordTimeSettingView();
  }
}

class _LedRecordTimeSettingView extends StatelessWidget {
  const _LedRecordTimeSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedRecordTimeSettingController>();

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B. ScrollView content (scrollable) ↔ layout_led_record_time_setting
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 16, // dp_16 paddingStart
                  top: 12, // dp_12 paddingTop
                  right: 16, // dp_16 paddingEnd
                  bottom: 40, // dp_40 paddingBottom
                ),
                children: [
                  // B1. Time selection section
                  _TimeSelectionSection(l10n: l10n),
                  const SizedBox(height: 24), // marginTop before chart
                  // B2. Spectrum chart section
                  _SpectrumChartSection(l10n: l10n),
                  const SizedBox(height: 24), // marginTop before sliders
                  // B3. Channel sliders (9 channels)
                  _ChannelSlidersSection(l10n: l10n),
                ],
              ),
            ),
          ],
        ),

        // C. Progress overlay ↔ progress.xml
        if (controller.isLoading) const _ProgressOverlay(),
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
              // Left: Cancel (text button, no behavior)
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
              // Center: Title (activity_led_record_time_setting_title → @string/record_time)
              // TODO(android @string/record_time → "Scheduled Time Point")
              Text(
                l10n.ledRecordTimeSettingTitle,
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
// B1. Time selection section ↔ tv_time_title + btn_time
// ────────────────────────────────────────────────────────────────────────────

class _TimeSelectionSection extends StatelessWidget {
  const _TimeSelectionSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: @string/time
        Text(
          l10n.time,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary, // text_aaaa
          ),
        ),
        const SizedBox(height: 4), // marginTop: dp_4
        // MaterialButton (BackgroundMaterialButton style)
        MaterialButton(
          onPressed: null, // No behavior in Correction Mode
          color: AppColors.surfaceMuted, // bg_aaa
          textColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '05 : 00', // Placeholder time from XML
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // ic_down icon (24x24dp)
              // TODO(android @drawable/ic_down)
              CommonIconHelper.getDownIcon(size: 24),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2. Spectrum chart section ↔ chart_spectrum
// ────────────────────────────────────────────────────────────────────────────

class _SpectrumChartSection extends StatelessWidget {
  const _SpectrumChartSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ), // marginStart/End: dp_6
      child: AspectRatio(
        aspectRatio: 16 / 9, // Flexible chart (Android: 176dp fixed)
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'Spectrum Chart Placeholder',
              style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B3. Channel sliders section (9 channels)
// ────────────────────────────────────────────────────────────────────────────

class _ChannelSlidersSection extends StatelessWidget {
  const _ChannelSlidersSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Channel order from Android XML
    final channels = [
      _ChannelInfo('uv', l10n.lightUv, AppColors.ultraviolet),
      _ChannelInfo('purple', l10n.lightPurple, AppColors.purple),
      _ChannelInfo('blue', l10n.lightBlue, AppColors.blue),
      _ChannelInfo('royalBlue', l10n.lightRoyalBlue, AppColors.royalBlue),
      _ChannelInfo('green', l10n.lightGreen, AppColors.green),
      _ChannelInfo('red', l10n.lightRed, AppColors.red),
      _ChannelInfo('coldWhite', l10n.lightColdWhite, AppColors.coldWhite),
      _ChannelInfo('warmWhite', l10n.lightWarmWhite, AppColors.warmWhite),
      _ChannelInfo('moonlight', l10n.lightMoon, AppColors.moonLight),
    ];

    return Column(
      children: channels
          .map(
            (channel) => _ChannelSlider(
              channelId: channel.id,
              label: channel.label,
              trackColor: channel.color,
            ),
          )
          .toList(),
    );
  }
}

class _ChannelInfo {
  final String id;
  final String label;
  final Color color;

  _ChannelInfo(this.id, this.label, this.color);
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.channelId,
    required this.label,
    required this.trackColor,
  });

  final String channelId;
  final String label;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 0,
      ), // No bottom padding between sliders
      child: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.only(
              left: 6,
              right: 6,
            ), // marginStart/End: dp_6
            child: Row(
              children: [
                // Channel label (caption1, text_aaaa)
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4), // marginStart: dp_4
                // Value text (caption1, text_aaa)
                Padding(
                  padding: const EdgeInsets.only(right: 6), // marginEnd: dp_6
                  child: Text(
                    '0', // Placeholder value
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: trackColor,
              inactiveTrackColor: AppColors.surfacePressed, // bg_press
              thumbColor: trackColor,
              trackHeight: 2, // dp_2 trackHeight
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: 0, // Placeholder value
              min: 0,
              max: 100,
              onChanged: null, // No behavior in Correction Mode
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Progress overlay ↔ progress.xml
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
