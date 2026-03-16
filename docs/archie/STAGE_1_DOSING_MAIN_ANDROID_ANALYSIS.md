# 第一階段 - DosingMainPage 完整 Android 行為分析

**分析日期**: 2026-01-03  
**Android 源碼**: `reef-b-app/DropMainActivity.kt` + `DropMainViewModel.kt`  
**Flutter 目標**: `koralcore/lib/features/doser/presentation/pages/dosing_main_page.dart`

---

## 📋 Android 完整行為盤點

### 一、生命週期與初始化

#### `onCreate()` (Line 47-65)

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(binding.root)

    setView()
    setListener()
    setObserver()

    deviceId = getDeviceIdFromIntent()  // 從 Intent 獲取 device_id
    if (deviceId == -1) {
        finish()  // 無效 ID 則關閉頁面
    }

    viewModel.setDeviceById(deviceId)  // 設置當前裝置
    viewModel.getAllDropHead()         // 獲取所有泵頭
    viewModel.getDropHeadMode()        // 獲取泵頭模式
    viewModel.getAllDropInfo()         // 獲取所有滴液資訊（觸發 BLE Sync 0x65）
    UserConfig.setDropModified(false)
}
```

**初始化順序**:
1. 設置 View（RecyclerView）
2. 設置 Listener
3. 設置 Observer
4. 獲取 device_id
5. **ViewModel 初始化**:
   - `setDeviceById()` → 創建 BLEManager → 設置 listener
   - `getAllDropHead()` → 從 DB 載入 4 個泵頭
   - `getDropHeadMode()` → 獲取泵頭模式
   - `getAllDropInfo()` → **自動觸發 BLE Sync (0x65)**

#### `onResume()` (Line 67-80)

```kotlin
override fun onResume() {
    super.onResume()

    viewModel.setDeviceById(deviceId)

    if (UserConfig.isDropModified()) {
        viewModel.getAllDropHead()
        viewModel.getDropHeadMode()
        viewModel.getAllDropInfo()
    }
    UserConfig.setDropModified(false)
    setBleStateUi(viewModel.isConnectNowDevice())
}
```

**行為**:
- 如果從其他頁面返回且有修改（`UserConfig.isDropModified()`），則重新載入數據
- 更新 BLE 連線狀態 UI

---

### 二、UI 互動行為

#### 1. Toolbar Actions

##### 1.1 Back Button (Line 92-94)
```kotlin
binding.toolbarDropMain.btnBack.setOnClickListener {
    finish()
}
```
**行為**: 返回上一頁

##### 1.2 Menu Button (Line 95-120)
```kotlin
binding.toolbarDropMain.btnMenu.setOnClickListener { view ->
    val pop = PopupMenu(this, view)
    pop.inflate(R.menu.drop_menu)  // 3 個選項: Edit, Delete, Reset
    pop.setOnMenuItemClickListener { item ->
        when (item.itemId) {
            R.id.action_edit -> {
                // 導航到 DropSettingActivity
                val intent = Intent(this, DropSettingActivity::class.java)
                intent.putExtra("device_id", viewModel.getNowDevice().id)
                startActivity(intent)
            }
            R.id.action_delete -> {
                createDeleteDropDialog()  // 刪除裝置對話框
            }
            R.id.action_reset -> {
                if (viewModel.isConnectNowDevice()) {
                    createResetDropDialog()  // 重置裝置對話框
                } else {
                    (R.string.device_is_not_connect).toast(this)
                }
            }
        }
        true
    }
    pop.show()
}
```

**行為**:
- **Edit**: 導航到 `DropSettingActivity`
- **Delete**: 顯示刪除確認對話框
- **Reset**: 如果已連線，顯示重置確認對話框；否則 Toast "device_is_not_connect"

##### 1.3 Favorite Button (Line 121-123)
```kotlin
binding.toolbarDropMain.btnFavorite.setOnClickListener {
    viewModel.favoriteDevice()
}
```
**行為**: 切換喜愛狀態（Toggle）

#### 2. BLE Connection Button (Line 125-129)

```kotlin
binding.btnBle.setOnClickListener {
    checkBlePermission(this) {
        viewModel.clickBtnBle()
    }
}
```

**行為** (ViewModel Line 74-84):
```kotlin
fun clickBtnBle() {
    if (isConnectNowDevice()) {
        disConnect()  // 已連線 → 斷線
    } else {
        if (!BleContainer.getInstance().isExistBleManager(nowDevice.macAddress)) {
            setDeviceById(nowDevice.id)
        }
        connectDeviceByMacAddress(nowDevice.macAddress)  // 未連線 → 連線
    }
}
```

**流程**:
1. 檢查 BLE 權限
2. 如果已連線 → 斷線
3. 如果未連線 → 連線

#### 3. Pump Head Card Click (Line 299-305)

```kotlin
override fun onClickDropHead(data: DropHead) {
    val intent = Intent(this, DropHeadMainActivity::class.java)
    intent.putExtra("drop_head_id", data.id)
    startActivity(intent)
}
```

**行為**: 導航到 `DropHeadMainActivity`（泵頭詳細頁面）

#### 4. Play Button Click (Line 307-313)

```kotlin
override fun onClickPlayDropHead(data: DropHead) {
    viewModel.clickPlayDropHead(data) {
        createDropOutOfRangeDialog()  // 超出每日最大滴液量的回調
    }
}
```

**ViewModel 行為** (Line 86-105):
```kotlin
fun clickPlayDropHead(data: DropHead, dropExceed: () -> Unit) {
    clickPlayDropHeadId = data.headId
    data.maxDrop?.let {
        if (it < getDropHeadTodayTotalDrop(data.id)) {
            dropExceed()  // 超出每日最大滴液量
        } else {
            if (manualDropState[data.headId]) {
                bleManualDropEnd(data.headId)  // 正在滴液 → 結束 (0x6D)
            } else {
                bleManualDropStart(data.headId)  // 未滴液 → 開始 (0x6E)
            }
        }
    } ?: run {
        if (manualDropState[data.headId]) {
            bleManualDropEnd(data.headId)
        } else {
            bleManualDropStart(data.headId)
        }
    }
}
```

**流程**:
1. 檢查是否設置每日最大滴液量
2. 如果有設置且今日總量已達上限 → 顯示對話框
3. 否則：
   - 如果正在滴液 (`manualDropState[headId] == true`) → 發送結束指令 (0x6D)
   - 如果未滴液 → 發送開始指令 (0x6E)

---

### 三、BLE 指令序列

#### 3.1 連線成功後自動執行 (Line 336-340)

```kotlin
override fun onOpenNotify(gatt: BluetoothGatt?) {
    super.onOpenNotify(gatt)
    bleManager.detectDoseFormat()  // 檢測裝置能力 (0x7E or 0x7A)
    bleSetTimeCorrection()         // 時間校正 (0x60)
}
```

**序列**:
1. **連線成功** → `onOpenNotify()`
2. **檢測格式** → `detectDoseFormat()` (0x7E/0x7A)
3. **時間校正** → `bleSetTimeCorrection()` (0x60)
4. **時間校正成功** → `bleSyncInformation()` (0x65 START)

#### 3.2 Sync Information 流程 (Line 380-391)

```kotlin
{ dropSyncInformationState ->
    when (dropSyncInformationState) {
        COMMAND_STATUS.START -> {
            _loadingLiveData.postValue(true)
        }
        COMMAND_STATUS.END -> {
            bleGetTotalDrop(0)  // Sync 結束後，開始讀取今日總量
        }
        else -> {
            _loadingLiveData.postValue(false)
        }
    }
}
```

**序列**:
1. **發送 Sync START** (0x65)
2. **接收多筆資料** (排程、模式等)
3. **接收 Sync END**
4. **開始讀取今日總量** → `bleGetTotalDrop(0)`

#### 3.3 讀取今日總量流程 (Line 396-403)

```kotlin
{ dropGetTotalDropNo ->
    if (dropGetTotalDropNo < 3) {
        bleGetTotalDrop(dropGetTotalDropNo + 1)  // 依序讀取 0, 1, 2, 3
    } else {
        _dropHeadRecordLiveData.postValue(dropInformation.getModes())
        _loadingLiveData.postValue(false)
    }
}
```

**序列**:
1. **讀取泵頭 0** → `bleGetTotalDrop(0)` (0x7E/0x7A)
2. **讀取泵頭 1** → `bleGetTotalDrop(1)`
3. **讀取泵頭 2** → `bleGetTotalDrop(2)`
4. **讀取泵頭 3** → `bleGetTotalDrop(3)`
5. **完成** → 更新 UI

#### 3.4 手動滴液流程 (Line 403-430)

```kotlin
{ dropManualDropStartState ->
    when (dropManualDropStartState) {
        COMMAND_STATUS.SUCCESS -> {
            clickPlayDropHeadId?.let {
                manualDropState[it] = true  // 標記為滴液中
                manualDropSuccessLiveData.postValue(manualDropState)
            }
        }
        COMMAND_STATUS.FAILED_ING -> {
            _manualDropErrorLiveData.postValue(Unit)  // 已經在滴液中
        }
        else -> { }
    }
    _loadingLiveData.postValue(false)
}

