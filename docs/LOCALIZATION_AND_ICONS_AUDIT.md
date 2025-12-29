# 本地化和圖標資源審計報告

**日期**: 2024-12-28  
**目標**: 比對 koralcore 與 reef-b-app 的本地化鍵值和圖標資源，標示不一致之處

---

## 📋 執行摘要

本報告詳細比對了 koralcore 與 reef-b-app 之間的本地化字符串和圖標資源使用情況，標示出所有不一致和缺失的項目。

---

## 🔍 本地化字符串審計

### 1. 缺失的本地化鍵值

#### 1.1 LED Master Setting Page (`led_master_setting_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 124 | `'群組'` | `@string/group` | ❌ **缺失** |
| Line 134 | `'LED'` | `@string/led` | ❌ **缺失** |
| Line 142 | `'主從'` | `@string/master_slave` | ❌ **缺失** |

**reef-b-app 實際值**:
- `group`: "Group"
- `led`: "LED"
- `master_slave`: "Master/Slave"

**建議修復**:
```dart
// 需要在 app_localizations.dart 中添加：
String get group;
String get led;
String get masterSlave;
```

---

#### 1.2 Dosing Adjust List Page (`pump_head_adjust_list_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 220 | `'日期'` | `@string/adjust_date` | ❌ **缺失** |
| Line 244 | `'測量體積'` | `@string/measure_drop_volume` | ❌ **缺失** |

**reef-b-app 實際值**:
- `adjust_date`: "Calibration Date"
- `measure_drop_volume`: "Measured Volume"

**建議修復**:
```dart
// 需要在 app_localizations.dart 中添加：
String get dosingAdjustListDate;
String get dosingAdjustListVolume;
```

---

#### 1.3 LED Scene Delete Page (`led_scene_delete_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 275 | `'無設定'` | `@string/no` 或需要新增 | ⚠️ **需確認** |

**分析**: reef-b-app 使用 `@string/no` ("None")，但中文語境可能需要 "無設定"。

**建議**: 添加 `ledSceneNoSetting` 鍵值以保持一致性。

---

#### 1.4 LED Record Time Setting Page (`led_record_time_setting_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 145 | `'時間'` | `@string/time` | ❌ **缺失** |

**reef-b-app 實際值**:
- `time`: "Time Point"

**建議修復**:
```dart
// 需要在 app_localizations.dart 中添加：
String get time;
```

---

#### 1.5 LED Main Page (`led_main_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 288 | `'記錄'` | `@string/record` | ❌ **缺失** |
| Line 354 | `'場景'` | `@string/led_scene` | ❌ **缺失** |
| Line 580 | `'Unassigned'` | `@string/unassigned_device` | ❌ **缺失** |
| Line 925 | `'無設定'` | `@string/no` 或需要新增 | ⚠️ **需確認** |

**reef-b-app 實際值**:
- `record`: "Schedule"
- `led_scene`: "Scene"
- `unassigned_device`: "Unallocated Devices"

**建議修復**:
```dart
// 需要在 app_localizations.dart 中添加：
String get record;
String get ledScene;
String get unassignedDevice;
String get ledSceneNoSetting; // 新增
```

---

#### 1.6 Dosing Main Page (`dosing_main_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 460 | `'未設定'` | `@string/drop_record_type_none` | ❌ **不一致** |
| Line 614 | `'已排程'` | 需要根據模式判斷 | ⚠️ **需確認** |
| Line 616 | `'自由模式'` | `@string/drop_record_type_custom` | ❌ **不一致** |

**reef-b-app 實際值**:
- `drop_record_type_none`: "No Scheduled Tasks"
- `drop_record_type_custom`: "Free Mode"

**建議修復**: 使用正確的本地化鍵值。

---

#### 1.7 LED Record Page (`led_record_page.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 385 | `'時間'` | `@string/time` | ❌ **缺失** |

---

#### 1.8 Home Controller (`home_controller.dart`)

| 位置 | 當前值 | reef-b-app 鍵值 | 狀態 |
|------|--------|----------------|------|
| Line 54 | `'All Sinks'` | `@string/home_spinner_all_sink` | ❌ **缺失** |
| Line 55 | `'Favorite'` | `@string/home_spinner_favorite` | ❌ **缺失** |
| Line 63 | `'Unassigned'` | `@string/home_spinner_unassigned` | ❌ **缺失** |

**reef-b-app 實際值**:
- `home_spinner_all_sink`: "All Tanks"
- `home_spinner_favorite`: "Favorite devices" (引用 `@string/favorite_device`)
- `home_spinner_unassigned`: "Unallocated Devices" (引用 `@string/unassigned_device`)

**建議修復**:
```dart
// 需要在 app_localizations.dart 中添加：
String get homeSpinnerAllSink;
String get homeSpinnerFavorite;
String get homeSpinnerUnassigned;
```

---

### 2. 已存在但未使用的本地化鍵值

以下鍵值在 koralcore 中已存在，但代碼中使用硬編碼字符串：

| 鍵值 | 當前使用位置 | 應該使用 |
|------|-------------|---------|
| `sectionLedTitle` | `bluetooth_page.dart` Line 340 | ✅ 已使用 |
| `sectionDosingTitle` | `bluetooth_page.dart` Line 341 | ✅ 已使用 |

