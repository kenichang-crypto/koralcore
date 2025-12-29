# 步驟 2：現狀檢查 - 「加入新設備」功能

## 1. 已實現的部分

### ✅ UI 頁面
- **AddDevicePage** (`lib/ui/features/device/pages/add_device_page.dart`)
  - 已存在，基本結構完整
  - 包含設備名稱輸入、水槽位置選擇、Skip/Complete 按鈕
  - 已實現返回時斷開連接的邏輯

- **SinkPositionPage** (`lib/ui/features/sink/pages/sink_position_page.dart`)
  - 已存在，用於選擇水槽位置

### ✅ 業務邏輯
- **AddDeviceController** (`lib/ui/features/device/controllers/add_device_controller.dart`)
  - 已存在，包含基本業務邏輯
  - 已實現 `skip()` 和 `addDevice()` 方法
  - 已實現 `disconnect()` 方法（已修復）
  - 已實現 LED 群組分配邏輯
  - 已實現 DROP 設備限制檢查（每個水槽最多 4 個）

- **DeviceListController** (`lib/ui/features/device/controllers/device_list_controller.dart`)
  - 已存在，處理設備列表和連接邏輯

### ✅ 錯誤處理
- **AppErrorCode.sinkFull** - 已實現
- **錯誤消息本地化** - 已對照 reef-b-app

---

## 2. 缺失或需要修改的部分

### ⚠️ 1. 連接成功後自動導航到 AddDevicePage

#### reef-b-app 的實現
**觸發條件**：連接成功 && 設備不存在 → 自動啟動 AddDeviceActivity

**代碼位置**：
- `BluetoothFragment.kt`:
  ```kotlin
  viewModel.isConnectedLiveData.observe(viewLifecycleOwner) {
      if (it == true) {
          if (!viewModel.deviceIsExist()) {
              mainViewModel.startAddDeviceLiveData.value = Unit
          }
      }
  }
  ```

#### koralcore 的現狀
- ❌ **沒有自動導航邏輯**
- 當前：用戶需要手動點擊 FloatingActionButton 進入 AddDevicePage
- 需要：在 `DeviceListController.connect()` 成功後，檢查設備是否存在，如果不存在則自動導航

**需要實現**：
1. 在 `DeviceListController.connect()` 成功後檢查設備是否存在
2. 如果設備不存在，觸發導航到 AddDevicePage
3. 需要傳遞 BuildContext 或使用路由系統

---

### ⚠️ 2. 設備類型判斷

#### reef-b-app 的實現
**判斷方式**：從藍牙設備名稱判斷（不區分大小寫）
- 包含 "led" → LED 設備
- 包含 "dose" → DROP 設備

**代碼位置**：
- `AddDeviceViewModel.skip()` (63, 72行)
- `AddDeviceViewModel.clickBtnRight()` (102, 106行)

#### koralcore 的現狀
**當前實現**：
```dart
// AddDeviceController.addDevice()
final String? deviceType = device['type'] as String?;
```

**問題**：
- ⚠️ 從已保存的設備數據中讀取類型
- ⚠️ 但設備在連接時可能還沒有保存類型信息
- ⚠️ 需要確認連接時是否已保存類型

**已有工具類**：
- ✅ `DeviceNameFilter` (`lib/infrastructure/ble/device_name_filter.dart`)
  - `isLedDevice(String? deviceName)` - 檢查是否為 LED
  - `isDosingDevice(String? deviceName)` - 檢查是否為 DROP
  - `getDeviceType(String? deviceName)` - 獲取設備類型

**需要修改**：
1. 在 `AddDeviceController.skip()` 和 `addDevice()` 中，從設備名稱判斷類型
2. 使用 `DeviceNameFilter` 工具類
3. 從 `session.activeDeviceName` 或 BLE 連接狀態獲取設備名稱

---

### ⚠️ 3. BLE 連接限制檢查

#### reef-b-app 的實現
**限制規則**：最多只能同時連接 1 個設備

