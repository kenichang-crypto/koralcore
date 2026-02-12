import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../controllers/pump_head_adjust_controller.dart';
import '../widgets/pump_head_adjust_description_section.dart';
import '../widgets/pump_head_adjust_rotating_speed_section.dart';
import '../widgets/pump_head_adjust_drop_volume_section.dart';
import '../widgets/pump_head_adjust_image.dart';
import '../widgets/pump_head_adjust_bottom_buttons.dart';
import '../widgets/pump_head_adjust_speed_picker.dart';
import '../widgets/pump_head_adjust_countdown_overlay.dart';
import '../widgets/pump_head_adjust_loading_overlay.dart';

/// PumpHeadAdjustPage
///
/// PARITY: Mirrors reef-b-app's DropHeadAdjustActivity.
/// Page for calibrating a pump head with the following flow:
/// 1. Select rotating speed (Low/Medium/High)
/// 2. Enter calibration drop volume (0.1-500.9 ml, 1 decimal place)
/// 3. Click "Next" to start calibration
/// 4. Show countdown timer (21 seconds)
/// 5. After calibration completes, enter actual drop volume
/// 6. Click "Complete Calibration" to submit result
class PumpHeadAdjustPage extends StatelessWidget {
  final String headId;
  final int? initialSpeed;

  const PumpHeadAdjustPage({
    super.key,
    required this.headId,
    this.initialSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<PumpHeadAdjustController>(
      create: (_) => PumpHeadAdjustController(
        headId: headId,
        session: session,
        bleAdapter: appContext.bleAdapter,
        initialSpeed: initialSpeed,
      ),
      child: _PumpHeadAdjustView(headId: headId),
    );
  }
}

class _PumpHeadAdjustView extends StatelessWidget {
  final String headId;

  const _PumpHeadAdjustView({required this.headId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<PumpHeadAdjustController>();
    final isConnected = session.isBleConnected;
    final isReady = session.isReady;

    // Show error if any
    final AppErrorCode? errorCode = controller.lastErrorCode;
    if (errorCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeAppError(l10n, errorCode))),
          );
          controller.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.dosingAdjustTitle,
          style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - fixed layout, no scrolling
            // PARITY: activity_drop_head_adjust.xml layout_drop_head_adjust padding 16dp
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isConnected) ...[
                    const BleGuardBanner(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  // Description Section
                  PumpHeadAdjustDescriptionSection(l10n: l10n),
                  // Rotating Speed Section
                  const SizedBox(height: AppSpacing.lg),
                  PumpHeadAdjustRotatingSpeedSection(
                    controller: controller,
                    isConnected: isReady,
                    l10n: l10n,
                    onSpeedPickerTap: () => PumpHeadAdjustSpeedPicker.show(
                      context,
                      controller,
                      l10n,
                    ),
                  ),
                  // Drop Volume Section (shown after calibration starts)
                  if (controller.isCalibrationComplete) ...[
                    const SizedBox(height: AppSpacing.md),
                    PumpHeadAdjustDropVolumeSection(
                      controller: controller,
                      isConnected: isReady,
                      l10n: l10n,
                    ),
                  ],
                  // Adjust Image
                  const SizedBox(height: AppSpacing.lg),
                  const PumpHeadAdjustImage(),
                  // Bottom buttons
                  const Spacer(),
                  PumpHeadAdjustBottomButtons(
                    controller: controller,
                    isConnected: isReady,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (controller.isLoading) const PumpHeadAdjustLoadingOverlay(),
            // Calibration countdown overlay
            if (controller.isCalibrating && controller.remainingSeconds > 0)
              PumpHeadAdjustCountdownOverlay(
                remainingSeconds: controller.remainingSeconds,
                l10n: l10n,
              ),
          ],
        ),
      ),
    );
  }
}
