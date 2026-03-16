# DOSING_DROP_SETTING_PARITY_AUDIT.md

**稽核日期**：2026-01-03  
**稽核工程師**：資深 Android / Flutter IoT / BLE State Machine 稽核工程師  
**Android 事實來源**：reef-b-app  
**Flutter 對照對象**：koralcore

---

## 【A】Android 程式來源盤點

### A.1 Activity / Fragment

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| Activity | `DropSettingActivity.kt` | `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_setting/DropSettingActivity.kt` | Line 20-203 |

---

### A.2 XML Layout

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| Activity Layout | `activity_drop_setting.xml` | `android/ReefB_Android/app/src/main/res/layout/activity_drop_setting.xml` | Line 1-120 |
| Toolbar Include | `toolbar_two_action.xml` | `android/ReefB_Android/app/src/main/res/layout/toolbar_two_action.xml` | (已盤點) |
| Progress Include | `progress.xml` | `android/ReefB_Android/app/src/main/res/layout/progress.xml` | (已盤點) |
| Menu | `delay_time_menu.xml` | `android/ReefB_Android/app/src/main/res/menu/delay_time_menu.xml` | (待讀取) |

---

### A.3 ViewModel / Controller

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| ViewModel | `DropSettingViewModel.kt` | `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_setting/DropSettingViewModel.kt` | Line 18-291 |

---

### A.4 Manager / Repository / BLE

| 類別 | 檔名 | 方法 | 完整路徑 | 行號 |
|------|-----|------|----------|------|
| CommandManager | `CommandManager.kt` | `getDropSetDelayTimeCommand()` | `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ble/CommandManager.kt` | Line 404+ |
| BLEManager | `BLEManager.kt` | `addQueue()` | (標準 BLE 方法) | - |
| BleContainer | `BleContainer.kt` | `getBleManager()` | (標準 BLE 容器) | - |
| Database | `DeviceDao.kt` | `editDevice()`, `editDeviceDelayTime()` | (標準 DAO) | - |
| Database | `SinkDao.kt` | `getSinkById()` | (標準 DAO) | - |

---

## 【B】Android XML / UI 結構事實

### B.1 Root Layout

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent">
```

**事實**：
- Root: `ConstraintLayout`
- `layout_width`: `match_parent`
- `layout_height`: `match_parent`
- 無 `background` 屬性（使用預設）

---

### B.2 Toolbar

```xml
<include
    android:id="@+id/toolbar_drop_setting"
    layout="@layout/toolbar_two_action"
    app:layout_constraintBottom_toTopOf="@id/layout_drop_setting"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toTopOf="parent" />
```

**事實**：
- Include: `toolbar_two_action.xml`
- ID: `toolbar_drop_setting`
- Constraint: 固定於頂部，下方連接 `layout_drop_setting`
- Toolbar 內容（Activity 設定）：
  - `toolbarTitle.visibility = VISIBLE`
  - `toolbarTitle.text = @string/activity_drop_setting_title` (Line 59)
  - `btnRight.visibility = VISIBLE`
  - `btnRight.text = @string/activity_drop_setting_toolbar_right_btn` (Line 61)
  - `btnBack.visibility = VISIBLE`
  - `btnBack.setImageResource(R.drawable.ic_close)` (Line 63)

---

### B.3 Main Content Area

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:id="@+id/layout_drop_setting"
    android:layout_width="match_parent"
    android:layout_height="@dimen/dp_0"
    android:paddingStart="@dimen/dp_16"
    android:paddingTop="@dimen/dp_12"
    android:paddingEnd="@dimen/dp_16"
    android:paddingBottom="@dimen/dp_12"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/toolbar_drop_setting">
```

**事實**：
- ID: `layout_drop_setting`
- 類型: `ConstraintLayout`
- `layout_width`: `match_parent`
- `layout_height`: `@dimen/dp_0` (0dp，由 constraint 決定，填滿剩餘空間)
- Padding: `16/12/16/12dp` (start/top/end/bottom)
- Constraint: 固定於 Toolbar 下方至畫面底部
- **不可捲動**：無 `ScrollView`，此區塊為固定高度，由 constraint 決定

---

### B.4 UI 區塊 1：Device Name（設備名稱）

#### B.4.1 Title
```xml
<TextView
    android:id="@+id/tv_device_name_title"
    style="@style/SingleLine"
    android:layout_width="@dimen/dp_0"
    android:layout_height="wrap_content"
    android:text="@string/device_name"
    android:textAppearance="@style/caption1"
    app:layout_constraintBottom_toTopOf="@id/layout_name"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toTopOf="parent" />
```

