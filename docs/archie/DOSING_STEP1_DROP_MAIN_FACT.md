# Dosing 模組 STEP 1：對照分析報告

**審核目標**：DropMainActivity（Dosing 主頁）  
**審核日期**：2026-01-03  
**事實來源**：Android reef-b-app（唯一參考）  
**審核模式**：事實盤點（不寫 UI、不重構、不評論）

---

## 任務 1｜Android 來源盤點

### 1.1 Android Activity / Fragment

| 項目 | 值 |
|-----|-----|
| **Activity 名稱** | `DropMainActivity` |
| **Activity 路徑** | `tw.com.crownelectronics.reefb.ui.activity.drop_main.DropMainActivity.kt` |
| **Layout XML 名稱** | `activity_drop_main.xml` |
| **Layout XML 路徑** | `android/ReefB_Android/app/src/main/res/layout/activity_drop_main.xml` |

**事實來源**：
- `docs/WIDGET_AND_PAGE_MAPPING.md` Line 76
- `docs/reef_b_app_res/layout/activity_drop_main.xml` Line 1-107

---

## 任務 2｜Android XML 結構盤點

### 2.1 Root Layout 結構

```
ConstraintLayout (根容器, background=@color/bg_aaa)
├── Toolbar (include @layout/toolbar_device)
├── ScrollView (id=layout_drop_main, 可捲動)
│   └── ConstraintLayout (內容容器)
│       ├── ConstraintLayout (id=layout_device, 設備識別區, 固定)
│       └── RecyclerView (id=rv_drop_head, 泵頭列表, 動態)
└── Progress Overlay (include @layout/progress, visibility=gone)
```

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 2-107

---

### 2.2 Toolbar 區塊（固定）

| 屬性 | 值 |
|-----|-----|
| **類型** | `include @layout/toolbar_device` |
| **ID** | `toolbar_drop_main` |
| **位置** | 固定於頂部 |
| **Constraint** | `Top → parent.top`, `Bottom → layout_drop_main.top` |

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 9-15

**toolbar_device 內容**（推測，需確認實際 XML）：
- 返回按鈕（左側）
- 標題文字（中間）
- BLE 狀態圖標、設定圖標（右側）
- MaterialDivider（底部 2dp）

---

### 2.3 ScrollView（全頁可捲動）

| 屬性 | 值 |
|-----|-----|
| **ID** | `layout_drop_main` |
| **寬度** | `match_parent` |
| **高度** | `0dp`（constraint 至 parent.bottom） |
| **可捲動** | ✅ 是（ScrollView） |
| **Constraint** | `Top → toolbar.bottom`, `Bottom → parent.bottom` |

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 17-24

**重要發現**：
- ✅ Android 使用 **ScrollView 包住整頁內容**
- ✅ 非 "一頁一畫面不可捲動" 規則，此頁為例外（與 LED Record Time Setting Page 類似）

---

### 2.4 設備識別區（固定，不隨 RecyclerView 捲動）

#### 2.4.1 結構

```
ConstraintLayout (id=layout_device, background=@color/bg_aaaa)
├── TextView (id=tv_name, 設備名稱)
├── ImageView (id=btn_ble, BLE 狀態圖標)
└── TextView (id=tv_position, 位置名稱)
```

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 30-82

#### 2.4.2 詳細屬性

