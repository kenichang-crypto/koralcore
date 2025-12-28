import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../components/app_error_presenter.dart';
import '../../sink/pages/sink_position_page.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ReefColors.primaryStrong,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        title: Text(
          l10n.ledSettingTitle,
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
              onTap: () async {
                final appContext = context.read<AppContext>();
                final String? activeDeviceId = session.activeDeviceId;
                String? currentSinkId;
                if (activeDeviceId != null) {
                  final device = await appContext.deviceRepository.getDevice(activeDeviceId);
                  currentSinkId = device?['sinkId']?.toString();
                }
                final String? selectedSinkId = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => SinkPositionPage(
                      initialSinkId: currentSinkId,
                    ),
                  ),
                );
                // TODO: Update device sink_id if selectedSinkId is not null
                if (selectedSinkId != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedSinkId.isEmpty
                            ? l10n.sinkPositionNotSet
                            : l10n.sinkPositionSet,
                      ),
                    ),
                  );
                }
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
                    value: session.isBleConnected ? 'Connected' : 'Disconnected',
                  ),
                ],
              ),
            ),
          ),

          // Note: Master/Slave relationship management will be added in future
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

