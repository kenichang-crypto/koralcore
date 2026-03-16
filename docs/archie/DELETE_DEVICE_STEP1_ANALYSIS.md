# 步驟 1：對照分析 - 「刪除設備」功能

## 1. reef-b-app 中的相關文件

### Android 端

#### UI 層
- **`DeviceFragment.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/device/DeviceFragment.kt`)
  - 設備列表頁面的 Fragment
  - 處理刪除模式的切換
  - 顯示刪除確認對話框
  - 監聽刪除結果並顯示 Toast

- **`DeviceAdapter.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/adapter/DeviceAdapter.kt`)
  - RecyclerView 適配器
  - 管理刪除模式狀態
  - 管理選中的設備列表（`deleteList`）
  - 處理設備卡片的點擊事件（刪除模式 vs 正常模式）

- **`LedMainActivity.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_main/LedMainActivity.kt`)
  - LED 設備詳情頁面
  - 提供刪除當前設備的功能（從詳情頁刪除）

- **`DropMainActivity.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_main/DropMainActivity.kt`)
  - DROP 設備詳情頁面
  - 提供刪除當前設備的功能（從詳情頁刪除）

#### 業務邏輯層
- **`DeviceViewModel.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/device/DeviceViewModel.kt`)
  - 設備列表的 ViewModel
  - `deleteDevice(list: List<Device>)` - 刪除設備列表
  - `canDeleteDevice(device: Device)` - 檢查設備是否可以刪除（LED 主燈限制）
  - `dbDeleteDeviceById(id: Int)` - 數據庫刪除操作

- **`LedMainViewModel.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_main/LedMainViewModel.kt`)
  - LED 詳情頁的 ViewModel
  - `deleteDevice()` - 刪除當前 LED 設備

- **`DropMainViewModel.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_main/DropMainViewModel.kt`)
  - DROP 詳情頁的 ViewModel
  - `deleteDevice()` - 刪除當前 DROP 設備

#### 數據層
- **`DeviceDao.kt`** (`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/database/dao/DeviceDao.kt`)
  - `deleteDeviceById(id: Int)` - 數據庫刪除操作

#### UI 布局文件
- **`fragment_device.xml`** - 設備列表頁面布局
- **`adapter_device_led.xml`** - LED 設備卡片布局
- **`adapter_device_drop.xml`** - DROP 設備卡片布局

### iOS 端

#### UI 層
- **`DeviceListViewController.swift`** (`ios/ReefB_iOS/Reefb/Scenes/Main/DeviceList/DeviceListViewController.swift`)
  - 設備列表頁面的 ViewController
  - `showDeleteSelectedDevice()` - 顯示刪除確認 Alert
  - `deleteBarButtonItemTapped()` - 刪除按鈕點擊處理

#### 業務邏輯層
- **`DeviceListViewModel.swift`** (`ios/ReefB_iOS/Reefb/Scenes/Main/DeviceList/DeviceListViewModel.swift`)
  - 設備列表的 ViewModel
  - `deleteSelectedDevices()` - 刪除選中的設備
  - 檢查 LED 主燈限制（已註釋，但邏輯存在）

#### 數據層
- **`DBManager.swift`** (`ios/ReefB_iOS/Reefb/Manager/DataBase/DBManager.swift`)
  - `deleteDevice(deviceId: Int, completion: ((Bool) -> ())? = nil)` - 刪除設備

---

## 2. 完整的用戶流程

### 場景 1：從設備列表頁面刪除（批量刪除）

#### 步驟 1：進入刪除模式
- **UI**: `DeviceFragment` - 點擊 `btn_choose` 按鈕（在 MainActivity 的 Toolbar 中）
- **操作**: 用戶點擊「選擇」按鈕
- **邏輯**:
  - `DeviceFragment.setListener()` → `btnChoose.setOnClickListener`
  - 調用 `isDeleteMode(true)`
  - `DeviceAdapter.triggerDeleteMode(true)` - 啟用刪除模式
  - `MainViewModel.deleteModeLiveData.value = true` - 通知 MainActivity 更新 Toolbar

