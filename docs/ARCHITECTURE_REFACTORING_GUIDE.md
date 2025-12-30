# 架構重構指南 - 正規 IoT Flutter 架構

## 目標架構

```
lib/
├─ main.dart
├─ app/                        # App 啟動與全域配置
├─ core/                       # 純技術核心（與業務無關）
├─ domain/                     # 業務規則（最重要）
├─ data/                       # 資料來源實作
├─ features/                   # 使用者功能（UI 導向）
├─ shared/                     # 純 UI 共用（無邏輯）
└─ l10n/
```

---

## 重構步驟詳解

### ✅ 階段 1: 創建新目錄結構（已完成）

已創建：
- `lib/app/`
- `lib/core/ble/`, `lib/core/platform/`, `lib/core/error/`, `lib/core/utils/`
- `lib/shared/widgets/`, `lib/shared/theme/`

---

### ⏳ 階段 2: 移動文件

#### 2.1 移動 App 文件

**已完成**: `lib/ui/app/` → `lib/app/`

#### 2.2 移動 BLE 文件到 core/

**從**: 
- `lib/ui/components/ble_guard.dart`
- `lib/application/system/ble_readiness_controller.dart`

**到**: `lib/core/ble/`

**規則**: BLE 是平台能力，不是功能，必須放在 `core/`

#### 2.3 移動主題文件到 shared/theme/

**已完成**: 創建新的主題文件
- `app_colors.dart` (從 `reef_colors.dart`)
- `app_spacing.dart` (從 `reef_spacing.dart`)
- `app_radius.dart` (從 `reef_radius.dart`)
- `app_text_styles.dart` (從 `reef_text.dart`)
- `app_theme.dart` (從 `reef_theme.dart`)

#### 2.4 移動 Widget 文件到 shared/widgets/

**從**: 
- `lib/ui/widgets/`
- `lib/ui/components/` (除了 BLE 相關)

**到**: `lib/shared/widgets/`

**規則**: 
- ✅ 允許：無狀態 UI Widget
- ❌ 禁止：BLE, Controller, Device 狀態

#### 2.5 移動 Features 文件

**從**: `lib/ui/features/{feature}/`  
**到**: `lib/features/{feature}/presentation/`

**結構變更**:
- 頁面文件統一到 `presentation/pages/`
- Widget 文件到 `presentation/widgets/`
- Controller 文件到 `presentation/controllers/`
- Helper 文件到 `presentation/helpers/` (從 `support/` 重命名)

---

### ⏳ 階段 3: 更新 Import 語句

#### 3.1 Import 映射規則

| 舊 Import | 新 Import |
|-----------|-----------|
| `import 'ui/theme/reef_colors.dart'` | `import 'shared/theme/app_colors.dart'` |
| `import 'ui/theme/reef_spacing.dart'` | `import 'shared/theme/app_spacing.dart'` |
| `import 'ui/theme/reef_text.dart'` | `import 'shared/theme/app_text_styles.dart'` |
| `import 'ui/theme/reef_theme.dart'` | `import 'shared/theme/app_theme.dart'` |
| `import 'ui/widgets/...'` | `import 'shared/widgets/...'` |
| `import 'ui/components/...'` | `import 'shared/widgets/...'` |
| `import 'ui/components/ble_guard.dart'` | `import 'core/ble/ble_guard.dart'` |
| `import 'ui/app/...'` | `import 'app/...'` |
| `import 'ui/features/...'` | `import 'features/.../presentation/...'` |

#### 3.2 相對路徑調整

由於目錄結構變化，相對路徑需要調整：

**從 features 內部引用 shared**:
- 舊: `import '../../ui/widgets/...'`
- 新: `import '../../../shared/widgets/...'`

**從 features 內部引用 core**:
- 舊: `import '../../ui/components/ble_guard.dart'`
- 新: `import '../../../core/ble/ble_guard.dart'`

---

### ⏳ 階段 4: 重命名和統一

#### 4.1 統一頁面文件位置

**規則**: 所有頁面文件都在 `presentation/pages/` 目錄下

