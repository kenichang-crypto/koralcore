# L2 尺寸修正執行計劃

## 修正策略

由於涉及 30+ 個頁面，採用以下策略：

### 階段 1：Shared Widgets（已完成）
- ✅ `ReefIconButton` (44dp)
- ✅ `ReefTextButton` (44dp)

### 階段 2：優先修正（批量替換）
替換所有使用 **自訂 Toolbar** 的頁面（Parity Mode 頁面）：

**Dosing 模組**:
1. `dosing_main_page.dart` - `_ToolbarDevice` 內的 IconButton
2. `drop_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
3. `pump_head_detail_page.dart` - `_ToolbarDevice` 內的 IconButton
4. `pump_head_settings_page.dart` - `_ToolbarTwoAction` 內的 IconButton
5. `drop_type_page.dart` - `_ToolbarTwoAction` 內的 IconButton
6. `pump_head_record_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
7. `pump_head_record_time_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
8. `pump_head_adjust_list_page.dart` - `_ToolbarTwoAction` 內的 IconButton
9. `pump_head_calibration_page.dart` - `_ToolbarTwoAction` 內的 IconButton

**LED 模組**:
10. `led_main_page.dart` - `_ToolbarDevice` 內的按鈕（已是 44dp，無需修改）
11. `led_record_page.dart` - `_ToolbarTwoAction` 內的 IconButton
12. `led_record_time_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
13. `led_record_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
14. `led_master_setting_page.dart` - `_ToolbarTwoAction` 內的 IconButton
15. `led_scene_list_page.dart` - `_ToolbarTwoAction` 內的 IconButton
16. `led_scene_add_page.dart` - `_ToolbarTwoAction` 內的 IconButton
17. `led_scene_edit_page.dart` - `_ToolbarTwoAction` 內的 IconButton
18. `led_scene_delete_page.dart` - `_ToolbarTwoAction` 內的 IconButton

**其他模組**:
19. `sink_manager_page.dart` - `_ToolbarTwoAction` 內的 IconButton
20. `sink_position_page.dart` - `_ToolbarTwoAction` 內的 IconButton
21. `add_device_page.dart` - `_ToolbarTwoAction` 內的 IconButton

### 階段 3：使用 ReefAppBar 的頁面
替換所有使用 `ReefAppBar` 的頁面（需修改 ReefAppBar 內部實作）：

- `warning_page.dart`
- `manual_dosing_page.dart`
- `schedule_edit_page.dart`
- `home_tab_page.dart`
- `bluetooth_tab_page.dart`
- `device_tab_page.dart`

### 階段 4：修改 ReefAppBar 內部
修改 `ReefAppBar` 預設使用 `ReefIconButton`。

## 批量替換規則

### 規則 1：Toolbar 內的 IconButton
```dart
// ❌ Before
IconButton(
  icon: CommonIconHelper.getBackIcon(size: 24),
  onPressed: null,
)

// ✅ After
ReefIconButton(
  icon: CommonIconHelper.getBackIcon(size: 24),
  onPressed: null,
)
```

### 規則 2：Toolbar 內的 TextButton（右側文字按鈕）
```dart
// ❌ Before
TextButton(
  onPressed: null,
  child: Text('儲存', style: ...),
)

// ✅ After
ReefTextButton(
  onPressed: null,
  child: Text('儲存', style: ...),
)
```

### 規則 3：非 Toolbar 的 IconButton
保持不變（這些按鈕不受 44dp 限制）。

## 執行順序

1. ✅ P1: 補充 AppSpacing 關鍵尺寸
2. ✅ P0: 創建 ReefIconButton / ReefTextButton
3. ⏳ P0: 批量替換階段 2（Parity Mode 頁面）
4. ⏳ P0: 修改 ReefAppBar 內部（階段 4）
5. ⏳ P2: 補充 Android dimens 標註
6. ⏳ P2: 統一 BorderRadius 使用

## 預估工作量

- 階段 2：21 個頁面，每頁約 2-5 個 IconButton → **約 60+ 處替換**
- 階段 3：6 個頁面（通過 ReefAppBar 統一修改）
- 階段 4：1 個 Shared Widget 修改

**總計**: 約 **70+ 處修改**

