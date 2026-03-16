# reef-b-app LED Layout → koralcore Page Mapping

**Source:** Direct extraction from reef-b-app Android layouts and iOS ViewControllers.  
**Date:** 2025-02-11

---

## 1. activity_led_scene_add.xml

### Associated files
| Platform | File |
|----------|------|
| Android  | `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_scene_add/LedSceneAddActivity.kt` |
| iOS      | `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/SceneAdd/SceneAddViewController.swift` |

### Slider widgets (all 0–100, valueFrom="0", valueTo="100")

| ID | String key | Lines | Notes |
|----|------------|-------|-------|
| `sl_uv_light` | light_uv | 140–156 | UV channel |
| `sl_purple_light` | light_purple | 187–203 | Purple channel |
| `sl_blue_light` | light_blue | 232–248 | Blue channel |
| `sl_royal_blue_light` | light_royal_blue | 277–293 | Royal blue channel |
| `sl_green_light` | light_green | 322–338 | Green channel |
| `sl_red_light` | light_red | 367–383 | Red channel |
| `sl_cold_white_light` | light_cold_white | 412–428 | Cold white channel |
| `sl_warm_white_light` | light_warm_white | 352–368 | **visibility=gone** |
| `sl_moon_light` | light_moon | 391–408 | Moon light channel |

### Channel intensity controls (9 total)
- **8 visible:** UV, Purple, Blue, Royal Blue, Green, Red, Cold White, Moon
- **1 hidden:** Warm White

### Moon light control
- `sl_moon_light` (lines 391–408), `trackColorActive="@color/moon_light_color"`

### Sunrise/sunset
- **NONE** in activity_led_scene_add.xml

### Other UI
- `chart_spectrum` (LineChart, lines 97–106)
- `edt_name`, `rv_scene_icon`

---

## 2. activity_led_scene_edit.xml

### Associated files
| Platform | File |
|----------|------|
| Android  | `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_scene_edit/LedSceneEditActivity.kt` |
| iOS      | `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/SceneEditor/SceneEditorViewController.swift` |

### Slider widgets (same structure as scene_add)

| ID | String key | Lines | Notes |
|----|------------|-------|-------|
| `sl_uv_light` | light_uv | 141–157 | UV channel |
| `sl_purple_light` | light_purple | 188–204 | Purple channel |
| `sl_blue_light` | light_blue | 233–249 | Blue channel |
| `sl_royal_blue_light` | light_royal_blue | 278–294 | Royal blue channel |
| `sl_green_light` | light_green | 323–339 | Green channel |
| `sl_red_light` | light_red | 368–384 | Red channel |
| `sl_cold_white_light` | light_cold_white | 413–429 | Cold white channel |
| `sl_warm_white_light` | light_warm_white | 353–370 | **visibility=gone** |
| `sl_moon_light` | light_moon | 392–409 | Moon light channel |

### Channel intensity controls (9 total)
- Same as activity_led_scene_add: 8 visible + 1 hidden (Warm White)

### Moon light control
- `sl_moon_light` (lines 392–409)

### Sunrise/sunset
- **NONE** in activity_led_scene_edit.xml

---

## 3. activity_led_record_setting.xml

### Associated files
| Platform | File |
|----------|------|
| Android  | `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_record_setting/LedRecordSettingActivity.kt` |
| iOS      | `reef-b-app/ios/ReefB_iOS/Reefb/Scenes/LED/LedRecordSetting/LedRecordSettingViewController.swift` |

### Slider widgets

| ID | String key | Lines | Range | Notes |
|----|------------|-------|-------|-------|
| `sl_strength` | init_strength | 76–90 | 0–100 | Init strength (sun icon), CustomDashBoard + Slider |
| `sl_slow_start` | slow_start | 235–251 | 10–60, stepSize=10 | Slow start minutes |
| `sl_moon_light` | moon_light | 366–379 | 0–100 | Moon light |

### Channel intensity controls
- **NONE** in activity_led_record_setting. No UV/Purple/Blue/etc. sliders.

### Moon light control
- `sl_moon_light` (lines 366–379), `layout_slow_start_moon_light` section

### Sunrise/sunset
- **Not sliders.** Time picker buttons:
  - `btn_sunrise` (MaterialButton, lines 129–140) — displays time e.g. "06 : 00"
  - `btn_sunset` (MaterialButton, lines 169–181) — displays time e.g. "18 : 00"
- Section: `layout_sunrise_sunset` (lines 93–184)

### Other UI
- `db_strength` (CustomDashBoard), `tv_strength` (e.g. "50 %")

---

## 4. Reef Screen → koralcore Page Mapping

| Reef screen | Layout | Activity/ViewController | koralcore page |
|-------------|--------|-------------------------|----------------|
| **Scene Add** | activity_led_scene_add.xml | LedSceneAddActivity / SceneAddViewController | **led_scene_add_page.dart** |
| **Scene Edit** | activity_led_scene_edit.xml | LedSceneEditActivity / SceneEditorViewController | **led_scene_edit_page.dart** |
| **Record/Init Setting** (schedule init form) | activity_led_record_setting.xml | LedRecordSettingActivity / LedRecordSettingViewController | **led_schedule_edit_page.dart** |

---

## 5. Control parity summary

| Control type | activity_led_scene_add | activity_led_scene_edit | activity_led_record_setting |
|--------------|------------------------|-------------------------|------------------------------|
| **Channel sliders** (UV, Purple, Blue, Royal Blue, Green, Red, Cold White) | ✅ 7 visible | ✅ 7 visible | ❌ None |
| **Warm White slider** | ✅ visibility=gone | ✅ visibility=gone | ❌ None |
| **Moon light slider** | ✅ sl_moon_light | ✅ sl_moon_light | ✅ sl_moon_light |
| **Init strength slider** | ❌ None | ❌ None | ✅ sl_strength |
| **Slow start slider** | ❌ None | ❌ None | ✅ sl_slow_start (10–60 min) |
| **Sunrise/Sunset** | ❌ None | ❌ None | ✅ btn_sunrise, btn_sunset (time pickers, not sliders) |
| **Spectrum chart** | ✅ chart_spectrum | ✅ chart_spectrum | ❌ None |

---

## 6. koralcore page references

| koralcore page | Path | Reef parity |
|----------------|------|-------------|
| led_scene_add_page | `lib/features/led/presentation/pages/led_scene_add_page.dart` | activity_led_scene_add.xml |
| led_scene_edit_page | `lib/features/led/presentation/pages/led_scene_edit_page.dart` | activity_led_scene_edit.xml |
| led_schedule_edit_page | `lib/features/led/presentation/pages/led_schedule_edit_page.dart` | activity_led_record_setting.xml |