**需要移動的頁面**:
- `lib/ui/features/home/home_page.dart` → `lib/features/home/presentation/pages/home_page.dart`
- `lib/ui/features/device/device_page.dart` → `lib/features/device/presentation/pages/device_page.dart`
- `lib/ui/features/bluetooth/bluetooth_page.dart` → `lib/features/bluetooth/presentation/pages/bluetooth_page.dart`

#### 4.2 重命名 support/ 為 helpers/

**從**: `lib/ui/features/{feature}/support/`  
**到**: `lib/features/{feature}/presentation/helpers/`

---

## 文件映射完整表

### BLE 相關

| 當前位置 | 新位置 | 狀態 |
|---------|--------|------|
| `lib/ui/components/ble_guard.dart` | `lib/core/ble/ble_guard.dart` | ⏳ |
| `lib/application/system/ble_readiness_controller.dart` | `lib/core/ble/ble_readiness_controller.dart` | ⏳ |

### 主題相關

| 當前位置 | 新位置 | 狀態 |
|---------|--------|------|
| `lib/ui/theme/reef_colors.dart` | `lib/shared/theme/app_colors.dart` | ✅ |
| `lib/ui/theme/reef_text.dart` | `lib/shared/theme/app_text_styles.dart` | ✅ |
| `lib/ui/theme/reef_spacing.dart` | `lib/shared/theme/app_spacing.dart` | ✅ |
| `lib/ui/theme/reef_radius.dart` | `lib/shared/theme/app_radius.dart` | ✅ |
| `lib/ui/theme/reef_theme.dart` | `lib/shared/theme/app_theme.dart` | ✅ |

### Widget 相關

| 當前位置 | 新位置 | 狀態 |
|---------|--------|------|
| `lib/ui/widgets/reef_app_bar.dart` | `lib/shared/widgets/reef_app_bar.dart` | ⏳ |
| `lib/ui/widgets/reef_device_card.dart` | `lib/shared/widgets/reef_device_card.dart` | ⏳ |
| `lib/ui/components/empty_state_widget.dart` | `lib/shared/widgets/empty_state_widget.dart` | ⏳ |
| `lib/ui/components/error_state_widget.dart` | `lib/shared/widgets/error_state_widget.dart` | ⏳ |

### Features 相關

| 當前位置 | 新位置 | 狀態 |
|---------|--------|------|
| `lib/ui/features/home/home_page.dart` | `lib/features/home/presentation/pages/home_page.dart` | ⏳ |
| `lib/ui/features/device/device_page.dart` | `lib/features/device/presentation/pages/device_page.dart` | ⏳ |
| `lib/ui/features/device/pages/add_device_page.dart` | `lib/features/device/presentation/pages/add_device_page.dart` | ⏳ |
| `lib/ui/features/led/support/` | `lib/features/led/presentation/helpers/` | ⏳ |

### App 相關

| 當前位置 | 新位置 | 狀態 |
|---------|--------|------|
| `lib/ui/app/main_scaffold.dart` | `lib/app/main_scaffold.dart` | ✅ |
| `lib/ui/app/navigation_controller.dart` | `lib/app/navigation_controller.dart` | ✅ |

---

## 重要規則

### ✅ 允許

1. **shared/widgets/**: 無狀態 UI Widget
   - AppBar, Loading, Empty State
   - 純展示型 Widget

2. **features/{feature}/presentation/widgets/**: 功能內 Widget
   - 只在該功能內使用
   - 可能包含業務邏輯

3. **core/ble/**: BLE 平台能力
   - 掃描、連線、寫入、通知
   - 權限管理

### ❌ 禁止

1. **shared/**: 不能放 BLE, Controller, Device 狀態
2. **features/**: 不能放 BLE 相關（應該在 core/）
3. **Controller**: 不能直接處理業務規則（只能調用 usecases）

---

## 執行狀態

- ✅ 階段 1: 創建新目錄結構
- ⏳ 階段 2: 移動文件（進行中）
- ⏳ 階段 3: 更新 Import 語句
- ⏳ 階段 4: 重命名和統一

---

**下一步**: 繼續移動文件並更新所有 import 語句

