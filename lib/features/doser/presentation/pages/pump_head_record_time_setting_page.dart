// PARITY: 100% Android activity_drop_head_record_time_setting.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_time_setting.xml
// Mode: Correction (路徑 B：完全 Parity 化)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - Main Content: ConstraintLayout (固定高度，不可捲動，margin 16/12/16/12)
//   - tv_start_time_title + btn_start_time
//   - tv_end_time_title + btn_end_time (marginTop 16dp)
//   - tv_drop_times_title + btn_drop_times (marginTop 16dp)
//   - tv_drop_volume_title + layout_drop_volume (TextInputLayout, marginTop 16dp)
//   - tv_rotating_speed_title + btn_rotating_speed (marginTop 16dp, enabled=false)
// - Progress: include progress (visibility=gone)
//
// 所有業務邏輯已移除，僅保留 UI 結構。

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';

/// PumpHeadRecordTimeSettingPage (Parity Mode)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_time_setting.xml
///
/// 此頁面為純 UI Parity 實作，無業務邏輯。
/// - 所有按鈕 onPressed = null / enabled = false
/// - 不實作 BLE、DB、Navigation
/// - Main Content 為固定高度，不可捲動
class PumpHeadRecordTimeSettingPage extends StatelessWidget {
  const PumpHeadRecordTimeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: toolbar_drop_head_record_time_setting (Line 8-14)
              _ToolbarTwoAction(l10n: l10n),
              // PARITY: layout_drop_head_record_time_setting (Line 16-170)
              // ConstraintLayout with layout_height="0dp" (fills remaining space)
              // margin 16/12/16/12 (Line 20-23)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16, // dp_16 marginStart
                    top: 12, // dp_12 marginTop
                    right: 16, // dp_16 marginEnd
                    bottom: 12, // dp_12 marginBottom
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PARITY: tv_start_time_title + btn_start_time (Line 29-53)
                      Text(
                        'TODO(android @string/drop_start_time)', // TODO(android @string/drop_start_time)
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 46)
                      _BackgroundMaterialButton(
                        text: '08:00', // Placeholder
                        onPressed: null,
                      ),
                      const SizedBox(height: 16), // dp_16 marginTop (Line 60)
                      // PARITY: tv_end_time_title + btn_end_time (Line 55-80)
                      Text(
                        'TODO(android @string/drop_end_time)', // TODO(android @string/drop_end_time)
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 73)
                      _BackgroundMaterialButton(
                        text: '10:00', // Placeholder
                        onPressed: null,
                      ),
                      const SizedBox(height: 16), // dp_16 marginTop (Line 87)
                      // PARITY: tv_drop_times_title + btn_drop_times (Line 82-107)
                      Text(
                        'TODO(android @string/drop_times)', // TODO(android @string/drop_times)
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 100)
                      _BackgroundMaterialButton(
                        text: '3', // Placeholder
                        onPressed: null,
                      ),
                      const SizedBox(height: 16), // dp_16 marginTop (Line 114)
                      // PARITY: tv_drop_volume_title + layout_drop_volume (Line 109-142)
                      Text(
                        'TODO(android @string/drop_volume)', // TODO(android @string/drop_volume)
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textPrimary, // text_color_selector
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 128)
                      // layout_drop_volume (TextInputLayout, Line 123-142)
                      TextField(
                        enabled: false, // Disabled in Parity Mode
                        decoration: InputDecoration(
                          hintText: '1 ~ 500',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16), // dp_16 marginTop (Line 149)
                      // PARITY: tv_rotating_speed_title + btn_rotating_speed (Line 144-169)
                      // enabled=false (Line 150)
                      Text(
                        'TODO(android @string/drop_head_rotating_speed)', // TODO(android @string/drop_head_rotating_speed)
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textDisabled, // enabled=false
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 163)
                      _BackgroundMaterialButton(
                        text: '中速', // Placeholder
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // PARITY: progress (Line 172-177, visibility="gone")
          _ProgressOverlay(visible: false),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_two_action.xml
/// - Title: activity_drop_head_record_time_setting_title
/// - Left: btn_back (ic_close)
/// - Right: btn_right (activity_drop_head_record_time_setting_toolbar_right_btn = "儲存")
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
              'TODO(android @string/activity_drop_head_record_time_setting_title)', // TODO(android @string/activity_drop_head_record_time_setting_title)
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // btn_right ("儲存")
          TextButton(
            onPressed: null, // Disabled in Parity Mode
            child: Text(
              'TODO(android @string/activity_drop_head_record_time_setting_toolbar_right_btn)', // TODO(android @string/activity_drop_head_record_time_setting_toolbar_right_btn)
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: BackgroundMaterialButton style
/// Common button style for MaterialButton
class _BackgroundMaterialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _BackgroundMaterialButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: onPressed,
        color: AppColors.surfaceMuted, // bg_aaa background
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // dp_4 cornerRadius
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, textAlign: TextAlign.start, style: AppTextStyles.body),
            LedRecordIconHelper.getDownIcon(width: 20, height: 20),
          ],
        ),
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
