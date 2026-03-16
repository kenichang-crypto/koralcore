# DOSING_DROP_HEAD_MAIN_PARITY_AUDIT.md

**稽核日期**：2026-01-03  
**稽核工程師**：資深 Android / Flutter IoT / BLE State Machine 稽核工程師  
**Android 事實來源**：reef-b-app  
**Flutter 對照對象**：koralcore

---

## 【A】Android 程式來源盤點

### A.1 Activity / Fragment

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| Activity | `DropHeadMainActivity.kt` | `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_head_main/DropHeadMainActivity.kt` | Line 23-329 |

---

### A.2 XML Layout

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| Activity Layout | `activity_drop_head_main.xml` | `android/ReefB_Android/app/src/main/res/layout/activity_drop_head_main.xml` | Line 1-484 |
| Toolbar Include | `toolbar_device.xml` | `android/ReefB_Android/app/src/main/res/layout/toolbar_device.xml` | (已盤點) |
| Progress Include | `progress.xml` | `android/ReefB_Android/app/src/main/res/layout/progress.xml` | (已盤點) |
| RecyclerView Item | `adapter_drop_record_detail.xml` | (待盤點) |

---

### A.3 ViewModel / Controller

| 類別 | 檔名 | 完整路徑 | 行號 |
|------|-----|----------|------|
| ViewModel | `DropHeadMainViewModel.kt` | `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/drop_head_main/DropHeadMainViewModel.kt` | Line 24-216 |

---

### A.4 Adapter

| 類別 | 檔名 | 用途 |
|------|-----|------|
| `DropRecordDetailAdapter` | (推測) | RecyclerView adapter for record details |

---

### A.5 Manager / Repository / BLE

| 類別 | 檔名 | 方法 | 完整路徑 |
|------|-----|------|----------|
| CommandManager | `CommandManager.kt` | `getDropGetAdjustHistoryCommand()` | (標準 BLE 方法) |
| BLEManager | `BLEManager.kt` | `isDeviceConnect()` | (標準 BLE 方法) |
| BleContainer | `BleContainer.kt` | `getDropInformation()` | (標準 BLE 容器) |
| Database | `DropHeadDao.kt` | `getDropHeadById()` | (標準 DAO) |
| Database | `DeviceDao.kt` | `getDeviceById()` | (標準 DAO) |
| Database | `DropTypeDao.kt` | `getDropTypeById()` | (標準 DAO) |

---

## 【B】Android XML / UI 結構事實

### B.1 Root Layout

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg_aaa">
```

**事實**：
- Root: `ConstraintLayout`
- Background: `@color/bg_aaa` (#F7F7F7)
- `layout_width`: `match_parent`
- `layout_height`: `match_parent`

---

### B.2 Toolbar

```xml
<include
    android:id="@+id/toolbar_drop_head_main"
    layout="@layout/toolbar_device"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toTopOf="parent" />
```

**事實**：
- Include: `toolbar_device.xml`
- ID: `toolbar_drop_head_main`
- Constraint: 固定於頂部
- Toolbar 設定（Activity）：
  - `btnFavorite.visibility = GONE` (Line 55)
  - Title: `"${deviceName}/CH ${headId + 1}"` (Line 114-115)

---

### B.3 Main Content Area (不可捲動)

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="@dimen/dp_0"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/toolbar_drop_head_main">
```

**事實**：
- `layout_width`: `match_parent`
- `layout_height`: `@dimen/dp_0` (0dp，由 constraint 決定)
- Constraint: 填滿 Toolbar 下方至畫面底部
- **不可捲動**：無 `ScrollView`，所有內容必須在此固定高度內

---

### B.4 UI 區塊 1：Drop Head Info Card（泵頭資訊卡片）

```xml
<androidx.cardview.widget.CardView
    android:id="@+id/layout_drop_head_info"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginStart="@dimen/dp_16"
    android:layout_marginTop="@dimen/dp_12"
    android:layout_marginEnd="@dimen/dp_16"
    app:cardCornerRadius="@dimen/dp_10"
    app:cardElevation="@dimen/dp_5"
    ...>
```