| 元件 | ID | 屬性 | 值 |
|-----|----|----|-----|
| **Container** | `layout_device` | width | `match_parent` |
| | | height | `wrap_content` |
| | | background | `@color/bg_aaaa` |
| | | paddingStart | `16dp` |
| | | paddingTop | `8dp` |
| | | paddingEnd | `4dp` |
| | | paddingBottom | `12dp` |
| | | Constraint | `Top → parent.top`, `Bottom → rv_drop_head.top` |
| **設備名稱** | `tv_name` | width | `0dp` (constraint 至 btn_ble.start) |
| | | height | `wrap_content` |
| | | style | `@style/SingleLine` |
| | | textAppearance | `@style/body_accent` |
| | | textColor | `@color/text_aaaa` |
| | | Constraint | `Top → parent.top`, `Bottom → tv_position.top`, `Start → parent.start`, `End → btn_ble.start` |
| **BLE 按鈕** | `btn_ble` | width | `48dp` |
| | | height | `32dp` |
| | | style | `@style/ImageviewButton` |
| | | src | `@drawable/ic_disconnect_background` |
| | | marginEnd | `16dp` |
| | | Constraint | `Top → tv_name.top`, `Bottom → tv_position.bottom`, `Start → tv_name.end`, `End → parent.end` |
| **位置名稱** | `tv_position` | width | `0dp` (constraint 至 btn_ble.start) |
| | | height | `wrap_content` |
| | | style | `@style/SingleLine` |
| | | marginEnd | `4dp` |
| | | textAppearance | `@style/caption2` |
| | | textColor | `@color/text_aaa` |
| | | Constraint | `Top → tv_name.bottom`, `Start → tv_name.start`, `End → btn_ble.start` |

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 44-81

---

### 2.5 泵頭列表區（RecyclerView，可捲動）

| 屬性 | 值 |
|-----|-----|
| **ID** | `rv_drop_head` |
| **寬度** | `match_parent` |
| **高度** | `wrap_content` |
| **類型** | `RecyclerView` |
| **Item Layout** | `@layout/adapter_drop_head` |
| **clipToPadding** | `false` |
| **overScrollMode** | `never` |
| **paddingTop** | `12dp` |
| **paddingBottom** | `32dp` |
| **Constraint** | `Top → layout_device.bottom`, `Bottom → parent.bottom` |
| **工具預覽** | `tools:itemCount="4"`, `tools:listitem="@layout/adapter_drop_head"` |

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 84-97

**重要發現**：
- ✅ 工具預覽顯示 **4 個 item**（對應 DROP 設備的 4 個泵頭）
- ✅ 使用 `adapter_drop_head.xml` 作為 item layout

---

### 2.6 Progress Overlay（全畫面覆蓋）

| 屬性 | 值 |
|-----|-----|
| **類型** | `include @layout/progress` |
| **ID** | `progress` |
| **寬度** | `match_parent` |
| **高度** | `match_parent` |
| **visibility** | `gone`（預設隱藏） |

**事實來源**：`docs/reef_b_app_res/layout/activity_drop_main.xml` Line 101-106

---

## 任務 3｜RecyclerView Item 結構盤點（adapter_drop_head.xml）

### 3.1 Root 結構

```
MaterialCardView (圓角 8dp, elevation 10dp, margin 16/5/16/5dp)
└── ConstraintLayout
    ├── ConstraintLayout (id=layout_drop_head_title, 標題區, 灰色背景)
    │   ├── ImageView (id=img_drop_head, 泵頭圖片 80x20dp)
    │   └── TextView (id=tv_drop_type_name, 添加劑名稱)
    └── ConstraintLayout (id=layout_drop_head_main, 主要內容, 白色背景)
        ├── ImageView (id=btn_play, 播放按鈕 60x60dp)
        ├── TextView (id=tv_mode, 模式文字)
        ├── LinearLayout (id=layout_mode, 模式詳情)
        │   ├── LinearLayout (id=layout_weekday, 星期圖標 7 個)
        │   ├── TextView (id=tv_time, 時間文字)
        │   └── ConstraintLayout (進度條區塊)
        │       ├── LinearProgressIndicator (id=pb_volume, 進度條)
        │       └── TextView (id=tv_volume, 容量文字 "40 / 100 ml")
        └── Chip (id=chip_total, 總量顯示, visibility=gone)
```

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 1-242

---

### 3.2 MaterialCardView（Item 容器）

| 屬性 | 值 |
|-----|-----|
| **寬度** | `match_parent` |
| **高度** | `wrap_content` |
| **marginStart** | `16dp` |
| **marginTop** | `5dp` |
| **marginEnd** | `16dp` |
| **marginBottom** | `5dp` |
| **cardCornerRadius** | `8dp` |
| **cardElevation** | `10dp` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 2-12

