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
  String get ledScheduleStatusEnabled => 'Enabled';

  @override
  String get ledScheduleStatusDisabled => 'Disabled';
}
