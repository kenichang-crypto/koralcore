# 架構重構計劃 - 正規 IoT Flutter 架構

## 目標架構

```
lib/
├─ main.dart
│
├─ app/                        # App 啟動與全域配置
│   ├─ app.dart                # MaterialApp / Router
│   ├─ app_lifecycle.dart      # 前景/背景/恢復
│   └─ app_providers.dart      # 全域 Provider
│
├─ core/                       # ⚠️ 純技術核心（與業務無關）
│   ├─ ble/
│   │   ├─ ble_client.dart     # 掃描/連線/寫入/notify
│   │   ├─ ble_guard.dart      # 連線/notify/權限保護
│   │   └─ ble_types.dart
│   ├─ platform/
│   │   ├─ permissions.dart
│   │   └─ lifecycle.dart
│   ├─ error/
│   │   ├─ app_error.dart
│   │   └─ ble_error.dart
│   └─ utils/
│
├─ domain/                     # ⚠️ 業務規則（最重要）
│   ├─ device/
│   ├─ led/
│   ├─ doser/
│   └─ usecases/               # UI 唯一可呼叫入口
│
├─ data/                       # 資料來源實作
│   ├─ ble/
│   ├─ local/
│   └─ mappers/
│
├─ features/                   # 使用者功能（UI 導向）
│   ├─ home/
│   │   └─ presentation/
│   ├─ device/
│   │   └─ presentation/
│   ├─ led/
│   │   └─ presentation/
│   └─ doser/
│       └─ presentation/
│
├─ shared/                     # 純 UI 共用（無邏輯）
│   ├─ widgets/
│   └─ theme/
│
└─ l10n/
```

---

## 重構步驟

### 階段 1: 創建新目錄結構 ✅

- [x] 創建 `lib/app/`
- [x] 創建 `lib/core/ble/`, `lib/core/platform/`, `lib/core/error/`, `lib/core/utils/`
- [x] 創建 `lib/shared/widgets/`, `lib/shared/theme/`
- [x] 確保 `lib/features/` 存在

---

### 階段 2: 移動 BLE 相關文件到 core/

**從**: `lib/ui/components/ble_guard.dart`  
**到**: `lib/core/ble/ble_guard.dart`

**從**: `lib/application/system/ble_readiness_controller.dart`  
**到**: `lib/core/ble/ble_readiness_controller.dart` (或重構為更符合架構)

**規則**: BLE 是平台能力，不是功能，必須放在 `core/`

---

### 階段 3: 移動主題文件到 shared/theme/

**從**: `lib/ui/theme/`  
**到**: `lib/shared/theme/`

**文件**:
- `reef_colors.dart` → `app_colors.dart`
- `reef_text.dart` → `app_text_styles.dart`
- `reef_spacing.dart` → `app_spacing.dart`
- `reef_radius.dart` → `app_radius.dart`
- 合併為 `app_theme.dart`

---

### 階段 4: 移動 features 文件（移除 ui/ 層級）

**從**: `lib/ui/features/{feature}/`  
**到**: `lib/features/{feature}/presentation/`

**結構變更**:
```
lib/ui/features/home/home_page.dart
→ lib/features/home/presentation/home_page.dart

lib/ui/features/device/device_page.dart
→ lib/features/device/presentation/pages/device_page.dart

lib/ui/features/device/pages/add_device_page.dart
→ lib/features/device/presentation/pages/add_device_page.dart
```

---

### 階段 5: 合併 widgets/ 和 components/ 到 shared/widgets/

**從**: 
- `lib/ui/widgets/`
- `lib/ui/components/`

**到**: `lib/shared/widgets/`

**規則**: 
- ✅ 允許：無狀態 UI Widget（AppBar, Loading, Empty State）
- ❌ 禁止：BLE, Controller, Device 狀態

---

### 階段 6: 統一頁面文件到 pages/ 目錄

**當前問題**: 有些頁面在根目錄，有些在 `pages/` 子目錄