**事實**：
- ID: `tv_device_name_title`
- 類型: `TextView`
- `layout_width`: `0dp` (constraint 決定寬度)
- `layout_height`: `wrap_content`
- Text: `@string/device_name`
- TextAppearance: `@style/caption1`
- Style: `@style/SingleLine`
- Constraint: 頂部對齊 parent，下方連接 `layout_name`

#### B.4.2 Input Field
```xml
<com.google.android.material.textfield.TextInputLayout
    android:id="@+id/layout_name"
    style="@style/TextInputLayout"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_4"
    app:layout_constraintBottom_toTopOf="@id/tv_device_position_title"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/tv_device_name_title">

    <com.google.android.material.textfield.TextInputEditText
        android:id="@+id/edt_name"
        style="@style/SingleLine"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:inputType="text"
        android:textAppearance="@style/body" />
</com.google.android.material.textfield.TextInputLayout>
```

**事實**：
- ID: `layout_name` (外層), `edt_name` (內層)
- 類型: `TextInputLayout` + `TextInputEditText`
- `layout_width`: `match_parent`
- `layout_height`: `wrap_content`
- `layout_marginTop`: `4dp`
- Style: `@style/TextInputLayout` (外層), `@style/SingleLine` (內層)
- TextAppearance: `@style/body`
- InputType: `text`
- Constraint: 下方連接 `tv_device_position_title`

---

### B.5 UI 區塊 2：Sink Position（水槽位置）

#### B.5.1 Title
```xml
<TextView
    android:id="@+id/tv_device_position_title"
    style="@style/SingleLine"
    android:layout_width="@dimen/dp_0"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_16"
    android:text="@string/sink_position"
    android:textAppearance="@style/caption1"
    app:layout_constraintBottom_toTopOf="@id/btn_position"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/layout_name" />
```

**事實**：
- ID: `tv_device_position_title`
- 類型: `TextView`
- `layout_width`: `0dp` (constraint 決定寬度)
- `layout_height`: `wrap_content`
- `layout_marginTop`: `16dp`
- Text: `@string/sink_position`
- TextAppearance: `@style/caption1`
- Constraint: 下方連接 `btn_position`

#### B.5.2 Button
```xml
<com.google.android.material.button.MaterialButton
    android:id="@+id/btn_position"
    style="@style/BackgroundMaterialButton"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_4"
    android:textAlignment="textStart"
    app:icon="@drawable/ic_next"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/tv_device_position_title"
    tools:text="dasdasdksa;dksald;sakdl;askdl;dkaslkdl;sakdlsa;kdlas;dk;asldka;slkd" />
```

**事實**：
- ID: `btn_position`
- 類型: `MaterialButton`
- `layout_width`: `0dp` (constraint 決定寬度)
- `layout_height`: `wrap_content`
- `layout_marginTop`: `4dp`
- Style: `@style/BackgroundMaterialButton`
- TextAlignment: `textStart`
- Icon: `@drawable/ic_next` (右側箭頭)
- Constraint: 下方連接 `tv_delay_time_title`

---

### B.6 UI 區塊 3：Delay Time（延遲時間）

#### B.6.1 Title
```xml
<TextView
    android:id="@+id/tv_delay_time_title"
    style="@style/SingleLine"
    android:layout_width="@dimen/dp_0"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_16"
    android:text="@string/delay_time"
    android:textAppearance="@style/caption1"
    app:layout_constraintBottom_toTopOf="@id/btn_delay_time"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/btn_position" />
```

**事實**：
- ID: `tv_delay_time_title`
- 類型: `TextView`
- `layout_width`: `0dp` (constraint 決定寬度)
- `layout_height`: `wrap_content`
- `layout_marginTop`: `16dp`
- Text: `@string/delay_time`
- TextAppearance: `@style/caption1`
- Constraint: 下方連接 `btn_delay_time`

#### B.6.2 Button
```xml
<com.google.android.material.button.MaterialButton
    android:id="@+id/btn_delay_time"
    style="@style/BackgroundMaterialButton"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_4"
    android:textAlignment="textStart"
    app:icon="@drawable/ic_down"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/tv_delay_time_title"
    tools:text="15 秒" />
```

**事實**：
- ID: `btn_delay_time`
- 類型: `MaterialButton`
- `layout_width`: `0dp` (constraint 決定寬度)
- `layout_height`: `wrap_content`
- `layout_marginTop`: `4dp`
- Style: `@style/BackgroundMaterialButton`
- TextAlignment: `textStart`
- Icon: `@drawable/ic_down` (下拉箭頭)
- Constraint: 無下方 constraint（為最後一個元素）

---

### B.7 Progress Overlay

```xml
<include
    android:id="@+id/progress"
    layout="@layout/progress"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:visibility="gone" />
```

