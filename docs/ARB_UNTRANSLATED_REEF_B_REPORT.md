# ARB Untranslated Keys - reef-b-app Reference Report

**Generated:** 2025-02-11  
**Scope:** Keys in koralcore ARB files where value matched English (untranslated)  
**Method:** Exact string match in reef-b-app `android/.../res/values/strings.xml`

---

## Keys Updated (from reef-b-app)

| koralcore Key | English Value | reef-b Source | reef-b Key | Translation Applied |
|---------------|---------------|---------------|------------|---------------------|
| `dosingEntryCalibration` | Calibration | values/strings.xml L143 | `adjust` | 校正 (zh), 校正 (zh_Hant), キャリブレーション (ja), 보정 (ko), Kalibrierung (de), Calibración (es), Calibration (fr), Calibração (pt), Калибровка (ru), การสอดสอย (th), Hiệu chuẩn (vi), معايرة (ar), Kalibrasi (id) |
| `dosingPumpHeadSettingsSave` | Save | values/strings.xml L22 | `save` | 儲存 (zh), 儲存 (zh_Hant), 保存 (ja), 저장 (ko), Speichern (de), Guardar (es), Sauvegarder (fr), Salvar (pt), Сохранить (ru), บันทึก (th), Lưu (vi), حفظ (ar), Simpan (id) |
| `dosingPumpHeadSettingsCancel` | Cancel | values/strings.xml L18 | `cancel` | 取消 (zh), 取消 (zh_Hant), キャンセル (ja), 취소 (ko), Abbrechen (de), Cancelar (es), Annuler (fr), Cancelar (pt), Отмена (ru), ยกเลิก (th), Hủy (vi), إلغاء (ar), Batal (id) |

### Source File References (reef-b-app, read-only)

- **adjust** (Calibration): `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml` line 143  
  - zh-rTW L165: 校正  
  - ja L144: キャリブレーション  
  - ko L144: 보정  
  - de L144: Kalibrierung  
  - es L144: Calibración  
  - fr L144: Calibration  
  - pt L144: Calibração  
  - ru L144: Калибровка  
  - th L144: การสอดสอย  
  - vi L144: Hiệu chuẩn  
  - ar L144: معايرة  
  - in L144: Kalibrasi  

- **save**: `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml` line 22  
  - Each locale: `values-{locale}/strings.xml` (save, cancel)

- **cancel**: `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml` line 18  

### Target ARB Files Updated

- `lib/l10n/intl_zh.arb`
- `lib/l10n/intl_zh_Hant.arb`
- `lib/l10n/intl_ja.arb`
- `lib/l10n/intl_ko.arb`
- `lib/l10n/intl_de.arb`
- `lib/l10n/intl_es.arb`
- `lib/l10n/intl_fr.arb`
- `lib/l10n/intl_pt.arb`
- `lib/l10n/intl_ru.arb`
- `lib/l10n/intl_th.arb`
- `lib/l10n/intl_vi.arb`
- `lib/l10n/intl_ar.arb`
- `lib/l10n/intl_id.arb`

---

## Keys NOT Found in reef-b-app

The following **164 keys** have no exact matching English string in reef-b-app `strings.xml`.  
(Exact match required per instruction; no paraphrasing.)

