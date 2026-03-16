# REPHRASED_COPY – Applied reef-b Wording

**Generated:** 2025-02-11  
**Action:** Replaced koralcore wording with exact reef-b wording  
**reef-b-app:** Read-only reference (no modifications)

---

## Keys Updated

| koralcore Key | Previous (koralcore) | Applied (reef-b) | reef-b Source |
|---------------|---------------------|------------------|---------------|
| bleDisconnectedWarning | Connect via Bluetooth to continue. | Please enable Bluetooth. | please_open_ble L10 |
| bleGuardDialogMessage | Connect to a device to access this feature. | Please enable Bluetooth. | please_open_ble L10 |
| bleGuardDialogButton | Got it | I understood | i_konw L24 |
| errorNoDevice | No active device. | Device not connected | device_is_not_connect L43 |
| errorDeviceBusy | Device is busy. Try again shortly. | This pump head is currently dosing, please try again later. | toast_drophead_is_droping L223 |
| snackbarDeviceRemoved | Devices removed. | Successfully deleted device. | toast_delete_device_successful L201 |
| snackbarDeviceConnected | Device connected. | Connection successful. | toast_connect_successful L13 |
| dosingManualInvalidDose | Enter a dose greater than zero. | Each dosing volume cannot be less than 1ml. | toast_drop_volume_is_too_little L233 |
| dosingManualDoseInputHint | Enter the amount in milliliters. | Please enter the dosing volume. | toast_drop_volume_is_empty L230 |
| dosingPumpHeadSettingsNameEmpty | Name can't be empty. | Name cannot be empty. | toast_name_is_empty L192 |
| dosingPumpHeadSettingsUnsavedStay | Keep editing | Cancel | cancel L18 |
| dosingPumpHeadPlaceholder | No dosing data yet. | No scheduled tasks | no_records L44 |
| dosingTodayTotalEmpty | No dosing data yet. | No scheduled tasks | no_records L44 |
| dosingScheduleEmptyTitle | No schedule configured | No scheduled tasks | no_records L44 |
| dosingScheduleStatusDisabled | Paused | The schedule is paused. | record_pause L248 |
| dosingPumpHeadManualDoseSuccess | Manual dose sent. | Settings successful. | toast_setting_successful L207 |
| dosingPumpHeadTimedDoseSuccess | Timed dose scheduled. | Settings successful. | toast_setting_successful L207 |
| dosingScheduleApplyDailyAverageSuccess | 24h average schedule sent. | Settings successful. | toast_setting_successful L207 |
| dosingScheduleApplyCustomWindowSuccess | Custom window schedule sent. | Settings successful. | toast_setting_successful L207 |
| ledScheduleEditInvalidName | Enter a schedule name. | Name cannot be empty. | toast_name_is_empty L192 |
| ledScheduleEditSuccess | Lighting schedule saved. | Settings successful. | toast_setting_successful L207 |

---

## ARB Files Updated

- **intl_en.arb** – English baseline
- **intl_zh.arb**, **intl_zh_Hant.arb** – zh-rTW
- **intl_ja.arb** – ja
- **intl_ko.arb** – ko
- **intl_de.arb** – de
- **intl_es.arb** – es
- **intl_fr.arb** – fr
- **intl_pt.arb** – pt
- **intl_ru.arb** – ru
- **intl_th.arb** – th
- **intl_vi.arb** – vi
- **intl_ar.arb** – ar
- **intl_id.arb** – id (values-in)

Translations were copied from reef-b `values-{locale}/strings.xml` for each mapped key.

---

## Keys Not Replaced (no exact reef-b equivalent)

| Key | koralcore Value | Reason |
|-----|-----------------|--------|
| actionApply | Apply | No reef "Apply" |
| actionRetry | Retry | No reef standalone "Retry" |
| dosingPumpHeadSettingsUnsavedDiscard | Discard | reef delete ≠ Discard |
| dosingScheduleEmptySubtitle | Add a schedule with the Reef B app... | No equivalent |
| dosingScheduleViewButton | View schedules | No equivalent |
| dosingCalibrationHistoryEmptyTitle | No calibrations yet | No equivalent |
| dosingCalibrationHistoryEmptySubtitle | Run a calibration from the Reef B app... | No equivalent |
| dosingCalibrationHistoryViewButton | View calibration history | No equivalent |
| ledEntryScenes | Open Scenes | reef led_scene_add = "Add Scene" (different) |
| ledEntrySchedule | Open Schedule | No equivalent |
| ledScenesEmptyTitle | No scenes available | No equivalent |
| ledScenesEmptySubtitle | Sync scenes from the Reef B app... | No equivalent |
| ledScheduleEmptyTitle | No schedules available | No equivalent |
| ledScheduleEmptySubtitle | Create schedules in the Reef B app... | No equivalent |
| ledScheduleEditInvalidWindow | End time must be after start time. | reef toast_sun_time_error = sunrise/sunset (different) |

---

## Notes

- Placeholders preserved (none of the updated keys had placeholders).
- Meaning preserved; only wording changed to match reef-b.
- **reef-b-app:** No modifications made.
