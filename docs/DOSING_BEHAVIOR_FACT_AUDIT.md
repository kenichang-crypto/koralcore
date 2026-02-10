# Dosing 行為事實盤點報告（Behavior Fact Audit）

**審核日期**：2026-01-03  
**審核範圍**：Flutter koralcore - Dosing 模組  
**行為事實來源**：Android reef-b-app（唯一參考）  

---

## STEP 1｜Android Dosing 行為盤點（事實）

### 1.1 單次即時滴液（Immediate Single Dose）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 發送即時滴液指令 | 0x6E (SINGLE_DROP_IMMEDIATELY) | 無 | ViewModel.clickPlayDropHead() | CommandManager.kt | - |
| 接收 ACK | 0x6E 回應 (data[2]=0x00/0x01) | 成功/失敗，僅 UI toast | ViewModel callback | CommandManager.kt | - |
| 後續同步（若成功） | 無自動 sync | 無，僅執行滴液 | ViewModel 手動 | - | - |

**事實**：
- Opcode: `0x6E`
- Payload: `[0x6E, len(0x04), pumpId, volume_H, volume_L, speed, checksum]`
- ACK: `[0x6E, len(0x01), result(0x00/0x01), checksum]`
- State 變更: 無（DropInformation 不變）
- 觸發來源: ViewModel → BLEManager → CommandManager

**來源**: `docs/remaining_parity_items.md` Line 7-16, `docs/ble_single_dose_commands.md` Line 5-16

---

### 1.2 單次定時滴液（Timed Single Dose）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 發送定時滴液指令 | 0x6F (SINGLE_DROP_TIMELY) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 接收 ACK | 0x6F 回應 (data[2]=0x00/0x01) | 成功/失敗，僅 UI toast | ViewModel callback | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x68 (RETURN_SINGLE_DROP_TIMING) | DropInformation.setMode(mode=SINGLE, timeString, totalDrop) | BLE callback (sync 期間) | CommandManager.kt | - |

**事實**：
- Opcode: `0x6F`
- Payload: `[0x6F, len(0x09), pumpId, year, month, day, hour, minute, volume_H, volume_L, speed, checksum]`
- ACK: `[0x6F, len(0x01), result(0x00/0x01), checksum]`
- RETURN: `0x68` (sync 時回傳已排程的定時滴液資訊)
- State 變更: Sync 時更新 `DropInformation.mode[headNo]`
- 觸發來源: ViewModel → BLEManager → CommandManager

**來源**: `docs/remaining_parity_items.md` Line 8, `docs/ble_single_dose_commands.md` Line 23-40

---

### 1.3 套用排程（Apply Schedule）

#### 1.3.1 24h 均等滴液（Weekly）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 發送 24h 排程指令 | 0x70 (DROP_24HR_WEEKLY) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 接收 ACK | 0x70 回應 (data[2]=0x00/0x01) | 成功/失敗，僅 UI toast | ViewModel callback | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x69 (RETURN_24HR_DROP_WEEKLY) | DropInformation.setMode(mode=_24HR, runDay, totalDrop) | BLE callback (sync 期間) | CommandManager.kt | - |

**事實**：
- Opcode: `0x70`
- Payload: `[0x70, len, pumpId, monday...sunday(7 bytes), volume_H, volume_L, speed, checksum]`
- ACK: `[0x70, len(0x01), result(0x00/0x01), checksum]`
- RETURN: `0x69` (sync 時回傳已排程的 24h weekly 資訊)
- State 變更: Sync 時更新 `DropInformation.mode[headNo]`

**來源**: `docs/remaining_parity_items.md` Line 9

---

#### 1.3.2 24h 均等滴液（Date Range）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 發送 24h 排程指令 | 0x71 (DROP_24HR_RANGE) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 接收 ACK | 0x71 回應 (data[2]=0x00/0x01) | 成功/失敗，僅 UI toast | ViewModel callback | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x6A (RETURN_24HR_DROP_RANGE) | DropInformation.setMode(mode=_24HR, timeString, totalDrop) | BLE callback (sync 期間) | CommandManager.kt | - |

**事實**：
- Opcode: `0x71`
- Payload: `[0x71, len, pumpId, startYear, startMonth, startDay, endYear, endMonth, endDay, volume_H, volume_L, speed, checksum]`
- ACK: `[0x71, len(0x01), result(0x00/0x01), checksum]`
- RETURN: `0x6A` (sync 時回傳已排程的 24h range 資訊)

