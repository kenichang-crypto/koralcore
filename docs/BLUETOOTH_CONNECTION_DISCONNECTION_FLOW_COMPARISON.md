# 藍芽連線管理頁面 - 連接與斷開資訊流對照表

## 概述

本文件對照 `reef-b-app` 與 `koralcore` 在藍芽連線管理頁面中「管理設備的藍芽連線、連結藍芽及斷開藍芽」的資訊流與動作差異。

## 1. 已保存設備連接流程對照

### 1.1 點擊已保存設備

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **觸發點** | `BLEMyDeviceAdapter` → `onClickDevice(data)` | `_BtMyDeviceTile` → `onTap` | ✅ |
| **檢查連接狀態** | `viewModel.isDeviceConnect(data.macAddress)` | `device.isConnected` | ✅ |
| **已連接時動作** | 顯示斷開確認對話框 `createDisconnectBluetoothDialog(data)` | 直接調用 `onDisconnect()` | ⚠️ **差異：缺少確認對話框** |
| **未連接時動作** | `viewModel.connectDeviceByMacAddress(data.macAddress)` | `controller.connect(deviceId)` | ✅ |
| **BLE 權限檢查** | `checkBlePermission(requireActivity())` | 在 `ConnectDeviceUseCase` 中處理 | ✅ |

### 1.2 連接流程

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **1. 檢查連接限制** | `alreadyConnect4Device()` 回調（如果已連接 4 個設備） | `DeviceListController.connect()` → 檢查 `hasConnectedDevice` | ✅ |
| **2. 創建 BLEManager** | `BleContainer.getInstance().new(macAddress)` | `ConnectDeviceUseCase` → 創建 BLE 連接 | ✅ |
| **3. 檢查是否已連接** | `if (bleManagerOP?.isDeviceConnect() == true) return` | 在 `ConnectDeviceUseCase` 中處理 | ✅ |
| **4. 設置監聽器** | `bleManagerOP?.setListener(this)` | 在 BLE 層自動處理 | ✅ |
| **5. 顯示 Loading** | `_loadingLiveData.value = true` | 在 `ConnectDeviceUseCase` 中處理 | ✅ |
| **6. 開始連接** | `bleManagerOP?.connectWithMacAddress(macAddress)` | `ConnectDeviceUseCase.execute()` | ✅ |
| **7. 連接成功回調** | `onOpenNotify()` → `setTimeCorrection()` | `ConnectDeviceUseCase` → 自動時間校正 | ✅ |
| **8. 時間校正** | `bleLedSetTimeCorrection()` 或 `bleDropSetTimeCorrection()` | `ConnectDeviceUseCase` → 自動處理 | ✅ |
| **9. 連接狀態更新** | `connectState(true)` → `onReadData()` → `ledTimeCorrection` 或 `dropTimeCorrection` → `isConnectedLiveData.value = true` | `ConnectDeviceUseCase` → 連接成功 | ✅ |
| **10. 檢查設備是否存在** | `viewModel.deviceIsExist()` | `DeviceListController.connect()` → `deviceExists` | ✅ |
| **11. 導航到新增頁面** | `mainViewModel.startAddDeviceLiveData.value = Unit` | `onNewDeviceConnected()` 回調 → 導航到 `AddDevicePage` | ✅ |
| **12. 更新設備列表** | `viewModel.getAllDevice()` | `observeSavedDevices()` Stream 自動更新 | ✅ |
| **13. 隱藏 Loading** | `_loadingLiveData.value = false` | `ConnectDeviceUseCase` 完成後自動處理 | ✅ |

### 1.3 連接失敗處理

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **連接失敗回調** | `connectState(false)` → `isConnectedLiveData.value = false` | `ConnectDeviceUseCase` → 拋出 `AppError` | ✅ |
| **顯示錯誤提示** | `mainViewModel.toastLiveData.value = R.string.toast_connect_failed` | `DeviceListController` → `_setError()` → `showErrorSnackBar()` | ✅ |
| **隱藏 Loading** | `_loadingLiveData.value = false` | `ConnectDeviceUseCase` 完成後自動處理 | ✅ |

## 2. 已保存設備斷開流程對照

### 2.1 點擊已連接設備

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **觸發點** | `onClickDevice(data)` → `if (viewModel.isDeviceConnect(data.macAddress))` | `_BtMyDeviceTile` → `onTap: isConnected ? onDisconnect : onConnect` | ✅ |
| **顯示確認對話框** | `createDisconnectBluetoothDialog(data)` | **無確認對話框，直接斷開** | ⚠️ **差異：缺少確認對話框** |
| **對話框內容** | `dialog_disconnect_bluetooth_content`: "Do you want to disconnect Bluetooth?" | 無 | ⚠️ **差異** |
| **確認按鈕** | `dialog_disconnect_bluetooth_positive`: "OK" | 無 | ⚠️ **差異** |
| **取消按鈕** | `dialog_disconnect_bluetooth_negative`: "Cancel" | 無 | ⚠️ **差異** |

