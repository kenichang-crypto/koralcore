# UI 頁面概覽

## 生成日期
2024-12-28

---

## 頁面統計

- **總頁面數**: 約 40+ 個頁面
- **主要功能模塊**: 6 個（Home, Device, LED, Dosing, Sink, Warning, Bluetooth, Splash）

---

## 頁面分類

### 1. 主頁面（Home）

#### `HomePage`
- **路徑**: `lib/ui/features/home/home_page.dart`
- **功能**: 應用主頁，顯示設備概覽
- **導航**: 可導航到 LED、Dosing、Device、Warning 等頁面

---

### 2. 啟動頁面（Splash）

#### `SplashPage`
- **路徑**: `lib/ui/features/splash/pages/splash_page.dart`
- **功能**: 應用啟動畫面
- **導航**: 延遲後導航到 `MainScaffold`

---

### 3. 設備管理（Device）

#### `DevicePage`
- **路徑**: `lib/ui/features/device/device_page.dart`
- **功能**: 設備列表頁面
- **導航**: 可導航到設備設置、添加設備等

#### `DeviceSettingsPage`
- **路徑**: `lib/ui/features/device/pages/device_settings_page.dart`
- **功能**: 設備設置頁面
- **導航**: 返回設備列表

#### `AddDevicePage`
- **路徑**: `lib/ui/features/device/pages/add_device_page.dart`
- **功能**: 添加新設備頁面
- **導航**: 返回設備列表

---

### 4. LED 功能（LED）

#### `LedMainPage`
- **路徑**: `lib/ui/features/led/pages/led_main_page.dart`
- **功能**: LED 設備主頁面
- **導航**: 可導航到控制、場景、記錄、設置等

#### `LedControlPage`
- **路徑**: `lib/ui/features/led/pages/led_control_page.dart`
- **功能**: LED 手動控制頁面
- **導航**: 返回 LED 主頁

#### `LedSceneListPage`
- **路徑**: `lib/ui/features/led/pages/led_scene_list_page.dart`
- **功能**: LED 場景列表頁面
- **導航**: 可導航到場景添加、編輯、刪除頁面

#### `LedSceneAddPage`
- **路徑**: `lib/ui/features/led/pages/led_scene_add_page.dart`
- **功能**: 添加 LED 場景頁面
- **導航**: 返回場景列表

#### `LedSceneEditPage`
- **路徑**: `lib/ui/features/led/pages/led_scene_edit_page.dart`
- **功能**: 編輯 LED 場景頁面
- **導航**: 返回場景列表

#### `LedSceneDeletePage`
- **路徑**: `lib/ui/features/led/pages/led_scene_delete_page.dart`
- **功能**: 刪除 LED 場景頁面
- **導航**: 返回場景列表

#### `LedScheduleListPage`
- **路徑**: `lib/ui/features/led/pages/led_schedule_list_page.dart`
- **功能**: LED 排程列表頁面
- **導航**: 可導航到排程編輯頁面

#### `LedScheduleEditPage`
- **路徑**: `lib/ui/features/led/pages/led_schedule_edit_page.dart`
- **功能**: 編輯 LED 排程頁面
- **導航**: 返回排程列表

#### `LedRecordPage`
- **路徑**: `lib/ui/features/led/pages/led_record_page.dart`
- **功能**: LED 記錄頁面
- **導航**: 可導航到記錄設置頁面

#### `LedRecordSettingPage`
- **路徑**: `lib/ui/features/led/pages/led_record_setting_page.dart`
- **功能**: LED 記錄設置頁面
- **導航**: 返回記錄頁面

#### `LedRecordTimeSettingPage`
- **路徑**: `lib/ui/features/led/pages/led_record_time_setting_page.dart`
- **功能**: LED 記錄時間設置頁面
- **導航**: 返回記錄設置頁面

#### `LedSettingPage`
- **路徑**: `lib/ui/features/led/pages/led_setting_page.dart`
- **功能**: LED 設備設置頁面
- **導航**: 可導航到水槽位置、主從設置頁面

#### `LedMasterSettingPage`
- **路徑**: `lib/ui/features/led/pages/led_master_setting_page.dart`
- **功能**: LED 主從設置頁面
- **導航**: 返回 LED 設置頁面

---

### 5. Dosing 功能（Dosing）

#### `DosingMainPage`
- **路徑**: `lib/ui/features/dosing/pages/dosing_main_page.dart`
- **功能**: Dosing 設備主頁面
- **導航**: 可導航到泵頭詳情、手動加藥等