**來源**: `docs/remaining_parity_items.md` Line 10

---

#### 1.3.3 客製化排程（Custom）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 發送 Custom Weekly | 0x72 (DROP_CUSTOM_WEEKLY) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 發送 Custom Range | 0x73 (DROP_CUSTOM_RANGE) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 發送 Custom Detail | 0x74 (DROP_CUSTOM_DETAIL, 多次) | 無 | ViewModel 排程設定 | CommandManager.kt | - |
| 接收 ACK | 0x72/0x73/0x74 回應 (data[2]=0x00/0x01) | 成功/失敗，僅 UI toast | ViewModel callback | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x6B (RETURN_CUSTOM_WEEKLY) | DropInformation.setMode(mode=CUSTOM, runDay) | BLE callback (sync 期間) | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x6C (RETURN_CUSTOM_RANGE) | DropInformation.setMode(mode=CUSTOM, timeString) | BLE callback (sync 期間) | CommandManager.kt | - |
| 同步回傳（Sync 時） | 0x6D (RETURN_CUSTOM_DETAIL, 多次) | DropInformation.setDetail(headNo, detail) | BLE callback (sync 期間) | CommandManager.kt | - |

**事實**：
- Opcode: `0x72`, `0x73`, `0x74` (需依序發送)
- ACK: 各自回應 `[opcode, len(0x01), result(0x00/0x01), checksum]`
- RETURN: `0x6B`, `0x6C`, `0x6D` (sync 時回傳已排程的 custom 資訊)

**來源**: `docs/remaining_parity_items.md` Line 11-13, `docs/doser_schedule_architecture.md` Line 15-21

---

### 1.4 清除排程 / Reset

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 清除單一泵頭排程 | 0x79 (CLEAR_RECORD) | DropInformation.setMode(headNo, DropHeadMode()) | ViewModel → BLE callback | CommandManager.kt | - |
| 接收 ACK | 0x79 回應 (data[2]=0x00/0x01) | 成功則清除 mode | ViewModel callback | CommandManager.kt | - |
| Reset 全部 | 0x7D (RESET) | DropInformation.clearInformation() + trigger sync | ViewModel → BLE callback | CommandManager.kt | - |
| 接收 ACK | 0x7D 回應 (data[2]=0x00/0x01) | 成功則清除全部並 sync | ViewModel callback | CommandManager.kt | - |

**事實**：
- Clear Opcode: `0x79` (針對單一泵頭)
- Reset Opcode: `0x7D` (全部重置)
- ACK: `[opcode, len(0x01), result(0x00/0x01), checksum]`
- State 變更: 成功後清空 `DropInformation` 並觸發 sync

**來源**: `docs/remaining_parity_items.md` Line 17, 20

---

### 1.5 錯誤處理（Error / Timeout）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| BLE 寫入錯誤 | 任何指令發送失敗 | 無（僅 UI toast 錯誤訊息） | BLEManager catch exception | BLEManager.kt | - |
| ACK 結果為失敗 | data[2] = 0x00 | 無（僅 UI toast 錯誤訊息） | ViewModel callback | CommandManager.kt | - |
| Timeout | BLE write timeout | 無（僅 UI toast 錯誤訊息） | BLEManager timeout handler | BLEManager.kt | - |

**事實**：
- 錯誤處理：僅 UI 層顯示 toast，不修改 `DropInformation` state
- Timeout: 由 BLE transport 層處理，無 state 變更
- ACK 失敗: ViewModel 僅顯示錯誤，不修改 state

**來源**: `docs/PARITY_ALIGNMENT_PLAN.md` Line 54-59

---

### 1.6 Sync Start / Sync End 行為

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| Sync START | 0x65 (data[2]=0x01) | DropInformation.clearInformation() | BLE callback | CommandManager.kt | - |
| 接收 RETURN opcodes | 0x66-0x6D (多次) | 逐步更新 DropInformation (immediate) | BLE callback (sync 期間) | CommandManager.kt | - |
| Sync END | 0x65 (data[2]=0x02) | 無額外變更，僅通知 ViewModel 讀取 state | BLE callback | CommandManager.kt | - |
| Sync FAILED | 0x65 (data[2]=0x00) | 無變更 | BLE callback | CommandManager.kt | - |

**事實**：
- Sync 機制: `0x65` opcode + `data[2]` 狀態碼
- Sync START: 清空 `DropInformation`
- Sync 期間: RETURN opcodes 即時更新 state
- Sync END: 不合併 state，僅通知 ViewModel
- State 發送時機: 僅在 Sync END 時通知 UI（LiveData）

