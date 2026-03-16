# TRUE_NEW Keys – Classification Report

**Generated:** 2025-02-11  
**Scope:** 157 TRUE_NEW keys (no normalized match in reef-b-app)  
**Method:** Semantic analysis vs reef-b-app `values/strings.xml`

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| **NEW_FEATURE** | 71 | No equivalent in reef-b; KoralCore-specific functionality |
| **REPHRASED_COPY** | 36 | Similar meaning, different wording; reef-b has analogous strings |
| **DUPLICATE_SEMANTICS** | 38 | Same concept as reef-b but renamed or shortened |
| **INTERNAL_ONLY** | 12 | Format templates / placeholders; not standalone user-facing copy |
| **Total** | 157 | |

---

## 1. NEW_FEATURE (71 keys)

No equivalent in reef-b. KoralCore-specific UX, flows, or messaging.

| Key | English Value |
|-----|---------------|
| appTitle | KoralCore |
| homeConnectedCopy | Manage dosing and lighting right from your phone. |
| homeConnectCta | Connect a device |
| homeNoDeviceCopy | Pair your Koral doser or LED controller to manage schedules and lighting. |
| bleGuardDialogTitle | Bluetooth required |
| comingSoon | Coming soon |
| dosingSubHeader | Control daily dosing routines. |
| dosingEntrySchedule | Edit schedule |
| dosingEntryManual | Manual dose |
| dosingEntryHistory | Dose history |
| dosingManualPageSubtitle | Run an on-demand dose from this pump head. |
| dosingManualDoseInputLabel | Dose amount |
| dosingManualConfirmTitle | Send manual dose? |
| dosingManualConfirmMessage | This dose will start immediately. Make sure your dosing line is ready. |
| dosingPumpHeadsHeader | Pump heads |
| dosingPumpHeadsSubheader | Tap a head to review flow and totals. |
| dosingPumpHeadStatus | Status |
| dosingPumpHeadStatusReady | Ready |
| dosingPumpHeadDailyTarget | Daily target |
| dosingPumpHeadTodayDispensed | Today dispensed |
| dosingPumpHeadLastDose | Last dose |
| dosingPumpHeadFlowRate | Calibrated flow |
| dosingPumpHeadManualDose | Manual dose |
| dosingPumpHeadTimedDose | Schedule timed dose |
| dosingPumpHeadCalibrate | Calibrate head |
| dosingScheduleOverviewSubtitle | Review configured dosing windows. |
| dosingScheduleSummaryTitle | Schedule summary |
| dosingScheduleTypeDaily | 24-hour program |
| dosingScheduleTypeCustom | Custom window |
| dosingScheduleApplyDailyAverage | Apply 24h average schedule |
| dosingScheduleApplyCustomWindow | Apply custom window schedule |
| dosingTodayTotalTitle | Today's dosing |
| dosingCalibrationHistorySubtitle | Latest calibrations captured per speed. |
| dosingPumpHeadSettingsSubtitle | Rename the head or adjust execution delay. |
| dosingPumpHeadSettingsNameHint | Enter a custom label |
| dosingPumpHeadSettingsTankLabel | Tank / additive |
| dosingPumpHeadSettingsTankPlaceholder | Link additives from the Reef B app. |
| dosingPumpHeadSettingsDelaySubtitle | Applies a delay before the head runs. |
| dosingPumpHeadSettingsUnsavedTitle | Discard changes? |
| dosingPumpHeadSettingsUnsavedMessage | You have unsaved changes. |
| errorGeneric | Something went wrong. Please retry. |
| errorInvalidParam | Invalid parameters for this use case. |
| errorNotSupported | This action is not supported on the connected device. |
| errorTransport | Bluetooth transport error. Check the signal and retry. |
| ledSubHeader | Tune spectrums and schedules. |
| ledEntryIntensity | Adjust intensity |
| ledIntensityEntrySubtitle | Tune output for each lighting channel. |
| ledEntryPrograms | Scenes & programs |
| ledEntryManual | Manual control |
| ledScheduleAddButton | Add schedule |
| ledScheduleEditTitleNew | New lighting schedule |
| ledScheduleEditTitleEdit | Edit lighting schedule |
| ledScheduleEditDescription | Configure time windows and intensity levels. |
| ledScheduleEditNameHint | Enter a label |
| ledScheduleEditSave | Save schedule |
| ledScheduleEditSuccess | Lighting schedule saved. |
| ledControlTitle | Intensity & spectrum |
| ledControlSubtitle | Adjust each lighting channel, then apply when ready. |
| ledControlChannelsSection | Channels |
| ledControlApplySuccess | LED settings updated. |
| ledControlEmptyState | No adjustable LED channels yet. |
| ledDetailUnknownDevice | Unnamed device |
| ledDetailFavoriteTooltip | Mark as favorite (coming soon) |
| ledDetailHeaderHint | Control spectrum profiles and schedules from your phone. |
| ledScenesPlaceholderSubtitle | Swipe through presets from Reef B. |
| ledScenesListSubtitle | Review presets imported from Reef B. |
| ledSchedulePlaceholderTitle | Schedule preview |
| ledSchedulePlaceholderSubtitle | Planned spectrum envelope for the next 24h. |
| ledScheduleListSubtitle | Review lighting timelines synced from Reef B. |
| ledScheduleTypeDaily | Daily program |
| ledScheduleTypeCustom | Custom window |
| ledScheduleTypeScene | Scene-based |

