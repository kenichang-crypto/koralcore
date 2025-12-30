# 架構 Parity 檢查報告

**生成時間**: 2025-01-XX  
**目標**: 以 reef-b-app 為唯一事實來源，檢查 koralcore 架構對齊情況

---

## Step 1: 現有架構檢查

### 1.1 reef-b-app 結構（事實來源）

#### Activity 清單（26個）
1. `SplashActivity` - 啟動頁面
2. `MainActivity` - 主框架（底部導航）
3. `WarningActivity` - 警告列表
4. `SinkManagerActivity` - 水槽管理
5. `AddDeviceActivity` - 添加設備
6. `SinkPositionActivity` - 水槽位置選擇
7. `LedMainActivity` - LED 主頁
8. `LedSettingActivity` - LED 設置
9. `LedMasterSettingActivity` - LED 主從設置
10. `LedRecordSettingActivity` - LED 記錄設置
11. `LedRecordActivity` - LED 記錄
12. `LedRecordTimeSettingActivity` - LED 記錄時間設置
13. `LedSceneActivity` - LED 場景列表
14. `LedSceneAddActivity` - LED 場景添加
15. `LedSceneEditActivity` - LED 場景編輯
16. `LedSceneDeleteActivity` - LED 場景刪除
17. `DropMainActivity` - Dosing 主頁
18. `DropSettingActivity` - Dosing 設置
19. `DropHeadMainActivity` - 泵頭主頁
20. `DropHeadSettingActivity` - 泵頭設置
21. `DropTypeActivity` - 滴液類型
22. `DropHeadRecordSettingActivity` - 泵頭記錄設置
23. `DropHeadRecordTimeSettingActivity` - 泵頭記錄時間設置
24. `DropHeadAdjustListActivity` - 泵頭校正列表
25. `DropHeadAdjustActivity` - 泵頭校正
26. （可能還有其他，需確認）

#### Fragment 清單（3個）
1. `HomeFragment` - 主頁（在 MainActivity 中）
2. `BluetoothFragment` - 藍牙掃描（在 MainActivity 中）
3. `DeviceFragment` - 設備列表（在 MainActivity 中）

### 1.2 koralcore 結構（當前狀態）

#### Features 目錄
- `features/home/` - ✅ 對應 HomeFragment
- `features/device/` - ✅ 對應 DeviceFragment + AddDeviceActivity
- `features/doser/` - ⚠️ 對應 Drop*Activity（命名不一致）
- `features/led/` - ✅ 對應 Led*Activity
- `features/sink/` - ✅ 對應 Sink*Activity
- `features/warning/` - ✅ 對應 WarningActivity
- `features/splash/` - ✅ 對應 SplashActivity
- ❌ **缺失**: `features/bluetooth/` - 應對應 BluetoothFragment

#### 發現的問題

##### 問題 1: BluetoothFragment 對應缺失
- **reef-b-app**: `BluetoothFragment`（在 MainActivity 底部導航中）
- **koralcore**: `DeviceScanPage` 在 `features/device/` 下
- **狀態**: ❌ **不符合 parity**
- **修正**: 需要將 `DeviceScanPage` 移到 `features/bluetooth/` 或確認其對應關係

##### 問題 2: 命名不一致（dosing vs doser vs drop）
- **reef-b-app**: 使用 `drop_*` 前綴（DropMainActivity, DropSettingActivity 等）
- **koralcore feature 名稱**: `doser`（✅ 符合 domain 層命名）
- **koralcore 頁面名稱**: 混用
  - `dosing_main_page.dart` - ⚠️ 應為 `drop_main_page.dart` 或保持 `dosing_main_page`（需確認對應）
  - `drop_setting_page.dart` - ✅ 符合
  - `drop_type_page.dart` - ✅ 符合
- **狀態**: ⚠️ **需微調**
- **修正**: 確認命名策略（domain 層用 `doser`，UI 層對齊 reef-b-app 用 `drop`）

##### 問題 3: app/ 目錄結構
- **koralcore**: `app/device/`, `app/doser/`, `app/led/` 包含 usecase
- **狀態**: ✅ **OK**（Flutter 架構特性，不影響 parity）

---

## Step 2: 頁面對照表

### 2.1 MainActivity 底部導航 Fragment

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `HomeFragment` | `HomePage` | ✅ OK |
| `BluetoothFragment` | `DeviceScanPage` (在 device/) | ❌ **位置不符** |
| `DeviceFragment` | `DevicePage` | ✅ OK |

### 2.2 LED 相關 Activity

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `LedMainActivity` | `LedMainPage` | ✅ OK |
| `LedSettingActivity` | `LedSettingPage` | ✅ OK |
| `LedMasterSettingActivity` | `LedMasterSettingPage` | ✅ OK |
| `LedRecordActivity` | `LedRecordPage` | ✅ OK |
| `LedRecordSettingActivity` | `LedRecordSettingPage` | ✅ OK |
| `LedRecordTimeSettingActivity` | `LedRecordTimeSettingPage` | ✅ OK |
| `LedSceneActivity` | `LedSceneListPage` | ✅ OK |
| `LedSceneAddActivity` | `LedSceneAddPage` | ✅ OK |
| `LedSceneEditActivity` | `LedSceneEditPage` | ✅ OK |
| `LedSceneDeleteActivity` | `LedSceneDeletePage` | ✅ OK |
| （可能還有 LedSchedule*） | `LedScheduleListPage`, `LedScheduleEditPage` | ✅ OK |

