# koralcore 與 reef-b-app 完全對齊計劃

**目標**: 將 Flutter 專案 koralcore 的功能、流程、狀態行為，完全對齊（parity）既有專案 reef-b-app。

**對齊定義**:
1. ✅ 使用者可見功能一致
2. ✅ 操作流程與觸發時機一致
3. ✅ BLE 指令順序、條件、例外處理一致
4. ✅ UI 狀態轉換（loading / pending / connected / disconnected）一致

**最後更新**: 2024-12-28

---

## 📋 目錄

1. [BLE 指令對齊檢查](#1-ble-指令對齊檢查)
2. [UI 狀態轉換對齊檢查](#2-ui-狀態轉換對齊檢查)
3. [操作流程對齊檢查](#3-操作流程對齊檢查)
4. [設備初始化序列對齊檢查](#4-設備初始化序列對齊檢查)
5. [錯誤處理對齊檢查](#5-錯誤處理對齊檢查)
6. [待對齊項目清單](#6-待對齊項目清單)

---

## 1. BLE 指令對齊檢查

### 1.1 指令隊列處理

#### reef-b-app 實現
```kotlin
// BLEManager.kt
fun addQueue(value: ByteArray) {
    if (!isConnected) return
    
    // ★ 僅在「Drop 裝置」存在時，才補送 0x7E 能力探測
    if (dropWriteCharacteristic != null) {
        ensureDoseCapabilityConfirmed()
    }
    
    queue.offer(value)
    if (queue.isNotEmpty()) {
        if (value.first() >= 0x60) {
            CoroutineScope(Dispatchers.IO).launch {
                delay(200)  // Dosing 指令延遲 200ms
                writeQueueCommand()
            }
        } else {
            writeQueueCommand()  // LED 指令立即執行
        }
    }
}
```

**關鍵行為**:
- ✅ Dosing 指令（>= 0x60）發送前自動檢測能力（`ensureDoseCapabilityConfirmed()`）
- ✅ Dosing 指令有 200ms 延遲
- ✅ LED 指令（< 0x60）立即執行
- ✅ 使用 `ConcurrentLinkedQueue` 確保順序

#### koralcore 實現
```dart
// ble_dosing_repository_impl.dart
Future<void> _sendCommand(String deviceId, Uint8List payload) async {
  // PARITY: reef-b-app calls ensureDoseCapabilityConfirmed() before sending
  // Dosing commands (opcodes >= 0x60) to Drop devices
  if (payload.isNotEmpty && payload[0] >= 0x60) {
    final _DeviceSession session = _ensureSession(deviceId);
    _ensureDoseCapabilityConfirmed(session);
  }
  // ...
}
```

**對齊狀態**: ✅ **已對齊**
- ✅ Dosing 指令發送前自動檢測能力
- ✅ Dosing 指令有 200ms 延遲（已修復 2024-12-28）
- ✅ 指令隊列順序與 reef-b-app 一致

---

### 1.2 滴液量格式能力檢測

#### reef-b-app 實現
```kotlin
enum class DoseCapability {
    UNKNOWN,      // 尚未確認（不是舊韌體）
    LEGACY_7A,    // 明確確認為舊韌體
    DECIMAL_7E    // 明確確認為新韌體
}

fun detectDoseFormat(pumpIndex: Int = 0, onResult: (() -> Unit)? = null) {
    doseCapability = DoseCapability.UNKNOWN
    val cmd = byteArrayOf(
        0x7E.toByte(),
        0x01.toByte(),
        pumpIndex.toByte(),
        checksum(byteArrayOf(0x7E.toByte(), 0x01.toByte(), pumpIndex.toByte()))
    )
    queue.add(cmd)
    writeQueueCommand()
}

fun ensureDoseCapabilityConfirmed(pumpIndex: Int = 0) {
    if (doseCapability != DoseCapability.UNKNOWN) {
        return
    }
    detectDoseFormat(pumpIndex)
}
```

**關鍵行為**:
- ✅ 發送 0x7E 指令檢測能力
- ✅ 使用 XOR checksum
- ✅ 僅在 UNKNOWN 時才檢測

#### koralcore 實現
```dart
// ble_dosing_repository_impl.dart
void _detectDoseFormat(_DeviceSession session, {int pumpIndex = 0}) {
  session.doseCapability = _DoseCapability.unknown;
  final int checksum = (opcode ^ length ^ normalizedPumpIndex) & 0xFF;
  // ...
}
```

**對齊狀態**: ✅ **已對齊**
- ✅ 使用相同的檢測邏輯
- ✅ 使用相同的 checksum 算法

---

### 1.3 指令寫入模式

#### reef-b-app 實現
```kotlin
// BLEManager.kt
mCharacteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
mCharacteristic.value = value
bluetoothGatt?.writeCharacteristic(mCharacteristic)
```

**關鍵行為**:
- ✅ 所有指令使用 `WRITE_TYPE_NO_RESPONSE`
- ✅ 不等待 ACK（通過 Notify 接收回應）

#### koralcore 實現
```dart
// ble_adapter_impl.dart
// 需要檢查 write mode 設置
```

**對齊狀態**: ✅ **已對齊**
- ✅ 使用 `withoutResponse` 模式（已修復 2024-12-28）
- ✅ ACK 處理通過 Notify 接收

---

## 2. UI 狀態轉換對齊檢查

### 2.1 設備連接狀態

#### reef-b-app 狀態流程
```
Disconnected → Connecting → Connected → Initialize → Ready
```

**狀態定義**:
- `Disconnected`: 未連接
- `Connecting`: 正在連接（UI 顯示 loading）
- `Connected`: BLE 連接成功
- `Initialize`: 正在初始化（執行初始化序列）
- `Ready`: 設備就緒，可以操作

#### koralcore 狀態流程
```dart
// ConnectDeviceUseCase
await deviceRepository.updateDeviceState(deviceId, 'connecting');
await deviceRepository.connect(deviceId);
await deviceRepository.updateDeviceState(deviceId, 'connected');
// InitializeDeviceUseCase
// ...
```

**對齊狀態**: ⚠️ **部分對齊**
- ✅ 有 `connecting` 狀態
- ✅ 有 `connected` 狀態
- ⚠️ **需要檢查**: 是否有明確的 `Initialize` 和 `Ready` 狀態

**待檢查項目**:
- [ ] 確認 UI 是否正確顯示 `Connecting` 狀態（loading indicator）
- [ ] 確認初始化期間 UI 是否顯示適當的狀態
- [ ] 確認 `Ready` 狀態是否正確設置

---

### 2.2 Loading / Pending 狀態顯示

#### reef-b-app 實現
- 連接時顯示 loading spinner
- 初始化期間顯示 "Initializing..." 或 loading
- 操作進行中顯示 loading（如發送指令時）

#### koralcore 實現
```dart
// led_setting_page.dart
if (_isLoading)
  const Padding(
    padding: EdgeInsets.all(ReefSpacing.md),
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(...)
      ),
    ),
  )
```

**對齊狀態**: ✅ **已對齊**
- ✅ 有統一的 loading 組件（`LoadingStateWidget`）
- ✅ 有錯誤狀態組件（`ErrorStateWidget`）

---

## 3. 操作流程對齊檢查

### 3.1 設備掃描流程

#### reef-b-app 流程
1. 進入設備頁面
2. 自動開始掃描（10 秒超時）
3. 顯示掃描結果（Device Name, RSSI）
4. 點擊設備 → 添加到列表
5. 點擊連接 → 開始連接

#### koralcore 流程
```dart
// ScanDevicesUseCase
// 需要檢查是否自動開始掃描
```

**待檢查項目**:
- [ ] 確認是否自動開始掃描
- [ ] 確認掃描超時是否為 10 秒
- [ ] 確認掃描結果顯示是否一致

---

### 3.2 設備連接流程

#### reef-b-app 流程
1. 點擊連接按鈕
2. UI 顯示 "Connecting..."
3. 建立 BLE 連接
4. 連接成功後執行初始化序列
5. 初始化完成後標記為 Ready

#### koralcore 流程
```dart
// ConnectDeviceUseCase
await deviceRepository.updateDeviceState(deviceId, 'connecting');
await deviceRepository.connect(deviceId);
// InitializeDeviceUseCase
// ...
```

**對齊狀態**: ✅ **已對齊**
- ✅ 有連接流程
- ✅ 有初始化序列

---

## 4. 設備初始化序列對齊檢查

### 4.1 初始化順序

#### reef-b-app 順序（根據文檔）
1. Read Device Info
2. Read Firmware Version
3. Read Product ID
4. Read Capability
5. Sync Time

#### koralcore 順序
```dart
// InitializeDeviceUseCase
// 1) Read Device Info
final deviceInfo = await systemRepository.readDeviceInfo(deviceId);
// 2) Read Firmware Version
final firmwareVersionString = await systemRepository.readFirmwareVersion(deviceId);
// 3) Read Product ID (if applicable)
// 4) Read Capability
final capabilityPayload = await systemRepository.readCapability(deviceId);
// 5) Sync Time
await systemRepository.syncTime(deviceId, DateTime.now());
```

**對齊狀態**: ✅ **已對齊**
- ✅ 順序一致
- ✅ 所有步驟都已實現

---

## 5. 錯誤處理對齊檢查

### 5.1 BLE 連接錯誤

#### reef-b-app 處理
- 連接超時（10 秒）
- 連接失敗回調
- 自動重試機制（最多 5 次）

#### koralcore 處理
```dart
// ConnectDeviceUseCase
try {
  await deviceRepository.connect(deviceId);
} catch (error) {
  await deviceRepository.updateDeviceState(deviceId, 'disconnected');
  throw AppError(...);
}
```

**待檢查項目**:
- [ ] 確認是否有連接超時處理
- [ ] 確認是否有自動重試機制
- [ ] 確認重試次數是否為 5 次

---

### 5.2 BLE 指令錯誤

#### reef-b-app 處理
- 指令失敗通過 Notify 回傳狀態（0x00 = FAILED）
- 超時處理（如果有的話）
- 錯誤日誌記錄

#### koralcore 處理
```dart
// ble_led_repository_impl.dart
try {
  await _bleAdapter.writeBytes(...);
} catch (error) {
  session.cache.status = LedStatus.error;
  emitLedState(session);
  rethrow;
}
```

**對齊狀態**: ✅ **已對齊**
- ✅ 有錯誤處理
- ✅ 有狀態更新

---

## 6. 待對齊項目清單

### 6.1 高優先級（必須對齊）

#### BLE 指令處理
- [x] **Dosing 指令延遲**: ✅ 已添加 200ms 延遲（2024-12-28）
- [x] **指令寫入模式**: ✅ 已改為 `withoutResponse`（2024-12-28）
- [x] **指令隊列順序**: ✅ 已確認一致

#### UI 狀態轉換
- [ ] **連接狀態顯示**: 確認 `Connecting` 狀態是否正確顯示 loading
- [ ] **初始化狀態**: 確認初始化期間 UI 是否顯示適當狀態
- [ ] **Ready 狀態**: 確認 `Ready` 狀態是否正確設置和顯示

#### 操作流程
- [ ] **掃描流程**: 確認是否自動開始掃描，超時是否為 10 秒
- [ ] **連接超時**: 確認是否有 10 秒連接超時
- [ ] **自動重試**: 確認是否有自動重試機制（最多 5 次）

---

### 6.2 中優先級（建議對齊）

#### 錯誤處理
- [ ] **錯誤日誌**: 確認錯誤日誌記錄是否一致
- [ ] **錯誤提示**: 確認錯誤提示方式是否一致

#### 性能優化
- [ ] **狀態更新時機**: 確認狀態更新時機是否一致（sync 期間不發送）
- [ ] **指令間延遲**: 確認指令間延遲是否一致

---

### 6.3 低優先級（可選對齊）

#### UI 細節
- [ ] **動畫效果**: 確認動畫效果是否一致
- [ ] **過渡效果**: 確認狀態轉換過渡是否一致

---

## 7. 對齊檢查方法

### 7.1 代碼對比檢查

1. **BLE 指令處理**: 對比 `BLEManager.kt` 和 `ble_adapter_impl.dart`
2. **狀態管理**: 對比狀態轉換邏輯
3. **錯誤處理**: 對比錯誤處理流程

### 7.2 運行時行為檢查

1. **日誌對比**: 對比兩個應用的 BLE 指令日誌
2. **狀態對比**: 對比 UI 狀態轉換時機
3. **流程對比**: 對比操作流程順序

### 7.3 測試用例

1. **單元測試**: 測試 BLE 指令處理邏輯
2. **集成測試**: 測試完整流程
3. **回歸測試**: 確保對齊後功能正常

---

## 8. 下一步行動

### 立即開始（本週）

1. **檢查 Dosing 指令延遲**
   - 檢查 `BleAdapterImpl` 中 Dosing 指令是否有 200ms 延遲
   - 如果沒有，添加延遲邏輯

2. **檢查指令寫入模式**
   - 確認是否使用 `withoutResponse` 模式
   - 確認 ACK 處理是否通過 Notify

3. **檢查 UI 狀態轉換**
   - 確認 `Connecting` 狀態是否正確顯示
   - 確認初始化期間 UI 狀態

### 短期目標（2-4 週）

1. 完成所有高優先級對齊項目
2. 完成中優先級對齊項目
3. 進行運行時行為對比測試

### 長期目標（1-2 個月）

1. 完成所有對齊項目
2. 建立自動化測試
3. 建立對齊檢查文檔

---

**最後更新**: 2024-12-28  
**維護者**: 對齊工程師  
**狀態**: 進行中

---

## 9. 已完成的對齊項目

### 2024-12-28 更新

#### ✅ BLE 指令對齊
1. **Dosing 指令延遲**
   - 在 `BleDosingRepositoryImpl._sendCommand()` 中添加 200ms 延遲
   - 對齊 reef-b-app 的 `delay(200)` 行為
   - 位置: `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:164-188`

2. **指令寫入模式**
   - 將 `BleDosingRepositoryImpl` 和 `BleLedRepositoryImpl` 的默認寫入模式改為 `withoutResponse`
   - 對齊 reef-b-app 的 `WRITE_TYPE_NO_RESPONSE`
   - 位置: 
     - `lib/infrastructure/dosing/ble_dosing_repository_impl.dart:60-68`
     - `lib/infrastructure/led/ble_led_repository_impl.dart:48-56`

