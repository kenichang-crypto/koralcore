# 步驟 1：對照分析 - 「加入新設備」功能

## 1. reef-b-app 中的相關文件

### Android 端
- **Activity**: `AddDeviceActivity.kt`
- **ViewModel**: `AddDeviceViewModel.kt`
- **布局文件**: `activity_add_device.xml`
- **觸發點**: `BluetoothFragment.kt` → `MainActivity.kt` → `AddDeviceActivity.kt`
- **水槽選擇**: `SinkPositionActivity.kt`

### iOS 端
- **ViewController**: `AddDeviceViewController.swift`
- **ViewModel**: `AddDeviceViewModel.swift` (目前為空實現)
- **觸發點**: `BluetoothSettingViewController.swift`

---

## 2. 完整用戶操作流程

### 流程 A：從藍牙掃描添加新設備（主要流程）

#### 步驟 1：進入藍牙頁面
- **UI**: `BluetoothFragment`
- **操作**: 用戶點擊底部導航的「藍牙」標籤
- **邏輯**: 
  - `BluetoothFragment.onResume()` 被調用
  - `viewModel.getAllDevice()` 獲取已保存的設備列表
  - 清空掃描結果列表

#### 步驟 2：開始掃描
- **UI**: `BluetoothFragment` - 顯示「掃描」按鈕
- **操作**: 用戶點擊「掃描」按鈕 (`btnRefresh`)
- **邏輯**:
  - `BluetoothFragment.setListener()` → `btnRefresh.setOnClickListener`
  - 檢查藍牙權限
  - `viewModel.startScan()` 開始掃描
  - `viewIsScanning(true)` 顯示掃描進度

#### 步驟 3：掃描結果顯示
- **UI**: `BluetoothFragment` - RecyclerView 顯示掃描到的設備
- **操作**: 自動更新（無需用戶操作）
- **邏輯**:
  - `BluetoothViewModel.scanResult()` 處理掃描結果
  - **過濾條件**（嚴格限制）：
    1. 設備名稱不能為空：`result.device.name.isNullOrEmpty()` → 跳過
    2. 設備名稱必須包含以下之一（不區分大小寫）：
       - "koralDOSE"
       - "coralDOSE"
       - "koralLED"
       - "coralLED"
    3. 設備不能已存在於數據庫：`deviceIsExist(result.device.address)` → 跳過
    4. 不能重複（相同 MAC 地址）：檢查 `scanDevices` 列表中是否已有相同地址
  - 通過所有過濾條件的設備才會添加到列表
  - `addBleDeviceLiveData` 觸發
  - `BluetoothFragment.setObserver()` → `addBleDeviceLiveData.observe()` 更新列表

#### 步驟 4：選擇設備並連接
- **UI**: `BluetoothFragment` - 掃描結果列表中的設備卡片
- **操作**: 用戶點擊掃描到的設備
- **邏輯**:
  - `BluetoothFragment.onClickScanResult()` 被調用
  - `viewModel.connectBle(data.device, alreadyConnect4Device)` 開始連接
  - **連接限制檢查**：
    - 參數 `alreadyConnect4Device` 是回調函數，當達到連接限制時會被調用
    - 顯示錯誤提示：`toast_connect_limit` = "最多可1個裝置同時連線"（繁體中文）
    - **實際限制**：最多只能同時連接 **1 個設備**
    - 注意：Android 端代碼中有 `alreadyConnect4Device` 參數，但實際檢查邏輯可能在其他地方
  - 如果設備不存在於數據庫，設置 `BleContainer.setMacAddressForAdd(device.address)`
  - `_loadingLiveData.value = true` 顯示加載狀態

#### 步驟 5：連接成功處理
- **UI**: 自動處理（無需用戶操作）
- **操作**: BLE 連接成功
- **邏輯**:
  - `BluetoothViewModel.isConnectedLiveData` 觸發（值為 `true`）
  - `BluetoothFragment.setObserver()` → `isConnectedLiveData.observe()` 處理
  - 檢查設備是否存在：`viewModel.deviceIsExist()`
  - **如果設備不存在**：
    - 觸發 `mainViewModel.startAddDeviceLiveData.value = Unit`
    - `MainActivity.setObserver()` → `startAddDeviceLiveData.observe()` 監聽到事件
    - 啟動 `AddDeviceActivity`

