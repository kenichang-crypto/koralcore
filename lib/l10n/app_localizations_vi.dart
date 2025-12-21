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
