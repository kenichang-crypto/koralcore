import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/warning/warning.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/warning_controller.dart';

/// Warning list page.
///
/// PARITY: Mirrors reef-b-app's WarningActivity.
/// Note: BLE commands (0x2C, 0x7B) are not implemented in reef-b-app,
/// so this page will show empty state or placeholder data.
class WarningPage extends StatelessWidget {
  const WarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<WarningController>(
      create: (_) => WarningController(
        session: session,
        warningRepository: appContext.warningRepository,
      )..initialize(),
      child: const _WarningView(),
    );
  }
}

class _WarningView extends StatelessWidget {
  const _WarningView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<WarningController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getBackIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.warningTitle,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          if (controller.warnings.isNotEmpty)
            IconButton(
              icon: CommonIconHelper.getDeleteIcon(size: 24),
              tooltip: l10n.warningClearAll,
              onPressed: controller.isLoading
                  ? null
                  : () => _showClearAllDialog(context, controller, l10n),
            ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isConnected) ...[const BleGuardBanner()],
                Expanded(
                  child: controller.warnings.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : RefreshIndicator(
                          onRefresh: controller.refresh,
                          child: ListView.builder(
                            // PARITY: activity_warning.xml rv_warning
                            // RecyclerView with marginTop 13dp, no padding (padding is handled by adapter items)
                            padding: EdgeInsets.zero, // No padding - adapter items handle their own spacing
                            itemCount: controller.warnings.length,
                            itemBuilder: (context, index) {
                              final warning = controller.warnings[index];
                              return _WarningCard(
                                warning: warning,
                                onDelete: () =>
                                    controller.deleteWarning(warning.id),
                                l10n: l10n,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    WarningController controller,
    AppLocalizations l10n,
  ) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.warningClearAllTitle),
        content: Text(
          l10n.warningClearAllContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.actionClear),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.clearAllWarnings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.warningClearAllSuccess,
            ),
          ),
        );
      }
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }
}

/// Warning card matching adapter_warning.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_warning.xml structure:
/// - ConstraintLayout: bg_aaaa
/// - padding: 16/8/16/8dp
/// - tv_warning_title: caption1_accent
/// - tv_device_type: caption1
/// - tv_device_name: caption1_accent
/// - txt_clock: caption1, text_aa
/// - Two dividers: bg_aaa (full width) and bg_press (with 16dp margin)
class _WarningCard extends StatelessWidget {
  final Warning warning;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  const _WarningCard({
    required this.warning,
    required this.onDelete,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final String deviceName = warning.deviceId.isNotEmpty
        ? (session.savedDevices
                .where((d) => d.id == warning.deviceId)
                .isNotEmpty
                ? session.savedDevices
                    .where((d) => d.id == warning.deviceId)
                    .first
                    .name
                : null) ??
            warning.deviceId
        : '';
    final String deviceType = _getDeviceType(warning.deviceId, session);
    final String timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(warning.time);

    // PARITY: adapter_warning.xml structure
    return InkWell(
      onTap: onDelete,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (bg_aaaa background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16 paddingStart
              top: AppSpacing.xs, // dp_8 paddingTop
              right: AppSpacing.md, // dp_16 paddingEnd
              bottom: AppSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // bg_aaaa
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning title (tv_warning_title) - caption1_accent
                Text(
                  l10n.warningId(warning.warningId),
                  style: AppTextStyles.caption1Accent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs), // dp_8 marginTop
                // Device type and name row
                Row(
                  children: [
                    // Device type (tv_device_type) - caption1
                    Text(
                      deviceType,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                    // Device name (tv_device_name) - caption1_accent
                    Expanded(
                      child: Text(
                        deviceName,
                        style: AppTextStyles.caption1Accent.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs), // dp_8 marginTop
                // Clock (txt_clock) - caption1, text_aa
                Text(
                  timeStr,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondary, // text_aa
                  ),
                ),
              ],
            ),
          ),
          // First divider (bg_aaa, full width)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfaceMuted, // bg_aaa
          ),
          // Second divider (bg_press, with 16dp margin)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md), // dp_16 marginStart/End
            child: Divider(
              height: 1, // dp_1
              thickness: 1, // dp_1
              color: AppColors.surfacePressed, // bg_press
            ),
          ),
        ],
      ),
    );
  }

  String _getDeviceType(String deviceId, AppSession session) {
    if (deviceId.isEmpty) return '';
    final devices = session.savedDevices.where((d) => d.id == deviceId);
    if (devices.isEmpty) return '';
    final device = devices.first;
    final name = device.name.toLowerCase();
    if (name.contains('led')) return 'LED';
    if (name.contains('dose') || name.contains('drop')) return 'DROP';
    return '';
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonIconHelper.getCheckIcon(size: 64, color: AppColors.success),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.warningEmptyTitle,
            style: AppTextStyles.title2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.warningEmptySubtitle,
            style: AppTextStyles.body1.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
