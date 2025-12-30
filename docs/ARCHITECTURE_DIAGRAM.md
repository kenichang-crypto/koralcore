# koralcore 架構圖

## 正規 IoT Flutter 架構

```
koralcore/
│
├─ lib/
│  │
│  ├─ main.dart                    # 應用入口
│  │
│  ├─ app/                         # ⚡ App 啟動與全域配置
│  │  ├─ app.dart                  # MaterialApp / Router
│  │  ├─ app_lifecycle.dart        # 前景/背景/恢復
│  │  ├─ app_providers.dart        # 全域 Provider
│  │  ├─ main_scaffold.dart        # 主框架
│  │  └─ navigation_controller.dart # 導航控制器
│  │
│  ├─ core/                        # ⚡ 純技術核心（與業務無關）
│  │  ├─ ble/
│  │  │  ├─ ble_client.dart        # 掃描/連線/寫入/notify
│  │  │  ├─ ble_guard.dart         # 連線/notify/權限保護
│  │  │  ├─ ble_readiness_controller.dart # BLE 狀態管理
│  │  │  └─ ble_types.dart
│  │  ├─ platform/
│  │  │  ├─ permissions.dart
│  │  │  └─ lifecycle.dart
│  │  ├─ error/
│  │  │  ├─ app_error.dart
│  │  │  └─ ble_error.dart
│  │  └─ utils/
│  │
│  ├─ domain/                      # ⚡ 業務規則（最重要）
│  │  ├─ device/
│  │  │  ├─ device.dart            # 裝置模型
│  │  │  ├─ device_capability.dart
│  │  │  └─ device_type.dart       # LED / DOSER
│  │  ├─ led/
│  │  │  ├─ led_scene.dart
│  │  │  ├─ led_schedule.dart
│  │  │  └─ led_rules.dart
│  │  ├─ doser/
│  │  │  ├─ doser_head.dart
│  │  │  ├─ doser_schedule.dart
│  │  │  ├─ doser_record.dart
│  │  │  └─ dosing_rules.dart       # 0x7A / 0x7E 規則
│  │  └─ usecases/                 # ⚡ UI 唯一可呼叫入口
│  │     ├─ connect_device.dart
│  │     ├─ apply_led_scene.dart
│  │     ├─ read_today_dose.dart
│  │     └─ write_doser_schedule.dart
│  │
│  ├─ data/                        # ⚡ 資料來源實作
│  │  ├─ ble/
│  │  │  ├─ ble_device_repository.dart
│  │  │  ├─ ble_led_repository.dart
│  │  │  └─ ble_doser_repository.dart
│  │  ├─ local/
│  │  │  └─ preferences.dart
│  │  └─ mappers/
│  │
│  ├─ features/                    # ⚡ 使用者功能（UI 導向）
│  │  ├─ home/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     │  └─ home_page.dart
│  │  │     ├─ controllers/
│  │  │     │  └─ home_controller.dart
│  │  │     └─ widgets/
│  │  │
│  │  ├─ device/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     │  ├─ device_page.dart
│  │  │     │  ├─ add_device_page.dart
│  │  │     │  └─ device_settings_page.dart
│  │  │     ├─ controllers/
│  │  │     │  ├─ device_list_controller.dart
│  │  │     │  └─ add_device_controller.dart
│  │  │     └─ widgets/
│  │  │        └─ device_card.dart
│  │  │
│  │  ├─ led/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     │  ├─ led_main_page.dart
│  │  │     │  ├─ led_control_page.dart
│  │  │     │  ├─ led_scene_list_page.dart
│  │  │     │  ├─ led_scene_add_page.dart
│  │  │     │  ├─ led_scene_edit_page.dart
│  │  │     │  ├─ led_schedule_list_page.dart
│  │  │     │  ├─ led_record_page.dart
│  │  │     │  └─ ...
│  │  │     ├─ controllers/
│  │  │     │  ├─ led_control_controller.dart
│  │  │     │  ├─ led_scene_list_controller.dart
│  │  │     │  ├─ led_schedule_list_controller.dart
│  │  │     │  └─ ...
│  │  │     ├─ widgets/
│  │  │     │  ├─ led_spectrum_chart.dart
│  │  │     │  ├─ led_record_line_chart.dart
│  │  │     │  └─ scene_icon_picker.dart
│  │  │     └─ helpers/
│  │  │        └─ support/
│  │  │           ├─ led_record_icon_helper.dart
│  │  │           └─ scene_icon_helper.dart
│  │  │
│  │  ├─ doser/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     │  ├─ dosing_main_page.dart
│  │  │     │  ├─ pump_head_detail_page.dart
│  │  │     │  └─ ...
│  │  │     ├─ controllers/
│  │  │     └─ widgets/
│  │  │
│  │  ├─ bluetooth/
│  │  │  └─ presentation/
│  │  │     └─ pages/
│  │  │        └─ bluetooth_page.dart
│  │  │
│  │  ├─ splash/
│  │  │  └─ presentation/
│  │  │     └─ pages/
│  │  │        └─ splash_page.dart
│  │  │
│  │  ├─ sink/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     └─ controllers/
│  │  │
│  │  └─ warning/
│  │     └─ presentation/
│  │        ├─ pages/
│  │        └─ controllers/
│  │
│  ├─ shared/                      # ⚡ 純 UI 共用（無邏輯）
│  │  ├─ widgets/
│  │  │  ├─ reef_app_bar.dart      # AppBar
│  │  │  ├─ reef_device_card.dart  # 設備卡片
│  │  │  ├─ reef_backgrounds.dart  # 背景
│  │  │  ├─ empty_state_widget.dart # 空狀態
│  │  │  ├─ error_state_widget.dart # 錯誤狀態
│  │  │  └─ loading_state_widget.dart # 載入狀態
│  │  └─ theme/
│  │     ├─ app_colors.dart        # 顏色（對應 res/values/colors.xml）
│  │     ├─ app_spacing.dart       # 間距（對應 res/values/dimens.xml）
│  │     ├─ app_radius.dart        # 圓角（對應 res/values/styles.xml）
│  │     ├─ app_text_styles.dart   # 文字樣式（對應 res/values/styles.xml）
│  │     └─ app_theme.dart         # 主題（對應 res/values/styles.xml）
│  │
│  ├─ application/                 # 應用層（DTO、UseCase）
│  │  ├─ common/
│  │  │  ├─ app_context.dart
│  │  │  ├─ app_session.dart
│  │  │  └─ app_error_code.dart
│  │  ├─ device/
│  │  │  └─ device_snapshot.dart
│  │  └─ system/
│  │
│  ├─ infrastructure/              # 基礎設施層
│  │  ├─ repositories/
│  │  └─ ...
│  │
│  ├─ platform/                    # 平台抽象層
│  │  └─ contracts/
│  │
│  └─ l10n/                        # 多語言
│     ├─ intl_en.arb
│     ├─ intl_zh_Hant.arb
│     └─ ... (其他語言)
│
├─ assets/
│  ├─ icons/                       # ⚡ 統一 icons 目錄（無子分類）
│  │  ├─ ic_add_btn.svg
│  │  ├─ ic_connect.svg
│  │  ├─ ic_blue_light_thumb.svg
│  │  ├─ device_led.png
│  │  └─ ... (99 個文件)
│  │
│  └─ images/
│     └─ splash/
│
└─ pubspec.yaml
```

