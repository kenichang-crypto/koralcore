# L3｜外觀與圖標層（Visual / Icon）完整審核報告

**審核日期**: 2026-01-03  
**審核範圍**: 全專案所有 Flutter Pages 的 Icon 使用  
**審核標準**: 100% 來源一致性（只允許 Android drawable，禁止 Material Icons）

---

## 📋 L3-1 Icon 來源規則（Mandatory）

### ❌ 禁止事項

1. **Flutter 不得生成 icon**
2. **Flutter 不得選用近似 icon**
3. **Flutter 不得使用系統 / Material icon**

### ✅ 唯一合法來源

- ✅ Android `res/drawable/**`
- ✅ Android `res/mipmap/**`
- ✅ Android selector / layer-list

### ✅ Flutter 只能做一件事

**將 Android res 圖標轉為 Flutter asset，原樣使用**

---

## 📊 STEP 1：Flutter Icon 使用盤點

### 1.1 CommonIconHelper 使用情況

**檔案**: `lib/shared/assets/common_icon_helper.dart`

**提供的方法**: 40 個

**使用次數**: 97 次（全專案）

**評分**: ✅ **100% 合規** (所有 icon 都來自 Android drawable 轉換的 SVG)

**方法清單**:
```dart
// Toolbar icons
getBackIcon()          // ic_back.svg
getCloseIcon()         // ic_close.svg
getMenuIcon()          // ic_menu.svg
getAddIcon()           // ic_add_black.svg
getDeleteIcon()        // ic_delete.svg
getEditIcon()          // ic_edit.svg
getCheckIcon()         // ic_check.svg

// Device icons
getBluetoothIcon()     // ic_bluetooth.svg
getConnectIcon()       // ic_connect.svg
getDisconnectIcon()    // ic_disconnect.svg
getConnectBackgroundIcon()    // ic_connect_background.svg
getDisconnectBackgroundIcon() // ic_disconnect_background.svg
getDeviceIcon()        // ic_device.svg
getHomeIcon()          // ic_home.svg
getWarningIcon()       // ic_warning.svg

// Control icons
getPlayIcon()          // ic_play_enabled.svg
getStopIcon()          // ic_stop.svg
getPauseIcon()         // ic_pause.svg
getNextIcon()          // ic_next.svg
getMinusIcon()         // ic_minus.svg

// Manager icons
getManagerIcon()       // ic_manager.svg
getMasterIcon()        // ic_master.svg
getMasterBigIcon()     // ic_master_big.svg

// UI icons
getZoomInIcon()        // ic_zoom_in.svg
getZoomOutIcon()       // ic_zoom_out.svg
getCalendarIcon()      // ic_calendar.svg
getPreviewIcon()       // ic_preview.svg
getResetIcon()         // ic_reset.svg

// State icons
getFavoriteSelectIcon()    // ic_favorite_select.svg
getFavoriteUnselectIcon()  // ic_favorite_unselect.svg
getPlaySelectIcon()        // ic_play_select.svg
getPlayUnselectIcon()      // ic_play_unselect.svg
getMoreEnableIcon()        // ic_more_enable.svg
getMoreDisableIcon()       // ic_more_disable.svg
getPlayDisableIcon()       // ic_play_disable.svg
getGreenCheckIcon()        // ic_green_check.svg

// Additional icons
getAddBtnIcon()            // ic_add_btn.svg
getAddRoundedIcon()        // ic_add_rounded.svg
getAddWhiteIcon()          // ic_add_white.svg
```

---

### 1.2 🚨 Material Icons 違規使用情況

**檔案搜尋結果**: `grep -rn "Icons\." lib/features`

**違規次數**: **31 處**

**評分**: ❌ **0% 合規** (所有 Material Icons 都是違規)

#### 違規清單（逐一列出）

##### A. Dosing 模組（6 處）

