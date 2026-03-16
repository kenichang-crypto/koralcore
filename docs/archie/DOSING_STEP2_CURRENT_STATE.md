# Dosing 模組 STEP 2：現狀檢查報告

**審核目標**：DropMainActivity（Dosing 主頁）vs DosingMainPage（Flutter）  
**審核日期**：2026-01-03  
**事實來源**：Android reef-b-app vs koralcore 實際 code  
**審核模式**：事實對照（列出差異，不寫結論）

---

## 任務 1｜Flutter 現狀盤點

### 1.1 Flutter Page 資訊

| 項目 | 值 |
|-----|-----|
| **Page 名稱** | `DosingMainPage` |
| **File 路徑** | `lib/features/doser/presentation/pages/dosing_main_page.dart` |
| **Widget 類型** | `StatelessWidget` |
| **總行數** | 348 |

**事實來源**：`dosing_main_page.dart` Line 1-348

---

### 1.2 Flutter UI 結構（現狀）

```
Scaffold
├── ReefAppBar (自定義 Toolbar)
│   ├── Back Button (leading)
│   ├── Device Name (title)
│   ├── Favorite Button (actions)
│   ├── PopupMenuButton (Edit/Delete/Reset)
│   └── BLE Button (actions)
└── Body: ReefMainBackground
    └── SafeArea
        └── Column
            ├── Fixed Header Section (Padding)
            │   ├── dosingSubHeader (Text)
            │   ├── BleGuardBanner (if not connected)
            │   ├── dosingPumpHeadsHeader (Text)
            │   └── dosingPumpHeadsSubheader (Text)
            └── Expanded
                └── ListView (scrollable)
                    ├── DosingMainPumpHeadList (4 cards)
                    └── Padding (Entry tiles)
                        ├── DosingMainEntryTile (Schedule)
                        ├── DosingMainEntryTile (Manual)
                        ├── DosingMainEntryTile (Calibration)
                        └── DosingMainEntryTile (History)
```

**事實來源**：`dosing_main_page.dart` Line 38-335

---

### 1.3 Flutter 子 Widget

| Widget 名稱 | File 路徑 | 用途 |
|-----------|---------|------|
| `DosingMainPumpHeadList` | `lib/features/doser/presentation/widgets/dosing_main_pump_head_list.dart` | 泵頭列表容器 (4 個 card) |
| `DosingMainPumpHeadCard` | `lib/features/doser/presentation/widgets/dosing_main_pump_head_card.dart` | 單個泵頭 card |
| `DosingMainEntryTile` | `lib/features/doser/presentation/widgets/dosing_main_entry_tile.dart` | 功能入口磚 |

**事實來源**：`dosing_main_page.dart` imports

---

## 任務 2｜Android vs Flutter 結構對照

### 2.1 Root Layout 對照

| 項目 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Root Container** | `ConstraintLayout` | `Scaffold` | ✅ 對應 |
| **Background** | `@color/bg_aaa` | `ReefMainBackground` | ⚠️ 差異（需確認顏色） |
| **Toolbar** | `include @layout/toolbar_device` | `ReefAppBar` | ⚠️ 差異（結構不同） |
| **Scrollable Area** | `ScrollView` | `ListView` | ⚠️ 差異（範圍不同） |
| **Progress Overlay** | `include @layout/progress` (gone) | ❌ 無 | ❌ 缺失 |

**事實來源**：
- Android: `activity_drop_main.xml` Line 2-107
- Flutter: `dosing_main_page.dart` Line 38-335

---

### 2.2 Toolbar 對照

#### 2.2.1 Android toolbar_device（推測結構）

| 元素 | 類型 | 位置 |
|-----|------|------|
| **返回按鈕** | ImageView (推測) | Left |
| **標題** | TextView (推測) | Center |
| **BLE 圖標** | ImageView (推測) | Right |
| **設定圖標** | ImageView (推測) | Right |
| **MaterialDivider** | Divider (推測) | Bottom (2dp) |

**注意**：需讀取 `toolbar_device.xml` 確認實際結構

---

#### 2.2.2 Flutter ReefAppBar

| 元素 | 類型 | 位置 | 行為 |
|-----|------|------|-----|
| **返回按鈕** | `IconButton` | leading | `Navigator.pop()` |
| **設備名稱** | `Text` | title | 顯示 `activeDeviceName` |
| **Favorite Button** | `IconButton` (FutureBuilder) | actions[0] | Toggle favorite |
| **PopupMenuButton** | `PopupMenuButton` | actions[1] | Edit/Delete/Reset |
| **BLE Button** | `IconButton` | actions[2] | Connect/Disconnect |

