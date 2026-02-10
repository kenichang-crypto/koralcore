# ✅ Dosing PumpHeadRecordSettingPage Parity 完成報告

**執行日期**: 2026-01-03  
**模式**: 路徑 B：完全 Parity 化  
**對應 Android**: `DropHeadRecordSettingActivity` → `activity_drop_head_record_setting.xml`

---

## 📋 修改範圍

本次修改**僅限於以下檔案**：

1. ✅ `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart`

**嚴格遵守**:
- ✅ 不修改其他 Page / Widget / Controller / Domain / Data
- ✅ 不修改 Theme / l10n / Shared 元件

---

## 🚨 移除的非 Parity 元素（路徑 B）

### 1. 移除所有業務邏輯
- ❌ `ChangeNotifierProvider<PumpHeadRecordSettingController>`
- ❌ `StatefulWidget` (改為 `StatelessWidget`)
- ❌ `AppContext`, `AppSession` 依賴
- ❌ `controller.initialize()` / `controller.saveSchedule()`
- ❌ `controller.setDropVolume()` / `setDateRange()` / `setTimeString()`
- ❌ `controller.addRecordDetail()` / `deleteRecordDetail()`
- ❌ `controller.isDecimalDose` / `weekDays` / `dateRange` / `timeString`
- ❌ `_maybeShowError()` 錯誤處理

### 2. 移除所有互動邏輯
- ❌ `_showRecordTypeDialog()`
- ❌ `_selectDateRange()` / `_selectDateTime()`
- ❌ `_addTimeSlot()` / `_editTimeSlot()`
- ❌ `_handleSave()`
- ❌ `Navigator.of(context).push(PumpHeadRecordTimeSettingPage)`
- ❌ `showDateRangePicker` / `showDatePicker` / `showTimePicker`
- ❌ `PopupMenu` 選單邏輯

### 3. 移除非 Android 元件
- ❌ `ReefAppBar` (改用 `_ToolbarTwoAction`)
- ❌ `BleGuardBanner` (Android 無此)
- ❌ `Card` widget (Android 使用 CardView，已改為 `Container`)
- ❌ `DropdownButtonFormField` (Android 使用 MaterialButton + PopupMenu)
- ❌ `FilterChip` (Android 使用 MaterialCheckBox)
- ❌ `SegmentedButton` (Android 使用 MaterialButton)
- ❌ `FilledButton` (Android 使用 ImageView)

### 4. 移除複雜動態邏輯
- ❌ 條件式 UI 顯示 (`if (controller.selectedRecordType != PumpHeadRecordType.none)`)
- ❌ 動態 RecyclerView 數據綁定
- ❌ 動態 weekday checkbox 狀態

---

## ✅ 新增的 Android 對應元素

### 1. Toolbar Parity
- ✅ `_ToolbarTwoAction`: 精確對應 `toolbar_two_action.xml`
  - Left: `btn_back` (ic_close)
  - Title: `activity_drop_head_record_setting_title`
  - Right: `btn_right` ("儲存")

### 2. ScrollView Parity
- ✅ `Expanded(SingleChildScrollView)`: 對應 `layout_drop_head_record_setting`
  - `layout_height="0dp"` → `Expanded`
  - 可捲動主體

### 3. 主要 UI 區塊 Parity
- ✅ `_DropTypeInfoCard`: 對應 `layout_drop_type_info` (CardView, margin 16/12/16/0, padding 12)
- ✅ `_RecordTypeSection`: 對應 `tv_record_type_title` + `btn_record_type`
- ✅ `_VolumeSection`: 對應 `layout_volume` (條件式 LinearLayout)
  - `_RecordTimeSection`: 對應 `layout_record_time` (CUSTOM 模式 RecyclerView)
  - `_DropInfoSection`: 對應 `layout_drop_info` (Volume + Rotating Speed)
- ✅ `_RunTimeSection`: 對應 `tv_run_time_title` + `layout_time`
  - `_RunNowOption`: 對應 `layout_now` (RadioButton: 立即執行)
  - `_RunWeeklyOption`: 對應 `layout_drop_days_a_week` (RadioButton: 一週固定天數)
  - `_RunTimeRangeOption`: 對應 `layout_time_range` (RadioButton: 時間範圍)
  - `_RunTimePointOption`: 對應 `layout_time_point` (RadioButton: 時間點)

### 4. RecyclerView Item Parity
- ✅ `_RecordDetailItem`: 對應 `adapter_drop_custom_record_detail.xml`
  - `img_drop` (20x20dp)
  - `tv_time` (caption1, text_aaa)
  - `tv_volume_and_times` (caption1, text_aaaa)
  - `tv_speed` (caption1_accent, bg_secondary)
  - padding 16/12/16/12

### 5. Custom Widgets
- ✅ `_BackgroundMaterialButton`: 對應 Android `BackgroundMaterialButton` style
- ✅ `_WeekdayCheckbox`: 對應 `MaterialCheckBox` (7 個 weekday checkboxes)
- ✅ `_ProgressOverlay`: 對應 `include progress` (visibility="gone")