---

## 2. REPHRASED_COPY (36 keys)

Similar meaning but different wording. reef-b has analogous strings.

| Key | koralcore Value | reef-b Reference |
|-----|-----------------|------------------|
| bleDisconnectedWarning | Connect via Bluetooth to continue. | please_open_ble = "Please enable Bluetooth" |
| bleGuardDialogMessage | Connect to a device to access this feature. | please_open_ble |
| bleGuardDialogButton | Got it | i_konw = "I understood" |
| errorNoDevice | No active device. | device_is_not_connect = "Device not connected" |
| errorDeviceBusy | Device is busy. Try again shortly. | toast_drophead_is_droping |
| actionApply | Apply | confirm, save |
| actionRetry | Retry | toast_connect_failed ("try again") |
| snackbarDeviceRemoved | Devices removed. | toast_delete_device_successful |
| snackbarDeviceConnected | Device connected. | toast_connect_successful |
| dosingManualInvalidDose | Enter a dose greater than zero. | toast_drop_volume_is_too_little |
| dosingManualDoseInputHint | Enter the amount in milliliters. | drop_volume, adjust_volume_hint |
| dosingPumpHeadSettingsNameEmpty | Name can't be empty. | toast_name_is_empty = "Name cannot be empty." |
| dosingPumpHeadSettingsUnsavedDiscard | Discard | delete |
| dosingPumpHeadSettingsUnsavedStay | Keep editing | cancel, back |
| dosingPumpHeadPlaceholder | No dosing data yet. | no_records |
| dosingTodayTotalEmpty | No dosing data yet. | no_records |
| dosingScheduleEmptyTitle | No schedule configured | no_records = "No scheduled tasks" |
| dosingScheduleEmptySubtitle | Add a schedule with the Reef B app to see it here. | text_no_sink_content |
| dosingScheduleStatusDisabled | Paused | record_pause = "The schedule is paused" |
| dosingScheduleViewButton | View schedules | record, activity titles |
| dosingPumpHeadManualDoseSuccess | Manual dose sent. | toast_*_successful |
| dosingPumpHeadTimedDoseSuccess | Timed dose scheduled. | toast_*_successful |
| dosingScheduleApplyDailyAverageSuccess | 24h average schedule sent. | toast_*_successful |
| dosingScheduleApplyCustomWindowSuccess | Custom window schedule sent. | toast_*_successful |
| dosingCalibrationHistoryEmptyTitle | No calibrations yet | adjust_list empty |
| dosingCalibrationHistoryEmptySubtitle | Run a calibration from the Reef B app to see it here. | text_no_*_content |
| dosingCalibrationHistoryViewButton | View calibration history | adjust_list |
| ledEntryScenes | Open Scenes | led_scene_add |
| ledEntrySchedule | Open Schedule | activity_led_record_title |
| ledScheduleEditInvalidName | Enter a schedule name. | toast_name_is_empty |
| ledScheduleEditInvalidWindow | End time must be after start time. | toast_sun_time_error |
| ledScheduleEditSuccess | Lighting schedule saved. | toast_setting_successful |
| ledScenesEmptyTitle | No scenes available | text_no_* empty states |
| ledScenesEmptySubtitle | Sync scenes from the Reef B app to see them here. | text_no_*_content |
| ledScheduleEmptyTitle | No schedules available | text_no_* empty states |
| ledScheduleEmptySubtitle | Create schedules in the Reef B app to view them here. | text_no_*_content |

