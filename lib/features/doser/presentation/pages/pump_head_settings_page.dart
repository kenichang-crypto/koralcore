// PARITY: 100% Android activity_drop_head_setting.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_head_setting.xml
// Mode: Feature Implementation (完整功能實現)
//
// Android 結構：
// - Root: ConstraintLayout
// - Toolbar: include toolbar_two_action (固定)
// - Main Content: ConstraintLayout (固定高度，不可捲動)
//   - Drop Type Section (TextView + MaterialButton) ✅ VISIBLE
//   - Max Drop Volume Section - visibility=gone ❌ NOT IMPLEMENTED
//   - Rotating Speed Section (TextView + MaterialButton) - enabled=false ✅ VISIBLE

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../data/ble/dosing/dosing_command_builder.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../controllers/pump_head_settings_controller.dart';
import 'drop_type_page.dart';

/// PumpHeadSettingsPage - 泵頭設定頁面
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/activity_drop_head_setting.xml
///
/// Feature Implementation Mode:
/// - 集成 PumpHeadSettingsController
/// - 完整業務邏輯
/// - 選擇滴液種類、設定轉速
class PumpHeadSettingsPage extends StatelessWidget {
  final String deviceId;
  final String headId;

  const PumpHeadSettingsPage({
    super.key,
    required this.deviceId,
    required this.headId,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider(
      create: (_) => PumpHeadSettingsController(
        deviceId: deviceId,
        headId: headId,
        session: session,
        pumpHeadRepository: appContext.pumpHeadRepository,
        dropTypeRepository: appContext.dropTypeRepository,
        bleAdapter: appContext.bleAdapter,
        commandBuilder: const DosingCommandBuilder(),
      )..initialize(),
      child: _PumpHeadSettingsPageContent(),
    );
  }
}

/// Internal content widget that has access to PumpHeadSettingsController
class _PumpHeadSettingsPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final controller = context.watch<PumpHeadSettingsController>();
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !controller.isSaving,
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        body: Stack(
          children: [
            Column(
              children: [
                // PARITY: include toolbar_two_action (Line 8-14)
                _ToolbarTwoAction(
                  title: controller.getHeadDisplayName(),
                  rightButtonText: l10n.actionSave,
                  onBack: controller.isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  onRightButton: controller.isSaving || !session.isReady
                      ? null
                      : () => _save(context),
                ),
                // PARITY: layout_drop_head_setting (Line 16-160)
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
                        // UI Block 1: Drop Type
                        Text(
                          l10n.dosingType,
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _BackgroundMaterialButton(
                          text: controller.dropTypeName ?? l10n.sinkPositionNotSet,
                          icon: CommonIconHelper.getNextIcon(
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: controller.isSaving
                              ? null
                              : () => _selectDropType(context),
                        ),

                        // UI Block 2: Rotating Speed
                        const SizedBox(height: 16),
                        Text(
                          l10n.pumpHeadSpeed,
                          style: AppTextStyles.caption1.copyWith(
                            color: controller.isConnected
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _BackgroundMaterialButton(
                          text: _rotatingSpeedLabel(controller.rotatingSpeed, l10n),
                          icon: CommonIconHelper.getMenuIcon(
                            size: 20,
                            color: controller.isConnected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          onPressed: controller.isSaving || !session.isReady
                              ? null
                              : () => _selectRotatingSpeed(context),
                          textColor: controller.isConnected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // PARITY: include progress (Line 162-167)
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
  /// PARITY: DropHeadSettingActivity.setListener() btnRight (Line 97-102)
  Future<void> _save(BuildContext context) async {
    final controller = context.read<PumpHeadSettingsController>();
    final l10n = AppLocalizations.of(context);

    final currentContext = context;
    final success = await controller.save();

    if (!currentContext.mounted) return;

    if (success) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text(l10n.toastSettingSuccessful)),
      );
      Navigator.of(currentContext).pop(true);
    } else {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text(describeAppError(l10n, AppErrorCode.unknownError)),
        ),
      );
    }
  }

  /// Select drop type
  ///
  /// PARITY: DropHeadSettingActivity.setListener() btnDropType, DropTypeActivity setResult
  Future<void> _selectDropType(BuildContext context) async {
    final settingsController = context.read<PumpHeadSettingsController>();
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (context) => DropTypePage(
          initialDropTypeId: settingsController.dropTypeId,
        ),
      ),
    );
    if (context.mounted && result != null) {
      await settingsController.updateDropTypeId(result == 0 ? null : result);
    }
  }

  String _rotatingSpeedLabel(int speed, AppLocalizations l10n) {
    switch (speed) {
      case 1:
        return l10n.pumpHeadSpeedLow;
      case 2:
        return l10n.pumpHeadSpeedMedium;
      case 3:
        return l10n.pumpHeadSpeedHigh;
      default:
        return l10n.pumpHeadSpeedMedium;
    }
  }

  /// Select rotating speed
  ///
  /// PARITY: DropHeadSettingActivity.setListener() btnRotatingSpeed (Line 113-130)
  Future<void> _selectRotatingSpeed(BuildContext context) async {
    final controller = context.read<PumpHeadSettingsController>();
    final l10n = AppLocalizations.of(context);

    final options = PumpHeadSettingsController.getRotatingSpeedOptions();
    final labels = {
      1: l10n.pumpHeadSpeedLow,
      2: l10n.pumpHeadSpeedMedium,
      3: l10n.pumpHeadSpeedHigh,
    };

    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((speed) {
            return ListTile(
              title: Text(labels[speed] ?? '$speed'),
              trailing: controller.rotatingSpeed == speed
                  ? CommonIconHelper.getCheckIcon(
                      size: 24,
                      color: AppColors.primaryStrong,
                    )
                  : null,
              onTap: () {
                controller.updateRotatingSpeed(speed);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// PARITY: include toolbar_two_action
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
  final Color? textColor;

  const _BackgroundMaterialButton({
    required this.text,
    required this.icon,
    this.onPressed,
    this.textColor,
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
              style: AppTextStyles.body.copyWith(
                color: textColor ?? AppColors.textPrimary,
              ),
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