**統一為**: 所有頁面都在 `presentation/pages/` 目錄下

---

### 階段 7: 更新所有 import 語句

**需要更新的 import 模式**:

1. `import '../../ui/theme/...'` → `import '../../../shared/theme/...'`
2. `import '../../ui/widgets/...'` → `import '../../../shared/widgets/...'`
3. `import '../../ui/components/...'` → `import '../../../shared/widgets/...'`
4. `import '../../ui/features/...'` → `import '../../features/...'`
5. `import '../../ui/app/...'` → `import '../../../app/...'`

---

## 文件映射表

### BLE 相關

| 當前位置 | 新位置 | 說明 |
|---------|--------|------|
| `lib/ui/components/ble_guard.dart` | `lib/core/ble/ble_guard.dart` | BLE 守衛 |
| `lib/application/system/ble_readiness_controller.dart` | `lib/core/ble/ble_readiness_controller.dart` | BLE 狀態管理 |

### 主題相關

| 當前位置 | 新位置 | 說明 |
|---------|--------|------|
| `lib/ui/theme/reef_colors.dart` | `lib/shared/theme/app_colors.dart` | 顏色 |
| `lib/ui/theme/reef_text.dart` | `lib/shared/theme/app_text_styles.dart` | 文字樣式 |
| `lib/ui/theme/reef_spacing.dart` | `lib/shared/theme/app_spacing.dart` | 間距 |
| `lib/ui/theme/reef_radius.dart` | `lib/shared/theme/app_radius.dart` | 圓角 |

### Widget 相關

| 當前位置 | 新位置 | 說明 |
|---------|--------|------|
| `lib/ui/widgets/reef_app_bar.dart` | `lib/shared/widgets/reef_app_bar.dart` | AppBar |
| `lib/ui/widgets/reef_device_card.dart` | `lib/shared/widgets/reef_device_card.dart` | 設備卡片 |
| `lib/ui/components/empty_state_widget.dart` | `lib/shared/widgets/empty_state_widget.dart` | 空狀態 |
| `lib/ui/components/error_state_widget.dart` | `lib/shared/widgets/error_state_widget.dart` | 錯誤狀態 |

### Features 相關

| 當前位置 | 新位置 | 說明 |
|---------|--------|------|
| `lib/ui/features/home/home_page.dart` | `lib/features/home/presentation/home_page.dart` | 主頁 |
| `lib/ui/features/device/device_page.dart` | `lib/features/device/presentation/pages/device_page.dart` | 設備頁 |
| `lib/ui/features/device/pages/add_device_page.dart` | `lib/features/device/presentation/pages/add_device_page.dart` | 添加設備 |

### App 相關

| 當前位置 | 新位置 | 說明 |
|---------|--------|------|
| `lib/ui/app/main_scaffold.dart` | `lib/app/main_scaffold.dart` | 主框架 |
| `lib/ui/app/navigation_controller.dart` | `lib/app/navigation_controller.dart` | 導航控制器 |

---

## 重要規則

### ✅ 允許

1. **shared/widgets/**: 無狀態 UI Widget
   - AppBar, Loading, Empty State
   - 純展示型 Widget

2. **features/{feature}/presentation/widgets/**: 功能內 Widget
   - 只在該功能內使用
   - 可能包含業務邏輯

### ❌ 禁止

1. **shared/**: 不能放 BLE, Controller, Device 狀態
2. **features/**: 不能放 BLE 相關（應該在 core/）
3. **Controller**: 不能直接處理業務規則（只能調用 usecases）

---

## 執行順序

1. ✅ 創建新目錄結構
2. ⏳ 移動 BLE 文件到 core/
3. ⏳ 移動主題文件到 shared/theme/
4. ⏳ 移動 features 文件（移除 ui/ 層級）
5. ⏳ 合併 widgets/ 和 components/
6. ⏳ 統一頁面文件位置
7. ⏳ 更新所有 import 語句
8. ⏳ 測試編譯和運行

---

**狀態**: 進行中

