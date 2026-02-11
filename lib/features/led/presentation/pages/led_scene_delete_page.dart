import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../controllers/led_scene_list_controller.dart';
import '../helpers/support/scene_display_text.dart';
import '../helpers/support/scene_icon_helper.dart';
import '../models/led_scene_summary.dart';

/// LedSceneDeletePage
///
/// Parity with reef-b-app LedSceneDeleteActivity (activity_led_scene_delete.xml)
class LedSceneDeletePage extends StatelessWidget {
  const LedSceneDeletePage({
    super.key,
    required this.listController,
  });

  final LedSceneListController listController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LedSceneListController>.value(
      value: listController,
      child: const _LedSceneDeleteView(),
    );
  }
}

class _LedSceneDeleteView extends StatefulWidget {
  const _LedSceneDeleteView();

  @override
  State<_LedSceneDeleteView> createState() => _LedSceneDeleteViewState();
}

class _LedSceneDeleteViewState extends State<_LedSceneDeleteView> {
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listController = context.watch<LedSceneListController>();
    final session = context.read<AppSession>();
    final appContext = context.read<AppContext>();
    final isReady = session.isReady;

    final customScenes =
        listController.scenes.where((s) => !s.isPreset).toList(growable: false);

    return Stack(
      children: [
        Column(
          children: [
            _ToolbarTwoAction(
              l10n: l10n,
              listController: listController,
              session: session,
              selectedIds: _selectedIds,
              onCancel: () => Navigator.of(context).pop(),
              onDelete: () async {
                final deviceId = session.activeDeviceId;
                if (deviceId == null || _selectedIds.isEmpty) return;
                setState(() => _isDeleting = true);
                final deleteUseCase = appContext.deleteSceneUseCase;
                try {
                  for (final id in _selectedIds) {
                    final dbId = SceneIconHelper.parseLocalSceneId(id);
                    if (dbId != null) {
                      await deleteUseCase.execute(
                        deviceId: deviceId,
                        sceneId: dbId,
                      );
                    }
                  }
                  if (mounted) Navigator.of(context).pop(true);
                } catch (_) {
                  if (mounted) {
                    showErrorSnackBar(context, AppErrorCode.unknownError);
                  }
                } finally {
                  if (mounted) setState(() => _isDeleting = false);
                }
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: listController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customScenes.isEmpty
                        ? Center(
                            child: Text(
                              l10n.ledScenesEmptySubtitle,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView(
                            children: customScenes
                                .map(
                                  (scene) => _SceneSelectTile(
                                    scene: scene,
                                    l10n: l10n,
                                    isSelected: _selectedIds.contains(scene.id),
                                    isEnabled: isReady,
                                    onTap: () {
                                      setState(() {
                                        if (_selectedIds.contains(scene.id)) {
                                          _selectedIds.remove(scene.id);
                                        } else {
                                          _selectedIds.add(scene.id);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
              ),
            ),
          ],
        ),
        if (_isDeleting) const _ProgressOverlay(),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({
    required this.l10n,
    required this.listController,
    required this.session,
    required this.selectedIds,
    required this.onCancel,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final LedSceneListController listController;
  final AppSession session;
  final Set<String> selectedIds;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canDelete =
        session.isReady && !listController.isBusy && selectedIds.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              TextButton(
                onPressed: listController.isLoading ? null : onCancel,
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.ledSceneDeleteTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: canDelete ? onDelete : null,
                child: Text(
                  l10n.actionDelete,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B. Scene list items ↔ adapter_scene_select.xml
// ────────────────────────────────────────────────────────────────────────────

class _SceneSelectTile extends StatelessWidget {
  const _SceneSelectTile({
    required this.scene,
    required this.l10n,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final LedSceneSummary scene;
  final AppLocalizations l10n;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sceneName = LedSceneDisplayText.name(scene, l10n);
    final sceneIcon = SceneIconHelper.getSceneIcon(
      iconId: SceneIconHelper.iconKeyToId(scene.iconKey),
      width: 24,
      height: 24,
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 6,
              right: 12,
              bottom: 6,
            ),
            child: Row(
              children: [
                SizedBox(width: 24, height: 24, child: sceneIcon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sceneName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CommonIconHelper.getCheckIcon(
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Progress overlay ↔ progress.xml
// ────────────────────────────────────────────────────────────────────────────

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