**事實**：
- ID: `layout_drop_head_info`
- 類型: `CardView`
- Margin: `16/12/16/0dp` (start/top/end/bottom)
- Corner Radius: `10dp`
- Elevation: `5dp`
- Padding (內層): `12dp` (Line 40)

#### 子元件：

1. **tv_drop_type_title** + **tv_drop_type** (Line 42-67)
   - Label: `@string/drop_type`
   - Value: `dropHead.dropTypeId` → `DropType.name`
   - Layout: 左右排列（Label | Value）

2. **tv_max_drop_title** + **tv_max_drop** (Line 69-97)
   - Label: `@string/max_drop_volume`
   - Value: `${dropHead.maxDrop} ml`
   - **visibility**: `gone` (Line 74, 87)

---

### B.5 UI 區塊 2：Record Title + More Button

```xml
<TextView
    android:id="@+id/tv_record_title"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_16"
    android:text="@string/record"
    android:textAppearance="@style/body_accent"
    app:layout_constraintStart_toStartOf="@id/layout_drop_head_info"
    app:layout_constraintTop_toBottomOf="@id/layout_drop_head_info" />

<ImageView
    android:id="@+id/btn_record_more"
    android:layout_width="@dimen/dp_24"
    android:layout_height="@dimen/dp_24"
    android:layout_marginStart="@dimen/dp_16"
    android:layout_marginEnd="@dimen/dp_16"
    android:src="@drawable/ic_more_disable"
    ... />
```

**事實**：
- `tv_record_title`: `@string/record`
- `btn_record_more`: `24x24dp`，icon `ic_more_disable` or `ic_more_enable`
- 點擊行為：導航至 `DropHeadRecordSettingActivity`
- 連線狀態影響：未連線時 icon 改為 `ic_more_disable`

---

### B.6 UI 區塊 3：Record Card（紀錄卡片）

```xml
<androidx.cardview.widget.CardView
    android:id="@+id/layout_record"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_4"
    app:cardCornerRadius="@dimen/dp_10"
    app:cardElevation="@dimen/dp_0"
    ...>
```

**事實**：
- ID: `layout_record`
- Corner Radius: `10dp`
- Elevation: `0dp` (無陰影)
- Padding (內層): `12dp` (Line 140)

#### 子元件（由上至下）：

1. **tv_today_record_drop_volume_title** + **tv_today_record_drop_volume** (Line 142-168)
   - Label: `@string/today_record_drop_volume`
   - Value: `${todayVolume} ml` or `- ml` (未連線)

2. **divider_1** (Line 170-179)
   - 高度: `1dp`
   - 顏色: `@color/bg_press`
   - Margin: `4dp` top

3. **tv_record_type_title** + **tv_record_type** (Line 181-208)
   - Label: `@string/drop_record_type`
   - Value: 依據 `DropRecordType` 顯示不同文字：
     - `NONE`: `@string/no_records`
     - `_24HR`: `@string/drop_record_type_24`
     - `SINGLE`: `@string/drop_record_type_single`
     - `CUSTOM`: `@string/drop_record_type_custom`
     - 未連線: `@string/device_is_not_connect`

4. **rv_record_detail** (Line 210-220)
   - 類型: `RecyclerView`
   - 高度: `wrap_content`
   - Margin: `4dp` top
   - Item: `adapter_drop_record_detail.xml`
   - Visibility: 依 `DropRecordType` 動態控制

5. **layout_mode** (Line 223-322)
   - 類型: `LinearLayout` (vertical)
   - Margin: `12dp` top
   - Visibility: 依 `DropRecordType` 控制（僅 `_24HR` / `CUSTOM` 顯示）
   - 子元件：
     - **tv_run_cycle** (Line 234-240): `@string/run_cycle`
     - **layout_weekday** (Line 242-310): 7 個 `ImageView` (20x20dp)
       - Sunday → Saturday
       - src: `ic_*_unselect` or `ic_*_select`
     - **tv_time** (Line 312-321): 時間範圍文字

