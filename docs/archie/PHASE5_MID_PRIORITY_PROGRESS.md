# Phase 5 中優先級頁面更新進度

## 已完成更新

### LED 相關頁面
- ✅ `led_main_page.dart`
  - 使用 `InlineErrorMessage` 替換 `_buildInlineErrorMessage`
  - 使用 `LoadingStateWidget.center()` 替換 `CircularProgressIndicator`

- ✅ `led_control_page.dart`
  - 使用 `showErrorSnackBar` 替換 `_maybeShowError`
  - 使用 `LoadingStateWidget.center()` 替換 `CircularProgressIndicator`

### Dosing 相關頁面
- ✅ `pump_head_adjust_list_page.dart`
  - 使用 `showErrorSnackBar` 替換 `_maybeShowError`
  - 使用 `LoadingStateWidget.center()` 替換 `CircularProgressIndicator`
  - 使用 `EmptyStateWidget` 替換 `_EmptyState`

- ✅ `pump_head_calibration_page.dart`
  - 使用 `showErrorSnackBar` 替換 `_maybeShowCalibrationError`
  - 使用 `LoadingStateWidget.center()` 替換 `CircularProgressIndicator`
  - 使用 `EmptyStateCard` 替換 `_CalibrationEmptyState`

- ✅ `led_record_page.dart`
  - 使用 `showErrorSnackBar` 替換 `_maybeShowError` 中的手動 SnackBar
  - 使用 `LoadingStateWidget.inline()` 替換 `CircularProgressIndicator`

- ✅ `led_scene_list_page.dart`
  - 使用 `showErrorSnackBar` 和 `showSuccessSnackBar` 替換 `_maybeShowError` 和 `_maybeShowEvent`
  - 使用 `LoadingStateWidget.linear()` 和 `LoadingStateWidget.inline()` 替換 `LinearProgressIndicator` 和 `CircularProgressIndicator`

- ✅ `led_schedule_list_page.dart`
  - 使用 `showErrorSnackBar` 和 `showSuccessSnackBar` 替換 `_maybeShowError` 和 `_maybeShowEvent`
  - 使用 `LoadingStateWidget.linear()` 和 `LoadingStateWidget.inline()` 替換 `LinearProgressIndicator` 和 `CircularProgressIndicator`

- ✅ `pump_head_schedule_page.dart`
  - 使用 `showErrorSnackBar` 替換 `_maybeShowError`
  - 使用 `LoadingStateWidget.center()` 替換 `CircularProgressIndicator`
  - 使用 `EmptyStateCard` 替換 `_ScheduleEmptyState`

## 待更新頁面（低優先級）

### Dosing 相關
- [ ] `manual_dosing_page.dart` - 可以使用 `showErrorSnackBar` 和 `showSuccessSnackBar`
- [ ] `schedule_edit_page.dart` - 可以使用 `showErrorSnackBar`
- [ ] `pump_head_detail_page.dart` - 可以使用 `showErrorSnackBar`、`showSuccessSnackBar` 和 `LoadingStateWidget`
- [ ] `pump_head_record_setting_page.dart` - 可以使用 `showErrorSnackBar`
- [ ] `pump_head_record_time_setting_page.dart` - 可以使用 `showErrorSnackBar`
- [ ] `pump_head_settings_page.dart` - 可以使用 `showErrorSnackBar`
- [ ] `drop_type_page.dart` - 可以使用 `showErrorSnackBar`
- [ ] `drop_setting_page.dart` - 可以使用 `showErrorSnackBar`

## 注意事項

大部分 LED 和 Dosing 列表頁面已經有很好的空狀態和加載狀態實現，只需要：
1. 統一使用 `LoadingStateWidget` 而不是直接使用 `CircularProgressIndicator`
2. 統一使用 `showErrorSnackBar` 而不是手動創建 `SnackBar`
3. 檢查空狀態組件是否可以使用 `EmptyStateWidget` 或 `EmptyStateCard`

