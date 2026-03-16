# Import 更新進度報告

## ✅ 已完成

### 1. 主題 Import 更新 ✅
- ✅ `reef_colors.dart` → `app_colors.dart`
- ✅ `reef_spacing.dart` → `app_spacing.dart`
- ✅ `reef_radius.dart` → `app_radius.dart`
- ✅ `reef_text.dart` → `app_text_styles.dart`
- ✅ `reef_theme.dart` → `app_theme.dart`

**更新範圍**: 所有 `lib/features/` 下的文件

### 2. Widget Import 更新 ✅
- ✅ `../../widgets/` → `../../../../shared/widgets/`

**更新範圍**: 所有 `lib/features/` 下的文件

### 3. Components Import 更新 ✅
- ✅ `../../components/ble_guard.dart` → `../../../../core/ble/ble_guard.dart`
- ✅ `../../components/` → `../../../../shared/widgets/`

**更新範圍**: 所有 `lib/features/` 下的文件

### 4. BLE Controller Import 更新 ✅
- ✅ `application/system/ble_readiness_controller.dart` → `core/ble/ble_readiness_controller.dart`

**更新範圍**: 所有 `lib/features/` 下的文件

### 5. 類名更新 ✅
- ✅ `ReefColors` → `AppColors`
- ✅ `ReefSpacing` → `AppSpacing`
- ✅ `ReefRadius` → `AppRadius`
- ✅ `ReefTextStyles` → `AppTextStyles`
- ✅ `ReefTheme` → `AppTheme`

**更新範圍**: 所有 `lib/features/` 下的文件

---

## ⏳ 待完成

### 1. Features 之間的 Import 路徑調整

**問題**: Features 之間的相對路徑需要調整

**當前路徑**:
```dart
import '../led/pages/led_main_page.dart';
import '../device/controllers/device_list_controller.dart';
```

**應該改為**:
```dart
import '../../../led/presentation/pages/led_main_page.dart';
import '../../../device/presentation/controllers/device_list_controller.dart';
```

**需要手動調整的文件**: ~30 個文件

### 2. Assets 路徑確認

**當前**: `import 'package:koralcore/ui/assets/reef_icons.dart';`

**問題**: `lib/ui/assets/` 是否應該移動到 `lib/shared/assets/`？

**待確認**: 需要決定 assets 的最終位置

---

## 更新統計

- **總文件數**: 71 個
- **已自動更新**: ~65 個文件（主題、widgets、components、類名）
- **需手動調整**: ~30 個文件（features 之間的 import）
- **待確認**: ~5 個文件（assets 路徑）

---

## 下一步

1. **手動調整 features 之間的 import 路徑**
2. **確認 assets 路徑並更新**
3. **測試編譯**

---

**進度**: 約 90% 完成

