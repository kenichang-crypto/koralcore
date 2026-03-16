# ✅ Dosing PumpHeadRecordTimeSettingPage Parity 完成報告

**執行日期**: 2026-01-03  
**模式**: 路徑 B：完全 Parity 化  
**對應 Android**: `DropHeadRecordTimeSettingActivity` → `activity_drop_head_record_time_setting.xml`

---

## 📋 修改範圍

本次修改**僅限於以下檔案**：

1. ✅ `lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart`

**嚴格遵守**:
- ✅ 不修改其他 Page / Widget / Controller / Domain / Data
- ✅ 不修改 Theme / l10n / Shared 元件

---

## 🚨 移除的非 Parity 元素（路徑 B）

### 1. 移除所有業務邏輯
- ❌ `ChangeNotifierProvider<PumpHeadRecordTimeSettingController>`
- ❌ `StatefulWidget` (改為 `StatelessWidget`)
- ❌ `AppSession` 依賴
- ❌ `controller.initialize()` / `controller.save()`
- ❌ `controller.setStartTime()` / `setEndTime()` / `setDropTimes()` / `setDropVolume()` / `setRotatingSpeed()`
- ❌ `controller.startTime` / `endTime` / `dropTimes` / `dropVolume` / `rotatingSpeed`
- ❌ `controller.isDecimalDose` 判斷邏輯
- ❌ `_maybeShowError()` 錯誤處理

### 2. 移除所有互動邏輯
- ❌ `_selectStartTime()` / `_selectEndTime()` (showTimePicker)
- ❌ `_handleSave()` (保存並回傳 PumpHeadRecordDetail)
- ❌ `Navigator.of(context).pop(detail)` 導航邏輯
- ❌ `DropdownButtonFormField` 下拉選單
- ❌ `TextField.onChanged` 輸入監聽
- ❌ `SegmentedButton.onSelectionChanged` 選擇監聽

### 3. 移除非 Android 元件
- ❌ `ReefAppBar` (改用 `_ToolbarTwoAction`)
- ❌ `BleGuardBanner` (Android 無此)
- ❌ `Card` widget (Android 無 CardView)
- ❌ `OutlinedButton` (Android 使用 MaterialButton + PopupMenu)
- ❌ `DropdownButtonFormField` (Android 使用 MaterialButton + PopupMenu)
- ❌ `SegmentedButton` (Android 使用 MaterialButton + PopupMenu)
- ❌ `ListView` (Android 為固定高度 ConstraintLayout，不可捲動)

---

## ✅ 新增的 Android 對應元素

### 1. Toolbar Parity
- ✅ `_ToolbarTwoAction`: 精確對應 `toolbar_two_action.xml`
  - Left: `btn_back` (ic_close)
  - Title: `activity_drop_head_record_time_setting_title`
  - Right: `btn_right` ("儲存")

### 2. Main Content Parity (固定高度，不可捲動)
- ✅ `Expanded(Padding(Column))`: 對應 `layout_drop_head_record_time_setting`
  - `layout_height="0dp"` → `Expanded`
  - margin 16/12/16/12 (Line 20-23)
  - **不可捲動** (Android 為固定 ConstraintLayout)

### 3. Form Fields Parity
- ✅ `tv_start_time_title` + `btn_start_time`: Start Time 選擇
- ✅ `tv_end_time_title` + `btn_end_time`: End Time 選擇 (marginTop 16dp)
- ✅ `tv_drop_times_title` + `btn_drop_times`: Drop Times 選擇 (marginTop 16dp)
- ✅ `tv_drop_volume_title` + `layout_drop_volume`: Drop Volume 輸入 (TextInputLayout, marginTop 16dp)
- ✅ `tv_rotating_speed_title` + `btn_rotating_speed`: Rotating Speed 選擇 (marginTop 16dp, enabled=false)

### 4. Custom Widgets
- ✅ `_BackgroundMaterialButton`: 對應 Android `BackgroundMaterialButton` style
- ✅ `_ProgressOverlay`: 對應 `include progress` (visibility="gone")

---

## 🎯 結構變更（100% 對齊 Android）

