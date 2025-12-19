import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';

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
      )..refresh(),
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
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
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

  AppErrorPresenter.of(context).present(code: code);
  controller.clearError();
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
            const Icon(Icons.auto_awesome_outlined, size: 32),
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

  const _SceneCard({
    required this.scene,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                        Text(
                          scene.isEnabled
                              ? l10n.ledSceneStatusEnabled
                              : l10n.ledSceneStatusDisabled,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scene.isEnabled
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
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