#### 步驟 2：選擇要刪除的設備
- **UI**: `DeviceAdapter` - 設備卡片（`adapter_device_led.xml` 或 `adapter_device_drop.xml`）
- **操作**: 用戶點擊設備卡片
- **邏輯**:
  - `DeviceAdapter.LedViewHolder.bind()` → `binding.root.setOnClickListener`
  - 如果 `deleteMode == true`：
    - 調用 `addDeleteItem(data)` - 添加/移除設備到 `deleteList`
    - 更新 UI 顯示選中狀態（`imgCheck.visibility`）
  - 如果 `deleteMode == false`：
    - 調用 `listener.onClickDevice(data)` - 進入設備詳情頁

#### 步驟 3：點擊刪除按鈕
- **UI**: `MainActivity` - Toolbar 中的 `btn_delete`（ImageView）
- **操作**: 用戶點擊刪除按鈕
- **邏輯**:
  - `DeviceFragment.setListener()` → `btnDelete.setOnClickListener`
  - 獲取選中的設備列表：`deviceAdapter.getDeleteList()`
  - 如果列表為空，直接返回
  - **檢查 LED 主燈限制**：
    - 遍歷選中的設備
    - 如果是 LED 設備且 `!viewModel.canDeleteDevice(it)`：
      - 顯示 `createDeleteLedMasterDialog()` - 主燈不能刪除的提示
      - 返回，不執行刪除
  - 如果通過檢查，顯示 `createDeleteLedDialog()` - 刪除確認對話框

#### 步驟 4：確認刪除
- **UI**: `DeviceFragment` - 刪除確認對話框
- **操作**: 用戶點擊「刪除」按鈕
- **邏輯**:
  - `createDeleteLedDialog()` → `positiveListener`
  - 調用 `viewModel.deleteDevice(deviceAdapter.getDeleteList())`
  - 關閉刪除模式：`deviceAdapter.triggerDeleteMode(false)` 和 `isDeleteMode(false)`

#### 步驟 5：執行刪除
- **UI**: 無（後台操作）
- **操作**: 自動執行
- **邏輯**:
  - `DeviceViewModel.deleteDevice(list: List<Device>)`:
    - `_loadingLiveData.value = true` - 顯示加載狀態
    - 遍歷設備列表：
      - `dbDeleteDeviceById(it.id)` - 從數據庫刪除
      - 如果設備已連接（`it.macAddress == bleManager.getConnectDeviceMacAddress()`）：
        - `bleManager.disConnect()` - 斷開 BLE 連接
    - `_deleteDeviceLiveData.value = true` - 通知刪除完成
    - `_loadingLiveData.value = false` - 隱藏加載狀態

#### 步驟 6：顯示結果
- **UI**: `DeviceFragment` - Toast 消息
- **操作**: 自動顯示
- **邏輯**:
  - `DeviceFragment.setObserver()` → `deleteDeviceLiveData.observe()`
  - 如果 `it == true`：
    - `mainViewModel.toastLiveData.value = R.string.toast_delete_device_successful` - 顯示成功消息
    - `viewModel.getAllDevice()` - 刷新設備列表
  - 如果 `it == false`：
    - `mainViewModel.toastLiveData.value = R.string.toast_delete_device_failed` - 顯示失敗消息
  - `isDeleteMode(false)` - 關閉刪除模式

---

### 場景 2：從設備詳情頁刪除（單個刪除）

#### LED 設備詳情頁（LedMainActivity）

**步驟 1：點擊刪除按鈕**
- **UI**: `LedMainActivity` - Toolbar 中的刪除按鈕
- **操作**: 用戶點擊刪除按鈕
- **邏輯**:
  - `LedMainActivity` → 刪除按鈕的點擊事件
  - 調用 `viewModel.deleteDevice()`

**步驟 2：執行刪除**
- **UI**: 無（後台操作）
- **操作**: 自動執行
- **邏輯**:
  - `LedMainViewModel.deleteDevice()`:
    - `_loadingLiveData.value = true`
    - `dbDeleteDeviceById(nowDevice.id)` - 從數據庫刪除
    - `_deleteDeviceLiveData.value = true`
    - `_loadingLiveData.value = false`

