import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/app_error_presenter.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';

/// DropSettingPage
///
/// Page for editing Dosing device-specific settings.
/// Features:
/// - Device name editing
/// - Sink position selection
/// - Delay time setting (requires BLE connection)
class DropSettingPage extends StatefulWidget {
  const DropSettingPage({super.key});

  @override
  State<DropSettingPage> createState() => _DropSettingPageState();
}

class _DropSettingPageState extends State<DropSettingPage> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  int _selectedDelayTime = 60; // Default: 1 minute

  final List<int> _delayTimeOptions = [15, 30, 60, 120, 180, 240, 300]; // seconds

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

  String _formatDelayTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      return '${minutes}min';
    }
  }

  Future<void> _saveSettings() async {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final deviceId = session.activeDeviceId;
    final l10n = AppLocalizations.of(context);

    if (deviceId == null) {
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deviceNameEmpty)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await appContext.updateDeviceNameUseCase.execute(
        deviceId: deviceId,
        name: newName,
      );

      // TODO: Set delay time via BLE if connected
      // if (session.isBleConnected) {
      //   await appContext.setDosingDelayTimeUseCase.execute(
      //     deviceId: deviceId,
      //     delayTimeSeconds: _selectedDelayTime,
      //   );
      // }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deviceSettingsSaved)),
        );
      }
    } on AppError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(describeAppError(l10n, error.code)),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
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


  void _showDelayTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(ReefSpacing.md),
              child: Text(
                AppLocalizations.of(context).delayTime,
                style: ReefTextStyles.subheader1.copyWith(
                  color: ReefColors.textPrimary,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _delayTimeOptions.length,
              itemBuilder: (context, index) {
                final delayTime = _delayTimeOptions[index];
                final isSelected = delayTime == _selectedDelayTime;
                return ListTile(
                  title: Text(_formatDelayTime(delayTime)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: ReefColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDelayTime = delayTime;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final isConnected = session.isBleConnected;

    return Scaffold(
      appBar: ReefAppBar(
        backgroundColor: ReefColors.primaryStrong,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.dropSettingTitle,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(ReefSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ReefColors.onPrimary),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: !isConnected || _isLoading
                  ? null
                  : _saveSettings,
              child: Text(
                l10n.actionSave,
                style: ReefTextStyles.subheaderAccent.copyWith(
                  color: ReefColors.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        // PARITY: activity_drop_setting.xml layout_drop_setting padding 16/12/16/12dp
        padding: EdgeInsets.only(
          left: ReefSpacing.md, // dp_16 paddingStart
          top: ReefSpacing.md, // dp_12 paddingTop
          right: ReefSpacing.md, // dp_16 paddingEnd
          bottom: ReefSpacing.md, // dp_12 paddingBottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Name Section
            // PARITY: tv_device_name_title - caption1, 0dp width (constrained)
            Text(
              l10n.deviceName,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
            // PARITY: layout_name - marginTop 4dp, TextInputLayout style
            SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius, no border
                filled: true,
                fillColor: ReefColors.surfaceMuted, // bg_aaa (#F7F7F7)
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs), // dp_4
                  borderSide: BorderSide.none, // boxStrokeWidth 0dp
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ReefSpacing.md,
                  vertical: ReefSpacing.sm,
                ),
              ),
              // PARITY: edt_name - body textAppearance
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary,
              ),
              enabled: !_isLoading,
              maxLines: 1,
            ),

            // Sink Position Section
            // PARITY: tv_device_position_title - marginTop 16dp, caption1
            SizedBox(height: ReefSpacing.md), // dp_16 marginTop
            Text(
              l10n.sinkPosition,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
            // PARITY: btn_position - marginTop 4dp, BackgroundMaterialButton style
            SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
            MaterialButton(
              onPressed: !_isLoading && isConnected
                  ? () {
                      // TODO: Navigate to SinkPositionPage
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.sinkPositionFeatureComingSoon),
                        ),
                      );
                    }
                  : null,
              // PARITY: BackgroundMaterialButton style
              color: ReefColors.surfaceMuted, // bg_aaa background
              elevation: 0, // elevation 0dp
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ReefRadius.xs), // 4dp cornerRadius
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ReefSpacing.md,
                vertical: ReefSpacing.sm,
              ),
              textColor: ReefColors.textPrimary, // text_aaaa
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.sinkPositionNotSet, // TODO: Show actual sink name
                      style: ReefTextStyles.body.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right, // ic_next
                    size: 20,
                    color: ReefColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Delay Time Section
            // PARITY: tv_delay_time_title - marginTop 16dp, caption1
            SizedBox(height: ReefSpacing.md), // dp_16 marginTop
            Text(
              l10n.delayTime,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
            // PARITY: btn_delay_time - marginTop 4dp, BackgroundMaterialButton style, icon ic_down
            SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
            MaterialButton(
              onPressed: isConnected && !_isLoading ? _showDelayTimePicker : null,
              // PARITY: BackgroundMaterialButton style
              color: ReefColors.surfaceMuted, // bg_aaa background
              elevation: 0, // elevation 0dp
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ReefRadius.xs), // 4dp cornerRadius
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ReefSpacing.md,
                vertical: ReefSpacing.sm,
              ),
              textColor: ReefColors.textPrimary, // text_aaaa
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatDelayTime(_selectedDelayTime),
                      style: ReefTextStyles.body.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down, // ic_down
                    size: 20,
                    color: ReefColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Note: Device Info Section removed to match activity_drop_setting.xml
            // (activity_drop_setting.xml only has device name, position, and delay time sections)
          ],
        ),
      ),
    );
  }
}

