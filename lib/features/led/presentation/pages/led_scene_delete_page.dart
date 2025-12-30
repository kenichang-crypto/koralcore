import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/delete_scene_usecase.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../data/repositories/scene_repository_impl.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';
import '../helpers/support/scene_icon_helper.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// LedSceneDeletePage
///
/// Page for deleting LED scenes.
/// Currently only supports deleting local scenes (created via SceneRepositoryImpl).
class LedSceneDeletePage extends StatelessWidget {
  const LedSceneDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final appContext = context.read<AppContext>();
    final isConnected = session.isBleConnected;

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
      child: _LedSceneDeleteView(
        isConnected: isConnected,
        deleteSceneUseCase: appContext.deleteSceneUseCase,
      ),
    );
  }
}

class _LedSceneDeleteView extends StatefulWidget {
  final bool isConnected;
  final DeleteSceneUseCase deleteSceneUseCase;

  const _LedSceneDeleteView({
    required this.isConnected,
    required this.deleteSceneUseCase,
  });

  @override
  State<_LedSceneDeleteView> createState() => _LedSceneDeleteViewState();
}

class _LedSceneDeleteViewState extends State<_LedSceneDeleteView> {
  bool _previousBleConnected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // PARITY: reef-b-app disconnectLiveData.observe() → finish()
    // Monitor BLE connection state and close page on disconnect
    final session = context.watch<AppSession>();
    final isBleConnected = session.isBleConnected;
    
