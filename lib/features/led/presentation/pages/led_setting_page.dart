import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// LedSettingPage
///
/// Parity with reef-b-app LedSettingActivity (activity_led_setting.xml)
/// Correction Mode: UI structure only, no behavior
class LedSettingPage extends StatelessWidget {
  const LedSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedSettingView();
  }
}

class _LedSettingView extends StatelessWidget {
  const _LedSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B. Main content area (fixed, non-scrollable) ↔ layout_led_setting
            Expanded(
              child: Padding(
                // PARITY: layout_led_setting padding 16/12/16/12dp
                padding: const EdgeInsets.only(
                  left: 16, // dp_16 paddingStart
                  top: 12, // dp_12 paddingTop
                  right: 16, // dp_16 paddingEnd
                  bottom: 12, // dp_12 paddingBottom
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // B1. Device Name Section
                    _DeviceNameSection(l10n: l10n),

                    // B2. Sink Position Section
                    const SizedBox(height: 16), // marginTop: dp_16
                    _SinkPositionSection(l10n: l10n),
                  ],
                ),
              ),
            ),
          ],
        ),

        // C. Progress overlay ↔ progress.xml
        // PARITY: visibility="gone" by default, controlled by loading state
        // In Correction Mode, never show (no controller)
        // if (controller.isLoading) const _ProgressOverlay(),
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
              // Center: Title
              // TODO(android @string/led_setting_title): Confirm exact Android string key
              Text(
                l10n.ledSettingTitle,
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
// B1. Device Name Section ↔ tv_device_name_title + layout_name + edt_name
// ────────────────────────────────────────────────────────────────────────────

class _DeviceNameSection extends StatelessWidget {
  const _DeviceNameSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // tv_device_name_title ↔ @string/device_name, caption1
        Text(
          l10n.deviceName,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4), // marginTop: dp_4
        // layout_name (TextInputLayout) + edt_name (TextInputEditText)
        // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius, no border
        TextField(
          // No controller in Correction Mode
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs), // dp_4
              borderSide: BorderSide.none, // boxStrokeWidth 0dp
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, // Standard padding
              vertical: 12,
            ),
          ),
          // PARITY: edt_name - body textAppearance, inputType text
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          enabled: false, // No interaction in Correction Mode
          maxLines: 1,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2. Sink Position Section ↔ tv_device_position_title + btn_position
// ────────────────────────────────────────────────────────────────────────────

class _SinkPositionSection extends StatelessWidget {
  const _SinkPositionSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // tv_device_position_title ↔ @string/sink_position, caption1
        Text(
          l10n.sinkPosition,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4), // marginTop: dp_4
        // btn_position (MaterialButton)
        // PARITY: BackgroundMaterialButton style
        // - bg_aaa background
        // - 4dp cornerRadius
        // - elevation 0dp
        // - body textAppearance
        // - icon at end (ic_next)
        // - textAlignment textStart
        // - maxLines 1, ellipsize end
        MaterialButton(
          onPressed: null, // No behavior in Correction Mode
          color: AppColors.surfaceMuted, // bg_aaa background
          elevation: 0, // elevation 0dp
          disabledColor: AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.xs,
            ), // 4dp cornerRadius
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  // Placeholder text (no data in Correction Mode)
                  l10n.sinkPositionNotSet,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              // icon: ic_next (20dp from Android drawable)
              // TODO(android @drawable/ic_next)
              CommonIconHelper.getNextIcon(
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
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
