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
import '../support/scene_channel_helper.dart';
import '../support/scene_display_text.dart';
import '../widgets/led_spectrum_chart.dart';
import 'led_scene_add_page.dart';
import 'led_scene_edit_page.dart';
import 'led_scene_delete_page.dart';

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
        observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
        readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
        startLedPreviewUseCase: appContext.startLedPreviewUseCase,
        startLedRecordUseCase: appContext.startLedRecordUseCase,
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
          appBar: AppBar(
            title: Text(l10n.ledScenesListTitle),
            actions: [
              // Edit button (進入刪除場景頁面)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: l10n.ledScenesActionEdit,
                onPressed: isConnected && !controller.isBusy
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LedSceneDeletePage(),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
          floatingActionButton: isConnected && !controller.isBusy
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LedSceneAddPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
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
                else ...[
                  // Dynamic Scenes Section
                  if (controller.dynamicScenes.isNotEmpty) ...[
                    Text(
                      l10n.ledDynamicScene,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    ...controller.dynamicScenes.map(
                      (scene) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingM,
                        ),
                        child: _SceneCard(
                          scene: scene,
                          l10n: l10n,
                          channelCount: controller.currentChannelLevels.length,
                          isConnected: isConnected,
                          controller: controller,
                          onApply:
                              isConnected &&
                                  !controller.isBusy &&
                                  scene.isEnabled &&
                                  !scene.isActive
                              ? () => controller.applyScene(scene.id)
                              : null,
                          onTap: isConnected && !controller.isBusy
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LedSceneEditPage(sceneId: scene.id),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                  // Static Scenes Section
                  if (controller.staticScenes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.ledStaticScene,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isConnected && !controller.isBusy)
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: l10n.ledScenesActionAdd,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LedSceneAddPage(),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    ...controller.staticScenes.map(
                      (scene) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingM,
                        ),
                        child: _SceneCard(
                          scene: scene,
                          l10n: l10n,
                          channelCount: controller.currentChannelLevels.length,
                          isConnected: isConnected,
                          controller: controller,
                          onApply:
                              isConnected &&
                                  !controller.isBusy &&
                                  scene.isEnabled &&
                                  !scene.isActive
                              ? () => controller.applyScene(scene.id)
                              : null,
                          onTap: isConnected && !controller.isBusy
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LedSceneEditPage(sceneId: scene.id),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
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
  final AppLocalizations l10n;
  final int channelCount;
  final VoidCallback? onApply;
  final VoidCallback? onTap;
  final bool isConnected;
  final LedSceneListController controller;

  const _SceneCard({
    required this.scene,
    required this.l10n,
    required this.channelCount,
    this.onApply,
    this.onTap,
    required this.isConnected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = scene.isActive;
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final String sceneDescription = LedSceneDisplayText.description(
      scene,
      l10n,
    );
    final String statusLabel = isActive
        ? l10n.ledSceneStatusActive
        : scene.isEnabled
        ? l10n.ledSceneStatusEnabled
        : l10n.ledSceneStatusDisabled;
    final Color statusColor = isActive
        ? AppColors.success
        : scene.isEnabled
        ? AppColors.success
        : AppColors.warning;
    final Color badgeBackground = statusColor.withOpacity(
      isActive ? 0.2 : 0.12,
    );
    final String typeLabel = _sceneTypeLabel(scene);
    final String channelLabel = l10n.ledSceneChannelCount(channelCount);
    final IconData sceneIcon = _sceneIcon(scene.iconKey, scene.isPreset);
    final List<SceneChannelStat> channelStats = buildSceneChannelStats(
      scene,
      l10n,
    );

    return Card(
      color: isActive ? AppColors.ocean100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(
          color: isActive ? AppColors.ocean500 : AppColors.grey200,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Row(
          children: [
            _SceneSwatch(
              palette: scene.palette,
              icon: sceneIcon,
              isDynamic: scene.isDynamic,
            ),
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
                          sceneName,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        backgroundColor: badgeBackground,
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
                    sceneDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Wrap(
                    spacing: AppDimensions.spacingS,
                    runSpacing: AppDimensions.spacingXS,
                    children: [
                      Text(
                        typeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        channelLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  if (channelStats.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    _ChannelBadges(
                      stats: channelStats,
                      textColor: AppColors.grey800,
                      backgroundColor: AppColors.grey100,
                    ),
                  ],
                  if (isActive) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      l10n.ledSceneCurrentlyRunning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingS),
                  Row(
                    children: [
                      OutlinedButton.icon(
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
                      const SizedBox(width: AppDimensions.spacingS),
                      // Favorite button
                      if (isConnected && !controller.isBusy)
                        IconButton(
                          icon: Icon(
                            scene.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: scene.isFavorite
                                ? AppColors.error
                                : AppColors.grey500,
                          ),
                          tooltip: scene.isFavorite
                              ? l10n.ledScenesActionUnfavorite
                              : l10n.ledScenesActionFavorite,
                          onPressed: () => controller.toggleFavoriteScene(scene.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _sceneTypeLabel(LedSceneSummary scene) {
    return scene.isPreset ? l10n.ledScenePreset : l10n.ledSceneCustom;
  }
}

class _SceneSwatch extends StatelessWidget {
  final List<Color> palette;
  final IconData icon;
  final bool isDynamic;

  const _SceneSwatch({
    required this.palette,
    required this.icon,
    required this.isDynamic,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = palette.isNotEmpty
        ? palette
        : const <Color>[AppColors.ocean500, AppColors.ocean300];
    final List<Color> gradientColors = colors.length == 1
        ? <Color>[colors.first, colors.first.withOpacity(0.7)]
        : colors;

    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: 28, color: Colors.white)),
          if (isDynamic)
            Positioned(
              right: 6,
              bottom: 6,
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChannelBadges extends StatelessWidget {
  final List<SceneChannelStat> stats;
  final Color textColor;
  final Color backgroundColor;

  const _ChannelBadges({
    required this.stats,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingXS,
      children: stats
          .map(
            (stat) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: AppDimensions.spacingXS,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                '${stat.label} ${stat.value}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

IconData _sceneIcon(String? iconKey, bool isPreset) {
  switch (iconKey) {
    case 'ic_moon':
      return Icons.nightlight_round;
    case 'ic_thunder':
      return Icons.bolt;
    case 'ic_none':
      return Icons.light_mode;
    case 'ic_custom':
      return Icons.tune;
  }
  return isPreset ? Icons.auto_awesome_motion : Icons.pie_chart_outline;
}
