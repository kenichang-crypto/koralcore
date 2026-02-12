import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../device/presentation/pages/device_settings_page.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_scene_list_controller.dart';
import '../widgets/led_main_favorite_scene_card.dart';
import '../widgets/led_main_record_chart_section.dart';
import 'led_scene_list_page.dart';

/// LED main page.
///
/// PARITY target: Android `activity_led_main.xml`
class LedMainPage extends StatefulWidget {
  const LedMainPage({super.key});

  @override
  State<LedMainPage> createState() => _LedMainPageState();
}

class _LedMainPageState extends State<LedMainPage> {
  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

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
      child: _LedMainView(),
    );
  }
}

class _LedMainView extends StatelessWidget {
  const _LedMainView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedSceneListController>();

    // KC-A-FINAL: Redirect when active device was deleted (e.g. from Device tab).
    if (session.activeDeviceId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const SizedBox.shrink();
    }

    // Dynamic device display name is Android-parity data (not a string resource).
    final deviceName = session.activeDeviceName ?? l10n.ledDetailUnknownDevice;
    final isConnected = session.isBleConnected;

    // A–F: fixed blocks + only the scene list is scrollable.
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A. Toolbar (fixed) - toolbar_device.xml
                _ToolbarDevice(
                  title: deviceName,
                  onBack: () => Navigator.of(context).pop(),
                  onMenu: session.isReady
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DeviceSettingsPage(),
                            ),
                          )
                      : null,
                  onFavorite: session.isReady && !controller.isBusy
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LedSceneListPage(),
                            ),
                          )
                      : null,
                ),

                // B. Device identification section (fixed) - tv_name / btn_ble / tv_position / tv_group
                _DeviceIdentificationSection(
                  deviceName: deviceName,
                  isConnected: isConnected,
                  // TODO(android @id/tv_position): Android 顯示水槽位置（資料來源需從 session/repo 提供）
                  positionText: l10n.unassignedDevice,
                ),

                // C. Record / Preview card - reuses LedMainRecordChartSection for togglePreview
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: isConnected
                      ? LedMainRecordChartSection(
                          controller: controller,
                          isConnected: isConnected,
                          featuresEnabled: session.isReady,
                          l10n: l10n,
                          onToggleOrientation: () {}, // Main page: no orientation toggle
                          isLandscape: false,
                        )
                      : Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              l10n.homeStatusDisconnected,
                              style: AppTextStyles.bodyAccent.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),

                // D. Scene title row (fixed) - more navigates to scene list
                _SceneHeader(
                  title: l10n.ledScene,
                  onMore: session.isReady && !controller.isBusy
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LedSceneListPage(),
                            ),
                          )
                      : null,
                ),
                // E. Favorite scene list (only scrollable region)
                // PARITY: reef-b-app rv_favorite_scene – favorite scenes, clickable when connected.
                Expanded(
                  child: _FavoriteSceneArea(
                    controller: controller,
                    isConnected: isConnected,
                    featuresEnabled: session.isReady,
                    l10n: l10n,
                  ),
                ),
              ],
            ),

            // F. Progress overlay (full screen) - @layout/progress
            // PARITY: include is "gone" by default; show only when controller is busy.
            if (controller.isBusy) const _ProgressOverlay(),
          ],
        ),
      ),
    );
  }
}

/// A. Toolbar – mirrors `toolbar_device.xml` (white background + 2dp divider).
/// PARITY: back/menu/favorite buttons wired per UX Parity Principles (P4).
class _ToolbarDevice extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onFavorite;

  const _ToolbarDevice({
    required this.title,
    this.onBack,
    this.onMenu,
    this.onFavorite,
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
                // btn_back (56x44dp, padding 16/8/16/8)
                InkWell(
                  onTap: onBack,
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
                // Right actions: btn_menu + btn_favorite (both exist in toolbar_device.xml)
                // UI parity only: do not wire behavior.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: CommonIconHelper.getMenuIcon(
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: CommonIconHelper.getFavoriteUnselectIcon(
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
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

/// B. Device identification section – mirrors tv_name/btn_ble/tv_position/tv_group in `activity_led_main.xml`.
class _DeviceIdentificationSection extends StatelessWidget {
  final String deviceName;
  final bool isConnected;
  final String positionText;

  const _DeviceIdentificationSection({
    required this.deviceName,
    required this.isConnected,
    required this.positionText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Layout notes (activity_led_main.xml):
    // - tv_name: marginStart 16dp, marginTop 8dp, marginEnd 4dp
    // - btn_ble: 48x32dp, marginEnd 16dp, aligned with tv_name/tv_position
    // - tv_position: caption2, text_aaa
    // - tv_group exists but default is GONE
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    deviceName,
                    style: AppTextStyles.bodyAccent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              isConnected
                  ? CommonIconHelper.getConnectBackgroundIcon(
                      width: 48,
                      height: 32,
                    )
                  : CommonIconHelper.getDisconnectBackgroundIcon(
                      width: 48,
                      height: 32,
                    ),
            ],
          ),
          // tv_position + tv_group (tv_group 預設 visibility="gone")
          Row(
            children: [
              Text(
                positionText,
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // tv_group (visibility="gone" in Android XML, marginStart/End 4dp)
              // PARITY: 結構必須存在，預設不顯示
              // TODO(android @id/tv_group): 群組資訊來源待從 session/repo 提供
              Visibility(
                visible: false, // 預設 visibility="gone"
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.group, // PARITY: @string/group (reef tv_group)
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.textTertiary, // text_aa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// D. Scene title row – mirrors tv_scene_title + btn_scene_more.
class _SceneHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;

  const _SceneHeader({required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyAccent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: CommonIconHelper.getMoreEnableIcon(
              size: 24,
              color: onMore != null
                  ? AppColors.textPrimary
                  : AppColors.textPrimary.withValues(alpha: 0.5),
            ),
            onPressed: onMore,
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}

/// E. Favorite scene area – mirrors reef-b-app rv_favorite_scene.
/// FavoriteSceneAdapter.setEnabled(true) when connected; chips call onClickScene to apply.
class _FavoriteSceneArea extends StatelessWidget {
  final LedSceneListController controller;
  final bool isConnected;
  final bool featuresEnabled;
  final AppLocalizations l10n;

  const _FavoriteSceneArea({
    required this.controller,
    required this.isConnected,
    required this.featuresEnabled,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteScenes =
        controller.scenes.where((scene) => scene.isFavorite).toList();

    if (favoriteScenes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.ledFavoriteScenesSubtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // PARITY: rv_favorite_scene – horizontal LinearLayoutManager, padding 8dp
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < favoriteScenes.length; i++) ...[
            LedMainFavoriteSceneCard(
              scene: favoriteScenes[i],
              l10n: l10n,
              isConnected: isConnected,
              featuresEnabled: featuresEnabled,
              controller: controller,
            ),
            if (i < favoriteScenes.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// F. Progress overlay – mirrors `@layout/progress`.
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
