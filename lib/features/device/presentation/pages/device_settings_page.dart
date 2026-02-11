import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';

/// DeviceSettingsPage
///
/// Page for editing device settings (name, position, etc.)
/// Currently supports editing device name only.
/// Position (Sink) management will be added in future phases.
class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  // ignore: unused_field
  AppErrorCode? _lastErrorCode;

  @override
  void initState() {
    super.initState();
    final session = context.read<AppSession>();
    final deviceName = session.activeDeviceName ?? '';
    _nameController = TextEditingController(text: deviceName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;
    final l10n = AppLocalizations.of(context);

    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }
    // KC-A-FINAL: Gate on device ready state
    if (!session.isReady) {
      _setError(AppErrorCode.deviceNotReady);
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _setError(AppErrorCode.invalidParam);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deviceNameEmpty)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _lastErrorCode = null;
    });

    try {
      await appContext.updateDeviceNameUseCase.execute(
        deviceId: deviceId,
        name: newName,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deviceSettingsSaved)),
        );
      }
    } on AppError catch (error) {
      _setError(error.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, error.code)),
          ),
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
    setState(() {
      _lastErrorCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    // ignore: unused_local_variable
    final deviceName = session.activeDeviceName ?? l10n.deviceSettingsTitle;

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: AppColors.primaryStrong,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.deviceSettingsTitle,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
          ),
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: !session.isReady || _isLoading
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
        // (device_settings_page uses similar layout pattern)
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_16 paddingStart
          top: AppSpacing.md, // dp_12 paddingTop
          right: AppSpacing.md, // dp_16 paddingEnd
          bottom: AppSpacing.md, // dp_12 paddingBottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!session.isBleConnected) ...[
              const BleGuardBanner(),
              SizedBox(height: AppSpacing.md), // dp_16 marginTop
            ],
            // Device Name Section
            // PARITY: tv_device_name_title - caption1, 0dp width (constrained)
            Text(
              l10n.deviceName,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            // PARITY: layout_name - marginTop 4dp, TextInputLayout style
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
                  horizontal: AppSpacing.md,
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

            // Note: Device Info Section removed to match activity_led_setting.xml pattern
            // (activity_led_setting.xml only has device name and position sections)
            // Note: Position (Sink) management will be added in future phases
            // as it requires SinkRepository integration
          ],
        ),
      ),
    );
  }
}

