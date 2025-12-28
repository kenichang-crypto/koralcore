# LED BLE Parity 計畫

**目標**：讓 koralcore 的 LED BLE 行為完全對照 reef-b-app（Android/iOS）

**約束條件**：
- reef-b-app 為**只讀**參考來源，不可修改
- Domain 層（`LedState`, `LedStateSchedule`, `LedRecord` 等）**不可動**
- Application/UseCase 層**不可動**
- 僅修改 Infrastructure 層（`ble_led_repository_impl.dart`）

---

## 階段 1：修正 Sync END 處理機制

### 1.1 問題描述
- **目前**：koralcore 使用 opcode `0xFF` 作為 sync end
- **reef-b-app**：使用 `0x21` + `data[2] == 0x02` 作為 sync end
- **影響範圍**：`_handleDevicePacket()` 的 switch case

### 1.2 修改內容

#### 修改 1：移除 0xFF opcode 定義
```dart
// 刪除這行
static const int _opcodeSyncEnd = 0xFF;
```

#### 修改 2：修改 0x21 處理邏輯
```dart
case _opcodeSyncStart:
  // 檢查 data[2] 的值
  if (data.length < 3) {
    return; // 無效 payload
  }
  final int status = data[2] & 0xFF;
  switch (status) {
    case 0x01: // Sync START
      session.cache.status = LedStatus.syncing;
      session.cache.recordStatus = LedRecordStatus.idle;
      session.cache.handleSyncStart();
      break;
    case 0x02: // Sync END
      // 直接完成 sync，無需 _finalizeSync（因為已即時更新）
      session.cache.finishSync();
      session.syncInFlight = false;
      _emitLedState(session);
      _emitRecordState(session);
      break;
    case 0x00: // Sync FAILED
      session.cache.finishSync();
      session.syncInFlight = false;
      break;
  }
  break;
```

#### 修改 3：移除 0xFF case
```dart
// 刪除這個 case
case _opcodeSyncEnd:
  _finalizeSync(session);
  break;
```

### 1.3 測試檢查點
- [ ] Sync START (0x21 + 0x01) 正確觸發 `handleSyncStart()`
- [ ] Sync END (0x21 + 0x02) 正確完成 sync 並發送狀態
- [ ] Sync FAILED (0x21 + 0x00) 正確處理錯誤
- [ ] 不再處理 0xFF opcode

---

## 階段 2：移除 _SyncSession 暫存機制，改為即時更新

### 2.1 問題描述
- **目前**：koralcore 使用 `_SyncSession` 暫存 scenes/records，在 sync END 時統一套用
- **reef-b-app**：收到 RETURN opcodes 時立即更新 `LedInformation`，無暫存機制
- **影響範圍**：所有 RETURN opcode handlers

### 2.2 修改內容

#### 修改 1：移除 _SyncSession 的建立
```dart
void _handleDevicePacket(_DeviceSession session, BleNotifyPacket packet) {
  final Uint8List data = packet.payload;
  if (data.isEmpty) {
    return;
  }
  if (!session.cache.isValid && !session.cache.isSyncing) {
    session.syncInFlight = false;
    return;
  }
  final int opcode = data[0] & 0xFF;
  // 刪除這行：session.activeSync ??= _SyncSession(deviceId: session.deviceId);

  switch (opcode) {
    // ...
  }
}
```

#### 修改 2：修改 _handleSceneReturn 為即時更新
```dart
void _handleSceneReturn(
  _DeviceSession session,
  Uint8List data, {
  required bool isCustom,
}) {
  final LedStateScene? scene = _parseSceneReturn(
    session,
    data,
    isCustom: isCustom,
  );
  if (scene == null) {
    return;
  }
  
  // 即時更新 cache，不再暫存到 sync
  session.cache.saveScene(scene);
  
  if (isCustom) {
    session.cache.setMode(LedMode.customScene);
    session.cache.customSceneChannels = scene.channelLevels;
  } else if (scene.presetCode != null) {
    session.cache.setMode(LedMode.presetScene);
    session.cache.presetSceneCode = scene.presetCode;
  }
  
  // 即時發送狀態（reef-b-app 無此行為，但 koralcore 需要通知 UI）
  // 注意：reef-b-app 在 sync END 時才通知 ViewModel，但 koralcore 的架構不同
  // 這裡保持即時發送，因為 Domain 層已經改變了
}
```

