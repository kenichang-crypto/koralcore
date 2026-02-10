// PARITY: 100% Android activity_drop_head_adjust_list.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_adjust_list.xml
// Mode: Correction (路徑 B：完全 Parity 化)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - RecyclerView: rv_adjust (可捲動, padding 16/8/16/8, layout_height="0dp")
// - Progress: include progress (visibility=gone)
//
// 所有業務邏輯已移除，僅保留 UI 結構。

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// PumpHeadAdjustListPage (Parity Mode)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_head_adjust_list.xml
///
/// 此頁面為純 UI Parity 實作，無業務邏輯。
/// - 所有按鈕 onPressed = null
/// - 不實作 BLE、DB、Navigation
/// - RecyclerView 可捲動
class PumpHeadAdjustListPage extends StatelessWidget {
  const PumpHeadAdjustListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: toolbar_drop_head_adjust_list (Line 8-13)
              _ToolbarTwoAction(l10n: l10n),
              // PARITY: rv_adjust (Line 15-29)
              // RecyclerView with layout_height="0dp" (fills remaining space)
              // padding 16/8/16/8 (Line 20-23), clipToPadding=false (Line 19)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 16, // dp_16 paddingStart
                    top: 8, // dp_8 paddingTop
                    right: 16, // dp_16 paddingEnd
                    bottom: 8, // dp_8 paddingBottom
                  ),
                  children: [
                    // PARITY: adapter_adjust.xml (tools:listitem, Line 25)
                    // Placeholder for RecyclerView items
                    _AdjustHistoryItem(),
                    _AdjustHistoryItem(),
                    _AdjustHistoryItem(),
                  ],
                ),
              ),
            ],
          ),
          // PARITY: progress (Line 31-36, visibility="gone")
          _ProgressOverlay(visible: false),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_two_action.xml
/// - Title: activity_drop_head_adjust_list_title
/// - Left: btn_back
/// - Right: btn_right (activity_drop_head_adjust_list_toolbar_right_btn = "開始校準")
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
          // btn_back
          IconButton(
            icon: CommonIconHelper.getBackIcon(size: 24, 
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: null, // Disabled in Parity Mode
          ),
          // toolbar_title
          Expanded(
            child: Text(
              'TODO(android @string/activity_drop_head_adjust_list_title)', // TODO(android @string/activity_drop_head_adjust_list_title)
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // btn_right ("開始校準")
          TextButton(
            onPressed: null, // Disabled in Parity Mode
            child: Text(
              'TODO(android @string/activity_drop_head_adjust_list_toolbar_right_btn)', // TODO(android @string/activity_drop_head_adjust_list_toolbar_right_btn)
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: adapter_adjust.xml
/// RecyclerView item for adjust history
/// - ConstraintLayout: background_white_radius, padding 12dp, margin 4/4 top/bottom
/// - tv_speed_title + tv_speed (caption1_accent + caption1)
/// - tv_date_title + tv_date (caption1_accent + caption1, marginTop 4dp)
/// - tv_volume_title + tv_volume (caption1_accent + caption1, marginTop 4dp)
class _AdjustHistoryItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 4, // dp_4 marginTop
        bottom: 4, // dp_4 marginBottom
      ),
      decoration: BoxDecoration(
        color: AppColors.surface, // white background (background_white_radius)
        borderRadius: BorderRadius.circular(8), // radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // dp_12 padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speed row
          Row(
            children: [
              // tv_speed_title (caption1_accent, text_aaa)
              Text(
                'TODO(android @string/rotating_speed)', // TODO(android @string/rotating_speed)
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_speed (caption1, bg_secondary)
              Expanded(
                child: Text(
                  '中速', // Placeholder
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondary, // bg_secondary
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // Date row
          Row(
            children: [
              // tv_date_title (caption1_accent, text_aaa)
              Text(
                'TODO(android @string/date)', // TODO(android @string/date)
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_date (caption1)
              Expanded(
                child: Text(
                  '2024-01-01 12:00:00', // Placeholder
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // Volume row
          Row(
            children: [
              // tv_volume_title (caption1_accent, text_aaa)
              Text(
                'TODO(android @string/volume)', // TODO(android @string/volume)
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_volume (caption1)
              Expanded(
                child: Text(
                  '10.0 ml', // Placeholder
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
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