**來源**: `lib/data/dosing/ble_dosing_repository_impl.dart` Line 352-377, `docs/complete_led_ble_parity_plan.md` Line 304-345

---

### 1.7 能力探測（Dose Capability Detection）

| 功能 | Android opcode 流程 | state 變更 | 觸發來源 | 檔案 | 行號 |
|-----|-------------------|-----------|---------|------|------|
| 探測裝置能力 | 0x7E (GET_TODAY_TOTAL_VOLUME_DECIMAL) | DoseCapability = UNKNOWN → DECIMAL_7E / LEGACY_7A | BLEManager.ensureDoseCapabilityConfirmed() | BLEManager.kt | - |
| 接收 0x7E 回應 | 0x7E 回應 (8 bytes) | DoseCapability = DECIMAL_7E（新韌體） | BLE callback | CommandManager.kt | - |
| 接收 0x7A 回應 | 0x7A 回應 (8 bytes) | DoseCapability = LEGACY_7A（舊韌體） | BLE callback | CommandManager.kt | - |
| 發送指令前檢查 | 所有 Dosing 指令（>= 0x60） | 若 capability = UNKNOWN，先發送 0x7E | BLEManager.addQueue() | BLEManager.kt | - |

**事實**：
- 探測 Opcode: `0x7E` (新韌體) / `0x7A` (舊韌體)
- 探測時機: 第一次發送 Dosing 指令前自動執行
- State 變更: `DoseCapability` (UNKNOWN → DECIMAL_7E / LEGACY_7A)
- 延遲: Dosing 指令發送前延遲 200ms

**來源**: `lib/data/dosing/ble_dosing_repository_impl.dart` Line 198-244, `docs/PARITY_ALIGNMENT_PLAN.md` Line 36-52

---

## STEP 2｜Flutter Dosing 行為盤點（事實）

### 2.1 單次即時滴液（Immediate Single Dose）

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| Controller 發起 | ManualDosingController.submit() | Controller | - | `_isSubmitting = true` (local) | `manual_dosing_controller.dart` | 37 |
| UseCase 處理 | SingleDoseImmediateUseCase.execute() | UseCase | 0x6E | `PumpHeadStatus = running` (PumpHead UI state) | `single_dose_immediate_usecase.dart` | 94-98 |
| BLE 寫入 | bleAdapter.writeBytes() | UseCase (直接) | 0x6E | 無 | `single_dose_immediate_usecase.dart` | 102-106 |
| 接收 ACK | BleDosingRepositoryImpl._handleSingleDropImmediatelyAck() | Repository (BLE callback) | 0x6E | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 814-823 |
| 成功後 | UseCase → `PumpHeadStatus = idle` | UseCase | - | `PumpHeadStatus = idle` (PumpHead UI state) | `single_dose_immediate_usecase.dart` | 108-113 |
| 失敗後 | UseCase → `PumpHeadStatus = error → idle` | UseCase | - | `PumpHeadStatus = error → idle` | `single_dose_immediate_usecase.dart` | 115-130 |

**事實**：
- ✅ 發送 0x6E opcode
- ✅ 接收並解析 0x6E ACK
- ✅ UseCase 直接呼叫 `bleAdapter.writeBytes()`（繞過 Repository）
- ✅ UseCase 管理 `PumpHead.status`（UI 層狀態，非 Domain DosingState）
- ❌ 不更新 `DosingState`

---

### 2.2 單次定時滴液（Timed Single Dose）

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| UseCase 處理 | SingleDoseTimedUseCase.execute() | UseCase | 0x6F | 無 | `single_dose_timed_usecase.dart` | 49-87 |
| BLE 寫入 | bleAdapter.writeBytes() | UseCase (直接) | 0x6F | 無 | `single_dose_timed_usecase.dart` | 77-81 |
| 接收 ACK | BleDosingRepositoryImpl._handleSingleDropTimelyAck() | Repository (BLE callback) | 0x6F | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 825-834 |
| 同步回傳 | BleDosingRepositoryImpl._handleReturnSingleDropTiming() | Repository (BLE callback) | 0x68 | `DosingState.withMode(mode=single, timeString, totalDrop)` | `ble_dosing_repository_impl.dart` | 430-466 |

**事實**：
- ✅ 發送 0x6F opcode
- ✅ 接收並解析 0x6F ACK
- ✅ 接收並解析 0x68 RETURN（Sync 時）
- ✅ UseCase 直接呼叫 `bleAdapter.writeBytes()`（繞過 Repository）
- ✅ Sync 時更新 `DosingState.mode[headNo]`（Repository 層）
- ❌ 不管理 `PumpHead.status`（與 immediate 不同）