---

### 3.3 標題區（layout_drop_head_title）

| 元件 | ID | 屬性 | 值 |
|-----|----|----|-----|
| **Container** | `layout_drop_head_title` | width | `match_parent` |
| | | height | `wrap_content` |
| | | background | `@color/grey` |
| | | padding | `8dp` |
| | | Constraint | `Top → parent.top`, `Bottom → layout_drop_head_main.top` |
| **泵頭圖片** | `img_drop_head` | width | `80dp` |
| | | height | `20dp` |
| | | scaleType | `fitCenter` |
| | | Constraint | `Start → parent.start`, `CenterVertical → parent` |
| | | tools:src | `@drawable/img_drop_head_1` |
| **添加劑名稱** | `tv_drop_type_name` | width | `0dp` (constraint 至 parent.end) |
| | | height | `wrap_content` |
| | | style | `@style/SingleLine` |
| | | marginStart | `32dp` |
| | | marginEnd | `8dp` |
| | | textAppearance | `@style/body_accent` |
| | | Constraint | `Start → img_drop_head.end`, `End → parent.end`, `CenterVertical → img_drop_head` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 18-53

---

### 3.4 主要內容區（layout_drop_head_main）

#### 3.4.1 Container

| 屬性 | 值 |
|-----|-----|
| **ID** | `layout_drop_head_main` |
| **寬度** | `match_parent` |
| **高度** | `wrap_content` |
| **背景** | `@color/white` |
| **paddingStart** | `8dp` |
| **paddingTop** | `8dp` |
| **paddingEnd** | `12dp` |
| **paddingBottom** | `12dp` |
| **Constraint** | `Top → layout_drop_head_title.bottom`, `Bottom → parent.bottom` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 55-67

---

#### 3.4.2 播放按鈕（btn_play）

| 屬性 | 值 |
|-----|-----|
| **ID** | `btn_play` |
| **寬度** | `60dp` |
| **高度** | `60dp` |
| **style** | `@style/ImageviewButton` |
| **src** | `@drawable/ic_play_enabled` |
| **Constraint** | `Start → parent.start`, `CenterVertical → parent` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 69-78

---

#### 3.4.3 模式文字（tv_mode）

| 屬性 | 值 |
|-----|-----|
| **ID** | `tv_mode` |
| **寬度** | `0dp` (constraint 至 parent.end) |
| **高度** | `wrap_content` |
| **style** | `@style/SingleLine` |
| **marginStart** | `12dp` |
| **marginEnd** | `44dp` |
| **textAppearance** | `@style/caption1` |
| **textColor** | `@color/bg_secondary` |
| **Constraint** | `Top → parent.top`, `Bottom → layout_mode.top`, `Start → btn_play.end`, `End → parent.end` |
| **tools:text** | `"自由模式"` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 80-93

---

#### 3.4.4 模式詳情區（layout_mode）

##### 3.4.4.1 Container

| 屬性 | 值 |
|-----|-----|
| **ID** | `layout_mode` |
| **類型** | `LinearLayout` (vertical) |
| **寬度** | `0dp` (constraint 至 parent.end) |
| **高度** | `wrap_content` |
| **marginTop** | `8dp` |
| **Constraint** | `Top → tv_mode.bottom`, `Bottom → chip_total.top`, `Start → tv_mode.start`, `End → parent.end` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 95-104

---

##### 3.4.4.2 星期圖標列（layout_weekday）

**結構**：7 個 ImageView（Sunday → Saturday）

