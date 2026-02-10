import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_edit_controller.dart';

/// LedSceneAddPage
///
/// Parity with reef-b-app LedSceneAddActivity (activity_led_scene_add.xml)
/// Correction Mode: UI structure only, no behavior
class LedSceneAddPage extends StatelessWidget {
  const LedSceneAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedSceneAddView();
  }
}

class _LedSceneAddView extends StatelessWidget {
  const _LedSceneAddView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneEditController>();

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B. ScrollView content (scrollable) ↔ layout_led_record_time_setting
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 12,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // B1. Scene name section
                        _SceneNameSection(l10n: l10n, controller: controller),
                        const SizedBox(height: 24),

                        // B2. Scene icon section
                        _SceneIconSection(l10n: l10n),
                        const SizedBox(height: 24),

                        // B3. Spectrum chart section
                        _SpectrumChartSection(l10n: l10n),
                        const SizedBox(height: 24),

                        // B4. Channel sliders (8 visible + 1 gone)
                        _ChannelSlidersSection(l10n: l10n),
                      ],
                    ),
                  ),
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
              // TODO(android @string/activity_led_scene_add_toolbar_left_btn) → uses @string/cancel
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
              // Center: Title (activity_led_scene_add_title → @string/led_scene_add)
              // TODO(android @string/led_scene_add → "Add Scene" / "新增場景")
              Text(
                l10n.ledSceneAddTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Save (text button, no behavior)
              // TODO(android @string/activity_led_scene_add_toolbar_right_btn) → uses @string/save
              TextButton(
                onPressed: null, // No behavior in Correction Mode
                child: Text(
                  // TODO(android @string/save → l10n.actionSave is in intl_en.arb but missing in intl_zh_Hant.arb)
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
// B1. Scene name section ↔ tv_time_title + layout_name (TextInputLayout + EditText)
// ────────────────────────────────────────────────────────────────────────────

class _SceneNameSection extends StatelessWidget {
  const _SceneNameSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedSceneEditController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: @string/led_scene_name
        Text(
          l10n.ledSceneNameLabel,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary, // text_aaaa
          ),
        ),
        const SizedBox(height: 4), // marginTop: dp_4
        // TextField (no behavior)
        TextField(
          enabled: false, // Disabled in Correction Mode
          decoration: InputDecoration(
            hintText: l10n.ledSceneNameHint,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.surfaceMuted,
          ),
          controller: TextEditingController(text: controller.name),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2. Scene icon section ↔ tv_scene_icon_title + rv_scene_icon (adapter_scene_icon.xml)
// ────────────────────────────────────────────────────────────────────────────

class _SceneIconSection extends StatelessWidget {
  const _SceneIconSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: @string/led_scene_icon
        Text(
          l10n.ledSceneIcon,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary, // text_aaaa
          ),
        ),
        const SizedBox(height: 4), // marginTop: dp_4
        // Icon grid placeholder (no behavior)
        // TODO(android @layout/adapter_scene_icon → ShapeableImageView 40x40dp, padding 8dp, cornerRadius 24dp)
        // Android uses RecyclerView with adapter_scene_icon.xml (icon size 40dp)
        // This is a structural placeholder only, no icon selection
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ), // paddingStart/End: dp_8
          child: SizedBox(
            height: 56, // Approximate height for one row of 40dp icons + margin
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // TODO(android drawables: ic_sun, ic_sunrise, ic_sunset, ic_moon, etc.)
                // repo has: ic_sun.svg, ic_sunrise.svg, ic_sunset.svg, ic_sunny.svg
                _IconPlaceholder(),
                const SizedBox(width: 16),
                _IconPlaceholder(),
                const SizedBox(width: 16),
                _IconPlaceholder(),
                const SizedBox(width: 16),
                _IconPlaceholder(),
                const SizedBox(width: 16),
                _IconPlaceholder(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(
          20,
        ), // cornerRadius 24dp → 20 for 40dp size
      ),
      child: const Icon(
        // TODO(L3): Icons.image is placeholder for scene icon
        // Android uses rv_scene_icon (RecyclerView) with adapter_scene_icon.xml
        // This should use SceneIconHelper or actual scene icon image
        // VIOLATION: Material Icon not in Android XML
        Icons.image,
        size: 24,
        color: Colors.grey,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B3. Spectrum chart section ↔ chart_spectrum
// ────────────────────────────────────────────────────────────────────────────

class _SpectrumChartSection extends StatelessWidget {
  const _SpectrumChartSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ), // margin: 22dp total (16+6)
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
// B4. Channel sliders section (8 visible + 1 gone)
// ────────────────────────────────────────────────────────────────────────────

class _ChannelSlidersSection extends StatelessWidget {
  const _ChannelSlidersSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Channel order from Android XML (Warm White is visibility="gone")
    final channels = [
      _ChannelInfo('uv', l10n.lightUv, AppColors.ultraviolet, false),
      _ChannelInfo('purple', l10n.lightPurple, AppColors.purple, false),
      _ChannelInfo('blue', l10n.lightBlue, AppColors.blue, false),
      _ChannelInfo(
        'royalBlue',
        l10n.lightRoyalBlue,
        AppColors.royalBlue,
        false,
      ),
      _ChannelInfo('green', l10n.lightGreen, AppColors.green, false),
      _ChannelInfo('red', l10n.lightRed, AppColors.red, false),
      _ChannelInfo(
        'coldWhite',
        l10n.lightColdWhite,
        AppColors.coldWhite,
        false,
      ),
      _ChannelInfo(
        'warmWhite',
        l10n.lightWarmWhite,
        AppColors.warmWhite,
        true,
      ), // visibility="gone"
      _ChannelInfo('moonlight', l10n.lightMoon, AppColors.moonLight, false),
    ];

    return Column(
      children: channels
          .map(
            (channel) => channel.isGone
                ? const SizedBox.shrink() // Warm White: visibility="gone"
                : _ChannelSlider(
                    channelId: channel.id,
                    label: channel.label,
                    trackColor: channel.color,
                    isLast: channel.id == 'moonlight',
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
  final bool isGone;

  _ChannelInfo(this.id, this.label, this.color, this.isGone);
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.channelId,
    required this.label,
    required this.trackColor,
    required this.isLast,
  });

  final String channelId;
  final String label;
  final Color trackColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 40 : 0,
      ), // moonlight marginBottom: 40dp
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // margin: dp_16
            child: SliderTheme(
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