#### 修改 3：修改 _handleRecordReturn 為即時更新
```dart
void _handleRecordReturn(_DeviceSession session, Uint8List data) {
  final LedRecord? record = _parseRecordReturn(data);
  if (record == null) {
    return;
  }
  
  // 即時更新 cache，不再暫存到 sync
  session.cache.saveRecord(record);
  
  if (session.cache.mode == LedMode.none) {
    session.cache.setMode(LedMode.record);
  }
  
  // 即時發送狀態
  _emitRecordState(session);
}
```

#### 修改 4：移除 _SyncSession 類別
```dart
// 刪除整個 _SyncSession 類別定義（lines 1079-1117）
```

#### 修改 5：移除 _DeviceSession 中的 activeSync
```dart
class _DeviceSession {
  // ...
  // 刪除這行：_SyncSession? activeSync;
}
```

#### 修改 6：清理所有 activeSync 引用
- 刪除 `session.activeSync = null;` 的所有引用
- 刪除 `session.activeSync?.schedules.add(schedule);` 等暫存操作

### 2.3 測試檢查點
- [ ] 收到 0x24 (preset scene) 時立即更新 cache 和 mode
- [ ] 收到 0x25 (custom scene) 時立即更新 cache 和 mode
- [ ] 收到 0x23 (record) 時立即更新 cache 和 records
- [ ] 不再使用 `_SyncSession` 暫存資料
- [ ] Sync END 時不再進行狀態合併

---

## 階段 3：移除 0x33 作為資料回傳的處理

### 3.1 問題描述
- **目前**：koralcore 在 sync 過程中解析 0x33 作為 channel levels 資料回傳
- **reef-b-app**：0x33 僅作為調光命令的 ACK，不是資料回傳
- **影響範圍**：`_handleChannelLevels()` 方法

### 3.2 修改內容

#### 修改 1：修改 _handleChannelLevels 為僅處理 ACK
```dart
void _handleChannelLevels(_DeviceSession session, Uint8List data) {
  // 0x33 僅作為調光命令的 ACK，不是資料回傳
  // Payload: [0x33, 0x01, result(0x00/0x01), checksum]
  if (data.length != 4) {
    return; // 無效 payload
  }
  
  final bool success = (data[2] & 0xFF) == 0x01;
  if (success) {
    // ACK 成功，但 channel levels 已經在 setChannelLevels() 時更新
    // 這裡不需要額外處理
  }
  // 注意：reef-b-app 中 0x33 的 ACK 處理在 ViewModel 層，這裡僅記錄
}
```

#### 修改 2：移除 pendingChannels 相關邏輯
- 刪除 `_SyncSession.pendingChannels` 欄位
- 刪除 `session.activeSync!.pendingChannels = channels;` 的賦值
- 刪除 `_finalizeSync()` 中 `pendingChannels` 的套用邏輯

### 3.3 測試檢查點
- [ ] 0x33 僅作為 ACK 處理，不再解析 channel levels
- [ ] 調光命令的 channel levels 在 `setChannelLevels()` 時已更新
- [ ] Sync 過程中不再處理 0x33 作為資料回傳

---

## 階段 4：移除從 records 衍生 schedules 的邏輯

### 4.1 問題描述
- **目前**：koralcore 有 `_deriveSchedulesFromRecords()` 邏輯，將 records 轉為 schedules
- **reef-b-app**：`LedInformation` 僅儲存 records，無 schedule 概念
- **影響範圍**：`_deriveSchedulesFromRecords()`, `_rebuildSchedulesFromRecords()`, `_finalizeSync()`

### 4.2 修改內容