---

## 🎨 圖標資源審計

### 1. 缺失的圖標資源

#### 1.1 LED Master Setting Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 238 | `'assets/icons/ic_master_big.png'` | `@drawable/ic_master_big` | ❌ **缺失** |
| Line 251 | `'assets/icons/ic_menu.png'` | `@drawable/ic_menu` | ❌ **缺失** |

**reef-b-app 使用**: 
- `ic_master_big`: 20×20dp 圖標
- `ic_menu`: 24×24dp 圖標

---

#### 1.2 Dosing Record Setting Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 780 | `'assets/icons/ic_drop.png'` | 未找到對應資源 | ⚠️ **需確認** |

---

#### 1.3 Drop Type Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 199 | `'assets/icons/ic_edit.png'` | `@drawable/ic_edit` | ❌ **缺失** |

---

#### 1.4 Dosing Main Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 444 | `'assets/icons/dosing/img_drop_head_*.png'` | 未找到對應資源 | ⚠️ **需確認** |
| Line 494 | `'assets/icons/ic_play_enabled.png'` | 未找到對應資源 | ⚠️ **需確認** |

---

#### 1.5 LED Scene List Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 389-390 | `'assets/icons/ic_play_*.png'` | 未找到對應資源 | ⚠️ **需確認** |
| Line 412-413 | `'assets/icons/ic_favorite_*.png'` | `@drawable/ic_favorite_*` | ❌ **缺失** |

**reef-b-app 使用**:
- `ic_favorite_select`: 已選中的喜愛圖標
- `ic_favorite_unselect`: 未選中的喜愛圖標

---

#### 1.6 LED Record Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 652 | `'assets/icons/ic_more_enable.png'` | 未找到對應資源 | ⚠️ **需確認** |

---

#### 1.7 Sink Manager Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 301 | `'assets/icons/ic_edit.png'` | `@drawable/ic_edit` | ❌ **缺失** |

---

#### 1.8 Bluetooth Page

| 位置 | 當前值 | reef-b-app 資源 | 狀態 |
|------|--------|----------------|------|
| Line 514 | `'assets/icons/ic_master.png'` | `@drawable/ic_master` | ❌ **缺失** |
| Line 532-533 | `'assets/icons/ic_connect_*.png'` | `@drawable/ic_connect_background` / `@drawable/ic_disconnect_background` | ❌ **缺失** |

**reef-b-app 使用**:
- `ic_master`: Master 設備圖標
- `ic_connect_background`: 已連接狀態背景圖標
- `ic_disconnect_background`: 未連接狀態背景圖標

---

### 2. 圖標使用不一致

#### 2.1 Scene Icons

| 位置 | 當前值 | reef-b-app 使用 | 狀態 |
|------|--------|----------------|------|
| `led_scene_delete_page.dart` Line 267 | `Icons.light_mode` | Scene-specific icons based on `iconId` | ⚠️ **需實現** |
| `led_main_page.dart` Line 921 | `Icons.favorite` | Scene-specific icons | ⚠️ **需實現** |

**分析**: reef-b-app 使用場景特定的圖標（如 `ic_none`, `ic_custom` 等），需要根據 `scene.iconId` 動態選擇。

---

## 📊 統計摘要

### 本地化字符串

| 類別 | 數量 | 狀態 |
|------|------|------|
| 缺失的鍵值 | 8 | ❌ 需要添加 |
| 需確認的鍵值 | 6 | ⚠️ 需要驗證 |
| 已存在但未使用 | 0 | ✅ 無問題 |

### 圖標資源

| 類別 | 數量 | 狀態 |
|------|------|------|
| 缺失的圖標 | 10 | ❌ 需要添加 |
| 需確認的圖標 | 5 | ⚠️ 需要驗證 |
| 使用不一致 | 2 | ⚠️ 需要修復 |

---

## 🔧 修復建議

### 優先級 1（高優先級）

1. **添加缺失的本地化鍵值**:
   - `group`
   - `led`
   - `masterSlave`
   - `time`
   - `record`
   - `ledScene`

2. **添加缺失的圖標資源**:
   - `ic_master_big.png`
   - `ic_menu.png`
   - `ic_edit.png`
   - `ic_master.png`
   - `ic_favorite_select.png`
   - `ic_favorite_unselect.png`
   - `ic_connect_background.png`
   - `ic_disconnect_background.png`

### 優先級 2（中優先級）

1. **驗證並添加需確認的本地化鍵值**:
   - 日期相關鍵值
   - 體積相關鍵值
   - "無設定"相關鍵值

2. **實現場景圖標動態選擇邏輯**:
   - 根據 `scene.iconId` 選擇對應圖標
   - 實現圖標映射表

### 優先級 3（低優先級）

1. **驗證並添加需確認的圖標資源**:
   - Dosing pump head 圖標
   - Play 按鈕圖標
   - More 按鈕圖標

---

## ✅ 下一步行動

1. **立即執行**: 添加高優先級的本地化鍵值和圖標資源
2. **短期執行**: 驗證並修復中優先級項目
3. **長期執行**: 完善低優先級項目並進行視覺回歸測試

---

**報告生成時間**: 2024-12-28  
**審計人員**: AI Assistant  
**狀態**: 待修復