**事實來源**：`dosing_main_page.dart` Line 39-188

---

#### 2.2.3 差異分析

| 差異項 | Android | Flutter | 說明 |
|-------|---------|---------|------|
| **Favorite Button** | ❌ 無（推測） | ✅ 有 | Flutter 多出 |
| **PopupMenuButton** | ❌ 無（推測） | ✅ 有（Edit/Delete/Reset） | Flutter 多出 |
| **設定圖標** | ✅ 有（推測） | ❌ 無（在 PopupMenu 中） | 位置不同 |
| **MaterialDivider** | ✅ 有（推測 2dp） | ⚠️ 未知（需確認 ReefAppBar） | 需確認 |

**⚠️ 重大差異**：Flutter Toolbar 功能比 Android 多（Favorite, PopupMenu）

---

### 2.3 ScrollView 範圍對照

| 項目 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Scrollable 範圍** | 從 Toolbar 下方到頁面底部（整頁） | 僅從 Fixed Header 下方（部分） | ❌ 不一致 |
| **Fixed 區塊** | 無（除了 Toolbar） | Header Section (dosingSubHeader, BleGuardBanner, dosingPumpHeadsHeader, dosingPumpHeadsSubheader) | ❌ 差異 |
| **Scrollable 區塊** | 設備識別區 + RecyclerView | 僅 DosingMainPumpHeadList + Entry Tiles | ❌ 差異 |

**事實來源**：
- Android: `activity_drop_main.xml` Line 17-99（ScrollView 包住整個內容）
- Flutter: `dosing_main_page.dart` Line 194-330（Fixed Header + Expanded ListView）

**⚠️ 重大差異**：Android 整頁可捲動，Flutter 只有部分區域可捲動

---

### 2.4 設備識別區對照

#### 2.4.1 Android layout_device

```
ConstraintLayout (background=bg_aaaa, padding=16/8/4/12dp)
├── TextView (tv_name, 設備名稱)
├── ImageView (btn_ble, BLE 狀態圖標, 48x32dp)
└── TextView (tv_position, 位置名稱)
```

**事實來源**：`activity_drop_main.xml` Line 30-82

---

#### 2.4.2 Flutter 對應區塊

**❌ 無對應區塊**

Flutter 的設備名稱在 **AppBar title**，BLE 按鈕在 **AppBar actions**，位置名稱 **無顯示**。

**事實來源**：`dosing_main_page.dart` Line 39-188

---

#### 2.4.3 差異分析

| 元素 | Android 位置 | Flutter 位置 | 狀態 |
|-----|------------|------------|------|
| **設備名稱** | 內容區（layout_device） | AppBar title | ⚠️ 位置不同 |
| **BLE 圖標** | 內容區（layout_device） | AppBar actions | ⚠️ 位置不同 |
| **位置名稱** | 內容區（layout_device） | ❌ 無 | ❌ 缺失 |
| **Container 背景** | bg_aaaa | ❌ 無 | ❌ 缺失 |
| **Container padding** | 16/8/4/12dp | ❌ 無 | ❌ 缺失 |

**⚠️ 重大差異**：Flutter 無設備識別區，元素分散在 AppBar 和缺失

---

### 2.5 泵頭列表對照

#### 2.5.1 Android RecyclerView (rv_drop_head)

| 屬性 | 值 |
|-----|-----|
| **Item Layout** | `adapter_drop_head.xml` |
| **Item Count** | 4 (固定) |
| **paddingTop** | 12dp |
| **paddingBottom** | 32dp |
| **clipToPadding** | false |
| **overScrollMode** | never |

**事實來源**：`activity_drop_main.xml` Line 84-97

---

#### 2.5.2 Flutter DosingMainPumpHeadList

| 屬性 | 值 |
|-----|-----|
| **Item Widget** | `DosingMainPumpHeadCard` |
| **Item Count** | 4 (headOrder: A, B, C, D) |
| **Container** | `Column` (in ListView) |
| **Item Spacing** | `SizedBox(height: AppSpacing.md)` (16dp) |
| **Padding** | 由 ListView 控制（xl=24dp） |

**事實來源**：
- `dosing_main_pump_head_list.dart` Line 15-67
- `dosing_main_page.dart` Line 227-231