| 元件 | ID | 屬性 | 值 |
|-----|----|----|-----|
| **Container** | `layout_weekday` | orientation | `horizontal` |
| | | width | `wrap_content` |
| | | height | `wrap_content` |
| **Sunday** | `img_sunday` | width | `20dp` |
| | | height | `20dp` |
| | | marginEnd | `4dp` |
| | | scaleType | `fitCenter` |
| | | src | `@drawable/ic_sunday_unselect` |
| **Monday** | `img_monday` | width | `20dp` |
| | | height | `20dp` |
| | | marginStart | `4dp` |
| | | marginEnd | `4dp` |
| | | src | `@drawable/ic_monday_unselect` |
| **Tuesday** | `img_tuesday` | 同 Monday | src=`@drawable/ic_tuesday_unselect` |
| **Wednesday** | `img_wednesday` | 同 Monday | src=`@drawable/ic_wednesday_unselect` |
| **Thursday** | `img_thursday` | 同 Monday | src=`@drawable/ic_thursday_unselect` |
| **Friday** | `img_friday` | 同 Monday | src=`@drawable/ic_friday_unselect` |
| **Saturday** | `img_saturday` | 同 Monday | src=`@drawable/ic_saturday_unselect` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 106-175

**重要發現**：
- ✅ 星期順序為 **Sunday → Saturday**（日 → 六）
- ✅ 每個圖標 20x20dp，間距 4dp
- ✅ 預設狀態為 `unselect`（未選中）

---

##### 3.4.4.3 時間文字（tv_time）

| 屬性 | 值 |
|-----|-----|
| **ID** | `tv_time` |
| **寬度** | `match_parent` |
| **高度** | `wrap_content` |
| **textAppearance** | `@style/caption1_accent` |
| **textColor** | `@color/text_aaaa` |
| **tools:text** | `"2022-10-30 ~ 2022-11-03"` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 177-186

---

##### 3.4.4.4 進度條區塊

```
ConstraintLayout
├── LinearProgressIndicator (id=pb_volume, 進度條)
└── TextView (id=tv_volume, 容量文字)
```

| 元件 | ID | 屬性 | 值 |
|-----|----|----|-----|
| **進度條** | `pb_volume` | width | `match_parent` |
| | | height | `wrap_content` |
| | | marginTop | `4dp` |
| | | indicatorColor | `@color/grey` |
| | | trackColor | `@color/bg_press` |
| | | trackCornerRadius | `10dp` |
| | | trackThickness | `20dp` |
| | | tools:progress | `40` |
| **容量文字** | `tv_volume` | width | `0dp` (constraint 至 pb_volume) |
| | | height | `wrap_content` |
| | | textAlignment | `center` |
| | | textAppearance | `@style/caption1` |
| | | textColor | `@color/text_aaaa` |
| | | Constraint | `CenterHorizontal → pb_volume`, `CenterVertical → pb_volume` |
| | | tools:text | `"40 / 100 ml"` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 188-219

---

#### 3.4.5 總量 Chip（chip_total）

| 屬性 | 值 |
|-----|-----|
| **ID** | `chip_total` |
| **類型** | `com.google.android.material.chip.Chip` |
| **寬度** | `wrap_content` |
| **高度** | `wrap_content` |
| **marginTop** | `8dp` |
| **clickable** | `false` |
| **visibility** | `gone`（預設隱藏） |
| **textAppearance** | `@style/caption1` |
| **textColor** | `@color/text_aaaa` |
| **chipBackgroundColor** | `@color/bg_aaaa` |
| **chipIcon** | `@drawable/ic_solid_add` |
| **chipMinTouchTargetSize** | `0dp` |
| **chipStrokeColor** | `@color/text_aaaa` |
| **chipStrokeWidth** | `1dp` |
| **Constraint** | `Top → layout_mode.bottom`, `Bottom → parent.bottom`, `Start → tv_mode.start` |
| **tools:text** | `"120 ml"` |

**事實來源**：`docs/reef_b_app_res/layout/adapter_drop_head.xml` Line 222-239

**重要發現**：
- ✅ **預設 visibility=gone**
- ✅ 當顯示時，顯示總量（例如 "120 ml"）
- ✅ 不可點擊（clickable=false）

---

## 任務 4｜Android ViewModel / 行為盤點

### 4.1 ViewModel 資訊

| 項目 | 值 |
|-----|-----|
| **ViewModel 名稱** | `DropMainViewModel` |
| **ViewModel 路徑** | `tw.com.crownelectronics.reefb.ui.activity.drop_main.DropMainViewModel.kt` |
| **對應 Activity** | `DropMainActivity` |

