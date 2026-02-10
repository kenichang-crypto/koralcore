# DropSettingPage Android 行為分析

**分析日期**: 2026-01-03  
**Android Activity**: `DropSettingActivity`  
**Android ViewModel**: `DropSettingViewModel`  
**Android Layout**: `activity_drop_setting.xml`  

---

## 📋 Android 完整行為分析

### 1. 入口參數
```kotlin
// Line 199-202
private fun getDeviceIdFromIntent(): Int {
    return intent.getIntExtra("device_id", -1)
}
```
**參數**: `device_id` (Int)

---

### 2. 初始化流程

#### 2.1 setView() (Line 49-75)
1. 獲取 `device_id` 從 Intent
2. 如果 `device_id == -1` → `finish()`
3. `viewModel.setNowDeviceId(deviceId)` → 初始化設備資訊
4. 設置 Toolbar (title, right button, back button)
5. 設置 Device Name TextField (autoTrim, doAfterTextChanged)
6. 設置 Delay Time Button 啟用狀態 (根據連線狀態)

#### 2.2 ViewModel.setNowDeviceId() (Line 52-77)
1. Loading = true
2. 從 DB 讀取 `Device` by `id`
3. 初始化或獲取 `BLEManager` for device
4. 設置 BLE Listener
5. 讀取 `delayTime` 並更新 UI
6. 讀取 `sinkId` 並更新 UI
7. Loading = false

---

### 3. UI 結構 (activity_drop_setting.xml)

#### Root: ConstraintLayout
```xml
Line 2-6: Root ConstraintLayout (match_parent x match_parent)
```

#### Toolbar: toolbar_two_action (Line 8-14)
- Title: "設備設定" (activity_drop_setting_title)
- Right Button: "儲存" (activity_drop_setting_toolbar_right_btn)
- Back Button: ic_close

#### Main Content: ConstraintLayout (Line 16-112)
- **Padding**: 16dp (start/end), 12dp (top/bottom)
- **Height**: 0dp (填充剩餘空間)

**UI 結構 (由上到下)**:

1. **Device Name Section** (Line 29-59)
   - TextView: "設備名稱" (device_name)
   - TextInputLayout + TextInputEditText
   - Margin: 4dp (top)

2. **Sink Position Section** (Line 61-85)
   - TextView: "水槽位置" (sink_position)
   - MaterialButton: 顯示水槽名稱，icon=ic_next
   - Margin: 16dp (top), 4dp (between title and button)

3. **Delay Time Section** (Line 87-111)
   - TextView: "延遲時間" (delay_time)
   - MaterialButton: 顯示延遲時間，icon=ic_down
   - Margin: 16dp (top), 4dp (between title and button)

#### Progress Overlay (Line 114-119)
- Full screen overlay
- Visibility: gone (default)

---

### 4. 業務邏輯流程

#### 4.1 Edit Device Name (Line 66-72)
```kotlin
binding.edtName.apply {
    autoTrim(this)
    doAfterTextChanged {
        viewModel.setName(it.toString())
    }
    setText(viewModel.getDeviceName())
}
```
- 即時更新 ViewModel 的 `edtName`
- autoTrim: 自動去除頭尾空白

#### 4.2 Select Sink Position (Line 89-94)
```kotlin
binding.btnPosition.setOnClickListener {
    val intent = Intent(this, SinkPositionActivity::class.java)
    intent.putExtra("sink_id", viewModel.getSelectSinkId())
    sinkPositionLauncher.launch(intent)
}
```
- 啟動 `SinkPositionActivity` for result
- 傳入當前 `sink_id`
- 返回時更新 `selectSinkId` (Line 28-36)

