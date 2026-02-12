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
import 'pump_head_calibration_page.dart';

/// PumpHeadAdjustListPage - PARITY with reef DropHeadAdjustListActivity
///
/// reef: back->finish, right->start DropHeadAdjustActivity (PumpHeadCalibrationPage)
class PumpHeadAdjustListPage extends StatelessWidget {
  final String headId;

  const PumpHeadAdjustListPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              _ToolbarTwoAction(
                l10n: l10n,
                onBack: () => Navigator.of(context).pop(),
                onRight: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PumpHeadCalibrationPage(headId: headId),
                      ),
                    ),
              ),
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

/// PARITY: toolbar_two_action - reef: back->finish, right->start calibration
class _ToolbarTwoAction extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback onRight;

  const _ToolbarTwoAction({
    required this.l10n,
    required this.onBack,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 40, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: CommonIconHelper.getBackIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              l10n.dosingAdjustListTitle,
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRight,
            child: Text(
              l10n.dosingAdjustListStartAdjust,
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
    final l10n = AppLocalizations.of(context);
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
                l10n.rotatingSpeed,
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_speed (caption1, bg_secondary)
              Expanded(
                child: Text(
                  l10n.pumpHeadSpeedMedium,
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
                l10n.dosingAdjustDateTitle,
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_date (caption1)
              Expanded(
                child: Text(
                  l10n.generalNone,
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
                l10n.dosingVolume,
                style: AppTextStyles.caption1Accent.copyWith(
                  color: AppColors.textTertiary, // text_aaa
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_volume (caption1)
              Expanded(
                child: Text(
                  '',
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