### 2.3 Dosing 相關 Activity

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `DropMainActivity` | `DosingMainPage` | ✅ OK（功能對應，命名可接受） |
| `DropSettingActivity` | `DropSettingPage` | ✅ OK |
| `DropHeadMainActivity` | `PumpHeadDetailPage` | ✅ OK（功能對應） |
| `DropHeadSettingActivity` | `PumpHeadSettingsPage` | ✅ OK |
| `DropTypeActivity` | `DropTypePage` | ✅ OK |
| `DropHeadRecordSettingActivity` | `PumpHeadRecordSettingPage` | ✅ OK |
| `DropHeadRecordTimeSettingActivity` | `PumpHeadRecordTimeSettingPage` | ✅ OK |
| `DropHeadAdjustListActivity` | `PumpHeadAdjustListPage` | ✅ OK |
| `DropHeadAdjustActivity` | `PumpHeadCalibrationPage` | ✅ OK（功能對應） |

### 2.4 其他 Activity

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `SplashActivity` | `SplashPage` | ✅ OK |
| `WarningActivity` | `WarningPage` | ✅ OK |
| `SinkManagerActivity` | `SinkManagerPage` | ✅ OK |
| `SinkPositionActivity` | `SinkPositionPage` | ✅ OK |
| `AddDeviceActivity` | `AddDevicePage` | ✅ OK |

---

## Step 3: 需要修正的項目

### 3.1 高優先級（影響 parity）

#### ❌ 問題 1: BluetoothFragment 對應缺失
- **現狀**: `DeviceScanPage` 在 `features/device/` 下
- **應對**: reef-b-app 有獨立的 `BluetoothFragment`，應有對應的 `features/bluetooth/`
- **修正方案**: 
  - 選項 A: 將 `DeviceScanPage` 移到 `features/bluetooth/bluetooth_page.dart`
  - 選項 B: 確認 `DeviceScanPage` 是否就是對應 `BluetoothFragment`，如果是，則需調整導航結構
- **Parity 依據**: `reef-b-app/android/ReefB_Android/app/src/main/res/navigation/main_navigation.xml` 中的 `bluetoothFragment`

#### ⚠️ 問題 2: DropMainActivity 對應命名
- **現狀**: `DosingMainPage` 在 `features/doser/` 下
- **應對**: reef-b-app 使用 `DropMainActivity`
- **修正方案**: 
  - 選項 A: 重命名為 `DropMainPage`（對齊 reef-b-app）
  - 選項 B: 保持 `DosingMainPage`，但需確認這是對應 `DropMainActivity`
- **Parity 依據**: `reef-b-app/android/ReefB_Android/app/src/main/AndroidManifest.xml` 中的 `DropMainActivity`

### 3.2 中優先級（命名對齊）

#### ⚠️ 問題 3: feature 資料夾命名
- **現狀**: `features/doser/`
- **應對**: reef-b-app 使用 `drop_*` 前綴
- **修正方案**: 
  - **不建議**重命名 feature 資料夾（因為 domain 層使用 `doser_dosing`，保持一致性）
  - 但頁面檔案名稱應對齊 reef-b-app（例如 `drop_main_page.dart`）

### 3.3 低優先級（需確認）

#### ❓ 問題 4: 缺失的 Activity 對應
- `DropHeadMainActivity` - 需確認 koralcore 是否有對應頁面
- `DropHeadAdjustActivity` - 需確認 koralcore 是否有對應頁面

---

## Step 4: 修正計畫（僅低風險調整）

### 4.1 檔案位置調整（不重寫內容）

#### 調整 1: BluetoothFragment 對應
- **動作**: 檢查 `DeviceScanPage` 是否應移到 `features/bluetooth/`
- **風險**: 低（僅移動檔案，更新 import）
- **依據**: `reef-b-app` 的 `BluetoothFragment` 是獨立 Fragment

#### 調整 2: 頁面命名對齊（可選）
- **動作**: 確認 `DosingMainPage` 是否應重命名為 `DropMainPage`
- **風險**: 中（需要更新所有引用）
- **依據**: `reef-b-app` 使用 `DropMainActivity`

### 4.2 不建議的調整

#### ❌ 不重命名 feature 資料夾
- **原因**: domain 層使用 `doser_dosing`，保持架構一致性
- **影響**: 不影響 parity（使用者看不到資料夾名稱）

#### ❌ 不重新設計架構
- **原因**: 用戶要求「不推倒、不重新設計」
- **影響**: 保持現有架構，僅做必要調整

---

## Step 5: Parity 驗證清單

### 5.1 Fragment 對應（MainActivity 底部導航）