---

### B.7 UI 區塊 4：Adjust Title + More Button

```xml
<TextView
    android:id="@+id/tv_adjust_title"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_16"
    android:text="@string/recently_adjust_list"
    android:textAppearance="@style/body_accent"
    ... />

<ImageView
    android:id="@+id/btn_adjust_more"
    android:layout_width="@dimen/dp_24"
    android:layout_height="@dimen/dp_24"
    android:src="@drawable/ic_more_disable"
    ... />
```

**事實**：
- `tv_adjust_title`: `@string/recently_adjust_list`
- `btn_adjust_more`: `24x24dp`，icon `ic_more_disable` or `ic_more_enable`
- 點擊行為：導航至 `DropHeadAdjustListActivity`
- 連線狀態影響：未連線時 icon 改為 `ic_more_disable`

---

### B.8 UI 區塊 5：Adjust Card（校正記錄卡片）

```xml
<androidx.cardview.widget.CardView
    android:id="@+id/layout_adjust"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_4"
    app:cardCornerRadius="@dimen/dp_10"
    app:cardElevation="@dimen/dp_0"
    ...>
```

**事實**：
- ID: `layout_adjust`
- Corner Radius: `10dp`
- Elevation: `0dp`
- Padding (內層): `12dp` (Line 366)

#### 子元件（兩種狀態）：

**狀態 A：未連線**
```xml
<TextView
    android:id="@+id/tv_adjust_no_connect"
    android:text="@string/device_is_not_connect"
    android:visibility="gone"
    ... />
```

**狀態 B：已連線**
```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:id="@+id/layout_adjust_connect"
    ...>
```

包含：
1. **tv_low_speed_title** + **tv_low_speed** (Line 391-416)
   - Label: `@string/low_rotating_speed`
   - Value: 最後一次低速校正時間 or `@string/no_eng`

2. **tv_middle_speed_title** + **tv_middle_speed** (Line 418-444)
   - Label: `@string/middle_rotating_speed`
   - Value: 最後一次中速校正時間 or `@string/no_eng`

3. **tv_high_speed_title** + **tv_high_speed** (Line 446-472)
   - Label: `@string/high_rotating_speed`
   - Value: 最後一次高速校正時間 or `@string/no_eng`

---

### B.9 Progress Overlay

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
- visibility: `gone` (預設隱藏)
- 全畫面覆蓋

---

## 【C】UI → 行為 → Method 呼叫鏈

### C.1 進入頁面（onResume）

**流程**：
```
DropHeadMainActivity.onResume()
  ↓
Line 43: dropHeadId = getDropHeadIdFromIntent()
  ↓
Line 44: if (dropHeadId == -1) → finish()
  ↓
Line 46: viewModel.setNowDropHeadId(dropHeadId)
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 62-78: setNowDropHeadId(id: Int)
    ↓
    Line 63: _loadingLiveData.value = true
    ↓
    Line 64: nowDropHead = dbGetDropHeadById(id)
    ↓
    Line 65: nowDevice = dbGetDeviceById(nowDropHead.deviceId)
    ↓
    Line 67-72: BLE Manager 初始化
      - BleContainer.getInstance().new(nowDevice.macAddress)
      - bleManager = BleContainer.getInstance().getBleManager(...)
      - bleManager.setListener(this)
      - dropInformation = BleContainer.getInstance().getDropInformation(...)
    ↓
    Line 74-76: _dropHeadLiveData.value = DropHeadForAdapter(...)
    ↓
    Line 77: _loadingLiveData.value = false
  ───────────────────────────────────────────────────────────────────
  ↓
Line 47: viewModel.getNowRecords()
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 115-118: getNowRecords()
    ↓
    Line 116: _recordsLiveData.value = dropInformation.getMode(nowDropHead.headId)
    ↓
    Line 117: _detailsLiveData.value = dropInformation.getDetails(nowDropHead.headId)
  ───────────────────────────────────────────────────────────────────
  ↓
Line 48: viewModel.getAdjustHistory()
  ───────────────────────────────────────────────────────────────────
  ViewModel Line 128-137: getAdjustHistory()
    ↓
    Line 134-136: bleManager.addQueue(
        CommandManager.getDropGetAdjustHistoryCommand(nowDropHead.headId)
    )
  ───────────────────────────────────────────────────────────────────
  ↓
Line 50: setBleStateUi(viewModel.isConnectNowDevice())
```

