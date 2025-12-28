import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';

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
      appBar: AppBar(
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
      body: ListView(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        children: [
          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: ReefSpacing.lg),
          ],
          // Device Name Section
          Text(
            l10n.deviceName,
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReefSpacing.sm),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n.deviceNameHint,
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

          // Delay Time Section
          Text(
            l10n.delayTime,
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
            child: ListTile(
              title: Text(l10n.delayTime),
              subtitle: Text(
                _formatDelayTime(_selectedDelayTime),
                style: ReefTextStyles.body1.copyWith(
                  color: ReefColors.textPrimary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled: isConnected && !_isLoading,
              onTap: isConnected ? _showDelayTimePicker : null,
            ),
          ),
          if (!isConnected) ...[
            const SizedBox(height: ReefSpacing.sm),
            Text(
              l10n.delayTimeRequiresConnection,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: ReefSpacing.xl),

          // Sink Position Section
          Text(
            l10n.sinkPosition,
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
            child: ListTile(
              title: Text(l10n.sinkPosition),
              subtitle: Text(
                l10n.sinkPositionNotSet,
                style: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to SinkPositionPage
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.sinkPositionFeatureComingSoon),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: ReefSpacing.xl),

          // Device Info Section
          Text(
            l10n.deviceInfo,
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
                    label: l10n.deviceId,
                    value: session.activeDeviceId ?? '-',
                  ),
                  const SizedBox(height: ReefSpacing.md),
                  _InfoRow(
                    label: 'State',
                    value: isConnected ? 'Connected' : 'Disconnected',
                  ),
                ],
              ),
            ),
          ),
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

