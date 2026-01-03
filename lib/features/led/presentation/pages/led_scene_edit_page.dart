import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_edit_controller.dart';

/// LedSceneEditPage
///
/// Parity with reef-b-app LedSceneEditActivity (activity_led_scene_edit.xml)
/// Correction Mode: UI structure only, no behavior
class LedSceneEditPage extends StatelessWidget {
  final String sceneId;

  const LedSceneEditPage({super.key, required this.sceneId});

  @override
  Widget build(BuildContext context) {
    return const _LedSceneEditView();
  }
}

class _LedSceneEditView extends StatelessWidget {
  const _LedSceneEditView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneEditController>();

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            const _ToolbarTwoAction(),

            // B. Form content (fixed, non-scrollable)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // B1. Scene name section ↔ tv_time_title + layout_name
                    _SceneNameSection(l10n: l10n, controller: controller),
                    const SizedBox(height: 24),

                    // B2. Scene icon section ↔ tv_scene_icon_title + rv_scene_icon
                    _SceneIconSection(l10n: l10n),
                    const SizedBox(height: 24),

                    // B3. TODO: Android activity_led_scene_edit.xml does NOT have enable switch
                    // enable switch is NOT present in either add or edit XML
                    // This section is a placeholder per user instruction (B3)
                    // _SceneEnableSection(l10n: l10n),
                  ],
                ),
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
  const _ToolbarTwoAction();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              // Left: Cancel (text button, no behavior)
              // TODO(android @string/activity_led_scene_edit_toolbar_left_btn) → uses @string/cancel
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
              // Center: Title (activity_led_scene_edit_title → @string/led_scene_edit)
              Text(
                // TODO(android @string/led_scene_edit → "Edit Scene" / "場景設定")
                l10n.ledSceneEditTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Save (text button, no behavior)
              // TODO(android @string/activity_led_scene_edit_toolbar_right_btn) → uses @string/save
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
            color: AppColors.textSecondary,
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
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4), // marginTop: dp_4
        // Icon grid placeholder (no behavior)
        // TODO(android @layout/adapter_scene_icon → ShapeableImageView 40x40dp, padding 8dp, cornerRadius 24dp)
        // Android uses RecyclerView with adapter_scene_icon.xml (icon size 40dp)
        // This is a structural placeholder only, no icon selection
        SizedBox(
          height: 56, // Approximate height for one row of 40dp icons + margin
          child: Row(
            children: [
              // TODO(android drawables: ic_sun, ic_sunrise, ic_sunset, ic_moon, etc.)
              // repo has: ic_sun.svg, ic_sunrise.svg, ic_sunset.svg, ic_sunny.svg
              // This is a placeholder row, no actual icon selection
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
      child: const Icon(Icons.image, size: 24, color: Colors.grey),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B3. Scene enable section (placeholder, NOT in activity_led_scene_edit.xml)
// ────────────────────────────────────────────────────────────────────────────

// Android activity_led_scene_edit.xml does NOT have enable switch
// enable switch is NOT present in either add or edit XML
// This section would be structured as:
/*
class _SceneEnableSection extends StatelessWidget {
  const _SceneEnableSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title: TODO(android @string/enable → not found in strings.xml)
        // Possible Android key: "enable" or "enabled"
        Text(
          'Enable', // TODO: missing l10n key
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(),
        // Switch (disabled, read-only)
        Switch(
          value: false,
          onChanged: null, // Disabled in Correction Mode
        ),
      ],
    );
  }
}
*/

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
