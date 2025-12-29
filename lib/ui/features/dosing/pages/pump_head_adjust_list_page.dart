import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../assets/common_icon_helper.dart';
import '../../../components/ble_guard.dart';
import '../../../components/error_state_widget.dart';
import '../../../components/loading_state_widget.dart';
import '../../../components/empty_state_widget.dart';
import '../controllers/pump_head_calibration_controller.dart';
import '../models/pump_head_calibration_record.dart';
import 'pump_head_calibration_page.dart';

/// Pump head adjust list page.
///
/// PARITY: Mirrors reef-b-app's DropHeadAdjustListActivity.
class PumpHeadAdjustListPage extends StatelessWidget {
  final String headId;

  const PumpHeadAdjustListPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadCalibrationController>(
      create: (_) => PumpHeadCalibrationController(
        headId: headId,
        session: session,
        readCalibrationHistoryUseCase: appContext.readCalibrationHistoryUseCase,
      )..refresh(),
      child: _PumpHeadAdjustListView(headId: headId),
    );
  }
}

class _PumpHeadAdjustListView extends StatelessWidget {
  final String headId;

  const _PumpHeadAdjustListView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<PumpHeadCalibrationController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: ReefColors.surfaceMuted,
      appBar: ReefAppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getBackIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.dosingAdjustListTitle,
        ),
        actions: [
          IconButton(
            icon: CommonIconHelper.getResetIcon(size: 24),
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: l10n.actionRefresh,
          ),
          TextButton(
            onPressed: controller.isLoading || !isConnected
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PumpHeadCalibrationPage(headId: headId),
                      ),
                    );
                  },
            child: Text(
              l10n.dosingAdjustListStartAdjust,
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const LoadingStateWidget.center()
          : Column(
              children: [
                if (!isConnected) ...[const BleGuardBanner()],
                Expanded(
                  child: controller.records.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : RefreshIndicator(
                          onRefresh: controller.refresh,
                          child: ListView.builder(
                            // PARITY: activity_drop_head_adjust_list.xml rv_adjust padding 16/8/16/8dp
                            padding: EdgeInsets.only(
                              left: ReefSpacing.md, // dp_16 paddingStart
                              top: ReefSpacing.xs, // dp_8 paddingTop
                              right: ReefSpacing.md, // dp_16 paddingEnd
                              bottom: ReefSpacing.xs, // dp_8 paddingBottom
                            ),
                            itemCount: controller.records.length,
                            itemBuilder: (context, index) {
                              final record = controller.records[index];
                              return _AdjustHistoryCard(
                                record: record,
                                l10n: l10n,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showErrorSnackBar(context, code);
    });
  }
}

class _AdjustHistoryCard extends StatelessWidget {
  final PumpHeadCalibrationRecord record;
  final AppLocalizations l10n;

  const _AdjustHistoryCard({required this.record, required this.l10n});

  /// Convert speedProfile string to rotatingSpeed int.
  /// Low -> 1, Medium -> 2, High -> 3, Custom/Other -> 2 (default to medium)
  int _speedProfileToInt(String speedProfile) {
    switch (speedProfile.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      default:
        return 2; // Default to medium for Custom or unknown profiles
    }
  }

  /// Adjust history card matching adapter_adjust.xml layout.
  ///
  /// PARITY: Mirrors reef-b-app's adapter_adjust.xml structure:
  /// - ConstraintLayout: background_white_radius, padding 12dp, margin 4dp top/bottom
  /// - tv_speed_title: caption1_accent, text_aaa
  /// - tv_speed: caption1, bg_secondary
  /// - tv_date_title: caption1_accent, text_aaa, marginTop 4dp
  /// - tv_date: caption1
  /// - tv_volume_title: caption1_accent, text_aaa, marginTop 4dp
  /// - tv_volume: caption1
  @override
  Widget build(BuildContext context) {
    final int speed = _speedProfileToInt(record.speedProfile);
    final String speedText = _getSpeedText(speed, l10n);
    final String dateText = DateFormat('yyyy-MM-dd HH:mm:ss').format(record.performedAt);
    final String volumeText = '${record.flowRateMlPerMin.toStringAsFixed(1)} ml';

    // PARITY: adapter_adjust.xml structure
    return Container(
      margin: EdgeInsets.only(
        top: ReefSpacing.xs, // dp_4 marginTop
        bottom: ReefSpacing.xs, // dp_4 marginBottom
      ),
      decoration: BoxDecoration(
        color: ReefColors.surface, // white background
        borderRadius: BorderRadius.circular(ReefRadius.md), // background_white_radius
      ),
      padding: EdgeInsets.all(ReefSpacing.md), // dp_12 padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speed row
          Row(
            children: [
              // Speed title (tv_speed_title) - caption1_accent, text_aaa
              Text(
                l10n.dosingScheduleEditRotatingSpeedLabel, // "旋轉速度" or "Rotating Speed"
                style: ReefTextStyles.caption1Accent.copyWith(
                  color: ReefColors.textTertiary, // text_aaa
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
              // Speed value (tv_speed) - caption1, bg_secondary
              Expanded(
                child: Text(
                  speedText,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textSecondary, // bg_secondary (using textSecondary as fallback)
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
          // Date row
          Row(
            children: [
              // Date title (tv_date_title) - caption1_accent, text_aaa
              Text(
                l10n.dosingAdjustListDate,
                style: ReefTextStyles.caption1Accent.copyWith(
                  color: ReefColors.textTertiary, // text_aaa
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
              // Date value (tv_date) - caption1
              Expanded(
                child: Text(
                  dateText,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
          // Volume row
          Row(
            children: [
              // Volume title (tv_volume_title) - caption1_accent, text_aaa
              Text(
                l10n.dosingAdjustListVolume,
                style: ReefTextStyles.caption1Accent.copyWith(
                  color: ReefColors.textTertiary, // text_aaa
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_4 marginStart
              // Volume value (tv_volume) - caption1
              Expanded(
                child: Text(
                  volumeText,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textPrimary,
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

  String _getSpeedText(int speed, AppLocalizations l10n) {
    switch (speed) {
      case 1:
        return l10n.dosingRotatingSpeedLow;
      case 2:
        return l10n.dosingRotatingSpeedMedium;
      case 3:
        return l10n.dosingRotatingSpeedHigh;
      default:
        return l10n.dosingRotatingSpeedMedium;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: l10n.dosingAdjustListEmptyTitle,
      subtitle: l10n.dosingAdjustListEmptySubtitle,
      icon: Icons.history,
    );
  }
}