---

#### 2.5.3 差異分析

| 項目 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Container 類型** | RecyclerView | Column in ListView | ⚠️ 差異 |
| **Item Count** | 4 (tools:itemCount) | 4 (headOrder) | ✅ 一致 |
| **Head ID Format** | 推測 0-3 or A-D（需確認） | A-D | ⚠️ 需確認 Android 格式 |
| **paddingTop** | 12dp | ListView padding xl=24dp | ❌ 不一致 |
| **paddingBottom** | 32dp | ListView padding xl=24dp | ❌ 不一致 |
| **clipToPadding** | false | 未設置 | ⚠️ 差異 |
| **overScrollMode** | never | 未設置 | ⚠️ 差異 |

---

### 2.6 泵頭 Card 對照（adapter_drop_head.xml vs DosingMainPumpHeadCard）

#### 2.6.1 Card Container

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `MaterialCardView` | `Card` | ✅ 對應 |
| **marginStart** | 16dp | 16dp (AppSpacing.md) | ✅ 一致 |
| **marginTop** | 5dp | 5dp | ✅ 一致 |
| **marginEnd** | 16dp | 16dp (AppSpacing.md) | ✅ 一致 |
| **marginBottom** | 5dp | 5dp | ✅ 一致 |
| **cornerRadius** | 8dp | 8dp (AppRadius.sm) | ✅ 一致 |
| **elevation** | 10dp | 10 | ✅ 一致 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 2-12
- Flutter: `dosing_main_pump_head_card.dart` Line 55-65

---

#### 2.6.2 標題區（layout_drop_head_title）

| 元素 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Container 類型** | `ConstraintLayout` | `Container` (Row) | ⚠️ 差異 |
| **背景** | `@color/grey` | `AppColors.grey` | ✅ 一致 |
| **padding** | 8dp | 8dp (AppSpacing.xs) | ✅ 一致 |
| **泵頭圖片 (img_drop_head)** | `ImageView`, 80x20dp | `SvgPicture.asset`, 80x20dp | ✅ 一致 |
| **泵頭圖片來源** | `@drawable/img_drop_head_1` | `assets/icons/img_drop_head_a.svg` | ⚠️ 格式不同 |
| **添加劑名稱 (tv_drop_type_name)** | `TextView`, body_accent | `Text`, bodyAccent | ✅ 一致 |
| **名稱 marginStart** | 32dp | 32dp | ✅ 一致 |
| **名稱 marginEnd** | 8dp | ❌ 無（Expanded） | ⚠️ 差異 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 18-53
- Flutter: `dosing_main_pump_head_card.dart` Line 73-108

---

#### 2.6.3 主要內容區（layout_drop_head_main）

##### Container

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `ConstraintLayout` | `Container` (Row) | ⚠️ 差異 |
| **背景** | `@color/white` | `AppColors.surface` | ⚠️ 需確認顏色 |
| **paddingStart** | 8dp | 8dp (AppSpacing.xs) | ✅ 一致 |
| **paddingTop** | 8dp | 8dp (AppSpacing.xs) | ✅ 一致 |
| **paddingEnd** | 12dp | 12dp (AppSpacing.md + xs) | ✅ 一致 |
| **paddingBottom** | 12dp | 12dp (AppSpacing.md + xs) | ✅ 一致 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 55-67
- Flutter: `dosing_main_pump_head_card.dart` Line 111-125

---

##### 播放按鈕（btn_play）

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `ImageView` | `IconButton` | ⚠️ 差異 |
| **尺寸** | 60x60dp | 60x60dp | ✅ 一致 |
| **style** | `@style/ImageviewButton` | padding=zero, constraints=60x60 | ⚠️ 差異 |
| **src** | `@drawable/ic_play_enabled` | `CommonIconHelper.getPlayIcon(size: 60)` | ⚠️ 需確認圖標 |
| **可點擊** | ✅ 是 | ✅ 是（onPlay） | ✅ 一致 |
| **marginEnd** | 無（Constraint） | 12dp (AppSpacing.md) | ⚠️ 差異 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 69-78
- Flutter: `dosing_main_pump_head_card.dart` Line 129-146

---

