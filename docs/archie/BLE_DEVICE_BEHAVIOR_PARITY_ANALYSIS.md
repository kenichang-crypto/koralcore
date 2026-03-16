# BLE 連線與設備管理行為對照分析

**分析日期:** 2025-02-11  
**範圍:** koralcore 與 reef-b-app 靜態對照  
**方法:** 程式碼靜態分析，不修改程式碼

---

## 1. 登入流程

### 1.1 reef-b-app 行為

| 對照項 | reef-b-app 實作 | 檔案 / 函式 |
|--------|-----------------|-------------|
| 使用者輸入 account/password | **無** | — |
| 與後端或本地 session 建立 | **無** | 無登入流程 |
| 權限檢查 | `checkBlePermission(activity) { action() }` | `PermissionUtil.kt:28` |
| 是否觸發 BLE 初始狀態重置 | 有：`MainActivity.onCreate` 通過權限後呼叫 `BleContainer.getInstance().getBleManager().scanLeDevice()` | `MainActivity.kt:45-49` |

**結論:** reef-b-app 為本機單機 app，**無帳密登入**。進入後直接執行 BLE 權限檢查，通過後自動開始掃描。

---

### 1.2 koralcore 對應實作

| 對照項 | koralcore 實作 | 檔案 / 函式 | 已可用 |
|--------|----------------|-------------|--------|
| 使用者輸入 account/password | **無** | — | Yes（與 reef-b 一致） |
| 與後端或本地 session 建立 | **無** | — | Yes |
| 權限檢查 | `BleReadinessController` 管理權限與 BLuetooth 狀態 | `lib/app/system/ble_readiness_controller.dart` | Yes |
| 是否觸發 BLE 初始狀態重置 | Splash 後進入 MainShell，各 Tab 依需求觸發掃描；無在 app 啟動時強制啟動 BLE 掃描 | `main.dart`, `splash_page.dart` | **差異** |

**差異說明:**

- reef-b: `MainActivity.onCreate` 在權限通過後**立即**呼叫 `scanLeDevice()`。
- koralcore: 無對應「權限通過後自動開始掃描」的統一入口，掃描由 BluetoothTabPage 的 refresh 或進入該 tab 時觸發。

**建議:** 若需與 reef-b 一致，可於 `MainShellPage` 或 app 啟動流程中，在 BLE 權限就緒後呼叫一次 `ScanDevicesUseCase`。

---

## 2. App 首頁 BLE 連線流程

### 2.1 reef-b-app 行為

| 對照項 | reef-b-app 實作 | 檔案 / 函式 |
|--------|-----------------|-------------|
| 掃描 BLE 裝置 | `bleManager.scanLeDevice(allowScanWhenConnected = true)` | `BluetoothViewModel.kt:169`, `MainActivity.kt:48` |
| 顯示裝置列表 | `addBleDeviceLiveData`（未配對）, `deviceListLiveData`（已配對） | `BluetoothViewModel.kt`, `BluetoothFragment.kt` |
| 點選裝置建立 BLE 連線 | `connectBle(device)` / `connectDeviceByMacAddress(mac)` | `BluetoothViewModel.kt:176-207` |
| 顯示連線狀態回饋 | `isConnectedLiveData`, `loadingLiveData` | `BluetoothViewModel.kt:386-399` |
| 連線失敗重試 | `connectState(false)` 時設 `_isConnectedLiveData.postValue(false)`, `_loadingLiveData.postValue(false)`；UI 可再點選重試 | `BluetoothViewModel.kt:394-398` |
| 斷線後自動 reconnect 或提示 | `onDisconnected` → `disconnectLiveData`，observer 只做 `getAllDevice` 與 `notifyDataSetChanged`，**無自動重連** | `BluetoothViewModel.kt:268-271`, `BluetoothFragment.kt:117-119` |

---

### 2.2 koralcore 對應實作

| 對照項 | koralcore 實作 | 檔案 / 函式 | 已可用 |
|--------|----------------|-------------|--------|
| 掃描 BLE 裝置 | `ScanDevicesUseCase.execute()`，由 `DeviceListController.refresh()` 觸發 | `device_list_controller.dart:94-114`, `ble_scan_service.dart` | Yes |
| 顯示裝置列表 | `savedDevices`（已配對）, `discoveredDevices`（掃描到的） | `bluetooth_tab_page.dart`, `device_list_controller.dart` | Yes |
| 點選裝置建立 BLE 連線 | `controller.connect(device.id)` | `bluetooth_tab_page.dart:98-109`, `_BtDeviceTile`, `_BtMyDeviceTile` | Yes |
| 顯示連線狀態回饋 | `DeviceSnapshot.isConnected`，透過 `deviceRepository.observeSavedDevices()` 等 stream 更新 | `device_snapshot.dart`, `device_repository_impl.dart` | Yes |
| 連線失敗重試 | 失敗時設定 `_lastErrorCode`，UI 可再點選重試 | `device_list_controller.dart:149-154` | Yes |
| 斷線後自動 reconnect 或提示 | **無自動重連**；`AppSession._onDevices` 會 `currentDeviceSession.clear()`，UI 顯示未連線狀態 | `app_session.dart:131-134` | **部分** |