**事實**：
- Include: `progress.xml`
- ID: `progress`
- `layout_width`: `match_parent`
- `layout_height`: `match_parent`
- `visibility`: `gone` (預設隱藏)
- Constraint: 無（覆蓋全畫面）

---

## 【C】UI → 行為 → Method 呼叫鏈

### C.1 進入頁面（onCreate）

**流程**：
```
DropSettingActivity.onCreate()
  ↓
Line 42: setView()
  ↓
Line 50: deviceId = getDeviceIdFromIntent()
  ↓
Line 51-53: if (deviceId == -1) → finish()
  ↓
Line 54: viewModel.setNowDeviceId(deviceId)
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 52-77: setNowDeviceId(id: Int)
    ↓
    Line 53: _loadingLiveData.value = true
    ↓
    Line 55: nowDevice = dbGetDeviceById(id)
    ↓
    Line 57-62: BLE Manager 設定
      - BleContainer.getInstance().new(nowDevice.macAddress)
      - bleManager = BleContainer.getInstance().getBleManager(...)
      - bleManager.setListener(this)
    ↓
    Line 63-66: 讀取 delayTime
      - nowDevice.delayTime?.let { selectDelayTime = it; _delayTimeLiveData.value = it }
    ↓
    Line 68-74: 讀取 sinkId
      - sinkId = dbGetDeviceSinkIdByDeviceId(nowDevice.id)
      - if (sinkId != null) → setSelectSinkId(it)
      - else → setSelectSinkId(0)
    ↓
    Line 76: _loadingLiveData.value = false
  ───────────────────────────────────────────────────────────────────
  ↓
Line 66-72: 設定 TextField（edtName）
  - autoTrim(this)
  - doAfterTextChanged { viewModel.setName(it.toString()) }
  - setText(viewModel.getDeviceName())
  ↓
Line 74: btn_delay_time.isEnabled = viewModel.isConnectNowDevice()
```

**事實盤點**：
- 進入頁面觸發 `onCreate()`
- `deviceId` 從 `Intent` 取得（Line 50, 200-202）
- 若 `deviceId == -1` → 直接 `finish()`
- 呼叫 `viewModel.setNowDeviceId(deviceId)`：
  - Loading 開始（`_loadingLiveData = true`）
  - 從 DB 取得 `nowDevice`
  - 初始化 BLE Manager（若不存在則建立）
  - 讀取 `delayTime` 並更新至 LiveData
  - 讀取 `sinkId` 並呼叫 `setSelectSinkId()`
  - Loading 結束（`_loadingLiveData = false`）
- `edtName` 設定：
  - `autoTrim()` (自動去除首尾空格)
  - `doAfterTextChanged` → `viewModel.setName()`
  - 預設值：`viewModel.getDeviceName()`
- `btn_delay_time` 啟用狀態：依 `isConnectNowDevice()` 決定

---

### C.2 點擊 Toolbar Back Button

**流程**：
```
Activity Line 78-80: btnBack.setOnClickListener
  ↓
finish()
```

**事實盤點**：
- 點擊 Back Button → `finish()`（關閉頁面）
- 無任何儲存動作
- 無 BLE 操作

---

### C.3 點擊 Toolbar Right Button（儲存）

**流程**：
```
Activity Line 81-88: btnRight.setOnClickListener
  ↓
Line 82: UserConfig.setDropModified(true)
  ↓
Line 83-87: viewModel.editDevice(
    sinkIsFull = { (R.string.toast_sink_is_full).toast(this) },
    nameIsEmpty = { (R.string.toast_name_is_empty).toast(this) }
  )
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 106-154: editDevice(sinkIsFull: () -> Unit, nameIsEmpty: () -> Unit)
    ↓
    Line 109-112: 檢查 edtName 是否為空
      - if (edtName.isEmpty()) → nameIsEmpty() → return
    ↓
    Line 114: _loadingLiveData.value = true
    ↓
    Line 115-127: 若 sinkId 未變更
      - dbEditDevice(DeviceEdit(...))
      - _editDeviceLiveData.value = true
    ↓
    Line 128-153: 若 sinkId 已變更
      - Line 128-137: 若 selectSinkId == 0（未分配）
        - dbEditDevice(DeviceEdit(..., sinkId = null))
        - _editDeviceLiveData.value = true
      - Line 138-152: 若 selectSinkId != 0（已分配）
        - Line 139: dropInSinkAmount = dbGetDropInSinkBySinkId(selectSinkId).size
        - Line 140-141: if (dropInSinkAmount >= 4) → sinkIsFull() → 不執行
        - Line 142-150: else → dbEditDevice(...) → _editDeviceLiveData.value = true
  ───────────────────────────────────────────────────────────────────
```

