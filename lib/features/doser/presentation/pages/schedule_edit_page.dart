import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_dosing/custom_window_schedule_definition.dart';
import '../../../../domain/doser_dosing/daily_average_schedule_definition.dart';
import '../../../../domain/doser_dosing/schedule_weekday.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/pump_head_schedule_controller.dart';
import '../models/pump_head_schedule_entry.dart';

class ScheduleEditPage extends StatefulWidget {
  final String headId;
  final PumpHeadScheduleEntry? initialEntry;
  final PumpHeadScheduleType initialType;

  const ScheduleEditPage({
    super.key,
    required this.headId,
    this.initialEntry,
    this.initialType = PumpHeadScheduleType.dailyAverage,
  });

  @override
  State<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends State<ScheduleEditPage> {
  late PumpHeadScheduleType _type;
  late PumpHeadScheduleRecurrence _recurrence;
  late bool _isEnabled;

  late TextEditingController _dailyDoseController;
  late TextEditingController _customDoseController;
  late int _dailyEvents;
  late int _customEvents;
  late TimeOfDay _dailyStartTime;
  late TimeOfDay _windowStartTime;
  late TimeOfDay _windowEndTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final PumpHeadScheduleEntry? entry = widget.initialEntry;
    _type = entry?.type ?? widget.initialType;
    _recurrence = entry?.recurrence ?? PumpHeadScheduleRecurrence.daily;
    _isEnabled = entry?.isEnabled ?? true;

    _dailyDoseController = TextEditingController(
      text: entry != null && entry.type == PumpHeadScheduleType.dailyAverage
          ? entry.doseMlPerEvent.toStringAsFixed(1)
          : '1.0',
    );
    _customDoseController = TextEditingController(
      text: entry != null && entry.type == PumpHeadScheduleType.customWindow
          ? entry.doseMlPerEvent.toStringAsFixed(1)
          : '1.0',
    );

    _dailyEvents =
        entry != null && entry.type == PumpHeadScheduleType.dailyAverage
        ? entry.eventsPerDay
        : 4;
    _customEvents =
        entry != null && entry.type == PumpHeadScheduleType.customWindow
        ? entry.eventsPerDay
        : 2;

    _dailyStartTime =
        entry != null && entry.type == PumpHeadScheduleType.dailyAverage
        ? entry.startTime
        : const TimeOfDay(hour: 6, minute: 0);
    _windowStartTime =
        entry != null && entry.type == PumpHeadScheduleType.customWindow
        ? entry.startTime
        : const TimeOfDay(hour: 8, minute: 0);
    _windowEndTime = entry != null && entry.endTime != null
        ? entry.endTime!
        : const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    _dailyDoseController.dispose();
    _customDoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = context.watch<AppSession>();
    final bool isConnected = session.isBleConnected;
    final bool isReady = session.isReady;
    final title = widget.initialEntry == null
        ? l10n.dosingScheduleEditTitleNew
        : l10n.dosingScheduleEditTitleEdit;

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
            l10n.dosingPumpHeadSummaryTitle(widget.headId.toUpperCase()),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.dosingScheduleEditDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildTypeSelector(l10n),
          const SizedBox(height: AppSpacing.md),
          _buildEnabledToggle(l10n),
          const SizedBox(height: AppSpacing.md),
          if (_type == PumpHeadScheduleType.dailyAverage)
            _DailyAverageForm(
              doseController: _dailyDoseController,
              eventsPerDay: _dailyEvents,
              onEventsChanged: (value) => setState(() => _dailyEvents = value),
              startTime: _dailyStartTime,
              onStartTimeChanged: (time) =>
                  setState(() => _dailyStartTime = time),
            )
          else
            _CustomWindowForm(
              doseController: _customDoseController,
              eventsPerWindow: _customEvents,
              onEventsChanged: (value) => setState(() => _customEvents = value),
              startTime: _windowStartTime,
              endTime: _windowEndTime,
              onStartChanged: (time) => setState(() => _windowStartTime = time),
              onEndChanged: (time) => setState(() => _windowEndTime = time),
            ),
          const SizedBox(height: AppSpacing.md),
          _buildRecurrenceSelector(l10n),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                        },
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
                      : Text(l10n.dosingScheduleEditSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dosingScheduleEditTypeLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<PumpHeadScheduleType>(
          initialValue: _type,
          items: [
            DropdownMenuItem(
              value: PumpHeadScheduleType.dailyAverage,
              child: Text(l10n.dosingScheduleTypeDaily),
            ),
            DropdownMenuItem(
              value: PumpHeadScheduleType.customWindow,
              child: Text(l10n.dosingScheduleTypeCustom),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
      ],
    );
  }

  Widget _buildEnabledToggle(AppLocalizations l10n) {
    return SwitchListTile(
      value: _isEnabled,
      title: Text(l10n.dosingScheduleEditEnabledToggle),
      onChanged: (value) => setState(() => _isEnabled = value),
    );
  }

  Widget _buildRecurrenceSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dosingScheduleEditRecurrenceLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<PumpHeadScheduleRecurrence>(
          initialValue: _recurrence,
          items: [
            DropdownMenuItem(
              value: PumpHeadScheduleRecurrence.daily,
              child: Text(l10n.dosingScheduleRecurrenceDaily),
            ),
            DropdownMenuItem(
              value: PumpHeadScheduleRecurrence.weekdays,
              child: Text(l10n.dosingScheduleRecurrenceWeekdays),
            ),
            DropdownMenuItem(
              value: PumpHeadScheduleRecurrence.weekends,
              child: Text(l10n.dosingScheduleRecurrenceWeekends),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _recurrence = value);
          },
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<PumpHeadScheduleController>();
    final FocusScopeNode scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus) {
      scope.unfocus();
    }

    final bool isDaily = _type == PumpHeadScheduleType.dailyAverage;
    final TextEditingController controllerForDose = isDaily
        ? _dailyDoseController
        : _customDoseController;
    final double? dose = double.tryParse(controllerForDose.text);
    if (dose == null || dose <= 0) {
      _showSnackbar(l10n.dosingScheduleEditInvalidDose);
      return;
    }

    if (!isDaily) {
      final int startMinutes = _timeOfDayToMinutes(_windowStartTime);
      final int endMinutes = _timeOfDayToMinutes(_windowEndTime);
      if (endMinutes <= startMinutes) {
        _showSnackbar(l10n.dosingScheduleEditInvalidWindow);
        return;
      }
    }

    setState(() => _isSaving = true);
    final bool success = await _dispatchSave(controller, dose);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    if (!success) {
      final AppErrorCode code =
          controller.lastErrorCode ?? AppErrorCode.unknownError;
      _showSnackbar(describeAppError(l10n, code));
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<bool> _dispatchSave(
    PumpHeadScheduleController controller,
    double dose,
  ) async {
    final PumpHeadScheduleEntry preview = _buildPreviewEntry(dose);
    final int pumpId = _pumpIdFromHeadId(widget.headId);
    final String scheduleId = preview.id;

    if (_type == PumpHeadScheduleType.dailyAverage) {
      final DailyAverageScheduleDefinition definition = _buildDailyDefinition(
        scheduleId,
        pumpId,
        dose,
      );
      return controller.saveDailyAverageSchedule(
        definition: definition,
        preview: preview,
      );
    }

    final CustomWindowScheduleDefinition definition = _buildCustomDefinition(
      scheduleId,
      pumpId,
      dose,
    );
    return controller.saveCustomWindowSchedule(
      definition: definition,
      preview: preview,
    );
  }

  PumpHeadScheduleEntry _buildPreviewEntry(double dose) {
    final String scheduleId =
        widget.initialEntry?.id ??
        'user-${widget.headId}-${DateTime.now().millisecondsSinceEpoch}';
    if (_type == PumpHeadScheduleType.dailyAverage) {
      return PumpHeadScheduleEntry(
        id: scheduleId,
        type: PumpHeadScheduleType.dailyAverage,
        doseMlPerEvent: dose,
        eventsPerDay: _dailyEvents,
        startTime: _dailyStartTime,
        recurrence: _recurrence,
        isEnabled: _isEnabled,
      );
    }

    return PumpHeadScheduleEntry(
      id: scheduleId,
      type: PumpHeadScheduleType.customWindow,
      doseMlPerEvent: dose,
      eventsPerDay: _customEvents,
      startTime: _windowStartTime,
      endTime: _windowEndTime,
      recurrence: _recurrence,
      isEnabled: _isEnabled,
    );
  }

  DailyAverageScheduleDefinition _buildDailyDefinition(
    String scheduleId,
    int pumpId,
    double dose,
  ) {
    final Set<ScheduleWeekday> repeatDays = _mapRecurrenceToWeekdays(
      _recurrence,
    );
    final List<DailyDoseSlot> slots = _buildDailySlots(dose);

    return DailyAverageScheduleDefinition(
      scheduleId: scheduleId,
      pumpId: pumpId,
      repeatDays: repeatDays,
      slots: slots,
    );
  }

  List<DailyDoseSlot> _buildDailySlots(double dose) {
    final List<DailyDoseSlot> slots = <DailyDoseSlot>[];
    final int events = _dailyEvents.clamp(1, 24);
    final int interval = (24 * 60) ~/ events;
    final int startMinutes = _timeOfDayToMinutes(_dailyStartTime);

    for (int index = 0; index < events; index++) {
      final int minutes = (startMinutes + index * interval) % (24 * 60);
      final int hour = minutes ~/ 60;
      final int minute = minutes % 60;
      slots.add(
        DailyDoseSlot(
          hour: hour,
          minute: minute,
          doseMl: dose,
          speed: PumpSpeed.medium,
        ),
      );
    }
    return slots;
  }

  CustomWindowScheduleDefinition _buildCustomDefinition(
    String scheduleId,
    int pumpId,
    double dose,
  ) {
    final int startMinutes = _timeOfDayToMinutes(_windowStartTime);
    final int endMinutes = _timeOfDayToMinutes(_windowEndTime);
    final int duration = endMinutes - startMinutes;
    final List<WindowDoseEvent> events = <WindowDoseEvent>[];

    final int steps = _customEvents.clamp(1, 8);
    if (steps <= 1) {
      events.add(
        WindowDoseEvent(minuteOffset: 0, doseMl: dose, speed: PumpSpeed.medium),
      );
    } else {
      final double gap = duration / (steps - 1);
      for (int index = 0; index < steps; index++) {
        final int offset = (index * gap).round().clamp(0, duration);
        events.add(
          WindowDoseEvent(
            minuteOffset: offset,
            doseMl: dose,
            speed: PumpSpeed.medium,
          ),
        );
      }
    }

    final ScheduleWindowChunk chunk = ScheduleWindowChunk(
      chunkIndex: 0,
      windowStartMinute: startMinutes,
      windowEndMinute: endMinutes,
      events: events,
    );

    return CustomWindowScheduleDefinition(
      scheduleId: scheduleId,
      pumpId: pumpId,
      chunks: <ScheduleWindowChunk>[chunk],
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  int _pumpIdFromHeadId(String value) {
    final String normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 1;
    }
    final int candidate = normalized.codeUnitAt(0) - 64;
    if (candidate < 1) {
      return 1;
    }
    return candidate;
  }

  Set<ScheduleWeekday> _mapRecurrenceToWeekdays(
    PumpHeadScheduleRecurrence recurrence,
  ) {
    switch (recurrence) {
      case PumpHeadScheduleRecurrence.weekdays:
        return const <ScheduleWeekday>{
          ScheduleWeekday.monday,
          ScheduleWeekday.tuesday,
          ScheduleWeekday.wednesday,
          ScheduleWeekday.thursday,
          ScheduleWeekday.friday,
        };
      case PumpHeadScheduleRecurrence.weekends:
        return const <ScheduleWeekday>{
          ScheduleWeekday.saturday,
          ScheduleWeekday.sunday,
        };
      case PumpHeadScheduleRecurrence.daily:
        return ScheduleWeekday.values.toSet();
    }
  }
}

class _DailyAverageForm extends StatelessWidget {
  final TextEditingController doseController;
  final int eventsPerDay;
  final ValueChanged<int> onEventsChanged;
  final TimeOfDay startTime;
  final ValueChanged<TimeOfDay> onStartTimeChanged;

  const _DailyAverageForm({
    required this.doseController,
    required this.eventsPerDay,
    required this.onEventsChanged,
    required this.startTime,
    required this.onStartTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleTypeDaily,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: doseController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.dosingScheduleEditDoseLabel,
                hintText: l10n.dosingScheduleEditDoseHint,
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _NumberStepper(
              label: l10n.dosingScheduleEditEventsLabel,
              value: eventsPerDay,
              min: 1,
              max: 24,
              onChanged: onEventsChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            _TimePickerTile(
              label: l10n.dosingScheduleEditStartTimeLabel,
              value: localizations.formatTimeOfDay(startTime),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  onStartTimeChanged(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomWindowForm extends StatelessWidget {
  final TextEditingController doseController;
  final int eventsPerWindow;
  final ValueChanged<int> onEventsChanged;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const _CustomWindowForm({
    required this.doseController,
    required this.eventsPerWindow,
    required this.onEventsChanged,
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingScheduleTypeCustom,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: doseController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.dosingScheduleEditDoseLabel,
                hintText: l10n.dosingScheduleEditDoseHint,
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _NumberStepper(
              label: l10n.dosingScheduleEditWindowEventsLabel,
              value: eventsPerWindow,
              min: 1,
              max: 8,
              onChanged: onEventsChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            _TimePickerTile(
              label: l10n.dosingScheduleEditWindowStartLabel,
              value: localizations.formatTimeOfDay(startTime),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  onStartChanged(picked);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _TimePickerTile(
              label: l10n.dosingScheduleEditWindowEndLabel,
              value: localizations.formatTimeOfDay(endTime),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) {
                  onEndChanged(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall),
              Text('$value', style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: CommonIconHelper.getMinusIcon(size: 24),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: CommonIconHelper.getAddIcon(size: 24),
        ),
      ],
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle: Text(value, style: theme.textTheme.titleMedium),
      trailing: CommonIconHelper.getCalendarIcon(size: 24),
      onTap: onTap,
    );
  }
}