| 檔案 | 行號 | 違規代碼 | 用途 | Android 對應 | 狀態 |
|------|------|---------|------|-------------|------|
| `pump_head_calibration_page.dart` | 143 | `Icons.tune` | 調整按鈕 | ❓ 待查 | ❌ 違規 |
| `pump_head_record_setting_page.dart` | 339 | `Icons.water_drop` | 水滴圖標 | `ic_drop.svg` | ❌ 違規 |
| `pump_head_record_setting_page.dart` | 602 | `Icons.calendar_today` | 日曆圖標 | `ic_calendar.svg` | ❌ 違規 |
| `pump_head_record_setting_page.dart` | 618 | `Icons.navigate_next` | 下一步箭頭 | `ic_next.svg` | ❌ 違規 |
| `pump_head_record_setting_page.dart` | 650 | `Icons.calendar_today` | 日曆圖標 | `ic_calendar.svg` | ❌ 違規 |
| `pump_head_record_setting_page.dart` | 666 | `Icons.navigate_next` | 下一步箭頭 | `ic_next.svg` | ❌ 違規 |

---

##### B. LED 模組（23 處）

| 檔案 | 行號 | 違規代碼 | 用途 | Android 對應 | 狀態 |
|------|------|---------|------|-------------|------|
| `led_record_time_setting_page.dart` | 168 | `Icons.arrow_drop_down` | 下拉箭頭 | `ic_down.svg` | ❌ 違規 |
| `led_record_page.dart` | 100 | `Icons.arrow_back` | 返回按鈕 | `ic_back.svg` | ❌ 違規 |
| `led_record_page.dart` | 116 | `Icons.settings` | 設定按鈕 | ❓ 待查 | ❌ 違規 |
| `led_record_page.dart` | 193 | `Icons.add` | 新增按鈕 | `ic_add_black.svg` | ❌ 違規 |
| `led_record_page.dart` | 197 | `Icons.remove` | 移除按鈕 | `ic_minus.svg` | ❌ 違規 |
| `led_record_page.dart` | 202 | `Icons.skip_previous` | 上一步 | ❓ 待查 | ❌ 違規 |
| `led_record_page.dart` | 207 | `Icons.skip_next` | 下一步 | ❓ 待查 | ❌ 違規 |
| `led_record_page.dart` | 212 | `Icons.play_arrow` | 播放按鈕 | `ic_play_enabled.svg` | ❌ 違規 |
| `led_record_page.dart` | 275 | `Icons.add_circle_outline` | 新增記錄 | `ic_add_btn.svg` | ❌ 違規 |
| `led_record_page.dart` | 324 | `Icons.more_horiz` | 更多選項 | `ic_more_enable.svg` | ❌ 違規 |
| `led_scene_edit_page.dart` | 251 | `Icons.image` | 場景圖標占位 | ❓ 待查 | ❌ 違規 |
| `led_scene_list_page.dart` | 505 | `Icons.auto_awesome` | 預設場景圖標 | ❓ 待查 | ❌ 違規 |
| `led_scene_list_page.dart` | 569 | `Icons.auto_awesome_motion` | 預設場景圖標 | ❓ 待查 | ❌ 違規 |
| `led_scene_list_page.dart` | 569 | `Icons.pie_chart_outline` | 自訂場景圖標 | ❓ 待查 | ❌ 違規 |
| `led_record_setting_page.dart` | 295 | `Icons.arrow_drop_down` | 下拉箭頭 | `ic_down.svg` | ❌ 違規 |
| `led_record_setting_page.dart` | 349 | `Icons.arrow_drop_down` | 下拉箭頭 | `ic_down.svg` | ❌ 違規 |
| `led_record_setting_page.dart` | 388 | `Icons.speed` | Slow Start 圖標 | ❓ 待查 | ❌ 違規 |
| `led_record_setting_page.dart` | 488 | `Icons.nightlight_round` | Moon Light 圖標 | `ic_moon_round.svg` | ❌ 違規 |
| `led_scene_add_page.dart` | 249 | `Icons.image` | 場景圖標占位 | ❓ 待查 | ❌ 違規 |
| `led_scene_delete_page.dart` | 168 | `Icons.image` | 場景圖標占位 | ❓ 待查 | ❌ 違規 |
| `led_scene_delete_page.dart` | 193 | `Icons.check` | 勾選圖標 | `ic_check.svg` | ❌ 違規 |
| `scene_icon_helper.dart` | 70 | `Icons.circle_outlined` | 預設場景圖標 | ❓ 待查 | ❌ 違規 |
| `scene_icon_helper.dart` | 98 | `Icons.circle_outlined` | 預設場景圖標 | ❓ 待查 | ❌ 違規 |
| `scene_icon_helper.dart` | 144 | `Icons.circle_outlined` | 預設場景圖標 | ❓ 待查 | ❌ 違規 |