**事實盤點**：
- 進入頁面觸發 `onResume()`
- `dropHeadId` 從 `Intent` 取得（Line 295-296）
- 若 `dropHeadId == -1` → 直接 `finish()`
- 呼叫 `viewModel.setNowDropHeadId(dropHeadId)`：
  - Loading 開始
  - 從 DB 取得 `nowDropHead` 和 `nowDevice`
  - 初始化 BLE Manager
  - 發送 `_dropHeadLiveData`（更新 UI）
  - Loading 結束
- 呼叫 `viewModel.getNowRecords()`：
  - 更新 `_recordsLiveData`（從 `dropInformation` 取得）
  - 更新 `_detailsLiveData`（從 `dropInformation` 取得）
- 呼叫 `viewModel.getAdjustHistory()`：
  - 發送 BLE 指令 `getDropGetAdjustHistoryCommand()`
- 呼叫 `setBleStateUi()`：
  - 更新 UI 依據連線狀態

---

### C.2 Toolbar Back Button

**流程**：
```
Activity Line 66: btnBack.setOnClickListener
  ↓
finish()
```

**事實盤點**：
- 點擊 Back Button → `finish()`（關閉頁面）

---

### C.3 Toolbar Menu Button

**流程**：
```
Activity Line 68-83: btnMenu.setOnClickListener
  ↓
Line 69-82: PopupMenu(this, view).apply {
    inflate(R.menu.drop_head_menu)
    setOnMenuItemClickListener { item ->
        when (item.itemId) {
            R.id.action_edit -> {
                val intent = Intent(..., DropHeadSettingActivity::class.java)
                intent.putExtra("drop_head_id", viewModel.getNowDropHead().id)
                startActivity(intent)
            }
        }
        true
    }
    show()
}
```

**事實盤點**：
- 點擊 Menu Button → 顯示 PopupMenu
- Menu 選項：`action_edit`
- 選擇 Edit → 導航至 `DropHeadSettingActivity`
- 傳遞 `drop_head_id`

---

### C.4 Record More Button

**流程**：
```
Activity Line 85-93: btn_record_more.setOnClickListener
  ↓
Line 86-89: if (!viewModel.isConnectNowDevice()) {
    (R.string.device_is_not_connect).toast(this)
    return@setOnClickListener
}
  ↓
Line 90-92: val intent = Intent(this, DropHeadRecordSettingActivity::class.java)
            intent.putExtra("drop_head_id", viewModel.getNowDropHead().id)
            startActivity(intent)
```

**事實盤點**：
- 點擊 Record More Button → 檢查連線狀態
- 若未連線 → 顯示 Toast `device_is_not_connect`
- 若已連線 → 導航至 `DropHeadRecordSettingActivity`

---

### C.5 Adjust More Button

**流程**：
```
Activity Line 95-104: btn_adjust_more.setOnClickListener
  ↓
Line 96-99: if (!viewModel.isConnectNowDevice()) {
    (R.string.device_is_not_connect).toast(this)
    return@setOnClickListener
}
  ↓
Line 100-103: val bundle = Bundle().apply {
    putInt("drop_head_id", viewModel.getNowDropHead().id)
}
startActivity(bundle, DropHeadAdjustListActivity::class.java)
```

