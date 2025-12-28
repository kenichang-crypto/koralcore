# TODO 驗證結果報告

## 驗證日期
2024-12-28

## 驗證原則
**⚠️ TODO 事項不一定正確，要以 reef-b-app 為主**

---

## 驗證結果

### ✅ 1. LED Schedule 解析 (0x26) - 已更新

**位置**: `lib/infrastructure/led/ble_led_repository_impl.dart:521`

**原始 TODO**:
```dart
// TODO: Map schedule payload fields per reef-b-app
```

**驗證結果**:
- ✅ **reef-b-app 未實現** 0x26 (RETURN_SCHEDULE)
- ✅ 在 `CommandManager.kt` 中沒有 `CMD_LED_RETURN_SCHEDULE` 的處理
- ✅ koralcore 返回 null 是正確的

**更新內容**:
- 移除了 TODO
- 添加了 PARITY 註釋說明 reef-b-app 未實現
- 簡化了實現，直接返回 null

**狀態**: ✅ **已修正**

---

### ✅ 2. Mutation ACK 對齊 - 已更新

**位置**: `lib/infrastructure/led/ble_led_repository_impl.dart:906`

**原始 TODO**:
```dart
// TODO: Align with reef-b-app acks (delete/clear/record changes).
```

**驗證結果**:
- ✅ **已對齊** - 檢查了 reef-b-app 的實際處理：
  - 0x2F (DELETE_RECORD): ViewModel 調用 `ledInformation.deleteRecord()` ✅
  - 0x30 (CLEAR_RECORD): ViewModel 調用 `ledInformation.clearRecord()` ✅
  - 0x27 (SET_RECORD): ViewModel 更新狀態 ✅
- ✅ koralcore 的實現已對齊（`_handleDeleteRecordAck`, `_handleClearRecordsAck`, `_handleSetRecordAck`）

**更新內容**:
- 移除了 TODO
- 添加了詳細的 PARITY 註釋說明對齊情況
- 確認 `_finalizeMutation` 的行為已對齊

**狀態**: ✅ **已修正**

---

### ⚠️ 3. Dosing Adjust History headNo 追蹤 - 已更新註釋

**位置**: `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:904`

**原始 TODO**:
```dart
// TODO: Track pending headNo for adjust history commands
```

**驗證結果**:
- ✅ **reef-b-app 確實需要 headId**
- ✅ 在 `DropHeadAdjustListViewModel.kt:196` 中：
  ```kotlin
  dropInformation.initAdjustHistory(nowDropHead.headId, dropGetAdjustHistorySize)
  ```
- ⚠️ **headId 來自 ViewModel 的上下文**（`nowDropHead.headId`），不是從 ACK payload 中獲取
- ⚠️ koralcore 需要從命令上下文中追蹤 headId

**更新內容**:
- 更新了 TODO 註釋，說明：
  - reef-b-app 的實際行為
  - headId 來自 ViewModel 上下文
  - koralcore 需要實現命令上下文追蹤
- 保留了 placeholder (0) 直到實現命令上下文追蹤

**狀態**: ⚠️ **已更新註釋，待實現命令上下文追蹤**

---

### ⚠️ 4. Dosing Clear Record headId 追蹤 - 已更新註釋

**位置**: `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:924`

**原始 TODO**:
```dart
// TODO: Track pending headId for clear record commands
```

**驗證結果**:
- ✅ **reef-b-app 確實需要 headId**
- ✅ 在 `DropHeadRecordSettingViewModel.kt:705` 中：
  ```kotlin
  dropInformation.setMode(nowDropHead.headId, DropHeadMode())
  ```
- ⚠️ **headId 來自 ViewModel 的上下文**（`nowDropHead.headId`），不是從 ACK payload 中獲取
- ⚠️ koralcore 需要從命令上下文中追蹤 headId

**更新內容**:
- 更新了 TODO 註釋，說明：
  - reef-b-app 的實際行為
  - headId 來自 ViewModel 上下文
  - koralcore 需要實現命令上下文追蹤
- 保留了當前實現（無法清除 mode）直到實現命令上下文追蹤

**狀態**: ⚠️ **已更新註釋，待實現命令上下文追蹤**

---

## 總結

### 已修正的 TODO

1. ✅ **LED Schedule 解析 (0x26)** - 確認 reef-b-app 未實現，已更新註釋
2. ✅ **Mutation ACK 對齊** - 確認已對齊，已移除 TODO

### 已更新註釋的 TODO

3. ⚠️ **Dosing Adjust History headNo** - 已更新註釋，說明需要命令上下文追蹤
4. ⚠️ **Dosing Clear Record headId** - 已更新註釋，說明需要命令上下文追蹤

### 發現

- **reef-b-app 的模式**：headId 來自 ViewModel 的上下文（如 `nowDropHead.headId`），不是從 ACK payload 中獲取
- **koralcore 的挑戰**：需要實現命令上下文追蹤，以便在發送命令時記錄 headId，並在收到 ACK 時使用

---

## 下一步行動

### 高優先級

1. **實現命令上下文追蹤**
   - 在發送命令時記錄 headId
   - 在收到 ACK 時使用記錄的 headId
   - 這將解決 Dosing Adjust History 和 Clear Record 的問題

### 低優先級

2. **其他 TODO 驗證**
   - 檢查其他 TODO 事項（如 Warning Repository 的 TODO）
   - 對照 reef-b-app 驗證準確性

---

## 驗證方法

對於每個 TODO：
1. ✅ 搜索 reef-b-app 的對應實現
2. ✅ 檢查實際行為
3. ✅ 對照 koralcore 的實現
4. ✅ 更新或移除不準確的 TODO
5. ✅ 記錄驗證結果

---

**驗證完成日期**: 2024-12-28

