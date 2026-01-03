import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';

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
                  title: l10n.ledScene, // @string/led_scene
                  // toolbar_two_action.xml 的 btn_left/btn_right 由 Activity 控制顯示
                  // UI parity only: 僅保留結構，不接行為。
                  //
                  // TODO(android @string/menu_delete): Android 可能顯示「刪除」動作
                  leftText: l10n.actionDelete,
                  // TODO(android @string/led_scene_add): Android 新增場景行為；此處僅結構占位
                  rightText: l10n.actionAdd,
                ),
                Expanded(
                  child: _SceneList(
                    dynamicTitle:
                        l10n.ledDynamicScene, // @string/led_dynamic_scene
                    staticTitle:
                        l10n.ledStaticScene, // @string/led_static_scene
                    dynamicScenes: controller.dynamicScenes,
                    staticScenes: controller.staticScenes,
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

/// Toolbar – mirrors `toolbar_two_action.xml` (white background + 2dp divider).
class _ToolbarTwoAction extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;

  const _ToolbarTwoAction({
    required this.title,
    required this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: [
                // Left: back icon area exists in toolbar_two_action.xml (btn_back 56x44)
                SizedBox(
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
                // Left text action (btn_left) placeholder
                TextButton(
                  onPressed: null,
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
                // Right text action (btn_right) placeholder
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: null,
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

  const _SceneList({
    required this.dynamicTitle,
    required this.staticTitle,
    required this.dynamicScenes,
    required this.staticScenes,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_led_scene paddingStart/Top/End/Bottom = 16/14/16/14dp
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
          return _StaticHeaderWithAdd(text: item.text!);
        }
        return _SceneTile(scene: item.scene!);
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

  const _StaticHeaderWithAdd({required this.text});

  @override
  Widget build(BuildContext context) {
    // PARITY: tv_static_scene + btn_add_scene (ic_add_btn, 24x24)
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
          // TODO(android @drawable/ic_add_btn): 若資源尚未移入，需補齊；此處僅結構占位
          CommonIconHelper.getAddRoundedIcon(
            size: 24,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

/// Scene tile – mirrors `adapter_scene.xml` (icon + name + play + favorite).
class _SceneTile extends StatelessWidget {
  final LedSceneSummary scene;

  const _SceneTile({required this.scene});

  @override
  Widget build(BuildContext context) {
    // adapter_scene.xml:
    // - MaterialCardView: marginTop 8dp, bg_aaa, corner 8dp, elevation 0
    // - Padding: start 8, top 6, end 12, bottom 6
    // - img_icon 24dp, tv_name body, btn_play 20dp, btn_favorite 20dp
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.surfaceMuted, // bg_aaa
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        child: Row(
          children: [
            // img_icon (24dp)
            // TODO(android @id/img_icon): Android uses scene icon drawable (e.g. ic_sunrise). Repo 內未完整映射。
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
            // btn_play (ic_play_unselect, 20dp)
            CommonIconHelper.getPlayUnselectIcon(
              size: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            // btn_favorite (ic_favorite_unselect, 20dp)
            CommonIconHelper.getFavoriteUnselectIcon(
              size: 20,
              color: AppColors.textPrimary,
            ),
          ],
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