##### 模式文字（tv_mode）

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `TextView` | `Text` | ✅ 對應 |
| **style** | `@style/SingleLine` | maxLines=1, overflow=ellipsis | ✅ 對應 |
| **textAppearance** | `@style/caption1` | `AppTextStyles.caption1` | ✅ 一致 |
| **textColor** | `@color/bg_secondary` | `AppColors.textSecondary` | ⚠️ 需確認顏色 |
| **marginStart** | 12dp (Constraint) | 12dp (SizedBox) | ✅ 一致 |
| **marginEnd** | 44dp | ❌ 無（Expanded） | ⚠️ 差異 |
| **tools:text** | "自由模式" | `_getModeName()` | ⚠️ 邏輯不同 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 80-93
- Flutter: `dosing_main_pump_head_card.dart` Line 154-161

---

##### 星期圖標（layout_weekday）

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Container 類型** | `LinearLayout` (horizontal) | `Row` | ✅ 對應 |
| **圖標數量** | 7 (Sunday → Saturday) | 7 (index 0-6) | ✅ 一致 |
| **圖標尺寸** | 20x20dp | 20x20dp | ✅ 一致 |
| **圖標間距** | marginStart=4dp, marginEnd=4dp | padding left/right=4dp | ✅ 一致 |
| **圖標來源** | `@drawable/ic_sunday_unselect` 等 | `assets/icons/ic_sunday_unselect.svg` 等 | ⚠️ 格式不同 |
| **選中狀態** | ic_xxx_select / ic_xxx_unselect | _getWeekdayIconAsset(index, isSelected) | ✅ 對應 |
| **實際資料** | 由 Adapter 填充 | `weekDays = [false, false, ...]` (TODO) | ❌ 未實作 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 106-175
- Flutter: `dosing_main_pump_head_card.dart` Line 169-185

**⚠️ 重大差異**：Flutter 星期圖標全部 hardcode 為 `false`（未實作實際資料）

---

##### 時間文字（tv_time）

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `TextView` | `Text` (conditional) | ✅ 對應 |
| **textAppearance** | `@style/caption1_accent` | `AppTextStyles.caption1Accent` | ✅ 一致 |
| **textColor** | `@color/text_aaaa` | `AppColors.textPrimary` | ⚠️ 需確認顏色 |
| **tools:text** | "2022-10-30 ~ 2022-11-03" | `timeString` (null, TODO) | ❌ 未實作 |
| **實際資料** | 由 Adapter 填充 | `final String? timeString = null; // TODO` | ❌ 未實作 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 177-186
- Flutter: `dosing_main_pump_head_card.dart` Line 188-198

**⚠️ 重大差異**：Flutter 時間文字未實作（hardcode null）

---

##### 進度條（pb_volume, tv_volume）

| 元素 | 屬性 | Android | Flutter | 狀態 |
|-----|-----|---------|---------|------|
| **進度條** | 類型 | `LinearProgressIndicator` | `LinearProgressIndicator` | ✅ 對應 |
| | trackThickness | 20dp | minHeight=20 | ✅ 一致 |
| | trackCornerRadius | 10dp | borderRadius=10 | ✅ 一致 |
| | indicatorColor | `@color/grey` | `AppColors.grey` | ✅ 一致 |
| | trackColor | `@color/bg_press` | `AppColors.surfacePressed` | ⚠️ 需確認顏色 |
| | tools:progress | 40 | progress (calculated) | ⚠️ 計算邏輯不同 |
| | marginTop | 4dp | 4dp (SizedBox) | ✅ 一致 |
| **容量文字** | 類型 | `TextView` | `Text` | ✅ 對應 |
| | textAppearance | `@style/caption1` | `AppTextStyles.caption1` | ✅ 一致 |
| | textColor | `@color/text_aaaa` | `AppColors.textPrimary` | ⚠️ 需確認顏色 |
| | textAlignment | center | textAlign=center | ✅ 一致 |
| | tools:text | "40 / 100 ml" | `dosingVolumeFormat(...)` | ⚠️ 格式需確認 |
| | Constraint | Center in pb_volume | Stack center | ✅ 對應 |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 192-219
- Flutter: `dosing_main_pump_head_card.dart` Line 200-223

**Progress 計算邏輯**：
- Flutter: `progress = (todayDispensedMl / dailyTargetMl).clamp(0.0, 1.0)`
- Android: 需確認實際計算邏輯（可能相同）

---

##### 總量 Chip（chip_total）

