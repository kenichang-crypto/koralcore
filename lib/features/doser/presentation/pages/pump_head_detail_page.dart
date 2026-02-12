// PARITY: 100% Android activity_drop_head_main.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_main.xml
// Mode: Feature Implementation (完整功能實現)
//
// Android 結構：
// - Root: ConstraintLayout (bg_aaa)
// - Toolbar: include toolbar_device (固定)
// - Main Content: ConstraintLayout (固定高度，不可捲動)
//   - Drop Head Info Card (CardView)
//   - Record Section (Title + ImageView Button + CardView)
//   - Adjust Section (Title + ImageView Button + CardView)
// - Progress: include progress (visibility=gone)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../domain/doser_dosing/dosing_schedule_summary.dart';
import '../../../../domain/doser_dosing/pump_head_adjust_history.dart';
import '../controllers/pump_head_detail_controller.dart';
import 'pump_head_settings_page.dart';
import 'pump_head_schedule_page.dart';
import 'pump_head_adjust_list_page.dart';
import '../../../../core/ble/ble_guard.dart';
import 'package:koralcore/l10n/app_localizations.dart';

/// PumpHeadDetailPage - 100% Parity with Android DropHeadMainActivity
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_head_main.xml
///
/// Feature Implementation Mode:
/// - 集成 PumpHeadDetailController
/// - 完整業務邏輯
/// - BLE 連線狀態處理
/// - 數據讀取與顯示
class PumpHeadDetailPage extends StatelessWidget {
  final String headId;

  const PumpHeadDetailPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider(
      create: (_) => PumpHeadDetailController(
        headId: headId,
        session: session,
        observeDosingStateUseCase: appContext.observeDosingStateUseCase,
        readTodayTotalUseCase: appContext.readTodayTotalUseCase,
        readDosingScheduleSummaryUseCase:
            appContext.readDosingScheduleSummaryUseCase,
        singleDoseImmediateUseCase: appContext.singleDoseImmediateUseCase,
        singleDoseTimedUseCase: appContext.singleDoseTimedUseCase,
      )..refresh(),
      child: _PumpHeadDetailPageContent(headId: headId),
    );
  }
}

/// Internal content widget that has access to PumpHeadDetailController
class _PumpHeadDetailPageContent extends StatefulWidget {
  final String headId;

  const _PumpHeadDetailPageContent({required this.headId});

  @override
  State<_PumpHeadDetailPageContent> createState() =>
      _PumpHeadDetailPageContentState();
}

