# reef-b-app Parity Verification Report

**Date:** 2025-02-11  
**Scope:** led_control_page, led_schedule_edit_page, manual_dosing_page, schedule_edit_page (dosing)  
**Method:** Direct search of reef-b-app Android and iOS source code. No inference.

---

## Task 1: led_control_page Parity

### Android reef-b-app

| Search Term | Result |
|-------------|--------|
| `activity_led_control.xml` | **NO IMPLEMENTATION FOUND** |
| `LedControlActivity` | **NO IMPLEMENTATION FOUND** |
| Fragment for LED control | **NO IMPLEMENTATION FOUND** |

### iOS reef-b-app

| Search Term | Result |
|-------------|--------|
| `LedControlViewController` | **NO IMPLEMENTATION FOUND** |
| Separate LED control screen | **NO IMPLEMENTATION FOUND** |

### Where LED control logic lives

- **LedMainActivity** (`activity_led_main.xml`) contains: toolbar, device name, BLE button, record section (line chart, expand, preview), scene section (RecyclerView of favorite scenes).
- **activity_led_main.xml** lines 1-268: Record chart (line_chart), layout_record_pause, btn_preview, btn_expand, rv_favorite_scene. **No channel sliders, no dimming control.**
- **LedSettingActivity** (`activity_led_setting.xml`): Device name, sink position settings. **No channel intensity control.**

### Output

- **Found separate screen?** NO
- **LED control logic lives:** NOT PRESENT in reef-b-app. No activity, layout, or screen provides channel sliders or dimming control.
- **File paths:**
  - `reef-b-app/android/ReefB_Android/app/src/main/res/layout/activity_led_main.xml` (LedMainActivity host)
  - `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_main/LedMainActivity.kt`
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LED/LEDViewController.swift` (LED main screen)

---

## Task 2: led_schedule_edit_page Parity

### Android reef-b-app

| Search Term | Result |
|-------------|--------|
| `activity_led_schedule_edit.xml` | **NO IMPLEMENTATION FOUND** |
| `LedScheduleEditActivity` | **NO IMPLEMENTATION FOUND** |
| LED schedule edit form layout | **FOUND:** `activity_led_record_setting.xml` |

- **LedRecordSettingActivity** uses `activity_led_record_setting.xml` (init strength, sunrise/sunset, slow start, moon light sliders).
- **LedRecordActivity** uses `activity_led_record.xml` (schedule list with chart, time add button).

### Menu resources

- `R.menu.led_menu` exists; no `R.menu.*schedule*` for LED. LedRecordSettingActivity uses toolbar, not PopupMenu for schedule type.

### iOS reef-b-app

| Search Term | Result |
|-------------|--------|
| `LedScheduleEditViewController` | **NO IMPLEMENTATION FOUND** (exact name) |
| LedRecordSettingViewController | **FOUND** |

- `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LedRecordSetting/LedRecordSettingViewController.swift`
- `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LEDScheduleDetail/LEDScheduleDetailViewController.swift` (schedule detail/view)
- `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LEDScheduleTimeSetting/LEDScheduleTimeSettingViewController.swift` (time setting)

### Output

- **Independent screen?** YES
- **Equivalent screens:**
  - Android: `LedRecordSettingActivity` + `activity_led_record_setting.xml`
  - iOS: `LedRecordSettingViewController`
- **File paths:**
  - `reef-b-app/android/ReefB_Android/app/src/main/res/layout/activity_led_record_setting.xml` (lines 1-318: init strength, sunrise/sunset, slow start, moon light)
  - `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_record_setting/LedRecordSettingActivity.kt`
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LedRecordSetting/LedRecordSettingViewController.swift`

---

## Task 3: manual_dosing_page Parity

### Android reef-b-app

| Search Term | Result |
|-------------|--------|
| `ManualDosingActivity` | **NO IMPLEMENTATION FOUND** |
| `activity_manual_dosing.xml` | **NO IMPLEMENTATION FOUND** |
| Manual dosing UI layout | **FOUND:** embedded in `activity_drop_main.xml` + `adapter_drop_head.xml` |

- **DropMainActivity** hosts `rv_drop_head` (RecyclerView) with `adapter_drop_head` items.
- **adapter_drop_head.xml** line 69-77: `btn_play` (ImageView) = manual dose trigger per pump head.
- **DropMainViewModel.kt** lines 52-61, 593-609: `manualDropSuccessLiveData`, `manualDropErrorLiveData`, `manualDropState`.

### iOS reef-b-app

| Search Term | Result |
|-------------|--------|
| `ManualDosingViewController` | **NO IMPLEMENTATION FOUND** |
| Manual dosing screen | **NO IMPLEMENTATION FOUND** (embedded) |

- **InfustionPumpViewController** / **InfustionPumpViewModel**: `manuallyDropEvent`, manual drip logic. Manual dosing is embedded in the main InfusionPump view.

### Output

- **Independent screen?** NO
- **Embedded in:** `activity_drop_main.xml` → `adapter_drop_head.xml` (btn_play per pump head card)
- **File paths:**
  - `reef-b-app/android/ReefB_Android/app/src/main/res/layout/activity_drop_main.xml` (lines 84-97: rv_drop_head)
  - `reef-b-app/android/ReefB_Android/app/src/main/res/layout/adapter_drop_head.xml` (lines 69-77: btn_play)
  - `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_main/DropMainActivity.kt` (lines 240-245: manualDrop observers)
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/InfustionPump/InfustionPump/InfustionPumpViewController.swift` (line 209: manuallyDropEvent)
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/InfustionPump/InfustionPump/InfustionPumpViewModel.swift` (lines 36-51, 171-394: manual drop logic)

---

## Task 4: schedule_edit_page (dosing) Parity

### Android reef-b-app

| Search Term | Result |
|-------------|--------|
| `activity_drop_head_record_setting.xml` | **FOUND** |
| `DropHeadRecordSettingActivity` | **FOUND** |
| `R.menu.drop_record_type_menu` | **FOUND** |

- **DropHeadRecordSettingActivity.kt** line 179: `menuRes = R.menu.drop_record_type_menu` for record type selection.
- **PopupMenu** on `btnRecordType` (lines 175-205): NONE, 24HR, SINGLE, CUSTOM.
- **Full screen** activity; schedule edit form is the main content, not inline.

### iOS reef-b-app

| Search Term | Result |
|-------------|--------|
| `DropHeadRecordSettingViewController` | **NO IMPLEMENTATION FOUND** (exact name) |
| `PumpHeadScheduleViewController` | **FOUND** (dosing schedule edit equivalent) |

- `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/InfustionPump/PumpHeadSchedule/PumpHeadScheduleViewController.swift`
- Navigated from `PumpHeadViewController` (line 640-641).

### Output

- **Independent screen?** YES
- **Implementation:** Full screen activity with PopupMenu for record type (NONE / 24HR / SINGLE / CUSTOM).
- **File paths:**
  - `reef-b-app/android/ReefB_Android/app/src/main/res/layout/activity_drop_head_record_setting.xml`
  - `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_head_record_setting/DropHeadRecordSettingActivity.kt` (lines 40-457, 175-205: PopupMenu)
  - `reef-b-app/android/ReefB_Android/app/src/main/res/menu/drop_record_type_menu.xml`
  - `reef-b-app/android/ReefB_Android/app/src/main/AndroidManifest.xml` (line 112: DropHeadRecordSettingActivity)
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/InfustionPump/PumpHeadSchedule/PumpHeadScheduleViewController.swift`
  - `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/InfustionPump/PumpHead/PumpHeadViewController.swift` (lines 640-641: navigation to schedule)