| 屬性 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **類型** | `com.google.android.material.chip.Chip` | ❌ 無 | ❌ 缺失 |
| **visibility** | **gone** (預設) | ❌ 無 | ⚠️ 差異（Android 預設隱藏） |
| **marginTop** | 8dp | - | - |
| **clickable** | false | - | - |
| **textAppearance** | `@style/caption1` | - | - |
| **textColor** | `@color/text_aaaa` | - | - |
| **chipBackgroundColor** | `@color/bg_aaaa` | - | - |
| **chipIcon** | `@drawable/ic_solid_add` | - | - |
| **chipStrokeColor** | `@color/text_aaaa` | - | - |
| **chipStrokeWidth** | 1dp | - | - |
| **tools:text** | "120 ml" | - | - |

**事實來源**：
- Android: `adapter_drop_head.xml` Line 222-239
- Flutter: `dosing_main_pump_head_card.dart`（無對應元素）

**⚠️ 重大差異**：Flutter 完全缺失 chip_total 元素

---

### 2.7 Entry Tiles 對照

#### 2.7.1 Android 狀態

**❌ Android 無 Entry Tiles**

Android `activity_drop_main.xml` 只包含：
- Toolbar
- 設備識別區
- 泵頭列表

無任何 "Schedule / Manual / Calibration / History" 入口磚。

**事實來源**：`activity_drop_main.xml` Line 1-107（完整 XML，無 Entry Tiles）

---

#### 2.7.2 Flutter 狀態

**✅ Flutter 有 4 個 Entry Tiles**

| Entry | 標題 | 副標題 | 導航目標 |
|-------|-----|-------|---------|
| **Schedule** | `l10n.dosingEntrySchedule` | `l10n.dosingScheduleOverviewSubtitle` | `PumpHeadSchedulePage` |
| **Manual** | `l10n.dosingEntryManual` | `l10n.dosingManualPageSubtitle` | `ManualDosingPage` |
| **Calibration** | `l10n.dosingEntryCalibration` | `l10n.dosingCalibrationHistorySubtitle` | `PumpHeadCalibrationPage` |
| **History** | `l10n.dosingEntryHistory` | `l10n.dosingHistorySubtitle` | `PumpHeadDetailPage` |

**事實來源**：`dosing_main_page.dart` Line 254-324

---

#### 2.7.3 差異分析

**⚠️ 重大差異**：Flutter 多出 4 個 Entry Tiles，Android 完全無此結構。

**推測**：Android 的這些功能入口可能在：
1. 泵頭 item 點擊後進入的詳情頁（`DropHeadMainActivity`）
2. Toolbar 的設定選單
3. 其他頁面

**需確認**：Android 進入這些功能的實際路徑。

---

### 2.8 Progress Overlay 對照

| 項目 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Progress Overlay** | `include @layout/progress` | ❌ 無 | ❌ 缺失 |
| **visibility** | gone (預設) | - | - |
| **width** | match_parent | - | - |
| **height** | match_parent | - | - |

**事實來源**：
- Android: `activity_drop_main.xml` Line 101-106
- Flutter: `dosing_main_page.dart`（完整檔案無 Progress Overlay）

**⚠️ 重大差異**：Flutter 完全缺失全畫面 Loading Progress Overlay

---

## 任務 3｜行為對照

### 3.1 進入頁面行為

| 行為 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **獲取 device_id** | 從 Intent extra | 從 `AppSession.activeDeviceId` | ⚠️ 方式不同 |
| **setDeviceById** | `viewModel.setDeviceById(deviceId)` | ❌ 無 | ❌ 缺失 |
| **發送 Sync** | 0x65 (START) | ❌ 無 | ❌ 缺失 |
| **等待 RETURN** | 0x66-0x6D, 0x7A/0x7E | ❌ 無 | ❌ 缺失 |
| **更新 UI** | Adapter.notifyDataSetChanged | `context.watch<AppSession>()` | ⚠️ 方式不同 |

**事實來源**：
- Android: 推測（需確認 `DropMainActivity.kt`）
- Flutter: `dosing_main_page.dart` Line 27-347

**⚠️ 重大差異**：Flutter 無 Sync 行為，僅 watch AppSession

---

### 3.2 點擊行為對照

#### 3.2.1 點擊 BLE 圖標

| 行為 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **觸發點** | layout_device -> btn_ble | AppBar actions -> IconButton | ⚠️ 位置不同 |
| **連接時** | `viewModel.clickBtnBle()` → disconnect | `handleDisconnect(context, session, appContext)` | ⚠️ 需確認邏輯 |
| **斷開時** | `viewModel.clickBtnBle()` → connect | `handleConnect(context, session, appContext)` | ⚠️ 需確認邏輯 |