#### 4.3 Select Delay Time (Line 95-124)
```kotlin
binding.btnDelayTime.setOnClickListener {
    showMenu(it, R.menu.delay_time_menu, PopupMenu.OnMenuItemClickListener { menu ->
        when (menu.itemId) {
            R.id.action_15_sec -> viewModel.setSelectDelayTime(15)
            R.id.action_30_sec -> viewModel.setSelectDelayTime(30)
            R.id.action_1_min -> viewModel.setSelectDelayTime(60)
            R.id.action_2_min -> viewModel.setSelectDelayTime(120)
            R.id.action_3_min -> viewModel.setSelectDelayTime(180)
            R.id.action_4_min -> viewModel.setSelectDelayTime(240)
            R.id.action_5_min -> viewModel.setSelectDelayTime(300)
        }
        return@OnMenuItemClickListener false
    })
}
```
- 顯示 PopupMenu 選擇延遲時間
- 選項: 15秒, 30秒, 1分, 2分, 3分, 4分, 5分

#### 4.4 Save (Line 81-88)
```kotlin
binding.toolbarDropSetting.btnRight.setOnClickListener {
    UserConfig.setDropModified(true)
    viewModel.editDevice({
        (R.string.toast_sink_is_full).toast(this)
    }, {
        (R.string.toast_name_is_empty).toast(this)
    })
}
```

**ViewModel.editDevice() 流程** (Line 106-154):
1. 檢查 `edtName.isEmpty()` → 顯示 "名稱為空" toast
2. Loading = true
3. 檢查水槽位置是否變更
   - 未變更 → 直接更新 DB
   - 變更 → 檢查新水槽是否已滿 (最多 4 個設備)
     - 已滿 → 顯示 "水槽已滿" toast
     - 未滿 → 更新 DB
4. 更新成功 → `_editDeviceLiveData.value = true`

---

### 5. BLE 命令流程

#### 5.1 setDelayTime() (Line 173-180)
```kotlin
fun setDelayTime() {
    if(isConnectNowDevice()){
        bleSetDelayTime(selectDelayTime)
    }else{
        _loadingLiveData.value = false
        _setDelayTimeLiveData.value = true
    }
}
```
- 如果設備已連線 → 發送 BLE 命令
- 如果未連線 → 直接完成 (只更新 DB)

#### 5.2 bleSetDelayTime() (Line 183-186)
```kotlin
private fun bleSetDelayTime(delayTime: Int) {
    _loadingLiveData.value = true
    bleManager.addQueue(CommandManager.getDropSetDelayTimeCommand(delayTime))
}
```
- BLE Command: `CommandManager.getDropSetDelayTimeCommand(delayTime)`

#### 5.3 BLE ACK 處理 (Line 255-265)
```kotlin
{ dropSetDelayTimeState ->
    when (dropSetDelayTimeState) {
        COMMAND_STATUS.SUCCESS -> {
            setDeviceDelayTime(selectDelayTime)
            _setDelayTimeLiveData.postValue(true)
        }
        else -> {
            _setDelayTimeLiveData.postValue(false)
        }
    }
    _loadingLiveData.postValue(false)
}
```
- SUCCESS → 更新 DB, 顯示成功 toast, finish()
- FAIL → 顯示失敗 toast

---

### 6. LiveData 觀察

#### 6.1 loadingLiveData (Line 128-137)
- true → 顯示 Progress Overlay
- false → 隱藏 Progress Overlay

#### 6.2 sinkNameLiveData (Line 138-144)
- not null → 顯示水槽名稱
- null → 顯示 "無" (R.string.no)

#### 6.3 editDeviceLiveData (Line 145-154)
- true → 調用 `setDelayTime()` (發送 BLE 命令)
- false → 顯示 "設定失敗" toast

#### 6.4 disconnectLiveData (Line 155-157)
- 斷線 → Delay Time Button disabled

#### 6.5 delayTimeLiveData (Line 158-184)
- 更新 Delay Time Button 顯示文字

#### 6.6 setDelayTimeLiveData (Line 185-195)
- true → 顯示 "設定成功" toast, finish()
- false → 顯示 "設定失敗" toast

---

### 7. 錯誤處理

#### 7.1 驗證錯誤
- 名稱為空 → toast "名稱為空" (toast_name_is_empty)
- 水槽已滿 → toast "水槽已滿" (toast_sink_is_full)