**觀察者處理**（Activity Line 145-154）：
```
editDeviceLiveData.observe(this)
  ↓
Line 147-149: when (it == true)
  ↓
  viewModel.setDelayTime()
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 173-180: setDelayTime()
    ↓
    Line 174-175: if (isConnectNowDevice()) → bleSetDelayTime(selectDelayTime)
    ↓
    Line 176-179: else
      - _loadingLiveData.value = false
      - _setDelayTimeLiveData.value = true
  ───────────────────────────────────────────────────────────────────
  ↓
Line 150-152: when (it == false)
  ↓
  (R.string.toast_setting_failed).toast(this)
```

**BLE 設定延遲時間**（ViewModel Line 183-186）：
```
bleSetDelayTime(delayTime: Int)
  ↓
Line 184: _loadingLiveData.value = true
  ↓
Line 185: bleManager.addQueue(CommandManager.getDropSetDelayTimeCommand(delayTime))
```

**事實盤點**：
- 點擊 Right Button → 設定 `UserConfig.setDropModified(true)`
- 呼叫 `viewModel.editDevice()`：
  - 檢查 `edtName` 是否為空 → 若空則顯示 Toast 並中止
  - Loading 開始
  - 檢查 sinkId 是否變更：
    - 未變更：直接更新 DB
    - 已變更且 `selectSinkId == 0`：更新 DB（sinkId = null）
    - 已變更且 `selectSinkId != 0`：
      - 檢查目標 sink 已有多少 DROP 設備
      - 若 >= 4：顯示「水槽已滿」Toast 並中止
      - 若 < 4：更新 DB
  - 更新成功：`_editDeviceLiveData = true`
- Activity 觀察 `editDeviceLiveData`：
  - 若 `true` → 呼叫 `viewModel.setDelayTime()`
  - 若 `false` → 顯示「設定失敗」Toast
- `setDelayTime()`：
  - 若裝置已連線：發送 BLE 指令 `getDropSetDelayTimeCommand(delayTime)`
  - 若裝置未連線：直接顯示成功（不發送 BLE）

---

### C.4 點擊 Sink Position Button

**流程**：
```
Activity Line 89-94: btn_position.setOnClickListener
  ↓
Line 91-92: val intent = Intent(this, SinkPositionActivity::class.java)
            intent.putExtra("sink_id", viewModel.getSelectSinkId())
  ↓
Line 93: sinkPositionLauncher.launch(intent)
  ───────────────────────────────────────────────────────────────────
  ActivityResultLauncher (Line 27-36)
    ↓
    Line 28-35: if (result.resultCode == Activity.RESULT_OK)
      ↓
      Line 31-34: result.data?.let {
        val id = intent.getIntExtra("sink_id", -1)
        viewModel.setSelectSinkId(id)
      }
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 83-86: setSelectSinkId(id: Int)
    ↓
    Line 84: selectSinkId = id
    ↓
    Line 85: _sinkNameLiveData.value = getDeviceSinkName()
      ─────────────────────────────────────────────────────────────
      Line 160-166: getDeviceSinkName(): String?
        ↓
        Line 161-165: if (selectSinkId == 0) → return null
                      else → return dbGetSinkNameById(selectSinkId)
      ─────────────────────────────────────────────────────────────
  ───────────────────────────────────────────────────────────────────
```

**觀察者處理**（Activity Line 138-144）：
```
sinkNameLiveData.observe(this)
  ↓
Line 139-143: name?.let { binding.btnPosition.text = it }
              ?: run { binding.btnPosition.setText(R.string.no) }
```

**事實盤點**：
- 點擊 Sink Position Button → 導航至 `SinkPositionActivity`
- 傳遞當前 `sink_id`（從 `viewModel.getSelectSinkId()` 取得）
- `SinkPositionActivity` 回傳結果：
  - `resultCode == RESULT_OK` → 取得新的 `sink_id`
  - 呼叫 `viewModel.setSelectSinkId(id)`：
    - 更新 `selectSinkId`
    - 更新 `_sinkNameLiveData`（從 DB 取得 sink 名稱）
- Activity 觀察 `sinkNameLiveData`：
  - 若有名稱：顯示名稱
  - 若無名稱（`selectSinkId == 0`）：顯示 `@string/no`

---

### C.5 點擊 Delay Time Button

**流程**：
```
Activity Line 95-124: btn_delay_time.setOnClickListener
  ↓
Line 97-123: showMenu(it, R.menu.delay_time_menu, OnMenuItemClickListener { menu ->
    when (menu.itemId) {
      R.id.action_15_sec → viewModel.setSelectDelayTime(15)
      R.id.action_30_sec → viewModel.setSelectDelayTime(30)
      R.id.action_1_min  → viewModel.setSelectDelayTime(60)
      R.id.action_2_min  → viewModel.setSelectDelayTime(120)
      R.id.action_3_min  → viewModel.setSelectDelayTime(180)
      R.id.action_4_min  → viewModel.setSelectDelayTime(240)
      R.id.action_5_min  → viewModel.setSelectDelayTime(300)
    }
    return false
  })
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 92-95: setSelectDelayTime(delayTime: Int)
    ↓
    Line 93: selectDelayTime = delayTime
    ↓
    Line 94: _delayTimeLiveData.value = delayTime
  ───────────────────────────────────────────────────────────────────
```