**事實來源**：
- Android: 推測（需確認 `DropMainActivity.kt`）
- Flutter: `dosing_main_page.dart` Line 178-187

---

#### 3.2.2 點擊泵頭 Card

| 行為 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **觸發點** | RecyclerView item click | Card onTap | ✅ 對應 |
| **導航目標** | `DropHeadMainActivity` (推測) | `PumpHeadDetailPage` | ⚠️ 需確認 |
| **傳遞參數** | device_id, head_no (0-3, 推測) | headId (A-D) | ⚠️ 格式不同 |

**事實來源**：
- Android: 推測（需確認 `DropMainActivity.kt`）
- Flutter: `dosing_main_page.dart` Line 237-242

---

#### 3.2.3 點擊播放按鈕

| 行為 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **觸發點** | btn_play (item) | IconButton onPlay | ✅ 對應 |
| **行為 A** | 直接發送 0x6E (immediate) | `handlePlayDosing(...)` | ⚠️ 需確認 Android 實際行為 |
| **行為 B** | 導航到 ManualDosingPage | - | ⚠️ 需確認 Android 實際行為 |

**事實來源**：
- Android: 推測（需確認 `DropMainActivity.kt`）
- Flutter: `dosing_main_page.dart` Line 244-246

---

### 3.3 業務邏輯對照

#### 3.3.1 BLE Sync

| 項目 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **進入時自動 Sync** | ✅ 是 | ❌ 否 | ❌ 缺失 |
| **Opcode** | 0x65 (START) | ❌ 無 | ❌ 缺失 |
| **等待 RETURN** | 0x66-0x6D, 0x7A/0x7E | ❌ 無 | ❌ 缺失 |
| **State 更新** | Repository (BLE Callback) | ❌ 無 | ❌ 缺失 |

**事實來源**：
- Android: `docs/DOSING_BEHAVIOR_FACT_AUDIT.md` STEP 1.6
- Flutter: `dosing_main_page.dart`（完整檔案無 Sync 邏輯）

**⚠️ 重大差異**：Flutter 完全無 BLE Sync 行為

---

#### 3.3.2 手動滴液

| 項目 | Android（推測） | Flutter | 狀態 |
|-----|---------------|---------|------|
| **觸發方式** | 點擊 btn_play | 點擊 IconButton onPlay | ✅ 對應 |
| **Opcode** | 0x6E (immediate) or 導航 | `handlePlayDosing(...)` | ⚠️ 需確認 |
| **等待 ACK** | ✅ 是 | ⚠️ 需確認 | ⚠️ 需確認 |

**事實來源**：
- Android: 推測（需確認 `DropMainActivity.kt`）
- Flutter: `dosing_main_page_helpers.dart` (handlePlayDosing)

---

#### 3.3.3 Favorite / Edit / Delete / Reset

| 項目 | Android | Flutter | 狀態 |
|-----|---------|---------|------|
| **Favorite** | ❌ 無（推測） | ✅ 有 | Flutter 多出 |
| **Edit** | ❌ 無（推測） | ✅ 有（PopupMenu） | Flutter 多出（或 Android 在其他位置） |
| **Delete** | ❌ 無（推測） | ✅ 有（PopupMenu） | Flutter 多出（或 Android 在其他位置） |
| **Reset** | ❌ 無（推測） | ✅ 有（PopupMenu） | Flutter 多出（或 Android 在其他位置） |

**事實來源**：
- Android: 推測（需確認 Toolbar 功能）
- Flutter: `dosing_main_page.dart` Line 109-176

---

## 任務 4｜資料來源對照

### 4.1 Android 資料來源（推測）

| 資料 | 來源 |
|-----|------|
| **設備名稱** | `viewModel.getNowDevice().name` |
| **設備位置** | `viewModel.getNowDevice().sinkName` or `positionName` |
| **BLE 連接狀態** | `viewModel.isConnected` or `BleManager.isConnected()` |
| **泵頭資料** | `viewModel.pumpHeads` (from `DosingState`) |
| **添加劑名稱** | `PumpHead.additiveName` |
| **今日總量** | `PumpHead.todayDispensedMl` |
| **目標總量** | `PumpHead.dailyTargetMl` |
| **模式** | `PumpHeadMode.mode` |
| **星期** | `PumpHeadMode.runDay` |
| **時間** | `PumpHeadMode.timeString` |