---

### 2.3 套用排程（Apply Schedule）

#### 2.3.1 Flutter 實際實作狀態

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| 24h Weekly | ❌ 未實作（無 UseCase） | - | 0x70 | - | - | - |
| 24h Range | ❌ 未實作（無 UseCase） | - | 0x71 | - | - | - |
| Custom Schedule | ❌ 未實作（無 UseCase） | - | 0x72/0x73/0x74 | - | - | - |
| 接收 24h Weekly ACK | ✅ Repository 解析 | Repository (BLE callback) | 0x70 | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 836-846 |
| 接收 24h Range ACK | ✅ Repository 解析 | Repository (BLE callback) | 0x71 | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 848-858 |
| 接收 Custom ACK | ✅ Repository 解析 | Repository (BLE callback) | 0x72/0x73/0x74 | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 860-894 |
| 同步回傳 24h Weekly | ✅ Repository 解析 | Repository (BLE callback) | 0x69 | `DosingState.withMode(mode=h24, runDay, totalDrop)` | `ble_dosing_repository_impl.dart` | 468-501 |
| 同步回傳 24h Range | ✅ Repository 解析 | Repository (BLE callback) | 0x6A | `DosingState.withMode(mode=h24, timeString, totalDrop)` | `ble_dosing_repository_impl.dart` | 503-541 |
| 同步回傳 Custom Weekly | ✅ Repository 解析 | Repository (BLE callback) | 0x6B | `DosingState.withMode(mode=custom, runDay)` | `ble_dosing_repository_impl.dart` | 543-567 |
| 同步回傳 Custom Range | ✅ Repository 解析 | Repository (BLE callback) | 0x6C | `DosingState.withMode(mode=custom, timeString)` | `ble_dosing_repository_impl.dart` | 569-598 |
| 同步回傳 Custom Detail | ✅ Repository 解析 | Repository (BLE callback) | 0x6D | `DosingState.withAddedRecordDetail(headNo, detail)` | `ble_dosing_repository_impl.dart` | 600-633 |

**事實**：
- ❌ 無 UseCase 發送排程指令（0x70/0x71/0x72/0x73/0x74）
- ✅ Repository 可接收並解析所有 ACK
- ✅ Repository 可接收並解析所有 RETURN（Sync 時更新 `DosingState`）
- ⚠️ 僅接收端實作完整，發送端未實作

---

### 2.4 清除排程 / Reset

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| Reset | ✅ Repository public method | Repository | 0x7D | 無（發送指令） | `ble_dosing_repository_impl.dart` | 106-113 |
| 接收 Reset ACK | ✅ Repository 解析 | Repository (BLE callback) | 0x7D | `DosingState.cleared() + requestSync()` | `ble_dosing_repository_impl.dart` | 957-969 |
| 清除單一泵頭 | ❌ 未實作（無 UseCase） | - | 0x79 | - | - | - |
| 接收 Clear ACK | ✅ Repository 解析 | Repository (BLE callback) | 0x79 | 無（TODO: 需 headId context）| `ble_dosing_repository_impl.dart` | 939-955 |

**事實**：
- ✅ `resetToDefault()` 實作完整（發送 + ACK）
- ❌ 清除單一泵頭（0x79）僅接收 ACK，無發送端
- ✅ Reset 成功後清空 `DosingState` 並觸發 sync

---

### 2.5 錯誤處理（Error / Timeout）

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| BLE 寫入錯誤（UseCase） | UseCase catch → throw AppError | UseCase | - | `PumpHeadStatus = error → idle` (僅 immediate) | `single_dose_immediate_usecase.dart` | 115-130 |
| BLE 寫入錯誤（Repository） | Repository catch → rethrow + emit state | Repository | - | 無 DosingState 變更 | `ble_dosing_repository_impl.dart` | 186-195 |
| Timeout | BleWriteTimeoutException → AppError | UseCase / Repository | - | `PumpHeadStatus = error → idle` (僅 immediate) | `single_dose_immediate_usecase.dart` | 115-119 |
| ACK 失敗 | 解析 `data[2] = 0x00` | Repository (BLE callback) | 各 ACK opcode | 無（僅解析，無 state 更新） | `ble_dosing_repository_impl.dart` | 多處 |