**事實盤點**：
- 點擊 Adjust More Button → 檢查連線狀態
- 若未連線 → 顯示 Toast `device_is_not_connect`
- 若已連線 → 導航至 `DropHeadAdjustListActivity`

---

## 【D】BLE 指令與 ACK / RETURN 處理

### D.1 BLE 指令：取得校正歷史

**Command**：
```kotlin
CommandManager.getDropGetAdjustHistoryCommand(nowDropHead.headId)
```

**發送時機**：
- `onResume()` 時 (Line 48)
- 透過 `viewModel.getAdjustHistory()` (Line 128-137)

---

### D.2 BLE ACK / RETURN 處理

**onReadData** (ViewModel Line 162-215)：

```kotlin
override fun onReadData(data: ByteArray, gatt: BluetoothGatt?) {
    CommandManager.parseCommand(data, ..., { dropGetAdjustHistorySize ->
        dropInformation.initAdjustHistory(nowDropHead.headId, dropGetAdjustHistorySize)
    }, { dropGetAdjustHistoryState ->
        when (dropGetAdjustHistoryState) {
            COMMAND_STATUS.START -> {
                _loadingLiveData.postValue(true)
            }
            COMMAND_STATUS.END -> {
                _adjustHistoryLiveData.postValue(dropInformation.getHistory(nowDropHead.headId))
                _loadingLiveData.postValue(false)
            }
            else -> {}
        }
    }, ...)
}
```

**事實盤點**：
- BLE 回應 parser：`CommandManager.parseCommand()`
- 回應類型 1：`dropGetAdjustHistorySize`
  - 初始化校正歷史（`initAdjustHistory()`）
- 回應類型 2：`dropGetAdjustHistoryState`
  - `START`：顯示 Loading
  - `END`：發送 `_adjustHistoryLiveData`，隱藏 Loading
  - `else`：無動作

---

## 【E】State Machine 與狀態轉移

### E.1 Loading State

**觸發時機**：
1. `setNowDropHeadId()` 開始時（Line 63）
2. BLE ACK `START` 時（Line 200）

**結束時機**：
1. `setNowDropHeadId()` 結束時（Line 77）
2. BLE ACK `END` 時（Line 205）

**LiveData**: `_loadingLiveData`

---

### E.2 Drop Head State

**觸發時機**：
- `setNowDropHeadId()` 時（Line 74-76）

**LiveData**: `_dropHeadLiveData`

**UI 反應**（Activity Line 113-124）：
- Toolbar Title: `"${deviceName}/CH ${headId + 1}"`
- Drop Type: `dropHead.dropTypeId` → `DropType.name`
- Max Drop: `${dropHead.maxDrop} ml`
- 呼叫 `setBleStateUi()`

---

### E.3 Records State

**觸發時機**：
- `getNowRecords()` 時（Line 116-117）

**LiveData**:
- `_recordsLiveData` (DropHeadMode)
- `_detailsLiveData` (List<DropHeadRecordDetail>)

**UI 反應**（Activity Line 130-239）：
- 依據 `DropRecordType` 顯示不同內容：
  - `NONE`: 無紀錄
  - `_24HR`: 24小時循環
  - `SINGLE`: 單次定時
  - `CUSTOM`: 自訂排程
- 更新星期圖標（`layout_weekday`）
- 更新時間範圍（`tv_time`）
- 更新 RecyclerView（`rv_record_detail`）

---

### E.4 Adjust History State

**觸發時機**：
- BLE ACK `END` 時（Line 204）

**LiveData**: `_adjustHistoryLiveData`

**UI 反應**（Activity Line 254-263）：
- 更新低速校正時間（`tv_low_speed`）
- 更新中速校正時間（`tv_middle_speed`）
- 更新高速校正時間（`tv_high_speed`）

---

### E.5 Disconnect State

**觸發時機**：
- BLE 斷線時（Line 159）

