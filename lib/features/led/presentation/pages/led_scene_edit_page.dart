import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../data/repositories/scene_repository_impl.dart';
import '../controllers/led_scene_edit_controller.dart';
import '../widgets/led_spectrum_chart.dart';
import '../widgets/scene_icon_picker.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// LedSceneEditPage
///
/// Simplified version for editing an existing LED scene.
/// Currently only supports editing local scenes (created via SceneRepositoryImpl).
class LedSceneEditPage extends StatelessWidget {
  final String sceneId;

  const LedSceneEditPage({super.key, required this.sceneId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;

    return FutureBuilder<_SceneEditData?>(
      future: _loadSceneData(deviceId, sceneId, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: ReefAppBar(
              title: Text(AppLocalizations.of(context).ledSceneEditTitle),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // PARITY: reef-b-app just calls finish() if sceneId == -1, no error display
        if (snapshot.hasError || snapshot.data == null) {
          // Navigate back silently, matching reef-b-app behavior
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return Scaffold(
            appBar: ReefAppBar(
              title: Text(AppLocalizations.of(context).ledSceneEditTitle),
            ),
            body: const Center(child: CircularProgressIndicator()),
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

  Future<_SceneEditData?> _loadSceneData(
    String? deviceId,
    String sceneIdString,
    BuildContext context,
  ) async {
    // PARITY: reef-b-app doesn't show error messages for invalid sceneId or missing device
    // It just calls finish() if sceneId == -1
    if (deviceId == null) {
      return null; // Return null to trigger navigation back
    }

    // Parse sceneId: "local_scene_1" -> 1
    final int? sceneId = _parseLocalSceneId(sceneIdString);
    if (sceneId == null) {
      return null; // Return null to trigger navigation back
    }

    final sceneRepository = SceneRepositoryImpl();
    final sceneRecord = await sceneRepository.getSceneById(
      deviceId: deviceId,
      sceneId: sceneId,
    );

    if (sceneRecord == null) {
      return null; // Return null to trigger navigation back
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
  late final LedSceneEditController _controller;
  bool _hasEnteredDimmingMode = false;
  bool _previousBleConnected = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<LedSceneEditController>();
    // PARITY: reef-b-app enters dimming mode after scene data is loaded
    // We'll enter dimming mode after the controller is initialized and data is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Enter dimming mode after data is loaded (similar to reef-b-app's sceneLiveData.observe)
      if (!_hasEnteredDimmingMode && _controller.channelLevels.isNotEmpty) {
        _controller.enterDimmingMode();
        _hasEnteredDimmingMode = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // PARITY: reef-b-app enters dimming mode after scene data is loaded
    // Enter dimming mode when controller data is ready
    if (!_hasEnteredDimmingMode && _controller.channelLevels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasEnteredDimmingMode) {
          _controller.enterDimmingMode();
          _hasEnteredDimmingMode = true;
        }
      });
    }
    
    // PARITY: reef-b-app disconnectLiveData.observe() → finish()
    // Monitor BLE connection state and close page on disconnect
    final session = context.watch<AppSession>();
    final isBleConnected = session.isBleConnected;
    
    // If BLE was connected but now disconnected, exit dimming mode and close page
    if (_previousBleConnected && !isBleConnected && _hasEnteredDimmingMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.exitDimmingMode();
          Navigator.of(context).pop();
        }
      });
    }
    
    _previousBleConnected = isBleConnected;
  }

  @override
  void dispose() {
    // PARITY: reef-b-app exits dimming mode when clicking back button
    // Auto-exit dimming mode when page closes
    if (_hasEnteredDimmingMode) {
      _controller.exitDimmingMode();
    }
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
        title: Text(l10n.ledSceneEditTitle),
        leading: IconButton(
          icon: CommonIconHelper.getCloseIcon(size: 24),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // PARITY: reef-b-app toolbar btnRight (Save button)
          TextButton(
            onPressed: (isConnected && !controller.isLoading)
                ? () async {
                    // PARITY: reef-b-app checks nameIsEmpty first
                    if (controller.name.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.toastNameIsEmpty)),
                      );
                      return;
                    }
                    
                    final success = await controller.saveScene();
                    if (mounted) {
                      if (success) {
                        Navigator.of(context).pop(true);
                        // PARITY: reef-b-app uses toast_setting_successful (R.string.toast_setting_successful)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.toastSettingSuccessful)),
                        );
                      } else {
                        // PARITY: reef-b-app shows toast_scene_name_is_exist when editScene returns 0
                        // (R.string.toast_scene_name_is_exist)
                        final errorCode = controller.lastErrorCode;
                        if (errorCode == AppErrorCode.invalidParam) {
                          // Assume it's scene name exists error (dbEditScene returns 0)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.toastSceneNameIsExist)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                describeAppError(
                                  l10n,
                                  errorCode ?? AppErrorCode.unknownError,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  }
                : null,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
        // PARITY: activity_led_scene_edit.xml padding 16/12/16 (no explicit paddingBottom)
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_16 paddingStart
          top: AppSpacing.sm, // dp_12 paddingTop
          right: AppSpacing.md, // dp_16 paddingEnd
          bottom: 40, // dp_40 paddingBottom (from sl_moon_light marginBottom)
        ),
        children: [
          // PARITY: activity_led_scene_edit.xml tv_time_title
          // marginStart/End: 16dp, marginTop: 12dp
          // Scene name input
          TextField(
            decoration: InputDecoration(
              labelText: l10n.ledSceneNameLabel,
              hintText: l10n.ledSceneNameHint,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: controller.name)
              ..selection = TextSelection.collapsed(
                offset: controller.name.length,
              ),
            onChanged: controller.setName,
          ),
          // PARITY: activity_led_scene_edit.xml tv_scene_icon_title
          // marginTop: 24dp (from layout_name to tv_scene_icon_title)
          const SizedBox(height: 24),

          // Icon picker
          SceneIconPicker(
            selectedIconId: controller.iconId,
            onIconSelected: controller.setIconId,
          ),
          // PARITY: activity_led_scene_edit.xml chart_spectrum
          // marginTop: 24dp (from rv_scene_icon to chart_spectrum)
          const SizedBox(height: 24),

          // Spectrum chart
          // PARITY: activity_led_scene_edit.xml chart_spectrum
          // height=176dp, marginStart/End=22dp, marginTop=24dp
          if (controller.channelLevels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 22, // dp_22 marginStart
                top: 24, // dp_24 marginTop
                right: 22, // dp_22 marginEnd
              ),
              child: LedSpectrumChart.fromChannelMap(
                controller.channelLevels,
                height: 176, // dp_176
                compact: true,
              ),
            ),
          // PARITY: activity_led_scene_edit.xml tv_uv_light_title
          // marginTop: 16dp (from chart_spectrum to tv_uv_light_title)
          const SizedBox(height: 16),

          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppSpacing.md),
          ],

          // Channel sliders
          ..._buildChannelSliders(context, controller, isConnected, l10n),
        ],
      ),
          // PARITY: reef-b-app progress overlay (full screen)
          if (controller.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChannelSliders(
    BuildContext context,
    LedSceneEditController controller,
    bool enabled,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    // PARITY: reef-b-app channel order and labels
    // Note: warmWhite is visibility="gone" in reef-b-app, so we exclude it
    final channels = [
      ('uv', l10n.lightUv),
      ('purple', l10n.lightPurple),
      ('blue', l10n.lightBlue),
      ('royalBlue', l10n.lightRoyalBlue),
      ('green', l10n.lightGreen),
      ('red', l10n.lightRed),
      ('coldWhite', l10n.lightColdWhite),
      // ('warmWhite', l10n.lightWarmWhite), // PARITY: reef-b-app visibility="gone"
      ('moonLight', l10n.lightMoon),
    ];

    return channels.map((channel) {
      final (id, label) = channel;
      final value = controller.getChannelLevel(id);
      // PARITY: activity_led_scene_edit.xml slider layout
      // marginStart=6dp (title), marginStart=4dp marginEnd=6dp (value)
      // slider marginStart/End=16dp
      // trackColorActive: @color/xxx_light_color, trackHeight: 2dp
      final activeColor = _getChannelColor(id);
      return Padding(
        padding: const EdgeInsets.only(
          left: 6, // dp_6 marginStart for title
          right: 6, // dp_6 marginEnd for value
          bottom: 0, // No bottom padding, spacing handled by ConstraintLayout
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary, // text_aaaa
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4), // dp_4 marginStart
                  child: Text(
                    '$value',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary, // text_aaa
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // dp_16 marginStart/End
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.0, // dp_2 trackHeight
                  activeTrackColor: activeColor, // trackColorActive
                  inactiveTrackColor: AppColors.surfacePressed, // bg_press
                  thumbColor: activeColor,
                  overlayColor: activeColor.withOpacity(0.1),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '$value',
                  onChanged: enabled && controller.isDimmingMode
                      ? (newValue) =>
                            controller.setChannelLevel(id, newValue.toInt())
                      : null,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // PARITY: reef-b-app trackColorActive colors
  Color _getChannelColor(String channelId) {
    switch (channelId) {
      case 'uv':
        return AppColors.ultraviolet; // #AA00D4
      case 'purple':
        return AppColors.purple; // #6600FF
      case 'blue':
        return AppColors.blue; // #0055D4
      case 'royalBlue':
        return AppColors.royalBlue; // #00AAD4
      case 'green':
        return AppColors.green; // #00FF00
      case 'red':
        return AppColors.red; // #FF0000
      case 'coldWhite':
        return AppColors.coldWhite; // #55DDFF
      case 'warmWhite':
        return AppColors.warmWhite; // #FFEEAA
      case 'moonLight':
        return AppColors.moonLight; // #FF9955
      default:
        return AppColors.primary;
    }
  }
}