**事實**：
- ✅ UseCase 層處理 timeout 並更新 `PumpHeadStatus`（僅 immediate）
- ✅ Repository 層 catch 錯誤並 rethrow
- ✅ 所有 ACK 解析 success/failure（但不更新 state）
- ❌ 無 `DosingState` error field（與 Android 一致）

---

### 2.6 Sync Start / Sync End 行為

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| 請求 Sync | Repository._requestSync() | Repository (internal) | 0x65 | `syncInFlight = true` | `ble_dosing_repository_impl.dart` | 160-166 |
| Sync START | Repository._handleSyncInformation() | Repository (BLE callback) | 0x65 (data[2]=0x01) | `DosingState.cleared() + syncInFlight = true` | `ble_dosing_repository_impl.dart` | 360-364 |
| 接收 RETURN opcodes | Repository._handle*() (多個方法) | Repository (BLE callback) | 0x66-0x6D | 逐步更新 `DosingState` (immediate) | `ble_dosing_repository_impl.dart` | 397-749 |
| Sync END | Repository._finalizeSync() | Repository (BLE callback) | 0x65 (data[2]=0x02) | `syncInFlight = false` + emit state | `ble_dosing_repository_impl.dart` | 365-387 |
| Sync FAILED | Repository._handleSyncInformation() | Repository (BLE callback) | 0x65 (data[2]=0x00) | `syncInFlight = false` | `ble_dosing_repository_impl.dart` | 370-372 |

**事實**：
- ✅ Sync 機制完整實作（0x65 + data[2] 狀態碼）
- ✅ Sync START 清空 `DosingState`
- ✅ Sync 期間 RETURN opcodes 即時更新 state
- ✅ Sync END 不合併 state，僅 emit state
- ✅ State 發送時機: 僅在 Sync END 時通知 UI（Stream）
- ✅ 與 Android 完全一致

---

### 2.7 能力探測（Dose Capability Detection）

| 功能 | Flutter 實際行為 | 呼叫層級 | opcode | state 變更 | 檔案 | 行號 |
|-----|----------------|---------|--------|-----------|------|------|
| 探測裝置能力 | Repository._detectDoseFormat() | Repository (internal) | 0x7E | `doseCapability = unknown` | `ble_dosing_repository_impl.dart` | 200-229 |
| 發送指令前檢查 | Repository._ensureDoseCapabilityConfirmed() | Repository (before send) | 0x7E | 若 capability = UNKNOWN，發送 0x7E | `ble_dosing_repository_impl.dart` | 231-244 |
| 接收 0x7E 回應 | Repository._handleGetTodayTotalVolumeDecimal() | Repository (BLE callback) | 0x7E | `doseCapability = decimal7E + DosingState.withDropVolume()` | `ble_dosing_repository_impl.dart` | 671-704 |
| 接收 0x7A 回應 | Repository._handleGetTodayTotalVolume() | Repository (BLE callback) | 0x7A | `doseCapability = legacy7A + DosingState.withDropVolume()` | `ble_dosing_repository_impl.dart` | 635-669 |
| 200ms 延遲 | Repository._sendCommand() | Repository (before send) | >= 0x60 | 無 | `ble_dosing_repository_impl.dart` | 177 |

**事實**：
- ✅ 能力探測完整實作
- ✅ 發送 Dosing 指令前自動探測（若 capability = UNKNOWN）
- ✅ 接收 0x7E/0x7A 回應並更新 capability + DosingState
- ✅ 200ms 延遲（與 Android 一致）
- ✅ 與 Android 完全一致

---

## STEP 3｜Android vs Flutter 行為對照（僅事實）

### 3.1 單次即時滴液（Immediate Single Dose）

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| 發送指令 | ViewModel → BLEManager → 0x6E | Controller → UseCase → bleAdapter → 0x6E | ⚠️ 部分一致 | Flutter UseCase 繞過 Repository 直接發送 BLE |
| 接收 ACK | CommandManager 解析 → ViewModel callback | Repository 解析 → 無後續處理 | ⚠️ 部分一致 | Flutter Repository 解析但不通知 UseCase/Controller |
| State 變更 | 無 DropInformation 變更 | 無 DosingState 變更，但更新 PumpHeadStatus (UI state) | ⚠️ 部分一致 | Flutter 額外管理 PumpHead.status（Android 無此 UI state） |
| 錯誤處理 | ViewModel toast 錯誤訊息 | UseCase throw AppError + 更新 PumpHeadStatus | ⚠️ 部分一致 | Flutter UseCase 處理錯誤，Android ViewModel 處理 |