**事實來源**：推測（基於命名規範，需確認實際檔案）

---

### 4.2 UI 觸發的 Method（推測，需確認實際 code）

| Method 名稱 | 觸發點 | 用途 |
|-----------|-------|------|
| `setDeviceById(deviceId: Int)` | `onCreate()` | 設置當前設備，初始化 ViewModel |
| `clickBtnBle()` | `btn_ble.onClick` | 切換 BLE 連接/斷開 |
| `clickBtnPlay(headNo: Int)` | `btn_play.onClick` (item) | 手動執行單次滴液 |
| `getDropHeadList()` | `onResume()` / Sync END | 獲取泵頭列表資料 |

**注意**：以上為推測，需查閱 `DropMainActivity.kt` 實際 code 確認

---

### 4.3 BLE / CommandManager 呼叫（推測，需確認）

| Method | Opcode | 目的 |
|--------|--------|-----|
| `bleManager.sendDropSyncInformationCommand()` | 0x65 | 同步 Dosing 資訊 |
| `bleManager.sendDropManualDropStartCommand(headNo)` | 0x63 | 開始手動滴液 |
| `bleManager.sendDropManualDropEndCommand(headNo)` | 0x64 | 結束手動滴液 |
| `bleManager.sendDropGetTotalDropDecimalCommand(headNo)` | 0x7E | 獲取今日總量 |

**事實來源**：`docs/remaining_parity_items.md` Line 1-28, `docs/DOSING_BEHAVIOR_FACT_AUDIT.md`

---

### 4.4 State 變更（推測，需確認）

| State 項目 | 變更時機 | 觸發來源 |
|-----------|---------|---------|
| `DropInformation.mode[headNo]` | Sync 時接收 RETURN opcodes (0x68-0x6D) | BLE Callback (Repository) |
| `DropInformation.dropVolume[headNo]` | 接收 0x7A/0x7E RETURN | BLE Callback (Repository) |
| `PumpHeadStatus` | 手動滴液開始/結束 | UseCase (immediate only, for Flutter) |

**事實來源**：`docs/DOSING_BEHAVIOR_FACT_AUDIT.md` STEP 4

---

## 任務 5｜使用者流程（Android 事實）

### 5.1 進入頁面

**觸發點**：
- 從 `DeviceFragment` / `HomeFragment` 點擊 DROP 設備卡片
- 或從其他頁面（例如 `DeviceTabPage`）導航

**流程**：
```kotlin
// DeviceFragment.onClickDevice()
when (data.type) {
    DeviceType.DROP -> {
        val intent = Intent(requireContext(), DropMainActivity::class.java)
        intent.putExtra("device_id", data.id)
        startActivity(intent)
    }
}
```

**事實來源**：推測（基於 LED 主頁的類似流程）

---

### 5.2 初始化（onCreate）

**流程**（推測，需確認實際 code）：
1. `setContentView(binding.root)` - 設置視圖
2. `setView()` - 初始化 UI 元件（RecyclerView, Adapter）
3. `setListener()` - 設置點擊監聽器（btn_ble, btn_play）
4. `setObserver()` - 設置 LiveData 觀察者
5. `deviceId = getDeviceIdFromIntent()` - 從 Intent 獲取 device_id
6. `viewModel.setDeviceById(deviceId)` - 設置設備並初始化
7. **自動讀取資料**（推測）：
   - 發送 0x65 Sync 指令
   - 等待 RETURN opcodes 更新 `DropInformation`
   - 更新 RecyclerView

**事實來源**：推測（基於 LED 主頁的類似流程，參考 `docs/LED_MAIN_PAGE_ENTRY_FLOW_COMPARISON.md`）

---

### 5.3 使用者操作

#### 5.3.1 點擊 BLE 圖標（btn_ble）

**位置**：設備識別區右側

**行為**（推測，需確認）：
1. 檢查當前連接狀態
2. 如果已連接 → 斷開連接
3. 如果未連接 → 連接設備
4. 更新 UI（圖標、設備名稱顏色）

