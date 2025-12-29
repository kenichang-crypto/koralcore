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
import '../../../../infrastructure/repositories/scene_repository_impl.dart';
import '../controllers/led_scene_edit_controller.dart';
import '../widgets/led_spectrum_chart.dart';
import '../widgets/scene_icon_picker.dart';

/// LedSceneEditPage
///
/// Simplified version for editing an existing LED scene.
/// Currently only supports editing local scenes (created via SceneRepositoryImpl).
class LedSceneEditPage extends StatelessWidget {
  final String sceneId;

  const LedSceneEditPage({
    super.key,
    required this.sceneId,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;

    return FutureBuilder<_SceneEditData?>(
      future: _loadSceneData(deviceId, sceneId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).ledSceneEditTitle),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).ledSceneEditTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(ReefSpacing.xl),
                child: Text(
                  snapshot.error?.toString() ?? 'Scene not found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ReefColors.danger,
                      ),
                ),
              ),
            ),
          );
        }

        final sceneData = snapshot.data!;
        return ChangeNotifierProvider<LedSceneEditController>(
          create: (_) => LedSceneEditController(
            session: session,
            addSceneUseCase: appContext.addSceneUseCase,
            updateSceneUseCase: appContext.updateSceneUseCase,
            enterDimmingModeUseCase: appContext.enterDimmingModeUseCase,
            exitDimmingModeUseCase: appContext.exitDimmingModeUseCase,
            setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
            applySceneUseCase: appContext.applySceneUseCase,
            initialSceneId: sceneData.sceneId,
            initialName: sceneData.name,
            initialChannelLevels: sceneData.channelLevels,
            initialIconId: sceneData.iconId,
          ),
          child: _LedSceneEditView(sceneId: sceneData.sceneId),
        );
      },
    );
  }

  Future<_SceneEditData?> _loadSceneData(String? deviceId, String sceneIdString) async {
    if (deviceId == null) {
      throw Exception('No active device');
    }

    // Parse sceneId: "local_scene_1" -> 1
    final int? sceneId = _parseLocalSceneId(sceneIdString);
    if (sceneId == null) {
      throw Exception('Invalid scene ID format');
    }

    final sceneRepository = SceneRepositoryImpl();
    final sceneRecord = await sceneRepository.getSceneById(
      deviceId: deviceId,
      sceneId: sceneId,
    );

    if (sceneRecord == null) {
      throw Exception('Scene not found');
    }

    return _SceneEditData(
      sceneId: sceneId,
      name: sceneRecord.name,
      channelLevels: sceneRecord.channelLevels,
      iconId: sceneRecord.iconId,
    );
  }

  int? _parseLocalSceneId(String sceneIdString) {
    // Format: "local_scene_1" -> 1
    if (sceneIdString.startsWith('local_scene_')) {
      final idStr = sceneIdString.substring('local_scene_'.length);
      return int.tryParse(idStr);
    }
    return null;
  }
}

class _SceneEditData {
  final int sceneId;
  final String name;
  final Map<String, int> channelLevels;
  final int iconId;

  _SceneEditData({
    required this.sceneId,
    required this.name,
    required this.channelLevels,
    required this.iconId,
  });
}

class _LedSceneEditView extends StatefulWidget {
  final int sceneId;

  const _LedSceneEditView({required this.sceneId});

  @override
  State<_LedSceneEditView> createState() => _LedSceneEditViewState();
}

class _LedSceneEditViewState extends State<_LedSceneEditView> {
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
        title: Text(l10n.ledSceneEditTitle),
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
      body: ListView(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        children: [
          // Scene name input
          TextField(
            decoration: InputDecoration(
              labelText: l10n.ledSceneNameLabel,
              hintText: l10n.ledSceneNameHint,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: controller.name)
              ..selection = TextSelection.collapsed(offset: controller.name.length),
            onChanged: controller.setName,
          ),
          const SizedBox(height: ReefSpacing.md),
          
          // Icon picker
          SceneIconPicker(
            selectedIconId: controller.iconId,
            onIconSelected: controller.setIconId,
          ),
          const SizedBox(height: ReefSpacing.md),
          
          // Spectrum chart
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Preview indicator (dimming mode is already active)
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
            onPressed: (isConnected && !controller.isLoading)
                ? () async {
                    final success = await controller.saveScene();
                    if (mounted) {
                      if (success) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.ledSceneEditSuccess)),
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
      ),
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
}