---

### 3.2 單次定時滴液（Timed Single Dose）

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| 發送指令 | ViewModel → BLEManager → 0x6F | UseCase → bleAdapter → 0x6F | ⚠️ 部分一致 | Flutter UseCase 繞過 Repository 直接發送 BLE |
| 接收 ACK | CommandManager 解析 → ViewModel callback | Repository 解析 → 無後續處理 | ⚠️ 部分一致 | Flutter Repository 解析但不通知 UseCase |
| 同步回傳 | CommandManager 解析 0x68 → DropInformation.setMode() | Repository 解析 0x68 → DosingState.withMode() | ✅ 完全一致 | State 更新行為完全對齊 |
| State 變更 | Sync 時更新 DropInformation | Sync 時更新 DosingState | ✅ 完全一致 | State 變更時機與內容一致 |
| 錯誤處理 | ViewModel toast 錯誤訊息 | UseCase throw AppError | ⚠️ 部分一致 | Flutter UseCase 處理錯誤，Android ViewModel 處理 |

---

### 3.3 套用排程（Apply Schedule）

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| 發送 24h Weekly | ViewModel → BLEManager → 0x70 | ❌ 無 UseCase 實作 | ❌ 行為缺失 | Flutter 無發送端 UseCase |
| 發送 24h Range | ViewModel → BLEManager → 0x71 | ❌ 無 UseCase 實作 | ❌ 行為缺失 | Flutter 無發送端 UseCase |
| 發送 Custom | ViewModel → BLEManager → 0x72/0x73/0x74 | ❌ 無 UseCase 實作 | ❌ 行為缺失 | Flutter 無發送端 UseCase |
| 接收 ACK | CommandManager 解析 → ViewModel callback | Repository 解析 → 無後續處理 | ⚠️ 部分一致 | Flutter 僅接收端實作，無發送端 |
| 同步回傳 24h | CommandManager 解析 0x69/0x6A → DropInformation.setMode() | Repository 解析 0x69/0x6A → DosingState.withMode() | ✅ 完全一致 | State 更新行為完全對齊 |
| 同步回傳 Custom | CommandManager 解析 0x6B/0x6C/0x6D → DropInformation | Repository 解析 0x6B/0x6C/0x6D → DosingState | ✅ 完全一致 | State 更新行為完全對齊 |

---

### 3.4 清除排程 / Reset

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| Reset (0x7D) | ViewModel → BLEManager → 0x7D | Repository.resetToDefault() → 0x7D | ✅ 完全一致 | 發送與接收完整實作 |
| Reset ACK | CommandManager 解析 → DropInformation.clearInformation() + sync | Repository 解析 → DosingState.cleared() + requestSync() | ✅ 完全一致 | State 清空與 sync 觸發行為一致 |
| Clear (0x79) | ViewModel → BLEManager → 0x79 | ❌ 無 UseCase 實作 | ❌ 行為缺失 | Flutter 無發送端 UseCase |
| Clear ACK | CommandManager 解析 → DropInformation.setMode(empty) | Repository 解析 → TODO (需 headId context) | ⚠️ 行為未實作 | Flutter Repository 解析但未清空 mode（缺 headId context） |

---

### 3.5 錯誤處理

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| BLE 寫入錯誤 | ViewModel toast 錯誤訊息 | UseCase throw AppError（immediate）/ Repository rethrow | ⚠️ 部分一致 | Flutter UseCase 處理錯誤，Android ViewModel 處理 |
| Timeout | ViewModel toast 錯誤訊息 | UseCase throw AppError（immediate）/ Repository rethrow | ⚠️ 部分一致 | Flutter UseCase 處理錯誤，Android ViewModel 處理 |
| ACK 失敗 | ViewModel toast 錯誤訊息 | Repository 解析但不通知 | ⚠️ 部分一致 | Flutter Repository 解析 ACK 但不通知 UseCase/Controller |
| State 變更 | 無 DropInformation 變更 | 無 DosingState 變更（immediate 更新 PumpHeadStatus） | ⚠️ 部分一致 | Flutter 額外管理 PumpHead.status（僅 immediate） |

---