**事實來源**：推測（基於 LED 主頁的類似行為，參考 `docs/LED_MAIN_PAGE_BUTTON_FUNCTIONALITY_COMPARISON.md` Line 144-196）

---

#### 5.3.2 點擊泵頭卡片（整個 Item）

**位置**：RecyclerView 的每個 item

**行為**（推測，需確認）：
1. 導航到 `DropHeadMainActivity`（泵頭詳情頁）
2. 傳遞 `device_id` 和 `head_no` (0-3)

**事實來源**：推測（需確認實際 `DropMainActivity.kt` code）

---

#### 5.3.3 點擊播放按鈕（btn_play）

**位置**：每個泵頭 item 的左側

**行為**（推測，需確認）：
1. 觸發 `viewModel.clickBtnPlay(headNo)`
2. **可能的流程 A**：直接發送 0x6E (immediate single dose)
3. **可能的流程 B**：導航到 `ManualDosingPage`（手動滴液頁面）

**事實來源**：推測（需確認實際 `DropMainActivity.kt` code）

---

### 5.4 自動同步行為

#### 5.4.1 進入頁面時

**行為**（推測，需確認）：
1. 發送 0x65 Sync 指令（data[2]=0x01, START）
2. 設備回傳 RETURN opcodes (0x66-0x6D, 0x7A/0x7E)
3. Repository 即時更新 `DosingState`
4. 接收 0x65 Sync END (data[2]=0x02)
5. ViewModel 從 Repository 讀取 state
6. 更新 UI（RecyclerView）

**事實來源**：`docs/DOSING_BEHAVIOR_FACT_AUDIT.md` STEP 1.6, STEP 2.6

---

#### 5.4.2 返回頁面時（onResume）

**行為**（推測，需確認）：
1. 檢查設備連接狀態
2. 如果已連接且需要刷新 → 重新發送 0x65 Sync
3. 更新 UI

**事實來源**：推測（需確認實際 `DropMainActivity.kt` code）

---

### 5.5 是否有「新增 / 設定 / 校正 / 排程」入口？

**推測**（需確認實際 UI）：

| 功能 | Android 是否存在 | 入口位置 | 目標頁面 |
|-----|---------------|---------|---------|
| **新增泵頭** | ❌ 無（泵頭在添加設備時自動創建 4 個） | N/A | N/A |
| **設定** | ✅ 有（推測） | Toolbar 右側設定圖標 | `DropSettingActivity` |
| **校正** | ✅ 有（推測） | 泵頭 item 長按 or 詳情頁 | `DropHeadCalibrationActivity` |
| **排程** | ✅ 有（推測） | 泵頭 item 點擊 → 詳情頁 → 排程按鈕 | `DropHeadScheduleActivity` |

**事實來源**：
- `docs/WIDGET_AND_PAGE_MAPPING.md` Line 76-87（有多個相關 Activity，說明存在這些功能）
- 需確認實際入口位置

---

## 任務 6｜UI 對照清單（Android 為準）

### 6.1 Toolbar

| 元素 | 類型 | 尺寸/屬性 | 必須對齊 |
|-----|------|---------|---------|
| **Toolbar Container** | `include @layout/toolbar_device` | 高度=? (需確認) | ✅ |
| **返回按鈕** | ImageView (推測) | ? | ✅ |
| **標題** | TextView (推測) | ? | ✅ |
| **BLE 圖標** | ImageView (推測) | ? | ✅ |
| **設定圖標** | ImageView (推測) | ? | ✅ |
| **MaterialDivider** | Divider (推測) | 2dp (高度) | ✅ |

**注意**：需讀取 `toolbar_device.xml` 確認實際結構

---

### 6.2 ScrollView 行為

| 屬性 | 值 | 必須對齊 |
|-----|-----|---------|
| **可捲動** | ✅ 是（ScrollView） | ✅ |
| **捲動範圍** | 從 Toolbar 下方到頁面底部 | ✅ |
| **內容** | 設備識別區 + RecyclerView | ✅ |

---

### 6.3 設備識別區