**觀察者處理**（Activity Line 158-184）：
```
delayTimeLiveData.observe(this)
  ↓
Line 159-184: 根據 delayTime 值設定顯示文字
  - 15  → getString(R.string._15sec)
  - 30  → getString(R.string._30sec)
  - 60  → getString(R.string._1min)
  - 120 → getString(R.string._2min)
  - 180 → getString(R.string._3min)
  - 240 → getString(R.string._4min)
  - 300 → getString(R.string._5min)
  ↓
Line 183: binding.btnDelayTime.text = timeString
```

**事實盤點**：
- 點擊 Delay Time Button → 顯示 PopupMenu（`delay_time_menu.xml`）
- Menu 選項：7 個選項（15秒、30秒、1分、2分、3分、4分、5分）
- 選擇後 → 呼叫 `viewModel.setSelectDelayTime(delayTime)`：
  - 更新 `selectDelayTime`
  - 更新 `_delayTimeLiveData`
- Activity 觀察 `delayTimeLiveData`：
  - 根據秒數轉換為文字（使用 `@string` 資源）
  - 更新 `btn_delay_time.text`
- **重要**：此階段僅更新 UI，**不發送 BLE 指令**
- BLE 指令僅在「點擊 Toolbar Right Button（儲存）」時才發送

---

### C.6 TextField 文字變更

**流程**：
```
Activity Line 68-70: edtName.doAfterTextChanged
  ↓
viewModel.setName(it.toString())
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 79-81: setName(name: String)
    ↓
    Line 80: edtName = name
  ───────────────────────────────────────────────────────────────────
```

**事實盤點**：
- TextField 文字變更 → 即時呼叫 `viewModel.setName()`
- `setName()` 僅更新 `edtName` 變數，無其他操作
- **不**即時儲存至 DB
- **不**發送 BLE 指令

---

## 【D】BLE 指令與 ACK / RETURN 處理

### D.1 BLE 指令：設定延遲時間

**Command Builder**（推測 Line 404+）：
```kotlin
fun getDropSetDelayTimeCommand(delayTime: Int): ByteArray
```

**發送時機**：
- `ViewModel.bleSetDelayTime(delayTime)` (Line 183-186)
- 觸發條件：
  - 點擊 Toolbar Right Button（儲存）
  - `editDevice()` 成功（`_editDeviceLiveData == true`）
  - `isConnectNowDevice() == true`（裝置已連線）

**BLE 流程**：
```
bleSetDelayTime(delayTime: Int)
  ↓
Line 184: _loadingLiveData.value = true
  ↓
Line 185: bleManager.addQueue(CommandManager.getDropSetDelayTimeCommand(delayTime))
  ↓
（等待 BLE 回應）
```

---

### D.2 BLE ACK / RETURN 處理

**onReadData** (ViewModel Line 235-290)：
```kotlin
override fun onReadData(data: ByteArray, gatt: BluetoothGatt?) {
    CommandManager.parseCommand(data, ..., { dropSetDelayTimeState ->
        when (dropSetDelayTimeState) {
            COMMAND_STATUS.SUCCESS -> {
                setDeviceDelayTime(selectDelayTime)  // Line 258
                _setDelayTimeLiveData.postValue(true)  // Line 259
            }
            else -> {
                _setDelayTimeLiveData.postValue(false)  // Line 262
            }
        }
        _loadingLiveData.postValue(false)  // Line 265
    }, ...)
}
```

**成功流程**（`COMMAND_STATUS.SUCCESS`）：
```
Line 258: setDeviceDelayTime(selectDelayTime)
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 189-197: setDeviceDelayTime(delayTime: Int)
    ↓
    Line 191-196: dbEditDeviceDelayTime(
        DeviceDelayTime(nowDevice.id, delayTime)
    )
  ───────────────────────────────────────────────────────────────────
  ↓
Line 259: _setDelayTimeLiveData.postValue(true)
  ↓
Line 265: _loadingLiveData.postValue(false)
```

**失敗流程**（`else`）：
```
Line 262: _setDelayTimeLiveData.postValue(false)
  ↓
Line 265: _loadingLiveData.postValue(false)
```

