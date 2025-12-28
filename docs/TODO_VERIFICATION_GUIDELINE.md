# TODO 事項驗證準則

## 重要原則

**⚠️ TODO 事項不一定正確，要以 reef-b-app 為主**

---

## 驗證流程

### 步驟 1: 識別 TODO 事項

在 koralcore 中搜索所有 TODO 註釋：
```bash
grep -r "TODO" lib/infrastructure/
```

### 步驟 2: 對照 reef-b-app

對於每個 TODO：
1. **檢查 reef-b-app 的實際實現**
2. **確認 TODO 是否準確**
3. **如果 TODO 不準確，以 reef-b-app 為準**

### 步驟 3: 更新或移除 TODO

- ✅ **如果 TODO 準確**：保留並標註驗證狀態
- ❌ **如果 TODO 不準確**：移除或修正
- ⚠️ **如果不確定**：標註為「待驗證」，並記錄 reef-b-app 的實際行為

---

## 當前 TODO 事項清單

### LED Repository

#### 1. `_parseScheduleReturn` - Schedule 解析

**位置**: `lib/infrastructure/led/ble_led_repository_impl.dart:522`

**TODO 內容**:
```dart
// TODO: Map schedule payload fields per reef-b-app (see Android LedSyncInformationCommand schedule parsing).
// Expected fields: scheduleId/code, enabled flag, window start/end minutes, recurrence label, channel levels.
```

**驗證狀態**: ⚠️ **待驗證**
- 需要檢查 reef-b-app 的 `LedSyncInformationCommand` 是否真的解析 schedule
- 需要確認 0x26 (RETURN_SCHEDULE) 是否在 reef-b-app 中實現

**行動**: 檢查 reef-b-app 的實際實現

---

#### 2. `_handleMutationAck` - Mutation ACK 處理

**位置**: `lib/infrastructure/led/ble_led_repository_impl.dart:907`

**TODO 內容**:
```dart
// TODO: Align with reef-b-app acks (delete/clear/record changes).
```

**驗證狀態**: ⚠️ **待驗證**
- 需要檢查 reef-b-app 的 `_handleMutationAck` 實際處理邏輯
- 需要確認是否與 reef-b-app 完全一致

**行動**: 檢查 reef-b-app 的 `CommandManager.kt` 中 mutation ACK 的處理

---

### Dosing Repository

#### 3. `_handleGetAdjustHistoryAck` - Adjust History ACK

**位置**: `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:904`

**TODO 內容**:
```dart
// TODO: Track pending headNo for adjust history commands
```

**驗證狀態**: ⚠️ **待驗證**
- 需要檢查 reef-b-app 是否追蹤 pending headNo
- 需要確認 ACK 處理是否需要 headNo 上下文

**行動**: 檢查 reef-b-app 的 `CommandManager.kt` 中 adjust history ACK 的處理

---

#### 4. `_handleClearRecordAck` - Clear Record ACK

**位置**: `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:924`

**TODO 內容**:
```dart
// TODO: Track pending headId for clear record commands
```

**驗證狀態**: ⚠️ **待驗證**
- 需要檢查 reef-b-app 是否追蹤 pending headId
- 需要確認 ACK 處理是否需要 headId 上下文

**行動**: 檢查 reef-b-app 的 `CommandManager.kt` 中 clear record ACK 的處理

---

## 驗證方法

### 1. 檢查 reef-b-app 的 CommandManager.kt

```kotlin
// 搜索對應的 opcode 處理
when (data[0]) {
    CommandID.CMD_LED_RETURN_SCHEDULE.value -> {
        // 檢查實際處理邏輯
    }
}
```

### 2. 檢查 reef-b-app 的 ViewModel

```kotlin
// 檢查 ViewModel 如何使用 ACK 結果
when (ledMutationAck) {
    COMMAND_STATUS.SUCCESS -> {
        // 檢查實際行為
    }
}
```

### 3. 檢查 reef-b-app 的 Information 類

```kotlin
// 檢查 LedInformation 或 DropInformation 的實際更新邏輯
ledInformation?.setSchedule(...)
```

---

## 驗證檢查清單

對於每個 TODO：

- [ ] 是否在 reef-b-app 中實現？
- [ ] reef-b-app 的實際行為是什麼？
- [ ] koralcore 的 TODO 是否準確？
- [ ] 是否需要修正或移除 TODO？
- [ ] 是否需要實現對應功能？

---

## 注意事項

1. **不要盲目相信 TODO**
   - TODO 可能是過時的
   - TODO 可能是基於假設的
   - TODO 可能不準確

2. **以 reef-b-app 為準**
   - 如果 TODO 與 reef-b-app 不符，以 reef-b-app 為準
   - 如果 reef-b-app 未實現，TODO 可能不需要

3. **記錄驗證結果**
   - 驗證後更新 TODO 註釋
   - 記錄 reef-b-app 的實際行為
   - 標註驗證日期和狀態

---

## 下一步行動

1. **系統性檢查所有 TODO**
   - 列出所有 TODO 事項
   - 逐一對照 reef-b-app

2. **更新或移除不準確的 TODO**
   - 移除過時的 TODO
   - 修正不準確的 TODO
   - 保留準確的 TODO

3. **實現缺失的功能**
   - 如果 TODO 準確且需要實現
   - 按照 reef-b-app 的實際行為實現

---

## 範例：驗證 TODO

### 範例 1: Schedule 解析 TODO

**TODO**:
```dart
// TODO: Map schedule payload fields per reef-b-app
```

**驗證步驟**:
1. 檢查 reef-b-app 的 `CommandManager.kt`
2. 搜索 `CMD_LED_RETURN_SCHEDULE` (0x26)
3. 發現：reef-b-app **未實現** 0x26

**結果**:
- ✅ TODO 準確：reef-b-app 確實未實現
- ✅ 當前實現正確：返回 null
- ✅ 保留 TODO，但標註「reef-b-app 未實現」

---

### 範例 2: Mutation ACK TODO

**TODO**:
```dart
// TODO: Align with reef-b-app acks
```

**驗證步驟**:
1. 檢查 reef-b-app 的 `CommandManager.kt`
2. 搜索 `CMD_LED_MUTATION_ACK` (0x2F)
3. 發現：reef-b-app 有實現，但行為可能不同

**結果**:
- ⚠️ TODO 需要驗證：檢查實際行為是否一致
- ⚠️ 如果一致：移除 TODO
- ⚠️ 如果不一致：修正實現

---

## 總結

**核心原則**：
- ⚠️ **TODO 事項不一定正確**
- ✅ **要以 reef-b-app 為主**
- 🔍 **驗證後再行動**

