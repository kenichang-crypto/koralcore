import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../sink/presentation/pages/sink_position_page.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// LedSettingPage
///
/// Page for editing LED device-specific settings.
/// Features:
/// - Device name editing
/// - Sink position selection
/// - Master/slave relationship management (future)
class LedSettingPage extends StatefulWidget {
  const LedSettingPage({super.key});

  @override
  State<LedSettingPage> createState() => _LedSettingPageState();
}

class _LedSettingPageState extends State<LedSettingPage> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _currentSinkId;
  String? _currentSinkName;
  String? _selectedSinkId;
  String? _deviceType;
  String? _currentGroup;
  bool? _currentMaster;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;
    if (deviceId == null) return;

    final device = await appContext.deviceRepository.getDevice(deviceId);
    if (device != null) {
      final deviceName = device['name']?.toString() ?? session.activeDeviceName ?? '';
      _nameController = TextEditingController(text: deviceName);
      
      _currentSinkId = device['sinkId']?.toString();
      _selectedSinkId = _currentSinkId;
      _deviceType = device['type']?.toString();
      _currentGroup = device['group']?.toString();
      _currentMaster = device['isMaster'] == true;

      // Load sink name
      if (_currentSinkId != null && _currentSinkId!.isNotEmpty) {
        final sinks = appContext.sinkRepository.getCurrentSinks();
        final sink = sinks.firstWhere(
          (s) => s.id == _currentSinkId,
          orElse: () => const Sink(
            id: '',
            name: '',
            type: SinkType.custom,
            deviceIds: [],
          ),
        );
        if (sink.id.isNotEmpty) {
          _currentSinkName = sink.name;
        }
      }
    } else {
      final deviceName = session.activeDeviceName ?? '';
      _nameController = TextEditingController(text: deviceName);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Check if device can be moved to another sink.
  ///
  /// PARITY: Matches reef-b-app's LedSettingViewModel.canMoveDevice().
  /// - Unassigned devices can always be moved
  /// - If group has only 1 device, master can be moved
  /// - If group has more than 1 device, master cannot be moved
  Future<bool> _canMoveDevice() async {
    if (_currentSinkId == null || _currentGroup == null) {
      // Unassigned device, can be moved
      return true;
    }

    if (_currentMaster != true) {
      // Not master, can be moved
      return true;
    }

    // Check if group has other devices
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;
    if (deviceId == null) return false;

    final List<Map<String, dynamic>> groupDevices =
        await appContext.deviceRepository.getDevicesBySinkIdAndGroup(
      _currentSinkId!,
      _currentGroup!,
    );

    // If group has only 1 device (this device), master can be moved
    return groupDevices.length <= 1;
  }

  Future<void> _saveSettings() async {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;
    final l10n = AppLocalizations.of(context);

    if (deviceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, AppErrorCode.noActiveDevice))),
        );
      }
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deviceNameEmpty)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update device name
      await appContext.updateDeviceNameUseCase.execute(
        deviceId: deviceId,
        name: newName,
      );

      // Update sink assignment if changed
      if (_selectedSinkId != _currentSinkId) {
        // Check if device can be moved (master restriction)
        final bool canMove = await _canMoveDevice();
        if (!canMove) {
          // Show error dialog (PARITY: reef-b-app's createLedMoveMasterDialog)
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.masterSetting),
                content: Text(l10n.errorLedMasterCannotMove),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionConfirm),
                  ),
                ],
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Update sink assignment
        await appContext.updateDeviceSinkUseCase.execute(
          deviceId: deviceId,
          newSinkId: _selectedSinkId,
          currentSinkId: _currentSinkId,
          deviceType: _deviceType ?? 'LED',
          currentGroup: _currentGroup,
          currentMaster: _currentMaster,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deviceSettingsSaved)));
      }
    } on AppError catch (error) {
      _setError(error.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    } catch (error) {
      _setError(AppErrorCode.unknownError);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, AppErrorCode.unknownError)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setError(AppErrorCode code) {
    // Error is displayed via SnackBar in catch blocks
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: AppColors.primaryStrong,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.ledSettingTitle,
          style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: !session.isBleConnected || _isLoading
                  ? null
                  : _saveSettings,
              child: Text(
                l10n.actionSave,
                style: AppTextStyles.subheaderAccent.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        // PARITY: activity_led_setting.xml layout_led_setting padding 16/12/16/12dp
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_16 paddingStart
          top: AppSpacing.md, // dp_12 paddingTop
          right: AppSpacing.md, // dp_16 paddingEnd
          bottom: AppSpacing.md, // dp_12 paddingBottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Name Section
            // PARITY: tv_device_name_title - caption1, 0dp width (constrained)
            Text(
              l10n.deviceName,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            // PARITY: layout_name - marginTop 4dp, TextInputLayout style
            // TextInputLayout: bg_aaa background, 4dp cornerRadius, no border, no hint
            SizedBox(height: AppSpacing.xs), // dp_4 marginTop
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius, no border
                filled: true,
                fillColor: AppColors.surfaceMuted, // bg_aaa (#F7F7F7)
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs), // dp_4
                  borderSide: BorderSide.none, // boxStrokeWidth 0dp
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, // Standard padding
                  vertical: AppSpacing.sm,
                ),
              ),
              // PARITY: edt_name - body textAppearance
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
              enabled: !_isLoading,
              maxLines: 1,
            ),

            // Sink Position Section
            // PARITY: tv_device_position_title - marginTop 16dp, caption1
            SizedBox(height: AppSpacing.md), // dp_16 marginTop
            Text(
              l10n.sinkPosition,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            // PARITY: btn_position - marginTop 4dp, BackgroundMaterialButton style
            // BackgroundMaterialButton: bg_aaa background, 4dp cornerRadius, elevation 0dp,
            // body textAppearance, icon at end, textAlignment textStart, maxLines 1, ellipsize end
            SizedBox(height: AppSpacing.xs), // dp_4 marginTop
            MaterialButton(
              onPressed: !_isLoading && session.isBleConnected
                  ? () async {
                      // Check if device can be moved (master restriction)
                      final bool canMove = await _canMoveDevice();
                      if (!canMove) {
                        // Show error dialog (PARITY: reef-b-app's createLedMoveMasterDialog)
                        if (mounted) {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.masterSetting),
                              content: Text(l10n.errorLedMasterCannotMove),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(l10n.actionConfirm),
                                ),
                              ],
                            ),
                          );
                        }
                        return;
                      }

                      final String? selectedSinkId = await Navigator.of(context)
                          .push<String>(
                            MaterialPageRoute(
                              builder: (_) => SinkPositionPage(
                                initialSinkId: _currentSinkId,
                              ),
                            ),
                          );
                      
                      if (selectedSinkId != null && mounted) {
                        setState(() {
                          _selectedSinkId = selectedSinkId.isEmpty ? null : selectedSinkId;
                          
                          // Update sink name display
                          if (_selectedSinkId == null || _selectedSinkId!.isEmpty) {
                            _currentSinkName = null;
                          } else {
                            final appContext = context.read<AppContext>();
                            final sinks = appContext.sinkRepository.getCurrentSinks();
                            final sink = sinks.firstWhere(
                              (s) => s.id == _selectedSinkId,
                              orElse: () => const Sink(
                                id: '',
                                name: '',
                                type: SinkType.custom,
                                deviceIds: [],
                              ),
                            );
                            _currentSinkName = sink.id.isNotEmpty ? sink.name : null;
                          }
                        });
                      }
                    }
                  : null,
              // PARITY: BackgroundMaterialButton style
              color: AppColors.surfaceMuted, // bg_aaa background
              elevation: 0, // elevation 0dp
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppRadius.xs,
                ), // 4dp cornerRadius
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              textColor: AppColors.textPrimary, // text_aaaa
              // PARITY: textAppearance body, textAlignment textStart, icon at end
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _currentSinkName ?? l10n.sinkPositionNotSet,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  CommonIconHelper.getNextIcon(
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Note: Device Info Section removed to match activity_led_setting.xml
            // (activity_led_setting.xml only has device name and position sections)
          ],
        ),
      ),
    );
  }
}
