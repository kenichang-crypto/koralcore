// PARITY: 100% Android activity_drop_head_adjust.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_adjust.xml
// Mode: Correction (路徑 B：完全 Parity 化)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - Main Content: ConstraintLayout (layout_height="0dp", padding 16dp)
//   - tv_adjust_description_title + tv_adjust_step (說明文字)
//   - tv_rotating_speed_title + btn_rotating_speed (旋轉速度, marginTop 24dp)
//   - tv_adjust_drop_volume_title + layout_adjust_drop_volume (滴液量, visibility=gone, marginTop 16dp)
//   - img_adjust (調整圖片, marginTop 24dp)
//   - btn_prev ("取消", left bottom) + btn_next ("下一步", right bottom)
//   - btn_complete ("完成校正", full width, visibility=invisible)
// - Progress: include progress (visibility=gone)
// - Loading: include dialog_loading (visibility=gone)
//
// 所有業務邏輯已移除，僅保留 UI 結構。

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import 'pump_head_adjust_page.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../led/presentation/helpers/support/led_record_icon_helper.dart';

/// PumpHeadCalibrationPage - PARITY with reef activity_drop_head_adjust
///
/// Intro page for calibration flow. Speed button selects speed, Next navigates
/// to PumpHeadAdjustPage with selected speed.
class PumpHeadCalibrationPage extends StatefulWidget {
  final String headId;

  const PumpHeadCalibrationPage({super.key, required this.headId});

  @override
  State<PumpHeadCalibrationPage> createState() =>
      _PumpHeadCalibrationPageState();
}

class _PumpHeadCalibrationPageState extends State<PumpHeadCalibrationPage> {
  int _selectedSpeed = 1; // 1=Low, 2=Medium, 3=High

  String _speedLabel(AppLocalizations l10n) {
    switch (_selectedSpeed) {
      case 1:
        return l10n.pumpHeadSpeedLow;
      case 2:
        return l10n.pumpHeadSpeedMedium;
      case 3:
        return l10n.pumpHeadSpeedHigh;
      default:
        return l10n.pumpHeadSpeedMedium;
    }
  }

  Future<void> _showSpeedPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.pumpHeadSpeedLow),
              onTap: () => Navigator.of(ctx).pop(1),
            ),
            ListTile(
              title: Text(l10n.pumpHeadSpeedMedium),
              onTap: () => Navigator.of(ctx).pop(2),
            ),
            ListTile(
              title: Text(l10n.pumpHeadSpeedHigh),
              onTap: () => Navigator.of(ctx).pop(3),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedSpeed = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final isReady = session.isReady;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: toolbar_drop_head_adjust (Line 8-14)
              _ToolbarTwoAction(l10n: l10n),
              // PARITY: layout_drop_head_adjust (Line 16-170)
              // ConstraintLayout with layout_height="0dp", padding 16dp
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16), // dp_16 padding (Line 20)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PARITY: tv_adjust_description_title (Line 26-37)
                      Text(
                        l10n.dosingAdjustDescription,
                        style: AppTextStyles.title2.copyWith(
                          color: AppColors.textPrimary, // text_aaaa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 43)
                      // PARITY: tv_adjust_step (Line 39-50)
                      Text(
                        l10n.dosingAdjustStep,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textTertiary, // text_aaa
                        ),
                      ),
                      const SizedBox(height: 24), // dp_24 marginTop (Line 57)
                      // PARITY: tv_rotating_speed_title + btn_rotating_speed (Line 52-78)
                      Text(
                        l10n.pumpHeadSpeed,
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textPrimary, // text_aaaa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // dp_4 marginTop (Line 71)
                      _BackgroundMaterialButton(
                        text: _speedLabel(l10n),
                        onPressed: isReady ? () => _showSpeedPicker(context) : null,
                      ),
                      const SizedBox(height: 16), // dp_16 marginTop (Line 86)
                      // PARITY: tv_adjust_drop_volume_title + layout_adjust_drop_volume (Line 80-114)
                      // visibility=gone (Line 83)
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dosingVolume,
                              style: AppTextStyles.caption1.copyWith(
                                color: AppColors
                                    .textPrimary, // text_color_selector
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 4,
                            ), // dp_4 marginTop (Line 100)
                            TextField(
                              // PARITY: reef edt_adjust_drop_volume 無 android:enabled=false
                              decoration: InputDecoration(
                                hintText:
                                    l10n.dosingAdjustVolumeHint,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24), // dp_24 marginTop (Line 121)
                      // PARITY: img_adjust (Line 116-125) - reef uses PNG; koralcore uses ic_strength_thumb
                      Expanded(
                        child: Center(
                          child: CommonIconHelper.getStrengthThumbIcon(
                            size: 120,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // PARITY: btn_prev + btn_next + btn_complete (Line 127-169)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              l10n.actionCancel,
                              style: AppTextStyles.caption1.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => PumpHeadAdjustPage(
                                    headId: widget.headId,
                                    initialSpeed: _selectedSpeed,
                                  ),
                                ),
                              );
                            },
                            color: AppColors.primary,
                            textColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 43,
                              vertical: 12,
                            ),
                            child: Text(
                              l10n.actionNext,
                              style: AppTextStyles.caption1,
                            ),
                          ),
                        ],
                      ),
                      // btn_complete ("完成校正", full width, visibility=invisible, Line 155-169)
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: SizedBox(
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: null, // Disabled in Parity Mode
                            color: AppColors.primary,
                            textColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 43, // dp_43 paddingStart/End
                              vertical: 12, // dp_12 paddingTop/Bottom
                            ),
                            child: Text(
                              l10n.dosingCompleteAdjust,
                              style: AppTextStyles.caption1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // PARITY: progress (Line 172-177, visibility="gone")
          _ProgressOverlay(visible: false),
          // PARITY: loading (dialog_loading, Line 179-184, visibility="gone")
          _LoadingOverlay(visible: false),
        ],
      ),
    );
  }
}

/// PARITY: toolbar_two_action.xml
/// - Title: activity_drop_head_adjust_title
/// - Left: btn_back
/// - Right: (no right button)
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
          IconButton(
            icon: CommonIconHelper.getBackIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          // toolbar_title
          Expanded(
            child: Text(
              l10n.dosingAdjustTitle,
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // No right button (Android only shows btn_back)
          const SizedBox(width: 48), // Balance for btn_back
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

/// PARITY: dialog_loading.xml (include layout)
/// Full-screen overlay with loading dialog
class _LoadingOverlay extends StatelessWidget {
  final bool visible;

  const _LoadingOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Visibility(
      visible: visible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5), // Semi-transparent overlay
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.dosingAdjusting,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
