import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/reef_blocking_overlay.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';
import '../helpers/support/scene_channel_helper.dart';
import '../helpers/support/scene_display_text.dart';
import '../helpers/support/scene_icon_helper.dart';
import '../widgets/led_spectrum_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../controllers/led_scene_edit_controller.dart';
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

class _LedSceneListView extends StatefulWidget {
  const _LedSceneListView();

  @override
  State<_LedSceneListView> createState() => _LedSceneListViewState();
}

class _LedSceneListViewState extends State<_LedSceneListView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // PARITY: reef-b-app LedSceneActivity.onResume() - refresh data when page becomes visible
    if (state == AppLifecycleState.resumed) {
      final controller = context.read<LedSceneListController>();
      // Refresh all data to ensure it's up to date
      controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedSceneListController>(
      builder: (context, session, controller, _) {
        final isConnected = session.isBleConnected;
        final isReady = session.isReady;
        final theme = Theme.of(context);
        _maybeShowError(context, controller);
        _maybeShowEvent(context, controller);

        return Scaffold(
          appBar: ReefAppBar(
            title: Text(l10n.ledScenesListTitle),
            actions: [
              // Edit button (進入刪除場景頁面)
              IconButton(
                icon: CommonIconHelper.getEditIcon(size: 24),
                tooltip: l10n.ledScenesActionEdit,
                onPressed: isReady && !controller.isBusy
                    ? () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => LedSceneDeletePage(
                              listController: controller,
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          controller.refresh();
                        }
                      }
                    : null,
              ),
            ],
          ),
          floatingActionButton: isReady && !controller.isBusy
              ? FloatingActionButton(
                  onPressed: () async {
                    final appContext = context.read<AppContext>();
                    final session = context.read<AppSession>();
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (ctx) => ChangeNotifierProvider<LedSceneEditController>(
                          create: (_) => LedSceneEditController(
                            session: session,
                            addSceneUseCase: appContext.addSceneUseCase,
                            updateSceneUseCase: appContext.updateSceneUseCase,
                            enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
                            exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
                            setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
                            applySceneUseCase: appContext.applySceneUseCase,
                          ),
                          child: const LedSceneAddPage(),
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      controller.refresh();
                    }
                  },
                  child: CommonIconHelper.getAddIcon(
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : null,
          body: Stack(
            children: [
              ReefMainBackground(
                child: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // PARITY: activity_led_scene.xml layout_led_scene padding 16/14/16/14dp
                      padding: EdgeInsets.only(
                        left: AppSpacing.md, // dp_16 paddingStart
                        top: 14, // dp_14 paddingTop (not standard spacing)
                        right: AppSpacing.md, // dp_16 paddingEnd
                        bottom:
                            14, // dp_14 paddingBottom (not standard spacing)
                      ),
                      children: [
                        Text(
                          l10n.ledScenesListSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (controller.currentChannelLevels.isNotEmpty) ...[
                          LedSpectrumChart.fromChannelMap(
                            controller.currentChannelLevels,
                            height: 72,
                            compact: true,
                            emptyLabel: l10n.ledControlEmptyState,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (!isConnected) ...[
                          const BleGuardBanner(),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        // PARITY: Use ReefBlockingOverlay instead of inline linear progress
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
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ...controller.dynamicScenes.map(
                              (scene) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _SceneCard(
                                  scene: scene,
                                  l10n: l10n,
                                  channelCount:
                                      controller.currentChannelLevels.length,
                                  isConnected: isConnected,
                                  isReady: isReady,
                                  controller: controller,
                                  onApply:
                                      session.isReady &&
                                          !controller.isBusy &&
                                          scene.isEnabled &&
                                          !scene.isActive
                                      ? () => controller.applyScene(scene.id)
                                      : null,
                                  // PARITY: reef-b-app - preset scenes (sceneId != null) cannot be edited
                                  // Only custom scenes (sceneId == null) can be edited
                                  onTap:
                                      (isReady &&
                                          !controller.isBusy &&
                                          !scene.isPreset)
                                      ? () async {
                                          final appContext = context.read<AppContext>();
                                          final session = context.read<AppSession>();
                                          final dbSceneId = SceneIconHelper.parseLocalSceneId(scene.id);
                                          final result = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (ctx) => ChangeNotifierProvider<LedSceneEditController>(
                                                create: (_) => LedSceneEditController(
                                                  session: session,
                                                  addSceneUseCase: appContext.addSceneUseCase,
                                                  updateSceneUseCase: appContext.updateSceneUseCase,
                                                  enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
                                                  exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
                                                  setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
                                                  applySceneUseCase: appContext.applySceneUseCase,
                                                  initialSceneId: dbSceneId,
                                                  initialName: scene.name,
                                                  initialChannelLevels: Map.from(scene.channelLevels),
                                                  initialIconId: SceneIconHelper.iconKeyToId(scene.iconKey),
                                                ),
                                                child: LedSceneEditPage(sceneId: scene.id),
                                              ),
                                            ),
                                          );
                                          if (result == true && context.mounted) {
                                            controller.refresh();
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          // Static Scenes Section
                          if (controller.staticScenes.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.ledStaticScene,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isReady && !controller.isBusy)
                                  IconButton(
                                    icon: CommonIconHelper.getAddIcon(size: 24),
                                    tooltip: l10n.ledScenesActionAdd,
                                    onPressed: () async {
                                      final appContext = context.read<AppContext>();
                                      final session = context.read<AppSession>();
                                      final result = await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (ctx) => ChangeNotifierProvider<LedSceneEditController>(
                                            create: (_) => LedSceneEditController(
                                              session: session,
                                              addSceneUseCase: appContext.addSceneUseCase,
                                              updateSceneUseCase: appContext.updateSceneUseCase,
                                              enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
                                              exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
                                              setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
                                              applySceneUseCase: appContext.applySceneUseCase,
                                            ),
                                            child: const LedSceneAddPage(),
                                          ),
                                        ),
                                      );
                                      if (result == true && context.mounted) {
                                        controller.refresh();
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ...controller.staticScenes.map(
                              (scene) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _SceneCard(
                                  scene: scene,
                                  l10n: l10n,
                                  channelCount:
                                      controller.currentChannelLevels.length,
                                  isConnected: isConnected,
                                  isReady: isReady,
                                  controller: controller,
                                  onApply:
                                      session.isReady &&
                                          !controller.isBusy &&
                                          scene.isEnabled &&
                                          !scene.isActive
                                      ? () => controller.applyScene(scene.id)
                                      : null,
                                  // PARITY: reef-b-app - preset scenes (sceneId != null) cannot be edited
                                  // Only custom scenes (sceneId == null) can be edited
                                  onTap:
                                      (isReady &&
                                          !controller.isBusy &&
                                          !scene.isPreset)
                                      ? () async {
                                          final appContext = context.read<AppContext>();
                                          final session = context.read<AppSession>();
                                          final dbSceneId = SceneIconHelper.parseLocalSceneId(scene.id);
                                          final result = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (ctx) => ChangeNotifierProvider<LedSceneEditController>(
                                                create: (_) => LedSceneEditController(
                                                  session: session,
                                                  addSceneUseCase: appContext.addSceneUseCase,
                                                  updateSceneUseCase: appContext.updateSceneUseCase,
                                                  enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
                                                  exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
                                                  setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
                                                  applySceneUseCase: appContext.applySceneUseCase,
                                                  initialSceneId: dbSceneId,
                                                  initialName: scene.name,
                                                  initialChannelLevels: Map.from(scene.channelLevels),
                                                  initialIconId: SceneIconHelper.iconKeyToId(scene.iconKey),
                                                ),
                                                child: LedSceneEditPage(sceneId: scene.id),
                                              ),
                                            ),
                                          );
                                          if (result == true && context.mounted) {
                                            controller.refresh();
                                          }
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
              if (controller.isBusy) const ReefBlockingOverlay(),
            ],
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_ledIconAsset, width: 32, height: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.ledScenesEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.ledScenesEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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
  final bool isReady;
  final LedSceneListController controller;

  const _SceneCard({
    required this.scene,
    required this.l10n,
    required this.channelCount,
    this.onApply,
    this.onTap,
    required this.isConnected,
    required this.isReady,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = scene.isActive;
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final Widget sceneIcon = _sceneIcon(scene.iconKey, scene.isPreset);

    // PARITY: adapter_scene.xml structure
    // MaterialCardView: bg_aaa, cornerRadius 8dp, elevation 0
    // padding: 8/6/12/6dp
    // Contains: icon (24×24dp), name (body, text_aaaa), play button (20×20dp), favorite button (20×20dp)
    return Card(
      color: AppColors.surfaceMuted, // bg_aaa
      elevation: 0, // dp_0
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs), // dp_8
        side: BorderSide(
          color: isActive ? AppColors.primary : Colors.transparent,
          width: isActive ? 2 : 0, // strokeWidth 2 when active
        ),
      ),
      margin: EdgeInsets.only(top: AppSpacing.xs), // dp_8 marginTop
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xs, // dp_8 paddingStart
            top: AppSpacing.sm, // dp_6 paddingTop
            right: AppSpacing.md, // dp_12 paddingEnd
            bottom: AppSpacing.sm, // dp_6 paddingBottom
          ),
          child: Row(
            children: [
              // Icon (img_icon) - 24×24dp
              SizedBox(
                width: 24, // dp_24
                height: 24, // dp_24
                child: sceneIcon,
              ),
              SizedBox(width: AppSpacing.xs), // dp_8 marginStart
              // Name (tv_name) - body, text_aaaa
              Expanded(
                child: Text(
                  sceneName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.xs), // dp_8 marginStart
              // Play button (btn_play) - 20×20dp
              // PARITY: reef-b-app ic_play_select / ic_play_unselect
              IconButton(
                icon: SvgPicture.asset(
                  isActive
                      ? 'assets/icons/ic_play_select.svg'
                      : 'assets/icons/ic_play_unselect.svg',
                  width: 20, // dp_20
                  height: 20, // dp_20
                  placeholderBuilder: (context) => isActive
                      ? CommonIconHelper.getPlaySelectIcon(size: 20)
                      : CommonIconHelper.getPlayUnselectIcon(size: 20),
                ),
                onPressed: onApply,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 20, minHeight: 20),
              ),
              SizedBox(width: AppSpacing.xs), // dp_8 marginStart
              // Favorite button (btn_favorite) - 20×20dp
              // PARITY: reef-b-app ic_favorite_select / ic_favorite_unselect
              if (isReady && !controller.isBusy)
                IconButton(
                  icon: SvgPicture.asset(
                    scene.isFavorite
                        ? 'assets/icons/ic_favorite_select.svg'
                        : 'assets/icons/ic_favorite_unselect.svg',
                    width: 20, // dp_20
                    height: 20, // dp_20
                    placeholderBuilder: (context) => scene.isFavorite
                        ? CommonIconHelper.getFavoriteSelectIcon(size: 20)
                        : CommonIconHelper.getFavoriteUnselectIcon(size: 20),
                  ),
                  onPressed: () => controller.toggleFavoriteScene(scene.id),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                ),
            ],
          ),
        ),
      ),
    );
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
        : const <Color>[AppColors.primary, AppColors.primaryOverlay];
    final List<Color> gradientColors = colors.length == 1
        ? <Color>[colors.first, colors.first.withValues(alpha: 0.7)]
        : colors;

    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                // TODO(L3): Icons.auto_awesome is indicator for dynamic scenes
                // Android doesn't have this overlay icon, it uses scene icon directly
                // VIOLATION: Material Icon not in Android
                Icons.auto_awesome,
                size: 16,
                color: Colors.white.withValues(alpha: 0.85),
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
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xxxs,
      children: stats
          .map(
            (stat) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
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

// PARITY: Use SceneIconHelper to get scene icons from SVG assets
// This replaces the Material Icons mapping with actual SVG assets from reef-b-app
Widget _sceneIcon(String? iconKey, bool isPreset) {
  if (iconKey != null) {
    return SceneIconHelper.getSceneIconByKey(
      iconKey: iconKey,
      width: 24,
      height: 24,
    );
  }
  // Fallback for preset or custom scenes without iconKey
  return Icon(
    // TODO(L3): Icons.auto_awesome_motion and Icons.pie_chart_outline are fallbacks
    // Android uses getSceneIconById() to load drawable resources
    // VIOLATION: Material Icons not in Android
    isPreset ? Icons.auto_awesome_motion : Icons.pie_chart_outline,
    size: 24,
  );
}