#### 7.2 BLE 錯誤
- 設定失敗 → toast "設定失敗" (toast_setting_failed)

#### 7.3 成功
- 設定成功 → toast "設定成功" (toast_setting_successful) + finish()

---

### 8. 狀態變數

#### ViewModel State
```kotlin
private var selectSinkId = 0 //目前裝置所在的水槽id
private var edtName: String = ""
private var selectDelayTime = 0
private lateinit var nowDevice: Device
```

---

## 📊 完整流程圖

### Success Case (已連線設備)
```
1. 用戶進入頁面 (device_id)
   ↓
2. ViewModel.setNowDeviceId()
   - 讀取 Device
   - 初始化 BLEManager
   - 讀取 delayTime, sinkId
   ↓
3. 用戶編輯設備名稱 → setName()
   ↓
4. 用戶選擇水槽位置 → SinkPositionActivity (for result) → setSelectSinkId()
   ↓
5. 用戶選擇延遲時間 → PopupMenu → setSelectDelayTime()
   ↓
6. 用戶點擊 "儲存"
   ↓
7. editDevice()
   - 驗證名稱
   - 驗證水槽容量
   - 更新 DB
   ↓
8. setDelayTime()
   - 檢查連線狀態
   - 發送 BLE 命令: getDropSetDelayTimeCommand(delayTime)
   ↓
9. BLE ACK: COMMAND_STATUS.SUCCESS
   - setDeviceDelayTime() (更新 DB)
   - 顯示 "設定成功" toast
   - finish()
```

### Success Case (未連線設備)
```
1-7. 同上
   ↓
8. setDelayTime()
   - 檢查連線狀態: 未連線
   - 直接返回成功 (不發送 BLE)
   ↓
9. 顯示 "設定成功" toast
   - finish()
```

---

## 🎯 Flutter 實施要點

### Controller 需實現
1. **狀態變數**:
   - `String deviceId`
   - `String deviceName`
   - `String? sinkId`
   - `String? sinkName`
   - `int delayTimeSeconds`
   - `bool isLoading`
   - `AppErrorCode? lastErrorCode`

2. **Public 方法**:
   - `initialize()` - 初始化設備資訊
   - `updateName(String name)` - 更新設備名稱
   - `updateSinkId(String? sinkId)` - 更新水槽位置
   - `updateDelayTime(int seconds)` - 更新延遲時間
   - `Future<bool> save()` - 儲存設定 (DB + BLE)

3. **依賴**:
   - `AppSession` - 當前設備資訊
   - `DeviceRepository` - 設備 CRUD
   - `SinkRepository` - 水槽查詢
   - `BleAdapter` + `DosingCommandBuilder` - BLE 命令
   - `UpdateDeviceSettingsUseCase` - 業務邏輯

### Page 需實現
1. **UI 結構**: 嚴格遵循 XML (已 100% Parity)
2. **互動**:
   - Device Name TextField: onChanged
   - Sink Position Button: 導航到 SinkPositionPage (for result)
   - Delay Time Button: 顯示 PopupMenu / BottomSheet
   - Save Button: 調用 controller.save()
3. **狀態處理**:
   - Loading Overlay
   - Error SnackBar
   - Success Toast + Navigator.pop()

---

## 📝 關鍵注意事項

### 1. 水槽容量限制
- 每個水槽最多 4 個 Dosing 設備
- 需在 save 前檢查

### 2. Delay Time 選項
- 15秒, 30秒, 1分, 2分, 3分, 4分, 5分
- 儲存時以秒為單位

### 3. BLE 命令
- Opcode: `getDropSetDelayTimeCommand(delayTime)`
- 只在設備已連線時發送
- 未連線時只更新 DB

### 4. 名稱驗證
- 不可為空
- autoTrim (去除頭尾空白)

### 5. 返回邏輯
- 成功儲存 → finish()
- 點擊 Back → finish() (不儲存)

---

**分析完成日期**: 2026-01-03  
**下一步**: 創建 DropSettingController