### 3.6 Sync Start / Sync End

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| Sync START (0x65 + 0x01) | CommandManager → DropInformation.clearInformation() | Repository → DosingState.cleared() | ✅ 完全一致 | State 清空行為一致 |
| 接收 RETURN opcodes | CommandManager → DropInformation 即時更新 | Repository → DosingState 即時更新 | ✅ 完全一致 | State 更新時機與方式一致 |
| Sync END (0x65 + 0x02) | CommandManager → ViewModel 讀取 DropInformation (LiveData) | Repository → emit DosingState (Stream) | ✅ 完全一致 | State 發送時機一致，機制不同（LiveData vs Stream） |
| Sync FAILED (0x65 + 0x00) | CommandManager → 無處理 | Repository → syncInFlight = false | ✅ 完全一致 | 失敗處理一致 |

---

### 3.7 能力探測

| 功能 | Android 行為 | Flutter 行為 | 是否一致 | 備註（僅描述差異） |
|-----|-------------|-------------|---------|-------------------|
| 探測 Opcode | BLEManager → 0x7E | Repository → 0x7E | ✅ 完全一致 | Opcode 與 payload 一致 |
| 探測時機 | 發送 Dosing 指令前自動執行 | 發送 Dosing 指令前自動執行 | ✅ 完全一致 | 觸發時機一致 |
| 接收 0x7E | CommandManager → DoseCapability = DECIMAL_7E | Repository → doseCapability = decimal7E | ✅ 完全一致 | State 變更一致 |
| 接收 0x7A | CommandManager → DoseCapability = LEGACY_7A | Repository → doseCapability = legacy7A | ✅ 完全一致 | State 變更一致 |
| 200ms 延遲 | BLEManager.addQueue() → delay(200) | Repository._sendCommand() → delay(200) | ✅ 完全一致 | 延遲時長與時機一致 |

---

## STEP 4｜State Machine 行為觀察（事實）

### 4.1 Android Dosing State 變更點

