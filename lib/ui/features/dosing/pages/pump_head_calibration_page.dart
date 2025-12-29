import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_session.dart';
import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_radius.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../assets/common_icon_helper.dart';
import '../../../components/ble_guard.dart';
import '../../../components/error_state_widget.dart';
import '../../../components/loading_state_widget.dart';
import '../../../components/empty_state_widget.dart';
import '../controllers/pump_head_calibration_controller.dart';
import '../models/pump_head_calibration_record.dart';
import 'pump_head_adjust_list_page.dart';

class PumpHeadCalibrationPage extends StatelessWidget {
  final String headId;

  const PumpHeadCalibrationPage({super.key, required this.headId});

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
      child: _PumpHeadCalibrationView(headId: headId),
    );
  }
}

class _PumpHeadCalibrationView extends StatelessWidget {
  final String headId;

  const _PumpHeadCalibrationView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, PumpHeadCalibrationController>(
      builder: (context, session, controller, _) {
        final isConnected = session.isBleConnected;
        final theme = Theme.of(context);
        // Show error if any
        final AppErrorCode? errorCode = controller.lastErrorCode;
        if (errorCode != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              showErrorSnackBar(context, errorCode);
              controller.clearError();
            }
          });
        }

        return Scaffold(
          appBar: ReefAppBar(
            title: Text(l10n.dosingCalibrationHistoryTitle),
            actions: [
              IconButton(
                icon: CommonIconHelper.getResetIcon(size: 24),
                tooltip: l10n.dosingCalibrationAdjustListTitle,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PumpHeadAdjustListPage(headId: headId),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // PARITY: activity_drop_head_adjust.xml padding 16dp
              padding: EdgeInsets.all(ReefSpacing.md), // dp_16 padding
              children: [
                Text(
                  l10n.dosingPumpHeadSummaryTitle(headId.toUpperCase()),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: ReefSpacing.xs),
                Text(
                  l10n.dosingCalibrationHistorySubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ReefColors.textSecondary,
                  ),
                ),
                const SizedBox(height: ReefSpacing.md),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.xl),
                ],
                if (controller.isLoading)
                  const LoadingStateWidget.center()
                else if (controller.records.isEmpty)
                  _CalibrationEmptyState(l10n: l10n)
                else
                  ...controller.records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: ReefSpacing.sm,
                      ),
                      child: _CalibrationRecordCard(
                        record: record,
                        isConnected: isConnected,
                        l10n: l10n,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalibrationEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _CalibrationEmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      title: l10n.dosingCalibrationHistoryEmptyTitle,
      subtitle: l10n.dosingCalibrationHistoryEmptySubtitle,
      icon: Icons.tune_outlined,
      iconSize: 32,
    );
  }
}

class _CalibrationRecordCard extends StatelessWidget {
  final PumpHeadCalibrationRecord record;
  final bool isConnected;
  final AppLocalizations l10n;

  const _CalibrationRecordCard({
    required this.record,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = DateFormat('MMM d • h:mm a').format(record.performedAt);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(ReefRadius.lg),
        onTap: isConnected
            ? () => _showComingSoon(context)
            : () => showBleGuardDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(ReefSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      l10n.dosingCalibrationRecordSpeed(record.speedProfile),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ReefSpacing.sm),
              Text(
                l10n.dosingCalibrationRecordFlow(
                  record.flowRateMlPerMin.toStringAsFixed(1),
                ),
                style: theme.textTheme.titleMedium,
              ),
              if (record.note != null) ...[
                const SizedBox(height: ReefSpacing.xxxs),
                Text(
                  '${l10n.dosingCalibrationRecordNoteLabel}: ${record.note!}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ReefColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }
}

