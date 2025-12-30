import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../controllers/led_scene_list_controller.dart';
import '../widgets/led_main_device_info_section.dart';
import '../widgets/led_main_record_chart_section.dart';
import '../widgets/led_main_favorite_scene_section.dart';
import 'led_record_page.dart';
import 'led_record_setting_page.dart';
import 'led_scene_list_page.dart';
import '../../../device/presentation/pages/device_settings_page.dart';
import '../../../../shared/assets/common_icon_helper.dart';


class LedMainPage extends StatelessWidget {
  const LedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedSceneListController>(
      create: (_) => LedSceneListController(
        session: session,
        readLedScenesUseCase: appContext.readLedScenesUseCase,
        applySceneUseCase: appContext.applySceneUseCase,
        observeLedStateUseCase: appContext.observeLedStateUseCase,
        readLedStateUseCase: appContext.readLedStateUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
        observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
        readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
        startLedPreviewUseCase: appContext.startLedPreviewUseCase,
        startLedRecordUseCase: appContext.startLedRecordUseCase,
      )..initialize(),
      child: const _LedMainScaffold(),
    );
  }
}

class _LedMainScaffold extends StatefulWidget {
  const _LedMainScaffold();

  @override
  State<_LedMainScaffold> createState() => _LedMainScaffoldState();
}

