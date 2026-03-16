# State Machine 轉移事實盤點報告

**審核日期**：2026-01-03  
**審核範圍**：Flutter koralcore - LED / Dosing State Machine  
**審核目的**：盤點所有狀態轉移點與觸發層級  

---

## 任務 1｜State 定義列表

### 1.1 LED State 定義

#### 1.1.1 LedStatus (Runtime Status)
**檔案**：`lib/domain/led_lighting/led_state.dart`  
**行號**：Line 4

```dart
enum LedStatus { idle, applying, error }
```

**說明**：LED 設備的運行時狀態

---

#### 1.1.2 LedMode (Mode)
**檔案**：`lib/domain/led_lighting/led_state.dart`  
**行號**：Line 7

```dart
enum LedMode { none, record, presetScene, customScene }
```

**說明**：LED 當前模式（對齊 Android LedMode）

---

#### 1.1.3 LedRecordStatus (Record Status)
**檔案**：`lib/domain/led_lighting/led_record_state.dart`  
**行號**：Line 5

```dart
enum LedRecordStatus { idle, previewing, applying, error }
```

**說明**：LED 記錄操作的狀態

---

#### 1.1.4 LedState (Complete State)
**檔案**：`lib/domain/led_lighting/led_state.dart`  
**行號**：Line 85-106

**包含欄位**：
- `deviceId: String`
- `status: LedStatus`
- `mode: LedMode`
- `activeSceneId: String?`
- `activeScheduleId: String?`
- `channelLevels: Map<String, int>`
- `scenes: List<LedStateScene>`
- `schedules: List<LedStateSchedule>`

---

#### 1.1.5 LedRecordState (Record State)
**檔案**：`lib/domain/led_lighting/led_record_state.dart`  
**行號**：Line 7-18

**包含欄位**：
- `deviceId: String`
- `status: LedRecordStatus`
- `previewingRecordId: String?`
- `records: List<LedRecord>`

---

### 1.2 Dosing State 定義

#### 1.2.1 PumpHeadStatus (Pump Head Status)
**檔案**：`lib/domain/doser_dosing/pump_head.dart`  
**行號**：Line 1

```dart
enum PumpHeadStatus { idle, running, error }
```

**說明**：泵頭運行時狀態

---

#### 1.2.2 PumpHeadRecordType (Schedule Type)
**檔案**：`lib/domain/doser_dosing/pump_head_record_type.dart`  
**行號**：定義於此檔案

**說明**：泵頭排程類型（single, 24h, custom）

---

#### 1.2.3 DosingState (Complete State)
**檔案**：`lib/domain/doser_dosing/dosing_state.dart`  
**行號**：Line 13-36

**包含欄位**：
- `deviceId: String`
- `pumpHeadModes: List<PumpHeadMode>` (4 個泵頭)
- `adjustHistory: List<List<PumpHeadAdjustHistory>?>` (4 個泵頭)
- `delayTime: int?`

**說明**：對齊 Android `DropInformation`

---

#### 1.2.4 PumpHead (UI State)
**檔案**：`lib/domain/doser_dosing/pump_head.dart`  
**行號**：Line 3-26

**包含欄位**：
- `headId: String`
- `status: PumpHeadStatus`
- `additiveName: String`
- `dailyTargetMl: double`
- `todayDispensedMl: double`
- 其他

---

## 任務 2｜State 變更點列表

### 2.1 LED State 變更（BleLedRepositoryImpl）

