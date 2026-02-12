import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_edit_controller.dart';
import '../controllers/led_scene_list_controller.dart';
import '../helpers/support/scene_icon_helper.dart';
import '../models/led_scene_summary.dart';
import 'led_scene_add_page.dart';
import 'led_scene_delete_page.dart';
import 'led_scene_edit_page.dart';

/// LedScenePage
///
/// Android parity target:
/// - Activity: LedSceneActivity
/// - Layout: activity_led_scene.xml
/// - Toolbar: @layout/toolbar_two_action
/// - Scene item: adapter_scene.xml
/// - Progress: @layout/progress
///
/// Gate: UI parity only (no onTap/onPressed/navigation/BLE/business behavior).
class LedScenePage extends StatelessWidget {
  const LedScenePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    // NOTE: 不在此呼叫 initialize()/refresh() 以避免業務副作用；僅做 UI 結構 parity。
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
      ),
      child: const _LedSceneView(),
    );
  }
}

class _LedSceneView extends StatelessWidget {
  const _LedSceneView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneListController>();

    // A. Toolbar (fixed)
    // B. ListView.builder (唯一可捲動)
    // C. Progress overlay
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ToolbarTwoAction(
                  title: l10n.ledScene,
                  leftText: l10n.actionDelete,
                  rightText: l10n.actionAdd,
                  controller: controller,
                  onBack: () => Navigator.of(context).pop(),
                  onLeft: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LedSceneDeletePage(
                        listController: controller,
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) controller.refresh();
                  }),
                  onRight: () {
                    if (controller.staticScenes.length >= 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.ledSceneLimitReached)),
                      );
                      return;
                    }
                    final appContext = context.read<AppContext>();
                    final session = context.read<AppSession>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChangeNotifierProvider(
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
                    ).then((_) {
                      if (context.mounted) controller.refresh();
                    });
                  },
                ),
                Expanded(
                  child: _SceneList(
                    dynamicTitle: l10n.ledDynamicScene,
                    staticTitle: l10n.ledStaticScene,
                    dynamicScenes: controller.dynamicScenes,
                    staticScenes: controller.staticScenes,
                    controller: controller,
                    onAddScene: () {
                      if (controller.staticScenes.length >= 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.ledSceneLimitReached)),
                        );
                        return;
                      }
                      final appContext = context.read<AppContext>();
                      final session = context.read<AppSession>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
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
                      ).then((_) {
                        if (context.mounted) controller.refresh();
                      });
                    },
                  ),
                ),
              ],
            ),
            if (controller.isLoading) const _ProgressOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Toolbar – mirrors `toolbar_two_action.xml` (PARITY: btnBack, btnEdit, btnAddScene).
class _ToolbarTwoAction extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;
  final LedSceneListController controller;
  final VoidCallback onBack;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _ToolbarTwoAction({
    required this.title,
    required this.leftText,
    required this.rightText,
    required this.controller,
    required this.onBack,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.isLoading && !controller.isBusy;
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 56,
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: CommonIconHelper.getBackIcon(
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: enabled ? onLeft : null,
                  child: Text(
                    leftText,
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.primaryStrong,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: enabled ? onRight : null,
                    child: Text(
                      rightText,
                      style: AppTextStyles.bodyAccent.copyWith(
                        color: AppColors.primaryStrong,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 2, color: AppColors.surfacePressed),
        ],
      ),
    );
  }
}

/// Scene list – single scrollable region.
///
/// Android `activity_led_scene.xml` has two RecyclerViews (dynamic/static) with titles; we keep the XML order
/// inside one ListView to satisfy "only list scrolls".
class _SceneList extends StatelessWidget {
  final String dynamicTitle;
  final String staticTitle;
  final List<LedSceneSummary> dynamicScenes;
  final List<LedSceneSummary> staticScenes;
  final LedSceneListController controller;
  final VoidCallback onAddScene;

  const _SceneList({
    required this.dynamicTitle,
    required this.staticTitle,
    required this.dynamicScenes,
    required this.staticScenes,
    required this.controller,
    required this.onAddScene,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_SceneListItem>[
      _SceneListItem.sectionTitle(dynamicTitle),
      for (final s in dynamicScenes) _SceneListItem.scene(s),
      _SceneListItem.sectionHeaderWithAdd(staticTitle),
      for (final s in staticScenes) _SceneListItem.scene(s),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.kind == _SceneListItemKind.sectionTitle) {
          return _SectionTitle(text: item.text!);
        }
        if (item.kind == _SceneListItemKind.sectionHeaderWithAdd) {
          return _StaticHeaderWithAdd(text: item.text!, onAdd: onAddScene);
        }
        return _SceneTile(scene: item.scene!, controller: controller);
      },
    );
  }
}

enum _SceneListItemKind { sectionTitle, sectionHeaderWithAdd, scene }

class _SceneListItem {
  final _SceneListItemKind kind;
  final String? text;
  final LedSceneSummary? scene;

  const _SceneListItem._(this.kind, {this.text, this.scene});

  factory _SceneListItem.sectionTitle(String text) =>
      _SceneListItem._(_SceneListItemKind.sectionTitle, text: text);

  factory _SceneListItem.sectionHeaderWithAdd(String text) =>
      _SceneListItem._(_SceneListItemKind.sectionHeaderWithAdd, text: text);

  factory _SceneListItem.scene(LedSceneSummary scene) =>
      _SceneListItem._(_SceneListItemKind.scene, scene: scene);
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyAccent.copyWith(color: AppColors.textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StaticHeaderWithAdd extends StatelessWidget {
  final String text;
  final VoidCallback onAdd;

  const _StaticHeaderWithAdd({required this.text, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyAccent.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: CommonIconHelper.getAddRoundedIcon(
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scene tile – mirrors `adapter_scene.xml` (PARITY: onClickScene, onClickPlayScene, onClickFavoriteScene).
class _SceneTile extends StatelessWidget {
  final LedSceneSummary scene;
  final LedSceneListController controller;

  const _SceneTile({required this.scene, required this.controller});

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.isLoading && !controller.isBusy;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.surfaceMuted,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: enabled
            ? () {
                final appContext = context.read<AppContext>();
                final session = context.read<AppSession>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => LedSceneEditController(
                        session: session,
                        addSceneUseCase: appContext.addSceneUseCase,
                        updateSceneUseCase: appContext.updateSceneUseCase,
                        enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
                        exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
                        setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
                        applySceneUseCase: appContext.applySceneUseCase,
                        initialSceneId: SceneIconHelper.parseLocalSceneId(scene.id),
                        initialName: scene.name,
                        initialChannelLevels: Map.from(scene.channelLevels),
                        initialIconId: SceneIconHelper.iconKeyToId(scene.iconKey),
                      ),
                      child: LedSceneEditPage(sceneId: scene.id),
                    ),
                  ),
                ).then((_) {
                  if (context.mounted) controller.refresh();
                });
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scene.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: enabled ? () => controller.applyScene(scene.id) : null,
                behavior: HitTestBehavior.opaque,
                child: CommonIconHelper.getPlayUnselectIcon(
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: enabled ? () => controller.toggleFavoriteScene(scene.id) : null,
                behavior: HitTestBehavior.opaque,
                child: CommonIconHelper.getFavoriteUnselectIcon(
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress overlay – mirrors `progress.xml` (default hidden).
class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: const Color(0x4D000000),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
