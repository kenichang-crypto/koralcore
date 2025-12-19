import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_session.dart';
import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/pump_head_calibration_controller.dart';
import '../models/pump_head_calibration_record.dart';

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
        _maybeShowError(context, controller.lastErrorCode);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.dosingCalibrationHistoryTitle)),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              children: [
                Text(
                  l10n.dosingPumpHeadSummaryTitle(head: headId.toUpperCase()),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  l10n.dosingCalibrationHistorySubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingXXL,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.records.isEmpty)
                  _CalibrationEmptyState(l10n: l10n)
                else
                  ...controller.records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
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
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.tune_outlined, size: 32),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              l10n.dosingCalibrationHistoryEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.dosingCalibrationHistoryEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: isConnected
            ? () => _showComingSoon(context)
            : () => showBleGuardDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      l10n.dosingCalibrationRecordSpeed(
                        speed: record.speedProfile,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                l10n.dosingCalibrationRecordFlow(
                  flow: record.flowRateMlPerMin.toStringAsFixed(1),
                ),
                style: theme.textTheme.titleMedium,
              ),
              if (record.note != null) ...[
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  '${l10n.dosingCalibrationRecordNoteLabel}: ${record.note!}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
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

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PumpHeadCalibrationController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      controller.clearError();
    });
  }
}
