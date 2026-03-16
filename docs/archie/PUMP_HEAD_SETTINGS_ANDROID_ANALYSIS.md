# PumpHeadSettingsPage Android 行為分析

**分析日期**: 2026-01-03  
**Android Activity**: `DropHeadSettingActivity`  
**Android ViewModel**: `DropHeadSettingViewModel`  
**Android Layout**: `activity_drop_head_setting.xml`  

---

## 📋 Android 完整行為分析

### 1. 入口參數
```kotlin
// Line 224-227
private fun getDropHeadIdFromIntent(): Int {
    return intent.getIntExtra("drop_head_id", -1)
}
```
**參數**: `drop_head_id` (Int) - 泵頭 ID (0-3, 對應 A-D)

---

### 2. UI 結構 (activity_drop_head_setting.xml)

#### Root: ConstraintLayout (Line 2-6)

#### Toolbar: toolbar_two_action (Line 8-14)
- Title: "CH {headId + 1}" (動態, e.g. CH 1, CH 2)
- Right Button: "儲存"
- Back Button: ic_close

#### Main Content: ConstraintLayout (Line 16-160)
- **Padding**: 16dp (start/end), 12dp (top/bottom)
- **Height**: 0dp (填充剩餘空間, **不可捲動**)

**UI 結構 (由上到下)**:

1. **Drop Type Section** (Line 29-53) ✅ **VISIBLE**
   - TextView: "滴液種類" (drop_type)
   - MaterialButton: 顯示種類名稱, icon=ic_next
   - Margin: 4dp (top)

2. **Max Drop Volume Section** (Line 55-130) ❌ **GONE**
   - TextView: "每日最大滴液量" (max_drop_volume) - **visibility=gone**
   - TextInputLayout + TextField (number input) - **visibility=gone**
   - TextView: "每日最大滴液量" (title) - **visibility=gone**
   - TextView: Hint text - **visibility=gone**
   - SwitchMaterial - **visibility=gone**
   - Margin: 16dp (top)

3. **Rotating Speed Section** (Line 132-159) ✅ **VISIBLE** (but **enabled=false**)
   - TextView: "轉速設定" (init_rotating_speed) - **enabled=false**
   - MaterialButton: 顯示轉速, icon=ic_down - **enabled=false**
   - Margin: 16dp (top), 4dp (between title and button)

#### Progress Overlay (Line 162-167)
- Full screen overlay
- Visibility: gone (default)

---

### 3. 初始化流程

#### 3.1 setView() (Line 56-91)
1. 獲取 `drop_head_id` 從 Intent
2. 如果 `drop_head_id == -1` → `finish()`
3. `viewModel.setNowDropHeadId(dropHeadId)` → 初始化泵頭資訊
4. 設置 Toolbar (title, right button, back button)
5. 設置 Max Drop Per Day TextField (已 GONE, 但程式碼仍設定)

#### 3.2 ViewModel.setNowDropHeadId() (Line 86-119)
1. Loading = true
2. 從 DB 讀取 `DropHead` by `id`
3. 設置 `selectDropTypeId` (dropTypeId or 0)
4. 設置 `swMaxDropPerDaySwitch` 和 `edtMaxDropPerDay`
5. 設置 `selectRotatingSpeed`
6. 讀取 `Device` 並初始化 `BLEManager`
7. 更新 UI (LiveData)
8. Loading = false

---

### 4. 業務邏輯流程

#### 4.1 Select Drop Type (Line 103-108)
```kotlin
binding.btnDropType.setOnClickListener {
    val intent = Intent(this, DropTypeActivity::class.java)
    intent.putExtra("drop_type_id", viewModel.getSelectSinkId())
    dropTypeLauncher.launch(intent)
}
```
- 啟動 `DropTypeActivity` for result
- 傳入當前 `drop_type_id`
- 返回時更新 `selectDropTypeId` (Line 35-37)