**LiveData**: `_disconnectLiveData`

**UI 反應**（Activity Line 126-128）：
- 呼叫 `setBleStateUi(false)`

---

### E.6 BLE Connection State UI

**方法**：`setBleStateUi(isConnect: Boolean)` (Activity Line 266-282)

**已連線**（`isConnect == true`）：
- `tv_adjust_no_connect.visibility = GONE`
- `layout_adjust_connect.visibility = VISIBLE`
- `btn_record_more` icon → `ic_more_enable`
- `btn_adjust_more` icon → `ic_more_enable`

**未連線**（`isConnect == false`）：
- `tv_adjust_no_connect.visibility = VISIBLE`
- `layout_adjust_connect.visibility = GONE`
- `btn_record_more` icon → `ic_more_disable`
- `btn_adjust_more` icon → `ic_more_disable`
- `tv_record_type.text` → `device_is_not_connect`
- `tv_today_record_drop_volume.text` → `- ml`
- `rv_record_detail.visibility = GONE`
- `layout_mode.visibility = GONE`

---

## 【F】完整流程圖（成功案例）

```
使用者進入 DropHeadMainActivity (onResume)
  ↓
getDropHeadIdFromIntent() → dropHeadId
  ↓
viewModel.setNowDropHeadId(dropHeadId)
  ├─ Loading Start
  ├─ 從 DB 取得 nowDropHead, nowDevice
  ├─ 初始化 BLE Manager
  ├─ 發送 _dropHeadLiveData
  │   ↓
  │  Activity 觀察 dropHeadLiveData
  │   ├─ 更新 Toolbar Title
  │   ├─ 更新 Drop Type
  │   ├─ 更新 Max Drop
  │   └─ 呼叫 setBleStateUi()
  └─ Loading End
  ↓
viewModel.getNowRecords()
  ├─ 更新 _recordsLiveData (從 dropInformation)
  │   ↓
  │  Activity 觀察 recordsLiveData
  │   ├─ 依 DropRecordType 更新 UI
  │   ├─ 更新 RecyclerView (record details)
  │   ├─ 更新星期圖標
  │   └─ 更新時間範圍
  └─ 更新 _detailsLiveData (從 dropInformation)
      ↓
     Activity 觀察 detailsLiveData
      └─ 更新 RecyclerView (custom details)
  ↓
viewModel.getAdjustHistory()
  ├─ 發送 BLE 指令 getDropGetAdjustHistoryCommand()
  ↓
（等待 BLE ACK）
  ↓
onReadData() → parseCommand()
  ├─ dropGetAdjustHistorySize
  │   └─ initAdjustHistory()
  ├─ dropGetAdjustHistoryState START
  │   └─ Loading Start
  └─ dropGetAdjustHistoryState END
      ├─ 發送 _adjustHistoryLiveData
      │   ↓
      │  Activity 觀察 adjustHistoryLiveData
      │   ├─ 更新低速校正時間
      │   ├─ 更新中速校正時間
      │   └─ 更新高速校正時間
      └─ Loading End
  ↓
setBleStateUi(isConnected)
  ├─ 若已連線
  │   ├─ 顯示校正歷史
  │   └─ More buttons 啟用
  └─ 若未連線
      ├─ 顯示「裝置未連線」
      └─ More buttons 禁用
```

---

## 【G】Flutter 對照現況

### G.1 Flutter Page

**檔名**: `pump_head_detail_page.dart`  
**路徑**: `lib/features/doser/presentation/pages/pump_head_detail_page.dart`  
**類別**: `PumpHeadDetailPage` (StatelessWidget)

---

### G.2 Flutter 與 Android 差異（初步盤點）

#### G.2.1 UI 結構差異