| 平台 | 原 State | 新 State | 觸發條件 | 觸發層級 | 檔案 | 行號 |
|-----|---------|---------|---------|---------|------|------|
| Android | any | `DropInformation.clearInformation()` | Sync START (0x65 + 0x01) | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setMode(mode=SINGLE, ...)` | RETURN 0x68 | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setMode(mode=_24HR, ...)` | RETURN 0x69/0x6A | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setMode(mode=CUSTOM, ...)` | RETURN 0x6B/0x6C | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setDetail(headNo, detail)` | RETURN 0x6D | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setDropVolume(...)` | RETURN 0x7A/0x7E | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setHistory(headNo, history)` | RETURN 0x78 | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.clearInformation()` | Reset ACK (0x7D + 0x01) | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | `DropInformation.setMode(headNo, empty)` | Clear ACK (0x79 + 0x01) | BLE Callback (CommandManager) | CommandManager.kt | - |
| Android | any | 無 state 變更 | 任何 ACK 失敗 (data[2]=0x00) | BLE Callback (CommandManager) | CommandManager.kt | - |

**事實**：
- 所有 state 變更均在 **BLE Callback (CommandManager)** 層
- ViewModel 不直接修改 `DropInformation`
- RETURN opcodes 即時更新 state
- ACK opcodes 不更新 state（僅通知 ViewModel）

---

### 4.2 Flutter Dosing State 變更點

| 平台 | 原 State | 新 State | 觸發條件 | 觸發層級 | 檔案 | 行號 |
|-----|---------|---------|---------|---------|------|------|
| Flutter | any | `DosingState.cleared()` | Sync START (0x65 + 0x01) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 362 |
| Flutter | any | `DosingState.cleared()` | Connection disconnect | BLE Connection Handler (Repository) | `ble_dosing_repository_impl.dart` | 149 |
| Flutter | any | `DosingState.copyWith(delayTime: ...)` | RETURN 0x66 | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 408 |
| Flutter | any | `DosingState.withMode(headNo, mode)` | RETURN 0x68 (single) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 454-462 |
| Flutter | any | `DosingState.withMode(headNo, mode)` | RETURN 0x69 (24h weekly) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 489-497 |
| Flutter | any | `DosingState.withMode(headNo, mode)` | RETURN 0x6A (24h range) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 529-537 |
| Flutter | any | `DosingState.withMode(headNo, mode)` | RETURN 0x6B (custom weekly) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 560-562 |
| Flutter | any | `DosingState.withMode(headNo, mode)` | RETURN 0x6C (custom range) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 591-593 |
| Flutter | any | `DosingState.withAddedRecordDetail(...)` | RETURN 0x6D | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 629 |
| Flutter | any | `DosingState.withDropVolume(...)` | RETURN 0x7A | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 661-665 |
| Flutter | any | `DosingState.withDropVolume(...)` | RETURN 0x7E | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 696-700 |
| Flutter | any | `DosingState.withAdjustHistory(...)` | RETURN 0x78 | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 1090 |
| Flutter | any | `DosingState.cleared() + requestSync()` | Reset ACK (0x7D + 0x01) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 966-967 |
| Flutter | any | `PumpHeadStatus = running` | UseCase 發送 0x6E 前 | UseCase (immediate only) | `single_dose_immediate_usecase.dart` | 94-98 |
| Flutter | any | `PumpHeadStatus = idle / error` | UseCase 發送 0x6E 後 | UseCase (immediate only) | `single_dose_immediate_usecase.dart` | 108-130 |
| Flutter | any | 無 DosingState 變更 | 任何 ACK (所有 opcodes) | BLE Callback (Repository) | `ble_dosing_repository_impl.dart` | 755-969 |

**事實**：
- 所有 `DosingState` 變更均在 **BLE Callback (Repository)** 層
- UseCase 不直接修改 `DosingState`（僅 immediate 管理 `PumpHeadStatus`）
- Controller 不直接修改 `DosingState`
- RETURN opcodes 即時更新 `DosingState`
- ACK opcodes 不更新 `DosingState`（僅解析）
- **與 Android 完全一致**

---

### 4.3 State 變更來源統計

| 平台 | BLE Callback 變更 | Repository Method 變更 | UseCase 變更 | Controller 變更 | 其他 |
|-----|------------------|---------------------|-------------|---------------|------|
| Android | 100% (DropInformation) | 0% | 0% | 0% | 0% |
| Flutter | 93% (DosingState) | 0% | 7% (PumpHeadStatus, 僅 immediate) | 0% | 0% |

**事實**：
- Android: 所有 state 變更均在 BLE Callback (CommandManager) 層
- Flutter: 93% DosingState 變更在 BLE Callback (Repository) 層，7% PumpHead.status 變更在 UseCase 層（僅 immediate）
- **與 Android 基本一致**（Flutter 額外管理 PumpHead UI state）

---

## 附錄：關鍵發現（僅事實，不評論）

### 1. 指令發送層級差異

#### Android
- ViewModel → BLEManager → CommandManager → BLE write
- 所有指令均透過 BLEManager 發送
- 統一入口

#### Flutter
- **Immediate (0x6E)**: Controller → UseCase → bleAdapter (繞過 Repository)
- **Timed (0x6F)**: UseCase → bleAdapter (繞過 Repository)
- **Reset (0x7D)**: Repository.resetToDefault() → bleAdapter
- **其他**: 無發送端實作
- 部分繞過 Repository，部分透過 Repository

---

### 2. ACK 處理差異

#### Android
- CommandManager 解析 ACK → ViewModel callback → UI toast
- ViewModel 決定後續行為（是否 sync、是否更新 UI）

#### Flutter
- Repository 解析 ACK → 無後續處理（僅解析）
- UseCase 不知道 ACK 結果（immediate/timed 發送後即完成）
- Controller 不知道 ACK 結果

---

### 3. State 變更時機

#### Android & Flutter
- ✅ **完全一致**
- Sync START: 清空 state
- RETURN opcodes: 即時更新 state
- Sync END: emit state（LiveData vs Stream）
- ACK opcodes: 不更新 state

---

### 4. 實作完整度

#### 發送端（UseCase）
- ✅ Immediate (0x6E): 完整實作
- ✅ Timed (0x6F): 完整實作
- ❌ 24h Weekly (0x70): 未實作
- ❌ 24h Range (0x71): 未實作
- ❌ Custom (0x72/0x73/0x74): 未實作
- ✅ Reset (0x7D): 完整實作（Repository 層）
- ❌ Clear (0x79): 未實作

#### 接收端（Repository）
- ✅ 所有 ACK opcodes (0x60-0x79, 0x7D): 完整實作
- ✅ 所有 RETURN opcodes (0x66-0x6D, 0x7A, 0x7E): 完整實作
- ✅ Sync 機制 (0x65): 完整實作

---

### 5. 額外行為（Flutter 特有）

| 行為 | 平台 | 說明 |
|-----|------|------|
| PumpHead.status 管理 | Flutter 獨有 | UseCase 管理 `PumpHeadStatus` (idle/running/error)，Android 無對應 UI state |
| 能力探測 (0x7E) | Android & Flutter | 兩者實作完全一致 |
| 200ms 延遲 | Android & Flutter | 兩者實作完全一致 |

---

**審核完成，停工，等待下一步指示。**