| 元素 | 類型 | 尺寸 (dp) | Padding/Margin (dp) | Visibility | 可點擊 |
|-----|------|----------|------------------|-----------|-------|
| **Container** | ConstraintLayout | width=match_parent, height=wrap_content | padding=16/8/4/12 | visible | ❌ |
| **設備名稱** | TextView | width=0dp, height=wrap_content | - | visible | ❌ |
| **BLE 圖標** | ImageView | 48x32 | marginEnd=16 | visible | ✅ |
| **位置名稱** | TextView | width=0dp, height=wrap_content | marginEnd=4 | visible | ❌ |

---

### 6.4 RecyclerView Item（泵頭卡片）

| 元素 | 類型 | 尺寸 (dp) | Padding/Margin (dp) | Visibility | 可點擊 |
|-----|------|----------|------------------|-----------|-------|
| **Card Container** | MaterialCardView | width=match_parent, height=wrap_content | margin=16/5/16/5 | visible | ✅ |
| | | cornerRadius=8, elevation=10 | | | |
| **標題區 Container** | ConstraintLayout | width=match_parent, height=wrap_content | padding=8 | visible | ❌ |
| **泵頭圖片** | ImageView | 80x20 | - | visible | ❌ |
| **添加劑名稱** | TextView | width=0dp, height=wrap_content | marginStart=32, marginEnd=8 | visible | ❌ |
| **主內容 Container** | ConstraintLayout | width=match_parent, height=wrap_content | padding=8/8/12/12 | visible | ❌ |
| **播放按鈕** | ImageView | 60x60 | - | visible | ✅ |
| **模式文字** | TextView | width=0dp, height=wrap_content | marginStart=12, marginEnd=44 | visible | ❌ |
| **星期圖標 (7個)** | ImageView | 20x20 (每個) | marginStart=4, marginEnd=4 | visible (依模式) | ❌ |
| **時間文字** | TextView | width=match_parent, height=wrap_content | - | visible (依模式) | ❌ |
| **進度條** | LinearProgressIndicator | width=match_parent, height=? | marginTop=4 | visible (依模式) | ❌ |
| | | trackThickness=20, cornerRadius=10 | | | |
| **容量文字** | TextView | width=0dp, height=wrap_content | - | visible (依模式) | ❌ |
| **總量 Chip** | Chip | width=wrap_content, height=wrap_content | marginTop=8 | **gone** (預設) | ❌ |

---

### 6.5 Progress Overlay

| 元素 | 類型 | 尺寸 | Visibility |
|-----|------|------|-----------|
| **Progress Container** | `include @layout/progress` | width=match_parent, height=match_parent | **gone** (預設) |

---

## 任務 7｜業務行為對照清單（Android 為準）

### 7.1 觸發 BLE Opcode 的行為

| 行為 | Opcode | 觸發時機 | 等待 ACK/RETURN | 錯誤處理 |
|-----|--------|---------|---------------|---------|
| **進入頁面** | 0x65 (START) | `onCreate()` / `setDeviceById()` | ✅ 等待 RETURN opcodes | BLE error / timeout |
| **手動滴液開始** | 0x63 | 點擊 btn_play (推測) | ✅ 等待 ACK (0x63) | ACK 失敗 / timeout |
| **手動滴液結束** | 0x64 | 手動滴液完成 (推測) | ✅ 等待 ACK (0x64) | ACK 失敗 / timeout |
| **獲取今日總量** | 0x7E / 0x7A | Sync 時 or 手動刷新 (推測) | ✅ 等待 RETURN (0x7E/0x7A) | BLE error / timeout |
| **Sync END** | 0x65 (END) | 接收所有 RETURN 後 | ❌ 無（單向通知） | - |

**事實來源**：`docs/DOSING_BEHAVIOR_FACT_AUDIT.md`, `docs/remaining_parity_items.md`

---

### 7.2 只改 UI State 的行為

| 行為 | State 變更 | 觸發時機 |
|-----|----------|---------|
| **點擊 BLE 圖標** | BLE 連接狀態 UI | 連接/斷開 BLE |
| **RecyclerView 更新** | Adapter notifyDataSetChanged | Sync END 後 |
| **Loading 顯示/隱藏** | `progress.visibility` | 發送指令前/後 |