**觀察者處理**（Activity Line 185-195）：
```
setDelayTimeLiveData.observe(this)
  ↓
Line 186-190: when (it == true)
  ↓
  (R.string.toast_setting_successful).toast(this)
  finish()
  ↓
Line 191-193: when (it == false)
  ↓
  (R.string.toast_setting_failed).toast(this)
```

**事實盤點**：
- BLE 回應 parser：`CommandManager.parseCommand()`
- 回應類型：`dropSetDelayTimeState`（`COMMAND_STATUS`）
- 成功（`SUCCESS`）：
  - 更新 DB (`dbEditDeviceDelayTime()`)
  - 發送 `_setDelayTimeLiveData = true`
  - Loading 結束
  - Activity 顯示「設定成功」Toast
  - `finish()`（關閉頁面）
- 失敗（`else`）：
  - 發送 `_setDelayTimeLiveData = false`
  - Loading 結束
  - Activity 顯示「設定失敗」Toast
  - **不**關閉頁面

---

### D.3 BLE 斷線處理

**onDisconnected** (ViewModel Line 229-233)：
```kotlin
override fun onDisconnected(force: Boolean, gatt: BluetoothGatt?) {
    Log.d(DEBUG_TAG, "ble_disconnect")
    _disconnectLiveData.postValue(Unit)
}
```

**觀察者處理**（Activity Line 155-157）：
```
disconnectLiveData.observe(this)
  ↓
Line 156: binding.btnDelayTime.isEnabled = false
```

**事實盤點**：
- BLE 斷線 → 發送 `_disconnectLiveData`
- Activity 觀察 → 禁用 `btn_delay_time`
- **不**關閉頁面
- **不**清除已輸入資料

---

## 【E】State Machine 與狀態轉移

### E.1 Loading State

**觸發時機**：
1. `setNowDeviceId()` 開始時（Line 53）
2. `editDevice()` 開始時（Line 114）
3. `bleSetDelayTime()` 開始時（Line 184）

**結束時機**：
1. `setNowDeviceId()` 結束時（Line 76）
2. BLE ACK 收到後（Line 265）
3. `setDelayTime()` 判定裝置未連線時（Line 177）

**LiveData**: `_loadingLiveData`

**UI 反應**（Activity Line 128-137）：
- `true` → `binding.progress.root.visibility = View.VISIBLE`
- `false` → `binding.progress.root.visibility = View.GONE`

---

### E.2 Sink Name State

**觸發時機**：
- `setSelectSinkId()` 時（Line 85）

**LiveData**: `_sinkNameLiveData`

**UI 反應**（Activity Line 138-144）：
- 有名稱 → `binding.btnPosition.text = it`
- 無名稱（`null`）→ `binding.btnPosition.setText(R.string.no)`

---

### E.3 Delay Time State

**觸發時機**：
1. `setNowDeviceId()` 讀取 `nowDevice.delayTime` 時（Line 65）
2. `setSelectDelayTime()` 選擇新延遲時間時（Line 94）

**LiveData**: `_delayTimeLiveData`

**UI 反應**（Activity Line 158-184）：
- 根據秒數轉換為文字（`_15sec`, `_30sec`, `_1min`, ...）
- 更新 `binding.btnDelayTime.text`

---

### E.4 Edit Device State

**觸發時機**：
- `editDevice()` 完成時（Line 126, 137, 150）

**LiveData**: `_editDeviceLiveData`

**值**：
- `true` → DB 更新成功
- `false` → DB 更新失敗（實際上此 ViewModel 無發送 `false` 的邏輯）

**UI 反應**（Activity Line 145-154）：
- `true` → 呼叫 `viewModel.setDelayTime()`
- `false` → 顯示「設定失敗」Toast

---

### E.5 Set Delay Time State

**觸發時機**：
1. BLE ACK 成功時（Line 259）
2. BLE ACK 失敗時（Line 262）
3. 裝置未連線時（Line 178）

**LiveData**: `_setDelayTimeLiveData`

**值**：
- `true` → BLE 設定成功 或 裝置未連線（視為成功）
- `false` → BLE 設定失敗

**UI 反應**（Activity Line 185-195）：
- `true` → 顯示「設定成功」Toast，`finish()`
- `false` → 顯示「設定失敗」Toast

---

### E.6 Disconnect State

**觸發時機**：
- BLE 斷線時（Line 232）

**LiveData**: `_disconnectLiveData`

**UI 反應**（Activity Line 155-157）：
- `binding.btnDelayTime.isEnabled = false`

---

## 【F】完整流程圖（成功案例）

