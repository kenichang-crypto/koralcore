import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../widgets/dosing_main_pump_head_list.dart';
import '../widgets/dosing_main_entry_tile.dart';
import 'dosing_main_page_helpers.dart'
    show confirmDeleteDevice, confirmResetDevice, handlePlayDosing, handleConnect, handleDisconnect;
import 'manual_dosing_page.dart';
import 'pump_head_detail_page.dart';
import 'pump_head_schedule_page.dart';
import 'pump_head_calibration_page.dart';
import '../../../device/presentation/pages/device_settings_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';


class DosingMainPage extends StatelessWidget {
  const DosingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final appContext = context.read<AppContext>();
    final l10n = AppLocalizations.of(context);
    final bool isConnected = session.isBleConnected;
    final deviceName = session.activeDeviceName ?? l10n.dosingHeader;

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getBackIcon(
            size: 24,
            color: AppColors.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          deviceName,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Favorite button
          FutureBuilder<bool>(
            future: session.activeDeviceId != null
                ? appContext.deviceRepository.isDeviceFavorite(session.activeDeviceId!)
                : Future.value(false),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              final deviceId = session.activeDeviceId;
              return IconButton(
                icon: isFavorite
                    ? CommonIconHelper.getFavoriteSelectIcon(
                        size: 24,
                        color: AppColors.error,
                      )
                    : CommonIconHelper.getFavoriteUnselectIcon(
                        size: 24,
                        color: AppColors.onPrimary.withValues(alpha: 0.7),
                      ),
                tooltip: isFavorite ? l10n.deviceActionUnfavorite : l10n.deviceActionFavorite,
                onPressed: isConnected && deviceId != null
                    ? () async {
                        try {
                          await appContext.toggleFavoriteDeviceUseCase.execute(
                            deviceId: deviceId,
                          );
                          if (context.mounted) {
                            final l10n = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? l10n.deviceUnfavorited
                                      : l10n.deviceFavorited,
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                                showErrorSnackBar(
                                  context,
                                  AppErrorCode.unknownError,
                                );
                          }
                        }
                      }
                    : null,
              );
            },
          ),
          // Menu button
          PopupMenuButton<String>(
            icon: CommonIconHelper.getMenuIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            enabled: isConnected,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeviceSettingsPage(),
                    ),
                  );
                  break;
                case 'delete':
                  confirmDeleteDevice(context, session, appContext);
                  break;
                case 'reset':
                  if (isConnected) {
                    confirmResetDevice(context, session, appContext);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.deviceStateDisconnected)),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    CommonIconHelper.getEditIcon(size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.deviceActionEdit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    CommonIconHelper.getDeleteIcon(
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10n.deviceActionDelete,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    CommonIconHelper.getResetIcon(size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.dosingResetDevice),
                  ],
                ),
              ),
            ],
          ),
          // BLE connection button
          IconButton(
            icon: CommonIconHelper.getBluetoothIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            tooltip: isConnected ? l10n.deviceActionDisconnect : l10n.deviceActionConnect,
            onPressed: isConnected
                ? () => handleDisconnect(context, session, appContext)
                : () => handleConnect(context, session, appContext),
          ),
        ],
      ),
      body: ReefMainBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Fixed header section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dosingSubHeader,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.dosingPumpHeadsHeader,
                      style: AppTextStyles.title2.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.dosingPumpHeadsSubheader,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable pump head list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl,
                  ),
                  children: [
                    DosingMainPumpHeadList(
                      isConnected: isConnected,
                      appContext: appContext,
                      session: session,
                      onHeadTap: (headId) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PumpHeadDetailPage(headId: headId),
                          ),
                        );
                      },
                      onHeadPlay: isConnected
                          ? (headId) => handlePlayDosing(context, session, appContext, headId)
                          : null,
                    ),
                    // PARITY: Entry tiles (Schedule, Manual, Calibration, History)
                    // These are not in the XML, but are part of the Flutter implementation
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          DosingMainEntryTile(
                            title: l10n.dosingEntrySchedule,
                            subtitle: l10n.dosingScheduleOverviewSubtitle,
                            enabled: isConnected,
                            onTapWhenEnabled: () {
                              // Navigate to first pump head's schedule page
                              final firstHeadId = _getFirstPumpHeadId(session);
                              if (firstHeadId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PumpHeadSchedulePage(headId: firstHeadId),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                                );
                              }
                            },
                          ),
                          DosingMainEntryTile(
                            title: l10n.dosingEntryManual,
                            subtitle: l10n.dosingManualPageSubtitle,
                            enabled: isConnected,
                            onTapWhenEnabled: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ManualDosingPage()),
                              );
                            },
                          ),
                          DosingMainEntryTile(
                            title: l10n.dosingEntryCalibration,
                            subtitle: l10n.dosingCalibrationHistorySubtitle,
                            enabled: isConnected,
                            onTapWhenEnabled: () {
                              // Navigate to first pump head's calibration page
                              final firstHeadId = _getFirstPumpHeadId(session);
                              if (firstHeadId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PumpHeadCalibrationPage(headId: firstHeadId),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                                );
                              }
                            },
                          ),
                          DosingMainEntryTile(
                            title: l10n.dosingEntryHistory,
                            subtitle: l10n.dosingHistorySubtitle,
                            enabled: isConnected,
                            onTapWhenEnabled: () {
                              // Navigate to first pump head's detail page (which shows record history)
                              final firstHeadId = _getFirstPumpHeadId(session);
                              if (firstHeadId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PumpHeadDetailPage(headId: firstHeadId),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the first available pump head ID
  String? _getFirstPumpHeadId(AppSession session) {
    final pumpHeads = session.pumpHeads;
    if (pumpHeads.isEmpty) {
      return null;
    }
    // Return the first pump head's headId (e.g., 'A', 'B', 'C', 'D')
    return pumpHeads.first.headId;
  }
}