---

## 架構層級說明

### 1. app/ - 應用配置層
**職責**: App 啟動、全域配置、路由、生命週期

**特點**:
- 應用級別的配置和初始化
- 不包含業務邏輯
- 提供全域 Provider

---

### 2. core/ - 技術核心層
**職責**: 純技術功能，與業務無關

**特點**:
- **BLE**: 平台能力，被多個功能共用
- **Platform**: 平台相關功能（權限、生命週期）
- **Error**: 錯誤處理
- **Utils**: 工具類

**規則**: 
- ✅ BLE 必須在 `core/`，因為是平台能力
- ✅ 不包含業務邏輯
- ✅ 可被多個 features 共用

---

### 3. domain/ - 業務規則層
**職責**: 業務邏輯和規則

**特點**:
- 純 Dart，無 Flutter 依賴
- 包含業務規則和驗證
- **usecases/**: UI 唯一可呼叫的業務邏輯入口

**規則**:
- ✅ Controller 不能直接處理業務規則
- ✅ Controller 只能調用 `domain/usecases/`

---

### 4. data/ - 資料層
**職責**: 資料來源實作

**特點**:
- BLE 資料實作
- 本地儲存實作
- 資料映射

---

### 5. features/ - 功能層
**職責**: 使用者功能（UI 導向）

**結構**:
```
features/{feature}/
└─ presentation/
   ├─ pages/          # 頁面
   ├─ widgets/        # 功能內 Widget
   ├─ controllers/    # 控制器（只調用 usecases）
   ├─ helpers/        # Helper 類
   └─ models/         # 功能內模型
```

**規則**:
- ✅ 每個功能獨立
- ✅ 功能內 Widget 在 `presentation/widgets/`
- ✅ Controller 只能調用 `domain/usecases/`

---

### 6. shared/ - 共享層
**職責**: 純 UI 共用，無業務邏輯

**結構**:
```
shared/
├─ widgets/    # 全局共享 Widget（無狀態 UI）
└─ theme/      # 主題配置
```

**規則**:
- ✅ 只能放無狀態 UI Widget
- ✅ 允許：AppBar, Loading, Empty State
- ❌ 禁止：BLE, Controller, Device 狀態

---

## 兩層 Widget 結構

### Feature-local Widgets
**位置**: `features/{feature}/presentation/widgets/`

**特點**:
- 只在該功能內使用
- 可能包含業務邏輯
- 例如：`led_spectrum_chart.dart`, `device_card.dart`

### Shared Widgets
**位置**: `shared/widgets/`

**特點**:
- 跨功能共用
- 無業務邏輯
- 例如：`reef_app_bar.dart`, `empty_state_widget.dart`

---

## 資源對應關係

### Android res/ → Flutter

| Android | Flutter | 說明 |
|---------|---------|------|
| `res/values/colors.xml` | `lib/shared/theme/app_colors.dart` | 顏色 |
| `res/values/styles.xml` | `lib/shared/theme/app_theme.dart` | 主題 |
| `res/values/dimens.xml` | `lib/shared/theme/app_spacing.dart` | 間距 |
| `res/values/strings.xml` | `lib/l10n/intl_*.arb` | 字串 |
| `res/drawable/*.xml` | `assets/icons/*.svg` | 圖標（統一在根目錄） |
| `res/layout/activity_*.xml` | `lib/features/*/presentation/pages/*_page.dart` | 頁面 |
| `res/layout/adapter_*.xml` | `lib/features/*/presentation/widgets/*.dart` | Widget |

---

## 資料流

```
UI (features/)
    ↓
Controller (features/*/presentation/controllers/)
    ↓
UseCase (domain/usecases/)
    ↓
Repository (data/)
    ↓
BLE/Storage (core/ 或 platform/)
```

---

## 重要規則總結

1. ✅ **BLE 在 core/** - 平台能力，不是功能
2. ✅ **Controller 不直接處理業務規則** - 只能調用 `domain/usecases/`
3. ✅ **兩層 Widget 結構** - Feature-local + Shared
4. ✅ **shared 只能放無狀態 UI** - 禁止 BLE, Controller, Device 狀態
5. ✅ **Icons 統一** - 所有 icons 在 `assets/icons/` 根目錄，無子分類

---

**狀態**: 架構重構完成 ✅

**符合**: 正規 IoT Flutter 架構 ✅

