import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/read_led_schedules.dart';
import '../../../../domain/usecases/led/save_led_schedule_usecase.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../models/led_schedule_summary.dart';

class LedScheduleEditPage extends StatefulWidget {
  final LedScheduleSummary? initialSchedule;

  const LedScheduleEditPage({super.key, this.initialSchedule});

  @override
  State<LedScheduleEditPage> createState() => _LedScheduleEditPageState();
}

class _LedScheduleEditPageState extends State<LedScheduleEditPage> {
  static const String _whiteChannelId = 'white';
  static const String _blueChannelId = 'blue';
  static const Map<String, int> _defaultChannelValues = {
    _whiteChannelId: 60,
    _blueChannelId: 80,
  };

  late final TextEditingController _nameController;
  late LedScheduleType _type;
  late LedScheduleRecurrence _recurrence;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isEnabled;
  final Map<String, double> _channelValues = {};

  bool _isSaving = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final LedScheduleSummary? summary = widget.initialSchedule;
    _nameController = TextEditingController(text: summary?.title ?? '');
    _type = summary?.type ?? LedScheduleType.dailyProgram;
    _recurrence = summary?.recurrence ?? LedScheduleRecurrence.everyday;
    _startTime = summary?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
    _endTime = summary?.endTime ?? const TimeOfDay(hour: 20, minute: 0);
    _isEnabled = summary?.isEnabled ?? true;

