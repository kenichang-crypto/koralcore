# 完整 LED + Dosing BLE Parity 計畫（對照 reef-b-app Android 版）

**重要發現**：koralcore 目前**完全沒有 Dosing BLE repository implementation**（類似 `ble_led_repository_impl.dart`），只有 `DoserRepositoryImpl` 處理 `readTodayTotals`（0x7A/0x7E），**缺少所有其他 Dosing opcodes 的處理**。

## 一、Opcode 對照表（完整版）

### 1. LED Opcodes（0x20-0x34）

### reef-b-app Android 定義的所有 LED Opcodes

| Opcode | 名稱 | 類型 | Payload 長度 | 狀態值 | reef-b-app Android 處理 | reef-b-app iOS 處理 | koralcore 狀態 | 備註 |
|--------|------|------|--------------|--------|------------------------|---------------------|----------------|------|
| 0x20 | CMD_LED_TIME_CORRECTION | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |
| 0x21 | CMD_LED_SYNC_INFORMATION | Status | 4 | 0x00=FAILED, 0x01=START, 0x02=END | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x23 | CMD_LED_RETURN_RECORD | Data Return | 14 | - | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x24 | CMD_LED_RETURN_PRESET_SCENE | Data Return | 4 | - | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x25 | CMD_LED_RETURN_CUSTOM_SCENE | Data Return | 12 | - | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x26 | CMD_LED_RETURN_SCHEDULE | Data Return | - | - | ❌ **未實現** | ❌ **未實現** | ✅ 已處理（返回 null） | 兩平台都未實現 |
| 0x27 | CMD_LED_SET_RECORD | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |
| 0x28 | CMD_LED_USE_PRESET_SCENE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x29 | CMD_LED_USE_CUSTOM_SCENE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x2A | CMD_LED_PREVIEW | ACK | 4 | 0x00=FAILED, 0x01=START, 0x02=END | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x2B | CMD_LED_START_RECORD | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |
| 0x2C | CMD_LED_GET_WARNING | Data Return? | - | - | ❌ **定義但未處理** | ✅ 已實現 | ❌ **未處理** | Android 未實作，iOS 有 |
| 0x2D | CMD_LED_WRITE_USER_ID | ACK? | - | - | ❌ **定義但未處理** | ✅ 已實現 | ❌ **未處理** | Android 未實作，iOS 有 |
| 0x2E | CMD_LED_RESET | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |
| 0x2F | CMD_LED_DELETE_RECORD | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x30 | CMD_LED_CLEAR_RECORD | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x31 | CMD_LED_DYNAMIC_SCENE_END | Data Return? | - | - | ❌ **定義但未處理** | ✅ 已實現 | ❌ **未處理** | Android 未實作，iOS 有 |
| 0x32 | CMD_LED_ENTER_DIMMING_MODE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |
| 0x33 | CMD_LED_DIMMING | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ✅ 已處理 | - |
| 0x34 | CMD_LED_EXIT_DIMMING_MODE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ 已實現 | ❌ **未處理** | - |

---

### 2. Dosing Opcodes（0x60-0x7E）

### reef-b-app Android 定義的所有 Dosing Opcodes