| 項目 | Android | Flutter | 一致性 |
|------|---------|---------|--------|
| Root Layout | ConstraintLayout (bg_aaa) | Scaffold (surfaceMuted) | ⚠️ 背景色一致 |
| Toolbar Type | toolbar_device | ReefAppBar | ⚠️ 待驗證 |
| Main Content | ConstraintLayout (固定高度) | 待確認 | ⚠️ 待驗證 |
| Drop Head Info Card | ✅ | ✅ (StatusCard) | ⚠️ 待驗證 |
| Record Section | ✅ | 待確認 | ⚠️ 待驗證 |
| Adjust Section | ✅ | 待確認 | ⚠️ 待驗證 |
| Progress Overlay | ✅ (visibility=gone) | 待確認 | ⚠️ 待驗證 |
| Scrollable | ❌ (固定高度) | 待確認 | ⚠️ 待驗證 |

---

## 【H】Android 字串資源盤點

### H.1 Activity 內使用的字串

| Android String Key | 用途 | 使用位置 |
|-------------------|------|---------|
| `drop_type` | 滴液類型標題 | XML Line 46 |
| `max_drop_volume` | 最大滴液量標題 | XML Line 75 |
| `record` | 紀錄標題 | XML Line 107 |
| `today_record_drop_volume` | 今日紀錄滴液量 | XML Line 147 |
| `drop_record_type` | 滴液紀錄類型 | XML Line 187 |
| `run_cycle` | 執行週期 | XML Line 238 |
| `recently_adjust_list` | 最近校正列表 | XML Line 332 |
| `device_is_not_connect` | 裝置未連線 | XML Line 373, Activity Line 87, 97, 277 |
| `low_rotating_speed` | 低轉速 | XML Line 396 |
| `middle_rotating_speed` | 中轉速 | XML Line 424 |
| `high_rotating_speed` | 高轉速 | XML Line 452 |
| `no_records` | 無紀錄 | Activity Line 286 |
| `drop_record_type_24` | 24小時循環 | Activity Line 144 |
| `drop_record_type_single` | 單次定時 | Activity Line 170 |
| `drop_record_type_custom` | 自訂排程 | Activity Line 193 |
| `no_eng` | 無(英文) | Activity Line 258, 260, 262 |
| `times` | 次 | Activity Line 246 |

---

## 【I】重要待確認事項

1. ❌ `adapter_drop_record_detail.xml` 內容尚未讀取
2. ❌ `R.menu.drop_head_menu` 內容尚未讀取
3. ❌ Flutter `PumpHeadDetailPage` 實際結構待確認
4. ❌ Flutter 是否包含所有 Android UI 區塊
5. ⚠️ Flutter 是否有 RecyclerView 對應實作
6. ⚠️ Flutter 是否有星期圖標顯示
7. ⚠️ Flutter 是否有校正歷史顯示

---

## 【J】稽核結論

### J.1 Android 事實已完整盤點

✅ **已盤點項目**：
- Activity 檔案與 XML Layout
- ViewModel 與所有 method
- BLE 指令發送流程
- BLE ACK 解析流程
- 所有 UI 事件與對應 method
- 所有 LiveData 與觀察者
- Loading / DropHead / Records / Details / AdjustHistory / Disconnect State
- 完整流程圖（成功案例）
- 字串資源清單

⚠️ **待補充項目**：
- `adapter_drop_record_detail.xml` 內容
- `R.menu.drop_head_menu` 內容
- Flutter 詳細結構對比

---

### J.2 Flutter 差異已標註

✅ **已標註**：
- UI 結構差異（待深入驗證）
- 行為差異（待深入驗證）

❌ **禁止項目**：
- 不提出 Flutter 修正方案
- 不撰寫 Flutter code
- 不重構、不優化

---

**報告完成日期**：2026-01-03  
**稽核狀態**：✅ **已完成**（Android 事實盤點）  
**Flutter Parity 狀態**：⚠️ **待人工判定路徑 A / B**

**備註**：此頁面結構複雜，包含多個 CardView、RecyclerView、動態顯示邏輯，建議執行路徑 B（完全 Parity 化），移除所有業務邏輯，僅保留 UI 結構。