    // If BLE was connected but now disconnected, close page
    if (_previousBleConnected && !isBleConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
    _previousBleConnected = isBleConnected;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneListController>();
    final session = context.watch<AppSession>();
    final currentIsConnected = session.isBleConnected;

    return Scaffold(
      appBar: ReefAppBar(
        title: Text(l10n.ledSceneDeleteTitle),
      ),
      body: ListView(
        // PARITY: activity_led_scene_delete.xml rv_scene padding 16/12/16/12dp
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_16 paddingStart
          top: AppSpacing.sm, // dp_12 paddingTop
          right: AppSpacing.md, // dp_16 paddingEnd
          bottom: AppSpacing.sm, // dp_12 paddingBottom
        ),
        children: [
          Text(
            l10n.ledSceneDeleteDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!currentIsConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Show local scenes (from SceneRepositoryImpl)
            _buildLocalScenes(context, session, controller, currentIsConnected),
            const SizedBox(height: AppSpacing.md),
            // Show device scenes (read-only, cannot delete)
            if (controller.staticScenes.isNotEmpty) ...[
              Text(
                l10n.ledSceneDeleteDeviceScenesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...controller.staticScenes.map(
                (scene) => _SceneInfoCard(scene: scene, canDelete: false),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLocalScenes(
    BuildContext context,
    AppSession session,
    LedSceneListController controller,
    bool isConnected,
  ) {
    final l10n = AppLocalizations.of(context);
    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            l10n.ledSceneDeleteEmpty,
          ),
        ),
      );
    }

    return FutureBuilder<List<_LocalSceneInfo>>(
      future: _loadLocalScenes(deviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                l10n.ledSceneDeleteEmpty,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledSceneDeleteLocalScenesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...snapshot.data!.map(
              (scene) => _SceneDeleteCard(
                scene: scene,
                deviceId: deviceId,
                deleteSceneUseCase: widget.deleteSceneUseCase,
                controller: controller,
                isConnected: isConnected,
                onDeleted: () {
                  // Refresh the scene list
                  controller.refresh();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<_LocalSceneInfo>> _loadLocalScenes(String deviceId) async {
    final sceneRepository = SceneRepositoryImpl();
    final scenes = await sceneRepository.getScenes(deviceId);
    return scenes.map((scene) {
      return _LocalSceneInfo(
        sceneId: scene.sceneId, // Use sceneId (device-scoped ID), not id (database primary key)
        sceneIdString: 'local_scene_${scene.sceneId}',
        name: scene.name,
        iconId: scene.iconId,
      );
    }).toList();
  }
}

class _LocalSceneInfo {
  final int sceneId;
  final String sceneIdString;
  final String name;
  final int iconId;

  _LocalSceneInfo({
    required this.sceneId,
    required this.sceneIdString,
    required this.name,
    required this.iconId,
  });
}

/// Scene select card matching adapter_scene_select.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_scene_select.xml structure:
/// - MaterialCardView: marginTop 12dp, selectableItemBackground, bg_aaa background, cornerRadius 8dp, elevation 0dp
/// - Padding: 8/6/12/6dp
/// - img_icon: 24×24dp
/// - tv_name: body, text_aaaa, marginStart 8dp
/// - img_check: 20×20dp, visibility gone (for selection mode)
class _SceneDeleteCard extends StatelessWidget {
  final _LocalSceneInfo scene;
  final String deviceId;
  final DeleteSceneUseCase deleteSceneUseCase;
  final LedSceneListController controller;
  final bool isConnected;
  final VoidCallback onDeleted;

  const _SceneDeleteCard({
    required this.scene,
    required this.deviceId,
    required this.deleteSceneUseCase,
    required this.controller,
    required this.isConnected,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // PARITY: adapter_scene_select.xml structure
    return Card(
      margin: EdgeInsets.only(top: AppSpacing.md), // dp_12 marginTop
      color: AppColors.surfaceMuted, // bg_aaa background
      elevation: 0, // dp_0
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm), // dp_8 cornerRadius
      ),
      child: InkWell(
        onTap: isConnected
            ? () => _confirmDelete(context, l10n)
            : () => showBleGuardDialog(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xs, // dp_8 paddingStart
            top: AppSpacing.xxxs, // dp_6 paddingTop
            right: AppSpacing.md, // dp_12 paddingEnd
            bottom: AppSpacing.xxxs, // dp_6 paddingBottom
          ),
          child: Row(
            children: [
              // Scene icon (img_icon) - 24×24dp
              // PARITY: Use SceneIconHelper to get scene icons from SVG assets
              SceneIconHelper.getSceneIcon(
                iconId: scene.iconId,
                width: 24, // dp_24
                height: 24, // dp_24
                color: AppColors.textPrimary,
              ),
              SizedBox(width: AppSpacing.xs), // dp_8 marginStart
              // Scene name (tv_name) - body, text_aaaa
              Expanded(
                child: Text(
                  scene.name.isEmpty ? l10n.ledSceneNoSetting : scene.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Delete button (replacing img_check)
              IconButton(
                icon: CommonIconHelper.getDeleteIcon(size: 24, color: AppColors.danger),
                iconSize: 20, // dp_20
                onPressed: isConnected
                    ? () => _confirmDelete(context, l10n)
                    : () => showBleGuardDialog(context),
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

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    // PARITY: reef-b-app checks if scene is currently in use
    // Check if sceneIdString == controller.activeSceneId
    final activeSceneId = controller.activeSceneId;
    if (activeSceneId == scene.sceneIdString) {
      // PARITY: reef-b-app shows toast_delete_now_scene
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.toastDeleteNowScene),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ledSceneDeleteConfirmTitle),
        content: Text(
          l10n.ledSceneDeleteConfirmMessage(scene.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await deleteSceneUseCase.execute(
        deviceId: deviceId,
        sceneId: scene.sceneId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledSceneDeleteSuccess(scene.name),
            ),
          ),
        );
        onDeleted();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledSceneDeleteError,
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _SceneInfoCard extends StatelessWidget {
  final LedSceneSummary scene;
  final bool canDelete;

  const _SceneInfoCard({
    required this.scene,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        title: Text(scene.name),
        subtitle: Text(scene.isPreset ? l10n.ledScenePreset : l10n.ledSceneCustom),
        trailing: canDelete
            ? IconButton(
                icon: CommonIconHelper.getDeleteIcon(size: 24, color: AppColors.danger),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.ledSceneDeleteCannotDeleteDeviceScenes),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                },
              )
            : CommonIconHelper.getWarningIcon(
                size: 24,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }
}