#### 步驟 6：AddDeviceActivity 初始化
- **UI**: `AddDeviceActivity` 顯示
- **操作**: 自動執行（Activity 啟動）
- **邏輯**:
  - `AddDeviceActivity.onCreate()` 執行
  - `setView()` 初始化 UI：
    - 設置 Toolbar 標題：「新增裝置」
    - 設置左側按鈕：「略過」
    - 設置右側按鈕：「完成」
    - 初始化水槽位置顯示為「無」
  - 從 `BleManager` 獲取連接的設備名稱：`viewModel.getConnectDeviceName()`
  - **如果沒有連接設備名稱**：直接關閉 Activity (`finish()`)
  - **如果有設備名稱**：預填到設備名稱輸入框 (`edtName.setText()`)
  - `setListener()` 設置點擊事件
  - `setObserver()` 監聽 ViewModel 狀態

#### 步驟 7：用戶輸入設備信息
- **UI**: `AddDeviceActivity` - 兩個輸入區域
  - **設備名稱輸入框** (`edt_name`):
    - 標題：「裝置名稱」
    - 預填藍牙設備名稱，用戶可修改
    - 實時更新：`doAfterTextChanged` → `viewModel.setEdtName()`
  - **水槽位置選擇** (`view_sink_position`):
    - 標題：「水槽位置」
    - 顯示當前選擇的水槽名稱（默認「無」）
    - 點擊後打開 `SinkPositionActivity`
- **操作**: 
  - 用戶可修改設備名稱
  - 用戶可點擊水槽位置選擇器

#### 步驟 8：選擇水槽位置（可選）
- **UI**: `SinkPositionActivity` 顯示
- **操作**: 用戶點擊水槽位置選擇器
- **邏輯**:
  - `AddDeviceActivity.setListener()` → `viewSinkPosition.setOnClickListener`
  - 啟動 `SinkPositionActivity`，傳入當前選擇的 `sink_id`
  - 用戶在 `SinkPositionActivity` 中選擇：
    - 「無」（sink_id = 0）
    - 現有水槽
    - 或添加新水槽
  - 返回結果：`sinkPositionLauncher` 接收結果
  - 更新 UI：顯示選擇的水槽名稱

#### 步驟 9：完成添加（兩種方式）

##### 方式 A：點擊「略過」按鈕
- **UI**: Toolbar 左側按鈕「略過」
- **操作**: 用戶點擊「略過」
- **邏輯**:
  - `AddDeviceActivity.setListener()` → `btnLeft.setOnClickListener`
  - `viewModel.skip()` 被調用
  - 判斷設備類型（從藍牙設備名稱）：
    - **LED 設備**：直接添加到數據庫，`sinkId = null`
    - **DROP 設備**：添加到數據庫，`sinkId = null`，並創建 4 個泵頭（headId: 0-3）
  - `_addDeviceLiveData.value = true` 觸發
  - `AddDeviceActivity.setObserver()` → `addDeviceLiveData.observe()` 處理
  - 顯示成功提示：「新增裝置成功」
  - 關閉 Activity (`finish()`)

##### 方式 B：點擊「完成」按鈕
- **UI**: Toolbar 右側按鈕「完成」
- **操作**: 用戶點擊「完成」
- **邏輯**:
  - `AddDeviceActivity.setListener()` → `btnRight.setOnClickListener`
  - `viewModel.clickBtnRight()` 被調用
  - 判斷設備類型（從藍牙設備名稱）：
    - **LED 設備**：
      - 如果 `selectSinkId == 0`（未分配水槽）：
        - 直接添加，`sinkId = null`
      - 如果 `selectSinkId != 0`（分配水槽）：
        - 調用 `addToWhichGroup()` 找到可用群組（A-E，每組最多 4 個）
        - 如果所有群組都滿了：`addDeviceResult(false)`
        - 否則：添加設備，設置 `sinkId`, `group`, `master = false`
    - **DROP 設備**：
      - 如果 `selectSinkId == 0`（未分配水槽）：
        - 直接添加，`sinkId = null`
      - 如果 `selectSinkId != 0`（分配水槽）：
        - 檢查水槽中 DROP 設備數量：`dbGetDropInSinkBySinkId()`
        - 如果已有 4 個：`addDeviceResult(false)`
        - 否則：添加設備，設置 `sinkId`
      - 創建 4 個泵頭（headId: 0-3）
  - `_addDeviceLiveData.value = true/false` 觸發
  - `AddDeviceActivity.setObserver()` → `addDeviceLiveData.observe()` 處理
  - **成功**：顯示「新增裝置成功」，關閉 Activity
  - **失敗**：顯示「水槽已滿」提示

