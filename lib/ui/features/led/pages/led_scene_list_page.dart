import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';
import '../widgets/led_spectrum_chart.dart';

const _ledIconAsset = 'assets/icons/led/led_main.png';

class LedSceneListPage extends StatelessWidget {
  const LedSceneListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    final appContext = context.read<AppContext>();
    return ChangeNotifierProvider<LedSceneListController>(
      create: (_) => LedSceneListController(
        session: session,
        readLedScenesUseCase: appContext.readLedScenesUseCase,
        applySceneUseCase: appContext.applySceneUseCase,
        observeLedStateUseCase: appContext.observeLedStateUseCase,
        readLedStateUseCase: appContext.readLedStateUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
      )..initialize(),
      child: const _LedSceneListView(),
    );
  }
}

class _LedSceneListView extends StatelessWidget {
  const _LedSceneListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedSceneListController>(
      builder: (context, session, controller, _) {
        final isConnected = session.isBleConnected;
        final theme = Theme.of(context);
        _maybeShowError(context, controller);
        _maybeShowEvent(context, controller);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.ledScenesListTitle)),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              children: [
                Text(
                  l10n.ledScenesListSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                if (controller.currentChannelLevels.isNotEmpty) ...[
                  LedSpectrumChart.fromChannelMap(
                    controller.currentChannelLevels,
                    height: 72,
                    compact: true,
                    emptyLabel: l10n.ledControlEmptyState,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                ],
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
                if (controller.isBusy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.spacingM),
                    child: LinearProgressIndicator(),
                  ),
                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingXXL,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.scenes.isEmpty)
                  _ScenesEmptyState(l10n: l10n)
                else
                  ...controller.scenes.map(
                    (scene) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      child: _SceneCard(
                        scene: scene,
                        isConnected: isConnected,
                        l10n: l10n,
                        onApply:
                            isConnected &&
                                !controller.isBusy &&
                                scene.isEnabled &&
                                !scene.isActive
                            ? () => controller.applyScene(scene.id)
                            : null,
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

void _maybeShowError(BuildContext context, LedSceneListController controller) {
  final code = controller.lastErrorCode;
  if (code == null) {
    return;
  }

  final message = describeAppError(AppLocalizations.of(context), code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  controller.clearError();
}

void _maybeShowEvent(BuildContext context, LedSceneListController controller) {
  final event = controller.consumeEvent();
  if (event == null) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  late final String message;
  switch (event.type) {
    case LedSceneEventType.applySuccess:
      message = l10n.ledScenesSnackApplied;
      break;
    case LedSceneEventType.applyFailure:
      final code = event.errorCode ?? AppErrorCode.unknownError;
      message = describeAppError(l10n, code);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _ScenesEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _ScenesEmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_ledIconAsset, width: 32, height: 32),
            const SizedBox(height: AppDimensions.spacingM),
            Text(l10n.ledScenesEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.ledScenesEmptySubtitle,
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

class _SceneCard extends StatelessWidget {
  final LedSceneSummary scene;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback? onApply;

  const _SceneCard({
    required this.scene,
    required this.isConnected,
    required this.l10n,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String statusLabel = scene.isActive
        ? l10n.ledSceneStatusActive
        : scene.isEnabled
        ? l10n.ledSceneStatusEnabled
        : l10n.ledSceneStatusDisabled;
    final Color statusColor = scene.isActive
        ? AppColors.success
        : scene.isEnabled
        ? AppColors.success
        : AppColors.warning;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: isConnected
            ? () => _showComingSoon(context)
            : () => showBleGuardDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Row(
            children: [
              _SceneSwatch(palette: scene.palette),
              const SizedBox(width: AppDimensions.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            scene.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          label: Text(
                            statusLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      scene.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: onApply,
                        icon: Icon(
                          scene.isActive ? Icons.check : Icons.play_arrow,
                        ),
                        label: Text(
                          scene.isActive
                              ? l10n.ledSceneStatusActive
                              : l10n.actionApply,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
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

class _SceneSwatch extends StatelessWidget {
  final List<Color> palette;

  const _SceneSwatch({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
