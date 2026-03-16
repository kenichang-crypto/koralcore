# ACK 與 Sync 說明

## 概述

在 BLE（藍牙低功耗）通訊中，**ACK** 和 **Sync** 是兩種不同類型的訊息，用於不同的目的：

- **ACK (Acknowledgement)**：確認訊息，表示「命令已收到並處理」
- **Sync (Synchronization)**：同步訊息，用於「同步設備的完整狀態」

---

## 1. ACK (Acknowledgement) - 確認訊息

### 定義
**ACK** 是設備對**單一命令**的回應，表示該命令是否成功執行。

### 特點
- **一對一**：每個命令對應一個 ACK
- **即時回應**：命令發送後，設備立即回應 ACK
- **簡單狀態**：ACK 只告訴你「成功 (0x01)」或「失敗 (0x00)」
- **不包含數據**：ACK 通常只有 4 字節：`[opcode, len, result, checksum]`

### 範例：LED 場景套用

```dart
// 1. App 發送命令：使用預設場景 (0x28)
_sendCommand(deviceId, [0x28, 0x01, sceneCode]);

// 2. 設備回應 ACK：確認是否成功
// Payload: [0x28, 0x01, 0x01, checksum]
//          └─┬─┘ └─┬─┘ └─┬─┘
//            │     │     └─ 0x01 = 成功, 0x00 = 失敗
//            │     └─ 長度
//            └─ 相同的 opcode (0x28)

// 3. App 處理 ACK
void _handlePresetSceneAck(_DeviceSession session, Uint8List data) {
  final bool success = (data[2] & 0xFF) == 0x01;
  if (success) {
    // 更新本地狀態：場景已套用
    session.cache.setMode(LedMode.presetScene);
    session.cache.presetSceneCode = sceneCode;
  }
}
```

### ACK 的用途
1. **確認命令執行**：知道命令是否成功
2. **更新本地狀態**：根據 ACK 結果更新 App 的狀態
3. **錯誤處理**：如果 ACK 顯示失敗，可以重試或顯示錯誤

### 常見的 ACK Opcodes

#### LED 設備
- `0x28` - 使用預設場景 ACK
- `0x29` - 使用自訂場景 ACK
- `0x2A` - 預覽 ACK
- `0x2F` - 刪除紀錄 ACK
- `0x30` - 清除紀錄 ACK
- `0x32` - 進入調光模式 ACK
- `0x33` - 設定通道層級 ACK
- `0x34` - 離開調光模式 ACK

#### Dosing 設備
- `0x60` - 時間校正 ACK
- `0x61` - 設定延遲時間 ACK
- `0x62` - 設定速度 ACK
- `0x63` - 開始滴液 ACK
- `0x64` - 結束滴液 ACK
- `0x6E-0x76` - 各種排程 ACK
- `0x79` - 清除紀錄 ACK
- `0x7D` - 重置 ACK

---

## 2. Sync (Synchronization) - 同步訊息

### 定義
**Sync** 是一個**多步驟流程**，用於從設備獲取**完整的狀態資訊**（場景、紀錄、排程等）。

### 特點
- **多步驟流程**：包含 START → 多個 RETURN → END
- **完整數據**：RETURN opcodes 包含完整的狀態數據
- **批量更新**：一次 Sync 可以更新多個狀態（場景、紀錄、排程等）
- **即時更新**：收到每個 RETURN 時立即更新狀態，不需要等到 END

### Sync 流程

```
1. App 發送 Sync 請求
   └─> _sendCommand(deviceId, [0x21, 0x00])  // LED: 0x21, Dosing: 0x65

2. 設備回應 Sync START (0x21 + 0x01)
   └─> 設備開始準備發送狀態數據

3. 設備發送多個 RETURN opcodes（包含完整數據）
   └─> 0x24: RETURN_PRESET_SCENE (預設場景數據)
   └─> 0x25: RETURN_CUSTOM_SCENE (自訂場景數據)
   └─> 0x23: RETURN_RECORD (紀錄數據)
   └─> 0x26: RETURN_SCHEDULE (排程數據，但 reef-b-app 未實現)

4. 設備發送 Sync END (0x21 + 0x02)
   └─> 同步完成，通知 App 可以讀取最終狀態
```

### 範例：LED 設備同步

```dart
// 1. App 請求同步
void _requestSync(_DeviceSession session) {
  session.syncInFlight = true;
  _sendCommand(session.deviceId, _commandBuilder.syncInformation());
  // 發送: [0x21, 0x00]
}

// 2. 設備回應 Sync START
void _handleDevicePacket(_DeviceSession session, BleNotifyPacket packet) {
  switch (opcode) {
    case 0x21: // Sync Information
      final int status = data[2] & 0xFF;
      switch (status) {
        case 0x01: // Sync START
          session.cache.status = LedStatus.syncing;
          session.cache.handleSyncStart(); // 清除舊數據
          break;
        case 0x02: // Sync END
          _finalizeSync(session); // 完成同步
          break;
      }
      break;
    
    // 3. 設備發送 RETURN opcodes（包含完整數據）
    case 0x24: // RETURN_PRESET_SCENE
      _handleSceneReturn(session, data, isCustom: false);
      // 立即更新狀態：session.cache.saveScene(scene)
      break;
    
    case 0x23: // RETURN_RECORD
      _handleRecordReturn(session, data);
      // 立即更新狀態：session.cache.saveRecord(record)
      break;
  }
}

// 4. Sync END 時通知 UI
void _finalizeSync(_DeviceSession session) {
  session.syncInFlight = false;
  session.cache.finishSync();
  _emitLedState(session); // 通知 UI：同步完成，可以讀取狀態
}
```