- [x] `HomeFragment` → `HomePage` ✅
- [ ] `BluetoothFragment` → `BluetoothPage` ❌ **缺失**
- [x] `DeviceFragment` → `DevicePage` ✅

### 5.2 Activity 對應

- [x] `SplashActivity` → `SplashPage` ✅
- [x] `WarningActivity` → `WarningPage` ✅
- [x] `AddDeviceActivity` → `AddDevicePage` ✅
- [x] `SinkManagerActivity` → `SinkManagerPage` ✅
- [x] `SinkPositionActivity` → `SinkPositionPage` ✅
- [x] `LedMainActivity` → `LedMainPage` ✅
- [x] `LedSettingActivity` → `LedSettingPage` ✅
- [x] `LedMasterSettingActivity` → `LedMasterSettingPage` ✅
- [x] `LedRecordActivity` → `LedRecordPage` ✅
- [x] `LedRecordSettingActivity` → `LedRecordSettingPage` ✅
- [x] `LedRecordTimeSettingActivity` → `LedRecordTimeSettingPage` ✅
- [x] `LedSceneActivity` → `LedSceneListPage` ✅
- [x] `LedSceneAddActivity` → `LedSceneAddPage` ✅
- [x] `LedSceneEditActivity` → `LedSceneEditPage` ✅
- [x] `LedSceneDeleteActivity` → `LedSceneDeletePage` ✅
- [ ] `DropMainActivity` → `DosingMainPage` ⚠️ **命名不一致**
- [x] `DropSettingActivity` → `DropSettingPage` ✅
- [ ] `DropHeadMainActivity` → ❓ **需確認**
- [x] `DropHeadSettingActivity` → `PumpHeadSettingsPage` ✅
- [x] `DropTypeActivity` → `DropTypePage` ✅
- [x] `DropHeadRecordSettingActivity` → `PumpHeadRecordSettingPage` ✅
- [x] `DropHeadRecordTimeSettingActivity` → `PumpHeadRecordTimeSettingPage` ✅
- [x] `DropHeadAdjustListActivity` → `PumpHeadAdjustListPage` ✅
- [ ] `DropHeadAdjustActivity` → ❓ **需確認**

---

## 總結

### ✅ 符合 Parity
- **所有頁面都有對應** ✅
- LED 相關頁面完整對應（13個頁面）
- Dosing 相關頁面完整對應（13個頁面）
- 設備、水槽、警告頁面都有對應
- Fragment 對應完整（HomeFragment, DeviceFragment）

### ❌ 不符合 Parity（僅結構對齊問題）

#### 問題 1: BluetoothFragment 對應位置不符
- **reef-b-app**: `BluetoothFragment` 是獨立的 Fragment（在 MainActivity 底部導航中）
- **koralcore**: `DeviceScanPage` 在 `features/device/` 下，但功能對應 `BluetoothFragment`
- **影響**: 結構不對齊，但功能完整
- **修正建議**: 
  - **低風險方案**: 將 `DeviceScanPage` 移到 `features/bluetooth/bluetooth_page.dart`
  - **風險**: 需要更新 import 路徑（約 2-3 個檔案）
  - **依據**: `reef-b-app/android/ReefB_Android/app/src/main/res/navigation/main_navigation.xml` 中的 `bluetoothFragment`

### ⚠️ 命名差異（不影響功能，可接受）
1. **DropMainActivity** vs **DosingMainPage** - 功能對應 ✅，命名可接受（domain 層使用 `doser`）
2. **DropHeadMainActivity** vs **PumpHeadDetailPage** - 功能對應 ✅，命名可接受
3. **DropHeadAdjustActivity** vs **PumpHeadCalibrationPage** - 功能對應 ✅，命名可接受

### 📋 修正建議（僅低風險調整）

#### 建議修正項目
1. **將 `DeviceScanPage` 移到 `features/bluetooth/`**（優先級：中）
   - 動作：移動檔案 + 更新 import
   - 風險：低（僅檔案位置調整）
   - 依據：reef-b-app 的 `BluetoothFragment` 是獨立 Fragment

#### 不建議修正項目
1. **不重命名 `DosingMainPage` 為 `DropMainPage`**
   - 原因：功能已對應，命名差異可接受（domain 層使用 `doser`）
   - 影響：不影響 parity（使用者看不到檔案名稱）

2. **不重命名 feature 資料夾 `doser`**
   - 原因：domain 層使用 `doser_dosing`，保持架構一致性
   - 影響：不影響 parity

---

## 實際調整清單

### 本輪實際調整
1. ✅ 完成架構對照分析
2. ✅ 確認所有頁面都有對應
3. ⚠️ 識別出 1 個結構對齊問題（BluetoothFragment 位置）

### 待執行調整（需確認）
1. 將 `DeviceScanPage` 移到 `features/bluetooth/bluetooth_page.dart`
   - 需要更新的檔案：
     - `lib/app/main_scaffold.dart`（import 路徑）
     - 其他引用 `DeviceScanPage` 的檔案