---

##### C. Device 模組（2 處）

| 檔案 | 行號 | 違規代碼 | 用途 | Android 對應 | 狀態 |
|------|------|---------|------|-------------|------|
| `device_card.dart` | 85 | `Icons.lightbulb` | LED 裝置圖標 | `icon_led.svg` | ❌ 違規 |
| `device_card.dart` | 86 | `Icons.water_drop` | Dosing 裝置圖標 | `icon_dosing.svg` | ❌ 違規 |

---

### 1.3 違規統計摘要

| 模組 | 違規次數 | 主要違規類型 |
|------|---------|------------|
| **Dosing** | 6 處 | 日曆、箭頭、水滴 |
| **LED** | 23 處 | 下拉、播放、場景圖標 |
| **Device** | 2 處 | 裝置圖標 |
| **總計** | **31 處** | - |

**違規率**: **31 / (97 + 31) = 24.2%**

---

## 📊 STEP 2：Android Drawable 資源盤點

### 2.1 Android Icon 統計

**來源**: `reef-b-app/android/ReefB_Android/app/src/main/res/drawable`

**Icon 總數**: 86 個

**已轉換為 Flutter SVG**: 87 個

**轉換率**: **101%** (Flutter 有 1 個額外的 icon)

---

### 2.2 Android Drawable 分類

#### A. Toolbar Icons（14 個）
- `ic_back.xml` ✅
- `ic_close.xml` ✅
- `ic_menu.xml` ✅
- `ic_next.xml` ✅
- `ic_down.xml` ✅
- `ic_add_black.xml` ✅
- `ic_add_btn.xml` ✅
- `ic_add_rounded.xml` ✅
- `ic_add_white.xml` ✅
- `ic_delete.xml` ✅
- `ic_edit.xml` ✅
- `ic_check.xml` ✅
- `ic_green_check.xml` ✅
- `ic_reset.xml` ✅

#### B. Device Icons（9 個）
- `ic_bluetooth.xml` ✅
- `ic_connect.xml` ✅
- `ic_disconnect.xml` ✅
- `ic_connect_background.xml` ✅
- `ic_disconnect_background.xml` ✅
- `ic_device.xml` ✅
- `ic_home.xml` ✅
- `ic_warning.xml` ✅
- `icon_device.svg` ✅

#### C. Control Icons（10 個）
- `ic_play_enabled.xml` ✅
- `ic_play_disable.xml` ✅
- `ic_play_select.xml` ✅
- `ic_play_unselect.xml` ✅
- `ic_stop.xml` ✅
- `ic_pause.xml` ✅
- `ic_minus.xml` ✅
- `ic_more_enable.xml` ✅
- `ic_more_disable.xml` ✅
- `ic_zoom_in.xml` ✅
- `ic_zoom_out.xml` ✅

#### D. Scene/Weather Icons（18 個）
- `ic_sunny.xml` ✅
- `ic_cloudy.xml` ✅
- `ic_rainy.xml` ✅
- `ic_thunder.xml` ✅
- `ic_moon.xml` ✅
- `ic_moon_round.xml` ✅
- `ic_sunset.xml` ✅
- `ic_light_off.xml` ✅
- ... (其他場景圖標)