**差異說明:**

- 兩者皆無自動重連，行為一致。
- reef-b 在斷線時有 `disconnectLiveData` 觸發列表刷新；koralcore 透過 `observeSavedDevices()` / 連線狀態 stream 自動更新，效果類似。

---

## 3. 刪除設備流程

### 3.1 reef-b-app 行為

| 對照項 | reef-b-app 實作 | 檔案 / 函式 |
|--------|-----------------|-------------|
| UI 操作 | Device tab：btn_choose 進入選擇模式，btn_delete 刪除已選裝置 | `DeviceFragment.kt:91-112`, `MainActivity.kt:100-108` |
| 從本地 DB 移除 | `dbDeleteDeviceById(it.id)` | `DeviceViewModel.kt:97-99` |
| 取消 BLE 相關資源 | `if (it.macAddress == bleManager.getConnectDeviceMacAddress()) { bleManager.disConnect() }` | `DeviceViewModel.kt:98-100` |
| 刪除後更新列表 | `deleteDeviceLiveData` → `getAllDevice()`, `isDeleteMode(false)` | `DeviceFragment.kt:137-149` |
| 主燈刪除限制 | `canDeleteDevice(device)`：群組內多裝置時主燈不可刪 | `DeviceViewModel.kt:106-119`, `DeviceFragment.kt:105-109` |

---

### 3.2 koralcore 對應實作

| 對照項 | koralcore 實作 | 檔案 / 函式 | 已可用 |
|--------|----------------|-------------|--------|
| UI 操作 | Device tab：Select 進入 selectionMode，Delete 刪除已選裝置 | `main_shell_page.dart:136-180`, `device_tab_page.dart` | Yes |
| 從本地 DB 移除 | `deviceRepository.removeDevice(deviceId)` | `remove_device_usecase.dart:48`, `device_repository_impl.dart` | Yes |
| 取消 BLE 相關資源 | 若 `deviceState == 'connected'` 先呼叫 `disconnectDeviceUseCase.execute(deviceId)` | `remove_device_usecase.dart:36-46` | Yes |
| 刪除後更新列表 | `observeSavedDevices()` stream 自動更新，`exitSelectionMode()` | `remove_device_usecase.dart:55`, `device_list_controller.dart:236-240` | Yes |
| 主燈刪除限制 | `canDeleteDevice(deviceId)`：LED 群組內多裝置時主燈不可刪 | `device_list_controller.dart:173-213` | Yes |

**結論:** 刪除流程與 reef-b 對齊，實作完整。

---

## 4. BLE 狀態機流程與 UI 對照

### 4.1 reef-b-app 行為

| 對照項 | reef-b-app 實作 | 檔案 / 函式 |
|--------|-----------------|-------------|
| 狀態標示 | `isConnect`（Device.isConnect）, `isScanningLiveData`, `loadingLiveData` | `BluetoothViewModel.kt`, `BluetoothFragment.kt` |
| AppSession.isReady / session 狀態 gate | **無** 對應 `isReady` 概念；以 BLE 連線狀態與 `BleContainer` 為主 | — |
| 阻擋非 ready 狀態下的指令 | 各 ViewModel 依連線狀態決定可否操作；無統一 `isReady` gate | `LedMainViewModel`, `DropMainViewModel` 等 |

---

### 4.2 koralcore 對應實作

| 對照項 | koralcore 實作 | 檔案 / 函式 | 已可用 |
|--------|----------------|-------------|--------|
| 狀態標示 | `AppSession.isBleConnected`, `session.isReady`, `DeviceSnapshot.isConnected` | `app_session.dart:47-49`, `device_snapshot.dart` | Yes |
| AppSession.isReady / session 狀態 gate | `CurrentDeviceSession.isReady`，`AppSession.isReady` 委派至 `currentDeviceSession.isReady` | `current_device_session.dart:33`, `app_session.dart:49` | Yes |
| 阻擋非 ready 狀態下的指令 | 多個 controller 檢查 `session.isReady` 再派發指令 | `manual_dosing_controller.dart:33`, `pump_head_adjust_controller.dart:71`, `dosing_main_controller.dart:249` 等 | Yes |

**差異說明:**

- reef-b 沒有 `isReady`，僅以連線狀態控制。
- koralcore 的 `isReady` 表示「已連線且完成 `InitializeDeviceUseCase`」，比單純連線更嚴格，能避免在未完成初始化時派送指令。

---

## 5. 其他典型 BLE 操作

### 5.1 reef-b-app 行為

| 對照項 | reef-b-app 實作 | 檔案 / 函式 |
|--------|-----------------|-------------|
| 重新掃描 / 手動刷新 | `btnRefresh` → `checkBlePermission` → `viewModel.startScan()` | `BluetoothFragment.kt:98-105` |
| 斷線後是否提示 | `disconnectLiveData` 觸發 `getAllDevice` 刷新，無明確 Snackbar 提示 | `BluetoothFragment.kt:117-119` |
| scheduling / dosing / LED 控制在非 ready 時是否被阻擋 | 依各 ViewModel 檢查連線；無統一 `isReady`，但會檢查 `BleContainer` 連線 | `LedMainViewModel`, `DropMainViewModel` 等 |