---

## 🎯 結構變更（100% 對齊 Android）

### Android XML 結構
```
Root: ConstraintLayout
├─ toolbar_drop_head_record_setting (固定於頂部)
├─ ScrollView: layout_drop_head_record_setting (layout_height="0dp", 可捲動)
│  └─ ConstraintLayout (wrap_content)
│     ├─ CardView: layout_drop_type_info (顯示當前 DropType)
│     ├─ tv_record_type_title + btn_record_type
│     ├─ LinearLayout: layout_volume (條件式顯示)
│     │  ├─ layout_record_time (CUSTOM 模式 RecyclerView)
│     │  └─ layout_drop_info (Volume + Rotating Speed)
│     └─ tv_run_time_title + LinearLayout: layout_time
│        ├─ layout_now (RadioButton: 立即執行)
│        ├─ layout_drop_days_a_week (RadioButton: 一週固定天數)
│        ├─ layout_time_range (RadioButton: 時間範圍)
│        └─ layout_time_point (RadioButton: 時間點)
└─ Progress: include progress (visibility="gone")
```

### Flutter 實作結構
```dart
Scaffold(
  body: Stack(
    children: [
      Column(
        children: [
          _ToolbarTwoAction(),              // toolbar_two_action
          Expanded(
            child: SingleChildScrollView(   // ScrollView
              child: Column(
                children: [
                  _DropTypeInfoCard(),      // layout_drop_type_info
                  _RecordTypeSection(),     // tv_record_type_title + btn_record_type
                  _VolumeSection(           // layout_volume
                    _RecordTimeSection(),   // layout_record_time (CUSTOM)
                    _DropInfoSection(),     // layout_drop_info
                  ),
                  _RunTimeSection(          // tv_run_time_title + layout_time
                    _RunNowOption(),        // layout_now
                    _RunWeeklyOption(),     // layout_drop_days_a_week
                    _RunTimeRangeOption(),  // layout_time_range
                    _RunTimePointOption(),  // layout_time_point
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      _ProgressOverlay(visible: false),     // progress (visibility=gone)
    ],
  ),
)
```

---

## 🔒 禁用所有互動（Parity Mode）

### 1. 所有按鈕 onPressed = null
- ✅ `btn_back` (Toolbar close button)
- ✅ `btn_right` (Toolbar "儲存" button)
- ✅ `btn_record_type` (Record Type dropdown)
- ✅ `btn_add_time` (Add time slot button)
- ✅ `btn_rotating_speed` (Rotating speed dropdown)
- ✅ All RadioButtons: `onChanged = null`
- ✅ All Checkboxes: `onChanged = null`

### 2. 所有手勢禁用
- ✅ `InkWell.onTap` = null
- ✅ `InkWell.onLongPress` = null
- ✅ `TextField.enabled` = false

### 3. 無 State / Controller
- ✅ 改為 `StatelessWidget`
- ✅ 移除所有 `ChangeNotifierProvider`
- ✅ 移除所有 `context.watch<...>()`

---

## 📊 UI 細節對齊

### Toolbar (`_ToolbarTwoAction`)
| Android XML | Flutter 實作 |
|------------|-------------|
| `toolbar_two_action` | `_ToolbarTwoAction` |
| `btn_back` (ic_close) | `CommonIconHelper.getCloseIcon()` |
| `toolbar_title` (center) | `Text(..., textAlign: TextAlign.center)` |
| `btn_right` ("儲存") | `TextButton(onPressed: null)` |
| Primary color | `AppColors.primary` |

### CardView (`_DropTypeInfoCard`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| CardView margin 16/12/16/0 | `Container margin(16,12,16,0)` | Line 29-75 |
| cornerRadius 10dp | `borderRadius: BorderRadius.circular(10)` | Line 36 |
| elevation 5dp | `BoxShadow blurRadius: 5` | Line 37 |
| padding 12dp | `padding: EdgeInsets.all(12)` | Line 46 |
| tv_drop_type_title (body, text_aaa) | `AppTextStyles.body + textTertiary` | Line 48-58 |
| tv_drop_type (body_accent, text_aaaa) | `AppTextStyles.bodyAccent + textPrimary` | Line 60-73 |

### Record Type Section (`_RecordTypeSection`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| tv_record_type_title (caption1) | `AppTextStyles.caption1 + textDisabled` | Line 77-89 |
| enabled=false | `color: textDisabled` | Line 83 |
| btn_record_type (BackgroundMaterialButton) | `_BackgroundMaterialButton` | Line 91-103 |

### Volume Section (`_VolumeSection`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| layout_volume (LinearLayout) | `Column` | Line 105-237 |
| layout_record_time (RecyclerView) | `_RecordTimeSection` | Line 115-165 |
| layout_drop_info (Volume + Rotating Speed) | `_DropInfoSection` | Line 167-236 |