#### 修改 1：移除 _deriveSchedulesFromRecords 的呼叫
```dart
void _finalizeSync(_DeviceSession session) {
  // 刪除所有 schedule 相關邏輯
  // 刪除：
  //   final List<LedStateSchedule> scheduleSource = sync.schedules.isNotEmpty
  //       ? sync.schedules
  //       : _deriveSchedulesFromRecords(sync.records);
  //   if (scheduleSource.isNotEmpty) { ... }
  
  // 保留 records 的處理（但改為即時更新，所以這裡可能不需要）
  // 實際上，因為改為即時更新，_finalizeSync 可能可以簡化或移除
}
```

#### 修改 2：移除 _rebuildSchedulesFromRecords 的呼叫
```dart
void _handleRecordReturn(_DeviceSession session, Uint8List data) {
  // ...
  session.cache.saveRecord(record);
  // 刪除這行：_rebuildSchedulesFromRecords(session.cache);
  _emitRecordState(session);
}
```

#### 修改 3：標記衍生函數為 deprecated（不刪除，因為可能被測試使用）
```dart
@Deprecated('reef-b-app does not derive schedules from records. This function is kept for testing only.')
List<LedStateSchedule> _deriveSchedulesFromRecords(List<LedRecord> records) {
  // 保留實作，但標記為 deprecated
  // ...
}
```

#### 修改 4：修改 cache 的 schedules 處理
```dart
// 在 _LedInformationCache 中，schedules 欄位保留（因為 Domain 層需要）
// 但不再從 records 衍生，改為空列表或保留上次的值
// 注意：如果 Domain 層需要 schedules，這裡可能需要保留空列表
```

### 4.3 測試檢查點
- [ ] 不再從 records 衍生 schedules
- [ ] `cache.schedules` 保持為空列表或上次的值
- [ ] Domain 層的 `LedState.schedules` 仍然可用（但為空）

---

## 階段 5：移除 sync END 時的狀態合併邏輯

### 5.1 問題描述
- **目前**：koralcore 在 `_finalizeSync()` 進行狀態合併（scenes/records/schedules）
- **reef-b-app**：無合併邏輯，僅通知 ViewModel，ViewModel 直接讀取狀態
- **影響範圍**：`_finalizeSync()`, `_reconcileSceneStateFromSync()`

### 5.2 修改內容

#### 修改 1：簡化 _finalizeSync（或移除）
```dart
void _finalizeSync(_DeviceSession session) {
  // 因為改為即時更新，這裡只需要：
  session.cache.finishSync();
  session.syncInFlight = false;
  _emitLedState(session);
  _emitRecordState(session);
  
  // 刪除所有合併邏輯：
  // - sync.scenes 的處理
  // - sync.schedules 的處理
  // - sync.records 的處理
  // - _reconcileSceneStateFromSync() 的呼叫
  // - pendingChannels 的套用
}
```

#### 修改 2：移除 _reconcileSceneStateFromSync
```dart
// 刪除整個 _reconcileSceneStateFromSync() 方法（lines 688-727）
// 或標記為 deprecated
```

#### 修改 3：修改 scene state 的處理
```dart
// 在 _handleSceneReturn 中，已經即時更新了 mode 和 scene
// 不需要在 sync END 時再次調和
// 但需要確保 activeSceneId 的設定
void _handleSceneReturn(...) {
  // ...
  session.cache.saveScene(scene);
  
  if (isCustom) {
    session.cache.setMode(LedMode.customScene);
    session.cache.customSceneChannels = scene.channelLevels;
    // 設定 activeSceneId
    session.cache.activeSceneId = scene.sceneId;
    session.cache.activeScheduleId = null;
  } else if (scene.presetCode != null) {
    session.cache.setMode(LedMode.presetScene);
    session.cache.presetSceneCode = scene.presetCode;
    // 設定 activeSceneId
    session.cache.activeSceneId = scene.sceneId;
    session.cache.activeScheduleId = null;
  }
}
```

### 5.3 測試檢查點
- [ ] Sync END 時不再進行狀態合併
- [ ] Scene state 在收到 RETURN opcode 時已正確設定
- [ ] `activeSceneId` 和 `activeScheduleId` 正確設定
- [ ] 不再呼叫 `_reconcileSceneStateFromSync()`

---

## 階段 6：清理與測試