#### 4.2 Max Drop Volume Switch (Line 109-112) ❌ **GONE, 不實現**
```kotlin
binding.swMaxDropPerDaySwitch.setOnCheckedChangeListener { buttonView, isChecked ->
    viewModel.setSwMaxDropPerDaySwitch(isChecked)
    setEdtMaxDropPerDay(isChecked)
}
```
- Switch ON → Enable TextField
- Switch OFF → Disable TextField, clear value

#### 4.3 Select Rotating Speed (Line 113-130)
```kotlin
binding.btnRotatingSpeed.setOnClickListener {
    showMenu(it, R.menu.rotating_speed_menu, PopupMenu.OnMenuItemClickListener { menu ->
        when (menu.itemId) {
            R.id.action_low_speed -> viewModel.setSelectRotatingSpeed(1)
            R.id.action_middle_speed -> viewModel.setSelectRotatingSpeed(2)
            R.id.action_high_speed -> viewModel.setSelectRotatingSpeed(3)
        }
        return@OnMenuItemClickListener false
    })
}
```
- 顯示 PopupMenu 選擇轉速
- 選項: 1=低速, 2=中速, 3=高速
- **只在已連線時啟用** (Line 203-205)

#### 4.4 Save (Line 97-102)
```kotlin
binding.toolbarDropHeadSetting.btnRight.setOnClickListener {
    UserConfig.setDropModified(true)
    viewModel.editDropHead {
        (R.string.toast_max_drop_per_day_is_empty).toast(this)
    }
}
```

**ViewModel.editDropHead() 流程** (Line 140-164):
1. 檢查 `swMaxDropPerDaySwitch && edtMaxDropPerDay == null` → 顯示 "最大滴液量為空" toast (但 Switch 已 GONE)
2. Loading = true
3. 創建 `DropHeadEdit` 並更新:
   - `dropTypeId` (如果不為 0)
   - `maxDrop` (根據 Switch 狀態)
4. 更新 DB
5. `_editDropHeadLiveData.value = true`

---

### 5. BLE 命令流程

#### 5.1 setRotatingSpeed() (Line 131-138)
```kotlin
fun setRotatingSpeed() {
    if (isConnectNowDevice()) {
        bleSetRotatingSpeed()
    } else {
        _loadingLiveData.value = false
        _setRotatingSpeedLiveData.value = true
    }
}
```
- 如果設備已連線 → 發送 BLE 命令
- 如果未連線 → 直接完成 (只更新 DB)

#### 5.2 bleSetRotatingSpeed() (Line 167-174)
```kotlin
private fun bleSetRotatingSpeed() {
    bleManager.addQueue(
        CommandManager.getDropSetRotatingSpeedCommand(
            nowDropHead.headId,
            selectRotatingSpeed
        )
    )
}
```
- BLE Command: `getDropSetRotatingSpeedCommand(headId, speed)`
- Opcode: 0x62

#### 5.3 BLE ACK 處理 (Line 245-255)
```kotlin
{ dropSetRotatingSpeed ->
    when (dropSetRotatingSpeed) {
        COMMAND_STATUS.SUCCESS -> {
            setDeviceRotatingSpeed()
            _setRotatingSpeedLiveData.postValue(true)
        }
        else -> {
            _setRotatingSpeedLiveData.postValue(false)
        }
    }
    _loadingLiveData.postValue(false)
}
```
- SUCCESS → 更新 DB, 顯示成功 toast, finish()
- FAIL → 顯示失敗 toast

---

### 6. LiveData 觀察

#### 6.1 loadingLiveData (Line 134-143)
- true → 顯示 Progress Overlay
- false → 隱藏 Progress Overlay

#### 6.2 dropHeadLiveData (Line 144-151)
- 更新 Toolbar title: "CH {headId + 1}"
- 更新 BLE 狀態 UI (enabled/disabled)

