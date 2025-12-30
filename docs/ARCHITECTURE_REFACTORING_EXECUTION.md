# 架構重構執行計劃

## 當前狀態

✅ **已完成**:
1. 創建新目錄結構
2. 複製 App 文件到 `lib/app/`
3. 複製 BLE 文件到 `lib/core/ble/`
4. 複製主題文件到 `lib/shared/theme/`（並創建新命名版本）
5. 複製 Widget 文件到 `lib/shared/widgets/`

⏳ **待完成**:
1. 移動 features 文件（移除 `ui/` 層級）
2. 更新所有 import 語句
3. 統一頁面文件位置
4. 重命名 `support/` 為 `helpers/`
5. 更新 BLE guard 的 import
6. 測試編譯

---

## 重構策略

由於文件數量較多（71+ 個文件），建議採用**分階段執行**：

### 階段 A: 核心文件移動（優先）

1. **更新 main.dart**
   - 更新 `app/`, `core/`, `shared/theme/` 的 import

2. **移動關鍵 features**
   - `home/` → `features/home/presentation/`
   - `device/` → `features/device/presentation/`
   - `splash/` → `features/splash/presentation/`

3. **更新 BLE guard**
   - 更新 import 路徑

### 階段 B: 批量移動和更新

使用腳本或手動批量處理剩餘文件。

---

## Import 更新規則

### 主題相關

```dart
// 舊
import 'ui/theme/reef_colors.dart';
import 'ui/theme/reef_spacing.dart';
import 'ui/theme/reef_text.dart';
import 'ui/theme/reef_theme.dart';

// 新
import 'shared/theme/app_colors.dart';
import 'shared/theme/app_spacing.dart';
import 'shared/theme/app_text_styles.dart';
import 'shared/theme/app_theme.dart';
```

### Widget 相關

```dart
// 舊
import 'ui/widgets/reef_app_bar.dart';
import 'ui/components/empty_state_widget.dart';

// 新
import 'shared/widgets/reef_app_bar.dart';
import 'shared/widgets/empty_state_widget.dart';
```

### BLE 相關

```dart
// 舊
import 'ui/components/ble_guard.dart';
import 'application/system/ble_readiness_controller.dart';

// 新
import 'core/ble/ble_guard.dart';
import 'core/ble/ble_readiness_controller.dart';
```

### App 相關

```dart
// 舊
import 'ui/app/main_scaffold.dart';
import 'ui/app/navigation_controller.dart';

// 新
import 'app/main_scaffold.dart';
import 'app/navigation_controller.dart';
```

### Features 相關

```dart
// 舊
import 'ui/features/home/home_page.dart';
import 'ui/features/device/device_page.dart';
import 'ui/features/device/pages/add_device_page.dart';

// 新
import 'features/home/presentation/pages/home_page.dart';
import 'features/device/presentation/pages/device_page.dart';
import 'features/device/presentation/pages/add_device_page.dart';
```

---

## 下一步行動

由於這是一個大規模重構，建議：

1. **先完成核心文件**（main.dart, 關鍵頁面）
2. **逐步移動 features**（一個功能一個功能處理）
3. **批量更新 import**（使用查找替換）
4. **測試編譯**（確保沒有破壞性變更）

---

**狀態**: 準備執行階段 A

