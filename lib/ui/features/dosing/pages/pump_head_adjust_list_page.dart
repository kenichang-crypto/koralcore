import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
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
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.dosingAdjustListTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                            padding: const EdgeInsets.all(ReefSpacing.lg),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(record.performedAt),
                  style: ReefTextStyles.title3,
                ),
                _RotatingSpeedChip(
                  speed: _speedProfileToInt(record.speedProfile),
                  l10n: l10n,
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.sm),
            Row(
              children: [
                Icon(Icons.water_drop, size: 16, color: ReefColors.primary),
                const SizedBox(width: ReefSpacing.xs),
                Text(
                  '${record.flowRateMlPerMin.toStringAsFixed(1)} ml/min',
                  style: ReefTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingSpeedChip extends StatelessWidget {
  final int speed;
  final AppLocalizations l10n;

  const _RotatingSpeedChip({required this.speed, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (speed) {
      case 1:
        label = l10n.dosingRotatingSpeedLow;
        color = ReefColors.success;
        break;
      case 2:
        label = l10n.dosingRotatingSpeedMedium;
        color = ReefColors.warning;
        break;
      case 3:
        label = l10n.dosingRotatingSpeedHigh;
        color = ReefColors.error;
        break;
      default:
        label = 'Unknown';
        color = ReefColors.grey;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
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
