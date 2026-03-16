# DUPLICATE_SEMANTICS – Canonical reef-b Key Suggestions

**Generated:** 2025-02-11  
**Scope:** 38 keys with same semantic meaning as reef-b but different key names  
**reef-b-app:** Read-only reference

---

## Summary

| Renaming Required | Count |
|-------------------|-------|
| **No** (can copy translation from reef key) | 38 |
| **Yes** (koralcore key structure differs; align with reef for consistency) | 0 |

All DUPLICATE_SEMANTICS keys can use reef-b translations from the suggested canonical keys without renaming koralcore keys.

---

## Canonical reef-b Key Mapping

| koralcore Key | koralcore Value | Canonical reef-b Key | reef-b Value | reef-b Path:Line |
|---------------|-----------------|----------------------|--------------|------------------|
| sectionDosingTitle | Dosing | drop | Dosing Pump | values/strings.xml:34 |
| sectionLedTitle | Lighting | led | LED | values/strings.xml:33 |
| dosingHeader | Dosing | drop | Dosing Pump | values/strings.xml:34 |
| ledHeader | Lighting | led | LED | values/strings.xml:33 |
| dosingScheduleOverviewTitle | Schedules | record | Schedule | values/strings.xml:128 |
| dosingScheduleSummaryEmpty | No schedule | no_records | No scheduled tasks | values/strings.xml:44 |
| dosingScheduleSummaryTotalLabel | Total / day | drop_volume_per_day | Daily Total Dosing Volume | values/strings.xml:99 |
| dosingTodayTotalTotal | Total | drop_volume_per_day | Daily Total Dosing Volume | values/strings.xml:99 |
| dosingTodayTotalScheduled | Scheduled | today_record_drop_volume | Today's Scheduled Immediate Dosing Volume | values/strings.xml:122 |
| dosingTodayTotalManual | Manual | drop_record_type_custom | Free Mode | values/strings.xml:72 |
| dosingScheduleRecurrenceDaily | Every day | drop_days_a_week | Weekly Dosing Days | values/strings.xml:103 |
| dosingScheduleRecurrenceWeekdays | Weekdays | *(no exact match)* | — | — |
| dosingScheduleRecurrenceWeekends | Weekends | *(no exact match)* | — | — |
| dosingScheduleStatusEnabled | Enabled | *(implied by record_pause)* | — | — |
| dosingPumpHeadSettingsNameLabel | Pump head name | device_name | Device Name | values/strings.xml:154 |
| dosingPumpHeadSettingsDelayLabel | Dose delay | delay_time | Delay Time | values/strings.xml:121 |
| dosingCalibrationHistoryTitle | Calibration history | adjust_list | Calibration Log | values/strings.xml:142 |
| dosingCalibrationRecordNoteLabel | Note | *(no exact match)* | — | — |
| ledScenesPlaceholderTitle | Scenes | led_scene | Scene | values/strings.xml:133 |
| ledScenesListTitle | Scenes | led_scene | Scene | values/strings.xml:133 |
| ledScheduleSummaryTitle | Lighting schedule | record | Schedule | values/strings.xml:128 |
| ledScheduleSummaryEmpty | No schedule configured | no_records | No scheduled tasks | values/strings.xml:44 |
| ledScheduleSummaryWindowLabel | Window | time_setting | Period Settings | values/strings.xml:131 |
| ledScheduleSummaryLabel | Label | led_scene_name | Scene Name | values/strings.xml:139 |
| ledScheduleListTitle | Schedules | record | Schedule | values/strings.xml:128 |
| ledScheduleEditStartLabel | Start time | drop_start_time | Dosing Start Time | values/strings.xml:107 |
| ledScheduleEditEndLabel | End time | drop_end_time | Dosing End Time | values/strings.xml:108 |
| ledScheduleEditNameLabel | Schedule name | led_scene_name | Scene Name | values/strings.xml:139 |
| ledScheduleEditRecurrenceLabel | Recurrence | drop_days_a_week | Weekly Dosing Days | values/strings.xml:103 |
| ledScheduleEditChannelsHeader | Channels | *(spectrum names)* | — | — |
| ledScheduleEditEnabledToggle | Enable schedule | record_pause | The schedule is paused. | values/strings.xml:248 |
| ledScheduleRecurrenceDaily | Every day | drop_days_a_week | Weekly Dosing Days | values/strings.xml:103 |
| ledScheduleRecurrenceWeekdays | Weekdays | *(no exact match)* | — | — |
| ledScheduleRecurrenceWeekends | Weekends | *(no exact match)* | — | — |
| ledSceneStatusEnabled | Enabled | *(no exact match)* | — | — |
| ledSceneStatusDisabled | Disabled | *(no exact match)* | — | — |
| ledScheduleStatusEnabled | Enabled | *(no exact match)* | — | — |
| ledScheduleStatusDisabled | Disabled | *(no exact match)* | — | — |

---

## Renaming Analysis

**Renaming required:** No. koralcore keys follow Flutter/ARB naming (camelCase, hierarchical). reef-b uses snake_case (e.g. `drop_record_type`). Keeping koralcore key names and mapping to reef-b for translation content only is sufficient.

**Recommendation:** Copy translations from the suggested reef-b keys into the corresponding koralcore ARB locale files. For keys marked *(no exact match)*, use the closest reef-b semantic key or add new translations.

---

## Notes

- **reef-b path:** `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml`
- **reef-b-app:** Read-only; no changes made.