**步驟 3：顯示結果並返回**
- **UI**: `LedMainActivity` - Toast 消息，然後關閉頁面
- **操作**: 自動執行
- **邏輯**:
  - `LedMainActivity` → `deleteDeviceLiveData.observe()`
  - 如果 `it == true`：
    - 顯示 `toast_delete_device_successful`
    - `viewModel.disConnect()` - 斷開連接
    - `finish()` - 關閉頁面
  - 如果 `it == false`：
    - 顯示 `toast_delete_device_failed`

#### DROP 設備詳情頁（DropMainActivity）

**流程與 LED 相同**，但使用 `DropMainViewModel.deleteDevice()`：
- 先調用 `disConnect()` 斷開連接
- 然後執行 `dbDeleteDeviceById(nowDevice.id)`

---

## 3. 每個步驟對應的 UI 和邏輯

### 場景 1：設備列表頁面批量刪除

| 步驟 | UI 組件 | 邏輯組件 | 關鍵代碼位置 |
|------|---------|----------|--------------|
| 1. 進入刪除模式 | `btn_choose` (MainActivity Toolbar) | `DeviceFragment.isDeleteMode(true)` | `DeviceFragment.kt:80-87` |
| 2. 選擇設備 | 設備卡片 (`adapter_device_led.xml` / `adapter_device_drop.xml`) | `DeviceAdapter.addDeleteItem()` | `DeviceAdapter.kt:52-61, 145-151, 195-201` |
| 3. 點擊刪除按鈕 | `btn_delete` (MainActivity Toolbar) | `DeviceFragment.createDeleteLedDialog()` | `DeviceFragment.kt:88-101, 198-210` |
| 4. 確認刪除 | 刪除確認對話框 | `DeviceViewModel.deleteDevice()` | `DeviceFragment.kt:203-207` |
| 5. 執行刪除 | 無（後台） | `DeviceViewModel.deleteDevice()` → `dbDeleteDeviceById()` + `bleManager.disConnect()` | `DeviceViewModel.kt:94-105` |
| 6. 顯示結果 | Toast 消息 | `DeviceFragment.setObserver()` → `deleteDeviceLiveData.observe()` | `DeviceFragment.kt:120-131` |

### 場景 2：設備詳情頁單個刪除

| 步驟 | UI 組件 | 邏輯組件 | 關鍵代碼位置 |
|------|---------|----------|--------------|
| 1. 點擊刪除按鈕 | Toolbar 刪除按鈕 | `LedMainViewModel.deleteDevice()` / `DropMainViewModel.deleteDevice()` | `LedMainActivity.kt:680`, `DropMainActivity.kt:278` |
| 2. 執行刪除 | 無（後台） | `dbDeleteDeviceById()` + `disConnect()` (DROP) | `LedMainViewModel.kt:244-249`, `DropMainViewModel.kt:181-187` |
| 3. 顯示結果並返回 | Toast 消息 + `finish()` | `deleteDeviceLiveData.observe()` | `LedMainActivity.kt:243-255`, `DropMainActivity.kt:165-176` |

---

## 4. 關鍵業務邏輯

### 4.1 LED 主燈刪除限制

**reef-b-app 的實現**：
```kotlin
fun canDeleteDevice(device: Device): Boolean {
    device.sinkId?.let { id ->
        val deviceList = dbGetDeviceBySinkIdAndGroup(id, device.group!!)
        
        if (deviceList.size <= 1) {
            // 群組內只有自己
            return true
        } else {
            return device.master == false  // 只有非主燈可以刪除
        }
    }
    // 未分配設備
    return true
}
```

**規則**：
- 如果設備未分配水槽（`sinkId == null`）→ 可以刪除
- 如果設備所在群組只有 1 個設備 → 可以刪除（即使它是主燈）
- 如果設備所在群組有多個設備：
  - 主燈（`master == true`）→ **不能刪除**
  - 副燈（`master == false`）→ 可以刪除

**錯誤提示**：
- `dialog_device_delete_led_master_content` = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈"

