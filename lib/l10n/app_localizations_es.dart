// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'KoralCore';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabDevice => 'Dispositivos';

  @override
  String homeStatusConnected(String device) {
    return 'Conectado a $device';
  }

  @override
  String get homeStatusDisconnected => 'Sin dispositivo activo';

  @override
  String get homeConnectedCopy =>
      'Gestiona dosis e iluminación desde tu teléfono.';

  @override
  String get homeConnectCta => 'Conectar un dispositivo';

  @override
  String get homeNoDeviceCopy =>
      'Empareja tu dosificador o controlador LED Koral para gestionar horarios y luz.';

  @override
  String get sectionDosingTitle => 'Dosificación';

  @override
  String get sectionLedTitle => 'Iluminación';

  @override
  String get bleDisconnectedWarning =>
      'Conéctate por Bluetooth para continuar.';

  @override
  String get bleGuardDialogTitle => 'Bluetooth requerido';

  @override
  String get bleGuardDialogMessage =>
      'Conecta un dispositivo para usar esta función.';

  @override
  String get bleGuardDialogButton => 'Entendido';

  @override
  String get bleOnboardingPermissionTitle => 'Habilitar el acceso Bluetooth';

  @override
  String get bleOnboardingPermissionCopy =>
      'Usamos Bluetooth para descubrir y controlar su hardware Koral cercano.';

  @override
  String get bleOnboardingPermissionCta => 'Permitir acceso';

  @override
  String get bleOnboardingSettingsTitle => 'Permiso requerido en Configuración';

  @override
  String get bleOnboardingSettingsCopy =>
      'El acceso a Bluetooth fue denegado previamente.Abra la configuración del sistema para habilitarlo.';

  @override
  String get bleOnboardingSettingsCta => 'Abrir configuración';

  @override
  String get bleOnboardingLocationTitle => 'Permitir acceso a la ubicación';

  @override
  String get bleOnboardingLocationCopy =>
      'Android requiere acceso a la ubicación en versiones anteriores para buscar dispositivos Bluetooth.';

  @override
  String get bleOnboardingBluetoothOffTitle => 'Activar Bluetooth';

  @override
  String get bleOnboardingBluetoothOffCopy =>
      'Bluetooth debe permanecer encendido para seguir escaneando y controlando sus dispositivos.';

  @override
  String get bleOnboardingBluetoothCta => 'Abrir la configuración de Bluetooth';

  @override
  String get bleOnboardingUnavailableTitle => 'Bluetooth no disponible';

  @override
  String get bleOnboardingUnavailableCopy =>
      'Este dispositivo no expone una radio Bluetooth que KoralCore pueda usar.';

  @override
  String get bleOnboardingRetryCta => 'Rever';

  @override
  String get bleOnboardingLearnMore => 'Más información';

  @override
  String get bleOnboardingSheetTitle => 'Por qué KoralCore necesita Bluetooth';

  @override
  String get bleOnboardingSheetDescription =>
      'Bluetooth potencia el descubrimiento y control de su hardware de dosificación e iluminación.Esto es lo que sucede una vez que otorgas acceso.';

  @override
  String get bleOnboardingSheetSearchTitle => 'Encuentra dispositivos cercanos';

  @override
  String get bleOnboardingSheetSearchCopy =>
      'Busque Reef Dose, Reef LED y otros equipos Koral alrededor de su tanque.';

  @override
  String get bleOnboardingSheetControlTitle =>
      'Controlar la dosificación y la iluminación.';

  @override
  String get bleOnboardingSheetControlCopy =>
      'Sincronice horarios, envíe comandos y mantenga el firmware actualizado a través de un enlace BLE seguro.';

  @override
  String get bleOnboardingSheetFooter =>
      'Tan pronto como Bluetooth esté listo, reanudaremos automáticamente el escaneo.';

  @override
  String get bleOnboardingDisabledHint =>
      'Conceda acceso a Bluetooth para comenzar a escanear.';

  @override
  String get bleOnboardingBlockedEmptyTitle =>
      'Se requiere configuración de Bluetooth';

  @override
  String get bleOnboardingBlockedEmptyCopy =>
      'Permita el acceso a Bluetooth o actívelo para descubrir su hardware de arrecife.';

  @override
  String get bluetoothHeader => 'Dispositivos cercanos';

  @override
  String get bluetoothScanCta => 'Buscar dispositivos';

  @override
  String get bluetoothScanning => 'Buscando...';

  @override
  String get bluetoothEmptyState => 'Todavía no se encontraron dispositivos.';

  @override
  String get bluetoothConnect => 'Conectar';

  @override
  String get deviceHeader => 'Mis dispositivos';

  @override
  String get deviceEmptyTitle => 'Sin dispositivos';

  @override
  String get deviceEmptySubtitle =>
      'Usa la pestaña Bluetooth para descubrir hardware.';

  @override
  String get deviceStateConnected => 'Conectado';

  @override
  String get deviceStateDisconnected => 'Desconectado';

  @override
  String get deviceStateConnecting => 'Conectando';

  @override
  String get deviceActionConnect => 'Conectar';

  @override
  String get deviceActionDisconnect => 'Desconectar';

  @override
  String get deviceDeleteMode => 'Eliminar';

  @override
  String get deviceSelectMode => 'Seleccionar';

  @override
  String get deviceDeleteConfirmTitle => '¿Eliminar dispositivos?';

  @override
  String get deviceDeleteConfirmMessage =>
      'Los dispositivos seleccionados se quitarán de este teléfono. No reinicia el hardware.';

  @override
  String get deviceDeleteConfirmPrimary => 'Eliminar';

  @override
  String get deviceDeleteConfirmSecondary => 'Conservar';

  @override
  String get deviceActionDelete => 'Eliminar seleccionados';

  @override
  String deviceSelectionCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get dosingHeader => 'Dosificación';

  @override
  String get dosingSubHeader => 'Controla las rutinas diarias.';

  @override
  String get dosingEntrySchedule => 'Editar horario';

  @override
  String get dosingEntryManual => 'Dosis manual';

  @override
  String get dosingEntryCalibration => 'Calibración';

  @override
  String get dosingEntryHistory => 'Historial de dosis';

  @override
  String get dosingScheduleAddButton => 'Agregar horario';

  @override
  String get dosingScheduleEditTitleNew => 'Nuevo horario';

  @override
  String get dosingScheduleEditTitleEdit => 'Editar horario';

  @override
  String get dosingScheduleEditDescription =>
      'Configure ventanas de dosificación para este cabezal de bomba.';

  @override
  String get dosingScheduleEditTypeLabel => 'Tipo de horario';

  @override
  String get dosingScheduleEditDoseLabel => 'Dosis por evento';

  @override
  String get dosingScheduleEditDoseHint => 'Ingrese la cantidad en mililitros.';

  @override
  String get dosingScheduleEditEventsLabel => 'Eventos por día';

  @override
  String get dosingScheduleEditStartTimeLabel => 'Primera dosis';

  @override
  String get dosingScheduleEditWindowStartLabel => 'inicio de ventana';

  @override
  String get dosingScheduleEditWindowEndLabel => 'final de la ventana';

  @override
  String get dosingScheduleEditWindowEventsLabel => 'Eventos por ventana';

  @override
  String get dosingScheduleEditRecurrenceLabel => 'Reaparición';

  @override
  String get dosingScheduleEditEnabledToggle => 'Habilitar horario';

  @override
  String get dosingScheduleEditSave => 'Guardar horario';

  @override
  String get dosingScheduleEditSuccess => 'Horario guardado.';

  @override
  String get dosingScheduleEditInvalidDose =>
      'Introduzca una dosis mayor que cero.';

  @override
  String get dosingScheduleEditInvalidWindow =>
      'La hora de finalización debe ser posterior a la hora de inicio.';

  @override
  String get dosingScheduleEditTemplateDaily =>
      'Usar plantilla de promedio diario';

  @override
  String get dosingScheduleEditTemplateCustom =>
      'Usar plantilla de ventana personalizada';

  @override
  String get dosingManualPageSubtitle =>
      'Ejecuta una dosis a demanda desde esta cabeza de bomba.';

  @override
  String get dosingManualDoseInputLabel => 'Cantidad de dosis';

  @override
  String get dosingManualDoseInputHint => 'Ingresa la cantidad en mililitros.';

  @override
  String get dosingManualConfirmTitle => '¿Enviar dosis manual?';

  @override
  String get dosingManualConfirmMessage =>
      'Esta dosis comenzará de inmediato. Asegúrate de que tu línea de dosificación esté lista.';

  @override
  String get dosingManualInvalidDose => 'Ingresa una dosis mayor que cero.';

  @override
  String get ledHeader => 'Iluminación';

  @override
  String get ledSubHeader => 'Ajusta espectros y horarios.';

  @override
  String get ledEntryIntensity => 'Ajustar intensidad';

  @override
  String get ledIntensityEntrySubtitle =>
      'Tune output for each lighting channel.';

  @override
  String get ledEntryPrograms => 'Escenas y programas';

  @override
  String get ledEntryManual => 'Control manual';

  @override
  String get ledEntryRecords => 'Open records';

  @override
  String get ledEntryRecordsSubtitle =>
      'Review lighting time points synced from Reef B.';

  @override
  String get ledChannelBlue => 'Blue';

  @override
  String get ledChannelRed => 'Red';

  @override
  String get ledChannelGreen => 'Green';

  @override
  String get ledChannelPurple => 'Purple';

  @override
  String get ledChannelUv => 'UV';

  @override
  String get ledChannelWarmWhite => 'Warm white';

  @override
  String get ledChannelMoon => 'Moonlight';

  @override
  String get ledScheduleAddButton => 'Add schedule';

  @override
  String get ledScheduleEditTitleNew => 'New lighting schedule';

  @override
  String get ledScheduleEditTitleEdit => 'Edit lighting schedule';

  @override
  String get ledScheduleEditDescription =>
      'Configure time windows and intensity levels.';

  @override
  String get ledScheduleEditNameLabel => 'Schedule name';

  @override
  String get ledScheduleEditNameHint => 'Enter a label';

  @override
  String get ledScheduleEditInvalidName => 'Enter a schedule name.';

  @override
  String get ledScheduleEditTypeLabel => 'Schedule type';

  @override
  String get ledScheduleEditStartLabel => 'Start time';

  @override
  String get ledScheduleEditEndLabel => 'End time';

  @override
  String get ledScheduleEditRecurrenceLabel => 'Recurrence';

  @override
  String get ledScheduleEditEnabledToggle => 'Enable schedule';

  @override
  String get ledScheduleEditChannelsHeader => 'Channels';

  @override
  String get ledScheduleEditChannelWhite => 'Cool white';

  @override
  String get ledScheduleEditChannelBlue => 'Royal blue';

  @override
  String get ledScheduleEditSave => 'Save schedule';

  @override
  String get ledScheduleEditSuccess => 'Lighting schedule saved.';

  @override
  String get ledScheduleEditInvalidWindow =>
      'End time must be after start time.';

  @override
  String get ledControlTitle => 'Intensity & spectrum';

  @override
  String get ledControlSubtitle =>
      'Adjust each lighting channel, then apply when ready.';

  @override
  String get ledControlChannelsSection => 'Channels';

  @override
  String ledControlValueLabel(int percent) {
    return '$percent% output';
  }

  @override
  String get ledControlApplySuccess => 'LED settings updated.';

  @override
  String get ledControlEmptyState => 'No adjustable LED channels yet.';

  @override
  String get comingSoon => 'Muy pronto';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get errorDeviceBusy =>
      'El dispositivo está ocupado. Intenta de nuevo.';

  @override
  String get errorNoDevice => 'No hay dispositivo activo.';

  @override
  String get errorNotSupported =>
      'Esta acción no es compatible con el dispositivo conectado.';

  @override
  String get errorInvalidParam => 'Parámetros inválidos para este caso de uso.';

  @override
  String get errorTransport =>
      'Error de transporte Bluetooth. Verifica la señal e inténtalo otra vez.';

  @override
  String get errorGeneric => 'Ocurrió un problema. Reintenta.';

  @override
  String get snackbarDeviceRemoved => 'Dispositivos eliminados.';

  @override
  String get snackbarDeviceConnected => 'Dispositivo conectado.';

  @override
  String get snackbarDeviceDisconnected => 'Dispositivo desconectado.';

  @override
  String get dosingPumpHeadsHeader => 'Pump heads';

  @override
  String get dosingPumpHeadsSubheader =>
      'Tap a head to review flow and totals.';

  @override
  String dosingPumpHeadSummaryTitle(String head) {
    return 'Head $head';
  }

  @override
  String get dosingPumpHeadStatus => 'Status';

  @override
  String get dosingPumpHeadStatusReady => 'Ready';

  @override
  String get dosingPumpHeadDailyTarget => 'Daily target';

  @override
  String get dosingPumpHeadTodayDispensed => 'Today dispensed';

  @override
  String get dosingPumpHeadLastDose => 'Last dose';

  @override
  String get dosingPumpHeadFlowRate => 'Calibrated flow';

  @override
  String get dosingPumpHeadManualDose => 'Manual dose';

  @override
  String get dosingPumpHeadManualDoseSuccess => 'Manual dose sent.';

  @override
  String get dosingPumpHeadTimedDose => 'Schedule timed dose';

  @override
  String get dosingPumpHeadTimedDoseSuccess => 'Timed dose scheduled.';

  @override
  String get dosingPumpHeadCalibrate => 'Calibrate head';

  @override
  String get dosingPumpHeadPlaceholder => 'No dosing data yet.';

  @override
  String get dosingScheduleOverviewTitle => 'Schedules';

  @override
  String get dosingScheduleOverviewSubtitle =>
      'Review configured dosing windows.';

  @override
  String get dosingTodayTotalTitle => 'Today\'s dosing';

  @override
  String get dosingTodayTotalTotal => 'Total';

  @override
  String get dosingTodayTotalScheduled => 'Scheduled';

  @override
  String get dosingTodayTotalManual => 'Manual';

  @override
  String get dosingTodayTotalEmpty => 'No dosing data yet.';

  @override
  String get dosingScheduleSummaryTitle => 'Schedule summary';

  @override
  String get dosingScheduleSummaryEmpty => 'No schedule';

  @override
  String get dosingScheduleSummaryTotalLabel => 'Total / day';

  @override
  String dosingScheduleSummaryWindowCount(int count) {
    return '$count windows';
  }

  @override
  String dosingScheduleSummarySlotCount(int count) {
    return '$count slots';
  }

  @override
  String get dosingScheduleApplyDailyAverage => 'Apply 24h average schedule';

  @override
  String get dosingScheduleApplyDailyAverageSuccess =>
      '24h average schedule sent.';

  @override
  String get dosingScheduleApplyCustomWindow => 'Apply custom window schedule';

  @override
  String get dosingScheduleApplyCustomWindowSuccess =>
      'Custom window schedule sent.';

  @override
  String get dosingScheduleViewButton => 'View schedules';

  @override
  String get dosingScheduleEmptyTitle => 'No schedule configured';

  @override
  String get dosingScheduleEmptySubtitle =>
      'Add a schedule with the Reef B app to see it here.';

  @override
  String get dosingScheduleTypeDaily => '24-hour program';

  @override
  String get dosingScheduleTypeSingle => 'Single dose';

  @override
  String get dosingScheduleTypeCustom => 'Custom window';

  @override
  String get dosingScheduleRecurrenceDaily => 'Every day';

  @override
  String get dosingScheduleRecurrenceWeekdays => 'Weekdays';

  @override
  String get dosingScheduleRecurrenceWeekends => 'Weekends';

  @override
  String get ledDetailUnknownDevice => 'Unnamed device';

  @override
  String get ledDetailFavoriteTooltip => 'Mark as favorite (coming soon)';

  @override
  String get ledDetailHeaderHint =>
      'Control spectrum profiles and schedules from your phone.';

  @override
  String get ledScenesPlaceholderTitle => 'Scenes';

  @override
  String get ledScenesPlaceholderSubtitle =>
      'Swipe through presets from Reef B.';

  @override
  String get ledScheduleSummaryTitle => 'Lighting schedule';

  @override
  String get ledScheduleSummaryEmpty => 'No schedule configured';

  @override
  String get ledScheduleSummaryWindowLabel => 'Window';

  @override
  String get ledScheduleSummaryLabel => 'Label';

  @override
  String get ledSchedulePlaceholderTitle => 'Schedule preview';

  @override
  String get ledSchedulePlaceholderSubtitle =>
      'Planned spectrum envelope for the next 24h.';

  @override
  String get ledEntryScenes => 'Open Scenes';

  @override
  String get ledEntrySchedule => 'Open Schedule';

  @override
  String get ledScenesListTitle => 'Scenes';

  @override
  String get ledScenesListSubtitle => 'Review presets imported from Reef B.';

  @override
  String get ledScenesEmptyTitle => 'No scenes available';

  @override
  String get ledScenesEmptySubtitle =>
      'Sync scenes from the Reef B app to see them here.';

  @override
  String get ledScheduleListTitle => 'Schedules';

  @override
  String get ledScheduleListSubtitle =>
      'Review lighting timelines synced from Reef B.';

  @override
  String get ledScheduleEmptyTitle => 'No schedules available';

  @override
  String get ledScheduleEmptySubtitle =>
      'Create schedules in the Reef B app to view them here.';

  @override
  String get ledScheduleDerivedLabel => 'From LED record';

  @override
  String get ledRecordsTitle => 'LED records';

  @override
  String get ledRecordsSubtitle =>
      'Manage every point in the 24-hour lighting timeline.';

  @override
  String get ledRecordsEmptyTitle => 'No records available';

  @override
  String get ledRecordsEmptySubtitle =>
      'Create records in the Reef B app to see them here.';

  @override
  String get ledRecordsSelectedTimeLabel => 'Selected time';

  @override
  String get ledRecordsStatusIdle => 'Ready';

  @override
  String get ledRecordsStatusApplying => 'Syncing...';

  @override
  String get ledRecordsStatusPreview => 'Previewing';

  @override
  String get ledRecordsActionPrev => 'Previous';

  @override
  String get ledRecordsActionNext => 'Next';

  @override
  String get ledRecordsActionDelete => 'Delete';

  @override
  String get ledRecordsActionClear => 'Clear all';

  @override
  String get ledRecordsActionPreviewStart => 'Preview';

  @override
  String get ledRecordsActionPreviewStop => 'Stop preview';

  @override
  String get ledRecordsClearConfirmTitle => 'Clear all records?';

  @override
  String get ledRecordsClearConfirmMessage =>
      'This removes every recorded time point from the LED schedule.';

  @override
  String get ledRecordsDeleteConfirmTitle => 'Delete record?';

  @override
  String get ledRecordsDeleteConfirmMessage =>
      'Remove the selected time point from the LED schedule?';

  @override
  String get ledRecordsSnackDeleted => 'Record deleted.';

  @override
  String get ledRecordsSnackDeleteFailed => 'Couldn\'t delete record.';

  @override
  String get ledRecordsSnackCleared => 'Records cleared.';

  @override
  String get ledRecordsSnackClearFailed => 'Couldn\'t clear records.';

  @override
  String get ledRecordsSnackMissingSelection => 'Select a record first.';

  @override
  String get ledRecordsSnackPreviewStarted => 'Preview started.';

  @override
  String get ledRecordsSnackPreviewStopped => 'Preview stopped.';

  @override
  String get ledScheduleTypeDaily => 'Daily program';

  @override
  String get ledScheduleTypeCustom => 'Custom window';

  @override
  String get ledScheduleTypeScene => 'Scene-based';

  @override
  String get ledScheduleRecurrenceDaily => 'Every day';

  @override
  String get ledScheduleRecurrenceWeekdays => 'Weekdays';

  @override
  String get ledScheduleRecurrenceWeekends => 'Weekends';

  @override
  String ledScheduleSceneSummary(String scene) {
    return 'Scene: $scene';
  }

  @override
  String get dosingCalibrationHistoryTitle => 'Calibration history';

  @override
  String get dosingCalibrationHistorySubtitle =>
      'Latest calibrations captured per speed.';

  @override
  String get dosingCalibrationHistoryViewButton => 'View calibration history';

  @override
  String get dosingCalibrationHistoryEmptyTitle => 'No calibrations yet';

  @override
  String get dosingCalibrationHistoryEmptySubtitle =>
      'Run a calibration from the Reef B app to see it here.';

  @override
  String get dosingCalibrationRecordNoteLabel => 'Note';

  @override
  String dosingCalibrationRecordSpeed(String speed) {
    return 'Speed: $speed';
  }

  @override
  String dosingCalibrationRecordFlow(String flow) {
    return '$flow ml/min';
  }

  @override
  String get dosingPumpHeadSettingsTitle => 'Pump head settings';

  @override
  String get dosingPumpHeadSettingsSubtitle =>
      'Rename the head or adjust execution delay.';

  @override
  String get dosingPumpHeadSettingsNameLabel => 'Pump head name';

  @override
  String get dosingPumpHeadSettingsNameHint => 'Enter a custom label';

  @override
  String get dosingPumpHeadSettingsNameEmpty => 'Name can\'t be empty.';

  @override
  String get dosingPumpHeadSettingsTankLabel => 'Tank / additive';

  @override
  String get dosingPumpHeadSettingsTankPlaceholder =>
      'Link additives from the Reef B app.';

  @override
  String get dosingPumpHeadSettingsDelayLabel => 'Dose delay';

  @override
  String get dosingPumpHeadSettingsDelaySubtitle =>
      'Applies a delay before the head runs.';

  @override
  String get dosingPumpHeadSettingsUnsavedTitle => 'Discard changes?';

  @override
  String get dosingPumpHeadSettingsUnsavedMessage =>
      'You have unsaved changes.';

  @override
  String get dosingPumpHeadSettingsUnsavedDiscard => 'Discard';

  @override
  String get dosingPumpHeadSettingsUnsavedStay => 'Keep editing';

  @override
  String get dosingPumpHeadSettingsSave => 'Save';

  @override
  String get dosingPumpHeadSettingsCancel => 'Cancel';

  @override
  String dosingPumpHeadSettingsDelayOption(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get dosingScheduleStatusEnabled => 'Enabled';

  @override
  String get dosingScheduleStatusDisabled => 'Paused';

  @override
  String get ledSceneStatusEnabled => 'Enabled';

  @override
  String get ledSceneStatusDisabled => 'Disabled';

  @override
  String get ledSceneStatusActive => 'Active';

  @override
  String get ledScenesSnackApplied => 'Scene applied.';

  @override
  String get ledScheduleStatusEnabled => 'Enabled';

  @override
  String get ledScheduleStatusDisabled => 'Disabled';

  @override
  String get ledScheduleStatusActive => 'Active';

  @override
  String get ledScheduleSnackApplied => 'Schedule applied.';

  @override
  String get ledRuntimeStatus => 'Runtime status';

  @override
  String get ledRuntimeIdle => 'Idle';

  @override
  String get ledRuntimeApplying => 'Applying';

  @override
  String get ledRuntimePreview => 'Previewing';

  @override
  String get ledRuntimeScheduleActive => 'Schedule active';

  @override
  String get ledSceneCurrentlyRunning => 'Currently running';

  @override
  String get ledScenePreset => 'Preset scene';

  @override
  String get ledSceneCustom => 'Custom scene';

  @override
  String ledSceneChannelCount(int count) {
    return '$count channels';
  }

  @override
  String get ledScheduleDaily => 'Daily schedule';

  @override
  String get ledScheduleWindow => 'Time window';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionClear => 'Clear';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceNameHint => 'Enter device name';

  @override
  String get deviceNameEmpty => 'Device name cannot be empty';

  @override
  String get deviceId => 'Device ID';

  @override
  String get deviceInfo => 'Device Info';

  @override
  String get deviceSettingsTitle => 'Device Settings';

  @override
  String get deviceSettingsSaved => 'Settings saved';

  @override
  String get deviceActionEdit => 'Edit';

  @override
  String get deviceActionAdd => 'Add Device';

  @override
  String get deviceState => 'State';

  @override
  String get ledSettingTitle => 'LED Settings';

  @override
  String get ledRecordSettingTitle => 'LED Record Settings';

  @override
  String get ledRecordTimeSettingTitle => 'LED Record Time Settings';

  @override
  String get ledSceneAddTitle => 'Add Scene';

  @override
  String get ledSceneEditTitle => 'Edit Scene';

  @override
  String get ledSceneDeleteTitle => 'Delete Scene';

  @override
  String get ledMasterSettingTitle => 'Master Settings';

  @override
  String get ledRecordTimeSettingTimeLabel => 'Time';

  @override
  String get ledRecordTimeSettingChannelsLabel => 'Channels';

  @override
  String get ledRecordTimeSettingErrorTime => 'Invalid time';

  @override
  String get ledRecordTimeSettingErrorTimeExists => 'Time already exists';

  @override
  String get ledRecordTimeSettingSuccess => 'Record saved';

  @override
  String get ledSceneNameLabel => 'Scene Name';

  @override
  String get ledSceneNameHint => 'Enter scene name';

  @override
  String get ledSceneEditSuccess => 'Scene updated';

  @override
  String get ledSceneAddSuccess => 'Scene added';

  @override
  String get ledSceneDeleteDescription => 'Select scenes to delete';

  @override
  String get ledSceneDeleteEmpty => 'No scenes to delete';

  @override
  String get ledSceneDeleteConfirmTitle => 'Delete Scene?';

  @override
  String ledSceneDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String ledSceneDeleteSuccess(String name) {
    return 'Scene \"$name\" deleted';
  }

  @override
  String get ledSceneDeleteError => 'Failed to delete scene';

  @override
  String get ledSceneLimitReached => 'Maximum scenes reached';

  @override
  String get ledMasterSettingGroup => 'Group';

  @override
  String get ledMasterSettingMaster => 'Master';

  @override
  String get ledMasterSettingSlave => 'Slave';

  @override
  String get ledMasterSettingSetMaster => 'Set as Master';

  @override
  String get ledMasterSettingMoveGroup => 'Move Group';

  @override
  String get ledMasterSettingSetMasterSuccess => 'Master set successfully';

  @override
  String get ledMasterSettingSelectGroup => 'Select Group';

  @override
  String get ledMasterSettingGroupFull => 'Group is full';

  @override
  String get ledMasterSettingMoveGroupSuccess => 'Group moved successfully';

  @override
  String get ledMasterSettingMoveGroupFailed => 'Failed to move group';

  @override
  String get ledRecordSettingInitStrength => 'Initial Strength';

  @override
  String get ledRecordSettingSunrise => 'Sunrise';

  @override
  String get ledRecordSettingSunset => 'Sunset';

  @override
  String get ledRecordSettingSlowStart => 'Slow Start';

  @override
  String get ledRecordSettingMoonlight => 'Moonlight';

  @override
  String get ledRecordSettingErrorSunTime => 'Invalid sunrise/sunset time';

  @override
  String get ledRecordSettingSuccess => 'Settings saved';

  @override
  String get minute => 'minute';

  @override
  String get ledScenesActionEdit => 'Edit';

  @override
  String get ledDynamicScene => 'Dynamic Scene';

  @override
  String get ledStaticScene => 'Static Scene';

  @override
  String get ledScenesActionAdd => 'Add Scene';

  @override
  String get ledScenesActionUnfavorite => 'Remove Favorite';

  @override
  String get ledScenesActionFavorite => 'Add Favorite';

  @override
  String get ledResetDevice => 'Reset Device';

  @override
  String get sinkPosition => 'Sink Position';

  @override
  String get sinkPositionTitle => 'Sink Position';

  @override
  String get sinkPositionNotSet => 'Not Set';

  @override
  String get sinkPositionSet => 'Set';

  @override
  String get sinkAddTitle => 'Add Sink';

  @override
  String get sinkNameLabel => 'Sink Name';

  @override
  String get sinkNameHint => 'Enter sink name';

  @override
  String get sinkAddSuccess => 'Sink added';

  @override
  String get sinkNameExists => 'Sink name already exists';

  @override
  String get sinkManagerTitle => 'Sink Manager';

  @override
  String get sinkEmptyStateTitle => 'No Sinks';

  @override
  String get sinkEmptyStateSubtitle => 'Add a sink to get started';

  @override
  String get sinkEditTitle => 'Edit Sink';

  @override
  String get sinkDeleteTitle => 'Delete Sink';

  @override
  String get sinkDeleteMessage => 'Are you sure you want to delete this sink?';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get warningTitle => 'Warnings';

  @override
  String get warningClearAll => 'Clear All';

  @override
  String get warningClearAllTitle => 'Clear All Warnings?';

  @override
  String get warningClearAllContent => 'This will clear all warnings';

  @override
  String get warningClearAllSuccess => 'All warnings cleared';

  @override
  String warningId(int id) {
    return 'Warning ID: $id';
  }

  @override
  String get warningEmptyTitle => 'No Warnings';

  @override
  String get warningEmptySubtitle => 'All clear!';

  @override
  String get addDeviceTitle => 'Add Device';

  @override
  String get addDeviceSuccess => 'Device added';

  @override
  String get addDeviceFailed => 'Failed to add device';

  @override
  String get dosingScheduleEditTitle => 'Edit Schedule';

  @override
  String get dosingScheduleTypeLabel => 'Schedule Type';

  @override
  String get dosingScheduleTypeNone => 'No Schedule';

  @override
  String get dosingScheduleType24h => '24-Hour Average';

  @override
  String get dosingScheduleEditTimeRangeLabel => 'Time Range';

  @override
  String get dosingScheduleEditTimePointLabel => 'Time Point';

  @override
  String get dosingScheduleEditSelectDateRange => 'Select Date Range';

  @override
  String get dosingScheduleEditSelectDateTime => 'Select Date & Time';

  @override
  String get dosingScheduleEditCustomDetailsLabel => 'Custom Details';

  @override
  String get dosingScheduleEditNoTimeSlots => 'No time slots';

  @override
  String get dosingScheduleEditRotatingSpeedLabel => 'Rotating Speed';

  @override
  String get dosingScheduleEditSpeedLow => 'Low';

  @override
  String get dosingScheduleEditSpeedMedium => 'Medium';

  @override
  String get dosingScheduleEditSpeedHigh => 'High';

  @override
  String get dosingScheduleEditErrorVolumeEmpty => 'Volume cannot be empty';

  @override
  String get dosingScheduleEditErrorTimeEmpty => 'Time cannot be empty';

  @override
  String get dosingScheduleEditErrorVolumeTooLittleNew => 'Volume too little';

  @override
  String get dosingScheduleEditErrorVolumeTooLittleOld =>
      'Volume too little (old)';

  @override
  String get dosingScheduleEditErrorVolumeTooMuch => 'Volume too much';

  @override
  String get dosingScheduleEditErrorVolumeOutOfRange =>
      'Volume exceeds maximum limit';

  @override
  String get dosingScheduleEditErrorDetailsEmpty => 'Time slots are required';

  @override
  String get dosingScheduleEditErrorTimeExists => 'Time already exists';

  @override
  String get dosingScheduleEditTimeSlotTitle => 'Edit Time Slot';

  @override
  String get dosingScheduleEditSelectStartTime => 'Select Start Time';

  @override
  String get dosingScheduleEditSelectEndTime => 'Select End Time';

  @override
  String get dosingScheduleEditDropTimesLabel => 'Drop Times';

  @override
  String get dosingCalibrationAdjustListTitle => 'Adjustment List';

  @override
  String get dosingResetDevice => 'Reset Device';

  @override
  String get dosingResetDeviceSuccess => 'Device reset successfully';

  @override
  String get dosingNoPumpHeads => 'No pump heads';

  @override
  String get dosingHistorySubtitle => 'History';

  @override
  String get dosingAdjustListTitle => 'Adjustment List';

  @override
  String get dosingAdjustListStartAdjust => 'Start Adjustment';

  @override
  String get dosingRotatingSpeedLow => 'Low';

  @override
  String get dosingRotatingSpeedMedium => 'Medium';

  @override
  String get dosingRotatingSpeedHigh => 'High';

  @override
  String get dosingAdjustListEmptyTitle => 'No Adjustments';

  @override
  String get dosingAdjustListEmptySubtitle => 'No adjustment records yet';

  @override
  String get dropSettingTitle => 'Drop Settings';

  @override
  String get delayTime => 'Delay Time';

  @override
  String get delayTimeRequiresConnection =>
      'Connection required for delay time';

  @override
  String get sinkPositionFeatureComingSoon => 'Coming soon';

  @override
  String get dropTypeTitle => 'Drop Types';

  @override
  String get dropTypeSubtitle => 'Manage drop types';

  @override
  String get dropTypeNo => 'No';

  @override
  String get dropTypeAddTitle => 'Add Drop Type';

  @override
  String get dropTypeNameLabel => 'Drop Type Name';

  @override
  String get dropTypeNameHint => 'Enter drop type name';

  @override
  String get dropTypeAddSuccess => 'Drop type added';

  @override
  String get dropTypeNameExists => 'Drop type name already exists';

  @override
  String get dropTypeEditTitle => 'Edit Drop Type';

  @override
  String get dropTypeEditSuccess => 'Drop type updated';

  @override
  String get dropTypeDeleteUsedTitle => 'Drop Type in Use';

  @override
  String get dropTypeDeleteTitle => 'Delete Drop Type';

  @override
  String get dropTypeDeleteUsedContent =>
      'This drop type is in use and cannot be deleted';

  @override
  String get dropTypeDeleteContent =>
      'Are you sure you want to delete this drop type?';

  @override
  String get dropTypeDeleteSuccess => 'Drop type deleted';

  @override
  String get dropTypeDeleteFailed => 'Failed to delete drop type';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';
}
