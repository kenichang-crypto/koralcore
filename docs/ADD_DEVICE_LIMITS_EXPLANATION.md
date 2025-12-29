# 「加入新設備」功能限制說明

## 1. 掃描結果過濾限制

### reef-b-app 的實現
**嚴格過濾條件**（`BluetoothViewModel.scanResult()`）：
1. 設備名稱不能為空
2. 設備名稱必須包含以下之一（不區分大小寫）：
   - "koralDOSE"
   - "coralDOSE"
   - "koralLED"
   - "coralLED"
3. 設備不能已存在於數據庫
4. 不能重複（相同 MAC 地址）

### koralcore 的處理
✅ **用戶要求：可以開放不受限**
- 不需要嚴格過濾設備名稱
- 可以顯示所有掃描到的設備
- 但仍需要過濾已存在的設備（避免重複顯示）

---

## 2. BLE 連接限制解釋

### 限制規則
**最多只能同時連接 1 個設備**

### 為什麼是 1 個設備？

#### 技術原因
1. **Android BLE 限制**：
   - Android 的 BLE API 理論上支持多個連接
   - 但實際使用中，同時維護多個 BLE 連接會導致：
     - 資源消耗增加
     - 連接穩定性下降
     - 數據傳輸衝突

2. **應用設計**：
   - reef-b-app 設計為「當前操作一個設備」的模式
   - 使用 `currentDeviceId` 來追蹤當前活動設備
   - UI 設計假設用戶一次只操作一個設備

3. **實際實現**：
   - `BleContainer` 使用 `bleManagerList` 管理多個 BLEManager（每個 MAC 地址一個）
   - 但應用邏輯層面限制為只允許一個活動連接
   - 錯誤消息：`toast_connect_limit` = "最多可1個裝置同時連線"

#### 代碼分析
從 `BluetoothViewModel.connectBle()` 和 `connectDeviceByMacAddress()` 看：
```kotlin
fun connectBle(device: BluetoothDevice, alreadyConnect4Device: () -> Unit) {
    // 檢查特定設備是否已連接
    if (bleManagerOP?.isDeviceConnect() == true) {
        return  // 如果這個設備已連接，直接返回
    }
    // 開始連接...
}
```

**注意**：
- 代碼只檢查**特定設備**是否已連接
- 沒有明確檢查**總連接數**是否達到 1
- `alreadyConnect4Device` 回調參數存在，但實際觸發邏輯可能在其他地方
- 可能是在 BLE 層面或系統層面自然限制為 1 個連接

#### iOS 端的註釋
```swift
private func canConnect(_ peripheralName: String?) -> Bool {
    // TODO: 滴液泵最多連1，LED最多5，總共6，這邊要防呆
    // bleManager.connectedPeripherals()
    return true
}
```
- 註釋提到更複雜的限制（滴液泵1，LED5，總共6）
- 但實際實現中 `maxConnectNumber = 1`
- 且 `canConnect()` 目前返回 `true`（未實現）

### 結論
- **設計限制**：應用設計為一次只連接 1 個設備
- **實際限制**：可能由 BLE 層面或系統層面自然限制
- **錯誤處理**：有錯誤消息 `toast_connect_limit`，但觸發條件需要確認

---

## 3. 設備類型判斷對照

### reef-b-app 的實現

#### Android 端
**位置**：`AddDeviceViewModel.kt`

**判斷邏輯**：
```kotlin
// skip() 方法
if (bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true) == true) {
    // LED 設備邏輯
    type = DeviceType.LED
} else if (bleManager?.getConnectDeviceName()?.contains("dose", ignoreCase = true) == true) {
    // DROP 設備邏輯
    type = DeviceType.DROP
}

// clickBtnRight() 方法
if (bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true) == true) {
    addDevice(DeviceType.LED) { ... }
} else if (bleManager?.getConnectDeviceName()?.contains("dose", ignoreCase = true) == true) {
    addDevice(DeviceType.DROP) { ... }
}
```

**判斷規則**：
- 從藍牙設備名稱判斷（不區分大小寫）
- 包含 "led" → LED 設備
- 包含 "dose" → DROP 設備
- 使用 `BleManager.getConnectDeviceName()` 獲取設備名稱

#### iOS 端
**位置**：`BluetoothSettingViewModel.swift`

**判斷邏輯**：
```swift
private func handleConnectSuccess(_ peripheral: NNRemotePeripheral) {
    guard
        let peripheralName = peripheral.name,
        let deviceType = DeviceType(peripheralName: peripheralName)
    else {
        isConnecting = false
        return
    }
    // ...
}

// DeviceType 初始化
init?(peripheralName: String) {
    if peripheralName.contains("DOSE") {
        self = .dripPump
    } else {
        self = .led
    }
}
```

**判斷規則**：
- 從藍牙設備名稱判斷
- 包含 "DOSE" → DROP 設備（dripPump）
- 否則 → LED 設備

### koralcore 的對照

#### 當前實現
**位置**：`AddDeviceController.dart`

**問題**：
```dart
final String? deviceType = device['type'] as String?;
```
- 從已保存的設備數據中讀取類型
- **但設備在連接時可能還沒有保存類型信息**

#### 需要對照的部分
✅ **reef-b-app 的做法**：
- 在 `AddDeviceViewModel` 中，直接從 `BleManager.getConnectDeviceName()` 獲取設備名稱
- 從設備名稱判斷類型（包含 "led" 或 "dose"）
- **不依賴已保存的設備數據**

⚠️ **koralcore 的問題**：
- 需要確認設備在連接時是否已保存基本信息（包括類型）
- 如果沒有，需要從設備名稱判斷類型
- 需要實現類似 `BleManager.getConnectDeviceName()` 的功能

### 對照結論

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 判斷時機 | 添加設備時（從 BLE 連接獲取名稱） | 添加設備時（從已保存數據讀取） | ⚠️ 需要確認 |
| 判斷方式 | 設備名稱包含 "led" 或 "dose" | 從 `device['type']` 讀取 | ⚠️ 需要對照 |
| 數據來源 | `BleManager.getConnectDeviceName()` | `session.activeDeviceName` | ⚠️ 需要確認 |
| 大小寫 | 不區分大小寫（`ignoreCase = true`） | - | ✅ 需要實現 |

### 需要實現的部分
1. **從 BLE 連接獲取設備名稱**：
   - 類似 `BleManager.getConnectDeviceName()`
   - 在 `AddDeviceController` 中獲取當前連接的設備名稱

2. **從設備名稱判斷類型**：
   - 實現類似 reef-b-app 的判斷邏輯
   - 包含 "led"（不區分大小寫）→ LED
   - 包含 "dose"（不區分大小寫）→ DROP

3. **確保類型判斷時機**：
   - 在 `skip()` 和 `addDevice()` 中都能正確判斷類型
   - 不依賴已保存的設備數據