### 2.2 斷開流程

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **1. 確認斷開** | 用戶點擊確認按鈕 | 直接執行（無確認步驟） | ⚠️ **差異** |
| **2. 檢查 BLEManager 是否存在** | `if (BleContainer.getInstance().isExistBleManager(macAddress))` | `DisconnectDeviceUseCase` → `deviceRepository.disconnect()` | ✅ |
| **3. 獲取 BLEManager** | `bleManagerOP = BleContainer.getInstance().getBleManager(macAddress)!!` | 在 `DisconnectDeviceUseCase` 中處理 | ✅ |
| **4. 設置監聽器** | `bleManagerOP?.setListener(this)` | 在 BLE 層自動處理 | ✅ |
| **5. 顯示 Loading** | `_loadingLiveData.value = true` | 在 `DisconnectDeviceUseCase` 中處理 | ✅ |
| **6. 執行斷開** | `bleManagerOP?.disConnect()` | `DisconnectDeviceUseCase.execute()` → `deviceRepository.disconnect()` | ✅ |
| **7. 斷開回調** | `onDisconnected()` → `_disconnectLiveData.postValue(Unit)` | `DisconnectDeviceUseCase` → 更新狀態 | ✅ |
| **8. 更新設備狀態** | `viewModel.getAllDevice()` → 更新連接狀態 | `deviceRepository.updateDeviceState(deviceId, 'disconnected')` | ✅ |
| **9. 清除當前設備** | 如果為當前設備，清除 `currentDeviceId` | `currentDeviceSession.clear()` | ✅ |
| **10. 重置泵頭狀態** | 無（在設備層面處理） | `_resetRunningPumpHeads(deviceId)` | ⚠️ **差異：koralcore 有額外重置** |
| **11. 重置 LED 狀態** | 無（在設備層面處理） | `_resetLedState(deviceId)` | ⚠️ **差異：koralcore 有額外重置** |
| **12. 更新設備列表** | `myDeviceAdapter.notifyDataSetChanged()` | `observeSavedDevices()` Stream 自動更新 | ✅ |
| **13. 隱藏 Loading** | `_loadingLiveData.value = false` | `DisconnectDeviceUseCase` 完成後自動處理 | ✅ |

### 2.3 斷開後 UI 更新

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **設備列表更新** | `myDeviceAdapter.notifyDataSetChanged()` | `observeSavedDevices()` Stream 自動更新 | ✅ |
| **連接狀態圖標** | `ic_connect_background` → `ic_disconnect_background` | `getConnectBackgroundIcon()` → `getDisconnectBackgroundIcon()` | ✅ |
| **設備名稱顏色** | `text_aaaa` → `text_aa` | `ReefColors.textPrimary` → `ReefColors.textSecondary` | ✅ |
| **斷開提示** | 無（靜默斷開） | 無（靜默斷開） | ✅ |

## 3. 掃描結果連接流程對照

### 3.1 點擊掃描結果

| 步驟 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **觸發點** | `BLEScanResultAdapter` → `onClickScanResult(data)` | `_BtDeviceTile` → `onTap` | ✅ |
| **連接動作** | `viewModel.connectBle(data.device)` | `controller.connect(deviceId)` | ✅ |
| **連接限制檢查** | `alreadyConnect4Device()` 回調 | `DeviceListController.connect()` → 檢查 `hasConnectedDevice` | ✅ |
| **連接限制提示** | `mainViewModel.toastLiveData.value = R.string.toast_connect_limit` | `_setError(AppErrorCode.connectLimit)` → `showErrorSnackBar()` | ✅ |

### 3.2 連接流程

與「已保存設備連接流程」相同，但有以下差異：

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **設備地址處理** | `data.device.address` (BluetoothDevice) | `deviceId` (String) | ✅ |
| **創建 BLEManager** | `BleContainer.getInstance().new(device.address)` | `ConnectDeviceUseCase` → 創建 BLE 連接 | ✅ |
| **開始連接** | `bleManagerOP?.connectBLE(device)` | `ConnectDeviceUseCase.execute()` | ✅ |
| **標記為新增設備** | `BleContainer.getInstance().setMacAddressForAdd(device.address)` | 在連接成功後檢查設備是否存在 | ✅ |

## 4. 資訊流對照

### 4.1 連接資訊流

```
reef-b-app:
用戶點擊設備
  → onClickDevice(data)
  → checkBlePermission()
  → viewModel.isDeviceConnect(macAddress)
  → [已連接] createDisconnectBluetoothDialog()
  → [未連接] viewModel.connectDeviceByMacAddress(macAddress)
    → 檢查連接限制 (alreadyConnect4Device)
    → BleContainer.getInstance().new(macAddress)
    → bleManagerOP?.connectWithMacAddress(macAddress)
    → onOpenNotify() → setTimeCorrection()
    → connectState(true) → onReadData()
    → ledTimeCorrection/dropTimeCorrection → isConnectedLiveData.value = true
    → viewModel.deviceIsExist() → startAddDeviceLiveData
    → viewModel.getAllDevice() → deviceListLiveData
    → myDeviceAdapter.submitList(it)

koralcore:
用戶點擊設備
  → _BtMyDeviceTile.onTap
  → [已連接] onDisconnect() → controller.disconnect(deviceId)
  → [未連接] onConnect() → controller.connect(deviceId)
    → 檢查連接限制 (hasConnectedDevice)
    → ConnectDeviceUseCase.execute(deviceId)
    → deviceRepository.connect(deviceId)
    → BLE 連接建立
    → 自動時間校正
    → 連接成功
    → deviceExists 檢查
    → onNewDeviceConnected() → 導航到 AddDevicePage
    → observeSavedDevices() Stream 更新
```