**事實來源**：推測（需確認 `DropMainViewModel.kt` 和 `DropMainActivity.kt`）

---

### 4.2 Flutter 資料來源

| 資料 | 來源 |
|-----|------|
| **設備名稱** | `session.activeDeviceName` |
| **設備位置** | ❌ 無 |
| **BLE 連接狀態** | `session.isBleConnected` |
| **泵頭資料** | `session.pumpHeads` |
| **添加劑名稱** | `PumpHead.additiveName` |
| **今日總量** | `PumpHead.todayDispensedMl` |
| **目標總量** | `PumpHead.dailyTargetMl` |
| **模式** | `_getModeName(summary, l10n)` (simplified) |
| **星期** | `weekDays = [false, false, ...]` (hardcode, TODO) |
| **時間** | `timeString = null` (hardcode, TODO) |

**事實來源**：
- `dosing_main_page.dart` Line 32-36
- `dosing_main_pump_head_list.dart` Line 37-46
- `dosing_main_pump_head_card.dart` Line 45-52

---

### 4.3 差異分析

| 資料項 | Android | Flutter | 狀態 |
|-------|---------|---------|------|
| **設備位置** | ✅ 有 | ❌ 無 | ❌ 缺失 |
| **模式** | 從 `PumpHeadMode.mode` | `_getModeName()` (simplified) | ⚠️ 邏輯不同 |
| **星期** | 從 `PumpHeadMode.runDay` | hardcode `false` | ❌ 未實作 |
| **時間** | 從 `PumpHeadMode.timeString` | hardcode `null` | ❌ 未實作 |

**⚠️ 重大差異**：Flutter 模式/星期/時間資料未實作

---

## 任務 5｜缺失清單（Flutter vs Android）

### 5.1 UI 元素缺失

| 元素 | Android 位置 | Flutter 狀態 |
|-----|------------|------------|
| **設備識別區 Container** | layout_device | ❌ 完全缺失 |
| **設備位置名稱** | tv_position | ❌ 缺失 |
| **總量 Chip** | chip_total (gone) | ❌ 缺失 |
| **Progress Overlay** | include progress (gone) | ❌ 缺失 |

---

### 5.2 行為缺失

| 行為 | Android | Flutter 狀態 |
|-----|---------|------------|
| **進入時 BLE Sync** | 0x65 (START) | ❌ 缺失 |
| **等待 RETURN** | 0x66-0x6D, 0x7A/0x7E | ❌ 缺失 |
| **Sync END 處理** | 0x65 (END) → update UI | ❌ 缺失 |
| **Progress 顯示** | visibility=visible/gone | ❌ 缺失 |

---

### 5.3 資料缺失

| 資料 | Android | Flutter 狀態 |
|-----|---------|------------|
| **設備位置** | tv_position | ❌ 缺失 |
| **星期選擇** | PumpHeadMode.runDay | ❌ 未實作（hardcode false） |
| **時間字串** | PumpHeadMode.timeString | ❌ 未實作（hardcode null） |

---

## 任務 6｜多餘項目（Flutter vs Android）

### 6.1 UI 元素多餘

| 元素 | Android | Flutter | 說明 |
|-----|---------|---------|------|
| **Fixed Header Section** | ❌ 無 | ✅ 有（dosingSubHeader, dosingPumpHeadsHeader, dosingPumpHeadsSubheader） | Flutter 多出 |
| **BleGuardBanner** | ❌ 無 | ✅ 有 | Flutter 多出 |
| **Favorite Button** | ❌ 無（推測） | ✅ 有（AppBar） | Flutter 多出 |
| **PopupMenuButton** | ❌ 無（推測） | ✅ 有（Edit/Delete/Reset） | Flutter 多出 |
| **Entry Tiles (4 個)** | ❌ 無 | ✅ 有（Schedule, Manual, Calibration, History） | Flutter 多出 |

---

### 6.2 行為多餘

| 行為 | Android | Flutter | 說明 |
|-----|---------|---------|------|
| **Favorite Toggle** | ❌ 無（推測） | ✅ 有 | Flutter 多出 |
| **Edit 導航** | ❌ 無（推測） | ✅ 有（DeviceSettingsPage） | Flutter 多出 |
| **Delete 確認** | ❌ 無（推測） | ✅ 有（confirmDeleteDevice） | Flutter 多出 |
| **Reset 確認** | ❌ 無（推測） | ✅ 有（confirmResetDevice） | Flutter 多出 |
| **Entry Tile 導航 (4 個)** | ❌ 無 | ✅ 有 | Flutter 多出 |

