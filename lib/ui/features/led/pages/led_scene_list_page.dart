import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_backgrounds.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/ble_guard.dart';
import '../../../components/error_state_widget.dart';
import '../../../components/loading_state_widget.dart';
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
          appBar: ReefAppBar(
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
          body: ReefMainBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // PARITY: activity_led_scene.xml layout_led_scene padding 16/14/16/14dp
                  padding: EdgeInsets.only(
                    left: ReefSpacing.md, // dp_16 paddingStart
                    top: 14, // dp_14 paddingTop (not standard spacing)
                    right: ReefSpacing.md, // dp_16 paddingEnd
                    bottom: 14, // dp_14 paddingBottom (not standard spacing)
                  ),
                  children: [
                    Text(
                      l10n.ledScenesListSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ReefColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: ReefSpacing.md),
                    if (controller.currentChannelLevels.isNotEmpty) ...[
                      LedSpectrumChart.fromChannelMap(
                        controller.currentChannelLevels,
                        height: 72,
                        compact: true,
                        emptyLabel: l10n.ledControlEmptyState,
                      ),
                      const SizedBox(height: ReefSpacing.md),
                    ],
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      const SizedBox(height: ReefSpacing.xl),
                    ],
                    if (controller.isBusy)
                      const LoadingStateWidget.linear(),
                    if (controller.isLoading)
                      const LoadingStateWidget.inline()
                    else if (controller.scenes.isEmpty)
                      _ScenesEmptyState(l10n: l10n)
                    else ...[
                      // Dynamic Scenes Section
                      if (controller.dynamicScenes.isNotEmpty) ...[
                        Text(
                          l10n.ledDynamicScene,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ReefColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: ReefSpacing.xs),
                        ...controller.dynamicScenes.map(
                          (scene) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: ReefSpacing.sm,
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
                        const SizedBox(height: ReefSpacing.md),
                      ],
                      // Static Scenes Section
                      if (controller.staticScenes.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.ledStaticScene,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ReefColors.textSecondary,
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
                        const SizedBox(height: ReefSpacing.xs),
                        ...controller.staticScenes.map(
                          (scene) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: ReefSpacing.sm,
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

  showErrorSnackBar(context, code);
  controller.clearError();
}

void _maybeShowEvent(BuildContext context, LedSceneListController controller) {
  final event = controller.consumeEvent();
  if (event == null) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  switch (event.type) {
    case LedSceneEventType.applySuccess:
      showSuccessSnackBar(context, l10n.ledScenesSnackApplied);
      break;
    case LedSceneEventType.applyFailure:
      final code = event.errorCode ?? AppErrorCode.unknownError;
      showErrorSnackBar(context, code);
      break;
  }
}

class _ScenesEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _ScenesEmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_ledIconAsset, width: 32, height: 32),
            const SizedBox(height: ReefSpacing.sm),
            Text(l10n.ledScenesEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: ReefSpacing.xs),
            Text(
              l10n.ledScenesEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ReefColors.textSecondary,
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
    final bool isActive = scene.isActive;
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final IconData sceneIcon = _sceneIcon(scene.iconKey, scene.isPreset);

    // PARITY: adapter_scene.xml structure
    // MaterialCardView: bg_aaa, cornerRadius 8dp, elevation 0
    // padding: 8/6/12/6dp
    // Contains: icon (24×24dp), name (body, text_aaaa), play button (20×20dp), favorite button (20×20dp)
    return Card(
      color: ReefColors.surfaceMuted, // bg_aaa
      elevation: 0, // dp_0
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefSpacing.xs), // dp_8
        side: BorderSide(
          color: isActive ? ReefColors.primary : Colors.transparent,
          width: isActive ? 2 : 0, // strokeWidth 2 when active
        ),
      ),
      margin: EdgeInsets.only(top: ReefSpacing.xs), // dp_8 marginTop
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ReefSpacing.xs),
        child: Padding(
          padding: EdgeInsets.only(
            left: ReefSpacing.xs, // dp_8 paddingStart
            top: ReefSpacing.sm, // dp_6 paddingTop
            right: ReefSpacing.md, // dp_12 paddingEnd
            bottom: ReefSpacing.sm, // dp_6 paddingBottom
          ),
          child: Row(
            children: [
              // Icon (img_icon) - 24×24dp
              SizedBox(
                width: 24, // dp_24
                height: 24, // dp_24
                child: Icon(
                  sceneIcon,
                  size: 24,
                  color: ReefColors.textPrimary,
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
              // Name (tv_name) - body, text_aaaa
              Expanded(
                child: Text(
                  sceneName,
                  style: ReefTextStyles.body.copyWith(
                    color: ReefColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
              // Play button (btn_play) - 20×20dp
              IconButton(
                icon: Image.asset(
                  isActive
                      ? 'assets/icons/ic_play_select.png' // TODO: Add icon asset
                      : 'assets/icons/ic_play_unselect.png', // TODO: Add icon asset
                  width: 20, // dp_20
                  height: 20, // dp_20
                  errorBuilder: (context, error, stackTrace) => Icon(
                    isActive ? Icons.play_arrow : Icons.play_arrow_outlined,
                    size: 20,
                    color: ReefColors.textPrimary,
                  ),
                ),
                onPressed: onApply,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
              ),
              SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
              // Favorite button (btn_favorite) - 20×20dp
              if (isConnected && !controller.isBusy)
                IconButton(
                  icon: Image.asset(
                    scene.isFavorite
                        ? 'assets/icons/ic_favorite_select.png' // TODO: Add icon asset
                        : 'assets/icons/ic_favorite_unselect.png', // TODO: Add icon asset
                    width: 20, // dp_20
                    height: 20, // dp_20
                    errorBuilder: (context, error, stackTrace) => Icon(
                      scene.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: scene.isFavorite
                          ? ReefColors.danger
                          : ReefColors.textTertiary,
                    ),
                  ),
                  onPressed: () => controller.toggleFavoriteScene(scene.id),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
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
        : const <Color>[ReefColors.primary, ReefColors.primaryOverlay];
    final List<Color> gradientColors = colors.length == 1
        ? <Color>[colors.first, colors.first.withOpacity(0.7)]
        : colors;

    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReefRadius.md),
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
      spacing: ReefSpacing.xs,
      runSpacing: ReefSpacing.xxxs,
      children: stats
          .map(
            (stat) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ReefSpacing.xs,
                vertical: ReefSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(ReefRadius.sm),
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
