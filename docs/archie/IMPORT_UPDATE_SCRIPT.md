# Import 更新腳本指南

## 批量更新 Import 語句

由於文件數量較多，建議使用 IDE 的批量查找替換功能。

---

## 查找替換規則

### 1. 主題相關

| 查找 | 替換為 |
|------|--------|
| `import 'ui/theme/reef_colors.dart'` | `import 'shared/theme/app_colors.dart'` |
| `import '../ui/theme/reef_colors.dart'` | `import '../../shared/theme/app_colors.dart'` |
| `import '../../ui/theme/reef_colors.dart'` | `import '../../../shared/theme/app_colors.dart'` |
| `import '../../../ui/theme/reef_colors.dart'` | `import '../../../../shared/theme/app_colors.dart'` |
| `ReefColors` | `AppColors` |
| `ReefSpacing` | `AppSpacing` |
| `ReefRadius` | `AppRadius` |
| `ReefTextStyles` | `AppTextStyles` |
| `ReefTheme` | `AppTheme` |

### 2. Widget 相關

| 查找 | 替換為 |
|------|--------|
| `import 'ui/widgets/` | `import 'shared/widgets/` |
| `import '../ui/widgets/` | `import '../../shared/widgets/` |
| `import '../../ui/widgets/` | `import '../../../shared/widgets/` |
| `import 'ui/components/` | `import 'shared/widgets/` |
| `import '../ui/components/` | `import '../../shared/widgets/` |

### 3. BLE 相關

| 查找 | 替換為 |
|------|--------|
| `import 'ui/components/ble_guard.dart'` | `import 'core/ble/ble_guard.dart'` |
| `import '../ui/components/ble_guard.dart'` | `import '../../core/ble/ble_guard.dart'` |
| `import 'application/system/ble_readiness_controller.dart'` | `import 'core/ble/ble_readiness_controller.dart'` |
| `import '../application/system/ble_readiness_controller.dart'` | `import '../../core/ble/ble_readiness_controller.dart'` |

### 4. App 相關

| 查找 | 替換為 |
|------|--------|
| `import 'ui/app/` | `import 'app/` |
| `import '../ui/app/` | `import '../app/` |
| `import '../../ui/app/` | `import '../../app/` |

### 5. Features 相關

| 查找 | 替換為 |
|------|--------|
| `import 'ui/features/` | `import 'features/` |
| `import '../ui/features/` | `import '../features/` |
| `import '../../ui/features/` | `import '../../features/` |
| `import '../../../ui/features/` | `import '../../../features/` |

**注意**: Features 的路徑需要加上 `/presentation/`:
- `features/home/home_page.dart` → `features/home/presentation/pages/home_page.dart`
- `features/device/device_page.dart` → `features/device/presentation/pages/device_page.dart`
- `features/device/pages/add_device_page.dart` → `features/device/presentation/pages/add_device_page.dart`
- `features/led/support/` → `features/led/presentation/helpers/`

---

## VS Code / Cursor 批量替換步驟

1. **打開查找替換** (`Cmd+Shift+H` / `Ctrl+Shift+H`)
2. **啟用正則表達式** (點擊 `.*` 按鈕)
3. **逐個執行替換規則**
4. **檢查結果**

---

## 相對路徑調整

由於目錄結構變化，相對路徑需要調整：

**從 `features/{feature}/presentation/pages/` 引用**:
- `shared/widgets/` → `../../../../shared/widgets/`
- `shared/theme/` → `../../../../shared/theme/`
- `core/ble/` → `../../../../core/ble/`
- `app/` → `../../../../app/`

**從 `features/{feature}/presentation/widgets/` 引用**:
- `shared/widgets/` → `../../../../shared/widgets/`
- `shared/theme/` → `../../../../shared/theme/`

**從 `features/{feature}/presentation/controllers/` 引用**:
- `shared/widgets/` → `../../../../shared/widgets/`
- `shared/theme/` → `../../../../shared/theme/`

---

## 執行順序

1. ✅ 先更新主題相關（最常用）
2. ✅ 再更新 Widget 相關
3. ✅ 然後更新 BLE 相關
4. ✅ 最後更新 Features 相關（最複雜）

---

**狀態**: 準備執行

