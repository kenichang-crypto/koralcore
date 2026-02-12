import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../controllers/led_scene_edit_controller.dart';
import '../widgets/scene_icon_picker.dart';

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
            _ToolbarTwoAction(l10n: l10n, controller: controller),

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
                        _SceneIconSection(l10n: l10n, controller: controller),
                        const SizedBox(height: 24),

                        // B3. Spectrum chart section
                        _SpectrumChartSection(l10n: l10n),
                        const SizedBox(height: 24),

                        // B4. Channel sliders (8 visible + 1 gone)
                        _ChannelSlidersSection(l10n: l10n, controller: controller),
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
  const _ToolbarTwoAction({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedSceneEditController controller;

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
                onPressed: controller.isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.ledSceneAddTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        final ok = await controller.saveScene();
                        if (ok && context.mounted) {
                          Navigator.of(context).pop(true);
                        } else if (context.mounted && controller.lastErrorCode != null) {
                          showErrorSnackBar(context, controller.lastErrorCode);
                          controller.clearError();
                        }
                      },
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
        TextFormField(
          enabled: !controller.isLoading,
          decoration: InputDecoration(
            hintText: l10n.ledSceneNameHint,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.surfaceMuted,
          ),
          initialValue: controller.name,
          onChanged: controller.setName,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2. Scene icon section ↔ tv_scene_icon_title + rv_scene_icon (adapter_scene_icon.xml)
// ────────────────────────────────────────────────────────────────────────────

class _SceneIconSection extends StatelessWidget {
  const _SceneIconSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedSceneEditController controller;

  @override
  Widget build(BuildContext context) {
    return SceneIconPicker(
      selectedIconId: controller.iconId,
      onIconSelected: controller.isLoading ? (_) {} : controller.setIconId,
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
          // PARITY: reef chart_spectrum; P14: 禁止 stub
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B4. Channel sliders section (8 visible + 1 gone)
// ────────────────────────────────────────────────────────────────────────────

class _ChannelSlidersSection extends StatelessWidget {
  const _ChannelSlidersSection({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final LedSceneEditController controller;

  @override
  Widget build(BuildContext context) {
    final channels = [
      _ChannelInfo('uv', l10n.lightUv, AppColors.ultraviolet, false),
      _ChannelInfo('purple', l10n.lightPurple, AppColors.purple, false),
      _ChannelInfo('blue', l10n.lightBlue, AppColors.blue, false),
      _ChannelInfo('royalBlue', l10n.lightRoyalBlue, AppColors.royalBlue, false),
      _ChannelInfo('green', l10n.lightGreen, AppColors.green, false),
      _ChannelInfo('red', l10n.lightRed, AppColors.red, false),
      _ChannelInfo('coldWhite', l10n.lightColdWhite, AppColors.coldWhite, false),
      _ChannelInfo('warmWhite', l10n.lightWarmWhite, AppColors.warmWhite, true),
      _ChannelInfo('moonLight', l10n.lightMoon, AppColors.moonLight, false),
    ];

    return Column(
      children: channels
          .map(
            (channel) => channel.isGone
                ? const SizedBox.shrink()
                : _ChannelSlider(
                    channelId: channel.id,
                    label: channel.label,
                    trackColor: channel.color,
                    isLast: channel.id == 'moonLight',
                    controller: controller,
                    isLoading: controller.isLoading,
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
    required this.controller,
    required this.isLoading,
  });

  final String channelId;
  final String label;
  final Color trackColor;
  final bool isLast;
  final LedSceneEditController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final value = controller.getChannelLevel(channelId).toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 40 : 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.round().toString(),
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: trackColor,
                inactiveTrackColor: AppColors.surfacePressed,
                thumbColor: trackColor,
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: isLoading
                    ? null
                    : (v) => controller.setChannelLevel(channelId, v.round()),
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
