import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../../theme/reef_colors.dart';
import '../../../../theme/reef_radius.dart';
import '../../../../theme/reef_spacing.dart';
import '../../../../theme/reef_text.dart';

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

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _setError(AppErrorCode.invalidParam);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deviceNameEmpty ?? 'Device name cannot be empty')),
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
          SnackBar(content: Text(l10n.deviceSettingsSaved ?? 'Device settings saved')),
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
          SnackBar(content: Text('Failed to save settings: $error')),
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
    final deviceName = session.activeDeviceName ?? l10n.deviceSettingsTitle ?? 'Device Settings';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ReefColors.primaryStrong,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.deviceSettingsTitle ?? 'Device Settings',
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
              onPressed: !session.isBleConnected || _isLoading
                  ? null
                  : _saveSettings,
              child: Text(
                l10n.actionSave ?? 'Save',
                style: ReefTextStyles.subheaderAccent.copyWith(
                  color: ReefColors.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        children: [
          if (!session.isBleConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: ReefSpacing.lg),
          ],
          // Device Name Section
          Text(
            l10n.deviceName ?? 'Device Name',
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReefSpacing.sm),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n.deviceNameHint ?? 'Enter device name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ReefRadius.md),
              ),
              filled: true,
              fillColor: ReefColors.surface,
            ),
            style: ReefTextStyles.body1.copyWith(
              color: ReefColors.textPrimary,
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: ReefSpacing.xl),

          // Device Info Section (read-only)
          Text(
            l10n.deviceInfo ?? 'Device Information',
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReefSpacing.sm),
          Card(
            color: ReefColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReefRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ReefSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: l10n.deviceId ?? 'Device ID',
                    value: session.activeDeviceId ?? '-',
                  ),
                  const SizedBox(height: ReefSpacing.md),
                  _InfoRow(
                    label: l10n.deviceState ?? 'State',
                    value: session.isBleConnected
                        ? (l10n.deviceStateConnected ?? 'Connected')
                        : (l10n.deviceStateDisconnected ?? 'Disconnected'),
                  ),
                ],
              ),
            ),
          ),

          // Note: Position (Sink) management will be added in future phases
          // as it requires SinkRepository integration
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: ReefTextStyles.body1.copyWith(
              color: ReefColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