---

### 5.2 koralcore 對應實作

| 對照項 | koralcore 實作 | 檔案 / 函式 | 已可用 |
|--------|----------------|-------------|--------|
| 重新掃描 / 手動刷新 | `_OtherDevicesHeader` 的 refresh → `controller.refresh()` → `ScanDevicesUseCase.execute()` | `bluetooth_tab_page.dart:56`, `device_list_controller.dart:94` | Yes |
| 斷線後是否提示 | 透過 stream 更新 UI，必要時可搭配 Snackbar；目前無與 reef-b 對齊的斷線 Snackbar | `app_session.dart`, `device_repository` | **可補強** |
| scheduling / dosing / LED 在非 ready 時是否被阻擋 | 各 controller 檢查 `session.isReady`，未 ready 時 `_setError(AppErrorCode.deviceNotReady)` 或停用按鈕 | `manual_dosing_controller.dart:33`, `pump_head_schedule_controller.dart:85` 等 | Yes |

---

## 6. 總結對照表

| 行為項目 | reef-b-app | koralcore | 已可用 |
|----------|------------|-----------|--------|
| 登入流程（account/password） | 無 | 無 | Yes |
| BLE 權限檢查 | checkBlePermission | BleReadinessController | Yes |
| 權限通過後自動掃描 | 有 (MainActivity) | 無 | **No** |
| BLE 掃描 | startScan() | ScanDevicesUseCase | Yes |
| 裝置列表顯示 | 已配對 + 掃描結果 | savedDevices + discoveredDevices | Yes |
| 點選連線 | connectBle / connectDeviceByMacAddress | ConnectDeviceUseCase | Yes |
| 連線狀態回饋 | isConnectedLiveData, loading | DeviceSnapshot.isConnected, streams | Yes |
| 連線失敗重試 | 可重試 | 可重試 | Yes |
| 斷線後自動重連 | 無 | 無 | Yes |
| 手動刷新 / 重掃 | btnRefresh | controller.refresh() | Yes |
| 刪除設備 UI | Select + Delete | Select + Delete | Yes |
| 從 DB 移除 | dbDeleteDeviceById | deviceRepository.removeDevice | Yes |
| 刪除時 BLE 斷線 | disConnect() | DisconnectDeviceUseCase | Yes |
| 刪除後列表更新 | getAllDevice() | observeSavedDevices stream | Yes |
| 主燈刪除限制 | canDeleteDevice | canDeleteDevice | Yes |
| 狀態標示（未連線/連線中/已連線） | isConnect, isScanning | isConnected, isReady | Yes |
| isReady / session gate | 無 | CurrentDeviceSession.isReady | Yes |
| 非 ready 時阻擋指令 | 各 ViewModel 自檢 | session.isReady 檢查 | Yes |

---

## 7. 具體修正建議

### 7.1 權限通過後自動開始掃描（與 reef-b 對齊）

**現狀:** reef-b 在 `MainActivity.onCreate` 權限通過後直接呼叫 `scanLeDevice()`；koralcore 無此行為。

**建議:** 在 `MainShellPage` 首次顯示或 `BleReadinessController` 判定權限/藍牙就緒時，觸發一次 `DeviceListController.refresh()`。

**檔案:** `lib/app/main_shell_page.dart` 或 `lib/features/splash/presentation/pages/splash_page.dart`  
**邏輯:** 當 `BleReadinessController.snapshot.isReady` 或權限/藍牙就緒時，呼叫 `context.read<DeviceListController>().refresh()`。

### 7.2 斷線後 Snackbar 提示（可選）

**現狀:** reef-b 斷線時僅刷新列表；koralcore 也未顯示 Snackbar。

**建議:** 若需明確提示，可在 `AppSession._onDevices` 或 `CurrentDeviceSession.clear()` 時觸發 Snackbar，顯示「Device disconnected」等訊息。

**檔案:** `lib/app/common/app_session.dart` 或負責顯示 Snackbar 的 UI 層。

---

## 8. 參考檔案清單

### reef-b-app
- `MainActivity.kt`
- `BluetoothFragment.kt`, `BluetoothViewModel.kt`
- `DeviceFragment.kt`, `DeviceViewModel.kt`
- `HomeViewModel.kt`
- `PermissionUtil.kt` (checkBlePermission)
- `BleContainer.kt`, `BLEManager.kt`

### koralcore
- `main.dart`, `main_shell_page.dart`
- `bluetooth_tab_page.dart`, `device_tab_page.dart`
- `device_list_controller.dart`
- `app_session.dart`, `current_device_session.dart`
- `connect_device_usecase.dart`, `remove_device_usecase.dart`, `disconnect_device_usecase.dart`
- `device_connection_coordinator.dart`
- `ble_guard.dart`, `ble_readiness_controller.dart`
