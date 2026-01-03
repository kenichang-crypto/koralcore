import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';

/// LedSceneDeletePage
///
/// Parity with reef-b-app LedSceneDeleteActivity (activity_led_scene_delete.xml)
/// Correction Mode: UI structure only, no behavior
class LedSceneDeletePage extends StatelessWidget {
  const LedSceneDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedSceneDeleteView();
  }
}

class _LedSceneDeleteView extends StatelessWidget {
  const _LedSceneDeleteView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneListController>();

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B. Scene list (scrollable) ↔ rv_scene
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ListView(
                  children: [
                    // Scene list items (placeholder)
                    // TODO(android @layout/adapter_scene_select.xml)
                    // Android RecyclerView with scene selection items
                    _SceneSelectTile(sceneName: 'Scene 1', isSelected: false),
                    _SceneSelectTile(sceneName: 'Scene 2', isSelected: false),
                    _SceneSelectTile(sceneName: 'Scene 3', isSelected: false),
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
              // TODO(android toolbar left button → uses @string/cancel or back icon)
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
              // Center: Title (activity_led_scene_delete_title → @string/led_scene_delete)
              Text(
                // TODO(android @string/led_scene_delete → "Delete Scene" / "刪除場景")
                l10n.ledSceneDeleteTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Delete (text button, no behavior)
              // TODO(android toolbar right button → uses @string/delete)
              TextButton(
                onPressed: null, // No behavior in Correction Mode
                child: Text(
                  l10n.actionDelete,
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
// B. Scene list items ↔ adapter_scene_select.xml
// ────────────────────────────────────────────────────────────────────────────

class _SceneSelectTile extends StatelessWidget {
  const _SceneSelectTile({required this.sceneName, required this.isSelected});

  final String sceneName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12), // marginTop: dp_12
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted, // bg_aaa
        borderRadius: BorderRadius.circular(8), // cornerRadius: dp_8
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null, // No behavior in Correction Mode
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8, // dp_8 paddingStart
              top: 6, // dp_6 paddingTop
              right: 12, // dp_12 paddingEnd
              bottom: 6, // dp_6 paddingBottom
            ),
            child: Row(
              children: [
                // Icon (24x24dp) ↔ img_icon
                // TODO(android @drawable/ic_sunrise or scene icon)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8), // marginStart: dp_8
                // Scene name ↔ tv_name
                Expanded(
                  child: Text(
                    sceneName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // marginStart: dp_8
                // Check icon (20x20dp, visibility="gone" by default) ↔ img_check
                // PARITY: Android visibility="gone" 不佔空間；Flutter 用 if 條件控制
                // TODO(android @drawable/ic_check)
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
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