#### E. Weekday Icons（14 個）
- `ic_sunday_select.xml` ✅
- `ic_sunday_unselect.xml` ✅
- `ic_monday_select.xml` ✅
- `ic_monday_unselect.xml` ✅
- ... (其他星期圖標)

#### F. Other Icons（21 個）
- `ic_manager.xml` ✅
- `ic_master.xml` ✅
- `ic_master_big.xml` ✅
- `ic_calendar.xml` ✅
- `ic_preview.xml` ✅
- `ic_favorite_select.xml` ✅
- `ic_favorite_unselect.xml` ✅
- ... (其他雜項圖標)

---

## 🚨 STEP 3：違規 Icon 詳細分析

### 3.1 可直接替換的違規 Icon（22 處）

這些違規 Icon **已有對應的 Android drawable**，可立即替換：

| Material Icon | 對應 Android | CommonIconHelper 方法 | 違規次數 |
|--------------|-------------|---------------------|---------|
| `Icons.arrow_back` | `ic_back.xml` | `getBackIcon()` | 1 |
| `Icons.calendar_today` | `ic_calendar.xml` | `getCalendarIcon()` | 2 |
| `Icons.navigate_next` | `ic_next.xml` | `getNextIcon()` | 2 |
| `Icons.arrow_drop_down` | `ic_down.xml` | ✅ 已存在（需新增 method） | 3 |
| `Icons.add` | `ic_add_black.xml` | `getAddIcon()` | 1 |
| `Icons.remove` | `ic_minus.xml` | `getMinusIcon()` | 1 |
| `Icons.play_arrow` | `ic_play_enabled.xml` | `getPlayIcon()` | 1 |
| `Icons.add_circle_outline` | `ic_add_btn.xml` | `getAddBtnIcon()` | 1 |
| `Icons.more_horiz` | `ic_more_enable.xml` | `getMoreEnableIcon()` | 1 |
| `Icons.check` | `ic_check.xml` | `getCheckIcon()` | 1 |
| `Icons.water_drop` | `ic_drop.svg` | ✅ 已存在（需新增 method） | 2 |
| `Icons.nightlight_round` | `ic_moon_round.xml` | ✅ 已存在（需新增 method） | 1 |
| `Icons.lightbulb` | `icon_led.svg` | ✅ 已存在（需新增 method） | 1 |

**小計**: 18 處可立即替換

---

### 3.2 需要新增 Android Drawable 的違規 Icon（9 處）

這些違規 Icon **Android 沒有對應的 drawable**，需要：
1. **選項 A**: 從 Android 設計師獲取原始 drawable
2. **選項 B**: 如果 Android 也使用 Material Icon，則 Flutter 可暫時保留（標註 TODO）
3. **選項 C**: 移除該 Icon（如果非必要）

| Material Icon | 用途 | 檔案 | Android 是否有？ | 建議 |
|--------------|------|------|---------------|------|
| `Icons.tune` | 調整按鈕 | `pump_head_calibration_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.settings` | 設定按鈕 | `led_record_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.skip_previous` | 上一步 | `led_record_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.skip_next` | 下一步 | `led_record_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.image` | 場景圖標占位 | `led_scene_*_page.dart` (3 處) | ❓ 待查 | 選項 C (移除) |
| `Icons.auto_awesome` | 預設場景圖標 | `led_scene_list_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.auto_awesome_motion` | 預設場景圖標 | `led_scene_list_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.pie_chart_outline` | 自訂場景圖標 | `led_scene_list_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.speed` | Slow Start 圖標 | `led_record_setting_page.dart` | ❓ 待查 | 選項 A/B |
| `Icons.circle_outlined` | 預設場景圖標 | `scene_icon_helper.dart` (3 處) | ❓ 待查 | 選項 A/B |

**小計**: 9 種 Icon (對應 13 處使用)

---

## ✅ STEP 4：修正計劃

### 4.1 優先級 P0：立即可替換（18 處）

這些違規 Icon 已有對應的 SVG 和 `CommonIconHelper` 方法，可立即替換。

#### 修正範例：