---

## 任務 7｜結構差異摘要

### 7.1 重大結構差異

| 差異項 | Android | Flutter | 影響 |
|-------|---------|---------|------|
| **Scrollable 範圍** | 整頁（ScrollView） | 部分（ListView, Fixed Header） | 🔴 重大 |
| **設備識別區** | 內容區（固定背景，顯示設備名/位置/BLE） | ❌ 無（分散在 AppBar） | 🔴 重大 |
| **Toolbar 功能** | 簡單（返回/標題/BLE/設定） | 複雜（返回/標題/Favorite/PopupMenu/BLE） | 🟡 中等 |
| **Entry Tiles** | ❌ 無 | ✅ 有（4 個） | 🔴 重大 |
| **Progress Overlay** | ✅ 有（gone） | ❌ 無 | 🔴 重大 |
| **Fixed Header** | ❌ 無 | ✅ 有 | 🟡 中等 |

---

### 7.2 資料差異

| 差異項 | Android | Flutter | 影響 |
|-------|---------|---------|------|
| **設備位置** | ✅ 有 | ❌ 無 | 🟡 中等 |
| **星期選擇** | ✅ 有（PumpHeadMode.runDay） | ❌ hardcode false | 🔴 重大 |
| **時間字串** | ✅ 有（PumpHeadMode.timeString） | ❌ hardcode null | 🔴 重大 |
| **模式名稱** | ✅ 有（PumpHeadMode.mode） | ⚠️ simplified `_getModeName()` | 🟡 中等 |

---

### 7.3 行為差異

| 差異項 | Android | Flutter | 影響 |
|-------|---------|---------|------|
| **進入時 BLE Sync** | ✅ 有（0x65） | ❌ 無 | 🔴 重大 |
| **Sync 完成更新 UI** | ✅ 有 | ❌ 無 | 🔴 重大 |
| **Progress 顯示** | ✅ 有 | ❌ 無 | 🟡 中等 |

---

## 審核結論

### ✅ 已確認的事實

1. **Flutter 已有 DosingMainPage 實作**（`dosing_main_page.dart`, 348 lines）
2. **Flutter 已有泵頭 Card 實作**（`DosingMainPumpHeadCard`, 對照 `adapter_drop_head.xml`）
3. **Flutter Card 結構基本對齊**（margin, elevation, padding, 標題區, 主內容區）
4. **Flutter 有 4 個泵頭 Card**（headOrder: A, B, C, D）
5. **Flutter 有播放按鈕、模式文字、星期圖標、進度條**

### ❌ 已確認的差異

#### 重大結構差異（🔴）

1. **Scrollable 範圍**：Android 整頁（ScrollView），Flutter 部分（ListView + Fixed Header）
2. **設備識別區**：Android 有（layout_device, 顯示設備名/位置/BLE），Flutter 無（分散在 AppBar）
3. **Entry Tiles**：Android 無，Flutter 有（Schedule, Manual, Calibration, History）
4. **Progress Overlay**：Android 有（gone），Flutter 無
5. **BLE Sync 行為**：Android 有（0x65 START/END），Flutter 無
6. **星期/時間資料**：Android 有（PumpHeadMode），Flutter 未實作（hardcode）

#### 中等差異（🟡）

1. **Toolbar 功能**：Flutter 比 Android 多（Favorite, PopupMenu）
2. **Fixed Header**：Android 無，Flutter 有（dosingSubHeader, dosingPumpHeadsHeader）
3. **設備位置顯示**：Android 有（tv_position），Flutter 無

### ⚠️ 需要進一步確認

1. **Android `DropMainActivity.kt` 實際 code**（setListener, setObserver, Sync 流程）
2. **Android `DropMainViewModel.kt` 實際 code**（BLE 呼叫, State 管理）
3. **Android `toolbar_device.xml` 實際結構**（確認 Toolbar 元素）
4. **Android btn_play 點擊行為**（直接滴液 or 導航）
5. **Android Entry 功能入口位置**（是否在其他頁面）
6. **Flutter `handlePlayDosing()` 實際行為**（需讀取 `dosing_main_page_helpers.dart`）

---

**審核完成，停工，等待下一步指示。**