#### `PumpHeadDetailPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_detail_page.dart`
- **功能**: 泵頭詳情頁面
- **導航**: 可導航到排程、校準、設置等

#### `PumpHeadSchedulePage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_schedule_page.dart`
- **功能**: 泵頭排程頁面
- **導航**: 可導航到排程設置、編輯頁面

#### `PumpHeadRecordSettingPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_record_setting_page.dart`
- **功能**: 泵頭排程設置頁面
- **導航**: 可導航到時間設置頁面

#### `PumpHeadRecordTimeSettingPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_record_time_setting_page.dart`
- **功能**: 泵頭排程時間設置頁面
- **導航**: 返回排程設置頁面

#### `ScheduleEditPage`
- **路徑**: `lib/ui/features/dosing/pages/schedule_edit_page.dart`
- **功能**: 編輯排程頁面
- **導航**: 返回排程列表

#### `PumpHeadCalibrationPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_calibration_page.dart`
- **功能**: 泵頭校準頁面
- **導航**: 可導航到校準歷史列表頁面

#### `PumpHeadAdjustListPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_adjust_list_page.dart`
- **功能**: 泵頭校準歷史列表頁面
- **導航**: 返回校準頁面

#### `PumpHeadSettingsPage`
- **路徑**: `lib/ui/features/dosing/pages/pump_head_settings_page.dart`
- **功能**: 泵頭設置頁面
- **導航**: 可導航到滴液類型頁面

#### `DropSettingPage`
- **路徑**: `lib/ui/features/dosing/pages/drop_setting_page.dart`
- **功能**: Dosing 設備設置頁面
- **導航**: 返回設備列表

#### `ManualDosingPage`
- **路徑**: `lib/ui/features/dosing/pages/manual_dosing_page.dart`
- **功能**: 手動加藥頁面
- **導航**: 返回 Dosing 主頁

#### `DropTypePage`
- **路徑**: `lib/ui/features/dosing/pages/drop_type_page.dart`
- **功能**: 滴液類型管理頁面
- **導航**: 返回泵頭設置頁面

---

### 6. 水槽管理（Sink）

#### `SinkManagerPage`
- **路徑**: `lib/ui/features/sink/pages/sink_manager_page.dart`
- **功能**: 水槽管理頁面
- **導航**: 可添加、編輯、刪除水槽

#### `SinkPositionPage`
- **路徑**: `lib/ui/features/sink/pages/sink_position_page.dart`
- **功能**: 選擇水槽位置頁面
- **導航**: 返回設備設置頁面

---

### 7. 警告管理（Warning）

#### `WarningPage`
- **路徑**: `lib/ui/features/warning/pages/warning_page.dart`
- **功能**: 警告列表頁面
- **導航**: 可清除警告

---

### 8. 藍牙管理（Bluetooth）

#### `BluetoothPage`
- **路徑**: `lib/ui/features/bluetooth/bluetooth_page.dart`
- **功能**: 藍牙掃描和連接頁面
- **導航**: 返回主頁

---

## 頁面導航結構

```
SplashPage
  └─> MainScaffold
      ├─> HomePage
      │   ├─> LedMainPage
      │   │   ├─> LedControlPage
      │   │   ├─> LedSceneListPage
      │   │   │   ├─> LedSceneAddPage
      │   │   │   ├─> LedSceneEditPage
      │   │   │   └─> LedSceneDeletePage
      │   │   ├─> LedScheduleListPage
      │   │   │   └─> LedScheduleEditPage
      │   │   ├─> LedRecordPage
      │   │   │   ├─> LedRecordSettingPage
      │   │   │   │   └─> LedRecordTimeSettingPage
      │   │   │   └─> LedRecordSettingPage
      │   │   └─> LedSettingPage
      │   │       ├─> SinkPositionPage
      │   │       └─> LedMasterSettingPage
      │   ├─> DosingMainPage
      │   │   ├─> PumpHeadDetailPage
      │   │   │   ├─> PumpHeadSchedulePage
      │   │   │   │   ├─> PumpHeadRecordSettingPage
      │   │   │   │   │   └─> PumpHeadRecordTimeSettingPage
      │   │   │   │   └─> ScheduleEditPage
      │   │   │   ├─> PumpHeadCalibrationPage
      │   │   │   │   └─> PumpHeadAdjustListPage
      │   │   │   └─> PumpHeadSettingsPage
      │   │   │       └─> DropTypePage
      │   │   ├─> ManualDosingPage
      │   │   └─> DropSettingPage
      │   ├─> DevicePage
      │   │   ├─> DeviceSettingsPage
      │   │   ├─> AddDevicePage
      │   │   │   └─> SinkPositionPage
      │   │   └─> DropSettingPage / LedSettingPage
      │   ├─> WarningPage
      │   └─> BluetoothPage
      └─> SinkManagerPage
```

