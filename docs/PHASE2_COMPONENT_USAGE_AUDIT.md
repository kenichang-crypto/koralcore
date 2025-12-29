# Phase 2: 基礎組件使用情況審計

## 審計日期
2024-12-28

---

## 目標

系統性檢查所有頁面的組件使用情況，確保它們正確使用 Theme 中定義的基礎組件樣式。

---

## 檢查項目

對每個頁面檢查以下項目：

1. **Card 組件**
   - [ ] 是否使用 `Card` Widget（而不是硬編碼的 `Container`）？
   - [ ] 是否移除硬編碼的 `color`、`elevation`、`shape` 以使用 Theme？
   - [ ] 如果需要自定義，是否正確使用 `ReefColors`、`ReefRadius`？

2. **Button 組件**
   - [ ] 是否使用 `FilledButton`、`OutlinedButton`、`TextButton`？
   - [ ] 是否移除硬編碼的樣式以使用 Theme？
   - [ ] 如果需要自定義，是否正確使用 `ReefColors`、`ReefRadius`、`ReefTextStyles`？

3. **TextField 組件**
   - [ ] 是否移除硬編碼的 `InputDecoration` 以使用 Theme？
   - [ ] 如果需要自定義，是否正確使用 `ReefColors`、`ReefRadius`？

4. **顏色使用**
   - [ ] 是否使用 `ReefColors` 常量而非硬編碼顏色？
   - [ ] 是否使用語義化顏色（`textPrimary`、`textSecondary` 等）？

5. **間距和圓角**
   - [ ] 是否使用 `ReefSpacing` 常量？
   - [ ] 是否使用 `ReefRadius` 常量？

6. **文字樣式**
   - [ ] 是否使用 `ReefTextStyles` 而非直接定義 `TextStyle`？

---

## 頁面檢查清單

### Home 相關
- [ ] `home/home_page.dart`

### Bluetooth 相關
- [ ] `bluetooth/bluetooth_page.dart`

### Device 相關
- [ ] `device/device_page.dart`
- [ ] `device/pages/add_device_page.dart`
- [ ] `device/pages/device_settings_page.dart`
- [ ] `device/widgets/device_card.dart`

### LED 相關
- [ ] `led/pages/led_main_page.dart`
- [ ] `led/pages/led_control_page.dart`
- [ ] `led/pages/led_scene_list_page.dart`
- [ ] `led/pages/led_scene_add_page.dart`
- [ ] `led/pages/led_scene_edit_page.dart`
- [ ] `led/pages/led_scene_delete_page.dart`
- [ ] `led/pages/led_schedule_list_page.dart`
- [ ] `led/pages/led_schedule_edit_page.dart`
- [ ] `led/pages/led_record_page.dart`
- [ ] `led/pages/led_record_setting_page.dart`
- [ ] `led/pages/led_record_time_setting_page.dart`
- [ ] `led/pages/led_setting_page.dart`
- [ ] `led/pages/led_master_setting_page.dart`

### Dosing 相關
- [ ] `dosing/pages/dosing_main_page.dart`
- [ ] `dosing/pages/pump_head_detail_page.dart`
- [ ] `dosing/pages/pump_head_settings_page.dart`
- [ ] `dosing/pages/pump_head_calibration_page.dart`
- [ ] `dosing/pages/pump_head_adjust_list_page.dart`
- [ ] `dosing/pages/pump_head_record_setting_page.dart`
- [ ] `dosing/pages/pump_head_record_time_setting_page.dart`
- [ ] `dosing/pages/pump_head_schedule_page.dart`
- [ ] `dosing/pages/drop_setting_page.dart`
- [ ] `dosing/pages/drop_type_page.dart`
- [ ] `dosing/pages/schedule_edit_page.dart`
- [ ] `dosing/pages/manual_dosing_page.dart`

### Sink 相關
- [ ] `sink/pages/sink_manager_page.dart`
- [ ] `sink/pages/sink_position_page.dart`

### Warning 相關
- [ ] `warning/pages/warning_page.dart`

### Splash 相關
- [ ] `splash/pages/splash_page.dart`

### Components
- [ ] `components/feature_entry_card.dart`
- [ ] `components/ble_guard.dart`
- [ ] `components/app_error_presenter.dart`

---

## 發現的問題

### Card 組件問題

#### 問題 1: 硬編碼 Card 樣式
**文件**: `dosing/pages/pump_head_record_setting_page.dart`
**問題**: Card 組件可能使用了硬編碼的樣式
**需要檢查**: 是否移除硬編碼的 `color`、`elevation`、`shape`

#### 問題 2: 使用 Container 而非 Card
**文件**: `device/widgets/device_card.dart`
**狀態**: ✅ 可接受（因為需要自定義邊框等）
**說明**: 使用 `AnimatedContainer` 是合理的，因為需要自定義邊框和動畫

---

### Button 組件問題

待檢查...

---

### TextField 組件問題

#### 問題 1: 硬編碼 InputDecoration
**文件**: `dosing/pages/pump_head_record_setting_page.dart` (line 151)
**問題**: `decoration: const InputDecoration(border: OutlineInputBorder())`
**需要修復**: 移除硬編碼的 decoration，使用 Theme 的 InputDecorationTheme

---

## 修復計劃

### Step 1: 修復 Card 組件
- 移除硬編碼的 `color`、`elevation`、`shape`
- 讓 Card 使用 Theme 中定義的 CardTheme

### Step 2: 修復 Button 組件
- 移除硬編碼的按鈕樣式
- 確保使用 Theme 中定義的 Button Themes

### Step 3: 修復 TextField 組件
- 移除硬編碼的 InputDecoration
- 讓 TextField 使用 Theme 中定義的 InputDecorationTheme

### Step 4: 統一顏色、間距、圓角、文字樣式
- 確保所有硬編碼值都替換為常量

---

## 進度追蹤

### 待處理頁面數
- 總頁面數：約 30+ 個
- 已檢查：0 個
- 待檢查：30+ 個

### 發現的問題數
- Card 問題：待統計
- Button 問題：待統計
- TextField 問題：待統計
- 其他問題：待統計

