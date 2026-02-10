# ✅ Dosing PumpHeadAdjustListPage Parity 完成報告

**執行日期**: 2026-01-03  
**模式**: 路徑 B：完全 Parity 化  
**對應 Android**: `DropHeadAdjustListActivity` → `activity_drop_head_adjust_list.xml`

---

## 📋 修改範圍

本次修改**僅限於以下檔案**：

1. ✅ `lib/features/doser/presentation/pages/pump_head_adjust_list_page.dart`

**嚴格遵守**:
- ✅ 不修改其他 Page / Widget / Controller / Domain / Data
- ✅ 不修改 Theme / l10n / Shared 元件

---

## 🚨 移除的非 Parity 元素（路徑 B）

### 1. 移除所有業務邏輯
- ❌ `ChangeNotifierProvider<PumpHeadCalibrationController>`
- ❌ `StatelessWidget` 內的業務邏輯
- ❌ `AppContext`, `AppSession` 依賴
- ❌ `controller.refresh()` / `controller.records` / `controller.isLoading`
- ❌ `controller.lastErrorCode` 錯誤處理
- ❌ `_maybeShowError()` 方法

### 2. 移除所有互動邏輯
- ❌ `Navigator.of(context).pop()` 返回邏輯
- ❌ `Navigator.of(context).push(PumpHeadAdjustPage)` 導航邏輯
- ❌ `RefreshIndicator` 下拉刷新
- ❌ `ListView.builder` 動態列表綁定
- ❌ `IconButton` refresh / reset 按鈕互動

### 3. 移除非 Android 元件
- ❌ `ReefAppBar` (改用 `_ToolbarTwoAction`)
- ❌ `BleGuardBanner` (Android 無此)
- ❌ `LoadingStateWidget` (Android 使用 Progress overlay)
- ❌ `EmptyStateWidget` (Android 無 empty state)
- ❌ `ErrorStateWidget` (Android 無 error state)
- ❌ `RefreshIndicator` (Android 無下拉刷新)

### 4. 移除複雜數據綁定
- ❌ `PumpHeadCalibrationRecord` 數據綁定
- ❌ `_speedProfileToInt()` 轉換邏輯
- ❌ `DateFormat` 日期格式化
- ❌ 動態 item 數量 (`itemCount: controller.records.length`)

---

## ✅ 新增的 Android 對應元素

### 1. Toolbar Parity
- ✅ `_ToolbarTwoAction`: 精確對應 `toolbar_two_action.xml`
  - Left: `btn_back`
  - Title: `activity_drop_head_adjust_list_title`
  - Right: `btn_right` ("開始校準")

### 2. RecyclerView Parity
- ✅ `Expanded(ListView)`: 對應 `rv_adjust`
  - `layout_height="0dp"` → `Expanded`
  - padding 16/8/16/8 (Line 20-23)
  - `clipToPadding="false"` → no impact on Flutter (default behavior)
  - background `@color/bg_aaa` → `Scaffold backgroundColor: AppColors.surfaceMuted`

### 3. Adapter Item Parity
- ✅ `_AdjustHistoryItem`: 對應 `adapter_adjust.xml`
  - ConstraintLayout → `Container`
  - background_white_radius → `BoxDecoration(borderRadius: 8, color: surface)`
  - padding 12dp → `padding: EdgeInsets.all(12)`
  - margin 4/4 top/bottom → `margin: EdgeInsets.only(top: 4, bottom: 4)`
  - 3 rows (Speed / Date / Volume) → `Column` with 3 `Row`s
  - Each row: title (caption1_accent, text_aaa) + value (caption1)

### 4. Progress Overlay Parity
- ✅ `_ProgressOverlay`: 對應 `include progress` (visibility="gone")

---

## 🎯 結構變更（100% 對齊 Android）

### Android XML 結構
```
Root: ConstraintLayout
├─ toolbar_drop_head_adjust_list (固定於頂部)
├─ RecyclerView: rv_adjust (layout_height="0dp", 可捲動, padding 16/8/16/8, clipToPadding=false)
│  └─ adapter_adjust.xml (item structure)
└─ Progress: include progress (visibility="gone")
```