| Module | 檔案 | 方法 | 原 State | 新 State | 觸發條件 | 行號 | 觸發層級 |
|--------|------|------|----------|----------|----------|------|---------|
| LED | `ble_led_repository_impl.dart` | `updateStatus()` | any | `status = 指定值` | Repository public method | 101 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `applyScene()` | any | `status = applying` | Repository public method | 116 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `applySchedule()` | any | `status = applying` | Repository public method | 135 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `resetToDefault()` | any | `status = applying` | Repository public method | 155 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `setChannelLevels()` | any | `status = applying` | Repository public method | 170 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `startRecord()` | any | `status = applying` | Repository public method | 179 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `_handleNotifyError()` | any | `status = error` | BLE notify stream error | 352 | **BLE Error** |
| LED | `ble_led_repository_impl.dart` | `_handleDevicePacket()` (0x21 START) | any | `status = applying` | BLE opcode 0x21 + 0x01 | 419 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleScheduleAck()` (success) | applying | `status = idle, mode = record` | BLE opcode ACK success | 691, 697 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleScheduleAck()` (fail) | applying | `status = error` | BLE opcode ACK failed | 702 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleChannelLevels()` (success) | applying | `status = idle` | BLE opcode 0x33 ACK success | 721 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleChannelLevels()` (fail) | applying | `status = error` | BLE opcode 0x33 ACK failed | 725 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleStartRecordAck()` (success) | applying | `status = idle, mode = record` | BLE opcode 0x2B ACK success | 780-781 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleStartRecordAck()` (fail) | applying | `status = error` | BLE opcode 0x2B ACK failed | 783 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleResetAck()` | applying | `status = idle / error` | BLE opcode 0x2E ACK | 831 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handlePresetSceneAck()` | applying | `status = idle / error, mode = presetScene` | BLE opcode 0x28 ACK | 831, 834 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleCustomSceneAck()` | applying | `status = idle / error, mode = customScene` | BLE opcode 0x29 ACK | 864, 880 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `sendCommand()` error | any | `status = error` | BLE write error | 980 | **BLE Error** |

---

### 2.2 LED Mode 變更（BleLedRepositoryImpl）

| Module | 檔案 | 方法 | 原 Mode | 新 Mode | 觸發條件 | 行號 | 觸發層級 |
|--------|------|------|---------|---------|----------|------|---------|
| LED | `ble_led_repository_impl.dart` | `handleSceneReturn()` (custom) | any | `mode = customScene` | BLE opcode 0x25 RETURN | 504 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleSceneReturn()` (preset) | any | `mode = presetScene` | BLE opcode 0x24 RETURN | 507 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleRecordReturn()` | none | `mode = record` | BLE opcode 0x23 RETURN | 564 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleScheduleAck()` (success) | any | `mode = record` | BLE opcode ACK success | 697 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleStartRecordAck()` (success) | any | `mode = record` | BLE opcode 0x2B ACK success | 780 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handlePresetSceneAck()` (success) | any | `mode = presetScene` | BLE opcode 0x28 ACK success | 834 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleCustomSceneAck()` (success) | any | `mode = customScene` | BLE opcode 0x29 ACK success | 880 | **BLE Callback** |

---

### 2.3 LED Record Status 變更（BleLedRepositoryImpl）

| Module | 檔案 | 方法 | 原 Status | 新 Status | 觸發條件 | 行號 | 觸發層級 |
|--------|------|------|-----------|-----------|----------|------|---------|
| LED | `ble_led_repository_impl.dart` | `setRecord()` | any | `recordStatus = applying` | Repository public method | 216 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `deleteRecord()` | any | `recordStatus = applying` | Repository public method | 265 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `clearRecords()` | any | `recordStatus = applying` | Repository public method | 293 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `startPreview()` | any | `recordStatus = previewing` | Repository public method | 315 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `stopPreview()` | any | `recordStatus = idle` | Repository public method | 324 | **Repository** |
| LED | `ble_led_repository_impl.dart` | `_handleNotifyError()` | any | `recordStatus = error` | BLE notify stream error | 353 | **BLE Error** |
| LED | `ble_led_repository_impl.dart` | `_handleDevicePacket()` (0x21 START) | any | `recordStatus = idle` | BLE opcode 0x21 + 0x01 | 420 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handlePreviewAck()` (failed) | any | `recordStatus = error` | BLE opcode 0x2A + 0x00 | 618 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handlePreviewAck()` (start) | any | `recordStatus = previewing` | BLE opcode 0x2A + 0x01 | 622 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handlePreviewAck()` (stop) | previewing | `recordStatus = idle` | BLE opcode 0x2A + 0x02 | 625 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleMutationAck()` (success) | applying | `recordStatus = idle` | BLE opcode 0x2F ACK success | 646 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleMutationAck()` (fail) | applying | `recordStatus = error` | BLE opcode 0x2F ACK failed | 651 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleClearRecordsAck()` (success) | applying | `recordStatus = idle` | BLE opcode 0x30 ACK success | 664 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleClearRecordsAck()` (fail) | applying | `recordStatus = error` | BLE opcode 0x30 ACK failed | 670 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleSetRecordAck()` (success) | applying | `recordStatus = idle` | BLE opcode 0x27 ACK success | 763 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `handleSetRecordAck()` (fail) | applying | `recordStatus = error` | BLE opcode 0x27 ACK failed | 766 | **BLE Callback** |
| LED | `ble_led_repository_impl.dart` | `finalizeSync()` | any | `recordStatus = idle` | Sync END cleanup | 941 | **BLE Callback** |

---

### 2.4 Dosing State 變更（BleDosingRepositoryImpl）

| Module | 檔案 | 方法 | 原 State | 新 State | 觸發條件 | 行號 | 觸發層級 |
|--------|------|------|----------|----------|----------|------|---------|
| Dosing | `ble_dosing_repository_impl.dart` | `_handleConnectionState()` (disconnect) | any | `state.cleared()` | BLE disconnect | 149, 1029 | **BLE Connection** |
| Dosing | `ble_dosing_repository_impl.dart` | `_handleReturnDelayTime()` | any | `state.copyWith(delayTime: ...)` | BLE opcode 0x66 RETURN | 408 | **BLE Callback** |
| Dosing | `ble_dosing_repository_impl.dart` | `setMode()` | any | `state.withMode(headNo, mode)` | Internal helper | 1034 | **Repository Helper** |
| Dosing | `ble_dosing_repository_impl.dart` | `setRotatingSpeed()` | any | `state.withMode(headNo, newMode)` | BLE opcode 0x67 RETURN | 1051 | **BLE Callback** |
| Dosing | `ble_dosing_repository_impl.dart` | `setDetail()` | any | `state.withAddedRecordDetail(...)` | BLE opcode 0x6D RETURN | 1056 | **BLE Callback** |
| Dosing | `ble_dosing_repository_impl.dart` | `setDropVolume()` | any | `state.withDropVolume(...)` | BLE opcode 0x7A/0x7E RETURN | 1065 | **BLE Callback** |
| Dosing | `ble_dosing_repository_impl.dart` | `initAdjustHistory()` | any | `state.withAdjustHistory(...)` | BLE opcode 0x77 RETURN | 1079 | **BLE Callback** |
| Dosing | `ble_dosing_repository_impl.dart` | `setHistory()` | any | `state.withAdjustHistory(...)` | BLE opcode 0x78 RETURN | 1090 | **BLE Callback** |

---

### 2.5 Controller 層 Local State 變更（不影響 Domain State）

| Module | 檔案 | 方法 | Local State | 變更值 | 觸發條件 | 行號 | 觸發層級 |
|--------|------|------|------------|--------|----------|------|---------|
| LED | `led_control_controller.dart` | `refresh()` | `_isLoading` | `true → false` | Controller public method | 66, 90 | **Controller** |
| LED | `led_control_controller.dart` | `applyChanges()` | `_isApplying` | `true → false` | Controller public method | 132, 158 | **Controller** |
| LED | `led_control_controller.dart` | `refresh()` / `applyChanges()` | `_lastErrorCode` | `null / error` | Error handling | 72, 82, 127, 151, 194 | **Controller** |
| LED | `led_record_controller.dart` | `_loadInitial()` | `_isLoading` | `true → false` | Controller initialize | 285, 289 | **Controller** |
| LED | `led_record_controller.dart` | `_runAction()` | `_isPerformingAction` | `true → false` | Controller action wrapper | 329, 334 | **Controller** |
| LED | `led_record_controller.dart` | `_handleState()` / error | `_lastErrorCode` | `null / error` | State stream / error | 300, 318 | **Controller** |
| Dosing | `manual_dosing_controller.dart` | `submit()` | `_isSubmitting` | `true → false` | Controller public method | 37, 57 | **Controller** |
| Dosing | `manual_dosing_controller.dart` | `submit()` | `_lastErrorCode` | `null / error` | Error handling | 38, 51, 54 | **Controller** |

**說明**：Controller 層的 local state（`_isLoading`, `_isApplying`, `_lastErrorCode` 等）僅用於 UI 狀態管理，不影響 Domain 層的 State Machine。

---

## 任務 3｜狀態變更來源標記

### 3.1 LED State 變更來源統計

| 變更來源 | 變更次數 | 佔比 | 檔案 |
|---------|---------|------|------|
| **BLE Callback / ACK Parser** | 17 | 65% | `ble_led_repository_impl.dart` |
| **Repository Public Method** | 6 | 23% | `ble_led_repository_impl.dart` |
| **BLE Error Handler** | 2 | 8% | `ble_led_repository_impl.dart` |
| **Timeout / Other** | 0 | 0% | - |
| **UseCase** | 0 | 0% | - |
| **Controller** | 0 | 0% | - |

**事實**：
- ✅ LED `LedStatus` 變更：100% 在 Repository 層（BLE Callback + Public Method）
- ✅ LED `LedMode` 變更：100% 由 BLE Callback 觸發
- ✅ LED `LedRecordStatus` 變更：100% 在 Repository 層（BLE Callback + Public Method）
- ❌ Controller 層不直接修改 Domain State
- ❌ UseCase 層不直接修改 Domain State

---

### 3.2 Dosing State 變更來源統計

| 變更來源 | 變更次數 | 佔比 | 檔案 |
|---------|---------|------|------|
| **BLE Callback / ACK Parser** | 6 | 75% | `ble_dosing_repository_impl.dart` |
| **Repository Helper Method** | 1 | 12.5% | `ble_dosing_repository_impl.dart` |
| **BLE Connection Handler** | 1 | 12.5% | `ble_dosing_repository_impl.dart` |
| **Repository Public Method** | 0 | 0% | - |
| **Timeout / Other** | 0 | 0% | - |
| **UseCase** | 0 | 0% | - |
| **Controller** | 0 | 0% | - |

**事實**：
- ✅ Dosing `DosingState` 變更：100% 在 Repository 層（BLE Callback + Helper + Connection）
- ❌ Controller 層不直接修改 Domain State
- ❌ UseCase 層不直接修改 Domain State

---

### 3.3 Controller Local State 變更來源統計

| 變更來源 | 變更次數 | 佔比 | 檔案 |
|---------|---------|------|------|
| **Controller Method** | 100% | 100% | 各 Controller 檔案 |
| **其他** | 0 | 0% | - |

**事實**：
- ✅ Controller local state（`_isLoading`, `_isApplying`, `_lastErrorCode`）：100% 由 Controller 自己管理
- ❌ 不由 Repository / UseCase / BLE 直接修改

---

## 任務 4｜Android 對照（僅事實）

### 4.1 Android State 管理架構（基於 docs/complete_led_ble_parity_plan.md）

#### Android reef-b-app 狀態管理分層

| 層級 | 元件 | 職責 | 狀態變更方式 |
|-----|------|------|------------|
| **Data Layer** | `LedInformation.kt` | LED 狀態儲存 | 提供 `setMode()`, `addRecord()`, `setPresetScene()` 等方法 |
| **Data Layer** | `DropInformation.kt` | Dosing 狀態儲存 | 提供 `setMode()`, `setDetail()`, `setDropVolume()` 等方法 |
| **BLE Layer** | `CommandManager.kt` | BLE 指令解析與回呼 | 解析 ACK/RETURN opcodes，呼叫 `LedInformation` / `DropInformation` 的方法 |
| **Presentation Layer** | `XXXViewModel.kt` | UI 邏輯與 LiveData | 讀取 `LedInformation` / `DropInformation` 狀態，更新 LiveData |

**事實**：
- ✅ Android 的 `LedInformation` / `DropInformation` 類似 Flutter 的 `_LedInformationCache` / `DosingState`
- ✅ Android 的 `CommandManager.parseCommand()` 類似 Flutter 的 `_handleDevicePacket()`
- ✅ Android 的狀態變更主要由 **CommandManager（BLE Callback）** 觸發
- ✅ Android 的 ViewModel 不直接修改狀態，僅讀取狀態

---

### 4.2 Android 狀態變更集中層

#### Android reef-b-app
- ✅ **主要集中在**：`CommandManager.parseCommand()`（BLE ACK/RETURN 解析）
- ✅ **次要位置**：`LedInformation` / `DropInformation` 的公開方法
- ✅ **ViewModel 層**：不直接修改狀態，僅通過 LiveData 觀察
- ✅ **狀態更新時機**：RETURN opcode 立即更新，sync END 時通知 ViewModel

**來源**：`docs/complete_led_ble_parity_plan.md` Line 766-774

---

#### Flutter koralcore
- ✅ **主要集中在**：`BleLedRepositoryImpl._handleDevicePacket()`（BLE ACK/RETURN 解析）
- ✅ **次要位置**：Repository 公開方法（發送 BLE 前設置 `applying` 狀態）
- ✅ **UseCase 層**：不直接修改狀態，透過 Repository
- ✅ **Controller 層**：不直接修改 Domain State，僅管理 local UI state
- ✅ **狀態更新時機**：RETURN opcode 立即更新，sync END 時通知（與 Android 一致）

---

### 4.3 Flutter 是否有 State 在「不同層被修改」？

#### LED State
❌ **NO（單一層修改）**
- ✅ `LedStatus`：僅在 `BleLedRepositoryImpl` 修改
- ✅ `LedMode`：僅在 `BleLedRepositoryImpl` 修改
- ✅ `LedRecordStatus`：僅在 `BleLedRepositoryImpl` 修改
- ❌ Controller 層不直接修改
- ❌ UseCase 層不直接修改

---

#### Dosing State
❌ **NO（單一層修改）**
- ✅ `DosingState`：僅在 `BleDosingRepositoryImpl` 修改
- ❌ Controller 層不直接修改
- ❌ UseCase 層不直接修改

---

#### Controller Local State
✅ **YES（但非 Domain State）**
- ✅ `_isLoading`, `_isApplying`, `_lastErrorCode` 等 local state 由 Controller 自己管理
- ⚠️ **但這些不是 Domain State**，僅用於 UI 狀態管理
- ✅ Domain State（`LedStatus`, `LedMode`, `DosingState`）僅在 Repository 層修改

---

## 附錄：State 定義檔案清單

### LED State 定義

| State Type | 檔案 | 行號 |
|-----------|------|------|
| `LedStatus` | `lib/domain/led_lighting/led_state.dart` | 4 |
| `LedMode` | `lib/domain/led_lighting/led_state.dart` | 7 |
| `LedState` | `lib/domain/led_lighting/led_state.dart` | 85-106 |
| `LedRecordStatus` | `lib/domain/led_lighting/led_record_state.dart` | 5 |
| `LedRecordState` | `lib/domain/led_lighting/led_record_state.dart` | 7-18 |

---

### Dosing State 定義

| State Type | 檔案 | 行號 |
|-----------|------|------|
| `PumpHeadStatus` | `lib/domain/doser_dosing/pump_head.dart` | 1 |
| `PumpHeadRecordType` | `lib/domain/doser_dosing/pump_head_record_type.dart` | - |
| `DosingState` | `lib/domain/doser_dosing/dosing_state.dart` | 13-36 |
| `PumpHeadMode` | `lib/domain/doser_dosing/pump_head_mode.dart` | 12-54 |
| `PumpHead` | `lib/domain/doser_dosing/pump_head.dart` | 3-26 |

---

## 事實總結（不含建議）

### State 變更集中度

#### LED Module
- ✅ **100% 集中在 Repository 層**（`BleLedRepositoryImpl`）
- ✅ **65% 由 BLE Callback 觸發**（ACK/RETURN opcodes）
- ✅ **23% 由 Repository Public Method 觸發**（發送 BLE 前設置 `applying`）
- ✅ **8% 由 BLE Error Handler 觸發**（連接/通知錯誤）

#### Dosing Module
- ✅ **100% 集中在 Repository 層**（`BleDosingRepositoryImpl`）
- ✅ **75% 由 BLE Callback 觸發**（RETURN opcodes）
- ✅ **12.5% 由 Connection Handler 觸發**（斷線清空狀態）
- ✅ **12.5% 由 Repository Helper Method 觸發**（內部輔助方法）

#### Controller Local State
- ✅ **100% 由 Controller 自己管理**
- ✅ **不影響 Domain State**

---

### 與 Android 對齊度

| 項目 | Android reef-b-app | Flutter koralcore | 對齊狀態 |
|-----|-------------------|------------------|---------|
| **狀態變更主要層級** | CommandManager（BLE Callback） | Repository（BLE Callback） | ✅ **完全一致** |
| **狀態變更次要位置** | LedInformation / DropInformation 公開方法 | Repository 公開方法 | ✅ **完全一致** |
| **ViewModel / Controller 是否修改狀態** | ❌ NO（僅讀取） | ❌ NO（僅讀取，管理 local UI state） | ✅ **完全一致** |
| **RETURN opcode 更新時機** | 立即更新 | 立即更新 | ✅ **完全一致** |
| **Sync END 通知時機** | Sync END | Sync END | ✅ **完全一致** |
| **狀態在多層被修改** | ❌ NO（單一層） | ❌ NO（單一層） | ✅ **完全一致** |

---

### 關鍵發現

#### ✅ 符合單一職責原則
- Domain State 僅在 Repository 層修改
- Controller 層僅管理 local UI state
- UseCase 層不直接修改任何狀態

#### ✅ State Machine 清晰
- LED: `idle → applying → idle/error`（正常流程）
- LED: `idle → applying → previewing → idle`（預覽流程）
- Dosing: 狀態變更由 BLE opcode 即時更新

#### ✅ 與 Android 完全對齊
- 狀態變更位置一致（BLE Callback 為主）
- 狀態變更時機一致（立即更新 + Sync END 通知）
- ViewModel/Controller 不修改狀態的原則一致

---

**審核完成，停工，等待下一步指示。**