**代碼位置**：
- `BluetoothFragment.onClickScanResult()` → `connectBle(..., alreadyConnect4Device)`
- `BluetoothFragment.onClickDevice()` → `connectDeviceByMacAddress(..., alreadyConnect4Device)`
- 錯誤消息：`toast_connect_limit` = "最多可1個裝置同時連線"

#### koralcore 的現狀
- ❌ **沒有明確的連接限制檢查**
- 當前：`DeviceListController.connect()` 直接調用 `ConnectDeviceUseCase`
- 需要：在連接前檢查當前是否已有設備連接

**需要實現**：
1. 在 `DeviceListController.connect()` 中檢查當前連接數
2. 如果已有設備連接，顯示錯誤消息
3. 添加錯誤消息到 ARB 文件：`errorConnectLimit`

---

### ⚠️ 4. 掃描結果過濾（用戶要求開放）

#### reef-b-app 的實現
**嚴格過濾**：
1. 設備名稱不為空
2. 設備名稱包含 "koralDOSE", "coralDOSE", "koralLED", "coralLED" 之一
3. 設備不存在於數據庫
4. 不重複（相同 MAC 地址）

#### koralcore 的現狀
- ✅ **用戶要求：可以開放不受限（以後再加規則）**
- 當前：需要確認掃描結果是否已過濾已存在的設備
- 需要：確認實現方式，確保已存在的設備不會顯示在掃描結果中

**需要確認**：
1. 掃描結果是否已過濾已存在的設備
2. 如果沒有，需要實現過濾邏輯（但不過濾設備名稱）

---

### ⚠️ 5. 設備名稱獲取

#### reef-b-app 的實現
**獲取方式**：`BleManager.getConnectDeviceName()` - 直接從 BLE 連接獲取

#### koralcore 的現狀
**當前實現**：
```dart
// AddDeviceController.connectedDeviceName
String? get connectedDeviceName {
  // TODO: Get from BLE connection state
  // For now, return from session
  return session.activeDeviceName;
}
```

**問題**：
- ⚠️ 從 `session.activeDeviceName` 獲取，但需要確認這個名稱是否在連接時已設置
- ⚠️ 需要確認名稱來源是否正確（從 BLE 連接 vs 從已保存數據）

**需要確認**：
1. `session.activeDeviceName` 是否在連接時已設置
2. 如果沒有，需要從 BLE 連接狀態獲取設備名稱

---

## 3. 對照總結

| 功能點 | reef-b-app | koralcore | 狀態 |
|--------|-----------|-----------|------|
| AddDevicePage UI | ✅ | ✅ | 已實現 |
| AddDeviceController | ✅ | ✅ | 已實現 |
| SinkPositionPage | ✅ | ✅ | 已實現 |
| BLE 斷開連接 | ✅ | ✅ | 已修復 |
| 錯誤消息對照 | ✅ | ✅ | 已對照 |
| **連接成功後自動導航** | ✅ | ❌ | **缺失** |
| **設備類型判斷（從名稱）** | ✅ | ⚠️ | **需要修改** |
| **連接限制檢查** | ✅ | ❌ | **缺失** |
| **掃描結果過濾** | ✅（嚴格） | ⚠️（開放） | **需要確認** |
| **設備名稱獲取** | ✅（從 BLE） | ⚠️（從 session） | **需要確認** |

---

## 4. 優先級

### 高優先級（必須實現）
1. **連接成功後自動導航到 AddDevicePage**
   - 這是測試用的關鍵流程，必須成功才能進入下一階段
   - 影響：用戶體驗，測試流程

2. **設備類型判斷（從設備名稱）**
   - 影響：設備添加邏輯的正確性
   - 已有工具類，只需修改判斷邏輯

### 中優先級（應該實現）
3. **BLE 連接限制檢查**
   - 影響：符合 reef-b-app 的行為
   - 需要添加錯誤消息

### 低優先級（確認即可）
4. **掃描結果過濾**
   - 用戶要求開放，但需要確認已存在設備的過濾

5. **設備名稱獲取**
   - 需要確認當前實現是否正確