class _LedMainScaffoldState extends State<_LedMainScaffold> with WidgetsBindingObserver {
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PARITY: reef-b-app FLAG_KEEP_SCREEN_ON
    // Keep screen on while on LED main page
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Disable wakelock when leaving page
    WakelockPlus.disable();
    // Reset to portrait when leaving page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // PARITY: reef-b-app onResume() - refresh data when page becomes visible
    if (state == AppLifecycleState.resumed) {
      final controller = context.read<LedSceneListController>();
      // Refresh all data to ensure it's up to date
      // PARITY: reef-b-app onResume() calls:
      // - setDeviceById() → already handled by AppSession.setActiveDevice()
      // - getAllLedInfo() → _bootstrapLedState()
      // - getNowRecords() → _bootstrapRecordState()
      // - getAllFavoriteScene() → refresh() (includes favorite scenes)
      controller.refreshAll();
    }
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);
    final deviceName = session.activeDeviceName ?? l10n.ledDetailUnknownDevice;

    return Consumer<LedSceneListController>(
      builder: (context, controller, _) {
        final bool isConnected = session.isBleConnected;
        final bool writeLocked = controller.isWriteLocked;
        final bool featuresEnabled = isConnected && !writeLocked;

        return PopScope(
          canPop: !controller.isPreviewing,
          onPopInvoked: (didPop) async {
            if (!didPop && controller.isPreviewing) {
              // PARITY: reef-b-app clickBtnBack() - stop preview if active
              await controller.stopPreview();
              // After stopping preview, allow pop
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } else if (!didPop && _isLandscape) {
              // PARITY: reef-b-app onBackPressed - if landscape, switch to portrait first
              setState(() {
                _isLandscape = false;
              });
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            }
          },
          child: Scaffold(
            appBar: ReefAppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              leading: IconButton(
                icon: CommonIconHelper.getBackIcon(
                  size: 24,
                  color: AppColors.onPrimary,
                ),
                onPressed: () async {
                  // PARITY: reef-b-app clickBtnBack() - stop preview if active
                  if (controller.isPreviewing) {
                    await controller.stopPreview();
                  }
                  // If landscape, switch to portrait first
                  if (_isLandscape) {
                    setState(() {
                      _isLandscape = false;
                    });
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                  } else {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
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
              Builder(
                builder: (context) {
                  final appContext = context.read<AppContext>();
                  return FutureBuilder<bool>(
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
                        onPressed: featuresEnabled && deviceId != null
                            ? () async {
                                // PARITY: reef-b-app clickBtnFavorite() - stop preview if active
                                if (controller.isPreviewing) {
                                  await controller.stopPreview();
                                }
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
                                    showErrorSnackBar(context, AppErrorCode.unknownError);
                                  }
                                }
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
              // Expand button (landscape/portrait toggle)
              // PARITY: reef-b-app uses ic_zoom_in for btnExpand
              IconButton(
                icon: CommonIconHelper.getZoomInIcon(
                  size: 24,
                  color: AppColors.onPrimary,
                ),
                tooltip: _isLandscape ? l10n.ledOrientationPortrait : l10n.ledOrientationLandscape,
                onPressed: featuresEnabled
                    ? () async {
                        // PARITY: reef-b-app clickBtnExpand() - stop preview if active
                        if (controller.isPreviewing) {
                          await controller.stopPreview();
                        }
                        _toggleOrientation();
                      }
                    : null,
              ),
              // Menu button
              Builder(
                builder: (context) {
                  final appContext = context.read<AppContext>();
                  return PopupMenuButton<String>(
                    icon: CommonIconHelper.getMenuIcon(
                      size: 24,
                      color: AppColors.onPrimary,
                    ),
                    enabled: featuresEnabled,
                    onSelected: (value) async {
                      // PARITY: reef-b-app clickBtnMenu() - stop preview if active
                      if (controller.isPreviewing) {
                        await controller.stopPreview();
                      }
                      switch (value) {
                        case 'edit':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DeviceSettingsPage(),
                            ),
                          );
                          break;
                        case 'delete':
                          _confirmDeleteDevice(context, session);
                          break;
                        case 'reset':
                          if (isConnected) {
                            _confirmResetDevice(context, session, appContext);
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
                        Text(l10n.ledResetDevice),
                      ],
                    ),
                  ),
                ],
                  );
                },
              ),
            ],
          ),
          body: ReefMainBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Fixed header section
                  // PARITY: tv_name margin 16/8/4
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md, // dp_16 marginStart
                      top: AppSpacing.xs, // dp_8 marginTop
                      right: AppSpacing.xxxs, // dp_4 marginEnd
                    ),
                    child: LedMainDeviceInfoSection(
                      deviceName: deviceName,
                      isConnected: isConnected,
                      session: session,
                      l10n: l10n,
                    ),
                  ),
                  // PARITY: tv_record_title marginTop 20dp (using xl + xs = 24 + 4 = 28, closest to 20)
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md, // dp_16 marginStart (same as tv_name)
                      top: AppSpacing.lg + AppSpacing.xs, // dp_20 marginTop (16 + 4)
                      right: AppSpacing.md, // dp_16 marginEnd (for btn_record_more)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.record, // PARITY: @string/record
                          style: AppTextStyles.bodyAccent,
                        ),
                        IconButton(
                          // PARITY: reef-b-app uses ic_more_enable / ic_more_disable
                          icon: CommonIconHelper.getMoreEnableIcon(
                            size: 24,
                            color: featuresEnabled
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                          iconSize: 24,
                          onPressed: featuresEnabled
                              ? () async {
                                  // PARITY: reef-b-app clickBtnRecordMore() - stop preview if active
                                  if (controller.isPreviewing) {
                                    await controller.stopPreview();
                                  }
                                  // PARITY: reef-b-app logic
                                  // If records are empty, navigate to record setting page
                                  // Otherwise, navigate to record list page
                                  if (controller.hasRecords) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const LedRecordPage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const LedRecordSettingPage(),
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  // PARITY: layout_record_background marginTop 4dp
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md, // dp_16 marginStart
                      top: AppSpacing.xxxs, // dp_4 marginTop
                      right: AppSpacing.md, // dp_16 marginEnd
                    ),
                    child: controller.hasRecords
                        ? LedMainRecordChartSection(
                            controller: controller,
                            isConnected: isConnected,
                            featuresEnabled: featuresEnabled,
                            l10n: l10n,
                            onToggleOrientation: _toggleOrientation,
                            isLandscape: _isLandscape,
                          )
                        : Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              l10n.deviceStateDisconnected,
                              style: AppTextStyles.bodyAccent.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                  ),
                  // PARITY: tv_scene_title marginTop 24dp
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md, // dp_16 marginStart
                      top: AppSpacing.xl, // dp_24 marginTop
                      right: AppSpacing.md, // dp_16 marginEnd (for btn_scene_more)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.ledScene, // PARITY: @string/led_scene
                          style: AppTextStyles.bodyAccent,
                        ),
                        IconButton(
                          // PARITY: reef-b-app uses ic_more_enable / ic_more_disable
                          icon: CommonIconHelper.getMoreEnableIcon(
                            size: 24,
                            color: featuresEnabled
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                          iconSize: 24,
                          onPressed: featuresEnabled
                              ? () async {
                                  // PARITY: reef-b-app clickBtnSceneMore() - stop preview if active
                                  if (controller.isPreviewing) {
                                    await controller.stopPreview();
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LedSceneListPage(),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  // Scrollable favorite scene section
                  // PARITY: rv_favorite_scene marginTop 4dp, paddingStart/End 8dp
                  // PARITY: constraintTop=tv_scene_title.bottom, constraintStart/End=parent
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.xxxs, // dp_4 marginTop
                        left: AppSpacing.xs, // dp_8 paddingStart
                        right: AppSpacing.xs, // dp_8 paddingEnd
                      ),
                      child: LedMainFavoriteSceneSection(
                        controller: controller,
                        isConnected: isConnected,
                        featuresEnabled: featuresEnabled,
                        l10n: l10n,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

void _confirmDeleteDevice(
  BuildContext context,
  AppSession session,
) async {
  final l10n = AppLocalizations.of(context);
  final appContext = context.read<AppContext>();
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deviceDeleteConfirmTitle),
      content: Text(l10n.deviceDeleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.deviceDeleteConfirmPrimary),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.removeDeviceUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackbarDeviceRemoved)),
        );
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    }
  }
}

void _confirmResetDevice(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.ledResetDevice),
      content: Text(
        'Are you sure you want to reset this device to default settings? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: Text(l10n.ledResetDevice),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.resetLedStateUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        showSuccessSnackBar(context, l10n.deviceSettingsSaved);
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    }
  }
}