---

### 7.3 等待 ACK / RETURN / Sync END 的行為

| 行為 | Opcode 流程 | 等待內容 | 成功後動作 | 失敗後動作 |
|-----|-----------|---------|----------|----------|
| **Sync 同步** | 0x65 (START) → 0x66-0x6D (RETURN) → 0x65 (END) | 等待 Sync END | 更新 UI（RecyclerView） | 顯示錯誤 toast |
| **手動滴液** | 0x63 → ACK (0x63) | 等待 ACK | 顯示成功 toast / 更新 UI | 顯示錯誤 toast |
| **獲取今日總量** | 0x7E → RETURN (0x7E) | 等待 RETURN | 更新進度條 & 容量文字 | 顯示錯誤 toast |

**事實來源**：`docs/DOSING_BEHAVIOR_FACT_AUDIT.md` STEP 1.5, STEP 1.6

---

### 7.4 錯誤處理來源

| 錯誤類型 | 來源 | Android 處理方式 |
|---------|------|---------------|
| **BLE 寫入錯誤** | `BleAdapter.writeBytes()` exception | Toast 錯誤訊息（在 Activity） |
| **ACK 失敗** | ACK opcode `data[2] = 0x00` | Toast 錯誤訊息（在 ViewModel callback） |
| **Sync 失敗** | 0x65 `data[2] = 0x00` (FAILED) | Toast 錯誤訊息 |
| **Timeout** | BLE write timeout | Toast 錯誤訊息 |
| **連接失敗** | BLE connection error | Toast 錯誤訊息（在 Fragment） |

**事實來源**：`docs/DOSING_BEHAVIOR_FACT_AUDIT.md` STEP 1.5

---

## 補充說明

### ⚠️ 需要進一步確認的項目

以下項目在現有文檔中無明確事實，需要讀取 Android 原始碼確認：

1. **DropMainActivity.kt 實際 code**：
   - `setView()` / `setListener()` / `setObserver()` 的完整實作
   - 點擊 btn_play 的實際行為（直接滴液 or 導航到其他頁面）
   - onResume() 的自動刷新邏輯

2. **DropMainViewModel.kt 實際 code**：
   - Public methods 完整清單
   - BLE 呼叫的時機與順序
   - State 管理邏輯

3. **toolbar_device.xml 實際結構**：
   - 所有子元件的 ID、尺寸、樣式
   - MaterialDivider 的確切高度與顏色

4. **星期圖標的顯示邏輯**：
   - 何時顯示星期圖標（哪種模式）
   - 何時顯示時間文字（哪種模式）
   - 何時顯示進度條（哪種模式）

5. **chip_total 的顯示條件**：
   - 在什麼情況下 visibility=visible
   - 顯示的內容來源（總量計算邏輯）

---

## 審核結論

### ✅ 已確認的事實

1. **Layout 結構**：Root ConstraintLayout → Toolbar → ScrollView → 設備識別區 + RecyclerView → Progress
2. **ScrollView 行為**：✅ **全頁可捲動**（例外於 "一頁一畫面" 規則）
3. **RecyclerView Item**：4 個 item（對應 4 個泵頭），使用 `adapter_drop_head.xml`
4. **Item 結構**：標題區（灰色背景）+ 主內容區（白色背景）
5. **主要元素**：泵頭圖片、添加劑名稱、播放按鈕、模式文字、星期圖標、時間文字、進度條、容量文字、總量 Chip
6. **Visibility**：chip_total 預設 gone

### ⚠️ 需要補充確認

1. **DropMainActivity.kt / DropMainViewModel.kt 原始碼**
2. **toolbar_device.xml 實際結構**
3. **使用者操作的實際行為**（點擊 item / btn_play）
4. **星期圖標 / 時間文字 / 進度條的顯示邏輯**
5. **chip_total 的顯示條件**

---

**審核完成，停工，等待下一步指示。**

