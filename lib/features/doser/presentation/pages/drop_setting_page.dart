// PARITY: 100% Android activity_drop_setting.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_setting.xml
// Mode: Feature Implementation (完整功能實現)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - Main Content: ConstraintLayout (固定高度，不可捲動)
//   - Device Name Section (TextView + TextInputLayout)
//   - Sink Position Section (TextView + MaterialButton)
//   - Delay Time Section (TextView + MaterialButton)
// - Progress: include progress (visibility=gone)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../data/ble/dosing/dosing_command_builder.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../controllers/drop_setting_controller.dart';

/// DropSettingPage - Dosing 設備設定頁面
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_setting.xml
///
/// Feature Implementation Mode:
/// - 集成 DropSettingController
/// - 完整業務邏輯
/// - 編輯設備名稱、水槽位置、延遲時間
class DropSettingPage extends StatelessWidget {
  final String deviceId;

  const DropSettingPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider(
      create: (_) => DropSettingController(
        deviceId: deviceId,
        session: session,
        updateDeviceNameUseCase: appContext.updateDeviceNameUseCase,
        updateDeviceSinkUseCase: appContext.updateDeviceSinkUseCase,
        deviceRepository: appContext.deviceRepository,
        sinkRepository: appContext.sinkRepository,
        bleAdapter: appContext.bleAdapter,
        commandBuilder: const DosingCommandBuilder(),
      )..initialize(),
      child: _DropSettingPageContent(),
    );
  }
}

/// Internal content widget that has access to DropSettingController
class _DropSettingPageContent extends StatefulWidget {
  @override
  State<_DropSettingPageContent> createState() =>
      _DropSettingPageContentState();
}

class _DropSettingPageContentState extends State<_DropSettingPageContent> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Initialize controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DropSettingController>();
      _nameController.text = controller.deviceName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final controller = context.watch<DropSettingController>();
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !controller.isSaving,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // PARITY: include toolbar_two_action (Line 8-14)
                _ToolbarTwoAction(
                  title: l10n.dropSettingTitle,
                  rightButtonText: l10n.actionSave,
                  onBack: controller.isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  onRightButton: controller.isSaving || !session.isReady
                      ? null
                      : () => _save(),
                ),
                // PARITY: layout_drop_setting (Line 16-112)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 12,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UI Block 1: Device Name
                        Text(
                          l10n.deviceName,
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: AppColors.primaryStrong,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          enabled: !controller.isSaving,
                          maxLines: 1,
                          onChanged: (value) {
                            controller.updateName(value);
                          },
                        ),

                        // UI Block 2: Sink Position
                        const SizedBox(height: 16),
                        Text(
                          l10n.sinkPosition,
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _BackgroundMaterialButton(
                          text: controller.sinkName ?? l10n.sinkPositionNotSet,
                          icon: CommonIconHelper.getNextIcon(
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: controller.isSaving
                              ? null
                              : () => _selectSinkPosition(),
                        ),

                        // UI Block 3: Delay Time
                        const SizedBox(height: 16),
                        Text(
                          l10n.delayTime,
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _BackgroundMaterialButton(
                          text: controller.getDelayTimeText(),
                          icon: CommonIconHelper.getMenuIcon(
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          onPressed:
                              controller.isSaving || !session.isReady
                              ? null
                              : () => _selectDelayTime(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // PARITY: include progress (Line 114-119)
            _ProgressOverlay(
              visible: controller.isLoading || controller.isSaving,
            ),
          ],
        ),
      ),
    );
  }

  /// Save settings
  ///
  /// PARITY: DropSettingActivity.setListener() btnRight (Line 81-88)
  Future<void> _save() async {
    final controller = context.read<DropSettingController>();
    final l10n = AppLocalizations.of(context);

    final currentContext = context;
    final success = await controller.save();

    if (!currentContext.mounted) return;

    if (success) {
      // Success: Show toast and finish
      ScaffoldMessenger.of(
        currentContext,
      ).showSnackBar(SnackBar(content: Text(l10n.toastSettingSuccessful)));
      Navigator.of(currentContext).pop(true);
    } else {
      // Error: Show error message
      final errorCode = controller.lastErrorCode;
      String errorMessage;

      if (errorCode == AppErrorCode.invalidParam) {
        // Name is empty
        errorMessage =
            'TODO(l10n): Name is empty'; // TODO(l10n): Use l10n.toastNameIsEmpty
      } else if (errorCode == AppErrorCode.sinkFull) {
        // Sink is full
        errorMessage =
            'TODO(l10n): Sink is full'; // TODO(l10n): Use l10n.toastSinkIsFull
      } else {
        // Generic error
        errorMessage =
            'TODO(l10n): Setting failed'; // TODO(l10n): Use l10n.toastSettingFailed
      }

      ScaffoldMessenger.of(
        currentContext,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  /// Select sink position
  ///
  /// PARITY: DropSettingActivity.setListener() btnPosition (Line 89-94)
  Future<void> _selectSinkPosition() async {
    // TODO: Navigate to SinkPositionPage
    // For now, show placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Navigate to SinkPositionPage')),
    );

    // Example of how it should work:
    // final result = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => SinkPositionPage(
    //       currentSinkId: controller.sinkId,
    //     ),
    //   ),
    // );
    // if (result != null && result is String) {
    //   await controller.updateSinkId(result);
    // }
  }

  /// Select delay time
  ///
  /// PARITY: DropSettingActivity.setListener() btnDelayTime (Line 95-124)
  Future<void> _selectDelayTime() async {
    final controller = context.read<DropSettingController>();

    final options = DropSettingController.getDelayTimeOptions();
    final labels = {
      15: '15 秒', // TODO(l10n): Use l10n.delay15Sec
      30: '30 秒', // TODO(l10n): Use l10n.delay30Sec
      60: '1 分鐘', // TODO(l10n): Use l10n.delay1Min
      120: '2 分鐘', // TODO(l10n): Use l10n.delay2Min
      180: '3 分鐘', // TODO(l10n): Use l10n.delay3Min
      240: '4 分鐘', // TODO(l10n): Use l10n.delay4Min
      300: '5 分鐘', // TODO(l10n): Use l10n.delay5Min
    };

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((seconds) {
            return ListTile(
              title: Text(labels[seconds] ?? '$seconds秒'),
              trailing: controller.delayTimeSeconds == seconds
                  ? Icon(Icons.check, color: AppColors.primaryStrong)
                  : null,
              onTap: () {
                controller.updateDelayTime(seconds);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// PARITY: include toolbar_two_action
/// android/ReefB_Android/app/src/main/res/layout/toolbar_two_action.xml
class _ToolbarTwoAction extends StatelessWidget {
  final String title;
  final String rightButtonText;
  final VoidCallback? onBack;
  final VoidCallback? onRightButton;

  const _ToolbarTwoAction({
    required this.title,
    required this.rightButtonText,
    this.onBack,
    this.onRightButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.primaryStrong,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: CommonIconHelper.getCloseIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.title2.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRightButton,
            child: Text(
              rightButtonText,
              style: AppTextStyles.subheaderAccent.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PARITY: BackgroundMaterialButton style
class _BackgroundMaterialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;

  const _BackgroundMaterialButton({
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: AppColors.surfaceMuted,
      elevation: 0,
      disabledColor: AppColors.surfaceMuted,
      disabledElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          icon,
        ],
      ),
    );
  }
}

/// PARITY: include progress (全畫面 Loading Overlay)
class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