#### 6.3 disconnectLiveData (Line 152-155)
- 斷線 → Rotating Speed Button + Title disabled

#### 6.4 dropTypeNameLiveData (Line 156-162)
- not null → 顯示種類名稱
- null → 顯示 "無" (R.string.no)

#### 6.5 editDropHeadLiveData (Line 163-172)
- true → 調用 `setRotatingSpeed()` (發送 BLE 命令)
- false → 顯示 "設定失敗" toast

#### 6.6 rotatingSpeedLiveData (Line 173-187)
- 更新 Rotating Speed Button 顯示文字:
  - 1 → "低速"
  - 2 → "中速"
  - 3 → "高速"

#### 6.7 setRotatingSpeedLiveData (Line 188-198)
- true → 顯示 "設定成功" toast, finish()
- false → 顯示 "設定失敗" toast

---

### 7. 連線狀態處理

#### 7.1 setBleStateUi() (Line 202-205)
```kotlin
private fun setBleStateUi(isConnect: Boolean) {
    binding.btnRotatingSpeed.isEnabled = isConnect
    binding.tvRotatingSpeedTitle.isEnabled = isConnect
}
```
- 已連線 → Rotating Speed 可操作
- 未連線 → Rotating Speed 禁用

---

## 🎯 Flutter 實施要點

### Controller 需實現/擴充

**現有 Controller**: `PumpHeadSettingsController` (53 lines) ⚠️ 需大幅擴充

**需要的狀態變數**:
1. `String headId` (A/B/C/D)
2. `int? dropTypeId`
3. `String? dropTypeName`
4. `int rotatingSpeed` (1/2/3)
5. `bool isLoading`
6. `bool isSaving`
7. `AppErrorCode? lastErrorCode`
8. `bool isConnected`

**需要的 Public 方法**:
1. `initialize()` - 初始化泵頭資訊
2. `updateDropTypeId(int? typeId)` - 更新滴液種類
3. `updateRotatingSpeed(int speed)` - 更新轉速
4. `Future<bool> save()` - 儲存設定 (DB + BLE)

**需要的依賴**:
- `AppSession` - 當前設備資訊
- `PumpHeadRepository` - 泵頭 CRUD
- `DropTypeRepository` - 滴液種類查詢 (新增！)
- `BleAdapter` + `DosingCommandBuilder` - BLE 命令

### Page 需實現

1. **UI 結構**: 嚴格遵循 XML
2. **互動**:
   - Drop Type Button: 導航到 DropTypePage (for result)
   - Rotating Speed Button: 顯示 PopupMenu / BottomSheet (只在已連線時)
   - Save Button: 調用 controller.save()
3. **狀態處理**:
   - Loading Overlay
   - Error SnackBar
   - Success Toast + Navigator.pop()

---

## 📝 關鍵注意事項

### 1. Max Drop Volume Section - ❌ **GONE**
- XML 中所有 Max Drop Volume 相關元件都是 **visibility=gone**
- **Flutter 不應實現此功能**
- 保持與 Android 完全一致

### 2. Rotating Speed - **只在已連線時啟用**
- 初始狀態: **enabled=false**
- 連線後: **enabled=true**
- 斷線後: **enabled=false**

### 3. BLE 命令
- Opcode: `getDropSetRotatingSpeedCommand(headId, speed)` (0x62)
- 只在設備已連線時發送
- 未連線時只更新 DB

### 4. 保存流程
1. Update DB (`dropTypeId`)
2. 發送 BLE 命令 (`setRotatingSpeed`)
3. Success → finish()

### 5. Toolbar Title
- 動態顯示: "CH {headId + 1}"
- headId: 0→CH 1, 1→CH 2, 2→CH 3, 3→CH 4
- 或 headId: A→CH 1, B→CH 2, C→CH 3, D→CH 4

---

**分析完成日期**: 2026-01-03  
**下一步**: 審查和擴充 PumpHeadSettingsController

