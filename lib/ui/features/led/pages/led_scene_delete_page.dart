import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/delete_scene_usecase.dart';
import '../../../components/ble_guard.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../../infrastructure/repositories/scene_repository_impl.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';

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

class _LedSceneDeleteView extends StatelessWidget {
  final bool isConnected;
  final DeleteSceneUseCase deleteSceneUseCase;

  const _LedSceneDeleteView({
    required this.isConnected,
    required this.deleteSceneUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedSceneListController>();
    final session = context.watch<AppSession>();
    final currentIsConnected = session.isBleConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledSceneDeleteTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        children: [
          Text(
            l10n.ledSceneDeleteDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ReefColors.textSecondary,
                ),
          ),
          const SizedBox(height: ReefSpacing.md),
          if (!currentIsConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: ReefSpacing.md),
          ],
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(ReefSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Show local scenes (from SceneRepositoryImpl)
            _buildLocalScenes(context, session, controller, currentIsConnected),
            const SizedBox(height: ReefSpacing.md),
            // Show device scenes (read-only, cannot delete)
            if (controller.staticScenes.isNotEmpty) ...[
              Text(
                l10n.ledSceneDeleteDeviceScenesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ReefSpacing.sm),
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
          padding: const EdgeInsets.all(ReefSpacing.xxl),
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
              padding: EdgeInsets.all(ReefSpacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(ReefSpacing.xxl),
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
            const SizedBox(height: ReefSpacing.sm),
            ...snapshot.data!.map(
              (scene) => _SceneDeleteCard(
                scene: scene,
                deviceId: deviceId,
                deleteSceneUseCase: deleteSceneUseCase,
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

class _SceneDeleteCard extends StatelessWidget {
  final _LocalSceneInfo scene;
  final String deviceId;
  final DeleteSceneUseCase deleteSceneUseCase;
  final bool isConnected;
  final VoidCallback onDeleted;

  const _SceneDeleteCard({
    required this.scene,
    required this.deviceId,
    required this.deleteSceneUseCase,
    required this.isConnected,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        title: Text(scene.name),
        subtitle: Text(l10n.ledSceneIdLabel(scene.sceneIdString)),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: ReefColors.danger),
          onPressed: isConnected
              ? () => _confirmDelete(context, l10n)
              : () => showBleGuardDialog(context),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
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
            style: TextButton.styleFrom(foregroundColor: ReefColors.danger),
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
            backgroundColor: ReefColors.danger,
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
                icon: Icon(Icons.delete, color: ReefColors.danger),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.ledSceneDeleteCannotDeleteDeviceScenes),
                      backgroundColor: ReefColors.warning,
                    ),
                  );
                },
              )
            : const Icon(Icons.info_outline, color: ReefColors.textSecondary),
      ),
    );
  }
}
