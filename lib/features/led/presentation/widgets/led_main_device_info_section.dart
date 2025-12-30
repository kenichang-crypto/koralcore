import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../controllers/led_scene_list_controller.dart';

/// Device info section matching activity_led_main.xml layout.
///
/// PARITY: Mirrors reef-b-app's activity_led_main.xml structure:
/// - tv_name: Device name (body_accent, text_aaaa)
/// - btn_ble: BLE state icon (48×32dp)
/// - tv_position: Position/Sink name (caption2, text_aaa)
/// - tv_group: Group (caption2, text_aa, optional)
class LedMainDeviceInfoSection extends StatelessWidget {
  final String deviceName;
  final bool isConnected;
  final AppSession session;
  final AppLocalizations l10n;

  const LedMainDeviceInfoSection({
    super.key,
    required this.deviceName,
    required this.isConnected,
    required this.session,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final deviceId = session.activeDeviceId;

    // Get device info from repository
    return FutureBuilder<Map<String, String?>>(
      future: _loadDeviceInfo(context, deviceId),
      builder: (context, snapshot) {
        final positionName = snapshot.data?['positionName'];
        final groupName = snapshot.data?['groupName'];

        final appContext = context.read<AppContext>();
        final controller = context.read<LedSceneListController>();
        return _buildDeviceInfo(
          context,
          appContext,
          controller,
          positionName,
          groupName,
        );
      },
    );
  }

  /// Load device info from repository.
  ///
  /// PARITY: Matches reef-b-app's LedMainActivity.setObserver() logic:
  /// - Gets sinkId from device, then gets sink name from sinkRepository
  /// - Gets group from device and formats as "群組${group}"
  Future<Map<String, String?>> _loadDeviceInfo(
    BuildContext context,
    String? deviceId,
  ) async {
    if (deviceId == null) {
      return {'positionName': null, 'groupName': null};
    }

    final appContext = context.read<AppContext>();
    final device = await appContext.deviceRepository.getDevice(deviceId);

    String? positionName;
    String? groupName;

    if (device != null) {
      // Get position name from sink
      final String? sinkId = device['sinkId']?.toString();
      if (sinkId != null && sinkId.isNotEmpty) {
        final sinks = appContext.sinkRepository.getCurrentSinks();
        final sink = sinks.firstWhere(
          (s) => s.id == sinkId,
          orElse: () => const Sink(
            id: '',
            name: '',
            type: SinkType.custom,
            deviceIds: [],
          ),
        );
        if (sink.id.isNotEmpty) {
          positionName = sink.name;
        }
      }

      // Get group name
      final String? group = device['group']?.toString();
      if (group != null && group.isNotEmpty) {
        // PARITY: reef-b-app format: "群組${group}"
        groupName = '${l10n.group}$group';
      }
    }

    return {
      'positionName': positionName,
      'groupName': groupName,
    };
  }

  Widget _buildDeviceInfo(
    BuildContext context,
    AppContext appContext,
    LedSceneListController controller,
    String? positionName,
    String? groupName,
  ) {
    // PARITY: activity_led_main.xml ConstraintLayout structure
    // Key constraints:
    // - btn_ble: constraintTop=tv_name.top, constraintBottom=tv_position.bottom (垂直居中於 tv_name 和 tv_position 之間)
    // - tv_group: constraintTop=tv_position.top, constraintBottom=tv_position.bottom (與 tv_position 垂直居中)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device name and position/group column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device name (tv_name)
              // PARITY: marginStart=16dp, marginTop=8dp, marginEnd=4dp
              Text(
                deviceName,
                style: AppTextStyles.subheaderAccent.copyWith(
                  color: isConnected
                      ? AppColors.textPrimary // text_aaaa when connected
                      : AppColors.textSecondary, // text_aa when disconnected
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Position and Group row (tv_position + tv_group)
              // PARITY: constraintTop=tv_name.bottom, constraintStart=tv_name.start
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.xs, // dp_8 (spacing between name and position)
                ),
                child: Row(
                  children: [
                    // Position (tv_position)
                    // PARITY: caption2, text_aaa, constraintStart=tv_name.start
                    if (positionName != null)
                      Flexible(
                        child: Text(
                          positionName,
                          style: AppTextStyles.caption2.copyWith(
                            color: AppColors.textTertiary, // text_aaa
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      Text(
                        l10n.unassignedDevice,
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textTertiary, // text_aaa
                        ),
                      ),
                    // Group (tv_group)
                    // PARITY: caption2, text_aa, marginStart=4dp
                    if (groupName != null) ...[
                      SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                      Text(
                        '｜$groupName', // PARITY: "｜群組 A" format
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textSecondary, // text_aa
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // BLE state icon (btn_ble)
        // PARITY: 48×32dp, marginEnd=16dp
        // PARITY: constraintTop=tv_name.top, constraintBottom=tv_position.bottom (垂直居中於 tv_name 和 tv_position 之間)
        // PARITY: reef-b-app clickBtnBle() - toggles connect/disconnect
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xs, // dp_4 marginStart (to match tv_name marginEnd)
            right: AppSpacing.md, // dp_16 marginEnd
          ),
          child: GestureDetector(
            onTap: () => _handleBleIconTap(context, appContext, controller),
            child: _buildBleStateIcon(isConnected),
          ),
        ),
      ],
    );
  }

  /// Build BLE state icon.
  ///
  /// PARITY: reef-b-app uses ic_connect_background (green) / ic_disconnect_background (grey).
  /// PARITY: Using SvgPicture for ic_connect_background/ic_disconnect_background for 100% parity
  /// PARITY: 48×32dp (standard icon size from reef-b-app)
  Widget _buildBleStateIcon(bool isConnected) {
    // PARITY: Using SvgPicture for ic_connect_background/ic_disconnect_background for 100% parity
    // PARITY: 48×32dp from reef-b-app activity_led_main.xml btn_ble
    return SvgPicture.asset(
      isConnected
          ? 'assets/icons/ic_connect_background.svg'
          : 'assets/icons/ic_disconnect_background.svg',
      width: AppSpacing.xxxl + AppSpacing.xs, // dp_48 = 40 + 8
      height: AppSpacing.xxl, // dp_32
      fit: BoxFit.contain,
    );
  }

  /// Handle BLE icon tap.
  ///
  /// PARITY: Matches reef-b-app's LedMainViewModel.clickBtnBle() logic:
  /// - If previewing, stop preview first
  /// - If connected, disconnect the device
  /// - If disconnected, connect to the device
  Future<void> _handleBleIconTap(
    BuildContext context,
    AppContext appContext,
    LedSceneListController controller,
  ) async {
    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    // PARITY: reef-b-app clickBtnBle() - stop preview if active
    if (controller.isPreviewing) {
      await controller.stopPreview();
    }

    final l10n = AppLocalizations.of(context);

    try {
      if (isConnected) {
        // Disconnect device
        await appContext.disconnectDeviceUseCase.execute(deviceId: deviceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackbarDeviceDisconnected)),
          );
        }
      } else {
        // Connect device
        // PARITY: reef-b-app checks BLE permission before connecting
        await appContext.connectDeviceUseCase.execute(deviceId: deviceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackbarDeviceConnected)),
          );
        }
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, error.code)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, AppErrorCode.unknownError)),
          ),
        );
      }
    }
  }
}

