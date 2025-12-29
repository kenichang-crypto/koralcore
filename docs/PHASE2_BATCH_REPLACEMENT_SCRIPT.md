# Phase 2: 批量替換腳本

## 替換規則

### AppColors → ReefColors
- `AppColors.primary` → `ReefColors.primary`
- `AppColors.success` → `ReefColors.success`
- `AppColors.warning` → `ReefColors.warning`
- `AppColors.danger` → `ReefColors.danger`
- `AppColors.error` → `ReefColors.danger`（注意：error 使用 danger）
- `AppColors.grey400` → `ReefColors.textTertiary`
- `AppColors.grey500` → `ReefColors.textTertiary`
- `AppColors.grey600` → `ReefColors.textSecondary`
- `AppColors.grey700` → `ReefColors.textSecondary`

### AppDimensions → ReefSpacing/ReefRadius
- `AppDimensions.spacingXS` → `ReefSpacing.xxxs`
- `AppDimensions.spacingS` → `ReefSpacing.xs`
- `AppDimensions.spacingM` → `ReefSpacing.sm`
- `AppDimensions.spacingL` → `ReefSpacing.md`
- `AppDimensions.spacingXL` → `ReefSpacing.xl`
- `AppDimensions.spacingXXL` → `ReefSpacing.xxl`
- `AppDimensions.radiusS` → `ReefRadius.sm`
- `AppDimensions.radiusM` → `ReefRadius.md`
- `AppDimensions.radiusL` → `ReefRadius.lg`

### Import 替換
- `import '../../../../theme/colors.dart';` → 移除或替換為 `import '../../../theme/reef_colors.dart';`
- `import '../../../../theme/dimensions.dart';` → 移除或替換為 `import '../../../theme/reef_spacing.dart';` 和 `import '../../../theme/reef_radius.dart';`

---

## 文件列表（需要處理）

### LED 相關（9 個文件）
1. ✅ `led/pages/led_scene_add_page.dart` - 正在處理
2. ✅ `led/pages/led_scene_delete_page.dart` - 正在處理
3. ⏳ `led/pages/led_scene_edit_page.dart`
4. ⏳ `led/pages/led_control_page.dart`
5. ⏳ `led/pages/led_schedule_list_page.dart`
6. ⏳ `led/pages/led_schedule_edit_page.dart`
7. ⏳ `led/pages/led_record_page.dart`
8. ⏳ `led/pages/led_scene_list_page.dart`
9. ⏳ `led/widgets/scene_icon_picker.dart`

### Dosing 相關（4 個文件）
10. ⏳ `dosing/pages/pump_head_calibration_page.dart`
11. ⏳ `dosing/pages/pump_head_schedule_page.dart`
12. ⏳ `dosing/pages/schedule_edit_page.dart`
13. ⏳ `dosing/pages/manual_dosing_page.dart`

---

## 注意事項

1. 確認每個文件都有正確的 import
2. 檢查是否有硬編碼的樣式需要移除
3. 確保所有常量值都正確映射
4. 檢查是否有編譯錯誤

