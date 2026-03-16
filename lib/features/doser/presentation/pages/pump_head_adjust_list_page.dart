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
import 'package:provider/provider.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../domain/doser_dosing/pump_head_adjust_history.dart';
import '../controllers/pump_head_adjust_list_controller.dart';
import 'pump_head_calibration_page.dart';

/// PumpHeadAdjustListPage - PARITY with reef DropHeadAdjustListActivity
///
/// reef: back->finish, right->start DropHeadAdjustActivity (PumpHeadCalibrationPage)
class PumpHeadAdjustListPage extends StatelessWidget {
  final String headId;

  const PumpHeadAdjustListPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<PumpHeadAdjustListController>(
      create: (_) => PumpHeadAdjustListController(
        headId: headId,
        session: session,
        observeDosingStateUseCase: appContext.observeDosingStateUseCase,
      ),
      child: _PumpHeadAdjustListContent(headId: headId),
    );
  }
}

class _PumpHeadAdjustListContent extends StatelessWidget {
  final String headId;

  const _PumpHeadAdjustListContent({required this.headId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PumpHeadAdjustListController>();
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final history = controller.history ?? const <PumpHeadAdjustHistory>[];

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
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
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: history.isNotEmpty ? history.length : 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, index) {
                    if (history.isEmpty) {
                      return _AdjustHistoryEmptyState(
                        l10n: l10n,
                        isConnected: session.isBleConnected,
                        error: controller.error,
                      );
                    }
                    return _AdjustHistoryItem(history: history[index]);
                  },
                ),
              ),
            ],
          ),
          _ProgressOverlay(visible: controller.isLoading),
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
  final PumpHeadAdjustHistory history;

  const _AdjustHistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(
            label: l10n.rotatingSpeed,
            value: _speedLabel(l10n, history.rotatingSpeed),
          ),
          const SizedBox(height: 4),
          _buildRow(
            label: l10n.dosingAdjustDateTitle,
            value: history.timeString,
          ),
          const SizedBox(height: 4),
          _buildRow(
            label: l10n.dosingVolume,
            value: '${history.volume} ml',
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.caption1Accent.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _speedLabel(AppLocalizations l10n, int speed) {
    switch (speed) {
      case 1:
        return l10n.pumpHeadSpeedLow;
      case 2:
        return l10n.pumpHeadSpeedMedium;
      case 3:
        return l10n.pumpHeadSpeedHigh;
      default:
        return l10n.pumpHeadSpeedDefault;
    }
  }
}

class _AdjustHistoryEmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isConnected;
  final Object? error;

  const _AdjustHistoryEmptyState({
    required this.l10n,
    required this.isConnected,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final String message = error?.toString() ??
        (isConnected ? l10n.dosingAdjustListEmptySubtitle : l10n.deviceNotConnected);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
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
