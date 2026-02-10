// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

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
  String get bleOnboardingPermissionTitle => 'Bật quyền truy cập Bluetooth';

  @override
  String get bleOnboardingPermissionCopy =>
      'Chúng tôi sử dụng Bluetooth để khám phá và kiểm soát phần cứng Koral của bạn ở gần.';

  @override
  String get bleOnboardingPermissionCta => 'Cho phép truy cập';

  @override
  String get bleOnboardingSettingsTitle => 'Cần có quyền trong Cài đặt';

  @override
  String get bleOnboardingSettingsCopy =>
      'Truy cập Bluetooth trước đây đã bị từ chối.Mở cài đặt hệ thống để kích hoạt nó.';

  @override
  String get bleOnboardingSettingsCta => 'Mở cài đặt';

  @override
  String get bleOnboardingLocationTitle => 'Cho phép truy cập vị trí';

  @override
  String get bleOnboardingLocationCopy =>
      'Android yêu cầu quyền truy cập vị trí trên các phiên bản cũ hơn để quét tìm thiết bị Bluetooth.';

  @override
  String get bleOnboardingBluetoothOffTitle => 'Bật Bluetooth';

  @override
  String get bleOnboardingBluetoothOffCopy =>
      'Bluetooth phải luôn bật để tiếp tục quét và điều khiển thiết bị của bạn.';

  @override
  String get bleOnboardingBluetoothCta => 'Mở cài đặt Bluetooth';

  @override
  String get bleOnboardingUnavailableTitle => 'Bluetooth không khả dụng';

  @override
  String get bleOnboardingUnavailableCopy =>
      'Thiết bị này không hiển thị đài Bluetooth mà KoralCore có thể sử dụng.';

  @override
  String get bleOnboardingRetryCta => 'Thử lại';

  @override
  String get bleOnboardingLearnMore => 'Tìm hiểu thêm';

  @override
  String get bleOnboardingSheetTitle => 'Tại sao KoralCore cần Bluetooth';

  @override
  String get bleOnboardingSheetDescription =>
      'Bluetooth hỗ trợ việc phát hiện và kiểm soát phần cứng định lượng và chiếu sáng của bạn.Đây là những gì xảy ra sau khi bạn cấp quyền truy cập.';

  @override
  String get bleOnboardingSheetSearchTitle => 'Tìm thiết bị ở gần';

  @override
  String get bleOnboardingSheetSearchCopy =>
      'Quét Reef Dose, Reef LED và các thiết bị Koral khác xung quanh bể của bạn.';

  @override
  String get bleOnboardingSheetControlTitle =>
      'Kiểm soát liều lượng và ánh sáng';

  @override
  String get bleOnboardingSheetControlCopy =>
      'Đồng bộ hóa lịch trình, gửi lệnh và cập nhật chương trình cơ sở qua liên kết BLE an toàn.';

  @override
  String get bleOnboardingSheetFooter =>
      'Ngay khi Bluetooth sẵn sàng, chúng tôi sẽ tự động tiếp tục quét.';

  @override
  String get bleOnboardingDisabledHint =>
      'Cấp quyền truy cập Bluetooth để bắt đầu quét.';

  @override
  String get bleOnboardingBlockedEmptyTitle => 'Cần thiết lập Bluetooth';

  @override
  String get bleOnboardingBlockedEmptyCopy =>
      'Cho phép truy cập Bluetooth hoặc bật nó để khám phá phần cứng rạn san hô của bạn.';

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
  String get bluetoothRearrangement => 'Rearrangement';

  @override
  String get bluetoothOtherDevice => 'Other Devices';

  @override
  String get bluetoothNoOtherDeviceTitle => 'No devices found.';

  @override
  String get bluetoothNoOtherDeviceContent =>
      'Tap on the top right to rescan nearby devices.';

  @override
  String get bluetoothDisconnectDialogContent =>
      'Do you want to disconnect Bluetooth?';

  @override
  String get bluetoothDisconnectDialogPositive => 'OK';

  @override
  String get bluetoothDisconnectDialogNegative => 'Cancel';

  @override
  String get deviceHeader => 'My devices';

  @override
  String get deviceEmptyTitle => 'No devices yet';

  @override
  String get deviceEmptySubtitle =>
      'Use the Bluetooth tab to discover hardware.';

  @override
  String get deviceInSinkEmptyTitle => 'The tank currently has no devices.';

  @override
  String get deviceInSinkEmptyContent =>
      'Add devices from the Bluetooth list below.';

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
  String get deviceDeleteConfirmTitle => '';

  @override
  String get deviceDeleteConfirmMessage => 'Xóa thiết bị đã chọn?';

  @override
  String get deviceDeleteConfirmPrimary => 'Xóa';

  @override
  String get deviceDeleteConfirmSecondary => 'Hủy';

  @override
  String get deviceDeleteLedMasterTitle => 'Cài đặt Master-Slave';

  @override
  String get deviceDeleteLedMasterContent =>
      'Để xóa đèn chính, vui lòng sửa đổi cài đặt master-slave và đặt các đèn nô lệ khác làm đèn chính.';

  @override
  String get deviceDeleteLedMasterPositive => 'Tôi đã hiểu';

  @override
  String get deviceActionDelete => 'Delete selected';

  @override
  String deviceSelectionCount(int count) {
    return '$count selected';
  }

  @override
  String get toastDeleteDeviceSuccessful => 'Xóa thiết bị thành công.';

  @override
  String get toastDeleteDeviceFailed => 'Không thể xóa thiết bị.';

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
  String get dosingScheduleAddButton => 'Thêm lịch trình';

  @override
  String get dosingScheduleEditTitleNew => 'Lịch trình mới';

  @override
  String get dosingScheduleEditTitleEdit => 'Chỉnh sửa lịch trình';

  @override
  String get dosingScheduleEditDescription =>
      'Cấu hình cửa sổ định lượng cho đầu bơm này.';

  @override
  String get dosingScheduleEditTypeLabel => 'Loại lịch trình';

  @override
  String get dosingScheduleEditDoseLabel => 'Liều mỗi sự kiện';

  @override
  String get dosingScheduleEditDoseHint => 'Nhập số lượng tính bằng mililit.';

  @override
  String get dosingScheduleEditEventsLabel => 'Sự kiện mỗi ngày';

  @override
  String get dosingScheduleEditStartTimeLabel => 'Liều đầu tiên';

  @override
  String get dosingScheduleEditWindowStartLabel => 'Bắt đầu cửa sổ';

  @override
  String get dosingScheduleEditWindowEndLabel => 'Cuối cửa sổ';

  @override
  String get dosingScheduleEditWindowEventsLabel => 'Sự kiện trên mỗi cửa sổ';

  @override
  String get dosingScheduleEditRecurrenceLabel => 'Tái phát';

  @override
  String get dosingScheduleEditEnabledToggle => 'Bật lịch trình';

  @override
  String get dosingScheduleEditSave => 'Lưu lịch trình';

  @override
  String get dosingScheduleEditSuccess => 'Đã lưu lịch trình.';

  @override
  String get dosingScheduleEditInvalidDose => 'Nhập liều lớn hơn 0.';

  @override
  String get dosingScheduleEditInvalidWindow =>
      'Thời gian kết thúc phải sau thời gian bắt đầu.';

  @override
  String get dosingScheduleEditTemplateDaily =>
      'Sử dụng mẫu trung bình hàng ngày';

  @override
  String get dosingScheduleEditTemplateCustom => 'Sử dụng mẫu cửa sổ tùy chỉnh';

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
  String get errorSinkFull => 'Tank is full.';

  @override
  String get errorSinkGroupsFull =>
      'All LED groups in this sink are full. Maximum 4 devices per group.';

  @override
  String get errorConnectLimit =>
      'Maximum 1 device can be connected simultaneously.';

  @override
  String get errorLedMasterCannotDelete =>
      'To delete the master light, please modify the master-slave settings and set other slave lights as the master.';

  @override
  String get errorDeleteFailed => 'Failed to delete device.';

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
      'Do you want to clear the schedule?';

  @override
  String get ledRecordsDeleteConfirmTitle => 'Delete record?';

  @override
  String get ledRecordsDeleteConfirmMessage =>
      'Do you want to delete this time point?';

  @override
  String get ledMoveMasterDialogTitle => 'Master Setting';

  @override
  String get ledMoveMasterDialogContent =>
      'To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light.';

  @override
  String ledSceneDeleteConfirmMessage(String name) {
    return 'Do you want to delete the scene?';
  }

  @override
  String get ledRecordsSnackDeleted => 'Successfully deleted time point.';

  @override
  String get ledRecordsSnackDeleteFailed => 'Failed to delete time point.';

  @override
  String get ledRecordsSnackCleared => 'Records cleared.';

  @override
  String get ledRecordsSnackClearFailed => 'Couldn\'t clear records.';

  @override
  String get ledRecordsSnackMissingSelection => 'Select a record first.';

  @override
  String get ledRecordsSnackPreviewStarted =>
      'One-minute quick preview started.';

  @override
  String get ledRecordsSnackPreviewStopped => 'One-minute quick preview ended.';

  @override
  String get ledRecordsSnackRecordsFull =>
      'Tối đa 24 điểm thời gian có thể thiết lập.';

  @override
  String get ledRecordsSnackTimeExists =>
      'Phạm vi thời gian này đã được thiết lập.';

  @override
  String get ledRecordsSnackTimeError =>
      'Thời điểm phải cách nhau ít nhất 10 phút.';

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
  String get ledSceneNameLabel => 'Scene Name';

  @override
  String get ledSceneNameHint => 'Enter scene name';

  @override
  String get ledSceneIcon => 'Biểu tượng Cảnh';

  @override
  String get lightUv => 'Ánh UV';

  @override
  String get lightPurple => 'Ánh tím';

  @override
  String get lightBlue => 'Ánh xanh';

  @override
  String get lightRoyalBlue => 'Ánh xanh dương hoàng gia';

  @override
  String get lightGreen => 'Ánh xanh lá cây';

  @override
  String get lightRed => 'Ánh đỏ';

  @override
  String get lightColdWhite => 'Ánh trắng lạnh';

  @override
  String get lightWarmWhite => 'Ánh trắng ấm';

  @override
  String get lightMoon => 'Ánh trăng';

  @override
  String get ledSceneAddSuccess => 'Successfully added scene.';

  @override
  String get toastNameIsEmpty => 'Tên không thể để trống.';

  @override
  String get toastSettingSuccessful => 'Cài đặt thành công.';

  @override
  String get toastSceneNameIsExist => 'Tên cảnh đã tồn tại.';

  @override
  String get ledSceneNameIsExist => 'Scene name already exists.';

  @override
  String get ledSceneDeleteDescription => 'Select scenes to delete';

  @override
  String get ledSceneDeleteEmpty => 'No scenes to delete';

  @override
  String get ledSceneDeleteConfirmTitle => 'Delete Scene?';

  @override
  String ledSceneDeleteSuccess(String name) {
    return 'Scene \"$name\" deleted';
  }

  @override
  String get ledSceneDeleteError => 'Failed to delete scene.';

  @override
  String get toastDeleteNowScene => 'Không thể xóa cảnh hiện đang sử dụng.';

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
  String get ledRecordSettingErrorSunTime =>
      'Sunrise and sunset time settings are incorrect.';

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

  @override
  String get group => 'Group';

  @override
  String get led => 'LED';

  @override
  String get masterSlave => 'Master/Slave';

  @override
  String get time => 'Time Point';

  @override
  String get record => 'Schedule';

  @override
  String get ledScene => 'Scene';

  @override
  String get unassignedDevice => 'Unallocated Devices';

  @override
  String get ledSceneNoSetting => 'No Setting';

  @override
  String get dosingAdjustListDate => 'Calibration Date';

  @override
  String get dosingAdjustListVolume => 'Measured Volume';

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
  String get dosingAdjustVolumeHint => 'Enter actual drop volume';

  @override
  String get dosingCompleteAdjust => 'Complete Calibration';

  @override
  String get dosingAdjusting => 'Calibrating';

  @override
  String get dosingAdjustVolumeEmpty => 'Drop volume cannot be empty';

  @override
  String get dosingStartAdjustFailed => 'Failed to start calibration';

  @override
  String get dosingAdjustSuccessful => 'Calibration successful';

  @override
  String get dosingAdjustFailed => 'Calibration failed';

  @override
  String get homeSpinnerAllSink => 'All Tanks';

  @override
  String get homeSpinnerFavorite => 'Favorite Devices';

  @override
  String get homeSpinnerUnassigned => 'Unallocated Devices';

  @override
  String get dosingPumpHeadNoType => 'Không có loại';

  @override
  String get dosingPumpHeadModeScheduled => 'Đã lên lịch';

  @override
  String get dosingPumpHeadModeFree => 'Chế độ tự do';

  @override
  String get dosingVolumeHint => 'Nhập thể tích';

  @override
  String get noRecords => 'Không có nhiệm vụ được lên lịch';

  @override
  String dosingManualStarted(String headId) {
    return 'Bắt đầu định liều cho đầu $headId';
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
  String get pumpHeadRecordTimeSettingsTitle => 'Time Setting';

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
}