    final Map<String, int> initialChannels = {
      for (final channel in summary?.channels ?? const [])
        channel.id: channel.percentage,
    };
    for (final entry in _defaultChannelValues.entries) {
      _channelValues[entry.key] = (initialChannels[entry.key] ?? entry.value)
          .toDouble();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = context.watch<AppSession>();
    final bool isConnected = session.isBleConnected;
    final bool isReady = session.isReady;
    final String title = widget.initialSchedule == null
        ? l10n.ledScheduleEditTitleNew
        : l10n.ledScheduleEditTitleEdit;

    return Scaffold(
      appBar: ReefAppBar(title: Text(title)),
      body: ListView(
        // PARITY: General settings page layout - padding 16/12/16/40dp
        padding: EdgeInsets.only(
          left: AppSpacing.md, // dp_16 paddingStart
          top: AppSpacing.sm, // dp_12 paddingTop
          right: AppSpacing.md, // dp_16 paddingEnd
          bottom: 40, // dp_40 paddingBottom
        ),
        children: [
          Text(
            l10n.ledScheduleEditDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildNameField(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildTypeSelector(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildTimePickers(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildRecurrenceSelector(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildEnabledToggle(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildChannelSection(l10n),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: !isReady || _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.ledScheduleEditSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: l10n.ledScheduleEditNameLabel,
        hintText: l10n.ledScheduleEditNameHint,
        errorText: _nameError,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_nameError != null) {
          setState(() => _nameError = null);
        }
      },
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ledScheduleEditTypeLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<LedScheduleType>(
          value: _type,
          items: [
            DropdownMenuItem(
              value: LedScheduleType.dailyProgram,
              child: Text(l10n.ledScheduleTypeDaily),
            ),
            DropdownMenuItem(
              value: LedScheduleType.customWindow,
              child: Text(l10n.ledScheduleTypeCustom),
            ),
            DropdownMenuItem(
              value: LedScheduleType.sceneBased,
              child: Text(l10n.ledScheduleTypeScene),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => _type = value);
          },
        ),
      ],
    );
  }

  Widget _buildTimePickers(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ledScheduleEditStartLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _TimeButton(
                label: materialLocalizations.formatTimeOfDay(_startTime),
                onPressed: _isSaving ? null : () => _pickTime(isStart: true),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TimeButton(
                label: materialLocalizations.formatTimeOfDay(_endTime),
                onPressed: _isSaving ? null : () => _pickTime(isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurrenceSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ledScheduleEditRecurrenceLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<LedScheduleRecurrence>(
          value: _recurrence,
          items: [
            DropdownMenuItem(
              value: LedScheduleRecurrence.everyday,
              child: Text(l10n.ledScheduleRecurrenceDaily),
            ),
            DropdownMenuItem(
              value: LedScheduleRecurrence.weekdays,
              child: Text(l10n.ledScheduleRecurrenceWeekdays),
            ),
            DropdownMenuItem(
              value: LedScheduleRecurrence.weekends,
              child: Text(l10n.ledScheduleRecurrenceWeekends),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => _recurrence = value);
          },
        ),
      ],
    );
  }

  Widget _buildEnabledToggle(AppLocalizations l10n) {
    return SwitchListTile(
      value: _isEnabled,
      title: Text(l10n.ledScheduleEditEnabledToggle),
      onChanged: _isSaving
          ? null
          : (value) => setState(() => _isEnabled = value),
    );
  }

  Widget _buildChannelSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ledScheduleEditChannelsHeader,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        ..._channelValues.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ChannelSlider(
              label: _channelLabel(entry.key, l10n),
              value: entry.value,
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() {
                      _channelValues[entry.key] = value;
                    }),
              valueLabel: l10n.ledControlValueLabel(entry.value.round()),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart ? _startTime : _endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() => _nameError = l10n.ledScheduleEditInvalidName);
      return;
    }
    if (_timeOfDayToMinutes(_endTime) <= _timeOfDayToMinutes(_startTime)) {
      _showSnackbar(l10n.ledScheduleEditInvalidWindow);
      return;
    }

    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _showSnackbar(describeAppError(l10n, AppErrorCode.noActiveDevice));
      return;
    }
    // KC-A-FINAL: Gate on device ready state
    if (!session.isReady) {
      _showSnackbar(describeAppError(l10n, AppErrorCode.deviceNotReady));
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Only pass scheduleId for local schedules; BLE schedules create new local copy
      final scheduleId = widget.initialSchedule?.id;
      final isLocalSchedule =
          scheduleId != null && scheduleId.startsWith('local_schedule_');
      final SaveLedScheduleRequest request = SaveLedScheduleRequest(
        scheduleId: isLocalSchedule ? scheduleId : null,
        title: trimmedName,
        type: _mapTypeToRead(_type),
        recurrence: _mapRecurrenceToRead(_recurrence),
        startMinutesFromMidnight: _timeOfDayToMinutes(_startTime),
        endMinutesFromMidnight: _timeOfDayToMinutes(_endTime),
        isEnabled: _isEnabled,
        channels: _channelValues.entries
            .map(
              (entry) => LedScheduleChannelInput(
                id: entry.key,
                label: _channelLabel(entry.key, l10n),
                percentage: entry.value.round().clamp(0, 100),
              ),
            )
            .toList(growable: false),
        sceneName: _buildSceneName(l10n),
      );

      await appContext.saveLedScheduleUseCase.execute(
        deviceId: deviceId,
        request: request,
      );
    } on AppError catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackbar(describeAppError(l10n, error.code));
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackbar(describeAppError(l10n, AppErrorCode.unknownError));
      }
      return;
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  ReadLedScheduleType _mapTypeToRead(LedScheduleType type) {
    switch (type) {
      case LedScheduleType.dailyProgram:
        return ReadLedScheduleType.dailyProgram;
      case LedScheduleType.customWindow:
        return ReadLedScheduleType.customWindow;
      case LedScheduleType.sceneBased:
        return ReadLedScheduleType.sceneBased;
    }
  }

  ReadLedScheduleRecurrence _mapRecurrenceToRead(
    LedScheduleRecurrence recurrence,
  ) {
    switch (recurrence) {
      case LedScheduleRecurrence.everyday:
        return ReadLedScheduleRecurrence.everyDay;
      case LedScheduleRecurrence.weekdays:
        return ReadLedScheduleRecurrence.weekdays;
      case LedScheduleRecurrence.weekends:
        return ReadLedScheduleRecurrence.weekends;
    }
  }

  int _timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _channelLabel(String channelId, AppLocalizations l10n) {
    switch (channelId) {
      case _whiteChannelId:
        return l10n.ledScheduleEditChannelWhite;
      case _blueChannelId:
        return l10n.ledScheduleEditChannelBlue;
      default:
        return channelId;
    }
  }

  String _buildSceneName(AppLocalizations l10n) {
    return _channelValues.entries
        .map(
          (entry) =>
              '${_channelLabel(entry.key, l10n)} ${entry.value.round().clamp(0, 100)}%',
        )
        .join(' / ');
  }

  void _showSnackbar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _TimeButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: CommonIconHelper.getCalendarIcon(size: 24),
      label: Text(label),
    );
  }
}

class _ChannelSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final String valueLabel;

  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
                Text(
                  valueLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              label: valueLabel,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