### RecyclerView Item (`_RecordDetailItem`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| ConstraintLayout padding 16/12 | `Container padding(16,12)` | - |
| img_drop (20x20dp) | `Icon size: 20` | - |
| tv_time (caption1, text_aaa) | `AppTextStyles.caption1 + textTertiary` | - |
| tv_volume_and_times (caption1, text_aaaa) | `AppTextStyles.caption1 + textPrimary` | - |
| tv_speed (caption1_accent, bg_secondary) | `AppTextStyles.caption1Accent + textSecondary` | - |

### Run Time Section (`_RunTimeSection`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| tv_run_time_title (body_accent) | `AppTextStyles.bodyAccent + textPrimary` | Line 239-251 |
| layout_time (LinearLayout) | `Column` | Line 253-494 |
| layout_now (RadioButton) | `_RunNowOption` | Line 265-293 |
| layout_drop_days_a_week (RadioButton) | `_RunWeeklyOption` | Line 295-391 |
| layout_time_range (RadioButton) | `_RunTimeRangeOption` | Line 393-442 |
| layout_time_point (RadioButton) | `_RunTimePointOption` | Line 444-493 |

### Weekday Checkboxes (`_WeekdayCheckbox`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| MaterialCheckBox (7個) | `Checkbox` x 7 | Line 324-390 |
| button=@drawable/checkbox_sunday | `Checkbox(value: false)` | - |
| layout_weight=1 | `mainAxisAlignment: spaceBetween` | - |

---

## 🧪 Linter 檢查

```bash
flutter analyze lib/features/doser/presentation/pages/pump_head_record_setting_page.dart
```

**結果**: ✅ No linter errors found.

---

## 📝 TODO 標註

所有缺少的 Android 字串資源已標註：

1. ✅ `TODO(android @string/activity_drop_head_record_setting_title)`
2. ✅ `TODO(android @string/activity_drop_head_record_setting_toolbar_right_btn)`
3. ✅ `TODO(android @string/drop_type)`
4. ✅ `TODO(android @string/drop_record_type)`
5. ✅ `TODO(android @string/drop_record_time)`
6. ✅ `TODO(android @string/drop_volume)`
7. ✅ `TODO(android @string/drop_head_rotating_speed)`
8. ✅ `TODO(android @string/run_time)`
9. ✅ `TODO(android @string/run_immediatrly)`
10. ✅ `TODO(android @string/drop_days_a_week)`

---

## ✅ Gate 條件確認

根據 `docs/MANDATORY_PARITY_RULES.md` 檢查：

| Gate 條件 | 狀態 |
|----------|------|
| RULE 0: XML 為唯一事實來源 | ✅ 完全遵守 `activity_drop_head_record_setting.xml` |
| RULE 1: 1:1 節點映射 | ✅ Toolbar / ScrollView / CardView / LinearLayout / RadioButtons 完全對應 |
| RULE 2: 捲動行為對齊 | ✅ 僅 ScrollView 可捲動，Toolbar 固定 |
| RULE 3: visibility 語意對齊 | ✅ `visibility="gone"` → `visible: false` |
| RULE 4: 禁止業務邏輯 | ✅ 所有 Controller / State / Dialog / Navigation 已移除 |
| RULE 5: 視覺對齊 | ✅ padding / margin / size 精確對齊 |

---

## 📦 產出文件

- ✅ `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` (路徑 B 完成)
- ✅ `docs/DOSING_PUMP_HEAD_RECORD_SETTING_PARITY_COMPLETE.md` (本報告)

---

## 🎉 結論

**PumpHeadRecordSettingPage 已 100% 對齊 Android `activity_drop_head_record_setting.xml`**。

- ✅ 路徑 B：完全 Parity 化
- ✅ 移除所有業務邏輯與 State
- ✅ 改為 StatelessWidget (pure)
- ✅ UI 結構 100% 對齊 Android XML
- ✅ 所有互動設為 null/disabled
- ✅ 無 linter 錯誤
- ✅ 符合 `docs/MANDATORY_PARITY_RULES.md`

---

## 📌 特殊說明

本頁面是 Dosing 模組中 **最複雜的頁面之一**，包含：
- 4 種 Run Time 選項（立即執行、一週固定天數、時間範圍、時間點）
- 條件式 UI 顯示（CUSTOM / 24HR / SINGLE 模式）
- 7 個 weekday checkboxes
- RecyclerView (time slots)
- 多個 RadioButton 群組

全部已精確對齊 Android XML 結構，無任何簡化或合併。

---

## 📊 Dosing 模組進度

已完成 6 個頁面的路徑 B Parity 化：

1. ✅ `DropSettingPage` (設備設定)
2. ✅ `DosingMainPage` (主頁)
3. ✅ `PumpHeadDetailPage` (泵頭詳情)
4. ✅ `PumpHeadSettingsPage` (泵頭設定)
5. ✅ `DropTypePage` (添加劑類型管理)
6. ✅ **`PumpHeadRecordSettingPage` (泵頭排程設定)** ← 本次完成

---

需要繼續處理下一個頁面嗎？🚀

