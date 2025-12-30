import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/pump_head_detail_controller.dart';
import '../widgets/pump_head_detail_status_card.dart';
import '../widgets/pump_head_detail_metrics_grid.dart';
import '../widgets/pump_head_detail_today_dose_card.dart';
import '../widgets/pump_head_detail_schedule_summary_card.dart';
import '../widgets/pump_head_detail_schedule_overview_tile.dart';
import '../widgets/pump_head_detail_calibration_history_tile.dart';
import '../widgets/pump_head_detail_settings_tile.dart';
import '../widgets/pump_head_detail_action_buttons.dart';
import 'pump_head_settings_page.dart';

class PumpHeadDetailPage extends StatelessWidget {
  final String headId;

  const PumpHeadDetailPage({super.key, required this.headId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadDetailController>(
      create: (_) => PumpHeadDetailController(
        headId: headId,
        session: session,
        readTodayTotalUseCase: appContext.readTodayTotalUseCase,
        readDosingScheduleSummaryUseCase:
            appContext.readDosingScheduleSummaryUseCase,
        singleDoseImmediateUseCase: appContext.singleDoseImmediateUseCase,
        singleDoseTimedUseCase: appContext.singleDoseTimedUseCase,
      )..refresh(),
      child: _PumpHeadDetailView(headId: headId),
    );
  }
}

class _PumpHeadDetailView extends StatelessWidget {
  final String headId;

  const _PumpHeadDetailView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<AppSession, PumpHeadDetailController>(
      builder: (context, session, controller, _) {
        final summary = controller.summary;
        final deviceName = session.activeDeviceName ?? l10n.appTitle;
        final isConnected = session.isBleConnected;
        _maybeShowError(context, controller.lastErrorCode);

        return Scaffold(
          backgroundColor: AppColors.surfaceMuted,
          appBar: ReefAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            title: Text(
              l10n.dosingPumpHeadSummaryTitle(summary.headId),
              style: AppTextStyles.title2.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            actions: [
              // Menu button (Edit settings)
              PopupMenuButton<String>(
                icon: CommonIconHelper.getMenuIcon(
                  size: 24,
                  color: AppColors.onPrimary,
                ),
                enabled: isConnected,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PumpHeadSettingsPage(
                            headId: headId,
                            initialName: summary.displayName,
                            initialDelaySeconds: 0,
                          ),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        CommonIconHelper.getEditIcon(size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.dosingPumpHeadSettingsTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: Column(
              children: [
                // Fixed header section
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md, // dp_16 paddingStart
                    top: AppSpacing.sm, // dp_12 paddingTop
                    right: AppSpacing.md, // dp_16 paddingEnd
                  ),
                  child: Column(
                    children: [
                      if (!isConnected) ...[
                        const BleGuardBanner(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      PumpHeadDetailStatusCard(
                        summary: summary,
                        deviceName: deviceName,
                        isLoading: controller.isLoading,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
                // Scrollable content section
                Expanded(
                  child: ListView(
                    // PARITY: General settings page layout - padding 16/12/16/40dp
                    padding: EdgeInsets.only(
                      left: AppSpacing.md, // dp_16 paddingStart
                      top: AppSpacing.xl, // dp_12 paddingTop + spacing
                      right: AppSpacing.md, // dp_16 paddingEnd
                      bottom: 40, // dp_40 paddingBottom
                    ),
                    children: [
                      PumpHeadDetailMetricsGrid(summary: summary, l10n: l10n),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailTodayDoseCard(controller: controller, l10n: l10n),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailScheduleSummaryCard(controller: controller, l10n: l10n),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailScheduleOverviewTile(
                        headId: headId,
                        isConnected: isConnected,
                        l10n: l10n,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailCalibrationHistoryTile(
                        headId: headId,
                        isConnected: isConnected,
                        l10n: l10n,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailSettingsTile(
                        headId: headId,
                        initialName: summary.displayName,
                        initialDelaySeconds: 0,
                        isConnected: isConnected,
                        l10n: l10n,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PumpHeadDetailActionButtons(
                        isConnected: isConnected,
                        l10n: l10n,
                        controller: controller,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
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

void _maybeShowError(BuildContext context, AppErrorCode? code) {
  if (code == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final controller = context.read<PumpHeadDetailController>();
    final l10n = AppLocalizations.of(context);
    final message = describeAppError(l10n, code);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    controller.clearError();
  });
}