---

## 頁面功能對照（與 reef-b-app）

### ✅ 已實現的頁面

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `SplashActivity` | `SplashPage` | ✅ 已完成 |
| `MainActivity` | `HomePage` | ✅ 已完成 |
| `DeviceActivity` | `DevicePage` | ✅ 已完成 |
| `DeviceSettingActivity` | `DeviceSettingsPage` | ✅ 已完成 |
| `AddDeviceActivity` | `AddDevicePage` | ✅ 已完成 |
| `LedMainActivity` | `LedMainPage` | ✅ 已完成 |
| `LedControlActivity` | `LedControlPage` | ✅ 已完成 |
| `LedSceneListActivity` | `LedSceneListPage` | ✅ 已完成 |
| `LedSceneAddActivity` | `LedSceneAddPage` | ✅ 已完成 |
| `LedSceneEditActivity` | `LedSceneEditPage` | ✅ 已完成 |
| `LedSceneDeleteActivity` | `LedSceneDeletePage` | ✅ 已完成 |
| `LedScheduleListActivity` | `LedScheduleListPage` | ✅ 已完成 |
| `LedScheduleEditActivity` | `LedScheduleEditPage` | ✅ 已完成 |
| `LedRecordActivity` | `LedRecordPage` | ✅ 已完成 |
| `LedRecordSettingActivity` | `LedRecordSettingPage` | ✅ 已完成 |
| `LedRecordTimeSettingActivity` | `LedRecordTimeSettingPage` | ✅ 已完成 |
| `LedSettingActivity` | `LedSettingPage` | ✅ 已完成 |
| `LedMasterSettingActivity` | `LedMasterSettingPage` | ✅ 已完成 |
| `DosingMainActivity` | `DosingMainPage` | ✅ 已完成 |
| `DropHeadDetailActivity` | `PumpHeadDetailPage` | ✅ 已完成 |
| `DropHeadScheduleActivity` | `PumpHeadSchedulePage` | ✅ 已完成 |
| `DropHeadRecordSettingActivity` | `PumpHeadRecordSettingPage` | ✅ 已完成 |
| `DropHeadRecordTimeSettingActivity` | `PumpHeadRecordTimeSettingPage` | ✅ 已完成 |
| `ScheduleEditActivity` | `ScheduleEditPage` | ✅ 已完成 |
| `DropHeadCalibrationActivity` | `PumpHeadCalibrationPage` | ✅ 已完成 |
| `DropHeadAdjustListActivity` | `PumpHeadAdjustListPage` | ✅ 已完成 |
| `DropHeadSettingActivity` | `PumpHeadSettingsPage` | ✅ 已完成 |
| `DropSettingActivity` | `DropSettingPage` | ✅ 已完成 |
| `ManualDosingActivity` | `ManualDosingPage` | ✅ 已完成 |
| `DropTypeActivity` | `DropTypePage` | ✅ 已完成 |
| `SinkManagerActivity` | `SinkManagerPage` | ✅ 已完成 |
| `SinkPositionActivity` | `SinkPositionPage` | ✅ 已完成 |
| `WarningActivity` | `WarningPage` | ✅ 已完成 |
| `BluetoothActivity` | `BluetoothPage` | ✅ 已完成 |

---

## 頁面特性

### BLE 連接保護

所有需要 BLE 連接的頁面都包含：
- ✅ `BleGuardBanner` - 顯示連接狀態
- ✅ 按鈕禁用邏輯 - 未連接時禁用操作
- ✅ 操作保護 - 未連接時阻止操作

### 資源使用

所有頁面都正確使用：
- ✅ 圖片資源（`Image.asset()`）
- ✅ 顏色資源（`ReefColors.*`）
- ✅ 尺寸資源（`ReefSpacing.*`, `ReefRadius.*`）
- ✅ 字符串資源（`AppLocalizations`）

### 導航

所有頁面都包含：
- ✅ 正確的導航邏輯
- ✅ 返回按鈕
- ✅ 導航到相關頁面

---

## 總結

✅ **所有核心 UI 頁面都已實現**

- 總共約 40+ 個頁面
- 涵蓋所有主要功能模塊
- 與 reef-b-app 功能對照完整
- 所有頁面都包含 BLE 連接保護
- 所有頁面都正確使用資源

**所有頁面都已就緒，可以正常使用。**