```
使用者進入 DropSettingActivity
  ↓
onCreate()
  ↓
getDeviceIdFromIntent() → deviceId
  ↓
viewModel.setNowDeviceId(deviceId)
  ├─ Loading Start
  ├─ 從 DB 取得 nowDevice
  ├─ 初始化 BLE Manager
  ├─ 讀取 delayTime → 更新 UI
  ├─ 讀取 sinkId → 更新 UI
  └─ Loading End
  ↓
使用者編輯 edtName
  ↓ (即時更新)
viewModel.setName(newName)
  ↓
使用者點擊 btn_position
  ↓
導航至 SinkPositionActivity
  ↓
回傳 sink_id
  ↓
viewModel.setSelectSinkId(id) → 更新 UI
  ↓
使用者點擊 btn_delay_time
  ↓
顯示 PopupMenu (delay_time_menu)
  ↓
使用者選擇延遲時間
  ↓
viewModel.setSelectDelayTime(delayTime) → 更新 UI
  ↓
使用者點擊 Toolbar Right Button（儲存）
  ↓
UserConfig.setDropModified(true)
  ↓
viewModel.editDevice()
  ├─ Loading Start
  ├─ 檢查 edtName 是否為空 → OK
  ├─ 檢查 sink 是否已滿 → OK
  ├─ DB 更新 device (name, sinkId)
  └─ _editDeviceLiveData = true
  ↓
Activity 觀察 editDeviceLiveData == true
  ↓
viewModel.setDelayTime()
  ├─ if (isConnectNowDevice() == true)
  │   ↓
  │   bleSetDelayTime(selectDelayTime)
  │     ├─ Loading Start
  │     └─ bleManager.addQueue(getDropSetDelayTimeCommand(delayTime))
  │         ↓
  │        （等待 BLE ACK）
  │         ↓
  │       onReadData() → parseCommand() → dropSetDelayTimeState
  │         ├─ if (SUCCESS)
  │         │   ├─ setDeviceDelayTime(selectDelayTime) → DB 更新
  │         │   ├─ _setDelayTimeLiveData.postValue(true)
  │         │   └─ _loadingLiveData.postValue(false)
  │         │       ↓
  │         │      Activity 觀察 setDelayTimeLiveData == true
  │         │       ├─ 顯示「設定成功」Toast
  │         │       └─ finish()
  │         └─ else
  │             ├─ _setDelayTimeLiveData.postValue(false)
  │             └─ _loadingLiveData.postValue(false)
  │                 ↓
  │                Activity 觀察 setDelayTimeLiveData == false
  │                 └─ 顯示「設定失敗」Toast
  │
  └─ else (裝置未連線)
      ├─ _loadingLiveData.value = false
      └─ _setDelayTimeLiveData.value = true
          ↓
         Activity 觀察 setDelayTimeLiveData == true
          ├─ 顯示「設定成功」Toast
          └─ finish()
```

---

## 【G】Flutter 對照現況

### G.1 Flutter Page

**檔名**: `drop_setting_page.dart`  
**路徑**: `lib/features/doser/presentation/pages/drop_setting_page.dart`  
**類別**: `DropSettingPage` (StatefulWidget)

---

### G.2 Flutter 與 Android 差異（初步盤點）

#### G.2.1 UI 結構差異

| 項目 | Android | Flutter | 一致性 |
|------|---------|---------|--------|
| Root Layout | ConstraintLayout | Scaffold | ❌ 不同類型 |
| Toolbar Type | toolbar_two_action | ReefAppBar | ⚠️ 待驗證 |
| Main Content Padding | 16/12/16/12dp | 16/16/16/16dp | ❌ 不一致 |
| Device Name Section | ✅ | ✅ | ✅ |
| Sink Position Section | ✅ | ✅ | ✅ |
| Delay Time Section | ✅ | ✅ | ✅ |
| Progress Overlay | ✅ (visibility=gone) | ❌ 無 | ❌ 缺失 |
| Scrollable | ❌ (固定高度) | ❌ (Column) | ✅ |

#### G.2.2 行為差異

| 行為 | Android | Flutter | 一致性 |
|------|---------|---------|--------|
| 進入頁面時讀取 device data | ✅ | ✅ | ✅ |
| TextField 即時更新 | ✅ (doAfterTextChanged) | ✅ (onChanged) | ✅ |
| 點擊 Sink Position → 導航 | ✅ | ✅ | ✅ |
| 點擊 Delay Time → PopupMenu | ✅ | ⚠️ ModalBottomSheet | ❌ 不同 UI |
| 儲存時檢查 name 是否為空 | ✅ | ✅ | ✅ |
| 儲存時檢查 sink 是否已滿 | ✅ | ❌ | ❌ 缺失 |
| 儲存時先更新 DB 再發 BLE | ✅ | ⚠️ 待確認 | ⚠️ |
| BLE 連線狀態影響 btn 啟用 | ✅ (btn_delay_time) | ✅ (所有 btn) | ⚠️ 範圍不同 |
| BLE 斷線時禁用 delay time btn | ✅ | ⚠️ 待確認 | ⚠️ |
| BLE ACK 成功後更新 DB | ✅ | ❌ TODO | ❌ 未實作 |
| BLE ACK 成功後 finish | ✅ | ✅ (pop) | ✅ |
| 儲存成功顯示 Toast | ✅ | ✅ (SnackBar) | ✅ |