#### 步驟 10：返回處理
- **UI**: 用戶按返回鍵
- **操作**: 用戶按返回鍵
- **邏輯**:
  - `AddDeviceActivity.setListener()` → `onBackPressedDispatcher.addCallback`
  - `viewModel.disconnect()` 斷開 BLE 連接
  - 關閉 Activity (`finish()`)

---

### 流程 B：從已保存設備列表連接

#### 步驟 1-4：同流程 A

#### 步驟 5：點擊已保存設備
- **UI**: `BluetoothFragment` - 「我的設備」列表
- **操作**: 用戶點擊已保存的設備
- **邏輯**:
  - `BluetoothFragment.onClickDevice()` 被調用
  - 檢查設備是否已連接：`viewModel.isDeviceConnect()`
  - **如果已連接**：顯示斷開對話框
  - **如果未連接**：`viewModel.connectDeviceByMacAddress()` 連接

#### 步驟 6：連接成功處理
- 同流程 A 的步驟 5，如果設備已存在則刷新列表，不存在則導航到 AddDeviceActivity

---

## 3. 每個步驟對應的 UI 和邏輯

### UI 組件對照表

| reef-b-app (Android) | 說明 | koralcore (Flutter) |
|---------------------|------|---------------------|
| `BluetoothFragment` | 藍牙掃描頁面 | `BluetoothPage` / `DevicePage` |
| `activity_add_device.xml` | 添加設備頁面布局 | `AddDevicePage` |
| `toolbar_two_action` | Toolbar（略過/完成） | `ReefAppBar` with actions |
| `edt_name` | 設備名稱輸入框 | `TextField` |
| `layout_sink_position` | 水槽位置選擇器 | `TextField` (disabled) + `InkWell` |
| `SinkPositionActivity` | 水槽選擇頁面 | `SinkPositionPage` |
| `progress` | 加載進度指示器 | `CircularProgressIndicator` |

### 邏輯組件對照表

| reef-b-app (Android) | 說明 | koralcore (Flutter) |
|---------------------|------|---------------------|
| `BluetoothViewModel` | 藍牙掃描和連接邏輯 | `DeviceListController` |
| `AddDeviceViewModel` | 添加設備業務邏輯 | `AddDeviceController` |
| `BleContainer` | BLE 連接管理 | `BleAdapter` / `BleContainer` |
| `DeviceDao` | 設備數據庫操作 | `DeviceRepository` |
| `DropHeadDao` | 泵頭數據庫操作 | `PumpHeadRepository` |
| `SinkDao` | 水槽數據庫操作 | `SinkRepository` |

### 關鍵邏輯流程

#### 1. 設備類型判斷
- **reef-b-app**: 從藍牙設備名稱判斷（不區分大小寫）
  - 包含 "led" → LED 設備
  - 包含 "dose" → DROP 設備
- **位置**: 
  - `AddDeviceViewModel.skip()`: `bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true)`
  - `AddDeviceViewModel.clickBtnRight()`: 同樣的判斷邏輯
  - `BluetoothViewModel.setTimeCorrection()`: 同樣的判斷邏輯
- **koralcore**: 需要從已保存的設備數據中讀取，或從設備名稱判斷
- **注意**: 設備類型判斷必須在連接時或添加時進行，因為需要知道是 LED 還是 DROP 來執行不同的邏輯

#### 2. LED 群組分配
- **邏輯**: `AddDeviceViewModel.addToWhichGroup()`
- **規則**: 按 A-E 順序，找到第一個未滿的群組（每組最多 4 個設備）

#### 3. DROP 設備限制
- **邏輯**: `AddDeviceViewModel.addDevice()` → DROP 分支
- **規則**: 每個水槽最多 4 個 DROP 設備

#### 4. 泵頭創建
- **邏輯**: `AddDeviceViewModel.skip()`, `AddDeviceViewModel.addDevice()`
- **規則**: DROP 設備自動創建 4 個泵頭（headId: 0-3）

#### 5. 連接成功後自動導航
- **邏輯**: `BluetoothFragment.setObserver()` → `isConnectedLiveData.observe()`
- **條件**: 連接成功 && 設備不存在於數據庫
- **動作**: 觸發 `mainViewModel.startAddDeviceLiveData` → 啟動 `AddDeviceActivity`

---

## 4. 關鍵數據流

### 數據傳遞
1. **MAC 地址傳遞**:
   - `BluetoothViewModel.connectBle()` → `BleContainer.setMacAddressForAdd()`
   - `AddDeviceViewModel` 構造函數接收 `macAddress`
   - `BleContainer.getInstance().getBleManager(macAddress)` 獲取 BLE 管理器

