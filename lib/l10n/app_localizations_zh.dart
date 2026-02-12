// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'KoralCore';

  @override
  String get tabHome => '首頁';

  @override
  String get tabBluetooth => '藍芽';

  @override
  String get tabDevice => '裝置';

  @override
  String homeStatusConnected(String device) {
    return '已連線至 $device';
  }

  @override
  String get homeStatusDisconnected => '目前尚無裝置';

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
  String get bleDisconnectedWarning => '請開啟藍芽';

  @override
  String get bleGuardDialogTitle => 'Bluetooth required';

  @override
  String get bleGuardDialogMessage => '請開啟藍芽';

  @override
  String get bleGuardDialogButton => '我瞭解了';

  @override
  String get bleOnboardingPermissionTitle => '啟用藍牙訪問';

  @override
  String get bleOnboardingPermissionCopy => '我們使用藍牙來發現和控制您附近的 Koral 硬件。';

  @override
  String get bleOnboardingPermissionCta => '允許訪問';

  @override
  String get bleOnboardingSettingsTitle => '設置中需要權限';

  @override
  String get bleOnboardingSettingsCopy => '藍牙訪問之前被拒絕。打開系統設置以啟用它。';

  @override
  String get bleOnboardingSettingsCta => '打開設置';

  @override
  String get bleOnboardingLocationTitle => '允許位置訪問';

  @override
  String get bleOnboardingLocationCopy => 'Android 需要舊版本上的位置訪問權限才能掃描藍牙設備。';

  @override
  String get bleOnboardingBluetoothOffTitle => '打開藍牙';

  @override
  String get bleOnboardingBluetoothOffCopy => '藍牙必須保持打開狀態才能繼續掃描和控制您的設備。';

  @override
  String get bleOnboardingBluetoothCta => '打開藍牙設置';

  @override
  String get bleOnboardingUnavailableTitle => '藍牙不可用';

  @override
  String get bleOnboardingUnavailableCopy => '此設備不公開 KoralCore 可以使用的藍牙無線電。';

  @override
  String get bleOnboardingRetryCta => '重試';

  @override
  String get bleOnboardingLearnMore => '了解更多';

  @override
  String get bleOnboardingSheetTitle => '為什麼 KoralCore 需要藍牙';

  @override
  String get bleOnboardingSheetDescription =>
      '藍牙支持發現和控制您的劑量和照明硬件。以下是您授予訪問權限後會發生的情況。';

  @override
  String get bleOnboardingSheetSearchTitle => '查找附近的設備';

  @override
  String get bleOnboardingSheetSearchCopy =>
      '掃描水族箱周圍的 Reef Dose、Reef LED 和其他 Koral 設備。';

  @override
  String get bleOnboardingSheetControlTitle => '控製劑量和照明';

  @override
  String get bleOnboardingSheetControlCopy => '通過安全的 BLE 鏈路同步計劃、發送命令並保持固件最新。';

  @override
  String get bleOnboardingSheetFooter => '一旦藍牙準備就緒，我們就會自動恢復掃描。';

  @override
  String get bleOnboardingDisabledHint => '授予藍牙訪問權限以開始掃描。';

  @override
  String get bleOnboardingBlockedEmptyTitle => '需要藍牙設置';

  @override
  String get bleOnboardingBlockedEmptyCopy => '允許藍牙訪問或將其打開以發現您的珊瑚礁硬件。';

  @override
  String get bluetoothHeader => '藍芽連線';

  @override
  String get bluetoothScanCta => '掃描裝置';

  @override
  String get bluetoothScanning => '掃描中...';

  @override
  String get bluetoothEmptyState => '尚未找到裝置。';

  @override
  String get bluetoothConnect => '連線';

  @override
  String get bluetoothRearrangement => '重新整理';

  @override
  String get bluetoothOtherDevice => '其他裝置';

  @override
  String get bluetoothNoOtherDeviceTitle => '未發現裝置';

  @override
  String get bluetoothNoOtherDeviceContent => '點擊右上重新掃描附近裝置';

  @override
  String get bluetoothDisconnectDialogContent => '是否中斷藍芽連線?';

  @override
  String get bluetoothDisconnectDialogPositive => '確定';

  @override
  String get bluetoothDisconnectDialogNegative => '取消';

  @override
  String get deviceHeader => '裝置';

  @override
  String get deviceEmptyTitle => '目前尚無裝置';

  @override
  String get deviceEmptySubtitle => '使用藍芽標籤頁來發現硬體。';

  @override
  String get deviceInSinkEmptyTitle => '水槽目前沒有裝置';

  @override
  String get deviceInSinkEmptyContent => '下方切換藍芽列表新增裝置';

  @override
  String get deviceStateConnected => '已連線';

  @override
  String get deviceStateDisconnected => '未連線';

  @override
  String get deviceStateConnecting => '連線中';

  @override
  String get deviceActionConnect => '連線';

  @override
  String get deviceActionDisconnect => '斷線';

  @override
  String get deviceDeleteMode => '刪除';

  @override
  String get deviceSelectMode => '選取';

  @override
  String get deviceDeleteConfirmTitle => '';

  @override
  String get deviceDeleteConfirmMessage => '是否刪除所選設備?';

  @override
  String get deviceDeleteConfirmPrimary => '刪除';

  @override
  String get deviceDeleteConfirmSecondary => '取消';

  @override
  String get deviceDeleteLedMasterTitle => '主從設定';

  @override
  String get deviceDeleteLedMasterContent => '欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈';

  @override
  String get deviceDeleteLedMasterPositive => '我瞭解了';

  @override
  String get deviceActionDelete => '刪除所選';

  @override
  String deviceSelectionCount(int count) {
    return '已選 $count 個';
  }

  @override
  String get toastDeleteDeviceSuccessful => '刪除設備成功';

  @override
  String get toastDeleteDeviceFailed => '刪除設備失敗';

  @override
  String get dosingHeader => 'Dosing';

  @override
  String get dosingSubHeader => 'Control daily dosing routines.';

  @override
  String get dosingEntrySchedule => 'Edit schedule';

  @override
  String get dosingEntryManual => 'Manual dose';

  @override
  String get dosingEntryCalibration => '校正';

  @override
  String get dosingEntryHistory => 'Dose history';

  @override
  String get dosingScheduleAddButton => '添加日程';

  @override
  String get dosingScheduleEditTitleNew => '新時間表';

  @override
  String get dosingScheduleEditTitleEdit => '編輯日程';

  @override
  String get dosingScheduleEditDescription => '為此泵頭配置計量窗口。';

  @override
  String get dosingScheduleEditTypeLabel => '日程類型';

  @override
  String get dosingScheduleEditDoseLabel => '每次事件的劑量';

  @override
  String get dosingScheduleEditDoseHint => '輸入以毫升為單位的量。';

  @override
  String get dosingScheduleEditEventsLabel => '每天的活動';

  @override
  String get dosingScheduleEditStartTimeLabel => '第一劑';

  @override
  String get dosingScheduleEditWindowStartLabel => '窗口啟動';

  @override
  String get dosingScheduleEditWindowEndLabel => '窗端';

  @override
  String get dosingScheduleEditWindowEventsLabel => '每個窗口的事件';

  @override
  String get dosingScheduleEditRecurrenceLabel => '復發';

  @override
  String get dosingScheduleEditEnabledToggle => '啟用時間表';

  @override
  String get dosingScheduleEditSave => '保存日程';

  @override
  String get dosingScheduleEditSuccess => '時間表已保存。';

  @override
  String get dosingScheduleEditInvalidDose => '輸入大於零的劑量。';

  @override
  String get dosingScheduleEditInvalidWindow => '結束時間必須晚於開始時間。';

  @override
  String get dosingScheduleEditTemplateDaily => '使用日平均模板';

  @override
  String get dosingScheduleEditTemplateCustom => '使用自定義窗口模板';

  @override
  String get dosingManualPageSubtitle =>
      'Run an on-demand dose from this pump head.';

  @override
  String get dosingManualDoseInputLabel => 'Dose amount';

  @override
  String get dosingManualDoseInputHint => '請輸入滴液量';

  @override
  String get dosingManualConfirmTitle => 'Send manual dose?';

  @override
  String get dosingManualConfirmMessage =>
      'This dose will start immediately. Make sure your dosing line is ready.';

  @override
  String get dosingManualInvalidDose => '每次滴液量不可低於1ml';

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
  String get ledScheduleEditInvalidName => '名稱不得為空';

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
  String get ledScheduleEditSuccess => '設定成功';

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
  String get actionCancel => '取消';

  @override
  String get actionConfirm => '確定';

  @override
  String get actionRetry => 'Retry';

  @override
  String get errorDeviceBusy => '此泵頭正在執行滴液動作，請稍後再試';

  @override
  String get errorNoDevice => '裝置未連線';

  @override
  String get errorNotSupported =>
      'This action is not supported on the connected device.';

  @override
  String get errorInvalidParam => 'Invalid parameters for this use case.';

  @override
  String get errorTransport =>
      'Bluetooth transport error. Check the signal and retry.';

  @override
  String get errorSinkFull => '水槽已滿';

  @override
  String get errorSinkGroupsFull =>
      'All LED groups in this sink are full. Maximum 4 devices per group.';

  @override
  String get errorConnectLimit => '最多可1個裝置同時連線';

  @override
  String get errorLedMasterCannotDelete => '欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈';

  @override
  String get errorDeleteFailed => '刪除設備失敗';

  @override
  String get errorGeneric => 'Something went wrong. Please retry.';

  @override
  String get snackbarDeviceRemoved => '刪除設備成功';

  @override
  String get snackbarDeviceConnected => '連線成功';

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
  String get dosingPumpHeadManualDoseSuccess => '設定成功';

  @override
  String get dosingPumpHeadTimedDose => 'Schedule timed dose';

  @override
  String get dosingPumpHeadTimedDoseSuccess => '設定成功';

  @override
  String get dosingPumpHeadCalibrate => 'Calibrate head';

  @override
  String get dosingPumpHeadPlaceholder => '無設定排程';

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
  String get dosingTodayTotalEmpty => '無設定排程';

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
  String get dosingScheduleApplyDailyAverageSuccess => '設定成功';

  @override
  String get dosingScheduleApplyCustomWindow => 'Apply custom window schedule';

  @override
  String get dosingScheduleApplyCustomWindowSuccess => '設定成功';

  @override
  String get dosingScheduleViewButton => 'View schedules';

  @override
  String get dosingScheduleEmptyTitle => '無設定排程';

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
  String get ledScheduleDerivedLabel => '來源：LED 排程紀錄';

  @override
  String get ledRecordsTitle => 'LED 記錄';

  @override
  String get ledRecordsSubtitle => '管理 24 小時照明時間軸中的每個時間點。';

  @override
  String get ledRecordsEmptyTitle => '沒有可用記錄';

  @override
  String get ledRecordsEmptySubtitle => '在 Reef B 應用程式中建立記錄以在此查看。';

  @override
  String get ledRecordsSelectedTimeLabel => '選定時間';

  @override
  String get ledRecordsStatusIdle => '就緒';

  @override
  String get ledRecordsStatusApplying => '同步中...';

  @override
  String get ledRecordsStatusPreview => '預覽中';

  @override
  String get ledRecordsActionPrev => '上一個';

  @override
  String get ledRecordsActionNext => '下一個';

  @override
  String get ledRecordsActionDelete => '刪除';

  @override
  String get ledRecordsActionClear => '清除全部';

  @override
  String get ledRecordsActionPreviewStart => '預覽';

  @override
  String get ledRecordsActionPreviewStop => '停止預覽';

  @override
  String get ledRecordsClearConfirmTitle => '清除所有記錄？';

  @override
  String get ledRecordsClearConfirmMessage => '是否要清除排程？';

  @override
  String get ledRecordsDeleteConfirmTitle => '刪除記錄？';

  @override
  String get ledRecordsDeleteConfirmMessage => '從 LED 排程中移除選定的時間點？';

  @override
  String get ledMoveMasterDialogTitle => '主從設定';

  @override
  String get ledMoveMasterDialogContent => '欲移動此裝置至其他水槽，請先修改主從設定，將其他副燈設定為主燈。';

  @override
  String ledSceneDeleteConfirmMessage(String name) {
    return '是否要刪除場景？';
  }

  @override
  String get ledRecordsSnackDeleted => '刪除時間點成功。';

  @override
  String get ledRecordsSnackDeleteFailed => '刪除時間點失敗。';

  @override
  String get ledRecordsSnackCleared => '記錄已清除。';

  @override
  String get ledRecordsSnackClearFailed => '無法清除記錄。';

  @override
  String get ledRecordsSnackMissingSelection => '請先選擇記錄。';

  @override
  String get ledRecordsSnackPreviewStarted => '一分鐘快速預覽開始';

  @override
  String get ledRecordsSnackPreviewStopped => '一分鐘快速預覽結束';

  @override
  String get ledRecordsSnackRecordsFull => '最多可設定 24 個時間點。';

  @override
  String get ledRecordsSnackTimeExists => '此時間區段已重複設定。';

  @override
  String get ledRecordsSnackTimeError => '時間點需間隔大於10分鐘。';

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
  String get dosingPumpHeadSettingsNameEmpty => '名稱不得為空';

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
  String get dosingPumpHeadSettingsUnsavedStay => '取消';

  @override
  String get dosingPumpHeadSettingsSave => '儲存';

  @override
  String get dosingPumpHeadSettingsCancel => '取消';

  @override
  String dosingPumpHeadSettingsDelayOption(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get dosingScheduleStatusEnabled => 'Enabled';

  @override
  String get dosingScheduleStatusDisabled => '排程已暫停';

  @override
  String get dosingScheduleDeleteConfirmMessage => 'Delete this schedule?';

  @override
  String get dosingScheduleDeleted => 'Schedule deleted.';

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
  String get actionNext => 'Next';

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
  String get deviceSettingsDeleteConfirm =>
      'Are you sure you want to remove this device?';

  @override
  String get deviceSettingsDeleteDevice => 'Delete Device';

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
  String get ledMasterSettingTitle => 'Master-Slave Pairing';

  @override
  String get ledSetMaster => 'Set as Master Light';

  @override
  String get ledMoveGroup => 'Move Group';

  @override
  String get ledMasterSettingMenuPlaceholder =>
      'Requires device and sink configuration.';

  @override
  String get ledRecordTimeSettingTimeLabel => 'Time';

  @override
  String get ledRecordTimeSettingSpectrumLabel => 'Spectrum';

  @override
  String get ledRecordTimeSettingChannelsLabel => 'Channels';

  @override
  String get ledRecordTimeSettingErrorTime => 'Invalid time';

  @override
  String get ledRecordTimeSettingErrorTimeExists => 'Time already exists';

  @override
  String get ledRecordTimeSettingSuccess => 'Record saved';

  @override
  String get ledSceneNameLabel => '場景名稱';

  @override
  String get ledSceneNameHint => '輸入場景名稱';

  @override
  String get ledSceneIcon => '場景圖標';

  @override
  String get lightUv => 'UV 燈';

  @override
  String get lightPurple => '紫光';

  @override
  String get lightBlue => '藍光';

  @override
  String get lightRoyalBlue => '皇家藍光';

  @override
  String get lightGreen => '綠光';

  @override
  String get lightRed => '紅光';

  @override
  String get lightColdWhite => '冷白光';

  @override
  String get lightWarmWhite => '暖白光';

  @override
  String get lightMoon => '月光';

  @override
  String get ledSceneAddSuccess => '添加場景成功。';

  @override
  String get toastNameIsEmpty => '名稱不得為空';

  @override
  String get toastSettingSuccessful => '設定成功';

  @override
  String get toastSettingFailed => 'Settings failed.';

  @override
  String get toastSetTimeError =>
      'Time points must be at least 10 minutes apart.';

  @override
  String get toastSetTimeIsExist => 'This time period has already been set.';

  @override
  String get hintSelectTime => 'Please select a time.';

  @override
  String get toastSceneNameIsExist => '場景名稱重複';

  @override
  String get ledSceneNameIsExist => '場景名稱重複';

  @override
  String get ledSceneDeleteDescription => 'Select scenes to delete';

  @override
  String get ledSceneDeleteEmpty => 'No scenes to delete';

  @override
  String get ledSceneDeleteConfirmTitle => '刪除場景？';

  @override
  String ledSceneDeleteSuccess(String name) {
    return '刪除場景成功。';
  }

  @override
  String get ledSceneDeleteError => '刪除場景失敗。';

  @override
  String get toastDeleteNowScene => '不可刪除目前使用的場景';

  @override
  String get ledSceneDeleteLocalScenesTitle => 'Local Scenes';

  @override
  String get ledSceneDeleteDeviceScenesTitle => 'Device Scenes (Read-only)';

  @override
  String get ledSceneDeleteCannotDeleteDeviceScenes =>
      'Cannot delete device scenes';

  @override
  String ledSceneIdLabel(String id) {
    return 'Scene ID: $id';
  }

  @override
  String get ledSceneLimitReached => 'Maximum 5 custom scenes can be set.';

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
  String get ledRecordSettingInitStrength => '起始強度';

  @override
  String get ledRecordSettingSunrise => '日出';

  @override
  String get ledRecordSettingSunset => '日落';

  @override
  String get ledRecordSettingSlowStart => '緩啟動';

  @override
  String get ledRecordSettingMoonlight => '月光';

  @override
  String get ledRecordSettingErrorSunTime => '日出時間、日落時間設定錯誤。';

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
  String get deviceActionFavorite => 'Favorite';

  @override
  String get deviceActionUnfavorite => 'Unfavorite';

  @override
  String get deviceFavorited => 'Device favorited';

  @override
  String get deviceUnfavorited => 'Device unfavorited';

  @override
  String get ledOrientationPortrait => 'Portrait';

  @override
  String get ledOrientationLandscape => 'Landscape';

  @override
  String get ledFavoriteScenesTitle => 'Favorite Scenes';

  @override
  String get ledFavoriteScenesSubtitle => 'Your favorite scenes';

  @override
  String get ledContinueRecord => 'Resume execution.';

  @override
  String get actionPlay => 'Run';

  @override
  String get ledResetDevice => 'Reset Device';

  @override
  String get sinkTypeDefault => 'Default';

  @override
  String get sinkPosition => 'Tank Location';

  @override
  String get sinkPositionTitle => 'Sink Position';

  @override
  String get sinkPositionNotSet => 'Not Set';

  @override
  String get errorLedMasterCannotMove =>
      'To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light.';

  @override
  String get masterSetting => 'Master Setting';

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
  String get sinkEditSuccess => 'Sink updated.';

  @override
  String get sinkDeleteSuccess => 'Sink deleted.';

  @override
  String sinkDeviceCount(int count) {
    return '$count devices';
  }

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
  String get dosingResetDevice => '恢复默认设置';

  @override
  String get dosingResetDeviceSuccess => '设备已成功恢复默认设置';

  @override
  String get dosingResetDeviceFailed => '恢复默认设置失败';

  @override
  String get dosingResetDeviceConfirm => '此装置将成为未分配装置并清除目前所有泵头设定、校正纪录';

  @override
  String get dosingDeleteDeviceConfirm => '是否删除此滴液泵?';

  @override
  String get dosingDeleteDeviceSuccess => '删除设备成功';

  @override
  String get dosingTodayDropOutOfRangeTitle => '每日最大滴液量';

  @override
  String get dosingTodayDropOutOfRangeContent => '今日滴液量已达到每日最大滴液量';

  @override
  String get dosingDropHeadIsDropping => '此泵头正在执行滴液动作，请稍后再试';

  @override
  String get dosingDeleteDeviceFailed => '删除设备失败';

  @override
  String get actionReset => '恢复默认';

  @override
  String get dosingNoPumpHeads => 'No pump heads';

  @override
  String get dosingHistorySubtitle => 'History';

  @override
  String get dosingAdjustListTitle => 'Calibration Log';

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
  String get delay15Sec => '15 sec';

  @override
  String get delay30Sec => '30 sec';

  @override
  String get delay1Min => '1 min';

  @override
  String get delay2Min => '2 min';

  @override
  String get delay3Min => '3 min';

  @override
  String get delay4Min => '4 min';

  @override
  String get delay5Min => '5 min';

  @override
  String delaySecondsFallback(int seconds) {
    return '$seconds秒';
  }

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

  @override
  String get group => '群組';

  @override
  String get led => 'LED';

  @override
  String get drop => '滴液泵';

  @override
  String get masterSlave => '主從';

  @override
  String get time => '時間點';

  @override
  String get record => '排程';

  @override
  String get ledScene => '場景';

  @override
  String get unassignedDevice => '未分配裝置';

  @override
  String get ledSceneNoSetting => '無設定';

  @override
  String get dosingAdjustListDate => '日期';

  @override
  String get dosingAdjustListVolume => '測量體積';

  @override
  String get dosingAdjustTitle => 'Calibration';

  @override
  String get dosingAdjustDescription => 'Calibration Instructions';

  @override
  String get dosingAdjustStep =>
      '1. Prepare the included measuring cup and some tubes\n2. Start manual operation to fill the tubes with liquid\n3. Select the speed for calibration';

  @override
  String get dosingRotatingSpeedTitle => 'Rotating Speed';

  @override
  String get dosingDropVolume => 'Drop Volume';

  @override
  String get dosingAdjustVolumeHint => '1 ~ 15; one decimal place';

  @override
  String get dosingCompleteAdjust => 'Complete Calibration';

  @override
  String get dosingAdjusting => 'Calibrating...';

  @override
  String get dosingAdjustVolumeEmpty => 'Drop volume cannot be empty';

  @override
  String get dosingStartAdjustFailed => 'Failed to start calibration';

  @override
  String get dosingAdjustSuccessful => 'Calibration successful';

  @override
  String get dosingAdjustFailed => 'Calibration failed';

  @override
  String get homeSpinnerAllSink => '所有水槽';

  @override
  String get homeSpinnerFavorite => '喜愛裝置';

  @override
  String get homeSpinnerUnassigned => '未分配設備';

  @override
  String get dosingPumpHeadNoType => '無種類';

  @override
  String get dosingPumpHeadModeScheduled => '排程模式';

  @override
  String get dosingPumpHeadModeFree => '自由模式';

  @override
  String get dosingVolumeHint => '請輸入滴液量';

  @override
  String get noRecords => '無排程任務';

  @override
  String dosingManualStarted(String headId) {
    return '泵頭 $headId 已開始滴液';
  }

  @override
  String dosingVolumeFormat(String dispensed, String target) {
    return '$dispensed / $target ml';
  }

  @override
  String channelPercentageFormat(String label, int percentage) {
    return '$label $percentage%';
  }

  @override
  String get timeRangeSeparator => '~';

  @override
  String get dosingVolume => 'Dosing Volume (ml)';

  @override
  String get dosingStartTime => 'Dosing Start Time';

  @override
  String get dosingEndTime => 'Dosing End Time';

  @override
  String get dosingFrequency => 'Dosing Frequency';

  @override
  String get dosingType => 'Dosing Type';

  @override
  String get dosingScheduleType => 'Schedule Type';

  @override
  String get dosingSchedulePeriod => 'Schedule Period';

  @override
  String get dosingWeeklyDays => 'Weekly Dosing Days';

  @override
  String get dosingExecuteNow => 'Execute Now';

  @override
  String get dosingExecutionTime => 'Execution Time';

  @override
  String get pumpHeadSpeed => 'Pump Head Speed';

  @override
  String get pumpHeadSpeedLow => 'Low Speed';

  @override
  String get pumpHeadSpeedMedium => 'Medium Speed';

  @override
  String get pumpHeadSpeedHigh => 'High Speed';

  @override
  String get pumpHeadSpeedDefault => 'Default Speed';

  @override
  String get calibrationInstructions => 'Calibration Instructions';

  @override
  String get calibrationSteps =>
      '1.Prepare the included measuring cup and some tubes\n2. Start manual operation to fill the tubes with liquid\n3. Select the speed for calibration';

  @override
  String get calibrationVolumeHint => '1 ~ 15; one decimal place';

  @override
  String get calibrating => 'Calibrating...';

  @override
  String get calibrationComplete => 'Complete Calibration';

  @override
  String get recentCalibrationRecords => 'Recent Calibration Records';

  @override
  String get todayScheduledVolume =>
      'Today\'s Scheduled Immediate Dosing Volume';

  @override
  String get maxDosingVolume => 'Daily Max Dosing Volume';

  @override
  String get maxDosingVolumeHint =>
      'Limit dosing volume for scheduled and non-scheduled operation after opening';

  @override
  String get delayTime1Min => '1 minute';

  @override
  String get dosingSettingsTitle => 'Dosing Pump Settings';

  @override
  String get pumpHeadRecordTitle => 'Schedule';

  @override
  String get pumpHeadRecordSettingsTitle => 'Schedule Settings';

  @override
  String get pumpHeadRecordTimeSettingsTitle => 'Period Settings';

  @override
  String get pumpHeadAdjustListTitle => 'Adjust List';

  @override
  String get pumpHeadAdjustTitle => 'Adjust';

  @override
  String get dosingTypeTitle => 'Dosing Type';

  @override
  String get rotatingSpeed => 'Speed';

  @override
  String get ledInitialIntensity => 'Initial Intensity';

  @override
  String get ledSunrise => 'Sunrise';

  @override
  String get ledSunset => 'Sunset';

  @override
  String get ledSlowStart => 'Soft Start';

  @override
  String get ledInitDuration => '30 Minutes';

  @override
  String get ledScheduleTimePoint => 'Scheduled Time Point';

  @override
  String get ledScheduleSettings => 'Schedule Settings';

  @override
  String get ledSceneAdd => 'Add Scene';

  @override
  String get ledSceneEdit => 'Scene Settings';

  @override
  String get ledSceneDelete => 'Delete Scene';

  @override
  String get ledRecordPause => 'The schedule is paused.';

  @override
  String get ledRecordContinue => 'Resume execution.';

  @override
  String get actionEdit => 'Edit';

  @override
  String get generalNone => 'None';

  @override
  String get actionComplete => 'Done';

  @override
  String get actionRun => 'Run';

  @override
  String get deviceNotConnected => 'Device not connected';

  @override
  String get sinkEmptyMessage =>
      'Tap the add button at the bottom right to add a tank.';

  @override
  String get bottomSheetAddSinkTitle => 'Add Tank';

  @override
  String get bottomSheetAddSinkFieldTitle => 'Tank Name';

  @override
  String get bottomSheetEditSinkTitle => 'Tank Settings';

  @override
  String get bottomSheetEditSinkFieldTitle => 'Tank Name';

  @override
  String get bottomSheetAddDropTypeTitle => 'Add Custom Dosing';

  @override
  String get bottomSheetAddDropTypeFieldTitle => 'Dosing Name';

  @override
  String get bottomSheetEditDropTypeTitle => 'Edit Custom Dosing';

  @override
  String get bottomSheetEditDropTypeFieldTitle => 'Dosing Name';

  @override
  String get dosingVolumeRangeHint => '1 ~ 500';

  @override
  String get dropRecordTypeNone => 'No Scheduled Tasks';

  @override
  String get dosingAdjustDateTitle => 'Calibration Date';

  @override
  String get dosingAdjustVolumeTitle => 'Measured Volume';

  @override
  String get groupPlaceholder => 'Group A';

  @override
  String get ledChartPlaceholder => 'Chart Placeholder';

  @override
  String get ledSpectrumChartPlaceholder => 'Spectrum Chart Placeholder';

  @override
  String get ledTimePlaceholder => '07:27';

  @override
  String get dosingRecordTimePlaceholder => '08:00';

  @override
  String get dosingRecordEndTimePlaceholder => '10:00';

  @override
  String get dosingRecordDetailPlaceholder => '50 ml / 5 times';

  @override
  String get dosingTypeNamePlaceholder => 'Type A';

  @override
  String get dosingTypeNamePlaceholderB => 'Type B';

  @override
  String get dosingTypeNamePlaceholderC => 'Type C';

  @override
  String get dosingRecordTimeRangePlaceholder => '2022-10-14 ~ 2022-10-31';

  @override
  String get dosingRecordTimePointPlaceholder => '2022-10-14 10:20:13';

  @override
  String get dosingAdjustDatePlaceholder => '2024-01-01 12:00:00';

  @override
  String get dosingAdjustVolumePlaceholder => '10.0 ml';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'KoralCore';

  @override
  String get tabHome => '首頁';

  @override
  String get tabBluetooth => '藍芽';

  @override
  String get tabDevice => '裝置';

  @override
  String homeStatusConnected(String device) {
    return '已連線至 $device';
  }

  @override
  String get homeStatusDisconnected => '目前尚無裝置';

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
  String get bleDisconnectedWarning => '請開啟藍芽';

  @override
  String get bleGuardDialogTitle => 'Bluetooth required';

  @override
  String get bleGuardDialogMessage => '請開啟藍芽';

  @override
  String get bleGuardDialogButton => '我瞭解了';

  @override
  String get bleOnboardingPermissionTitle => '啟用藍牙訪問';

  @override
  String get bleOnboardingPermissionCopy => '我們使用藍牙來發現和控制您附近的 Koral 硬件。';

  @override
  String get bleOnboardingPermissionCta => '允許訪問';

  @override
  String get bleOnboardingSettingsTitle => '設置中需要權限';

  @override
  String get bleOnboardingSettingsCopy => '藍牙訪問之前被拒絕。打開系統設置以啟用它。';

  @override
  String get bleOnboardingSettingsCta => '打開設置';

  @override
  String get bleOnboardingLocationTitle => '允許位置訪問';

  @override
  String get bleOnboardingLocationCopy => 'Android 需要舊版本上的位置訪問權限才能掃描藍牙設備。';

  @override
  String get bleOnboardingBluetoothOffTitle => '打開藍牙';

  @override
  String get bleOnboardingBluetoothOffCopy => '藍牙必須保持打開狀態才能繼續掃描和控制您的設備。';

  @override
  String get bleOnboardingBluetoothCta => '打開藍牙設置';

  @override
  String get bleOnboardingUnavailableTitle => '藍牙不可用';

  @override
  String get bleOnboardingUnavailableCopy => '此設備不公開 KoralCore 可以使用的藍牙無線電。';

  @override
  String get bleOnboardingRetryCta => '重試';

  @override
  String get bleOnboardingLearnMore => '了解更多';

  @override
  String get bleOnboardingSheetTitle => '為什麼 KoralCore 需要藍牙';

  @override
  String get bleOnboardingSheetDescription =>
      '藍牙支持發現和控制您的劑量和照明硬件。以下是您授予訪問權限後會發生的情況。';

  @override
  String get bleOnboardingSheetSearchTitle => '查找附近的設備';

  @override
  String get bleOnboardingSheetSearchCopy =>
      '掃描水族箱周圍的 Reef Dose、Reef LED 和其他 Koral 設備。';

  @override
  String get bleOnboardingSheetControlTitle => '控製劑量和照明';

  @override
  String get bleOnboardingSheetControlCopy => '通過安全的 BLE 鏈路同步計劃、發送命令並保持固件最新。';

  @override
  String get bleOnboardingSheetFooter => '一旦藍牙準備就緒，我們就會自動恢復掃描。';

  @override
  String get bleOnboardingDisabledHint => '授予藍牙訪問權限以開始掃描。';

  @override
  String get bleOnboardingBlockedEmptyTitle => '需要藍牙設置';

  @override
  String get bleOnboardingBlockedEmptyCopy => '允許藍牙訪問或將其打開以發現您的珊瑚礁硬件。';

  @override
  String get bluetoothHeader => '藍芽連線';

  @override
  String get bluetoothScanCta => '掃描裝置';

  @override
  String get bluetoothScanning => '掃描中...';

  @override
  String get bluetoothEmptyState => '尚未找到裝置。';

  @override
  String get bluetoothConnect => '連線';

  @override
  String get bluetoothRearrangement => '重新整理';

  @override
  String get bluetoothOtherDevice => '其他裝置';

  @override
  String get bluetoothNoOtherDeviceTitle => '未發現裝置';

  @override
  String get bluetoothNoOtherDeviceContent => '點擊右上重新掃描附近裝置';

  @override
  String get bluetoothDisconnectDialogContent => '是否中斷藍芽連線?';

  @override
  String get bluetoothDisconnectDialogPositive => '確定';

  @override
  String get bluetoothDisconnectDialogNegative => '取消';

  @override
  String get deviceHeader => '裝置';

  @override
  String get deviceEmptyTitle => '目前尚無裝置';

  @override
  String get deviceEmptySubtitle => '使用藍芽標籤頁來發現硬體。';

  @override
  String get deviceInSinkEmptyTitle => '水槽目前沒有裝置';

  @override
  String get deviceInSinkEmptyContent => '下方切換藍芽列表新增裝置';

  @override
  String get deviceStateConnected => '已連線';

  @override
  String get deviceStateDisconnected => '未連線';

  @override
  String get deviceStateConnecting => '連線中';

  @override
  String get deviceActionConnect => '連線';

  @override
  String get deviceActionDisconnect => '斷線';

  @override
  String get deviceDeleteMode => '刪除';

  @override
  String get deviceSelectMode => '選取';

  @override
  String get deviceDeleteConfirmTitle => '';

  @override
  String get deviceDeleteConfirmMessage => '是否刪除所選設備?';

  @override
  String get deviceDeleteConfirmPrimary => '刪除';

  @override
  String get deviceDeleteConfirmSecondary => '取消';

  @override
  String get deviceDeleteLedMasterTitle => '主從設定';

  @override
  String get deviceDeleteLedMasterContent => '欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈';

  @override
  String get deviceDeleteLedMasterPositive => '我瞭解了';

  @override
  String get deviceActionDelete => '刪除所選';

  @override
  String deviceSelectionCount(int count) {
    return '已選 $count 個';
  }

  @override
  String get toastDeleteDeviceSuccessful => '刪除設備成功';

  @override
  String get toastDeleteDeviceFailed => '刪除設備失敗';

  @override
  String get dosingHeader => 'Dosing';

  @override
  String get dosingSubHeader => 'Control daily dosing routines.';

  @override
  String get dosingEntrySchedule => 'Edit schedule';

  @override
  String get dosingEntryManual => 'Manual dose';

  @override
  String get dosingEntryCalibration => '校正';

  @override
  String get dosingEntryHistory => 'Dose history';

  @override
  String get dosingScheduleAddButton => '添加日程';

  @override
  String get dosingScheduleEditTitleNew => '新時間表';

  @override
  String get dosingScheduleEditTitleEdit => '編輯日程';

  @override
  String get dosingScheduleEditDescription => '為此泵頭配置計量窗口。';

  @override
  String get dosingScheduleEditTypeLabel => '日程類型';

  @override
  String get dosingScheduleEditDoseLabel => '每次事件的劑量';

  @override
  String get dosingScheduleEditDoseHint => '輸入以毫升為單位的量。';

  @override
  String get dosingScheduleEditEventsLabel => '每天的活動';

  @override
  String get dosingScheduleEditStartTimeLabel => '第一劑';

  @override
  String get dosingScheduleEditWindowStartLabel => '窗口啟動';

  @override
  String get dosingScheduleEditWindowEndLabel => '窗端';

  @override
  String get dosingScheduleEditWindowEventsLabel => '每個窗口的事件';

  @override
  String get dosingScheduleEditRecurrenceLabel => '復發';

  @override
  String get dosingScheduleEditEnabledToggle => '啟用時間表';

  @override
  String get dosingScheduleEditSave => '保存日程';

  @override
  String get dosingScheduleEditSuccess => '時間表已保存。';

  @override
  String get dosingScheduleEditInvalidDose => '輸入大於零的劑量。';

  @override
  String get dosingScheduleEditInvalidWindow => '結束時間必須晚於開始時間。';

  @override
  String get dosingScheduleEditTemplateDaily => '使用日平均模板';

  @override
  String get dosingScheduleEditTemplateCustom => '使用自定義窗口模板';

  @override
  String get dosingManualPageSubtitle =>
      'Run an on-demand dose from this pump head.';

  @override
  String get dosingManualDoseInputLabel => 'Dose amount';

  @override
  String get dosingManualDoseInputHint => '請輸入滴液量';

  @override
  String get dosingManualConfirmTitle => 'Send manual dose?';

  @override
  String get dosingManualConfirmMessage =>
      'This dose will start immediately. Make sure your dosing line is ready.';

  @override
  String get dosingManualInvalidDose => '每次滴液量不可低於1ml';

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
  String get ledScheduleEditInvalidName => '名稱不得為空';

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
  String get ledScheduleEditSuccess => '設定成功';

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
  String get actionCancel => '取消';

  @override
  String get actionConfirm => '確定';

  @override
  String get actionRetry => 'Retry';

  @override
  String get errorDeviceBusy => '此泵頭正在執行滴液動作，請稍後再試';

  @override
  String get errorNoDevice => '裝置未連線';

  @override
  String get errorNotSupported =>
      'This action is not supported on the connected device.';

  @override
  String get errorInvalidParam => 'Invalid parameters for this use case.';

  @override
  String get errorTransport =>
      'Bluetooth transport error. Check the signal and retry.';

  @override
  String get errorSinkFull => '水槽已滿';

  @override
  String get errorSinkGroupsFull =>
      'All LED groups in this sink are full. Maximum 4 devices per group.';

  @override
  String get errorConnectLimit => '最多可1個裝置同時連線';

  @override
  String get errorLedMasterCannotDelete => '欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈';

  @override
  String get errorDeleteFailed => '刪除設備失敗';

  @override
  String get errorGeneric => 'Something went wrong. Please retry.';

  @override
  String get snackbarDeviceRemoved => '刪除設備成功';

  @override
  String get snackbarDeviceConnected => '連線成功';

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
  String get dosingPumpHeadManualDoseSuccess => '設定成功';

  @override
  String get dosingPumpHeadTimedDose => 'Schedule timed dose';

  @override
  String get dosingPumpHeadTimedDoseSuccess => '設定成功';

  @override
  String get dosingPumpHeadCalibrate => 'Calibrate head';

  @override
  String get dosingPumpHeadPlaceholder => '無設定排程';

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
  String get dosingTodayTotalEmpty => '無設定排程';

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
  String get dosingScheduleApplyDailyAverageSuccess => '設定成功';

  @override
  String get dosingScheduleApplyCustomWindow => 'Apply custom window schedule';

  @override
  String get dosingScheduleApplyCustomWindowSuccess => '設定成功';

  @override
  String get dosingScheduleViewButton => 'View schedules';

  @override
  String get dosingScheduleEmptyTitle => '無設定排程';

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
  String get ledScheduleDerivedLabel => '來源：LED 排程紀錄';

  @override
  String get ledRecordsTitle => 'LED 記錄';

  @override
  String get ledRecordsSubtitle => '管理 24 小時照明時間軸中的每個時間點。';

  @override
  String get ledRecordsEmptyTitle => '沒有可用記錄';

  @override
  String get ledRecordsEmptySubtitle => '在 Reef B 應用程式中建立記錄以在此查看。';

  @override
  String get ledRecordsSelectedTimeLabel => '選定時間';

  @override
  String get ledRecordsStatusIdle => '就緒';

  @override
  String get ledRecordsStatusApplying => '同步中...';

  @override
  String get ledRecordsStatusPreview => '預覽中';

  @override
  String get ledRecordsActionPrev => '上一個';

  @override
  String get ledRecordsActionNext => '下一個';

  @override
  String get ledRecordsActionDelete => '刪除';

  @override
  String get ledRecordsActionClear => '清除全部';

  @override
  String get ledRecordsActionPreviewStart => '預覽';

  @override
  String get ledRecordsActionPreviewStop => '停止預覽';

  @override
  String get ledRecordsClearConfirmTitle => '清除所有記錄？';

  @override
  String get ledRecordsClearConfirmMessage => '是否要清除排程？';

  @override
  String get ledRecordsDeleteConfirmTitle => '刪除記錄？';

  @override
  String get ledRecordsDeleteConfirmMessage => '從 LED 排程中移除選定的時間點？';

  @override
  String get ledMoveMasterDialogTitle => '主從設定';

  @override
  String get ledMoveMasterDialogContent => '欲移動此裝置至其他水槽，請先修改主從設定，將其他副燈設定為主燈。';

  @override
  String ledSceneDeleteConfirmMessage(String name) {
    return '是否要刪除場景？';
  }

  @override
  String get ledRecordsSnackDeleted => '刪除時間點成功。';

  @override
  String get ledRecordsSnackDeleteFailed => '刪除時間點失敗。';

  @override
  String get ledRecordsSnackCleared => '記錄已清除。';

  @override
  String get ledRecordsSnackClearFailed => '無法清除記錄。';

  @override
  String get ledRecordsSnackMissingSelection => '請先選擇記錄。';

  @override
  String get ledRecordsSnackPreviewStarted => '一分鐘快速預覽開始';

  @override
  String get ledRecordsSnackPreviewStopped => '一分鐘快速預覽結束';

  @override
  String get ledRecordsSnackRecordsFull => '最多可設定 24 個時間點。';

  @override
  String get ledRecordsSnackTimeExists => '此時間區段已重複設定。';

  @override
  String get ledRecordsSnackTimeError => '時間點需間隔大於10分鐘。';

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
  String get dosingPumpHeadSettingsNameEmpty => '名稱不得為空';

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
  String get dosingPumpHeadSettingsUnsavedStay => '取消';

  @override
  String get dosingPumpHeadSettingsSave => '儲存';

  @override
  String get dosingPumpHeadSettingsCancel => '取消';

  @override
  String dosingPumpHeadSettingsDelayOption(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get dosingScheduleStatusEnabled => 'Enabled';

  @override
  String get dosingScheduleStatusDisabled => '排程已暫停';

  @override
  String get dosingScheduleDeleteConfirmMessage => 'Delete this schedule?';

  @override
  String get dosingScheduleDeleted => 'Schedule deleted.';

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
  String get actionSave => '儲存';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => '略過';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionNext => '下一步';

  @override
  String get deviceName => '裝置名稱';

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
  String get deviceSettingsDeleteConfirm =>
      'Are you sure you want to remove this device?';

  @override
  String get deviceSettingsDeleteDevice => 'Delete Device';

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
  String get ledMasterSettingTitle => 'Master-Slave Pairing';

  @override
  String get ledSetMaster => 'Set as Master Light';

  @override
  String get ledMoveGroup => 'Move Group';

  @override
  String get ledMasterSettingMenuPlaceholder =>
      'Requires device and sink configuration.';

  @override
  String get ledRecordTimeSettingTimeLabel => 'Time';

  @override
  String get ledRecordTimeSettingSpectrumLabel => 'Spectrum';

  @override
  String get ledRecordTimeSettingChannelsLabel => 'Channels';

  @override
  String get ledRecordTimeSettingErrorTime => 'Invalid time';

  @override
  String get ledRecordTimeSettingErrorTimeExists => 'Time already exists';

  @override
  String get ledRecordTimeSettingSuccess => 'Record saved';

  @override
  String get ledSceneNameLabel => '場景名稱';

  @override
  String get ledSceneNameHint => '輸入場景名稱';

  @override
  String get ledSceneIcon => '場景圖標';

  @override
  String get lightUv => 'UV 燈';

  @override
  String get lightPurple => '紫光';

  @override
  String get lightBlue => '藍光';

  @override
  String get lightRoyalBlue => '皇家藍光';

  @override
  String get lightGreen => '綠光';

  @override
  String get lightRed => '紅光';

  @override
  String get lightColdWhite => '冷白光';

  @override
  String get lightWarmWhite => '暖白光';

  @override
  String get lightMoon => '月光';

  @override
  String get ledSceneAddSuccess => '添加場景成功。';

  @override
  String get toastNameIsEmpty => '名稱不得為空';

  @override
  String get toastSettingSuccessful => '設定成功';

  @override
  String get toastSettingFailed => 'Settings failed.';

  @override
  String get toastSetTimeError =>
      'Time points must be at least 10 minutes apart.';

  @override
  String get toastSetTimeIsExist => 'This time period has already been set.';

  @override
  String get hintSelectTime => 'Please select a time.';

  @override
  String get toastSceneNameIsExist => '場景名稱重複';

  @override
  String get ledSceneNameIsExist => '場景名稱重複';

  @override
  String get ledSceneDeleteDescription => 'Select scenes to delete';

  @override
  String get ledSceneDeleteEmpty => 'No scenes to delete';

  @override
  String get ledSceneDeleteConfirmTitle => '刪除場景？';

  @override
  String ledSceneDeleteSuccess(String name) {
    return '刪除場景成功。';
  }

  @override
  String get ledSceneDeleteError => '刪除場景失敗。';

  @override
  String get toastDeleteNowScene => '不可刪除目前使用的場景';

  @override
  String get ledSceneDeleteLocalScenesTitle => 'Local Scenes';

  @override
  String get ledSceneDeleteDeviceScenesTitle => 'Device Scenes (Read-only)';

  @override
  String get ledSceneDeleteCannotDeleteDeviceScenes =>
      'Cannot delete device scenes';

  @override
  String ledSceneIdLabel(String id) {
    return 'Scene ID: $id';
  }

  @override
  String get ledSceneLimitReached => 'Maximum 5 custom scenes can be set.';

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
  String get ledRecordSettingInitStrength => '起始強度';

  @override
  String get ledRecordSettingSunrise => '日出';

  @override
  String get ledRecordSettingSunset => '日落';

  @override
  String get ledRecordSettingSlowStart => '緩啟動';

  @override
  String get ledRecordSettingMoonlight => '月光';

  @override
  String get ledRecordSettingErrorSunTime => '日出時間、日落時間設定錯誤。';

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
  String get deviceActionFavorite => 'Favorite';

  @override
  String get deviceActionUnfavorite => 'Unfavorite';

  @override
  String get deviceFavorited => 'Device favorited';

  @override
  String get deviceUnfavorited => 'Device unfavorited';

  @override
  String get ledOrientationPortrait => 'Portrait';

  @override
  String get ledOrientationLandscape => 'Landscape';

  @override
  String get ledFavoriteScenesTitle => 'Favorite Scenes';

  @override
  String get ledFavoriteScenesSubtitle => 'Your favorite scenes';

  @override
  String get ledContinueRecord => 'Resume execution.';

  @override
  String get actionPlay => 'Run';

  @override
  String get ledResetDevice => 'Reset Device';

  @override
  String get sinkTypeDefault => 'Default';

  @override
  String get sinkPosition => '水槽位置';

  @override
  String get sinkPositionTitle => 'Sink Position';

  @override
  String get sinkPositionNotSet => 'Not Set';

  @override
  String get errorLedMasterCannotMove =>
      'To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light.';

  @override
  String get masterSetting => 'Master Setting';

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
  String get sinkEditSuccess => 'Sink updated.';

  @override
  String get sinkDeleteSuccess => 'Sink deleted.';

  @override
  String sinkDeviceCount(int count) {
    return '$count devices';
  }

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
  String get dosingResetDevice => '恢復預設設定';

  @override
  String get dosingResetDeviceSuccess => '裝置已成功恢復預設設定';

  @override
  String get dosingResetDeviceFailed => '恢復預設設定失敗';

  @override
  String get dosingResetDeviceConfirm => '此裝置將成為未分配裝置並清除目前所有泵頭設定、校正紀錄';

  @override
  String get dosingDeleteDeviceConfirm => '是否刪除此滴液泵?';

  @override
  String get dosingDeleteDeviceSuccess => '刪除設備成功';

  @override
  String get dosingTodayDropOutOfRangeTitle => '每日最大滴液量';

  @override
  String get dosingTodayDropOutOfRangeContent => '今日滴液量已達到每日最大滴液量';

  @override
  String get dosingDropHeadIsDropping => '此泵頭正在執行滴液動作，請稍後再試';

  @override
  String get dosingDeleteDeviceFailed => '刪除設備失敗';

  @override
  String get actionReset => '恢復預設';

  @override
  String get dosingNoPumpHeads => 'No pump heads';

  @override
  String get dosingHistorySubtitle => 'History';

  @override
  String get dosingAdjustListTitle => 'Calibration Log';

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
  String get delayTime => '延遲時間';

  @override
  String get delayTimeRequiresConnection =>
      'Connection required for delay time';

  @override
  String get delay15Sec => '15 sec';

  @override
  String get delay30Sec => '30 sec';

  @override
  String get delay1Min => '1 min';

  @override
  String get delay2Min => '2 min';

  @override
  String get delay3Min => '3 min';

  @override
  String get delay4Min => '4 min';

  @override
  String get delay5Min => '5 min';

  @override
  String delaySecondsFallback(int seconds) {
    return '$seconds秒';
  }

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

  @override
  String get group => '群組';

  @override
  String get led => 'LED';

  @override
  String get drop => '滴液泵';

  @override
  String get masterSlave => '主從';

  @override
  String get time => '時間點';

  @override
  String get record => '排程';

  @override
  String get ledScene => '場景';

  @override
  String get unassignedDevice => '未分配裝置';

  @override
  String get ledSceneNoSetting => '無設定';

  @override
  String get dosingAdjustListDate => '日期';

  @override
  String get dosingAdjustListVolume => '測量體積';

  @override
  String get dosingAdjustTitle => 'Calibration';

  @override
  String get dosingAdjustDescription => 'Calibration Instructions';

  @override
  String get dosingAdjustStep =>
      '1. Prepare the included measuring cup and some tubes\n2. Start manual operation to fill the tubes with liquid\n3. Select the speed for calibration';

  @override
  String get dosingRotatingSpeedTitle => 'Rotating Speed';

  @override
  String get dosingDropVolume => 'Drop Volume';

  @override
  String get dosingAdjustVolumeHint => '1 ~ 15; one decimal place';

  @override
  String get dosingCompleteAdjust => 'Complete Calibration';

  @override
  String get dosingAdjusting => 'Calibrating...';

  @override
  String get dosingAdjustVolumeEmpty => 'Drop volume cannot be empty';

  @override
  String get dosingStartAdjustFailed => 'Failed to start calibration';

  @override
  String get dosingAdjustSuccessful => 'Calibration successful';

  @override
  String get dosingAdjustFailed => 'Calibration failed';

  @override
  String get homeSpinnerAllSink => '所有水槽';

  @override
  String get homeSpinnerFavorite => '喜愛裝置';

  @override
  String get homeSpinnerUnassigned => '未分配設備';

  @override
  String get dosingPumpHeadNoType => '無種類';

  @override
  String get dosingPumpHeadModeScheduled => '排程模式';

  @override
  String get dosingPumpHeadModeFree => '自由模式';

  @override
  String get dosingVolumeHint => '請輸入滴液量';

  @override
  String get noRecords => '無排程任務';

  @override
  String dosingManualStarted(String headId) {
    return '泵頭 $headId 已開始滴液';
  }

  @override
  String dosingVolumeFormat(String dispensed, String target) {
    return '$dispensed / $target ml';
  }

  @override
  String channelPercentageFormat(String label, int percentage) {
    return '$label $percentage%';
  }

  @override
  String get timeRangeSeparator => '~';

  @override
  String get dosingVolume => '滴液量 (ml)';

  @override
  String get dosingStartTime => '滴液開始時間';

  @override
  String get dosingEndTime => '滴液結束時間';

  @override
  String get dosingFrequency => '滴液次數';

  @override
  String get dosingType => '滴液種類';

  @override
  String get dosingScheduleType => '排程種類';

  @override
  String get dosingSchedulePeriod => '排程時段';

  @override
  String get dosingWeeklyDays => '一週滴液天數';

  @override
  String get dosingExecuteNow => '立即執行';

  @override
  String get dosingExecutionTime => '執行時間';

  @override
  String get pumpHeadSpeed => '泵頭轉速';

  @override
  String get pumpHeadSpeedLow => '低速';

  @override
  String get pumpHeadSpeedMedium => '中速';

  @override
  String get pumpHeadSpeedHigh => '高速';

  @override
  String get pumpHeadSpeedDefault => '預設轉速';

  @override
  String get calibrationInstructions => '校正說明';

  @override
  String get calibrationSteps =>
      '1.準備好隨附量筒及一些管子\n2.以啟動手動運轉讓管子內充滿液體\n3.選定轉速進行校正';

  @override
  String get calibrationVolumeHint => '1 ~ 15;小數點後一位';

  @override
  String get calibrating => '校正中...';

  @override
  String get calibrationComplete => '完成校正';

  @override
  String get recentCalibrationRecords => '最近校正紀錄';

  @override
  String get todayScheduledVolume => '今日排程即時滴液量';

  @override
  String get maxDosingVolume => '每日最大滴液量';

  @override
  String get maxDosingVolumeHint => '開啟後排程及非排程運行動作將被限制滴液量';

  @override
  String get delayTime1Min => '1 分';

  @override
  String get dosingSettingsTitle => '滴液泵設定';

  @override
  String get pumpHeadRecordTitle => '排程';

  @override
  String get pumpHeadRecordSettingsTitle => '排程設定';

  @override
  String get pumpHeadRecordTimeSettingsTitle => '時段設定';

  @override
  String get pumpHeadAdjustListTitle => '校正紀錄';

  @override
  String get pumpHeadAdjustTitle => '校正';

  @override
  String get dosingTypeTitle => '滴液種類';

  @override
  String get rotatingSpeed => '轉速';

  @override
  String get ledInitialIntensity => '起始強度';

  @override
  String get ledSunrise => '日出';

  @override
  String get ledSunset => '日落';

  @override
  String get ledSlowStart => '緩啟動';

  @override
  String get ledInitDuration => '30 分鐘';

  @override
  String get ledScheduleTimePoint => '排程時間點';

  @override
  String get ledScheduleSettings => '排程設定';

  @override
  String get ledSceneAdd => '新增場景';

  @override
  String get ledSceneEdit => '場景設定';

  @override
  String get ledSceneDelete => '刪除場景';

  @override
  String get ledRecordPause => '排程已暫停';

  @override
  String get ledRecordContinue => '繼續執行';

  @override
  String get actionEdit => '編輯';

  @override
  String get generalNone => '無';

  @override
  String get actionComplete => '完成';

  @override
  String get actionRun => '執行';

  @override
  String get deviceNotConnected => '裝置未連線';

  @override
  String get sinkEmptyMessage => '點擊右下新增按鈕增加水槽';

  @override
  String get bottomSheetAddSinkTitle => 'Add Tank';

  @override
  String get bottomSheetAddSinkFieldTitle => 'Tank Name';

  @override
  String get bottomSheetEditSinkTitle => 'Tank Settings';

  @override
  String get bottomSheetEditSinkFieldTitle => 'Tank Name';

  @override
  String get bottomSheetAddDropTypeTitle => 'Add Custom Dosing';

  @override
  String get bottomSheetAddDropTypeFieldTitle => 'Dosing Name';

  @override
  String get bottomSheetEditDropTypeTitle => 'Edit Custom Dosing';

  @override
  String get bottomSheetEditDropTypeFieldTitle => 'Dosing Name';

  @override
  String get dosingVolumeRangeHint => '1 ~ 500';

  @override
  String get dropRecordTypeNone => 'No Scheduled Tasks';

  @override
  String get dosingAdjustDateTitle => 'Calibration Date';

  @override
  String get dosingAdjustVolumeTitle => 'Measured Volume';

  @override
  String get groupPlaceholder => 'Group A';

  @override
  String get ledChartPlaceholder => 'Chart Placeholder';

  @override
  String get ledSpectrumChartPlaceholder => 'Spectrum Chart Placeholder';

  @override
  String get ledTimePlaceholder => '07:27';

  @override
  String get dosingRecordTimePlaceholder => '08:00';

  @override
  String get dosingRecordEndTimePlaceholder => '10:00';

  @override
  String get dosingRecordDetailPlaceholder => '50 ml / 5 times';

  @override
  String get dosingTypeNamePlaceholder => 'Type A';

  @override
  String get dosingTypeNamePlaceholderB => 'Type B';

  @override
  String get dosingTypeNamePlaceholderC => 'Type C';

  @override
  String get dosingRecordTimeRangePlaceholder => '2022-10-14 ~ 2022-10-31';

  @override
  String get dosingRecordTimePointPlaceholder => '2022-10-14 10:20:13';

  @override
  String get dosingAdjustDatePlaceholder => '2024-01-01 12:00:00';

  @override
  String get dosingAdjustVolumePlaceholder => '10.0 ml';
}
