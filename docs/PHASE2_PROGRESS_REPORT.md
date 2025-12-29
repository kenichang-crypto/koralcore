# Phase 2: 基礎組件調整進度報告

## 開始日期
2024-12-28

---

## 已完成的工作

### 1. ✅ 更新 ReefTheme 配置

已更新 `lib/ui/theme/reef_theme.dart`，添加了：
- ✅ CardTheme（白色背景，圓角 20dp，無陰影）
- ✅ FilledButtonTheme（綠色背景，白色文字）
- ✅ OutlinedButtonTheme（綠色邊框和文字）
- ✅ TextButtonTheme（深綠色文字）
- ✅ InputDecorationTheme（淺灰背景 #F7F7F7，圓角 4dp，無邊框）

---

### 2. ✅ 已修復的文件

#### TextField 組件修復
1. ✅ **pump_head_record_setting_page.dart**
   - 移除了 `DropdownButtonFormField` 的硬編碼 `InputDecoration(border: OutlineInputBorder())`
   - 移除了 `TextField` 的硬編碼 `InputDecoration(border: OutlineInputBorder())`
   - 現在使用 Theme 的 InputDecorationTheme

2. ✅ **pump_head_record_time_setting_page.dart**
   - 移除了 `DropdownButtonFormField` 的硬編碼 `InputDecoration(border: OutlineInputBorder())`
   - 移除了 `TextField` 的硬編碼 `InputDecoration(border: OutlineInputBorder())`
   - 現在使用 Theme 的 InputDecorationTheme

3. ✅ **drop_type_page.dart**
   - 移除了兩個 `TextField` 的硬編碼 `InputDecoration`（移除了 `labelText`）
   - 現在使用 Theme 的 InputDecorationTheme

4. ✅ **drop_setting_page.dart**
   - 移除了 `TextField` 的硬編碼 `InputDecoration`（邊框、圓角、填充色）
   - 移除了 `Card` 的硬編碼 `color` 和 `shape`
   - 現在使用 Theme 的配置

#### Card 組件修復
5. ✅ **drop_setting_page.dart**
   - 移除了 Card 的硬編碼 `color: ReefColors.surface` 和 `shape`
   - 現在使用 Theme 的 CardTheme

#### Button 組件修復
6. ✅ **sink_manager_page.dart**
   - 將 `ElevatedButton` 改為 `FilledButton`
   - 將 `backgroundColor: Colors.red` 改為 `backgroundColor: ReefColors.danger`

#### 資源使用統一化
7. ✅ **sink_manager_page.dart**
   - 替換了所有 `AppColors` 為 `ReefColors`
   - 替換了所有 `AppDimensions` 為 `ReefSpacing`
   - 替換了硬編碼的 `TextStyle` 為 `ReefTextStyles`
   - 添加了必要的 imports

---

## 待處理的文件

根據 grep 結果，以下文件仍使用 `AppColors` 或 `AppDimensions`，需要檢查和修復：

### LED 相關頁面（12 個文件）
- [ ] `led/pages/led_scene_add_page.dart`
- [ ] `led/pages/led_scene_delete_page.dart`
- [ ] `led/pages/led_scene_edit_page.dart`
- [ ] `led/pages/led_control_page.dart`
- [ ] `led/pages/led_schedule_list_page.dart`
- [ ] `led/pages/led_schedule_edit_page.dart`
- [ ] `led/pages/led_record_page.dart`
- [ ] `led/pages/led_scene_list_page.dart`
- [ ] `led/widgets/scene_icon_picker.dart`

### Dosing 相關頁面（4 個文件）
- [ ] `dosing/pages/pump_head_calibration_page.dart`
- [ ] `dosing/pages/pump_head_schedule_page.dart`
- [ ] `dosing/pages/schedule_edit_page.dart`
- [ ] `dosing/pages/manual_dosing_page.dart`

### 其他文件
- [ ] `components/feature_entry_card.dart` - 需要檢查是否有硬編碼 Card 樣式

---

## 檢查統計

### 總頁面數
- 約 34 個 `_page.dart` 文件

### 已檢查/修復
- ✅ 5 個文件已修復（TextField、Card、Button、資源統一）
- ⏳ 13 個文件需要檢查（使用 AppColors/AppDimensions）
- ⏳ 16+ 個文件需要檢查（其他組件使用情況）

### 主要問題類型

1. **TextField 硬編碼 InputDecoration** - ✅ 已修復 4 個文件
2. **Card 硬編碼樣式** - ✅ 已修復 1 個文件
3. **Button 硬編碼樣式** - ✅ 已修復 1 個文件
4. **使用 AppColors/AppDimensions** - ⏳ 13 個文件待處理
5. **使用硬編碼顏色/間距/圓角** - ⏳ 待檢查

---

## 下一步計劃

### 優先級 1: 替換 AppColors/AppDimensions（13 個文件）
批量替換 `AppColors` → `ReefColors` 和 `AppDimensions` → `ReefSpacing`/`ReefRadius`

### 優先級 2: 檢查其他組件使用
- 檢查 Card 組件是否有硬編碼樣式
- 檢查 Button 組件是否有硬編碼樣式
- 檢查 TextField 組件是否有其他硬編碼 decoration

### 優先級 3: 檢查硬編碼值
- 檢查是否有硬編碼的顏色值（`Color(0x...)`、`Colors.xxx`）
- 檢查是否有硬編碼的間距值（數字而非常量）
- 檢查是否有硬編碼的圓角值

---

## 預計工作量

- 替換 AppColors/AppDimensions：13 個文件 × 10-15 分鐘 = 2-3 小時
- 檢查其他組件：20+ 個文件 × 5-10 分鐘 = 2-3 小時
- **總計**：約 4-6 小時