### 4.2 斷開資訊流

```
reef-b-app:
用戶點擊已連接設備
  → onClickDevice(data)
  → viewModel.isDeviceConnect(macAddress) == true
  → createDisconnectBluetoothDialog(data)
  → 用戶確認
  → viewModel.disConnect(data.macAddress)
    → BleContainer.getInstance().getBleManager(macAddress)
    → bleManagerOP?.disConnect()
    → onDisconnected() → disconnectLiveData.postValue(Unit)
    → viewModel.getAllDevice() → deviceListLiveData
    → myDeviceAdapter.notifyDataSetChanged()

koralcore:
用戶點擊已連接設備
  → _BtMyDeviceTile.onTap (isConnected == true)
  → onDisconnect() → controller.disconnect(deviceId)
  → DisconnectDeviceUseCase.execute(deviceId)
    → deviceRepository.disconnect(deviceId)
    → BLE 斷開
    → deviceRepository.updateDeviceState(deviceId, 'disconnected')
    → currentDeviceSession.clear()
    → _resetRunningPumpHeads(deviceId)
    → _resetLedState(deviceId)
    → observeSavedDevices() Stream 更新
```

## 5. 主要差異分析

### 5.1 高優先級差異

1. **斷開確認對話框** ⚠️
   - **reef-b-app**: 點擊已連接設備時，顯示確認對話框 `createDisconnectBluetoothDialog(data)`
   - **koralcore**: 直接斷開，無確認對話框
   - **影響**: 用戶體驗差異，可能誤觸斷開
   - **建議**: 添加斷開確認對話框

2. **斷開後狀態重置** ⚠️
   - **reef-b-app**: 只斷開 BLE 連接，不重置設備狀態
   - **koralcore**: 斷開後會重置泵頭狀態和 LED 狀態（`_resetRunningPumpHeads`, `_resetLedState`）
   - **影響**: 行為差異，可能影響設備狀態
   - **建議**: 確認是否需要重置狀態

### 5.2 中優先級差異

1. **Loading 狀態管理**
   - **reef-b-app**: 使用 `loadingLiveData` 統一管理，顯示在 `MainActivity`
   - **koralcore**: 在 `UseCase` 層面處理，可能沒有統一的 Loading 顯示
   - **影響**: UI 反饋差異
   - **建議**: 確認 Loading 顯示是否一致

2. **設備列表更新時機**
   - **reef-b-app**: 斷開後手動調用 `viewModel.getAllDevice()` 和 `myDeviceAdapter.notifyDataSetChanged()`
   - **koralcore**: 通過 `observeSavedDevices()` Stream 自動更新
   - **影響**: 實現方式不同，但結果相同
   - **狀態**: ✅ 可接受

### 5.3 低優先級差異

1. **錯誤提示方式**
   - **reef-b-app**: 使用 `toastLiveData` 顯示 Toast
   - **koralcore**: 使用 `SnackBar` 顯示錯誤
   - **影響**: UI 反饋方式不同，但功能相同
   - **狀態**: ✅ 可接受

## 6. 需要修正的問題

### 6.1 必須修正（100% 對照要求）

1. **添加斷開確認對話框**
   - 在 `_BtMyDeviceTile` 的 `onDisconnect` 回調中，先顯示確認對話框
   - 用戶確認後才執行斷開
   - 使用 `dialog_disconnect_bluetooth_content`, `dialog_disconnect_bluetooth_positive`, `dialog_disconnect_bluetooth_negative`

### 6.2 需要確認

1. **斷開後狀態重置**
   - 確認 `_resetRunningPumpHeads` 和 `_resetLedState` 是否必要
   - 對照 `reef-b-app` 的行為，確認是否需要移除或保留

2. **Loading 狀態顯示**
   - 確認連接/斷開時是否有統一的 Loading 顯示
   - 對照 `reef-b-app` 的 `loadingLiveData` 行為

## 7. 對照評分

| 類別 | 評分 | 說明 |
|------|------|------|
| **連接流程** | 95% | 基本對照，但實現方式略有不同 |
| **斷開流程** | 80% | 缺少確認對話框，狀態重置行為不同 |
| **資訊流** | 90% | 資訊流基本對照，但部分細節不同 |
| **UI 反饋** | 85% | Loading 和錯誤提示方式不同 |
| **總體評分** | 87.5% | 需要添加斷開確認對話框以達到 100% |

## 8. 下一步行動

1. ✅ 添加斷開確認對話框
2. ⚠️ 確認斷開後狀態重置是否必要
3. ⚠️ 確認 Loading 狀態顯示是否一致

