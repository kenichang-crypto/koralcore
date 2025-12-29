import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/pump_head_settings_controller.dart';
import 'drop_type_page.dart';

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
        final bool isConnected = session.isBleConnected;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final allow = await _handleWillPop(l10n);
            if (allow && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: ReefAppBar(title: Text(l10n.dosingPumpHeadSettingsTitle)),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(ReefSpacing.xl),
                    children: [
                      Text(
                        l10n.dosingPumpHeadSummaryTitle(
                          widget.headId.toUpperCase(),
                        ),
                        style: ReefTextStyles.subheaderAccent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.sm),
                      Text(
                        l10n.dosingPumpHeadSettingsSubtitle,
                        style: ReefTextStyles.body.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.md),
                      if (!isConnected) ...[
                        const BleGuardBanner(),
                        const SizedBox(height: ReefSpacing.xl),
                      ],
                      _NameCard(
                        controller: _nameController,
                        errorText: _nameError,
                        isEnabled: !controller.isSaving,
                        l10n: l10n,
                      ),
                      const SizedBox(height: ReefSpacing.md),
                      _TankPlaceholderCard(l10n: l10n),
                      const SizedBox(height: ReefSpacing.md),
                      _DropTypeCard(l10n: l10n),
                      const SizedBox(height: ReefSpacing.md),
                      // PARITY: activity_drop_head_setting.xml tv_rotating_speed_title + btn_rotating_speed
                      // Rotating Speed Section (enabled="false" in XML)
                      Text(
                        l10n.dosingScheduleEditRotatingSpeedLabel, // init_rotating_speed
                        style: ReefTextStyles.caption1.copyWith(
                          color: ReefColors.textSecondary, // text_color_selector (disabled)
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
                      MaterialButton(
                        onPressed: null, // enabled="false" in XML
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
                        textColor: ReefColors.textSecondary, // text_color_selector (disabled)
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.dosingRotatingSpeedMedium, // TODO: Get actual rotating speed
                                style: ReefTextStyles.body.copyWith(
                                  color: ReefColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down, // ic_down
                              size: 20,
                              color: ReefColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.md),
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
                      const SizedBox(height: ReefSpacing.xl),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(ReefSpacing.xl),
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
                      const SizedBox(width: ReefSpacing.sm),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingPumpHeadSettingsNameLabel,
              style: ReefTextStyles.subheader.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
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
    return Card(
      child: ListTile(
        enabled: false,
        title: Text(
          l10n.dosingPumpHeadSettingsTankLabel,
          style: ReefTextStyles.subheader.copyWith(
            color: ReefColors.textPrimary,
          ),
        ),
        subtitle: Text(
          l10n.dosingPumpHeadSettingsTankPlaceholder,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        trailing: Text(
          l10n.comingSoon,
          style: ReefTextStyles.caption1Accent.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DropTypeCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _DropTypeCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: activity_drop_head_setting.xml tv_drop_type_title + btn_drop_type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_drop_type_title - caption1, 0dp width (constrained)
        Text(
          l10n.dropTypeTitle,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        // PARITY: btn_drop_type - marginTop 4dp, BackgroundMaterialButton style
        SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
        MaterialButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DropTypePage(),
              ),
            );
          },
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
                  l10n.dropTypeSubtitle, // TODO: Show actual drop type name
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
      ],
    );
  }
}

/// Delay time tile matching adapter_delay_time.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_delay_time.xml structure:
/// - ConstraintLayout: selectableItemBackground
/// - TextView: bg_aaa background, padding 12/8/12/8dp, body style, text_aaaa color
class _DelayTimeTile extends StatelessWidget {
  final String delayText;

  const _DelayTimeTile({required this.delayText});

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_delay_time.xml structure
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ReefSpacing.md, // dp_12 paddingStart/End
        vertical: ReefSpacing.xs, // dp_8 paddingTop/Bottom
      ),
      decoration: BoxDecoration(
        color: ReefColors.surfaceMuted, // bg_aaa background
      ),
      child: Text(
        delayText,
        style: ReefTextStyles.body.copyWith(
          color: ReefColors.textPrimary, // text_aaaa
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingPumpHeadSettingsDelayLabel,
              style: ReefTextStyles.subheader.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: currentDelay,
              items: delayOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: _DelayTimeTile(
                        delayText: l10n.dosingPumpHeadSettingsDelayOption(value),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isEnabled ? onChanged : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                helperText: l10n.dosingPumpHeadSettingsDelaySubtitle,
                helperStyle: ReefTextStyles.caption1.copyWith(
                  color: ReefColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