| Key | English Value (untranslated) |
|-----|------------------------------|
| appTitle | KoralCore |
| homeConnectedCopy | Manage dosing and lighting right from your phone. |
| homeConnectCta | Connect a device |
| homeNoDeviceCopy | Pair your Koral doser or LED controller to manage schedules and lighting. |
| sectionDosingTitle | Dosing |
| sectionLedTitle | Lighting |
| bleDisconnectedWarning | Connect via Bluetooth to continue. |
| bleGuardDialogTitle | Bluetooth required |
| bleGuardDialogMessage | Connect to a device to access this feature. |
| bleGuardDialogButton | Got it |
| deviceDeleteConfirmTitle | (empty) |
| dosingHeader | Dosing |
| dosingSubHeader | Control daily dosing routines. |
| dosingEntrySchedule | Edit schedule |
| dosingEntryManual | Manual dose |
| dosingEntryHistory | Dose history |
| dosingManualPageSubtitle | Run an on-demand dose from this pump head. |
| dosingManualDoseInputLabel | Dose amount |
| dosingManualDoseInputHint | Enter the amount in milliliters. |
| dosingManualConfirmTitle | Send manual dose? |
| dosingManualConfirmMessage | This dose will start immediately. Make sure your dosing line is ready. |
| dosingManualInvalidDose | Enter a dose greater than zero. |
| ledHeader | Lighting |
| ledSubHeader | Tune spectrums and schedules. |
| ledEntryIntensity | Adjust intensity |
| ledIntensityEntrySubtitle | Tune output for each lighting channel. |
| ledEntryPrograms | Scenes & programs |
| ledEntryManual | Manual control |
| ledScheduleAddButton | Add schedule |
| ledScheduleEditTitleNew | New lighting schedule |
| ledScheduleEditTitleEdit | Edit lighting schedule |
| ledScheduleEditDescription | Configure time windows and intensity levels. |
| ledScheduleEditNameLabel | Schedule name |
| ledScheduleEditNameHint | Enter a label |
| ledScheduleEditInvalidName | Enter a schedule name. |
| ledScheduleEditTypeLabel | Schedule type |
| ledScheduleEditStartLabel | Start time |
| ledScheduleEditEndLabel | End time |
| ledScheduleEditRecurrenceLabel | Recurrence |
| ledScheduleEditEnabledToggle | Enable schedule |
| ledScheduleEditChannelsHeader | Channels |
| ledScheduleEditChannelWhite | Cool white |
| ledScheduleEditChannelBlue | Royal blue |
| ledScheduleEditSave | Save schedule |
| ledScheduleEditSuccess | Lighting schedule saved. |
| ledScheduleEditInvalidWindow | End time must be after start time. |
| ledControlTitle | Intensity & spectrum |
| ledControlSubtitle | Adjust each lighting channel, then apply when ready. |
| ledControlChannelsSection | Channels |
| ledControlValueLabel | {percent}% output |
| ledControlApplySuccess | LED settings updated. |
| ledControlEmptyState | No adjustable LED channels yet. |
| comingSoon | Coming soon |
| actionApply | Apply |
| actionRetry | Retry |
| errorDeviceBusy | Device is busy. Try again shortly. |
| errorNoDevice | No active device. |
| errorNotSupported | This action is not supported on the connected device. |
| errorInvalidParam | Invalid parameters for this use case. |
| errorTransport | Bluetooth transport error. Check the signal and retry. |
| errorGeneric | Something went wrong. Please retry. |
| snackbarDeviceRemoved | Devices removed. |
| snackbarDeviceConnected | Device connected. |
| snackbarDeviceDisconnected | Device disconnected. |
| dosingPumpHeadsHeader | Pump heads |
| dosingPumpHeadsSubheader | Tap a head to review flow and totals. |
| dosingPumpHeadSummaryTitle | Head {head} |
| dosingPumpHeadStatus | Status |
| dosingPumpHeadStatusReady | Ready |
| dosingPumpHeadDailyTarget | Daily target |
| dosingPumpHeadTodayDispensed | Today dispensed |
| dosingPumpHeadLastDose | Last dose |
| dosingPumpHeadFlowRate | Calibrated flow |
| dosingPumpHeadManualDose | Manual dose |
| dosingPumpHeadManualDoseSuccess | Manual dose sent. |
| dosingPumpHeadTimedDose | Schedule timed dose |
| dosingPumpHeadTimedDoseSuccess | Timed dose scheduled. |
| dosingPumpHeadCalibrate | Calibrate head |
| dosingPumpHeadPlaceholder | No dosing data yet. |
| dosingScheduleOverviewTitle | Schedules |
| dosingScheduleOverviewSubtitle | Review configured dosing windows. |
| dosingTodayTotalTitle | Today's dosing |
| dosingTodayTotalTotal | Total |
| dosingTodayTotalScheduled | Scheduled |
| dosingTodayTotalManual | Manual |
| dosingTodayTotalEmpty | No dosing data yet. |
| dosingScheduleSummaryTitle | Schedule summary |
| dosingScheduleSummaryEmpty | No schedule |
| dosingScheduleSummaryTotalLabel | Total / day |
| dosingScheduleSummaryWindowCount | {count} windows |
| dosingScheduleSummarySlotCount | {count} slots |
| dosingScheduleApplyDailyAverage | Apply 24h average schedule |
| dosingScheduleApplyDailyAverageSuccess | 24h average schedule sent. |
| dosingScheduleApplyCustomWindow | Apply custom window schedule |
| dosingScheduleApplyCustomWindowSuccess | Custom window schedule sent. |
| dosingScheduleViewButton | View schedules |
| dosingScheduleEmptyTitle | No schedule configured |
| dosingScheduleEmptySubtitle | Add a schedule with the Reef B app to see it here. |
| dosingScheduleTypeDaily | 24-hour program |
| dosingScheduleTypeSingle | Single dose |
| dosingScheduleTypeCustom | Custom window |
| dosingScheduleRecurrenceDaily | Every day |
| dosingScheduleRecurrenceWeekdays | Weekdays |
| dosingScheduleRecurrenceWeekends | Weekends |
| ledDetailUnknownDevice | Unnamed device |
| ledDetailFavoriteTooltip | Mark as favorite (coming soon) |
| ledDetailHeaderHint | Control spectrum profiles and schedules from your phone. |
| ledScenesPlaceholderTitle | Scenes |
| ledScenesPlaceholderSubtitle | Swipe through presets from Reef B. |
| ledScheduleSummaryTitle | Lighting schedule |
| ledScheduleSummaryEmpty | No schedule configured |
| ledScheduleSummaryWindowLabel | Window |
| ledScheduleSummaryLabel | Label |
| ledSchedulePlaceholderTitle | Schedule preview |
| ledSchedulePlaceholderSubtitle | Planned spectrum envelope for the next 24h. |
| ledEntryScenes | Open Scenes |
| ledEntrySchedule | Open Schedule |
| ledScenesListTitle | Scenes |
| ledScenesListSubtitle | Review presets imported from Reef B. |
| ledScenesEmptyTitle | No scenes available |
| ledScenesEmptySubtitle | Sync scenes from the Reef B app to see them here. |
| ledScheduleListTitle | Schedules |
| ledScheduleListSubtitle | Review lighting timelines synced from Reef B. |
| ledScheduleEmptyTitle | No schedules available |
| ledScheduleEmptySubtitle | Create schedules in the Reef B app to view them here. |
| ledScheduleTypeDaily | Daily program |
| ledScheduleTypeCustom | Custom window |
| ledScheduleTypeScene | Scene-based |
| ledScheduleRecurrenceDaily | Every day |
| ledScheduleRecurrenceWeekdays | Weekdays |
| ledScheduleRecurrenceWeekends | Weekends |
| ledScheduleSceneSummary | Scene: {scene} |
| dosingCalibrationHistoryTitle | Calibration history |
| dosingCalibrationHistorySubtitle | Latest calibrations captured per speed. |
| dosingCalibrationHistoryViewButton | View calibration history |
| dosingCalibrationHistoryEmptyTitle | No calibrations yet |
| dosingCalibrationHistoryEmptySubtitle | Run a calibration from the Reef B app to see it here. |
| dosingCalibrationRecordNoteLabel | Note |
| dosingCalibrationRecordSpeed | Speed: {speed} |
| dosingCalibrationRecordFlow | {flow} ml/min |
| dosingPumpHeadSettingsTitle | Pump head settings |
| dosingPumpHeadSettingsSubtitle | Rename the head or adjust execution delay. |
| dosingPumpHeadSettingsNameLabel | Pump head name |
| dosingPumpHeadSettingsNameHint | Enter a custom label |
| dosingPumpHeadSettingsNameEmpty | Name can't be empty. |
| dosingPumpHeadSettingsTankLabel | Tank / additive |
| dosingPumpHeadSettingsTankPlaceholder | Link additives from the Reef B app. |
| dosingPumpHeadSettingsDelayLabel | Dose delay |
| dosingPumpHeadSettingsDelaySubtitle | Applies a delay before the head runs. |
| dosingPumpHeadSettingsUnsavedTitle | Discard changes? |
| dosingPumpHeadSettingsUnsavedMessage | You have unsaved changes. |
| dosingPumpHeadSettingsUnsavedDiscard | Discard |
| dosingPumpHeadSettingsUnsavedStay | Keep editing |
| dosingPumpHeadSettingsDelayOption | {seconds} seconds |
| dosingScheduleStatusEnabled | Enabled |
| dosingScheduleStatusDisabled | Paused |
| ledSceneStatusEnabled | Enabled |
| ledSceneStatusDisabled | Disabled |
| ledScheduleStatusEnabled | Enabled |
| ledScheduleStatusDisabled | Disabled |
| led | LED |
| dosingVolumeFormat | {dispensed} / {target} ml |
| channelPercentageFormat | {label} {percentage}% |
| timeRangeSeparator | ~ |

**Note:** `led` has an exact match in reef-b (`@string/led` = "LED"), but reef-b values-zh-rTW also uses "LED" (same), so no translation change.

---

## Summary

- **Keys updated:** 3  
- **Target ARB files:** 13 (zh, zh_Hant, ja, ko, de, es, fr, pt, ru, th, vi, ar, id)  
- **Keys not found in reef-b-app:** 164  
- **reef-b-app:** Read-only, no modifications made

**Next steps:** Run `flutter gen-l10n` to regenerate `app_localizations_*.dart` from the updated ARB files.