---

## 3. DUPLICATE_SEMANTICS (38 keys)

Same concept as reef-b but renamed or shortened.

| Key | koralcore Value | reef-b Reference |
|-----|-----------------|------------------|
| sectionDosingTitle | Dosing | drop = "Dosing Pump" |
| sectionLedTitle | Lighting | led = "LED", led_setting |
| dosingHeader | Dosing | drop |
| ledHeader | Lighting | led, led_setting |
| dosingScheduleOverviewTitle | Schedules | record = "Schedule" |
| dosingScheduleSummaryEmpty | No schedule | no_records, drop_record_type_none |
| dosingScheduleSummaryTotalLabel | Total / day | drop_volume_per_day |
| dosingTodayTotalTotal | Total | drop_volume_per_day |
| dosingTodayTotalScheduled | Scheduled | today_record_drop_volume |
| dosingTodayTotalManual | Manual | manual / Free Mode |
| dosingScheduleRecurrenceDaily | Every day | drop_days_a_week |
| dosingScheduleRecurrenceWeekdays | Weekdays | days |
| dosingScheduleRecurrenceWeekends | Weekends | days |
| dosingScheduleStatusEnabled | Enabled | record state |
| dosingPumpHeadSettingsNameLabel | Pump head name | device_name, drop_type_name |
| dosingPumpHeadSettingsDelayLabel | Dose delay | delay_time |
| dosingCalibrationHistoryTitle | Calibration history | adjust_list = "Calibration Log" |
| dosingCalibrationRecordNoteLabel | Note | hint/note patterns |
| ledScenesPlaceholderTitle | Scenes | led_scene = "Scene" |
| ledScenesListTitle | Scenes | led_scene |
| ledScheduleSummaryTitle | Lighting schedule | record = "Schedule" |
| ledScheduleSummaryEmpty | No schedule configured | no_records |
| ledScheduleSummaryWindowLabel | Window | time_setting = "Period Settings" |
| ledScheduleSummaryLabel | Label | led_scene_name |
| ledScheduleListTitle | Schedules | record |
| ledScheduleEditStartLabel | Start time | drop_start_time, record_time |
| ledScheduleEditEndLabel | End time | drop_end_time |
| ledScheduleEditNameLabel | Schedule name | led_scene_name, device_name |
| ledScheduleEditRecurrenceLabel | Recurrence | drop_days_a_week |
| ledScheduleEditChannelsHeader | Channels | channel spectrum names |
| ledScheduleEditEnabledToggle | Enable schedule | record_pause |
| ledScheduleRecurrenceDaily | Every day | drop_days_a_week |
| ledScheduleRecurrenceWeekdays | Weekdays | days |
| ledScheduleRecurrenceWeekends | Weekends | days |
| ledSceneStatusEnabled | Enabled | scene state |
| ledSceneStatusDisabled | Disabled | scene state |
| ledScheduleStatusEnabled | Enabled | record state |
| ledScheduleStatusDisabled | Disabled | record state |

---

## 4. INTERNAL_ONLY (12 keys)

Format templates and placeholders; not standalone user-facing copy. Output is built from these at runtime.

| Key | Value |
|-----|-------|
| deviceDeleteConfirmTitle | (empty) |
| dosingPumpHeadSummaryTitle | Head {head} |
| ledControlValueLabel | {percent}% output |
| dosingScheduleSummaryWindowCount | {count} windows |
| dosingScheduleSummarySlotCount | {count} slots |
| dosingCalibrationRecordSpeed | Speed: {speed} |
| dosingCalibrationRecordFlow | {flow} ml/min |
| dosingPumpHeadSettingsDelayOption | {seconds} seconds |
| ledScheduleSceneSummary | Scene: {scene} |
| dosingVolumeFormat | {dispensed} / {target} ml |
| channelPercentageFormat | {label} {percentage}% |
| timeRangeSeparator | ~ |

---

## Notes

- **reef-b-app read-only:** No changes were made to reef-b-app.
- **Source:** `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml`
- **DUPLICATE_SEMANTICS:** Use reef-b translation for the referenced key where applicable.
- **REPHRASED_COPY:** Use reef-b as reference; adapt wording to fit koralcore context.