### Sync 的用途
1. **初始化連接**：設備連接時，自動觸發 Sync 獲取完整狀態
2. **狀態刷新**：需要獲取最新狀態時（例如：切換頁面、手動刷新）
3. **錯誤恢復**：命令失敗後，可以通過 Sync 重新獲取正確狀態
4. **數據一致性**：確保 App 的狀態與設備實際狀態一致

### 常見的 RETURN Opcodes

#### LED 設備
- `0x23` - RETURN_RECORD（返回紀錄數據）
- `0x24` - RETURN_PRESET_SCENE（返回預設場景數據）
- `0x25` - RETURN_CUSTOM_SCENE（返回自訂場景數據）
- `0x26` - RETURN_SCHEDULE（返回排程數據，但 reef-b-app 未實現）

#### Dosing 設備
- `0x66` - RETURN_DELAY_TIME（返回延遲時間）
- `0x67` - RETURN_ROTATING_SPEED（返回旋轉速度）
- `0x68-0x6D` - 各種排程 RETURN（返回排程數據）
- `0x77` - RETURN_ADJUST_HISTORY_DETAIL（返回校準歷史詳情）

---

## 3. ACK vs Sync 的比較

| 特性 | ACK | Sync |
|------|-----|------|
| **目的** | 確認單一命令是否成功 | 獲取設備的完整狀態 |
| **觸發時機** | 發送命令後自動回應 | 手動請求或連接時自動觸發 |
| **數據量** | 很少（4 字節） | 很多（多個 RETURN opcodes） |
| **更新方式** | 根據 ACK 結果更新本地狀態 | 根據 RETURN 數據更新本地狀態 |
| **頻率** | 每個命令都有 | 需要時才觸發（連接、刷新、錯誤恢復） |
| **狀態** | 簡單（成功/失敗） | 複雜（完整的場景、紀錄、排程等） |

---

## 4. 實際應用場景

### 場景 1：套用 LED 場景

```dart
// 使用 ACK：確認場景是否套用成功
Future<void> usePresetScene(String deviceId, int sceneCode) async {
  // 1. 發送命令
  await _sendCommand(deviceId, [0x28, 0x01, sceneCode]);
  
  // 2. 等待 ACK（在 _handlePresetSceneAck 中處理）
  // 3. ACK 成功時，更新本地狀態
  //    session.cache.setMode(LedMode.presetScene);
}
```

### 場景 2：獲取設備完整狀態

```dart
// 使用 Sync：獲取所有場景、紀錄、排程
Future<LedState> getLedState(String deviceId) async {
  // 1. 請求同步
  _requestSync(session);
  
  // 2. 等待 Sync START
  // 3. 接收多個 RETURN opcodes（場景、紀錄等）
  // 4. 每個 RETURN 立即更新狀態
  // 5. 等待 Sync END
  // 6. 返回完整狀態
  return session.cache.state;
}
```

### 場景 3：連接設備時

```dart
// 連接時自動觸發 Sync
void _handleConnectionState(BleConnectionState state) {
  if (state.isConnected) {
    // 自動請求同步，獲取設備的完整狀態
    _requestSync(session);
  }
}
```

---

## 5. 為什麼需要兩種機制？

### ACK 的優勢
- **快速**：立即知道命令是否成功
- **簡單**：只需要處理成功/失敗
- **即時**：不需要等待完整數據

### Sync 的優勢
- **完整**：獲取所有狀態數據
- **可靠**：確保 App 狀態與設備一致
- **恢復**：可以從錯誤狀態恢復

### 兩者配合使用
- **命令操作**：使用 ACK 確認操作成功
- **狀態查詢**：使用 Sync 獲取完整狀態
- **錯誤恢復**：命令失敗後，使用 Sync 重新獲取正確狀態

---

## 6. 在 koralcore 中的實現

### ACK 處理
- 位置：`lib/infrastructure/led/ble_led_repository_impl.dart`
- 方法：`_handle*Ack()` 系列方法
- 範例：`_handlePresetSceneAck()`, `_handleSetRecordAck()`

### Sync 處理
- 位置：`lib/infrastructure/led/ble_led_repository_impl.dart`
- 方法：
  - `_requestSync()` - 請求同步
  - `_handleSyncInformation()` - 處理 Sync START/END
  - `_handleSceneReturn()` - 處理場景 RETURN
  - `_handleRecordReturn()` - 處理紀錄 RETURN
  - `_finalizeSync()` - 完成同步

---

## 總結

- **ACK** = 確認訊息，告訴你「命令是否成功」
- **Sync** = 同步流程，告訴你「設備的完整狀態是什麼」

兩者配合使用，可以確保 App 與設備的狀態保持一致，並提供良好的用戶體驗。

