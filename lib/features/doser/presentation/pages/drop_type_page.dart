// PARITY: 100% Android activity_drop_type.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_type.xml
// Mode: Correction (路徑 B：完全 Parity 化)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - RecyclerView: rv_drop_type (可捲動)
// - FloatingActionButton: fab_add_drop_type (固定右下)
// - Progress: include progress (visibility=gone)
//
// 所有業務邏輯已移除，僅保留 UI 結構。

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// DropTypePage (Parity Mode)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_type.xml
///
/// 此頁面為純 UI Parity 實作，無業務邏輯。
/// - 所有按鈕 onPressed = null
/// - 不實作 Add/Edit/Delete
/// - 不實作 Controller、State
class DropTypePage extends StatelessWidget {
  const DropTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      // PARITY: Stack for overlay
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: toolbar_two_action (Line 8-13)
              _ToolbarTwoAction(l10n: l10n),
              // PARITY: rv_drop_type (Line 15-23)
              // RecyclerView with layout_height="0dp" (fills remaining space)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Item 0: "No" (無)
                    _DropTypeItem(
                      name:
                          'TODO(android @string/no)', // TODO(android @string/no)
                      isSelected: false,
                      onTap: null,
                      onEditPressed: null, // No edit button for "No" option
                    ),
                    // Item 1-N: Drop types
                    _DropTypeItem(
                      name: 'Type A', // Placeholder
                      isSelected: true,
                      onTap: null,
                      onEditPressed: null,
                    ),
                    _DropTypeItem(
                      name: 'Type B', // Placeholder
                      isSelected: false,
                      onTap: null,
                      onEditPressed: null,
                    ),
                    _DropTypeItem(
                      name: 'Type C', // Placeholder
                      isSelected: false,
                      onTap: null,
                      onEditPressed: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // PARITY: fab_add_drop_type (Line 25-33)
          // FloatingActionButton fixed at bottom-right
          Positioned(
            right: 16, // dp_16 margin
            bottom: 16, // dp_16 margin
            child: FloatingActionButton(
              onPressed: null, // Disabled in Parity Mode
              child: CommonIconHelper.getAddIcon(size: 24, 
                size: 24,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          // PARITY: progress (Line 35-40, visibility="gone")
          _ProgressOverlay(visible: false),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_two_action.xml
/// - Title: activity_drop_type_title
/// - Left: btn_back (ic_close)
/// - Right: btn_right (activity_sink_position_toolbar_right_btn = "完成")
class _ToolbarTwoAction extends StatelessWidget {
  final AppLocalizations l10n;

  const _ToolbarTwoAction({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(
        top: 40,
        bottom: 8,
      ), // Status bar + padding
      child: Row(
        children: [
          // btn_back (ic_close)
          IconButton(
            icon: CommonIconHelper.getCloseIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: null, // Disabled in Parity Mode
          ),
          // toolbar_title
          Expanded(
            child: Text(
              'TODO(android @string/activity_drop_type_title)', // TODO(android @string/activity_drop_type_title)
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // btn_right ("完成")
          TextButton(
            onPressed: null, // Disabled in Parity Mode
            child: Text(
              'TODO(android @string/activity_sink_position_toolbar_right_btn)', // TODO(android @string/activity_sink_position_toolbar_right_btn)
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: adapter_drop_type.xml
/// - ConstraintLayout (padding 16/0/16/0dp)
/// - RadioButton
/// - tv_name (body, text_aaaa)
/// - btn_edit (24x24dp, optional)
/// - Divider (bg_press)
class _DropTypeItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;

  const _DropTypeItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // dp_16 paddingStart/End
            child: Row(
              children: [
                // RadioButton
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: null, // Disabled in Parity Mode
                ),
                const SizedBox(width: 16), // dp_16 marginEnd
                // tv_name (body, text_aaaa)
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary, // text_aaaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // btn_edit (24x24dp, optional)
                if (onEditPressed != null) ...[
                  const SizedBox(width: 16), // dp_16 marginEnd
                  IconButton(
                    icon: CommonIconHelper.getEditIcon(size: 24, 
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: null, // Disabled in Parity Mode
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

/// PARITY: progress.xml (include layout)
/// Full-screen overlay with CircularProgressIndicator
class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3), // Semi-transparent overlay
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
