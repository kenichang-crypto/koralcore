# Controller 單一入口盤點報告

**審核日期**：2026-01-03  
**審核範圍**：Flutter koralcore - LED / Dosing Controller  
**審核目的**：確認 BLE 指令發送的入口點與架構一致性  

---

## 任務 1｜Controller 唯一入口盤點

### 1.1 LED Controllers

#### 1.1.1 LedControlController
**檔案位置**：`lib/features/led/presentation/controllers/led_control_controller.dart`

| Public Method | 是否發送 BLE | 是否改 state | 行號 | 備註 |
|--------------|-------------|-------------|------|------|
| `refresh()` | ❌ NO | ✅ YES | 65-93 | 呼叫 UseCase，不直接發 BLE |
| `updateChannel()` | ❌ NO | ✅ YES | 95-111 | 僅更新本地狀態 |
| `resetEdits()` | ❌ NO | ✅ YES | 113-118 | 僅重置本地狀態 |
| `applyChanges()` | ❌ NO | ✅ YES | 120-161 | ⭐ **唯一入口**（透過 UseCase） |
| `clearError()` | ❌ NO | ✅ YES | 163-169 | 僅清除錯誤狀態 |

**事實**：
- ✅ 唯一入口：`applyChanges()` → `setChannelIntensityUseCase.execute()`
- ❌ 不直接發送 BLE
- ✅ 透過 UseCase 層發送

---

#### 1.1.2 LedRecordController
**檔案位置**：`lib/features/led/presentation/controllers/led_record_controller.dart`

| Public Method | 是否發送 BLE | 是否改 state | 行號 | 備註 |
|--------------|-------------|-------------|------|------|
| `initialize()` | ❌ NO | ✅ YES | 79-101 | 初始化，不發 BLE |
| `refresh()` | ❌ NO | ✅ YES | 103-110 | ⭐ 呼叫 `refreshLedRecordStateUseCase` |
| `selectRecord()` | ❌ NO | ✅ YES | 116-123 | 僅更新選擇狀態 |
| `goToNextRecord()` | ❌ NO | ✅ YES | 125-145 | 僅更新選擇狀態 |
| `goToPreviousRecord()` | ❌ NO | ✅ YES | 147-174 | 僅更新選擇狀態 |
| `deleteRecord()` | ❌ NO | ✅ YES | 176-190 | ⭐ 呼叫 `deleteLedRecordUseCase` |
| `deleteSelectedRecord()` | ❌ NO | ✅ YES | 192-209 | ⭐ 呼叫 `deleteLedRecordUseCase` |
| `clearRecords()` | ❌ NO | ✅ YES | 211-223 | ⭐ 呼叫 `clearLedRecordsUseCase` |
| `togglePreview()` | ❌ NO | ✅ YES | 225-255 | ⭐ 呼叫 `startLedPreviewUseCase` |
| `clearError()` | ❌ NO | ✅ YES | 257-263 | 僅清除錯誤狀態 |
| `selectTime()` | ❌ NO | ✅ YES | 369-371 | 僅更新選擇狀態 |

**事實**：
- ✅ 多個入口，但全部透過 UseCase 層
- ❌ 不直接發送 BLE
- ✅ 所有 BLE 操作透過專用 UseCase

---

#### 1.1.3 其他 LED Controllers（未實際使用）

**檔案位置**：`lib/features/led/presentation/controllers/`