| Opcode | 名稱 | 類型 | Payload 長度 | 狀態值 | reef-b-app Android 處理 | koralcore 狀態 | 備註 |
|--------|------|------|--------------|--------|------------------------|----------------|------|
| 0x60 | CMD_DROP_TIME_CORRECTION | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x61 | CMD_DROP_SET_DELAY | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x62 | CMD_DROP_SET_SPEED | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x63 | CMD_DROP_START_DROP | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS, 0x02=FAILED_ING | ✅ 已實現 | ❌ **未處理** | - |
| 0x64 | CMD_DROP_END_DROP | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x65 | CMD_DROP_SYNC_INFORMATION | Status | 4 | 0x00=FAILED, 0x01=START, 0x02=END | ✅ 已實現 | ❌ **未處理** | **關鍵：Dosing Sync** |
| 0x66 | CMD_DROP_RETURN_DELAY_TIME | Data Return | 5 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x67 | CMD_DROP_RETURN_ROTATING_SPEED | Data Return | 5 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x68 | CMD_DROP_RETURN_SINGLE_DROP_TIMING | Data Return | 12 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x69 | CMD_DROP_RETURN_24HR_DROP_WEEKLY | Data Return | 14 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x6A | CMD_DROP_RETURN_24HR_DROP_RANGE | Data Return | 13 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x6B | CMD_DROP_RETURN_CUSTOM_DROP_WEEKLY | Data Return | 12 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x6C | CMD_DROP_RETURN_CUSTOM_DROP_RANGE | Data Return | 11 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x6D | CMD_DROP_RETURN_CUSTOM_DROP_DETAIL | Data Return | 12 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x6E | CMD_DROP_SINGLE_DROP_IMMEDIATELY | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x6F | CMD_DROP_SINGLE_DROP_TIMELY | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x70 | CMD_DROP_24HR_DROP_WEEKLY | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x71 | CMD_DROP_24HR_DROP_RANGE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x72 | CMD_DROP_CUSTOM_DROP_WEEKLY | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x73 | CMD_DROP_CUSTOM_DROP_RANGE | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x74 | CMD_DROP_CUSTOM_DROP_DETAIL | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ✅ **僅發送命令** | koralcore 有 encoder，但無 ACK 處理 |
| 0x75 | CMD_DROP_ADJUST | ACK | 4 | 0x00=FAILED, 0x01=START, 0x02=END | ✅ 已實現 | ❌ **未處理** | - |
| 0x76 | CMD_DROP_ADJUST_RESULT | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x77 | CMD_DROP_GET_ADJUST_HISTORY | Data Return | 4 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x78 | CMD_DROP_RETURN_ADJUST_HISTORY_DETAIL | Data Return | 13 | - | ✅ 已實現 | ❌ **未處理** | - |
| 0x79 | CMD_DROP_CLEAR_RECORD | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x7A | CMD_DROP_GET_TODAY_TOTAL_VOLUME | Data Return | 8 | - | ✅ 已實現 | ✅ **已處理** | koralcore 有 `DoserRepositoryImpl.readTodayTotals()` |
| 0x7B | CMD_DROP_GET_WARNING | Data Return? | - | - | ❌ **定義但未處理** | ❌ **未處理** | Android 未實作 |
| 0x7C | CMD_DROP_WRITE_USER_ID | ACK? | - | - | ❌ **定義但未處理** | ❌ **未處理** | Android 未實作 |
| 0x7D | CMD_DROP_RESET | ACK | 4 | 0x00=FAILED, 0x01=SUCCESS | ✅ 已實現 | ❌ **未處理** | - |
| 0x7E | CMD_DROP_GET_TODAY_TOTAL_VOLUME_DECIMAL | Data Return | 8 | - | ✅ 已實現 | ✅ **已處理** | koralcore 有 `DoserRepositoryImpl.readTodayTotals()` |

**重要發現**：
- ❌ **koralcore 完全沒有 Dosing BLE repository implementation**（類似 `ble_led_repository_impl.dart`）
- ✅ koralcore 只有 `DoserRepositoryImpl` 處理 `readTodayTotals`（0x7A/0x7E）
- ❌ koralcore **缺少所有其他 Dosing opcodes 的處理**（0x60-0x79, 0x7B-0x7D）
- ❌ koralcore **沒有處理 Dosing sync（0x65）**
- ❌ koralcore **沒有處理 Dosing data returns（0x66-0x6D, 0x77, 0x78）**
- ❌ koralcore **沒有處理 Dosing ACKs（0x60-0x64, 0x6E-0x76, 0x79, 0x7D）**

---

## 二、詳細差異分析

### A. LED Opcodes 差異

### 1. 0x20 - TIME_CORRECTION ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_TIME_CORRECTION.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledTimeCorrectionState(COMMAND_STATUS.FAILED)
        0x01 -> ledTimeCorrectionState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法

