// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'KoralCore';

  @override
  String get tabHome => 'Home';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabDevice => 'Devices';

  @override
  String homeStatusConnected(String device) {
    return 'Connected to $device';
  }

  @override
  String get homeStatusDisconnected => 'No active device';

  @override
  String get homeConnectedCopy =>
      'Manage dosing and lighting right from your phone.';

  @override
  String get homeConnectCta => 'Connect a device';

  @override
  String get homeNoDeviceCopy =>
      'Pair your Koral doser or LED controller to manage schedules and lighting.';

  @override
  String get sectionDosingTitle => 'Dosing';

  @override
  String get sectionLedTitle => 'Lighting';

  @override
  String get bleDisconnectedWarning => 'Connect via Bluetooth to continue.';

  @override
  String get bleGuardDialogTitle => 'Bluetooth required';

  @override
  String get bleGuardDialogMessage =>
      'Connect to a device to access this feature.';

  @override
  String get bleGuardDialogButton => 'Got it';

  @override
  String get bleOnboardingPermissionTitle => 'เปิดใช้งานการเข้าถึงบลูทูธ';

  @override
  String get bleOnboardingPermissionCopy =>
      'เราใช้บลูทูธเพื่อค้นหาและควบคุมฮาร์ดแวร์ Koral ของคุณในบริเวณใกล้เคียง';

  @override
  String get bleOnboardingPermissionCta => 'อนุญาตให้เข้าถึง';

  @override
  String get bleOnboardingSettingsTitle => 'ต้องได้รับอนุญาตในการตั้งค่า';

  @override
  String get bleOnboardingSettingsCopy =>
      'การเข้าถึงบลูทูธถูกปฏิเสธก่อนหน้านี้เปิดการตั้งค่าระบบเพื่อเปิดใช้งาน';

  @override
  String get bleOnboardingSettingsCta => 'เปิดการตั้งค่า';

  @override
  String get bleOnboardingLocationTitle => 'อนุญาตให้เข้าถึงตำแหน่ง';

  @override
  String get bleOnboardingLocationCopy =>
      'Android ต้องมีการเข้าถึงตำแหน่งในเวอร์ชันเก่าเพื่อสแกนหาอุปกรณ์บลูทูธ';

  @override
  String get bleOnboardingBluetoothOffTitle => 'เปิดบลูทูธ';

  @override
  String get bleOnboardingBluetoothOffCopy =>
      'ต้องเปิดบลูทูธไว้เพื่อให้สามารถสแกนและควบคุมอุปกรณ์ของคุณต่อไปได้';

  @override
  String get bleOnboardingBluetoothCta => 'เปิดการตั้งค่าบลูทูธ';

  @override
  String get bleOnboardingUnavailableTitle => 'บลูทูธไม่พร้อมใช้งาน';

  @override
  String get bleOnboardingUnavailableCopy =>
      'อุปกรณ์นี้ไม่เปิดเผยวิทยุ Bluetooth ที่ KoralCore สามารถใช้ได้';

  @override
  String get bleOnboardingRetryCta => 'ลองอีกครั้ง';

  @override
  String get bleOnboardingLearnMore => 'เรียนรู้เพิ่มเติม';

  @override
  String get bleOnboardingSheetTitle => 'เหตุใด KoralCore จึงต้องการ Bluetooth';

  @override
  String get bleOnboardingSheetDescription =>
      'Bluetooth ขับเคลื่อนการค้นหาและควบคุมการจ่ายสารและฮาร์ดแวร์ระบบแสงสว่างของคุณนี่คือสิ่งที่จะเกิดขึ้นเมื่อคุณให้สิทธิ์การเข้าถึง';

  @override
  String get bleOnboardingSheetSearchTitle => 'ค้นหาอุปกรณ์ใกล้เคียง';

  @override
  String get bleOnboardingSheetSearchCopy =>
      'สแกนหาปริมาณแนวปะการัง, ไฟ LED แนวปะการัง และอุปกรณ์ Koral อื่นๆ รอบถังของคุณ';

  @override
  String get bleOnboardingSheetControlTitle => 'ควบคุมการให้ยาและแสงสว่าง';

  @override
  String get bleOnboardingSheetControlCopy =>
      'ซิงค์กำหนดการ ส่งคำสั่ง และอัปเดตเฟิร์มแวร์ให้ทันสมัยอยู่เสมอผ่านลิงก์ BLE ที่ปลอดภัย';

  @override
  String get bleOnboardingSheetFooter =>
      'ทันทีที่บลูทูธพร้อม เราจะทำการสแกนต่อโดยอัตโนมัติ';

  @override
  String get bleOnboardingDisabledHint =>
      'ให้สิทธิ์การเข้าถึง Bluetooth เพื่อเริ่มการสแกน';

  @override
  String get bleOnboardingBlockedEmptyTitle => 'จำเป็นต้องตั้งค่าบลูทูธ';

  @override
  String get bleOnboardingBlockedEmptyCopy =>
      'อนุญาตการเข้าถึงบลูทูธหรือเปิดใช้งานเพื่อค้นหาฮาร์ดแวร์แนวปะการังของคุณ';

  @override
  String get bluetoothHeader => 'Nearby devices';

  @override
  String get bluetoothScanCta => 'Scan for devices';

  @override
  String get bluetoothScanning => 'Scanning...';

  @override
  String get bluetoothEmptyState => 'No devices found yet.';

  @override
  String get bluetoothConnect => 'Connect';

  @override
  String get deviceHeader => 'My devices';

  @override
  String get deviceEmptyTitle => 'No devices yet';

  @override
  String get deviceEmptySubtitle =>
      'Use the Bluetooth tab to discover hardware.';

  @override
  String get deviceStateConnected => 'Connected';

  @override
  String get deviceStateDisconnected => 'Disconnected';

  @override
  String get deviceStateConnecting => 'Connecting';

  @override
  String get deviceActionConnect => 'Connect';

  @override
  String get deviceActionDisconnect => 'Disconnect';

  @override
  String get deviceDeleteMode => 'Delete';

  @override
  String get deviceSelectMode => 'Select';

  @override
  String get deviceDeleteConfirmTitle => 'Remove devices?';

  @override
  String get deviceDeleteConfirmMessage =>
      'The selected devices will be removed from this phone. This does not reset the hardware.';

  @override
  String get deviceDeleteConfirmPrimary => 'Remove';

  @override
  String get deviceDeleteConfirmSecondary => 'Keep';

  @override
  String get deviceActionDelete => 'Delete selected';

  @override
  String deviceSelectionCount(int count) {
    return '$count selected';
  }

  @override
  String get dosingHeader => 'Dosing';

  @override
  String get dosingSubHeader => 'Control daily dosing routines.';

  @override
  String get dosingEntrySchedule => 'Edit schedule';

  @override
  String get dosingEntryManual => 'Manual dose';

  @override
  String get dosingEntryCalibration => 'Calibration';

  @override
  String get dosingEntryHistory => 'Dose history';

  @override
  String get dosingScheduleAddButton => 'เพิ่มกำหนดการ';

  @override
  String get dosingScheduleEditTitleNew => 'กำหนดการใหม่';

  @override
  String get dosingScheduleEditTitleEdit => 'แก้ไขกำหนดการ';

  @override
  String get dosingScheduleEditDescription =>
      'กำหนดค่าช่องจ่ายสารสำหรับหัวปั๊มนี้';

  @override
  String get dosingScheduleEditTypeLabel => 'ประเภทกำหนดการ';

  @override
  String get dosingScheduleEditDoseLabel => 'ปริมาณต่อเหตุการณ์';

  @override
  String get dosingScheduleEditDoseHint => 'ป้อนจำนวนเป็นมิลลิลิตร';

  @override
  String get dosingScheduleEditEventsLabel => 'กิจกรรมต่อวัน';

  @override
  String get dosingScheduleEditStartTimeLabel => 'โดสแรก';

  @override
  String get dosingScheduleEditWindowStartLabel => 'หน้าต่างเริ่มต้น';

  @override
  String get dosingScheduleEditWindowEndLabel => 'ปลายหน้าต่าง';

  @override
  String get dosingScheduleEditWindowEventsLabel => 'เหตุการณ์ต่อหน้าต่าง';

  @override
  String get dosingScheduleEditRecurrenceLabel => 'การเกิดซ้ำ';

  @override
  String get dosingScheduleEditEnabledToggle => 'เปิดใช้งานกำหนดการ';

  @override
  String get dosingScheduleEditSave => 'บันทึกกำหนดการ';

  @override
  String get dosingScheduleEditSuccess => 'บันทึกกำหนดการแล้ว';

  @override
  String get dosingScheduleEditInvalidDose => 'ป้อนขนาดยาที่มากกว่าศูนย์';

  @override
  String get dosingScheduleEditInvalidWindow =>
      'เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มต้น';

  @override
  String get dosingScheduleEditTemplateDaily => 'ใช้เทมเพลตเฉลี่ยรายวัน';

  @override
  String get dosingScheduleEditTemplateCustom =>
      'ใช้เทมเพลตหน้าต่างแบบกำหนดเอง';

  @override
  String get dosingManualPageSubtitle =>
      'Run an on-demand dose from this pump head.';

  @override
  String get dosingManualDoseInputLabel => 'Dose amount';

  @override
  String get dosingManualDoseInputHint => 'Enter the amount in milliliters.';

  @override
  String get dosingManualConfirmTitle => 'Send manual dose?';

  @override
  String get dosingManualConfirmMessage =>
      'This dose will start immediately. Make sure your dosing line is ready.';

  @override
  String get dosingManualInvalidDose => 'Enter a dose greater than zero.';

  @override
  String get ledHeader => 'Lighting';

  @override
  String get ledSubHeader => 'Tune spectrums and schedules.';

  @override
  String get ledEntryIntensity => 'Adjust intensity';

  @override
  String get ledIntensityEntrySubtitle =>
      'Tune output for each lighting channel.';

  @override
  String get ledEntryPrograms => 'Scenes & programs';

  @override
  String get ledEntryManual => 'Manual control';

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
  String get comingSoon => 'Coming soon';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRetry => 'Retry';

  @override
  String get errorDeviceBusy => 'Device is busy. Try again shortly.';

  @override
  String get errorNoDevice => 'No active device.';

  @override
  String get errorNotSupported =>
      'This action is not supported on the connected device.';

  @override
  String get errorInvalidParam => 'Invalid parameters for this use case.';

  @override
  String get errorTransport =>
      'Bluetooth transport error. Check the signal and retry.';

  @override
  String get errorGeneric => 'Something went wrong. Please retry.';

  @override
  String get snackbarDeviceRemoved => 'Devices removed.';

  @override
  String get snackbarDeviceConnected => 'Device connected.';

  @override
  String get snackbarDeviceDisconnected => 'Device disconnected.';

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
  String get led_runtime_status => 'Runtime status';

  @override
  String get led_runtime_idle => 'Idle';

  @override
  String get led_runtime_applying => 'Applying';

  @override
  String get led_runtime_preview => 'Previewing';

  @override
  String get led_runtime_schedule_active => 'Schedule active';

  @override
  String get led_scene_currently_running => 'Currently running';

  @override
  String get led_scene_preset => 'Preset scene';

  @override
  String get led_scene_custom => 'Custom scene';

  @override
  String led_scene_channel_count(int count) {
    return '$count channels';
  }

  @override
  String get led_schedule_daily => 'Daily schedule';

  @override
  String get led_schedule_window => 'Time window';
}
