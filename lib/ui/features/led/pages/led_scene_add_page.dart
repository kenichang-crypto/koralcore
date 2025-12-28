import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
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
      appBar: AppBar(
        title: Text(l10n.ledSceneAddTitle ?? 'Add Scene'),
        actions: [
          if (controller.isDimmingMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Dimming Mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        children: [
          // Scene name input
          TextField(
            decoration: InputDecoration(
              labelText: l10n.ledSceneNameLabel ?? 'Scene Name',
              hintText: l10n.ledSceneNameHint ?? 'Enter scene name',
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: controller.name)
              ..selection = TextSelection.collapsed(offset: controller.name.length),
            onChanged: controller.setName,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Scene count limit indicator
          if (controller.sceneCount != null) ...[
            _SceneCountIndicator(
              currentCount: controller.sceneCount!,
              isLimitReached: controller.isSceneLimitReached,
            ),
            const SizedBox(height: AppDimensions.spacingL),
          ],
          
          // Icon picker
          SceneIconPicker(
            selectedIconId: controller.iconId,
            onIconSelected: controller.setIconId,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Spectrum chart (simplified - will be enhanced in full version)
          if (controller.channelLevels.isNotEmpty)
            LedSpectrumChart.fromChannelMap(
              controller.channelLevels,
              height: 72,
              compact: true,
            ),
          const SizedBox(height: AppDimensions.spacingL),

          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // Channel sliders
          Text(
            l10n.ledControlChannelsSection ?? 'Channel Levels',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ..._buildChannelSliders(context, controller, isConnected),

          if (controller.isLoading)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingL),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final channels = [
      ('coldWhite', l10n.ledChannelColdWhite ?? 'Cold White'),
      ('royalBlue', l10n.ledChannelRoyalBlue ?? 'Royal Blue'),
      ('blue', l10n.ledChannelBlue ?? 'Blue'),
      ('red', l10n.ledChannelRed ?? 'Red'),
      ('green', l10n.ledChannelGreen ?? 'Green'),
      ('purple', l10n.ledChannelPurple ?? 'Purple'),
      ('uv', l10n.ledChannelUv ?? 'UV'),
      ('warmWhite', l10n.ledChannelWarmWhite ?? 'Warm White'),
      ('moonLight', l10n.ledChannelMoonLight ?? 'Moon Light'),
    ];

    return channels.map((channel) {
      final (id, label) = channel;
      final value = controller.getChannelLevel(id);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
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
                const SizedBox(height: AppDimensions.spacingS),
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
        backgroundColor: AppColors.grey400,
        icon: const Icon(Icons.block),
        label: Text(l10n.ledSceneLimitReached ?? 'Scene limit reached (5/5)'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Preview button (dimming mode is already active, so this is informational)
        if (controller.isDimmingMode)
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingM),
            child: FloatingActionButton(
              heroTag: 'preview',
              onPressed: null,
              backgroundColor: AppColors.success.withOpacity(0.7),
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
                        SnackBar(content: Text(l10n.ledSceneAddSuccess ?? 'Scene added successfully')),
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
          label: Text(l10n.actionSave ?? 'Save'),
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
      color: isLimitReached ? AppColors.warning.withOpacity(0.1) : AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Row(
          children: [
            Icon(
              isLimitReached ? Icons.warning : Icons.info_outline,
              color: isLimitReached ? AppColors.warning : AppColors.grey700,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                isLimitReached
                    ? 'Scene limit reached ($currentCount/5). Cannot add more scenes.'
                    : 'Current scenes: $currentCount/5',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLimitReached ? AppColors.warning : AppColors.grey700,
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