class _PumpHeadDetailPageContentState
    extends State<_PumpHeadDetailPageContent> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PumpHeadDetailController>();
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);

    // Build title: "Device Name / CH X"
    final deviceName = session.activeDeviceName ?? l10n.dosingHeader;
    final headNumber = _getHeadNumber(widget.headId);
    final title = '$deviceName / CH $headNumber';

    return Scaffold(
      // PARITY: Root ConstraintLayout (bg_aaa)
      backgroundColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
      body: Stack(
        children: [
          Column(
            children: [
              // PARITY: include toolbar_device (Line 9-14)
              _ToolbarDevice(
                title: title,
                onBack: () => Navigator.of(context).pop(),
                onMenu: () => _showPopupMenu(context),
              ),
              // PARITY: Main Content ConstraintLayout (Line 16-476)
              // UX A3: reef activity_drop_head_main 無 ScrollView → 單頁固定
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 12,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UI Block 1: Drop Head Info Card
                      _DropHeadInfoCard(
                        controller: controller,
                        isConnected: session.isBleConnected,
                      ),

                      // UI Block 2: Record Section
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: l10n.pumpHeadRecordTitle,
                        onMorePressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PumpHeadSchedulePage(
                                headId: widget.headId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _RecordCard(
                        controller: controller,
                        isConnected: session.isBleConnected,
                        l10n: l10n,
                      ),

                      // UI Block 3: Adjust Section
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: l10n.recentCalibrationRecords,
                        onMorePressed: () {
                          if (!session.isBleConnected) {
                            showBleGuardDialog(context);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PumpHeadAdjustListPage(
                                headId: widget.headId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _AdjustCard(
                        controller: controller,
                        isConnected: session.isBleConnected,
                        l10n: l10n,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // PARITY: include progress (Line 478-483)
          _ProgressOverlay(visible: controller.isLoading),
        ],
      ),
    );
  }

  int _getHeadNumber(String headId) {
    final normalized = headId.trim().toUpperCase();
    if (normalized.isEmpty) return 1;
    return normalized.codeUnitAt(0) - 64; // A=1, B=2, C=3, D=4
  }

  void _showPopupMenu(BuildContext context) {
    // PARITY: reef drop_head_menu.xml — 僅 action_edit (Edit → DropHeadSettingActivity)
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context).actionEdit),
              onTap: () async {
                Navigator.of(modalContext).pop();
                final session = context.read<AppSession>();
                final deviceId = session.activeDeviceId;
                if (deviceId != null) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PumpHeadSettingsPage(
                        deviceId: deviceId,
                        headId: widget.headId,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// PARITY: include toolbar_device
/// android/ReefB_Android/app/src/main/res/layout/toolbar_device.xml
class _ToolbarDevice extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const _ToolbarDevice({required this.title, this.onBack, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.primaryStrong,
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
              title,
              style: AppTextStyles.title2.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: CommonIconHelper.getMenuIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

/// PARITY: layout_drop_head_info (Line 24-99)
/// CardView for Drop Head Information
class _DropHeadInfoCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final bool isConnected;

  const _DropHeadInfoCard({
    required this.controller,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = controller.summary;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Row 1: Drop Type
            Row(
              children: [
                Text(
                  l10n.dosingType,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary.additiveName.isEmpty
                        ? l10n.dosingPumpHeadNoType
                        : summary.additiveName,
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Row 2: Max Drop Volume (visibility=gone in Android)
            // 保持隱藏以對齊 Android
          ],
        ),
      ),
    );
  }
}

/// PARITY: Section Header (Title + More Button)
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMorePressed;

  const _SectionHeader({required this.title, this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyAccent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onMorePressed,
          child: CommonIconHelper.getMenuIcon(
            size: 24,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// PARITY: layout_record (Line 126-324)
/// CardView for Record Information
class _RecordCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final bool isConnected;
  final AppLocalizations l10n;

  const _RecordCard({
    required this.controller,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleSummary = controller.dosingScheduleSummary;
    final todaySummary = controller.todayDoseSummary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Today Record Drop Volume
            Row(
              children: [
                Text(
                  l10n.todayScheduledVolume,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isConnected && todaySummary != null
                        ? '${todaySummary.scheduledMl?.toStringAsFixed(1) ?? '0.0'} ml'
                        : '- ml',
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Divider
            const SizedBox(height: 4),
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            // Row 2: Record Type
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  l10n.dosingScheduleType,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isConnected && scheduleSummary != null
                        ? _getScheduleTypeText(scheduleSummary)
                        : l10n.deviceNotConnected,
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: isConnected
                          ? AppColors.textPrimary
                          : const Color(0xFF6F916F),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getScheduleTypeText(DosingScheduleSummary scheduleSummary) {
    switch (scheduleSummary.mode) {
      case DosingScheduleMode.none:
        return l10n.dosingScheduleTypeNone;
      case DosingScheduleMode.dailyAverage:
        return l10n.dosingScheduleType24h;
      case DosingScheduleMode.customWindow:
        return l10n.dosingScheduleTypeCustom;
    }
  }
}

/// PARITY: layout_adjust (Line 351-475)
/// CardView for Adjust Information
/// layout_adjust_connect: low/middle/high speed rows with last calibration time
class _AdjustCard extends StatelessWidget {
  final PumpHeadDetailController controller;
  final bool isConnected;
  final AppLocalizations l10n;

  const _AdjustCard({
    required this.controller,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isConnected)
              Text(
                l10n.deviceNotConnected,
                style: AppTextStyles.bodyAccent.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
            else
              _buildCalibrationContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationContent() {
    final List<PumpHeadAdjustHistory>? history = controller.calibrationHistory;
    final Map<int, String> lastBySpeed = _lastCalibrationTimeBySpeed(history);

    if (lastBySpeed.isEmpty) {
      return Text(
        l10n.dosingCalibrationHistoryEmptySubtitle,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalibrationRow(
          label: l10n.pumpHeadSpeedLow,
          time: lastBySpeed[1] ?? l10n.generalNone,
        ),
        const SizedBox(height: 8),
        _CalibrationRow(
          label: l10n.pumpHeadSpeedMedium,
          time: lastBySpeed[2] ?? l10n.generalNone,
        ),
        const SizedBox(height: 8),
        _CalibrationRow(
          label: l10n.pumpHeadSpeedHigh,
          time: lastBySpeed[3] ?? l10n.generalNone,
        ),
      ],
    );
  }

  Map<int, String> _lastCalibrationTimeBySpeed(
    List<PumpHeadAdjustHistory>? history,
  ) {
    if (history == null || history.isEmpty) return {};
    final Map<int, String> result = {};
    for (final entry in history) {
      result[entry.rotatingSpeed] = entry.timeString;
    }
    return result;
  }
}

class _CalibrationRow extends StatelessWidget {
  final String label;
  final String time;

  const _CalibrationRow({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption1Accent.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            time,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// PARITY: include progress (全畫面 Loading Overlay)
class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