```dart
// ❌ Before (違規)
Icon(Icons.arrow_back, size: 24)

// ✅ After (合規)
import '../../../../shared/assets/common_icon_helper.dart';

CommonIconHelper.getBackIcon(size: 24)
```

#### 需要新增的 CommonIconHelper 方法（4 個）：

```dart
// lib/shared/assets/common_icon_helper.dart

/// Get down icon (dropdown arrow)
static SvgPicture getDownIcon({double? size, Color? color}) {
  return SvgPicture.asset(
    'assets/icons/ic_down.svg',
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

/// Get drop icon (water drop)
static SvgPicture getDropIcon({double? size, Color? color}) {
  return SvgPicture.asset(
    'assets/icons/ic_drop.svg',
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

/// Get moon round icon
static SvgPicture getMoonRoundIcon({double? size, Color? color}) {
  return SvgPicture.asset(
    'assets/icons/ic_moon_round.svg',
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

/// Get LED device icon
static SvgPicture getLedIcon({double? size, Color? color}) {
  return SvgPicture.asset(
    'assets/icons/icon_led.svg',
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

/// Get Dosing device icon
static SvgPicture getDosingIcon({double? size, Color? color}) {
  return SvgPicture.asset(
    'assets/icons/icon_dosing.svg',
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}
```

---

### 4.2 優先級 P1：需要查證 Android（13 處）

這些違規 Icon 需要先查證 Android `reef-b-app` 是否有對應的 drawable：

1. 查找 Android 對應頁面的 XML layout
2. 確認 Android 使用的 drawable 或 Material Icon
3. 根據結果選擇：
   - **如果 Android 有 drawable**: 轉換為 SVG，新增到 `CommonIconHelper`
   - **如果 Android 也用 Material Icon**: 標註 `TODO(android)` 保留（但需確認）
   - **如果 Android 沒有該 Icon**: 移除該 Icon（Parity Mode 不應有）

---

### 4.3 優先級 P2：場景圖標系統（Scene Icon System）

`scene_icon_helper.dart` 使用 `Icons.circle_outlined` 作為預設圖標，這需要特殊處理：

**選項 A**: 從 Android 獲取場景圖標系統的所有 drawable  
**選項 B**: 使用 placeholder SVG（如果 Android 也是占位圖）  
**選項 C**: 使用純色圓形（如果 Android 也是）

---

## 📊 STEP 5：L3 層評分

### 修正前

| 檢查項目 | 合規 / 總數 | 評分 |
|---------|-----------|------|
| **CommonIconHelper 使用** | 97 / 97 | ✅ 100% |
| **Material Icons 使用** | 0 / 31 | ❌ 0% |
| **整體合規率** | 97 / 128 | ⚠️ **75.8%** |

**L3｜外觀與圖標層總分**: ⚠️ **75.8%**

**阻塞問題**: 31 處 Material Icons 違規

---

### 修正後（預期）

| 檢查項目 | 合規 / 總數 | 評分 |
|---------|-----------|------|
| **CommonIconHelper 使用** | 97 / 97 | ✅ 100% |
| **Material Icons 使用** | 31 / 31 (替換為 CommonIconHelper) | ✅ 100% |
| **整體合規率** | 128 / 128 | ✅ **100%** |

**L3｜外觀與圖標層總分**: ✅ **100%**

---

## 📋 STEP 6：修正執行清單

### 階段 1：新增 CommonIconHelper 方法（P0）

- [ ] 新增 `getDownIcon()` (ic_down.svg)
- [ ] 新增 `getDropIcon()` (ic_drop.svg)
- [ ] 新增 `getMoonRoundIcon()` (ic_moon_round.svg)
- [ ] 新增 `getLedIcon()` (icon_led.svg)
- [ ] 新增 `getDosingIcon()` (icon_dosing.svg)

---

### 階段 2：替換可立即修正的違規（P0，18 處）