{ dropManualDropEndState ->
    when (dropManualDropEndState) {
        COMMAND_STATUS.SUCCESS -> {
            clickPlayDropHeadId?.let {
                manualDropState[it] = false  // 標記為停止
                manualDropSuccessLiveData.postValue(manualDropState)
            }
        }
        else -> { }
    }
    _loadingLiveData.postValue(false)
}
```

**流程**:
1. **發送開始指令** (0x6E)
2. **接收 ACK**:
   - SUCCESS → 更新 UI，Play Button 變為 Pause
   - FAILED_ING → Toast "drophead_is_droping"
3. **發送結束指令** (0x6D)
4. **接收 ACK**:
   - SUCCESS → 更新 UI，Pause Button 變為 Play

---

### 四、LiveData Observers

#### 4.1 loadingLiveData (Line 133-142)
**行為**: 控制 Progress Overlay 顯示/隱藏

#### 4.2 deviceLiveData (Line 143-164)
**行為**:
- 更新 Toolbar 標題（裝置名稱）
- 更新 Favorite 圖標
- 更新裝置識別區（名稱、位置）
- 更新 BLE 連線狀態圖標

#### 4.3 deleteDeviceLiveData (Line 165-176)
**行為**:
- true → Toast "delete_device_successful" → `disConnect()` → `finish()`
- false → Toast "delete_device_failed"

#### 4.4 resetDeviceLiveData (Line 177-188)
**行為**:
- true → Toast "reset_device_successful" → `disConnect()` → `finish()`
- false → Toast "reset_device_failed"

#### 4.5 favoriteDeviceLiveData (Line 189-199)
**行為**:
- true → 更新圖標為 `ic_favorite_select`
- false → 更新圖標為 `ic_favorite_unselect`
- 重新載入裝置資料

#### 4.6 dropHeadLiveData (Line 200-202)
**行為**: 更新 RecyclerView (4 個泵頭卡片)

#### 4.7 disconnectLiveData (Line 203-205)
**行為**: 更新 BLE 連線狀態 UI

#### 4.8 isConnectedLiveData (Line 206-216)
**行為**:
- true → Toast "connect_successful" → 更新 BLE 連線狀態 UI
- false → Toast "connect_failed"

#### 4.9 dropHeadRecordLiveData (Line 217-229)
**行為**: 更新泵頭卡片的排程資訊（模式、時間、進度條等）

#### 4.10 manualDropSuccessLiveData (Line 230-234)
**行為**: 更新 Play/Pause 按鈕狀態（4 個按鈕）

#### 4.11 manualDropErrorLiveData (Line 235-237)
**行為**: Toast "drophead_is_droping"

---

### 五、完整 BLE 指令清單

| 指令 | Opcode | 時機 | 參數 | ACK |
|------|--------|------|------|-----|
| 檢測格式 | 0x7E/0x7A | 連線成功後 | - | 返回裝置能力 |
| 時間校正 | 0x60 | 檢測格式後 | 年月日時分秒星期 | SUCCESS/FAILED |
| Sync Information | 0x65 | 時間校正成功後 | START | START/END |
| 讀取今日總量 | 0x7E/0x7A | Sync END 後 | 泵頭編號 (0-3) | 總量數值 |
| 手動滴液開始 | 0x6E | Play Button | 泵頭編號 (0-3) | SUCCESS/FAILED_ING |
| 手動滴液結束 | 0x6D | Pause Button | 泵頭編號 (0-3) | SUCCESS/FAILED |
| 重置裝置 | 0x70 | Reset Dialog | - | SUCCESS/FAILED |

---

### 六、Dialogs

#### 6.1 Delete Dialog (Line 272-282)
```kotlin
private fun createDeleteDropDialog() {
    createDialog(
        this,
        content = getString(R.string.dialog_delete_drop_content),
        positiveString = getString(R.string.dialog_delete_drop_positive),
        positiveListener = { _, _ ->
            viewModel.deleteDevice()
        },
        negativeString = getString(R.string.dialog_delete_drop_negative),
    )
}
```

#### 6.2 Reset Dialog (Line 285-296)
```kotlin
private fun createResetDropDialog() {
    createDialog(
        this,
        title = getString(R.string.dialog_reset_drop_title),
        content = getString(R.string.dialog_reset_drop_content),
        positiveString = getString(R.string.dialog_reset_drop_positive),
        positiveListener = { _, _ ->
            viewModel.resetDevice()
        },
        negativeString = getString(R.string.dialog_reset_drop_negative),
    )
}
```

#### 6.3 Drop Out of Range Dialog (Line 262-269)
```kotlin
private fun createDropOutOfRangeDialog() {
    createDialog(
        this,
        title = getString(R.string.dialog_today_drop_out_of_range_title),
        content = getString(R.string.dialog_today_drop_out_of_range_content),
        positiveString = getString(R.string.dialog_today_drop_out_of_range_positive),
    )
}
```

---

## 📋 Flutter 實施清單

### Phase 1: 架構重建（4-6 小時）

#### 1.1 創建 DosingMainController
- [ ] 繼承 `ChangeNotifier`
- [ ] 定義所有 State
- [ ] 實現 `initialize(deviceId)` 方法
- [ ] 實現 BLE 連線/斷線方法
- [ ] 實現 Play/Pause 方法
- [ ] 實現 Favorite/Delete/Reset 方法

#### 1.2 創建 UseCases
- [ ] `ConnectDosingDeviceUseCase`
- [ ] `DisconnectDosingDeviceUseCase`
- [ ] `SyncDosingStateUseCase`
- [ ] `ExecuteImmediateDosingUseCase`
- [ ] `ToggleFavoriteDeviceUseCase`
- [ ] `DeleteDeviceUseCase`
- [ ] `ResetDeviceUseCase`

#### 1.3 創建/更新 Repository
- [ ] `BleDosingRepository` interface
- [ ] `BleDosingRepositoryImpl` implementation
- [ ] 實現所有 BLE 指令方法：
  - `detectDoseFormat()` (0x7E/0x7A)
  - `sendTimeCorrection()` (0x60)
  - `syncInformation()` (0x65)
  - `readTodayTotal(headIndex)` (0x7E/0x7A)
  - `startManualDrop(headIndex)` (0x6E)
  - `endManualDrop(headIndex)` (0x6D)
  - `resetDevice()` (0x70)

### Phase 2: UI 更新（2-3 小時）

#### 2.1 修改 DosingMainPage
- [ ] 從 `StatelessWidget` 改為使用 `ChangeNotifierProvider`
- [ ] 移除所有 `onPressed: null`
- [ ] 連接 Controller 的所有方法
- [ ] 添加 Dialog widgets

#### 2.2 修改 Toolbar
- [ ] 啟用 Back button → `Navigator.pop()`
- [ ] 啟用 Menu button → `showPopupMenu()`
- [ ] 啟用 Favorite button → `controller.toggleFavorite()`

#### 2.3 修改 BLE Button
- [ ] 啟用 `onPressed` → `controller.toggleBleConnection()`

#### 2.4 修改 Pump Head Cards
- [ ] 啟用 Card `onTap` → 導航到 `PumpHeadDetailPage`
- [ ] 啟用 Play Button → `controller.toggleManualDrop(headId)`

### Phase 3: 測試與驗證（2-3 小時）

- [ ] 連線/斷線流程
- [ ] 手動滴液流程
- [ ] Favorite toggle
- [ ] Delete/Reset 流程
- [ ] 錯誤處理
- [ ] UI 狀態更新

---

## 🎯 預期時間

| 階段 | 預計時間 | 備註 |
|------|---------|------|
| Phase 1 | 4-6 小時 | 架構最複雜 |
| Phase 2 | 2-3 小時 | UI 較簡單 |
| Phase 3 | 2-3 小時 | 測試與調整 |
| **總計** | **8-12 小時** | 略超過原預估 8-10h |

---

**分析完成日期**: 2026-01-03  
**下一步**: 開始 Phase 1 - 創建 DosingMainController

