# Phase 2: 基礎組件調整完成狀態

## 完成日期
2024-12-28

---

## 已完成的工作

### 1. ✅ ReefTheme 配置更新

已更新 `lib/ui/theme/reef_theme.dart`，添加了：
- ✅ CardTheme（白色背景，圓角 20dp，無陰影）
- ✅ FilledButtonTheme
- ✅ OutlinedButtonTheme
- ✅ TextButtonTheme
- ✅ InputDecorationTheme（淺灰背景，圓角 4dp，無邊框）

---

### 2. ✅ 組件樣式修復

#### TextField 組件
- ✅ `pump_head_record_setting_page.dart` - 移除了硬編碼 InputDecoration
- ✅ `pump_head_record_time_setting_page.dart` - 移除了硬編碼 InputDecoration
- ✅ `drop_type_page.dart` - 移除了硬編碼 InputDecoration
- ✅ `drop_setting_page.dart` - 移除了硬編碼 InputDecoration
- ✅ `led_scene_add_page.dart` - 移除了硬編碼 InputDecoration

#### Card 組件
- ✅ `drop_setting_page.dart` - 移除了硬編碼 color 和 shape
- ✅ `feature_entry_card.dart` - 移除了硬編碼 color

#### Button 組件
- ✅ `sink_manager_page.dart` - ElevatedButton → FilledButton，使用 ReefColors.danger

---

### 3. ✅ AppColors/AppDimensions 替換

已批量替換以下文件：

#### LED 相關頁面（9 個文件）
1. ✅ `led_scene_add_page.dart`
2. ✅ `led_scene_delete_page.dart`
3. ✅ `led_scene_edit_page.dart`
4. ✅ `led_control_page.dart`
5. ✅ `led_schedule_list_page.dart`
6. ✅ `led_schedule_edit_page.dart`
7. ✅ `led_scene_list_page.dart`
8. ✅ `led_record_page.dart`
9. ✅ `led/widgets/scene_icon_picker.dart`

#### Dosing 相關頁面（4 個文件）
10. ✅ `pump_head_calibration_page.dart`
11. ✅ `pump_head_schedule_page.dart`
12. ✅ `schedule_edit_page.dart`
13. ✅ `manual_dosing_page.dart`

#### 其他文件
14. ✅ `sink_manager_page.dart` - 已替換並添加必要的 imports

---

## 替換規則總結

### AppColors → ReefColors
- `AppColors.primary` → `ReefColors.primary`
- `AppColors.success` → `ReefColors.success`
- `AppColors.warning` → `ReefColors.warning`
- `AppColors.error` → `ReefColors.danger`
- `AppColors.grey400` → `ReefColors.textTertiary`
- `AppColors.grey500` → `ReefColors.textTertiary`
- `AppColors.grey600` → `ReefColors.textSecondary`
- `AppColors.grey700` → `ReefColors.textSecondary`
- `AppColors.grey100` → `ReefColors.surfaceMuted`

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
- `import '../../../../theme/colors.dart'` → `import '../../../theme/reef_colors.dart'`
- `import '../../../../theme/dimensions.dart'` → `import '../../../theme/reef_spacing.dart'`（如果需要 ReefRadius，也添加）

---

## 統計

### 已修復文件總數
- **總計**: 14 個文件
- **TextField 修復**: 5 個文件
- **Card 修復**: 2 個文件
- **Button 修復**: 1 個文件
- **AppColors/AppDimensions 替換**: 13 個文件

### 主要改進
1. ✅ 所有 TextField 現在使用 Theme 的 InputDecorationTheme
2. ✅ 所有 Card 現在使用 Theme 的 CardTheme（或移除硬編碼樣式）
3. ✅ 所有 Button 使用正確的顏色常量
4. ✅ 所有頁面統一使用 ReefColors、ReefSpacing、ReefRadius

---

## 下一步

Phase 2 的基礎組件調整基本完成。接下來可以進行：
- Phase 3: 統一背景使用（將主要頁面改為 ReefMainBackground）
- 最終檢查：確保所有組件在淺色背景上顯示正確