2. **設備信息獲取**:
   - `BleManager.getConnectDeviceName()` → 設備名稱
   - `BleManager.getConnectDeviceMacAddress()` → MAC 地址
   - 從設備名稱判斷類型（LED/DROP）

3. **水槽選擇結果**:
   - `SinkPositionActivity` → `ActivityResult` → `sink_id`
   - `AddDeviceViewModel.setSelectSinkId()` 保存
   - `AddDeviceViewModel.getSinkNameById()` 獲取名稱顯示

### 狀態管理
- **Loading 狀態**: `AddDeviceViewModel.loadingLiveData` → `AddDeviceActivity` 顯示/隱藏進度條
- **連接狀態**: `AddDeviceViewModel.disconnectLiveData` → 自動關閉 Activity
- **添加結果**: `AddDeviceViewModel.addDeviceLiveData` → 顯示成功/失敗提示

---

## 5. 錯誤處理

### 錯誤情況
1. **沒有連接設備**: Activity 自動關閉
2. **水槽已滿** (DROP): 顯示「水槽已滿」提示
3. **所有群組已滿** (LED): 顯示「水槽已滿」提示
4. **連接失敗**: 顯示「連接失敗」提示（在 BluetoothFragment）

### 錯誤消息
- `toast_add_device_successful`: "新增裝置成功"
- `toast_sink_is_full`: "水槽已滿"
- `toast_connect_failed`: "連接失敗"

---

## 6. 關鍵限制和規則

### 6.1 掃描結果過濾限制

#### reef-b-app 的實現（嚴格）
**必須滿足所有條件才會顯示**：
1. ✅ 設備名稱不為空
2. ✅ 設備名稱包含 "koralDOSE", "coralDOSE", "koralLED", "coralLED" 之一（不區分大小寫）
3. ✅ 設備不存在於數據庫（已保存的設備不會顯示在掃描結果中）
4. ✅ 不重複（相同 MAC 地址只顯示一次）

**代碼位置**: `BluetoothViewModel.scanResult()` (258-286行)

#### koralcore 的處理
✅ **用戶要求：可以開放不受限（以後再加規則）**
- 不需要嚴格過濾設備名稱（koralDOSE/coralDOSE/koralLED/coralLED）
- 可以顯示所有掃描到的設備
- 但仍需要過濾已存在的設備（避免重複顯示在掃描結果中）
- **注意**：其他部分（連接限制、設備類型判斷等）全部對照 reef-b-app

---

### 6.2 BLE 連接限制

#### 限制規則
**最多只能同時連接 1 個設備**

#### 為什麼是 1 個設備？

**技術原因**：
1. **Android BLE 限制**：
   - Android 的 BLE API 理論上支持多個連接
   - 但實際使用中，同時維護多個 BLE 連接會導致：
     - 資源消耗增加（內存、CPU、電池）
     - 連接穩定性下降（信號衝突、數據傳輸衝突）
     - 命令隊列管理複雜

2. **應用設計**：
   - reef-b-app 設計為「當前操作一個設備」的模式
   - 使用 `currentDeviceId` 來追蹤當前活動設備
   - UI 設計假設用戶一次只操作一個設備（LED 控制頁面、Dosing 控制頁面都是單設備模式）

3. **實際實現**：
   - `BleContainer` 使用 `bleManagerList` 管理多個 BLEManager（每個 MAC 地址一個）
   - 但應用邏輯層面限制為只允許一個活動連接
   - 錯誤消息：`toast_connect_limit` = "最多可1個裝置同時連線"

#### 代碼分析
從 `BluetoothViewModel.connectBle()` 看：
```kotlin
fun connectBle(device: BluetoothDevice, alreadyConnect4Device: () -> Unit) {
    // 檢查特定設備是否已連接
    if (bleManagerOP?.isDeviceConnect() == true) {
        return  // 如果這個設備已連接，直接返回
    }
    // 開始連接...
}
```

**關鍵發現**：
- 代碼只檢查**特定設備**是否已連接（`isDeviceConnect()`）
- **沒有明確檢查總連接數**是否達到 1
- `alreadyConnect4Device` 回調參數存在，但實際觸發邏輯需要確認
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
- 且 `canConnect()` 目前返回 `true`（未實現限制檢查）

