import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../widgets/reef_app_bar.dart';
import '../controllers/led_scene_edit_controller.dart';
import '../widgets/led_spectrum_chart.dart';
import '../widgets/scene_icon_picker.dart';

/// LedSceneAddPage
///
/// Simplified version for adding a new LED scene.
/// Full version will include spectrum chart and icon picker.
class LedSceneAddPage extends StatelessWidget {
  const LedSceneAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedSceneEditController>(
      create: (_) => LedSceneEditController(
        session: session,
        addSceneUseCase: appContext.addSceneUseCase,
        updateSceneUseCase: appContext.updateSceneUseCase,
        enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
        exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
        setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
        applySceneUseCase: appContext.applySceneUseCase,
      ),
      child: const _LedSceneAddView(),
    );
  }
}

class _LedSceneAddView extends StatefulWidget {
  const _LedSceneAddView();

  @override
  State<_LedSceneAddView> createState() => _LedSceneAddViewState();
}

class _LedSceneAddViewState extends State<_LedSceneAddView> {
  @override
  void initState() {
    super.initState();
    // Auto-enter dimming mode when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<LedSceneEditController>();
      controller.enterDimmingMode();
    });
  }

  @override
  void dispose() {
    // Auto-exit dimming mode when page closes
    final controller = context.read<LedSceneEditController>();
    controller.exitDimmingMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedSceneEditController>();
    final isConnected = session.isBleConnected;

    return Scaffold(
      appBar: ReefAppBar(
        title: Text(l10n.ledSceneAddTitle),
        actions: [
          if (controller.isDimmingMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Dimming Mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ReefColors.success,
                      ),
                ),
              ),
            ),
        ],
      ),
      body            : ListView(
                // PARITY: activity_led_scene_add.xml padding 16/12/16 (no explicit paddingBottom)
                padding: EdgeInsets.only(
                  left: ReefSpacing.md, // dp_16 paddingStart
                  top: ReefSpacing.sm, // dp_12 paddingTop
                  right: ReefSpacing.md, // dp_16 paddingEnd
                  bottom: 40, // dp_40 paddingBottom (from sl_moon_light marginBottom)
                ),
        children: [
          // Scene name input
          TextField(
            decoration: InputDecoration(
              hintText: l10n.ledSceneNameHint,
            ),
            controller: TextEditingController(text: controller.name)
              ..selection = TextSelection.collapsed(offset: controller.name.length),
            onChanged: controller.setName,
          ),
          const SizedBox(height: ReefSpacing.md),
          
          // Scene count limit indicator
          if (controller.sceneCount != null) ...[
            _SceneCountIndicator(
              currentCount: controller.sceneCount!,
              isLimitReached: controller.isSceneLimitReached,
            ),
            const SizedBox(height: ReefSpacing.md),
          ],
          
          // Icon picker
          SceneIconPicker(
            selectedIconId: controller.iconId,
            onIconSelected: controller.setIconId,
          ),
          const SizedBox(height: ReefSpacing.md),
          
          // Spectrum chart (simplified - will be enhanced in full version)
          if (controller.channelLevels.isNotEmpty)
            LedSpectrumChart.fromChannelMap(
              controller.channelLevels,
              height: 72,
              compact: true,
            ),
          const SizedBox(height: ReefSpacing.md),

          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: ReefSpacing.md),
          ],

          // Channel sliders
          Text(
            'Channel Levels',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ReefSpacing.sm),
          ..._buildChannelSliders(context, controller, isConnected),

          if (controller.isLoading)
            const Padding(
              padding: EdgeInsets.all(ReefSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _buildActionButtons(context, l10n, controller, isConnected),
    );
  }

  List<Widget> _buildChannelSliders(
    BuildContext context,
    LedSceneEditController controller,
    bool enabled,
  ) {
    final theme = Theme.of(context);
    final channels = [
      ('coldWhite', 'Cold White'),
      ('royalBlue', 'Royal Blue'),
      ('blue', 'Blue'),
      ('red', 'Red'),
      ('green', 'Green'),
      ('purple', 'Purple'),
      ('uv', 'UV'),
      ('warmWhite', 'Warm White'),
      ('moonLight', 'Moon Light'),
    ];

    return channels.map((channel) {
      final (id, label) = channel;
      final value = controller.getChannelLevel(id);
      return Padding(
        padding: const EdgeInsets.only(bottom: ReefSpacing.sm),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(ReefSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(label, style: theme.textTheme.titleSmall),
                    ),
                    Text(
                      '$value%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ReefSpacing.xs),
                Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '$value%',
                  onChanged: enabled && controller.isDimmingMode
                      ? (newValue) => controller.setChannelLevel(id, newValue.toInt())
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    LedSceneEditController controller,
    bool isConnected,
  ) {
    if (controller.isSceneLimitReached) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: ReefColors.textTertiary,
        icon: const Icon(Icons.block),
        label: Text(l10n.ledSceneLimitReached),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Preview button (dimming mode is already active, so this is informational)
        if (controller.isDimmingMode)
          Padding(
            padding: const EdgeInsets.only(right: ReefSpacing.sm),
            child: FloatingActionButton(
              heroTag: 'preview',
              onPressed: null,
              backgroundColor: ReefColors.success.withOpacity(0.7),
              child: const Icon(Icons.preview),
            ),
          ),
        // Save button
        FloatingActionButton.extended(
          heroTag: 'save',
          onPressed: (isConnected && !controller.isLoading && !controller.isSceneLimitReached)
              ? () async {
                  final success = await controller.saveScene();
                  if (mounted) {
                    if (success) {
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.ledSceneAddSuccess)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            describeAppError(l10n, controller.lastErrorCode ?? AppErrorCode.unknownError),
                          ),
                        ),
                      );
                    }
                  }
                }
              : null,
          icon: const Icon(Icons.save),
          label: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

class _SceneCountIndicator extends StatelessWidget {
  const _SceneCountIndicator({
    required this.currentCount,
    required this.isLimitReached,
  });

  final int currentCount;
  final bool isLimitReached;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isLimitReached ? ReefColors.warning.withOpacity(0.1) : ReefColors.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.sm),
        child: Row(
          children: [
            Icon(
              isLimitReached ? Icons.warning : Icons.info_outline,
              color: isLimitReached ? ReefColors.warning : ReefColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: ReefSpacing.xs),
            Expanded(
              child: Text(
                isLimitReached
                    ? 'Scene limit reached ($currentCount/5). Cannot add more scenes.'
                    : 'Current scenes: $currentCount/5',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLimitReached ? ReefColors.warning : ReefColors.textSecondary,
                      fontWeight: isLimitReached ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
