import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';
import '../widgets/led_record_line_chart.dart';
import '../pages/led_record_page.dart';
import '../pages/led_record_setting_page.dart';

/// Record chart section for LED main page.
///
/// PARITY: Mirrors reef-b-app's layout_record_background CardView.
class LedMainRecordChartSection extends StatelessWidget {
  final LedSceneListController controller;
  final bool isConnected;
  final bool featuresEnabled;
  final AppLocalizations l10n;
  final VoidCallback onToggleOrientation;
  final bool isLandscape;

  const LedMainRecordChartSection({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.featuresEnabled,
    required this.l10n,
    required this.onToggleOrientation,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ledEntryRecords,
                  style: AppTextStyles.subheaderAccent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (featuresEnabled && controller.hasRecords) ...[
                      // PARITY: reef-b-app btn_expand uses ic_zoom_in
                      IconButton(
                        icon: CommonIconHelper.getZoomInIcon(size: 24),
                        iconSize: 24,
                        tooltip: isLandscape ? l10n.ledOrientationPortrait : l10n.ledOrientationLandscape,
                        onPressed: featuresEnabled && !controller.isPreviewing
                            ? () async {
                                // PARITY: reef-b-app clickBtnExpand() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
                                // PARITY: reef-b-app btnExpand toggles landscape/portrait
                                onToggleOrientation();
                              }
                            : null,
                      ),
                      // PARITY: reef-b-app btn_preview uses ic_preview / ic_stop
                      IconButton(
                        icon: controller.isPreviewing
                            ? CommonIconHelper.getStopIcon(size: 24)
                            : CommonIconHelper.getPreviewIcon(size: 24),
                        tooltip: controller.isPreviewing
                            ? l10n.ledRecordsActionPreviewStop
                            : l10n.ledRecordsActionPreviewStart,
                        onPressed: controller.isBusy
                            ? null
                            : controller.togglePreview,
                      ),
                      // PARITY: reef-b-app btn_continue_record - MaterialButton with text
                      // Using IconButton for now, but should match the button style
                      IconButton(
                        icon: CommonIconHelper.getPlayUnselectIcon(size: 24),
                        tooltip: l10n.ledContinueRecord,
                        onPressed: controller.isBusy || controller.isPreviewing
                            ? null
                            : controller.startRecord,
                      ),
                    ],
                    IconButton(
                      // PARITY: reef-b-app uses ic_more_enable / ic_more_disable for btn_record_more
                      icon: CommonIconHelper.getMoreEnableIcon(
                        size: 24,
                        color: featuresEnabled
                            ? AppColors.textPrimary
                            : AppColors.textPrimary.withValues(alpha: 0.5),
                      ),
                      iconSize: 24,
                      tooltip: l10n.ledEntryRecords,
                      onPressed: featuresEnabled
                          ? () {
                              // PARITY: reef-b-app logic
                              // If records are empty, navigate to record setting page
                              // Otherwise, navigate to record list page
                              if (controller.hasRecords) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LedRecordPage(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LedRecordSettingPage(),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // PARITY: line_chart height=242dp in reef-b-app
            // Using AspectRatio or LayoutBuilder for responsive height
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate height based on available width, maintaining aspect ratio
                // reef-b-app uses 242dp height, which is roughly 1.5:1 ratio for typical screen width
                final double chartHeight = constraints.maxWidth * 0.6;
                return LedRecordLineChart(
                  records: controller.records,
                  height: chartHeight,
                  showLegend: true,
                  interactive: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