#### G.2.3 BLE 流程差異

| 項目 | Android | Flutter | 一致性 |
|------|---------|---------|--------|
| BLE 指令：設定延遲時間 | `getDropSetDelayTimeCommand()` | ❌ TODO (Line 151-158) | ❌ 未實作 |
| BLE ACK 解析 | `dropSetDelayTimeState` | ❌ | ❌ 未實作 |
| ACK SUCCESS → DB 更新 | ✅ | ❌ | ❌ 未實作 |
| ACK FAIL → Toast | ✅ | ❌ | ❌ 未實作 |
| 裝置未連線 → 直接成功 | ✅ | ⚠️ 待確認 | ⚠️ |

---

## 【H】Android 字串資源盤點

### H.1 Activity 內使用的字串

| Android String Key | 用途 | 使用位置 |
|-------------------|------|---------|
| `activity_drop_setting_title` | Toolbar 標題 | Line 59 |
| `activity_drop_setting_toolbar_right_btn` | Toolbar 右鈕文字 | Line 61 |
| `device_name` | 設備名稱標題 | XML Line 34 |
| `sink_position` | 水槽位置標題 | XML Line 67 |
| `delay_time` | 延遲時間標題 | XML Line 93 |
| `no` | 未分配水槽時顯示 | Line 142 |
| `_15sec` | 15秒 | Line 162 |
| `_30sec` | 30秒 | Line 165 |
| `_1min` | 1分鐘 | Line 168 |
| `_2min` | 2分鐘 | Line 171 |
| `_3min` | 3分鐘 | Line 174 |
| `_4min` | 4分鐘 | Line 177 |
| `_5min` | 5分鐘 | Line 180 |
| `toast_sink_is_full` | Toast: 水槽已滿 | Line 84 |
| `toast_name_is_empty` | Toast: 名稱為空 | Line 86 |
| `toast_setting_successful` | Toast: 設定成功 | Line 188 |
| `toast_setting_failed` | Toast: 設定失敗 | Line 151, 192 |

---

## 【I】Delay Time Menu 盤點

**待讀取**: `android/ReefB_Android/app/src/main/res/menu/delay_time_menu.xml`

**用途**：PopupMenu 選單，提供 7 個延遲時間選項

**選項**（從 Activity Line 98-120 推斷）：
1. `action_15_sec` → 15秒
2. `action_30_sec` → 30秒
3. `action_1_min` → 60秒
4. `action_2_min` → 120秒
5. `action_3_min` → 180秒
6. `action_4_min` → 240秒
7. `action_5_min` → 300秒

---

## 【J】重要待確認事項

1. ❌ `delay_time_menu.xml` 內容尚未讀取
2. ❌ `CommandManager.getDropSetDelayTimeCommand()` 實際實作尚未讀取
3. ❌ BLE ACK 回應格式尚未確認
4. ❌ Flutter BLE 設定延遲時間流程尚未實作（TODO Line 151-158）
5. ⚠️ Flutter 是否有檢查 sink 已滿邏輯（4 個 DROP 上限）
6. ⚠️ Flutter 儲存流程順序是否與 Android 一致（先 DB 後 BLE）

---

## 【K】稽核結論

### K.1 Android 事實已完整盤點

✅ **已盤點項目**：
- Activity 檔案與 XML Layout
- ViewModel 與所有 method
- BLE 指令發送流程
- BLE ACK 解析流程
- 所有 UI 事件與對應 method
- 所有 LiveData 與觀察者
- Loading / Disconnect / EditDevice / SetDelayTime State
- 完整流程圖（成功案例）
- 字串資源清單

⚠️ **待補充項目**：
- `delay_time_menu.xml` 內容
- `CommandManager.getDropSetDelayTimeCommand()` 實作細節
- BLE ACK 回應 payload 格式

---

### K.2 Flutter 差異已標註

✅ **已標註**：
- UI 結構差異（Padding、Progress Overlay）
- 行為差異（Sink 已滿檢查、BLE 流程）
- BLE 未實作項目（TODO）

❌ **禁止項目**：
- 不提出 Flutter 修正方案
- 不撰寫 Flutter code
- 不重構、不優化

---

**報告完成日期**：2026-01-03  
**稽核狀態**：✅ **已完成**（Android 事實盤點）  
**Flutter Parity 狀態**：⚠️ **待人工判定路徑 A / B**

