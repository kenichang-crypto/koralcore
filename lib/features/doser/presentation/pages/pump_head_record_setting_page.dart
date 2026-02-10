// PARITY: 100% Android activity_drop_head_record_setting.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_setting.xml
// Mode: Correction (路徑 B：完全 Parity 化)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - ScrollView: layout_drop_head_record_setting (可捲動)
//   - CardView: layout_drop_type_info (顯示當前 DropType)
//   - tv_record_type_title + btn_record_type (Record Type 下拉選單)
//   - layout_volume (條件式顯示 LinearLayout)
//     - layout_record_time (CUSTOM 模式顯示 RecyclerView)
//     - layout_drop_info (24HR / SINGLE 模式顯示 Volume + Rotating Speed)
//   - tv_run_time_title + layout_time (Run Time 選擇)
//     - RadioButton: layout_now (立即執行)
//     - RadioButton: layout_drop_days_a_week (一週固定天數)
//     - RadioButton: layout_time_range (時間範圍)
//     - RadioButton: layout_time_point (時間點)
// - Progress: include progress (visibility=gone)
//
// 所有業務邏輯已移除，僅保留 UI 結構。

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';

/// PumpHeadRecordSettingPage (Parity Mode)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_setting.xml
///
/// 此頁面為純 UI Parity 實作，無業務邏輯。
/// - 所有按鈕 onPressed = null / enabled = false
/// - 不實作 BLE、DB、Navigation
/// - ScrollView 可捲動，Toolbar 固定
class PumpHeadRecordSettingPage extends StatelessWidget {
  const PumpHeadRecordSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: toolbar_drop_head_record_setting (Line 8-14)
              _ToolbarTwoAction(l10n: l10n),
              // PARITY: layout_drop_head_record_setting (Line 16-496)
              // ScrollView with layout_height="0dp" (fills remaining space)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // PARITY: layout_drop_type_info (Line 29-75)
                        // CardView margin 16/12/16/0
                        _DropTypeInfoCard(l10n: l10n),
                        // PARITY: tv_record_type_title + btn_record_type (Line 77-103)
                        // marginTop 16dp
                        _RecordTypeSection(l10n: l10n),
                        // PARITY: layout_volume (Line 105-237)
                        // Conditionally visible based on record type
                        // For Parity Mode, show all sections
                        _VolumeSection(l10n: l10n),
                        // PARITY: tv_run_time_title + layout_time (Line 239-494)
                        _RunTimeSection(l10n: l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // PARITY: progress (Line 498-503, visibility="gone")
          _ProgressOverlay(visible: false),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_two_action.xml
/// - Title: activity_drop_head_record_setting_title
/// - Left: btn_back (ic_close)
/// - Right: btn_right (activity_drop_head_record_setting_toolbar_right_btn = "儲存")
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
              'TODO(android @string/activity_drop_head_record_setting_title)', // TODO(android @string/activity_drop_head_record_setting_title)
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
              'TODO(android @string/activity_drop_head_record_setting_toolbar_right_btn)', // TODO(android @string/activity_drop_head_record_setting_toolbar_right_btn)
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_drop_type_info (Line 29-75)
/// CardView margin 16/12/16/0, padding 12dp
/// Shows current DropType
class _DropTypeInfoCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _DropTypeInfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        top: 12,
        right: 16,
      ), // dp_16/12/16
      decoration: BoxDecoration(
        color: AppColors.surface, // CardView background
        borderRadius: BorderRadius.circular(10), // dp_10 cornerRadius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5, // dp_5 elevation
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // dp_12 padding
      child: Row(
        children: [
          // tv_drop_type_title (body, text_aaa)
          Text(
            'TODO(android @string/drop_type)', // TODO(android @string/drop_type)
            style: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary, // text_aaa
            ),
          ),
          const SizedBox(width: 12), // dp_12 marginStart
          // tv_drop_type (body_accent, text_aaaa)
          Expanded(
            child: Text(
              'Type A', // Placeholder
              style: AppTextStyles.bodyAccent.copyWith(
                color: AppColors.textPrimary, // text_aaaa
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: tv_record_type_title + btn_record_type (Line 77-103)
/// marginTop 16dp, marginStart/End 16dp
class _RecordTypeSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _RecordTypeSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
      ), // dp_16 marginStart/Top/End
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tv_record_type_title (caption1, enabled=false)
          Text(
            'TODO(android @string/drop_record_type)', // TODO(android @string/drop_record_type)
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textDisabled, // enabled=false
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // btn_record_type (BackgroundMaterialButton)
          _BackgroundMaterialButton(
            text: '無設定排程', // Placeholder
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_volume (Line 105-237)
/// Conditionally visible LinearLayout
class _VolumeSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _VolumeSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PARITY: layout_record_time (Line 115-165)
        // For CUSTOM mode (RecyclerView)
        _RecordTimeSection(l10n: l10n),
        // PARITY: layout_drop_info (Line 167-236)
        // For 24HR / SINGLE mode (Volume + Rotating Speed)
        _DropInfoSection(l10n: l10n),
      ],
    );
  }
}

/// PARITY: layout_record_time (Line 115-165)
/// For CUSTOM mode (RecyclerView of time slots)
class _RecordTimeSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _RecordTimeSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16), // dp_16 marginTop
      child: Column(
        children: [
          // tv_record_time_title + btn_add_time (Line 124-149)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // dp_16
            child: Row(
              children: [
                // tv_record_time_title
                Expanded(
                  child: Text(
                    'TODO(android @string/drop_record_time)', // TODO(android @string/drop_record_time)
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.textPrimary, // text_aaaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // btn_add_time (24x24dp)
                IconButton(
                  icon: CommonIconHelper.getAddIcon(
                    size: 24, // dp_24
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
            ),
          ),
          const SizedBox(height: 8), // dp_8 marginTop
          // rv_time (RecyclerView, Line 151-164)
          // bg text_a, padding 2/2
          Container(
            color: AppColors.textDisabled, // text_a background
            padding: const EdgeInsets.symmetric(vertical: 2), // dp_2
            child: Column(
              children: [
                // Placeholder for RecyclerView items
                _RecordDetailItem(),
                _RecordDetailItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: adapter_drop_custom_record_detail.xml
/// RecyclerView item for time slots
class _RecordDetailItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // Disabled in Parity Mode
      onLongPress: null, // Disabled in Parity Mode
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // dp_16/12
        color: AppColors.surface, // bg_aaaa
        child: Row(
          children: [
            // img_drop (20x20dp)
            CommonIconHelper.getDropIcon(size: 20, color: AppColors.primary),
            const SizedBox(width: 8), // dp_8
            // tv_time (caption1, text_aaa)
            Text(
              '08:00', // Placeholder
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textTertiary, // text_aaa
              ),
            ),
            const SizedBox(width: 8), // dp_8
            // tv_volume_and_times (caption1, text_aaaa)
            Text(
              '50 ml / 5次', // Placeholder
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textPrimary, // text_aaaa
              ),
            ),
            const Spacer(),
            // tv_speed (caption1_accent, bg_secondary)
            Text(
              '中速', // Placeholder
              style: AppTextStyles.caption1Accent.copyWith(
                color: AppColors.textSecondary, // bg_secondary
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PARITY: layout_drop_info (Line 167-236)
/// For 24HR / SINGLE mode (Volume + Rotating Speed)
class _DropInfoSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _DropInfoSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
      ), // dp_16 marginStart/Top/End
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tv_drop_volume_title + layout_drop_volume (Line 175-207)
          Text(
            'TODO(android @string/drop_volume)', // TODO(android @string/drop_volume)
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textPrimary, // text_color_selector
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // layout_drop_volume (TextInputLayout)
          TextField(
            enabled: false, // Disabled in Parity Mode
            decoration: InputDecoration(
              hintText: '1 ~ 500',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16), // dp_16 marginTop
          // tv_rotating_speed_title + btn_rotating_speed (Line 209-235)
          Text(
            'TODO(android @string/drop_head_rotating_speed)', // TODO(android @string/drop_head_rotating_speed)
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textDisabled, // enabled=false
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // btn_rotating_speed (BackgroundMaterialButton)
          _BackgroundMaterialButton(
            text: '中速', // Placeholder
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

/// PARITY: tv_run_time_title + layout_time (Line 239-494)
/// Run Time selection (RadioButtons)
class _RunTimeSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _RunTimeSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 24,
        right: 16,
        bottom: 24,
      ), // dp_16/24/16/24
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tv_run_time_title (body_accent, Line 239-251)
          Text(
            'TODO(android @string/run_time)', // TODO(android @string/run_time)
            style: AppTextStyles.bodyAccent.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4), // dp_4 marginTop
          // layout_time (LinearLayout, Line 253-494)
          // 4 RadioButton options
          _RunNowOption(l10n: l10n),
          const SizedBox(height: 4), // dp_4 marginTop
          _RunWeeklyOption(l10n: l10n),
          const SizedBox(height: 4), // dp_4 marginTop
          _RunTimeRangeOption(l10n: l10n),
          const SizedBox(height: 4), // dp_4 marginTop
          _RunTimePointOption(l10n: l10n),
        ],
      ),
    );
  }
}

/// PARITY: layout_now (Line 265-293)
/// RadioButton: Run Immediately
class _RunNowOption extends StatelessWidget {
  final AppLocalizations l10n;

  const _RunNowOption({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // Disabled in Parity Mode
      child: Row(
        children: [
          // rb_now
          Radio<bool>(
            value: true,
            groupValue: false, // Not selected
            onChanged: null, // Disabled in Parity Mode
          ),
          const SizedBox(width: 4), // dp_4 marginStart
          // tv_now
          Expanded(
            child: Text(
              'TODO(android @string/run_immediatrly)', // TODO(android @string/run_immediatrly)
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_drop_days_a_week (Line 295-391)
/// RadioButton: Fixed days a week (with weekday checkboxes)
class _RunWeeklyOption extends StatelessWidget {
  final AppLocalizations l10n;

  const _RunWeeklyOption({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // Disabled in Parity Mode
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // rb_weekly
              Radio<bool>(
                value: true,
                groupValue: false, // Not selected
                onChanged: null, // Disabled in Parity Mode
              ),
              const SizedBox(width: 4), // dp_4 marginStart
              // tv_drop_days_a_week_title
              Expanded(
                child: Text(
                  'TODO(android @string/drop_days_a_week)', // TODO(android @string/drop_days_a_week)
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          // layout_weekday (LinearLayout, Line 324-390)
          Padding(
            padding: const EdgeInsets.only(
              left: 48,
              top: 4,
            ), // Align with RadioButton text
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 7 weekday checkboxes (Sun-Sat)
                _WeekdayCheckbox(label: 'S'), // Sunday
                _WeekdayCheckbox(label: 'M'), // Monday
                _WeekdayCheckbox(label: 'T'), // Tuesday
                _WeekdayCheckbox(label: 'W'), // Wednesday
                _WeekdayCheckbox(label: 'T'), // Thursday
                _WeekdayCheckbox(label: 'F'), // Friday
                _WeekdayCheckbox(label: 'S'), // Saturday
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekday checkbox (MaterialCheckBox with custom button)
class _WeekdayCheckbox extends StatelessWidget {
  final String label;

  const _WeekdayCheckbox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: false, // Not selected
      onChanged: null, // Disabled in Parity Mode
    );
  }
}

/// PARITY: layout_time_range (Line 393-442)
/// RadioButton: Time Range (with calendar icon and date range)
class _RunTimeRangeOption extends StatelessWidget {
  final AppLocalizations l10n;

  const _RunTimeRangeOption({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // Disabled in Parity Mode
      child: Row(
        children: [
          // rb_time_range
          Radio<bool>(
            value: true,
            groupValue: false, // Not selected
            onChanged: null, // Disabled in Parity Mode
          ),
          const SizedBox(width: 4), // dp_4 marginStart
          // img_calendar_time_range (24x24dp)
          CommonIconHelper.getCalendarIcon(size: 24, 
            size: 24, // dp_24
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4), // dp_4 marginStart
          // tv_time_range (caption1)
          Expanded(
            child: Text(
              '2022-10-14 ~ 2022-10-31', // Placeholder
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // img_time_range_more (24x24dp, ic_next)
          CommonIconHelper.getNextIcon(size: 24, 
            size: 24, // dp_24
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_time_point (Line 444-493)
/// RadioButton: Time Point (with calendar icon and datetime)
class _RunTimePointOption extends StatelessWidget {
  final AppLocalizations l10n;

  const _RunTimePointOption({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // Disabled in Parity Mode
      child: Row(
        children: [
          // rb_time_point
          Radio<bool>(
            value: true,
            groupValue: false, // Not selected
            onChanged: null, // Disabled in Parity Mode
          ),
          const SizedBox(width: 4), // dp_4 marginStart
          // img_calendar_time_point (24x24dp)
          CommonIconHelper.getCalendarIcon(size: 24, 
            size: 24, // dp_24
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4), // dp_4 marginStart
          // tv_time_point (caption1)
          Expanded(
            child: Text(
              '2022-10-14 10:20:13', // Placeholder
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // img_time_point_more (24x24dp, ic_next)
          CommonIconHelper.getNextIcon(size: 24, 
            size: 24, // dp_24
            color: AppColors.textPrimary,
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