**重要**：此限制**僅適用於 LED 設備**，在 `DeviceFragment.kt` 中檢查時：
```kotlin
tmpList.forEach {
    if (it.type == DeviceType.LED && !viewModel.canDeleteDevice(it)) {
        createDeleteLedMasterDialog()
        return@setOnClickListener
    }
}
```

### 4.1.1 DROP 設備刪除限制

**reef-b-app 的實現**：
- **DROP 設備沒有刪除限制**
- 在 `DeviceFragment.kt` 中，刪除前只檢查 LED 設備的主燈限制
- DROP 設備可以自由刪除，無需檢查主從關係（因為 DROP 設備沒有 `master` 和 `group` 概念）

**從詳情頁刪除 DROP 設備**：
- `DropMainActivity` 使用 `createDeleteDropDialog()`
- 確認消息：`dialog_delete_drop_content` = "是否刪除此滴液泵?" (繁體中文) / "Do you want to delete this dosing pump?" (英文)
- 刪除流程：先 `disConnect()` 斷開連接，然後 `dbDeleteDeviceById()`

### 4.2 刪除時斷開 BLE 連接

**reef-b-app 的實現**：
```kotlin
fun deleteDevice(list: List<Device>) {
    list.forEach {
        dbDeleteDeviceById(it.id)
        if (it.macAddress == bleManager.getConnectDeviceMacAddress()) {
            bleManager.disConnect()  // 如果設備已連接，先斷開
        }
    }
}
```

**規則**：
- 刪除設備前，檢查設備是否當前已連接
- 如果已連接，先斷開 BLE 連接
- 然後從數據庫刪除設備

### 4.3 刪除成功後的處理

**設備列表頁面**：
- 顯示成功 Toast
- 刷新設備列表：`viewModel.getAllDevice()`
- 關閉刪除模式：`isDeleteMode(false)`

**設備詳情頁**：
- 顯示成功 Toast
- 斷開連接：`viewModel.disConnect()`
- 關閉頁面：`finish()`

---

## 5. 與 koralcore 的對照

### 5.1 已實現的部分

#### ✅ 基本刪除功能
- **`DeviceListController.removeSelected()`** (`lib/ui/features/device/controllers/device_list_controller.dart`)
  - 已實現批量刪除選中設備
  - 使用 `RemoveDeviceUseCase` 執行刪除

- **`RemoveDeviceUseCase`** (`lib/application/device/remove_device_usecase.dart`)
  - 已實現刪除設備的 UseCase
  - 會清除當前會話（如果刪除的是當前設備）

- **`DeviceRepository.removeDevice()`** (`lib/infrastructure/repositories/device_repository_impl.dart`)
  - 已實現從數據庫刪除設備
  - 有主燈刪除限制檢查：`if (record.isMaster) { throw AppError }`

- **`DevicePage._confirmDelete()`** (`lib/ui/features/device/device_page.dart`)
  - 已實現刪除確認對話框
  - 顯示成功消息：`snackbarDeviceRemoved`

#### ✅ UI 組件
- **`DevicePage`** - 設備列表頁面已存在
- **`DeviceCard`** - 設備卡片已存在
- **選擇模式** - `DeviceListController.selectionMode` 已實現

### 5.2 缺失或需要修改的部分

#### ⚠️ 1. LED 主燈刪除限制檢查

**reef-b-app 的實現**：
- `DeviceViewModel.canDeleteDevice()` - 檢查設備是否可以刪除
- 在刪除前檢查：如果是 LED 主燈且群組內有其他設備，不能刪除
- 顯示錯誤對話框：`createDeleteLedMasterDialog()`

**koralcore 的現狀**：
- `DeviceRepository.removeDevice()` 中有檢查：`if (record.isMaster) { throw AppError }`
- **問題**：這個檢查太簡單，沒有考慮「群組內只有自己」的情況
- **需要修改**：實現類似 `canDeleteDevice()` 的邏輯

#### ⚠️ 2. 刪除時斷開 BLE 連接

**reef-b-app 的實現**：
- 在 `DeviceViewModel.deleteDevice()` 中：
  - 檢查設備是否已連接
  - 如果已連接，調用 `bleManager.disConnect()`