#### Dosing 模組（6 處）
- [ ] `pump_head_calibration_page.dart:143` - `Icons.tune` → 待查
- [ ] `pump_head_record_setting_page.dart:339` - `Icons.water_drop` → `getDropIcon()`
- [ ] `pump_head_record_setting_page.dart:602` - `Icons.calendar_today` → `getCalendarIcon()`
- [ ] `pump_head_record_setting_page.dart:618` - `Icons.navigate_next` → `getNextIcon()`
- [ ] `pump_head_record_setting_page.dart:650` - `Icons.calendar_today` → `getCalendarIcon()`
- [ ] `pump_head_record_setting_page.dart:666` - `Icons.navigate_next` → `getNextIcon()`

#### LED 模組（12 處）
- [ ] `led_record_time_setting_page.dart:168` - `Icons.arrow_drop_down` → `getDownIcon()`
- [ ] `led_record_page.dart:100` - `Icons.arrow_back` → `getBackIcon()`
- [ ] `led_record_page.dart:116` - `Icons.settings` → 待查
- [ ] `led_record_page.dart:193` - `Icons.add` → `getAddIcon()`
- [ ] `led_record_page.dart:197` - `Icons.remove` → `getMinusIcon()`
- [ ] `led_record_page.dart:212` - `Icons.play_arrow` → `getPlayIcon()`
- [ ] `led_record_page.dart:275` - `Icons.add_circle_outline` → `getAddBtnIcon()`
- [ ] `led_record_page.dart:324` - `Icons.more_horiz` → `getMoreEnableIcon()`
- [ ] `led_record_setting_page.dart:295` - `Icons.arrow_drop_down` → `getDownIcon()`
- [ ] `led_record_setting_page.dart:349` - `Icons.arrow_drop_down` → `getDownIcon()`
- [ ] `led_record_setting_page.dart:488` - `Icons.nightlight_round` → `getMoonRoundIcon()`
- [ ] `led_scene_delete_page.dart:193` - `Icons.check` → `getCheckIcon()`

#### Device 模組（2 處）
- [ ] `device_card.dart:85` - `Icons.lightbulb` → `getLedIcon()`
- [ ] `device_card.dart:86` - `Icons.water_drop` → `getDosingIcon()`

---

### 階段 3：查證 Android 並處理剩餘違規（P1，13 處）

需要逐一查證 Android 對應頁面：

- [ ] `Icons.tune` (1 處) - 查證 `activity_drop_head_adjust.xml`
- [ ] `Icons.settings` (1 處) - 查證 `activity_led_record.xml`
- [ ] `Icons.skip_previous` (1 處) - 查證 `activity_led_record.xml`
- [ ] `Icons.skip_next` (1 處) - 查證 `activity_led_record.xml`
- [ ] `Icons.image` (3 處) - 查證場景圖標占位
- [ ] `Icons.auto_awesome*` / `Icons.pie_chart_outline` (2 處) - 查證場景列表
- [ ] `Icons.speed` (1 處) - 查證 `activity_led_record_setting.xml`
- [ ] `Icons.circle_outlined` (3 處) - 查證 `scene_icon_helper.dart`

---

## 🎉 結論

### ✅ 現狀

1. **CommonIconHelper**: ✅ 100% 合規 (40 個方法，97 次使用，全部來自 Android drawable)
2. **Material Icons**: ❌ 31 處違規 (24.2% 違規率)
3. **Flutter SVG Assets**: ✅ 87 個 (對應 Android 86 個 drawable)

### 🎯 目標

**L3 層評分**: 75.8% → **100%** (+24.2%)

### 📋 待辦事項

1. **P0**: 新增 5 個 CommonIconHelper 方法
2. **P0**: 替換 18 處可立即修正的 Material Icons
3. **P1**: 查證並處理剩餘 13 處 Material Icons

### 🚀 預期成果

完成後，**所有 Icon 都將 100% 來自 Android drawable**，達成嚴格的「來源一致性」要求。

---

**完成日期**: 2026-01-03  
**產出**: L3 完整審核報告 + 修正計劃  
**下一步**: 執行階段 1 & 2（P0 優先）

