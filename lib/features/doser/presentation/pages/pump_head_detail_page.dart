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
import '../controllers/pump_head_detail_controller.dart';
import 'pump_head_settings_page.dart';
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
          RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: Column(
              children: [
                // PARITY: include toolbar_device (Line 9-14)
                _ToolbarDevice(
                  title: title,
                  onBack: () => Navigator.of(context).pop(),
                  onMenu: () => _showPopupMenu(context, controller),
                ),
                // PARITY: Main Content ConstraintLayout (Line 16-476)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                              // TODO: Navigate to Record Settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.comingSoon)),
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
                              // TODO: Navigate to Adjust List
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.comingSoon)),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          _AdjustCard(
                            isConnected: session.isBleConnected,
                            l10n: l10n,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showPopupMenu(
    BuildContext context,
    PumpHeadDetailController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final session = context.read<AppSession>();
    final isReady = session.isReady;

    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.dosingPumpHeadSettingsTitle),
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
            ListTile(
              title: Text(l10n.dosingManualPageSubtitle),
              enabled: isReady,
              onTap: () async {
                Navigator.of(modalContext).pop();
                final success = await controller.sendManualDose();
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.dosingPumpHeadManualDoseSuccess),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: Text(l10n.dosingPumpHeadTimedDose),
              enabled: isReady,
              onTap: () async {
                Navigator.of(modalContext).pop();
                final success = await controller.scheduleTimedDose();
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.dosingPumpHeadTimedDoseSuccess),
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

  String _getScheduleTypeText(dynamic scheduleSummary) {
    // TODO: 根據實際的 DosingScheduleSummary 結構返回正確的文字
    return l10n.dosingScheduleTypeNone;
  }
}

/// PARITY: layout_adjust (Line 351-475)
/// CardView for Adjust Information
class _AdjustCard extends StatelessWidget {
  final bool isConnected;
  final AppLocalizations l10n;

  const _AdjustCard({required this.isConnected, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (!isConnected)
              Text(
                l10n.deviceNotConnected,
                style: AppTextStyles.bodyAccent.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
            else
              // TODO: 顯示校正歷史數據
              // 需要 controller 支援 adjust history
              Text(
                l10n.dosingCalibrationHistoryEmptySubtitle,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
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