**koralcore 的現狀**：
- `RemoveDeviceUseCase` 中有 TODO：`// TODO: Ensure device disconnected (call DisconnectDeviceUseCase)`
- **需要實現**：在刪除前檢查設備是否已連接，如果已連接則先斷開

#### ⚠️ 3. 刪除成功後的處理

**reef-b-app 的實現**：
- 設備列表頁面：刷新設備列表 `getAllDevice()`
- 設備詳情頁：斷開連接 + 關閉頁面 `finish()`

**koralcore 的現狀**：
- `DevicePage._confirmDelete()` 中只顯示 SnackBar
- **需要確認**：設備列表是否自動刷新（通過 Stream 訂閱）
- **需要確認**：是否有從詳情頁刪除的功能

#### ⚠️ 4. 錯誤消息本地化

**reef-b-app 的錯誤消息**：
- `toast_delete_device_successful` = "刪除設備成功"
- `toast_delete_device_failed` = "刪除設備失敗"
- `dialog_device_delete_led_master_content` = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈"
- `dialog_device_delete` = "是否刪除所選設備?"

**koralcore 的現狀**：
- ✅ `snackbarDeviceRemoved` = "Devices removed." - 已存在
- ❌ 缺少主燈不能刪除的錯誤消息
- ❌ 缺少刪除失敗的錯誤消息

#### ⚠️ 5. 刪除模式 UI

**reef-b-app 的實現**：
- `DeviceAdapter` 管理刪除模式狀態（`deleteMode`）
- 刪除模式下，點擊設備卡片會選中/取消選中
- 顯示選中標記：`img_check` (ImageView, 20×20dp, `ic_check` 圖標)
- 選中時：`imgCheck.visibility = View.VISIBLE`
- 未選中時：`imgCheck.visibility = View.GONE` 或 `View.INVISIBLE`

**koralcore 的現狀**：
- ✅ `DeviceListController.selectionMode` - 已實現選擇模式
- ✅ `DeviceCard` - 已支持選擇模式
- ✅ 選中標記：使用 `IconButton` 顯示 `Icons.check_circle` 或 `Icons.circle_outlined`
- ✅ 選中時顯示藍色邊框：`borderColor = ReefColors.info`
- **對照狀態**：UI 實現方式不同（IconButton vs ImageView），但功能對照

---

## 6. 對照總結

| 功能點 | reef-b-app | koralcore | 狀態 |
|--------|-----------|-----------|------|
| 批量刪除（列表頁） | ✅ | ✅ | 已實現 |
| 單個刪除（詳情頁） | ✅ | ⚠️ | 需要確認 |
| 刪除確認對話框 | ✅ | ✅ | 已實現 |
| LED 主燈刪除限制 | ✅ | ⚠️ | 需要修改 |
| 刪除時斷開 BLE | ✅ | ❌ | 缺失 |
| 刪除成功後刷新列表 | ✅ | ⚠️ | 需要確認（可能通過 Stream 自動刷新） |
| 錯誤消息本地化 | ✅ | ⚠️ | 部分缺失 |
| 刪除模式 UI | ✅ | ✅ | 已實現（UI 方式不同但功能對照） |

### 6.1 UI 對照詳情

#### 刪除模式切換
- **reef-b-app**: `btn_choose` 按鈕（在 MainActivity Toolbar 中）切換刪除模式
- **koralcore**: `deviceSelectMode` 按鈕（在 DevicePage AppBar 中）切換選擇模式
- **對照狀態**: ✅ 功能對照，UI 位置不同

#### 選中標記
- **reef-b-app**: `img_check` (ImageView, 20×20dp, `ic_check` 圖標，位於卡片右下角)
- **koralcore**: `IconButton` 顯示 `Icons.check_circle` 或 `Icons.circle_outlined`（位於卡片右上角）
- **對照狀態**: ✅ 功能對照，UI 實現方式不同