### Flutter 實作結構
```dart
Scaffold(
  backgroundColor: AppColors.surfaceMuted, // bg_aaa
  body: Stack(
    children: [
      Column(
        children: [
          _ToolbarTwoAction(),              // toolbar_two_action
          Expanded(
            child: ListView(                // rv_adjust
              padding: EdgeInsets.only(16,8,16,8),
              children: [
                _AdjustHistoryItem(),       // adapter_adjust.xml x3 (placeholder)
                _AdjustHistoryItem(),
                _AdjustHistoryItem(),
              ],
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
- ✅ `btn_back` (Toolbar back button)
- ✅ `btn_right` (Toolbar "開始校準" button)
- ✅ 移除 `IconButton` refresh button (Flutter 有，Android 無)

### 2. 移除所有手勢
- ✅ 移除 `RefreshIndicator.onRefresh`
- ✅ 移除 `Navigator.pop/push` 邏輯

### 3. 無 State / Controller
- ✅ 改為 pure `StatelessWidget`
- ✅ 移除所有 `ChangeNotifierProvider`
- ✅ 移除所有 `context.watch<...>()`

---

## 📊 UI 細節對齊

### Toolbar (`_ToolbarTwoAction`)
| Android XML | Flutter 實作 |
|------------|-------------|
| `toolbar_two_action` | `_ToolbarTwoAction` |
| `btn_back` | `CommonIconHelper.getBackIcon()` |
| `toolbar_title` (center) | `Text(..., textAlign: TextAlign.center)` |
| `btn_right` ("開始校準") | `TextButton(onPressed: null)` |
| Primary color | `AppColors.primary` |

### RecyclerView (`rv_adjust`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| RecyclerView layout_height="0dp" | `Expanded(ListView)` | Line 15-29 |
| paddingStart/End 16dp | `padding: EdgeInsets.only(left: 16, right: 16)` | Line 21-22 |
| paddingTop/Bottom 8dp | `padding: EdgeInsets.only(top: 8, bottom: 8)` | Line 20, 23 |
| clipToPadding=false | (Flutter default behavior) | Line 19 |
| background bg_aaa | `Scaffold backgroundColor: AppColors.surfaceMuted` | Line 24 |

### Adapter Item (`_AdjustHistoryItem`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| ConstraintLayout | `Container` | - |
| background_white_radius | `BoxDecoration(borderRadius: 8, color: surface)` | - |
| padding 12dp | `padding: EdgeInsets.all(12)` | - |
| margin 4/4 top/bottom | `margin: EdgeInsets.only(top: 4, bottom: 4)` | - |
| tv_speed_title (caption1_accent, text_aaa) | `AppTextStyles.caption1Accent + textTertiary` | - |
| tv_speed (caption1, bg_secondary) | `AppTextStyles.caption1 + textSecondary` | - |
| tv_date_title (caption1_accent, text_aaa) | `AppTextStyles.caption1Accent + textTertiary` | - |
| tv_date (caption1) | `AppTextStyles.caption1 + textPrimary` | - |
| tv_volume_title (caption1_accent, text_aaa) | `AppTextStyles.caption1Accent + textTertiary` | - |
| tv_volume (caption1) | `AppTextStyles.caption1 + textPrimary` | - |

---

## 🧪 Linter 檢查

```bash
flutter analyze lib/features/doser/presentation/pages/pump_head_adjust_list_page.dart
```

**結果**: ✅ No linter errors found.

---

## 📝 TODO 標註

所有缺少的 Android 字串資源已標註：

1. ✅ `TODO(android @string/activity_drop_head_adjust_list_title)`
2. ✅ `TODO(android @string/activity_drop_head_adjust_list_toolbar_right_btn)`
3. ✅ `TODO(android @string/rotating_speed)`
4. ✅ `TODO(android @string/date)`
5. ✅ `TODO(android @string/volume)`

---

## ✅ Gate 條件確認

根據 `docs/MANDATORY_PARITY_RULES.md` 檢查：

| Gate 條件 | 狀態 |
|----------|------|
| RULE 0: XML 為唯一事實來源 | ✅ 完全遵守 `activity_drop_head_adjust_list.xml` |
| RULE 1: 1:1 節點映射 | ✅ Toolbar / RecyclerView / adapter_adjust.xml 完全對應 |
| RULE 2: 捲動行為對齊 | ✅ 僅 RecyclerView 可捲動，Toolbar 固定 |
| RULE 3: visibility 語意對齊 | ✅ `visibility="gone"` → `visible: false` |
| RULE 4: 禁止業務邏輯 | ✅ 所有 Controller / State / Navigation 已移除 |
| RULE 5: 視覺對齊 | ✅ padding / margin / size 精確對齊 |

---

## 📦 產出文件

- ✅ `lib/features/doser/presentation/pages/pump_head_adjust_list_page.dart` (路徑 B 完成)
- ✅ `docs/DOSING_PUMP_HEAD_ADJUST_LIST_PARITY_COMPLETE.md` (本報告)

---

## 🎉 結論

**PumpHeadAdjustListPage 已 100% 對齊 Android `activity_drop_head_adjust_list.xml`**。

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

1. **RecyclerView padding**:
   - Android: `paddingStart/End="16dp"`, `paddingTop/Bottom="8dp"`, `clipToPadding="false"` (Line 19-23)
   - Flutter: `padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8)`
   - ✅ 完全對齊

2. **adapter_adjust.xml 結構**:
   - Android: 3 rows (Speed / Date / Volume), 每個 row 有 title + value
   - Flutter: `Column` with 3 `Row`s, 每個 row 有 title `Text` + value `Text`
   - ✅ 完全對齊

3. **background_white_radius**:
   - Android: `@drawable/background_white_radius`
   - Flutter: `BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.surface)`
   - ✅ 完全對齊

4. **margin 4/4**:
   - Android: margin top/bottom 4dp
   - Flutter: `margin: EdgeInsets.only(top: 4, bottom: 4)`
   - ✅ 完全對齊

---

## 📊 Dosing 模組進度

已完成 8 個頁面的路徑 B Parity 化：

1. ✅ `DropSettingPage` (設備設定)
2. ✅ `DosingMainPage` (主頁)
3. ✅ `PumpHeadDetailPage` (泵頭詳情)
4. ✅ `PumpHeadSettingsPage` (泵頭設定)
5. ✅ `DropTypePage` (添加劑類型管理)
6. ✅ `PumpHeadRecordSettingPage` (泵頭排程設定)
7. ✅ `PumpHeadRecordTimeSettingPage` (泵頭排程時間設定)
8. ✅ **`PumpHeadAdjustListPage` (泵頭校準歷史列表)** ← 本次完成

---

需要繼續處理下一個頁面嗎？🚀