### Android XML 結構
```
Root: ConstraintLayout
├─ toolbar_drop_head_record_time_setting (固定於頂部)
├─ ConstraintLayout: layout_drop_head_record_time_setting (layout_height="0dp", 固定高度，不可捲動, margin 16/12/16/12)
│  ├─ tv_start_time_title + btn_start_time
│  ├─ tv_end_time_title + btn_end_time (marginTop 16dp)
│  ├─ tv_drop_times_title + btn_drop_times (marginTop 16dp)
│  ├─ tv_drop_volume_title + layout_drop_volume (TextInputLayout, marginTop 16dp)
│  └─ tv_rotating_speed_title + btn_rotating_speed (marginTop 16dp, enabled=false)
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
            child: Padding(                 // margin 16/12/16/12
              padding: EdgeInsets.only(...),
              child: Column(                // 固定高度，不可捲動
                children: [
                  Text(...) + _BackgroundMaterialButton(...), // Start Time
                  SizedBox(height: 16),
                  Text(...) + _BackgroundMaterialButton(...), // End Time
                  SizedBox(height: 16),
                  Text(...) + _BackgroundMaterialButton(...), // Drop Times
                  SizedBox(height: 16),
                  Text(...) + TextField(...), // Drop Volume
                  SizedBox(height: 16),
                  Text(...) + _BackgroundMaterialButton(...), // Rotating Speed
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
- ✅ `btn_start_time` (Start Time button)
- ✅ `btn_end_time` (End Time button)
- ✅ `btn_drop_times` (Drop Times button)
- ✅ `btn_rotating_speed` (Rotating Speed button)

### 2. 所有輸入禁用
- ✅ `TextField.enabled` = false (Drop Volume input)

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

### Main Content (固定高度，不可捲動)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| ConstraintLayout layout_height="0dp" | `Expanded(Padding(Column))` | Line 16-170 |
| margin 16/12/16/12 | `padding: EdgeInsets.only(16,12,16,12)` | Line 20-23 |
| **不可捲動** | `Column` (no ScrollView) | - |

### Form Fields
| Android XML | Flutter 實作 | 行號 | 備註 |
|------------|-------------|------|------|
| tv_start_time_title (caption1) | `AppTextStyles.caption1 + textSecondary` | Line 29-39 | - |
| btn_start_time (BackgroundMaterialButton) | `_BackgroundMaterialButton` | Line 41-53 | marginTop 4dp |
| tv_end_time_title (caption1) | `AppTextStyles.caption1 + textSecondary` | Line 55-66 | marginTop 16dp |
| btn_end_time (BackgroundMaterialButton) | `_BackgroundMaterialButton` | Line 68-80 | marginTop 4dp |
| tv_drop_times_title (caption1) | `AppTextStyles.caption1 + textSecondary` | Line 82-93 | marginTop 16dp |
| btn_drop_times (BackgroundMaterialButton) | `_BackgroundMaterialButton` | Line 95-107 | marginTop 4dp |
| tv_drop_volume_title (caption1) | `AppTextStyles.caption1 + textPrimary` | Line 109-121 | marginTop 16dp |
| layout_drop_volume (TextInputLayout) | `TextField(enabled: false)` | Line 123-142 | marginTop 4dp |
| tv_rotating_speed_title (caption1, enabled=false) | `AppTextStyles.caption1 + textDisabled` | Line 144-156 | marginTop 16dp |
| btn_rotating_speed (BackgroundMaterialButton) | `_BackgroundMaterialButton` | Line 158-169 | marginTop 4dp |

### BackgroundMaterialButton (`_BackgroundMaterialButton`)
| Android XML | Flutter 實作 |
|------------|-------------|
| BackgroundMaterialButton style | `_BackgroundMaterialButton` |
| bg_aaa background | `AppColors.surfaceMuted` |
| textAlignment=textStart | `textAlign: TextAlign.start` |
| icon=@drawable/ic_down | `LedRecordIconHelper.getDownIcon()` |
| padding 16/12 | `padding: EdgeInsets.symmetric(16, 12)` |

---

## 🧪 Linter 檢查

```bash
flutter analyze lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart
```

**結果**: ✅ No linter errors found.

---

## 📝 TODO 標註

所有缺少的 Android 字串資源已標註：

1. ✅ `TODO(android @string/activity_drop_head_record_time_setting_title)`
2. ✅ `TODO(android @string/activity_drop_head_record_time_setting_toolbar_right_btn)`
3. ✅ `TODO(android @string/drop_start_time)`
4. ✅ `TODO(android @string/drop_end_time)`
5. ✅ `TODO(android @string/drop_times)`
6. ✅ `TODO(android @string/drop_volume)`
7. ✅ `TODO(android @string/drop_head_rotating_speed)`

---

## ✅ Gate 條件確認

根據 `docs/MANDATORY_PARITY_RULES.md` 檢查：

| Gate 條件 | 狀態 |
|----------|------|
| RULE 0: XML 為唯一事實來源 | ✅ 完全遵守 `activity_drop_head_record_time_setting.xml` |
| RULE 1: 1:1 節點映射 | ✅ Toolbar / ConstraintLayout / 5 組 title+button 完全對應 |
| RULE 2: 捲動行為對齊 | ✅ **不可捲動**（Android 為固定 ConstraintLayout） |
| RULE 3: visibility 語意對齊 | ✅ `visibility="gone"` → `visible: false`, `enabled=false` → `color: textDisabled` |
| RULE 4: 禁止業務邏輯 | ✅ 所有 Controller / State / Dialog / TimePicker 已移除 |
| RULE 5: 視覺對齊 | ✅ padding / margin / size 精確對齊 |

---

## 📦 產出文件

- ✅ `lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart` (路徑 B 完成)
- ✅ `docs/DOSING_PUMP_HEAD_RECORD_TIME_SETTING_PARITY_COMPLETE.md` (本報告)

---

## 🎉 結論

**PumpHeadRecordTimeSettingPage 已 100% 對齊 Android `activity_drop_head_record_time_setting.xml`**。

- ✅ 路徑 B：完全 Parity 化
- ✅ 移除所有業務邏輯與 State
- ✅ 改為 StatelessWidget (pure)
- ✅ UI 結構 100% 對齊 Android XML
- ✅ 所有互動設為 null/disabled
- ✅ 無 linter 錯誤
- ✅ 符合 `docs/MANDATORY_PARITY_RULES.md`

---

## 📌 特殊說明

### 🔍 重要 Parity 細節

1. **不可捲動 (Non-scrollable)**:
   - Android: `ConstraintLayout` with `layout_height="0dp"` (固定高度)
   - Flutter: `Expanded(Padding(Column))` **without** `SingleChildScrollView`
   - ✅ 完全對齊：Main Content 為固定高度，不可捲動

2. **enabled=false**:
   - Android: `tv_rotating_speed_title` has `android:enabled="false"` (Line 150)
   - Flutter: `color: AppColors.textDisabled`
   - ✅ 視覺對齊：disabled 狀態使用 textDisabled 顏色

3. **margin 對齊**:
   - Android: margin 16/12/16/12 (Line 20-23)
   - Flutter: `padding: EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12)`
   - ✅ 完全對齊

4. **所有 marginTop 16dp**:
   - Android: 每個 section 之間的間距都是 16dp (Line 60, 87, 114, 149)
   - Flutter: `const SizedBox(height: 16)`
   - ✅ 完全對齊

---

## 📊 Dosing 模組進度

已完成 7 個頁面的路徑 B Parity 化：

1. ✅ `DropSettingPage` (設備設定)
2. ✅ `DosingMainPage` (主頁)
3. ✅ `PumpHeadDetailPage` (泵頭詳情)
4. ✅ `PumpHeadSettingsPage` (泵頭設定)
5. ✅ `DropTypePage` (添加劑類型管理)
6. ✅ `PumpHeadRecordSettingPage` (泵頭排程設定)
7. ✅ **`PumpHeadRecordTimeSettingPage` (泵頭排程時間設定)** ← 本次完成

---

需要繼續處理下一個頁面嗎？🚀