#### 刪除按鈕
- **reef-b-app**: `btn_delete` (ImageView, 在 MainActivity Toolbar 中)
- **koralcore**: `deviceActionDelete` (TextButton, 在 DevicePage AppBar 的 actions 中)
- **對照狀態**: ✅ 功能對照，UI 實現方式不同

#### 刪除確認對話框
- **reef-b-app**: 
  - `dialog_device_delete` = "是否刪除所選設備?" (繁體中文) / "Delete the selected device?" (英文)
  - `dialog_device_delete_led_positive` = "刪除" / "Delete"
  - `dialog_device_delete_led_negative` = "取消" / "Cancel"
- **koralcore**: 
  - `deviceDeleteConfirmTitle` = "Remove devices?" (英文) / "Remove devices?" (繁體中文，需要對照)
  - `deviceDeleteConfirmMessage` = "The selected devices will be removed from this phone. This does not reset the hardware."
  - `deviceDeleteConfirmPrimary` = "Remove" / "Remove" (需要對照)
  - `deviceDeleteConfirmSecondary` = "Keep" / "Keep" (需要對照)
- **對照狀態**: ⚠️ 功能對照，但消息文本需要對照 reef-b-app（特別是繁體中文）

---

## 7. 需要實現/修改的部分

### 高優先級
1. **LED 主燈刪除限制檢查**
   - **問題**: `DeviceRepository.removeSavedDevice()` 中的檢查太簡單
   - **reef-b-app 邏輯**: 
     - **僅適用於 LED 設備**
     - 如果設備未分配水槽 → 可以刪除
     - 如果群組內只有 1 個設備 → 可以刪除（即使它是主燈）
     - 如果群組內有多個設備且是主燈 → 不能刪除
   - **DROP 設備**: 沒有刪除限制，可以自由刪除
   - **需要實現**: 
     - 在 `DeviceListController` 或 `RemoveDeviceUseCase` 中添加 `canDeleteDevice()` 方法
     - **只檢查 LED 設備**（`device.type == 'LED'`）
     - 檢查設備的 `sinkId`、`group`、`isMaster` 狀態
     - 查詢同群組內的其他設備數量
   - **錯誤消息**: 添加 `dialog_device_delete_led_master_content` 的本地化消息

2. **刪除時斷開 BLE 連接**
   - **問題**: `RemoveDeviceUseCase` 中有 TODO，但未實現
   - **reef-b-app 邏輯**: 
     - 在刪除前檢查設備是否已連接（`it.macAddress == bleManager.getConnectDeviceMacAddress()`）
     - 如果已連接，先調用 `bleManager.disConnect()`
   - **需要實現**: 
     - 在 `RemoveDeviceUseCase.execute()` 中，刪除前檢查設備是否已連接
     - 如果已連接，調用 `DisconnectDeviceUseCase.execute()`
     - 或者檢查 `deviceRepository.getDeviceState(deviceId)` 是否為 'connected'

### 中優先級
3. **錯誤消息本地化**
   - **缺失的消息**:
     - `dialog_device_delete_led_master_content` = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈"
     - `toast_delete_device_successful` = "刪除設備成功"（koralcore 使用 `snackbarDeviceRemoved`，需要確認對照）
     - `toast_delete_device_failed` = "刪除設備失敗"
   - **需要對照的消息**:
     - `deviceDeleteConfirmTitle` 和 `deviceDeleteConfirmMessage` 的繁體中文翻譯需要對照 reef-b-app

4. **刪除成功後的處理**
   - **reef-b-app**: 
     - 設備列表頁面：`viewModel.getAllDevice()` 刷新列表
     - 設備詳情頁：`viewModel.disConnect()` + `finish()` 關閉頁面
   - **koralcore**: 
     - 設備列表可能通過 `observeSavedDevices()` Stream 自動刷新（需要確認）
     - 需要確認是否有從詳情頁刪除的功能（LED/DROP 詳情頁）

### 低優先級
5. **UI 對照檢查**
   - ✅ 選中標記：功能對照，UI 實現方式不同（IconButton vs ImageView）
   - ✅ 刪除模式：功能對照，UI 位置不同（AppBar vs Toolbar）
   - ⚠️ 需要確認：刪除模式的視覺效果是否完全對照