### 6.1 清理項目
- [ ] 刪除所有 `activeSync` 的引用
- [ ] 刪除 `_SyncSession` 類別定義
- [ ] 刪除 `pendingChannels` 相關邏輯
- [ ] 刪除 `_deriveSchedulesFromRecords()` 的實際使用（保留定義供測試）
- [ ] 刪除 `_rebuildSchedulesFromRecords()` 的呼叫
- [ ] 刪除 `_reconcileSceneStateFromSync()` 方法
- [ ] 刪除 `_finalizeSync()` 中的合併邏輯

### 6.2 測試策略

#### 單元測試
- [ ] 測試 0x21 + 0x01 (START) 正確觸發 `handleSyncStart()`
- [ ] 測試 0x21 + 0x02 (END) 正確完成 sync
- [ ] 測試 0x24 (preset scene) 即時更新 cache
- [ ] 測試 0x25 (custom scene) 即時更新 cache
- [ ] 測試 0x23 (record) 即時更新 cache
- [ ] 測試 0x33 僅作為 ACK，不解析 channel levels

#### 整合測試
- [ ] 完整 sync 流程測試（START → RETURN opcodes → END）
- [ ] 多個 RETURN opcodes 的順序處理
- [ ] Sync 失敗處理（0x21 + 0x00）
- [ ] 重複 sync 的處理

#### 回歸測試
- [ ] 確保 Domain 層的 `LedState` 仍然可用
- [ ] 確保 Application 層的 UseCase 仍然可用
- [ ] 確保 UI 層的 Controller 仍然可用

### 6.3 驗證檢查清單

#### 與 reef-b-app 對齊檢查
- [ ] Sync START 使用 0x21 + 0x01
- [ ] Sync END 使用 0x21 + 0x02（不是 0xFF）
- [ ] RETURN opcodes 即時更新 cache（無暫存）
- [ ] 0x33 僅作為 ACK，不解析 channel levels
- [ ] 不從 records 衍生 schedules
- [ ] Sync END 時無狀態合併邏輯

#### 功能完整性檢查
- [ ] LED sync 功能正常
- [ ] Scene 應用功能正常
- [ ] Record 管理功能正常
- [ ] Channel levels 設定功能正常

---

## 風險評估

### 高風險項目
1. **移除 _SyncSession 可能影響現有功能**
   - 緩解：逐步遷移，先改為即時更新，再移除暫存
   - 測試：完整測試所有 sync 場景

2. **移除 schedules 衍生可能影響 UI**
   - 緩解：保留 Domain 層的 `LedStateSchedule`，僅在 Infrastructure 層不衍生
   - 測試：確保 UI 能處理空 schedules 列表

### 中風險項目
1. **Sync END 邏輯簡化可能遺漏邊界情況**
   - 緩解：保留必要的狀態清理邏輯
   - 測試：測試各種 sync 失敗和重試場景

### 低風險項目
1. **0x33 處理修改影響調光功能**
   - 緩解：調光功能在 `setChannelLevels()` 時已更新，0x33 僅為 ACK
   - 測試：測試調光命令的完整流程

---

## 實作順序建議

1. **階段 1**：修正 Sync END 處理（最關鍵，影響最小）
2. **階段 3**：移除 0x33 資料回傳處理（獨立，影響小）
3. **階段 2**：移除 _SyncSession 暫存機制（核心變更，需要仔細測試）
4. **階段 4**：移除 schedules 衍生邏輯（依賴階段 2）
5. **階段 5**：移除狀態合併邏輯（依賴階段 2）
6. **階段 6**：清理與測試（最後階段）

---

## 注意事項

1. **Domain 層不可動**：所有修改僅在 Infrastructure 層
2. **向後相容**：確保 Domain 層的 `LedState` 結構不變
3. **測試覆蓋**：每個階段都需要完整測試
4. **文檔更新**：更新相關文檔說明新的行為

---

## 完成標準

- [ ] 所有階段完成
- [ ] 所有測試通過
- [ ] 與 reef-b-app 行為完全對齊
- [ ] 無回歸問題
- [ ] 文檔更新完成

