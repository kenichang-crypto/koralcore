import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/pump_head_settings_controller.dart';

class PumpHeadSettingsPage extends StatelessWidget {
  final String headId;
  final String initialName;
  final int initialDelaySeconds;

  const PumpHeadSettingsPage({
    super.key,
    required this.headId,
    required this.initialName,
    this.initialDelaySeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    final appContext = context.read<AppContext>();
    return ChangeNotifierProvider<PumpHeadSettingsController>(
      create: (_) => PumpHeadSettingsController(
        headId: headId,
        session: session,
        updateUseCase: appContext.updatePumpHeadSettingsUseCase,
      ),
      child: _PumpHeadSettingsView(
        headId: headId,
        initialName: initialName,
        initialDelaySeconds: initialDelaySeconds,
      ),
    );
  }
}

class _PumpHeadSettingsView extends StatefulWidget {
  final String headId;
  final String initialName;
  final int initialDelaySeconds;

  const _PumpHeadSettingsView({
    required this.headId,
    required this.initialName,
    required this.initialDelaySeconds,
  });

  @override
  State<_PumpHeadSettingsView> createState() => _PumpHeadSettingsViewState();
}

class _PumpHeadSettingsViewState extends State<_PumpHeadSettingsView> {
  static const List<int> _delayOptions = [0, 5, 10, 20, 30];

  late TextEditingController _nameController;
  late int _selectedDelay;
  bool _isDirty = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedDelay = widget.initialDelaySeconds;
    _nameController.addListener(_handleNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _handleNameChanged() {
    if (_nameError != null && _nameController.text.trim().isNotEmpty) {
      setState(() {
        _nameError = null;
      });
    }
    _refreshDirtyFlag();
  }

  void _refreshDirtyFlag() {
    final bool nextDirty =
        _nameController.text.trim() != widget.initialName.trim() ||
        _selectedDelay != widget.initialDelaySeconds;
    if (nextDirty != _isDirty) {
      setState(() {
        _isDirty = nextDirty;
      });
    }
  }

  Future<bool> _confirmDiscard(AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.dosingPumpHeadSettingsUnsavedTitle),
          content: Text(l10n.dosingPumpHeadSettingsUnsavedMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.dosingPumpHeadSettingsUnsavedStay),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.dosingPumpHeadSettingsUnsavedDiscard),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _handleWillPop(AppLocalizations l10n) async {
    if (!_isDirty) {
      return true;
    }
    return _confirmDiscard(l10n);
  }

  Future<void> _handleCancel(AppLocalizations l10n) async {
    if (!_isDirty || await _confirmDiscard(l10n)) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleSave(AppLocalizations l10n, bool isConnected) async {
    if (!isConnected) {
      await showBleGuardDialog(context);
      return;
    }

    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = l10n.dosingPumpHeadSettingsNameEmpty;
      });
      return;
    }

    final controller = context.read<PumpHeadSettingsController>();
    final bool success = await controller.save(
      name: trimmedName,
      delaySeconds: _selectedDelay,
    );
    if (!mounted) return;

    if (success) {
      setState(() {
        _isDirty = false;
      });
      Navigator.of(context).pop(true);
    } else {
      final AppErrorCode code =
          controller.lastErrorCode ?? AppErrorCode.unknownError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(describeAppError(l10n, code))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, PumpHeadSettingsController>(
      builder: (context, session, controller, _) {
        final theme = Theme.of(context);
        final bool isConnected = session.isBleConnected;

        return WillPopScope(
          onWillPop: () => _handleWillPop(l10n),
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.dosingPumpHeadSettingsTitle)),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.spacingXL),
                    children: [
                      Text(
                        l10n.dosingPumpHeadSummaryTitle(
                          widget.headId.toUpperCase(),
                        ),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        l10n.dosingPumpHeadSettingsSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      if (!isConnected) ...[
                        const BleGuardBanner(),
                        const SizedBox(height: AppDimensions.spacingXL),
                      ],
                      _NameCard(
                        controller: _nameController,
                        errorText: _nameError,
                        isEnabled: !controller.isSaving,
                        l10n: l10n,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      _TankPlaceholderCard(l10n: l10n),
                      const SizedBox(height: AppDimensions.spacingL),
                      _DelayCard(
                        currentDelay: _selectedDelay,
                        delayOptions: _delayOptions,
                        isEnabled: !controller.isSaving,
                        l10n: l10n,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedDelay = value;
                          });
                          _refreshDirtyFlag();
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isSaving
                              ? null
                              : () => _handleCancel(l10n),
                          child: Text(l10n.dosingPumpHeadSettingsCancel),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: FilledButton(
                          onPressed: controller.isSaving
                              ? null
                              : () => _handleSave(l10n, isConnected),
                          child: controller.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.dosingPumpHeadSettingsSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NameCard extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isEnabled;
  final AppLocalizations l10n;

  const _NameCard({
    required this.controller,
    required this.errorText,
    required this.isEnabled,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingPumpHeadSettingsNameLabel,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: controller,
              enabled: isEnabled,
              decoration: InputDecoration(
                hintText: l10n.dosingPumpHeadSettingsNameHint,
                errorText: errorText,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankPlaceholderCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _TankPlaceholderCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        enabled: false,
        title: Text(l10n.dosingPumpHeadSettingsTankLabel),
        subtitle: Text(
          l10n.dosingPumpHeadSettingsTankPlaceholder,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey700),
        ),
        trailing: Text(l10n.comingSoon),
      ),
    );
  }
}

class _DelayCard extends StatelessWidget {
  final int currentDelay;
  final List<int> delayOptions;
  final bool isEnabled;
  final AppLocalizations l10n;
  final ValueChanged<int?> onChanged;

  const _DelayCard({
    required this.currentDelay,
    required this.delayOptions,
    required this.isEnabled,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingPumpHeadSettingsDelayLabel,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            DropdownButtonFormField<int>(
              initialValue: currentDelay,
              items: delayOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        l10n.dosingPumpHeadSettingsDelayOption(value),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isEnabled ? onChanged : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                helperText: l10n.dosingPumpHeadSettingsDelaySubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
