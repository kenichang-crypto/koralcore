# ARB Missing Keys – reef-b-app Text Match Report

**Generated:** 2025-02-11  
**Scope:** 164 koralcore keys with untranslated values (value matches English)  
**Method:** Search reef-b-app `values/strings.xml` by text value (normalized: case-insensitive, whitespace-collapsed, trailing punctuation ignored)

---

## 1. MAPPING_SUGGESTION (1 key)

Exact text value matches reef-b-app. Translation can be copied from the listed reef-b key.

| koralcore Key | Text Value | reef-b Key | reef-b Path & Line |
|---------------|------------|------------|--------------------|
| `led` | LED | `led` (same key) | `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml` L33 |

**Note:** For `led`, koralcore and reef-b use the same key name. In reef-b `values-zh-rTW` the value is also "LED", so no translation change is needed for that locale.

---

## 2. COPY_MISMATCH (6 keys)

Normalized text matches reef-b-app, but koralcore wording differs from reef-b. Use exact reef wording for translations.

| koralcore Key | koralcore Value | reef-b Exact Wording | reef-b Key | reef-b Path & Line |
|---------------|-----------------|---------------------|------------|--------------------|
| `ledScheduleEditTypeLabel` | Schedule type | **Schedule Type** | `drop_record_type` | `values/strings.xml` L76 |
| `ledScheduleEditChannelWhite` | Cool white | **Cool White** | `cold_white` | `values/strings.xml` L59 |
| `ledScheduleEditChannelBlue` | Royal blue | **Royal Blue** | `royal_blue` | `values/strings.xml` L56 |
| `snackbarDeviceDisconnected` | Device disconnected. | **Device disconnected** | `toast_disconnect` | `values/strings.xml` L14 |
| `dosingScheduleTypeSingle` | Single dose | **Single Dose** | `drop_record_type_single` | `values/strings.xml` L73 |
| `dosingPumpHeadSettingsTitle` | Pump head settings | **Pump Head Settings** | `drop_head_setting` | `values/strings.xml` L89 |

**reef-b base path:** `reef-b-app/android/ReefB_Android/app/src/main/res/`

---

## 3. TRUE_NEW (157 keys)

No normalized match in reef-b-app. New Flutter-only strings; no reef-b translation source.

### App & Home
| Key | English Value |
|-----|---------------|
| appTitle | KoralCore |
| homeConnectedCopy | Manage dosing and lighting right from your phone. |
| homeConnectCta | Connect a device |
| homeNoDeviceCopy | Pair your Koral doser or LED controller to manage schedules and lighting. |
| sectionDosingTitle | Dosing |
| sectionLedTitle | Lighting |

### BLE / Bluetooth
| Key | English Value |
|-----|---------------|
| bleDisconnectedWarning | Connect via Bluetooth to continue. |
| bleGuardDialogTitle | Bluetooth required |
| bleGuardDialogMessage | Connect to a device to access this feature. |
| bleGuardDialogButton | Got it |

### Device
| Key | English Value |
|-----|---------------|
| deviceDeleteConfirmTitle | (empty) |

### Dosing – General
| Key | English Value |
|-----|---------------|
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

### LED – General
| Key | English Value |
|-----|---------------|
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
| ledScheduleEditStartLabel | Start time |
| ledScheduleEditEndLabel | End time |
| ledScheduleEditRecurrenceLabel | Recurrence |
| ledScheduleEditEnabledToggle | Enable schedule |
| ledScheduleEditChannelsHeader | Channels |
| ledScheduleEditSave | Save schedule |
| ledScheduleEditSuccess | Lighting schedule saved. |
| ledScheduleEditInvalidWindow | End time must be after start time. |
| ledControlTitle | Intensity & spectrum |
| ledControlSubtitle | Adjust each lighting channel, then apply when ready. |
| ledControlChannelsSection | Channels |
| ledControlValueLabel | {percent}% output |
| ledControlApplySuccess | LED settings updated. |
| ledControlEmptyState | No adjustable LED channels yet. |

### Actions & Common
| Key | English Value |
|-----|---------------|
| comingSoon | Coming soon |
| actionApply | Apply |
| actionRetry | Retry |

### Errors
| Key | English Value |
|-----|---------------|
| errorDeviceBusy | Device is busy. Try again shortly. |
| errorNoDevice | No active device. |
| errorNotSupported | This action is not supported on the connected device. |
| errorInvalidParam | Invalid parameters for this use case. |
| errorTransport | Bluetooth transport error. Check the signal and retry. |
| errorGeneric | Something went wrong. Please retry. |

### Snackbars
| Key | English Value |
|-----|---------------|
| snackbarDeviceRemoved | Devices removed. |
| snackbarDeviceConnected | Device connected. |

### Dosing – Pump heads
| Key | English Value |
|-----|---------------|
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

### Dosing – Schedule
| Key | English Value |
|-----|---------------|
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
| dosingScheduleTypeCustom | Custom window |
| dosingScheduleRecurrenceDaily | Every day |
| dosingScheduleRecurrenceWeekdays | Weekdays |
| dosingScheduleRecurrenceWeekends | Weekends |

### LED – Detail & Scenes
| Key | English Value |
|-----|---------------|
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

### Dosing – Calibration
| Key | English Value |
|-----|---------------|
| dosingCalibrationHistoryTitle | Calibration history |
| dosingCalibrationHistorySubtitle | Latest calibrations captured per speed. |
| dosingCalibrationHistoryViewButton | View calibration history |
| dosingCalibrationHistoryEmptyTitle | No calibrations yet |
| dosingCalibrationHistoryEmptySubtitle | Run a calibration from the Reef B app to see it here. |
| dosingCalibrationRecordNoteLabel | Note |
| dosingCalibrationRecordSpeed | Speed: {speed} |
| dosingCalibrationRecordFlow | {flow} ml/min |

### Dosing – Pump head settings
| Key | English Value |
|-----|---------------|
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

### Schedule/Scene status
| Key | English Value |
|-----|---------------|
| dosingScheduleStatusEnabled | Enabled |
| dosingScheduleStatusDisabled | Paused |
| ledSceneStatusEnabled | Enabled |
| ledSceneStatusDisabled | Disabled |
| ledScheduleStatusEnabled | Enabled |
| ledScheduleStatusDisabled | Disabled |

### Format strings (placeholders)
| Key | English Value |
|-----|---------------|
| dosingVolumeFormat | {dispensed} / {target} ml |
| channelPercentageFormat | {label} {percentage}% |
| timeRangeSeparator | ~ |

---

## Summary

| Category | Count |
|----------|-------|
| **MAPPING_SUGGESTION** (exact text match in reef-b, same key) | 1 |
| **COPY_MISMATCH** (normalized match; koralcore wording differs, use reef-b exact wording) | 6 |
| **TRUE_NEW** (no normalized match in reef-b) | 157 |
| **Total** | 164 |

---

## Notes

- **Normalization:** Case-insensitive comparison, whitespace collapsed, trailing punctuation ignored.
- **COPY_MISMATCH:** koralcore uses slightly different wording (e.g. "Cool white" vs "Cool White"). Use reef-b exact wording for translations.
- **reef-b-app read-only:** No changes were made to reef-b-app.
- **Source:** `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml`
