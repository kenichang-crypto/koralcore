import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../models/pump_head_summary.dart';

/// Drop head card matching adapter_drop_head.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_drop_head.xml structure:
/// - MaterialCardView: margin 16/5/16/5dp, cornerRadius 8dp, elevation 10dp
/// - Title area: grey background, padding 8dp, pump head icon (80×20dp), drop type name
/// - Main area: white background, padding 8/8/12/12dp, play button (60×60dp), mode, schedule info, progress bar
class DosingMainPumpHeadCard extends StatelessWidget {
  final PumpHeadSummary summary;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const DosingMainPumpHeadCard({
    super.key,
    required this.summary,
    required this.isConnected,
    required this.l10n,
    this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (todayDispensedMl / dailyTargetMl)
    final double progress = summary.dailyTargetMl > 0
        ? (summary.todayDispensedMl / summary.dailyTargetMl).clamp(0.0, 1.0)
        : 0.0;
    final String volumeText = l10n.dosingVolumeFormat(
      summary.todayDispensedMl.toStringAsFixed(0),
      summary.dailyTargetMl.toStringAsFixed(0),
    );

    // Mode name (simplified - TODO: Get from PumpHeadMode)
    final String modeName = _getModeName(summary, l10n);

    // Time string (simplified - TODO: Get from PumpHeadMode.timeString)
    final String? timeString = null; // TODO: Get from schedule

    // Weekday selection (simplified - TODO: Get from PumpHeadMode.runDay)
    final List<bool> weekDays = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ]; // TODO: Get from schedule

    // PARITY: adapter_drop_head.xml structure
    return Card(
      margin: EdgeInsets.only(
        left: AppSpacing.md, // dp_16 marginStart
        top: 5, // dp_5 marginTop
        right: AppSpacing.md, // dp_16 marginEnd
        bottom: 5, // dp_5 marginBottom
      ),
      elevation: 10, // dp_10
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm), // dp_8 cornerRadius
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title area (layout_drop_head_title) - grey background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.xs), // dp_8 padding
              decoration: BoxDecoration(
                color: AppColors.grey, // grey background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.sm),
                  topRight: Radius.circular(AppRadius.sm),
                ),
              ),
              child: Row(
                children: [
                  // Pump head icon (img_drop_head) - 80×20dp
                  // PARITY: Android img_drop_head_1.xml ~ img_drop_head_4.xml
                  // Mapping: A→1, B→2, C→3, D→4
                  // TODO(android @drawable/img_drop_head_1-4):
                  // Verify SVG content matches Android XML Vector Drawable
                  SvgPicture.asset(
                    'assets/icons/img_drop_head_${_headIdToNumber(summary.headId)}.svg',
                    width: 80, // dp_80
                    height: 20, // dp_20
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(width: 32), // dp_32 marginStart
                  // Drop type name (tv_drop_type_name) - body_accent
                  Expanded(
                    child: Text(
                      summary.additiveName.isNotEmpty
                          ? summary.additiveName
                          : l10n.dosingPumpHeadNoType,
                      style: AppTextStyles.bodyAccent.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Main area (layout_drop_head_main) - white background
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: AppSpacing.xs, // dp_8 paddingStart
                top: AppSpacing.xs, // dp_8 paddingTop
                right: AppSpacing.md + AppSpacing.xs, // dp_12 paddingEnd
                bottom: AppSpacing.md + AppSpacing.xs, // dp_12 paddingBottom
              ),
              decoration: BoxDecoration(
                color: AppColors.surface, // white background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.sm),
                  bottomRight: Radius.circular(AppRadius.sm),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Play button (btn_play) - 60×60dp
                  // PARITY: Android ic_play_enabled.xml
                  // TODO(android @drawable/ic_play_enabled):
                  // Verify CommonIconHelper.getPlayIcon() matches Android ic_play_enabled.xml
                  if (onPlay != null)
                    IconButton(
                      icon: CommonIconHelper.getPlayIcon(
                        size: 60,
                        color: AppColors.primary,
                      ),
                      onPressed: onPlay,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                    )
                  else
                    SizedBox(width: 60, height: 60),
                  SizedBox(width: AppSpacing.md), // dp_12 marginStart
                  // Mode and schedule info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mode (tv_mode) - caption1, bg_secondary color
                        Text(
                          modeName,
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors
                                .textSecondary, // bg_secondary (using textSecondary as fallback)
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs), // dp_8 marginTop
                        // Schedule info (layout_mode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Weekday icons (layout_weekday)
                            // PARITY: Android ic_*_select/unselect.xml (7 icons, 20x20dp)
                            // TODO(android @drawable/ic_sunday_unselect etc):
                            // Verify SVG icons match Android XML Vector Drawables
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(7, (index) {
                                final bool isSelected = weekDays[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0
                                        ? 0
                                        : AppSpacing
                                              .xs, // dp_4 marginStart (except first)
                                    right: index < 6
                                        ? AppSpacing.xs
                                        : 0, // dp_4 marginEnd (except last)
                                  ),
                                  // PARITY: Using SvgPicture for weekday icons for 100% parity
                                  child: SvgPicture.asset(
                                    _getWeekdayIconAsset(index, isSelected),
                                    width: 20, // dp_20
                                    height: 20, // dp_20
                                  ),
                                );
                              }),
                            ),
                            // Time string (tv_time) - caption1_accent, text_aaaa
                            if (timeString != null) ...[
                              SizedBox(height: AppSpacing.xs), // dp_8 marginTop
                              Text(
                                timeString,
                                style: AppTextStyles.caption1Accent.copyWith(
                                  color: AppColors.textPrimary, // text_aaaa
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            // Progress bar and volume (pb_volume, tv_volume)
                            SizedBox(height: AppSpacing.xs), // dp_4 marginTop
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Progress bar
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 20, // dp_20 trackThickness
                                  backgroundColor: AppColors
                                      .surfacePressed, // bg_press trackColor
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.grey, // grey indicatorColor
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // dp_10 trackCornerRadius
                                ),
                                // Volume text (tv_volume) - caption1, text_aaaa
                                Text(
                                  volumeText,
                                  style: AppTextStyles.caption1.copyWith(
                                    color: AppColors.textPrimary, // text_aaaa
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // PARITY: chip_total (visibility=gone)
                        // android/ReefB_Android/app/src/main/res/layout/adapter_drop_head.xml Line 222-239
                        //
                        // Chip properties:
                        // - marginTop: 8dp
                        // - clickable: false
                        // - visibility: gone (預設隱藏)
                        // - textAppearance: caption1
                        // - textColor: text_aaaa
                        // - chipBackgroundColor: bg_aaaa
                        // - chipIcon: ic_solid_add
                        // - chipStrokeColor: text_aaaa
                        // - chipStrokeWidth: 1dp
                        // - tools:text: "120 ml"
                        //
                        // PARITY: 因為預設 visibility=gone，所以不顯示
                        // 保留結構以供未來實作
                        const SizedBox.shrink(), // visibility=gone (不佔空間)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeName(PumpHeadSummary summary, AppLocalizations l10n) {
    // TODO: Get actual mode from PumpHeadMode
    // For now, return a default mode name
    if (summary.dailyTargetMl > 0) {
      return l10n.dosingPumpHeadModeScheduled;
    }
    return l10n.dosingPumpHeadModeFree;
  }

  String _getWeekdayIconAsset(int index, bool isSelected) {
    // Index: 0=Sunday, 1=Monday, ..., 6=Saturday
    // PARITY: Android ic_sunday_unselect.xml ~ ic_saturday_unselect.xml
    // TODO(android @drawable/ic_*_select/unselect):
    // Verify SVG content matches Android XML Vector Drawable
    final List<String> weekdayNames = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final String state = isSelected ? 'select' : 'unselect';
    return 'assets/icons/ic_${weekdayNames[index]}_$state.svg';
  }

  /// Convert head ID (A-D) to number (1-4) for Android resource naming
  /// PARITY: Android uses img_drop_head_1.xml ~ img_drop_head_4.xml
  String _headIdToNumber(String headId) {
    switch (headId.toUpperCase()) {
      case 'A':
        return '1';
      case 'B':
        return '2';
      case 'C':
        return '3';
      case 'D':
        return '4';
      default:
        return '1'; // Fallback to 1
    }
  }
}