| Controller | 狀態 | 備註 |
|-----------|------|------|
| `led_scene_list_controller.dart` | ❌ 已刪除 | 見 deleted_files |
| `led_scene_edit_controller.dart` | ❌ 已刪除 | 見 deleted_files |
| `led_record_time_setting_controller.dart` | ⚠️ 存在但未連接 | Line 102-180，TODO 標註未實現 BLE |
| `led_record_setting_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `led_schedule_summary_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `led_schedule_list_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `led_master_setting_controller.dart` | ❌ 已刪除 | 見 deleted_files |

**事實**：
- 大部分舊 Controller 已被刪除或處於未使用狀態
- 現有 Controller 均標註 TODO，未實際連接 BLE

---

### 1.2 Dosing Controllers

#### 1.2.1 ManualDosingController
**檔案位置**：`lib/features/doser/presentation/controllers/manual_dosing_controller.dart`

| Public Method | 是否發送 BLE | 是否改 state | 行號 | 備註 |
|--------------|-------------|-------------|------|------|
| `submit()` | ❌ NO | ✅ YES | 25-60 | ⭐ **唯一入口**（透過 UseCase） |
| `clearError()` | ❌ NO | ✅ YES | 62-68 | 僅清除錯誤狀態 |

**事實**：
- ✅ 唯一入口：`submit()` → `singleDoseImmediateUseCase.execute()`
- ❌ 不直接發送 BLE
- ✅ 透過 UseCase 層發送

---

#### 1.2.2 其他 Dosing Controllers（未實際使用）

**檔案位置**：`lib/features/doser/presentation/controllers/`

| Controller | 狀態 | 備註 |
|-----------|------|------|
| `pump_head_adjust_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_calibration_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_settings_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_detail_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_schedule_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `drop_type_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_record_time_setting_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |
| `pump_head_record_setting_controller.dart` | ⚠️ 存在但未連接 | 無 BLE 發送邏輯 |

**事實**：
- 所有 Dosing Controllers 均處於未實際使用狀態
- 無 BLE 發送邏輯

---

### 1.3 UseCase 層（BLE 發送實際位置）

#### 1.3.1 LED UseCases

| UseCase | 是否發送 BLE | 發送方式 | 檔案位置 | 行號 |
|---------|-------------|---------|---------|------|
| `SetChannelIntensityUseCase` | ❌ NO | 呼叫 `ledRepository.setChannelLevels()` | `lib/domain/usecases/led/set_channel_intensity.dart` | 59-62 |
| `DeleteLedRecordUseCase` | ❌ NO | 呼叫 `ledRecordRepository.deleteRecord()` | - | - |
| `ClearLedRecordsUseCase` | ❌ NO | 呼叫 `ledRecordRepository.clearRecords()` | - | - |
| `StartLedPreviewUseCase` | ❌ NO | 呼叫 `ledRecordRepository.startPreview()` | - | - |
| `StopLedPreviewUseCase` | ❌ NO | 呼叫 `ledRecordRepository.stopPreview()` | - | - |
| `RefreshLedRecordStateUseCase` | ❌ NO | 呼叫 `ledRecordRepository.refresh()` | - | - |
| `ApplyLedScheduleUseCase` | ✅ **YES** | 直接呼叫 `bleAdapter.writeBytes()` | `lib/domain/usecases/led/apply_led_schedule_usecase.dart` | 129-133 |

**事實**：
- ⚠️ **例外發現**：`ApplyLedScheduleUseCase` 直接呼叫 `bleAdapter.writeBytes()`（Line 129-133）
- 其他 UseCases 均透過 Repository 層

---

#### 1.3.2 Dosing UseCases

| UseCase | 是否發送 BLE | 發送方式 | 檔案位置 | 行號 |
|---------|-------------|---------|---------|------|
| `SingleDoseImmediateUseCase` | ✅ **YES** | 直接呼叫 `bleAdapter.writeBytes()` | `lib/domain/usecases/doser/single_dose_immediate_usecase.dart` | 102-106 |
| `SingleDoseTimedUseCase` | ✅ **YES** | 直接呼叫 `bleAdapter.writeBytes()` | `lib/domain/usecases/doser/single_dose_timed_usecase.dart` | 220-227 |
| `ApplyScheduleUseCase` | ✅ **YES** | 直接呼叫 `bleAdapter.writeBytes()` | `lib/domain/usecases/doser/apply_schedule_usecase.dart` | 多處 |

**事實**：
- ⚠️ **發現**：所有 Dosing UseCases 均直接呼叫 `bleAdapter.writeBytes()`
- ❌ 不經過 Repository 層

---

### 1.4 Repository 層（BLE 發送實際位置）

#### 1.4.1 BleLedRepositoryImpl
**檔案位置**：`lib/data/led/ble_led_repository_impl.dart`

| Repository Method | 是否發送 BLE | 發送位置 | 行號 | Opcode |
|------------------|-------------|---------|------|--------|
| `setChannelLevels()` | ✅ **YES** | `sendCommand(..._commandBuilder.dimming())` | 172 | 0x33 |
| `startRecord()` | ✅ **YES** | `sendCommand(..._commandBuilder.startRecordPlayback())` | 181 | 0x2B |
| `setRecord()` | ✅ **YES** | `sendCommand(..._commandBuilder.setRecord())` | 219-223 | 0x27 |
| `deleteRecord()` | ✅ **YES** | `sendCommand(..._commandBuilder.deleteRecord())` | 269-272 | 0x2F |
| `clearRecords()` | ✅ **YES** | `sendCommand(..._commandBuilder.clearRecords())` | 295 | 0x30 |
| `startPreview()` | ✅ **YES** | `sendCommand(..._commandBuilder.preview(true))` | 314 | 0x2A |
| `stopPreview()` | ✅ **YES** | `sendCommand(..._commandBuilder.preview(false))` | 326 | 0x2A |
| `applyScene()` | ✅ **YES** | `sendCommand(..._commandBuilder.usePresetScene() / useCustomScene())` | 116-121 | 0x28/0x29 |
| `resetToDefault()` | ✅ **YES** | `sendCommand(..._commandBuilder.reset())` | 154-160 | 0x2E |
| `sendCommand()` | ✅ **YES** | `_bleAdapter.writeBytes()` | 968-982 | - |

**事實**：
- ✅ 所有 BLE 發送均透過 `sendCommand()` 私有方法
- ✅ `sendCommand()` 呼叫 `_bleAdapter.writeBytes()`（Line 970-976）
- ✅ 單一入口設計

---

#### 1.4.2 BleDosingRepositoryImpl
**檔案位置**：`lib/data/dosing/ble_dosing_repository_impl.dart`

| Repository Method | 是否發送 BLE | 發送位置 | 行號 | Opcode |
|------------------|-------------|---------|------|--------|
| `resetToDefault()` | ✅ **YES** | `_sendCommand(..._commandBuilder.reset())` | 111 | 0x7D |
| `_sendCommand()` | ✅ **YES** | `_bleAdapter.writeBytes()` | 181-195 | - |

**事實**：
- ✅ 所有 BLE 發送均透過 `_sendCommand()` 私有方法
- ✅ `_sendCommand()` 呼叫 `_bleAdapter.writeBytes()`（Line 181-186）
- ✅ 單一入口設計
- ⚠️ **但**：Dosing 的大部分操作由 UseCase 直接發送，不經過此 Repository

---

## 任務 2｜多入口風險檢查

### 2.1 是否存在「兩個以上 public method 會直接發送 BLE 指令」？

#### LED 模組
❌ **NO**
- 所有 Controller 均不直接發送 BLE
- 所有 Controller 均透過 UseCase 層
- UseCase 層透過 Repository 層（除 `ApplyLedScheduleUseCase`）
- Repository 層僅有 `sendCommand()` 私有方法發送 BLE

#### Dosing 模組
⚠️ **YES（但在 UseCase 層，不是 Controller 層）**
- Controller 層不直接發送 BLE
- ⚠️ **發現**：多個 UseCase 直接呼叫 `bleAdapter.writeBytes()`
  - `SingleDoseImmediateUseCase.execute()` (Line 102-106)
  - `SingleDoseTimedUseCase.execute()` (Line 220-227)
  - `ApplyScheduleUseCase` (多處)
  - `ApplyLedScheduleUseCase` (Line 129-133)

---

### 2.2 是否存在「繞過 Controller、直接由 UI / Repository 發送 BLE」？

❌ **NO**
- 未發現 UI 直接呼叫 Repository 或 BLE Adapter
- 所有 UI 操作均透過 Controller

⚠️ **BUT**：
- 部分 UseCase 繞過 Repository，直接呼叫 `bleAdapter.writeBytes()`

---

### 2.3 是否存在「同一個 opcode 可能由不同 method 發送」？

❌ **NO**
- 每個 opcode 僅由一個 Repository method 發送
- 例如：
  - 0x33 (dimming) 僅由 `setChannelLevels()` 發送
  - 0x2B (start record) 僅由 `startRecord()` 發送
  - 0x27 (set record) 僅由 `setRecord()` 發送
  - 0x2F (delete record) 僅由 `deleteRecord()` 發送
  - 0x30 (clear records) 僅由 `clearRecords()` 發送
  - 0x2A (preview) 由 `startPreview()` 和 `stopPreview()` 發送（但參數不同）

**例外**：
- ⚠️ Dosing 的 0x6E/0x6F 由不同 UseCase 發送（`SingleDoseImmediateUseCase` vs `SingleDoseTimedUseCase`）

---

## 任務 3｜Android 對照

### 3.1 Android reef-b-app 的對應 Controller

#### Android 架構（reef-b-app）

| Android 元件 | 職責 | 對應 Flutter |
|------------|------|-------------|
| `CommandManager.kt` | BLE 指令發送與解析 | `BleLedRepositoryImpl` + `BleDosingRepositoryImpl` |
| `BLEManager.kt` | BLE 連接管理與寫入 | `BleAdapter` |
| `LedInformation.kt` | LED 狀態管理 | `LedState` (Domain) |
| `DropInformation.kt` | Dosing 狀態管理 | `DosingState` (Domain) |
| `XXXViewModel.kt` | UI 邏輯與狀態 | `XXXController.dart` (Presentation) |

---

### 3.2 Android 是否為單一入口設計？

✅ **YES**

**Android 事實（基於 docs/complete_led_ble_parity_plan.md）**：
- 所有 BLE 指令由 `BLEManager.sendCommand()` 發送
- `CommandManager` 負責指令編碼與 ACK 解析
- ViewModel 呼叫 `BLEManager` → `CommandManager` → BLE write
- 單一入口：`BLEManager.sendCommand()` (Kotlin 檔案)

---

### 3.3 Flutter 是否與 Android 行為一致？

#### LED 模組
✅ **YES（基本一致）**
- Flutter Controller → UseCase → Repository → `sendCommand()` → `bleAdapter.writeBytes()`
- Android ViewModel → BLEManager → `sendCommand()` → BLE write
- **架構對齊度**：✅ 高

⚠️ **例外**：
- `ApplyLedScheduleUseCase` 繞過 Repository，直接呼叫 `bleAdapter`
- Android 無此例外

#### Dosing 模組
⚠️ **Partial（部分不一致）**
- Flutter Controller → UseCase → **直接呼叫 `bleAdapter.writeBytes()`**
- Android ViewModel → BLEManager → `sendCommand()` → BLE write
- **架構對齊度**：⚠️ 中（UseCase 層行為不一致）

**事實陳述**：
- Android 所有 BLE 指令均透過 `BLEManager.sendCommand()`
- Flutter Dosing 部分指令由 UseCase 直接發送，繞過 Repository

---

## 附錄：檔案位置清單

### Controller 層（Presentation）

| 檔案 | 狀態 | BLE 發送 |
|-----|------|---------|
| `lib/features/led/presentation/controllers/led_control_controller.dart` | ✅ 使用中 | ❌ NO（透過 UseCase） |
| `lib/features/led/presentation/controllers/led_record_controller.dart` | ✅ 使用中 | ❌ NO（透過 UseCase） |
| `lib/features/doser/presentation/controllers/manual_dosing_controller.dart` | ✅ 使用中 | ❌ NO（透過 UseCase） |

### UseCase 層（Domain）

| 檔案 | BLE 發送 | 方式 |
|-----|---------|------|
| `lib/domain/usecases/led/set_channel_intensity.dart` | ❌ NO | 透過 Repository |
| `lib/domain/usecases/led/apply_led_schedule_usecase.dart` | ✅ **YES** | 直接呼叫 `bleAdapter` (Line 129-133) |
| `lib/domain/usecases/doser/single_dose_immediate_usecase.dart` | ✅ **YES** | 直接呼叫 `bleAdapter` (Line 102-106) |
| `lib/domain/usecases/doser/single_dose_timed_usecase.dart` | ✅ **YES** | 直接呼叫 `bleAdapter` (Line 220-227) |
| `lib/domain/usecases/doser/apply_schedule_usecase.dart` | ✅ **YES** | 直接呼叫 `bleAdapter` (多處) |

### Repository 層（Data）

| 檔案 | BLE 發送方法 | 行號 |
|-----|------------|------|
| `lib/data/led/ble_led_repository_impl.dart` | `sendCommand()` 私有方法 | 968-982 |
| `lib/data/dosing/ble_dosing_repository_impl.dart` | `_sendCommand()` 私有方法 | 168-196 |

---

## 事實總結（不含建議）

### 單一入口情況

#### Controller 層
- ✅ LED Controllers：所有入口透過 UseCase，無直接 BLE 發送
- ✅ Dosing Controllers：所有入口透過 UseCase，無直接 BLE 發送

#### UseCase 層
- ⚠️ LED：大部分透過 Repository，1 個例外（`ApplyLedScheduleUseCase`）
- ⚠️ Dosing：多個 UseCase 直接呼叫 `bleAdapter`，繞過 Repository

#### Repository 層
- ✅ LED：單一入口 `sendCommand()`
- ✅ Dosing：單一入口 `_sendCommand()`（但大部分操作由 UseCase 直接發送）

### 與 Android 對齊度
- ✅ Controller 層架構：完全對齊
- ⚠️ UseCase 層架構：部分不一致（Dosing 模組）
- ✅ Repository 層架構：基本對齊

---

**審核完成，等待下一步指示。**