**Parity 需求：**
- ✅ 添加 `case 0x20:` 處理
- ✅ 實現 `_handleTimeCorrectionAck` 方法
- ✅ 更新狀態（可選，因為 koralcore 可能沒有對應的狀態）

---

### 2. 0x27 - SET_RECORD ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_SET_RECORD.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledSetRecordState(COMMAND_STATUS.FAILED)
        0x01 -> ledSetRecordState(COMMAND_STATUS.SUCCESS)
    }
}
```

**reef-b-app ViewModel 處理（成功時）：**
```kotlin
when (setLedRecord) {
    COMMAND_STATUS.SUCCESS -> {
        ledInformation.addRecord(LedRecord(...))
        _setRecordLiveData.postValue(true)
    }
    else -> {
        _setRecordLiveData.postValue(false)
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法
- ✅ `setRecord` 方法已實現（發送命令）
- ❌ ACK 成功後未更新 cache

**Parity 需求：**
- ✅ 添加 `case 0x27:` 處理
- ✅ 實現 `_handleSetRecordAck` 方法
- ✅ ACK 成功時，將 pending record 添加到 cache（類似 ViewModel 的 `addRecord`）
- ✅ 完成 record mutation future

---

### 3. 0x2B - START_RECORD ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_START_RECORD.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledStartRecordState(COMMAND_STATUS.FAILED)
        0x01 -> {
            ledInformation?.setMode(LedMode.RECORD)
            ledStartRecordState(COMMAND_STATUS.SUCCESS)
        }
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法
- ✅ `startRecordPlayback` 方法已實現（發送命令）

**Parity 需求：**
- ✅ 添加 `case 0x2B:` 處理
- ✅ 實現 `_handleStartRecordAck` 方法
- ✅ ACK 成功時，設置 `session.cache.setMode(LedMode.record)`
- ✅ 更新狀態並發送通知

---

### 4. 0x2E - RESET ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_RESET.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledResetState(COMMAND_STATUS.FAILED)
        0x01 -> ledResetState(COMMAND_STATUS.SUCCESS)
    }
}
```

**reef-b-app ViewModel 處理（成功時）：**
```kotlin
when (ledReset) {
    COMMAND_STATUS.SUCCESS -> {
        dbResetDevice(DeviceReset(nowDevice.id))
        _resetDeviceLiveData.postValue(true)
    }
    else -> {
        _loadingLiveData.postValue(false)
        _resetDeviceLiveData.postValue(false)
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法
- ✅ `resetToDefault` 方法已實現（發送命令並觸發 sync）

**Parity 需求：**
- ✅ 添加 `case 0x2E:` 處理
- ✅ 實現 `_handleResetAck` 方法
- ✅ ACK 成功時，確認 reset 完成（koralcore 已在 `resetToDefault` 中處理 invalidate + sync）

---

### 5. 0x32 - ENTER_DIMMING_MODE ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_ENTER_DIMMING_MODE.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledEnterDimmingModeState(COMMAND_STATUS.FAILED)
        0x01 -> ledEnterDimmingModeState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法
- ❌ 沒有發送命令的方法（需要檢查是否有 UI 觸發）

**Parity 需求：**
- ✅ 添加 `case 0x32:` 處理
- ✅ 實現 `_handleEnterDimmingModeAck` 方法
- ✅ 更新狀態（可選，視 koralcore 是否有對應的狀態）

---

### 6. 0x34 - EXIT_DIMMING_MODE ACK

**reef-b-app 行為：**
```kotlin
CommandID.CMD_LED_EXIT_DIMMING_MODE.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> ledExitDimmingModeState(COMMAND_STATUS.FAILED)
        0x01 -> ledExitDimmingModeState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ❌ 未在 `_handleDevicePacket` 中處理
- ❌ 沒有對應的 handler 方法
- ❌ 沒有發送命令的方法（需要檢查是否有 UI 觸發）

**Parity 需求：**
- ✅ 添加 `case 0x34:` 處理
- ✅ 實現 `_handleExitDimmingModeAck` 方法
- ✅ 更新狀態（可選，視 koralcore 是否有對應的狀態）

---

### B. Dosing Opcodes 差異

#### 1. 0x65 - DROP_SYNC_INFORMATION（關鍵缺失）

**reef-b-app 行為：**
```kotlin
CommandID.CMD_DROP_SYNC_INFORMATION.value -> {
    if (data.size != 4) return
    when (data[2]) {
        0x00 -> dropSyncInformationState(COMMAND_STATUS.FAILED)
        0x01 -> {
            dropInformation?.clearInformation()
            dropSyncInformationState(COMMAND_STATUS.START)
        }
        0x02 -> dropSyncInformationState(COMMAND_STATUS.END)
    }
}
```

**reef-b-app ViewModel 處理：**
```kotlin
when (dropSyncInformationState) {
    COMMAND_STATUS.START -> {
        _loadingLiveData.postValue(true)
    }
    COMMAND_STATUS.END -> {
        bleGetTotalDrop(0)  // 開始查詢今日總滴液量
    }
    else -> {
        _loadingLiveData.postValue(false)
    }
}
```

**koralcore 現狀：**
- ❌ **完全沒有處理**：koralcore 沒有 Dosing BLE repository implementation
- ❌ 沒有對應的 `_handleDevicePacket` 處理 Dosing opcodes
- ❌ 沒有 Dosing 狀態管理（類似 `_LedInformationCache`）

**Parity 需求：**
- ✅ **需要創建 `BleDosingRepositoryImpl`**（類似 `BleLedRepositoryImpl`）
- ✅ 實現 Dosing sync START/END/FAILED 處理
- ✅ 實現 Dosing 狀態管理（類似 `DropInformation`）

---

#### 2. 0x66-0x6D - Dosing Data Returns（全部缺失）

**reef-b-app 行為：**
- 0x66: `dropReturnDelayTime(delayTime)` → 更新 `DropInformation.delay`
- 0x67: `dropReturnRotatingSpeed(headNo, rotatingRate)` → 更新 `DropInformation.mode[headNo].rotatingSpeed`
- 0x68: `dropInformation.setMode(headId, DropHeadMode(mode=SINGLE, ...))` → 更新單次滴液模式
- 0x69: `dropInformation.setMode(headId, DropHeadMode(mode=_24HR, runDay=..., ...))` → 更新 24h 均等滴液（週固定天數）
- 0x6A: `dropInformation.setMode(headId, DropHeadMode(mode=_24HR, timeString=..., ...))` → 更新 24h 均等滴液（時間範圍）
- 0x6B: `dropInformation.setMode(headId, DropHeadMode(mode=CUSTOM, runDay=..., ...))` → 更新客製化滴液（週固定天數）
- 0x6C: `dropInformation.setMode(headId, DropHeadMode(mode=CUSTOM, timeString=..., ...))` → 更新客製化滴液（時間範圍）
- 0x6D: `dropInformation.setDetail(headId, DropHeadRecordDetail(...))` → 更新客製化滴液細項

**koralcore 現狀：**
- ❌ **完全沒有處理**：所有 Dosing data returns 都沒有處理

**Parity 需求：**
- ✅ 實現所有 Dosing data return opcodes 的解析
- ✅ 即時更新 Dosing 狀態（類似 LED 的即時更新）

---

#### 3. 0x60-0x64, 0x6E-0x76, 0x79, 0x7D - Dosing ACKs（全部缺失）

**reef-b-app 行為：**
- 所有 ACK opcodes 都根據 `data[2]` 判斷成功/失敗
- ViewModel 根據 ACK 結果更新狀態或觸發後續操作

**koralcore 現狀：**
- ❌ **完全沒有處理**：所有 Dosing ACK opcodes 都沒有處理
- ✅ koralcore 有 encoder 可以發送命令（0x6E, 0x6F, 0x70-0x74），但沒有處理 ACK

**Parity 需求：**
- ✅ 實現所有 Dosing ACK opcodes 的處理
- ✅ 根據 ACK 結果更新狀態

---

#### 4. 0x75-0x78 - Dosing Adjust（全部缺失）

**reef-b-app 行為：**
- 0x75: `dropStartAdjustState(COMMAND_STATUS.START/END/FAILED)` → 開始/結束校正
- 0x76: `dropAdjustResultState(COMMAND_STATUS.SUCCESS/FAILED)` → 校正結果
- 0x77: `dropGetAdjustHistorySize(size)` → 取得校正歷史數量
- 0x78: `dropInformation.setHistory(headId, DropAdjustHistory(...))` → 更新校正歷史詳情

**koralcore 現狀：**
- ❌ **完全沒有處理**

**Parity 需求：**
- ✅ 實現 Dosing adjust 相關 opcodes 的處理

---

## 三、已實現但需確認的項目（LED）

### 1. 0x21 - SYNC_INFORMATION

**reef-b-app 行為：**
- START (0x01): `ledInformation?.clearInformation()`
- END (0x02): 僅通知 ViewModel，ViewModel 讀取 `ledInformation` 狀態
- FAILED (0x00): 通知 ViewModel

**koralcore 現狀：**
- ✅ START: `session.cache.handleSyncStart()`（應包含 clear）
- ✅ END: `_finalizeSync(session)`
- ✅ FAILED: `session.cache.finishSync()`

**需確認：**
- ✅ `handleSyncStart()` 是否正確清除所有資訊（mode, records, scenes）

---

### 2. 0x23 - RETURN_RECORD

**reef-b-app 行為：**
```kotlin
if (ledInformation?.getMode() == LedMode.NONE) {
    ledInformation?.setMode(LedMode.RECORD)
}
ledInformation?.addRecord(LedRecord(...))
```

**koralcore 現狀：**
- ✅ 已實現相同的邏輯

**需確認：**
- ✅ `saveRecord` 是否等同於 `addRecord`（應處理重複時間點的更新）

---

### 3. 0x24 - RETURN_PRESET_SCENE

**reef-b-app 行為：**
```kotlin
ledInformation?.setMode(LedMode.PRESET_SCENE)
ledInformation?.setPresetScene(data[2])
```

**koralcore 現狀：**
- ✅ 已實現相同的邏輯

---

### 4. 0x25 - RETURN_CUSTOM_SCENE

**reef-b-app 行為：**
```kotlin
ledInformation?.setMode(LedMode.CUSTOM_SCENE)
ledInformation?.setCustomScene(data[2..10])
```

**koralcore 現狀：**
- ✅ 已實現相同的邏輯

---

### 5. 0x28 - USE_PRESET_SCENE ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledUsePresetSceneState(COMMAND_STATUS.FAILED)
    0x01 -> {
        ledInformation?.setMode(LedMode.PRESET_SCENE)
        ledUsePresetSceneState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handlePresetSceneAck`
- ✅ 成功時設置 mode 和 scene

---

### 6. 0x29 - USE_CUSTOM_SCENE ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledUseCustomSceneState(COMMAND_STATUS.FAILED)
    0x01 -> {
        ledInformation?.setMode(LedMode.CUSTOM_SCENE)
        ledUseCustomSceneState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handleCustomSceneAck`
- ✅ 成功時設置 mode 和 scene

---

### 7. 0x2A - PREVIEW ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledPreviewState(COMMAND_STATUS.FAILED)
    0x01 -> ledPreviewState(COMMAND_STATUS.START)
    0x02 -> ledPreviewState(COMMAND_STATUS.END)
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handlePreviewAck`
- ✅ 處理所有三種狀態

---

### 8. 0x2F - DELETE_RECORD ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledDeleteRecordState(COMMAND_STATUS.FAILED)
    0x01 -> ledDeleteRecordState(COMMAND_STATUS.SUCCESS)
}
```

**reef-b-app ViewModel 處理（成功時）：**
```kotlin
when (ledDeleteRecord) {
    COMMAND_STATUS.SUCCESS -> {
        ledInformation.deleteRecord(deleteRecord.hour, deleteRecord.minute)
        _deleteRecordLiveData.postValue(true)
    }
    else -> {
        _deleteRecordLiveData.postValue(false)
    }
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handleDeleteRecordAck`
- ✅ 成功時調用 `session.cache.removeRecord(recordId)`

---

### 9. 0x30 - CLEAR_RECORD ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledClearRecordState(COMMAND_STATUS.FAILED)
    0x01 -> {
        ledInformation?.clearRecord()
        ledClearRecordState(COMMAND_STATUS.SUCCESS)
    }
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handleClearRecordsAck`
- ✅ 成功時調用 `session.cache.clearRecords()`

---

### 10. 0x33 - DIMMING ACK

**reef-b-app 行為：**
```kotlin
when (data[2]) {
    0x00 -> ledDimmingState(COMMAND_STATUS.FAILED)
    0x01 -> ledDimmingState(COMMAND_STATUS.SUCCESS)
}
```

**koralcore 現狀：**
- ✅ 已實現 `_handleChannelLevels`
- ✅ 正確處理 ACK（非資料回傳）

---

## 四、實作計畫

### Phase 0: 創建 Dosing BLE Repository Implementation（最高優先級）

**問題**：koralcore **完全沒有 Dosing BLE repository implementation**，需要從零開始創建。

**實作內容：**
1. **創建 `BleDosingRepositoryImpl`**（類似 `BleLedRepositoryImpl`）
   - 實現 `_handleDevicePacket` 處理所有 Dosing opcodes（0x60-0x7E）
   - 實現 Dosing 狀態管理（類似 `_LedInformationCache`，對應 `DropInformation`）
   - 實現多裝置管理（類似 `_DeviceSession`）

2. **實現 Dosing Sync（0x65）**
   - START: 清除 Dosing 狀態
   - END: 完成 sync 並發送狀態通知
   - FAILED: 處理錯誤

3. **實現所有 Dosing Data Returns（0x66-0x6D, 0x77, 0x78）**
   - 解析 payload
   - 即時更新 Dosing 狀態（類似 LED 的即時更新）

4. **實現所有 Dosing ACKs（0x60-0x64, 0x6E-0x76, 0x79, 0x7D）**
   - 根據 ACK 結果更新狀態

**參考架構：**
- `BleLedRepositoryImpl` 作為參考架構
- `DropInformation.kt` 作為狀態管理參考
- `CommandManager.kt` 的 Dosing opcodes 處理邏輯作為行為參考

---

### Phase 1: 添加缺失的 LED Opcode 處理（高優先級）

### Phase 1: 添加缺失的 Opcode 處理（高優先級 - 必須實作）

1. **0x27 - SET_RECORD ACK**
   - 添加 `case 0x27:` 到 `_handleDevicePacket`
   - 實現 `_handleSetRecordAck` 方法
   - ACK 成功時，從 pending 狀態添加 record 到 cache
   - 完成 record mutation future
   - **reef-b-app ViewModel 行為**：成功時調用 `ledInformation.addRecord(LedRecord(...))`

2. **0x2B - START_RECORD ACK**
   - 添加 `case 0x2B:` 到 `_handleDevicePacket`
   - 實現 `_handleStartRecordAck` 方法
   - ACK 成功時，設置 `mode = LedMode.record`
   - **reef-b-app 行為**：`ledInformation?.setMode(LedMode.RECORD)`

3. **0x2E - RESET ACK**
   - 添加 `case 0x2E:` 到 `_handleDevicePacket`
   - 實現 `_handleResetAck` 方法
   - 確認 reset 完成（koralcore 已在發送命令後處理 invalidate + sync）
   - **reef-b-app ViewModel 行為**：成功時調用 `dbResetDevice(DeviceReset(nowDevice.id))`

### Phase 2: 添加可選的 Opcode 處理（中優先級 - 建議實作）

4. **0x20 - TIME_CORRECTION ACK**
   - 添加 `case 0x20:` 到 `_handleDevicePacket`
   - 實現 `_handleTimeCorrectionAck` 方法
   - 更新狀態（如果 koralcore 有對應的狀態）
   - **reef-b-app ViewModel 行為**：成功時觸發 sync

5. **0x32 - ENTER_DIMMING_MODE ACK**
   - 添加 `case 0x32:` 到 `_handleDevicePacket`
   - 實現 `_handleEnterDimmingModeAck` 方法
   - 更新狀態

6. **0x34 - EXIT_DIMMING_MODE ACK**
   - 添加 `case 0x34:` 到 `_handleDevicePacket`
   - 實現 `_handleExitDimmingModeAck` 方法
   - 更新狀態

### Phase 3: 不實作的 Opcode（對照 Android 行為）

7. **0x2C - GET_WARNING**
   - ❌ **不實作**：reef-b-app Android 定義了但未處理
   - iOS 有實作，但我們對照 Android 版

8. **0x2D - WRITE_USER_ID**
   - ❌ **不實作**：reef-b-app Android 定義了但未處理
   - iOS 有實作，但我們對照 Android 版

9. **0x31 - DYNAMIC_SCENE_END**
   - ❌ **不實作**：reef-b-app Android 定義了但未處理
   - iOS 有實作，但我們對照 Android 版

### Phase 3: 驗證與測試

7. **驗證所有已實現的 opcode**
   - 確認 payload 長度驗證
   - 確認狀態更新邏輯
   - 確認錯誤處理

8. **對照 ViewModel 行為**
   - 確認 koralcore 的狀態更新與 reef-b-app ViewModel 一致
   - 確認 UI 通知時機

---

## 五、實作細節

### 1. SET_RECORD ACK 處理

**需要追蹤的狀態：**
- `pendingRecordData`: 儲存待確認的 record 資料（hour, minute, channels）
- 在 `setRecord` 方法中設置 pending 狀態
- ACK 成功時，從 pending 狀態創建 `LedRecord` 並添加到 cache

**實作範例：**
```dart
void _handleSetRecordAck(_DeviceSession session, Uint8List data) {
  if (data.length != 4) {
    return;
  }
  final bool success = (data[2] & 0xFF) == 0x01;
  if (success) {
    // 從 pending 狀態添加 record
    final pending = session.cache.pendingRecordData;
    if (pending != null) {
      final record = LedRecord(
        id: _recordIdForMinutes(pending.minutesFromMidnight),
        minutesFromMidnight: pending.minutesFromMidnight,
        channelLevels: pending.channelLevels,
      );
      session.cache.saveRecord(record);
      session.cache.pendingRecordData = null;
    }
    session.cache.recordStatus = LedRecordStatus.idle;
    session.resolveRecordMutationSuccess();
  } else {
    session.cache.recordStatus = LedRecordStatus.error;
    session.resolveRecordMutationFailure();
  }
  _emitRecordState(session);
}
```

### 2. START_RECORD ACK 處理

**實作範例：**
```dart
void _handleStartRecordAck(_DeviceSession session, Uint8List data) {
  if (data.length != 4) {
    return;
  }
  final bool success = (data[2] & 0xFF) == 0x01;
  if (success) {
    session.cache.setMode(LedMode.record);
    session.cache.status = LedStatus.idle;
  } else {
    session.cache.status = LedStatus.error;
  }
  _emitLedState(session);
}
```

### 3. RESET ACK 處理

**實作範例：**
```dart
void _handleResetAck(_DeviceSession session, Uint8List data) {
  if (data.length != 4) {
    return;
  }
  final bool success = (data[2] & 0xFF) == 0x01;
  // koralcore 已在 resetToDefault() 中處理 invalidate + sync
  // 這裡只需要確認狀態
  session.cache.status = success ? LedStatus.idle : LedStatus.error;
  _emitLedState(session);
}
```

---

## 六、檢查清單

### 必須實作（最高優先級 - Phase 0：Dosing）
- [ ] 創建 `BleDosingRepositoryImpl`（類似 `BleLedRepositoryImpl`）
- [ ] 實現 Dosing 狀態管理（類似 `_LedInformationCache`）
- [ ] 實現 Dosing sync（0x65）處理
- [ ] 實現所有 Dosing data returns（0x66-0x6D, 0x77, 0x78）
- [ ] 實現所有 Dosing ACKs（0x60-0x64, 0x6E-0x76, 0x79, 0x7D）

### 必須實作（高優先級 - Phase 1：LED）
- [ ] 0x27 - SET_RECORD ACK 處理
- [ ] 0x2B - START_RECORD ACK 處理
- [ ] 0x2E - RESET ACK 處理

### 建議實作（中優先級 - Phase 2：LED）
- [ ] 0x20 - TIME_CORRECTION ACK 處理
- [ ] 0x32 - ENTER_DIMMING_MODE ACK 處理
- [ ] 0x34 - EXIT_DIMMING_MODE ACK 處理

### 不實作（對照 Android 行為 - Phase 3：LED）
- [x] 0x2C - GET_WARNING（Android 未實作，不處理）
- [x] 0x2D - WRITE_USER_ID（Android 未實作，不處理）
- [x] 0x31 - DYNAMIC_SCENE_END（Android 未實作，不處理）

### 驗證項目
- [ ] 所有 opcode 的 payload 長度驗證與 reef-b-app 一致
- [ ] 所有狀態更新邏輯與 reef-b-app 一致
- [ ] 錯誤處理與 reef-b-app 一致
- [ ] UI 通知時機與 reef-b-app 一致（sync 期間不發送，僅在 END 發送）

---

## 七、重要發現

### reef-b-app Android 架構分析

1. **多裝置管理**
   - `BleContainer`：單例，管理所有裝置的 `BLEManager`、`LedInformation`、`DropInformation`
   - 每個裝置用 `macAddress` 作為 key
   - `LedInformation` 和 `DropInformation` 是簡單的狀態容器，沒有複雜邏輯

2. **狀態管理**
   - `LedInformation` 儲存：`mode`、`records`、`presetScene`、`customScene`、`nowScene`
   - 所有狀態更新都是**即時更新**，沒有緩存機制
   - `addRecord()` 會檢查重複時間點，如果存在則更新，否則新增並排序

3. **ViewModel 回呼模式**
   - `CommandManager.parseCommand()` 接受大量 lambda 回呼
   - ViewModel 只處理自己關心的回呼，其他傳空 lambda
   - sync END 時，ViewModel 讀取 `ledInformation` 的完整狀態並更新 LiveData

4. **未實作的 Opcode**
   - 0x2C、0x2D、0x31 在 `CommandID` enum 中有定義，但在 `parseCommand()` 的 `when` 語句中**沒有處理**
   - 這表示這些 opcode 在 Android 版中**定義但未實作**
   - iOS 版有實作這些 opcode，但我們對照 Android 版，所以**不需要實作**

## 八、注意事項

1. **reef-b-app Android 是唯一參考來源**：所有實作必須嚴格對照 reef-b-app Android 版
2. **不改變 Domain/Application 層**：只修改 Infrastructure 層
3. **狀態更新時機**：sync 期間不發送 UI 通知，僅在 sync END 發送
4. **即時更新**：所有 RETURN opcode 立即更新 cache，不緩存
5. **ACK 處理**：所有 ACK opcode 根據結果更新狀態並發送通知
6. **未實作的 Opcode**：
   - LED: 0x2C、0x2D、0x31 在 Android 中未實作，koralcore 也不需要實作
   - Dosing: 0x7B、0x7C 在 Android 中未實作，koralcore 也不需要實作
7. **Dosing 實作優先級**：Dosing BLE repository implementation 是最高優先級，因為 koralcore 目前完全沒有實作