#### 結論
- **設計限制**：應用設計為一次只連接 1 個設備
- **實際限制**：可能由 BLE 層面或系統層面自然限制，或由 UI 邏輯保證（用戶只能操作一個設備）
- **錯誤處理**：有錯誤消息 `toast_connect_limit`，但觸發條件需要確認

---

### 6.3 設備類型判斷規則

#### reef-b-app 的實現（已對照）

**Android 端**：
```kotlin
// AddDeviceViewModel.skip()
if (bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true) == true) {
    type = DeviceType.LED
} else if (bleManager?.getConnectDeviceName()?.contains("dose", ignoreCase = true) == true) {
    type = DeviceType.DROP
}

// AddDeviceViewModel.clickBtnRight()
if (bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true) == true) {
    addDevice(DeviceType.LED) { ... }
} else if (bleManager?.getConnectDeviceName()?.contains("dose", ignoreCase = true) == true) {
    addDevice(DeviceType.DROP) { ... }
}
```

**判斷規則**：
- ✅ 從藍牙設備名稱判斷（不區分大小寫）
- ✅ 包含 "led" → LED 設備
- ✅ 包含 "dose" → DROP 設備
- ✅ 使用 `BleManager.getConnectDeviceName()` 獲取設備名稱

**代碼位置**:
- `AddDeviceViewModel.skip()` (63, 72行)
- `AddDeviceViewModel.clickBtnRight()` (102, 106行)
- `BluetoothViewModel.setTimeCorrection()` (94, 96行)

#### koralcore 的對照

**當前實現**：
```dart
// AddDeviceController.addDevice()
final String? deviceType = device['type'] as String?;
```

**問題**：
- ⚠️ 從已保存的設備數據中讀取類型
- ⚠️ 但設備在連接時可能還沒有保存類型信息
- ⚠️ 需要確認設備在連接時是否已保存基本信息

**需要實現**：
1. ✅ 從 BLE 連接獲取設備名稱（類似 `BleManager.getConnectDeviceName()`）
2. ✅ 從設備名稱判斷類型（包含 "led" 或 "dose"，不區分大小寫）
3. ✅ 在 `skip()` 和 `addDevice()` 中都使用這個判斷邏輯

**對照狀態**：
- ✅ 判斷規則已對照（包含 "led" 或 "dose"）
- ⚠️ 判斷時機需要確認（連接時是否已保存類型）
- ⚠️ 數據來源需要確認（從 BLE 連接獲取名稱 vs 從已保存數據讀取）

---

## 7. 與 koralcore 的對照點

### 已實現的部分
✅ `AddDevicePage` - UI 頁面已存在
✅ `AddDeviceController` - 業務邏輯已存在
✅ `SinkPositionPage` - 水槽選擇頁面已存在
✅ 錯誤消息已對照
✅ BLE 斷開連接實現（已修復）

### 需要確認/實現的部分

#### 已確認（用戶要求）
✅ **掃描結果過濾**：可以開放不受限（不需要嚴格過濾設備名稱）

#### 需要實現/確認
⚠️ **連接限制檢查**：
   - 設計限制：最多 1 個設備同時連接
   - 需要確認：實際檢查邏輯在哪裡（可能在 BLE 層面或系統層面）
   - 需要實現：如果需要在應用層檢查，需要統計當前連接數

⚠️ **連接成功後自動導航**：
   - 觸發條件：連接成功 && 設備不存在 → 自動導航到 AddDevicePage
   - 這是測試用的關鍵流程，必須成功才能進入下一階段
   - 需要確認：koralcore 中是否有類似邏輯

⚠️ **設備類型判斷**：
   - ✅ 判斷規則已對照（從設備名稱判斷，包含 "led" 或 "dose"）
   - ⚠️ 判斷時機：需要確認連接時是否已保存類型，或需要從設備名稱判斷
   - ⚠️ 數據來源：需要從 BLE 連接狀態獲取設備名稱（類似 `BleManager.getConnectDeviceName()`）

⚠️ **設備名稱獲取**：
   - 當前：從 `session.activeDeviceName` 獲取
   - 需要確認：這個名稱是否在連接時已設置
   - 需要對照：reef-b-app 使用 `BleManager.getConnectDeviceName()` 直接從 BLE 連接獲取

---

## 總結

**完整流程**：藍牙掃描 → 選擇設備 → 連接 → 自動導航到添加頁面 → 輸入信息 → 完成添加

**關鍵觸發點**：連接成功 && 設備不存在 → 自動啟動 AddDeviceActivity

**核心邏輯**：設備類型判斷、群組分配、設備限制檢查、泵頭創建

