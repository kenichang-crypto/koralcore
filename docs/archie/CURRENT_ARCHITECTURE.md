# koralcore 當前架構圖

## 📐 整體架構

```
┌─────────────────────────────────────────────────────────────┐
│                        koralcore                            │
│                  正規 IoT Flutter 架構                       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
    ┌──────┐            ┌─────────┐          ┌──────────┐
    │ app/ │            │ core/   │          │ domain/  │
    │      │            │         │          │          │
    │ 啟動 │            │ BLE     │          │ 業務規則 │
    │ 配置 │            │ 平台    │          │ UseCase  │
    └──────┘            └─────────┘          └──────────┘
        │                     │                     │
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
    ┌─────────┐          ┌──────────┐          ┌────────┐
    │ features│          │ shared/  │          │ data/  │
    │         │          │          │          │        │
    │ UI功能  │          │ UI共用   │          │ 資料   │
    │         │          │          │          │        │
    └─────────┘          └──────────┘          └────────┘
```

---

## 📁 詳細目錄結構

```
lib/
│
├─ 📱 app/                          [App 啟動與全域配置]
│  ├─ main_scaffold.dart            # 主框架
│  └─ navigation_controller.dart    # 導航控制器
│
├─ ⚙️ core/                          [純技術核心（與業務無關）]
│  └─ ble/
│     ├─ ble_guard.dart             # BLE 守衛（權限保護）
│     └─ ble_readiness_controller.dart # BLE 狀態管理
│
├─ 🧠 domain/                        [業務規則（最重要）]
│  ├─ device/                       # 裝置模型
│  ├─ led/                          # LED 業務規則
│  ├─ doser/                        # Doser 業務規則
│  └─ usecases/                     # ⚡ UI 唯一可呼叫入口
│
├─ 💾 data/                          [資料來源實作]
│  ├─ ble/                          # BLE 資料實作
│  ├─ local/                        # 本地儲存
│  └─ mappers/                      # 資料映射
│
├─ 🎨 features/                      [使用者功能（UI 導向）]
│  │
│  ├─ 🏠 home/
│  │  └─ presentation/
│  │     ├─ pages/
│  │     │  └─ home_page.dart
│  │     ├─ controllers/
│  │     │  └─ home_controller.dart
│  │     └─ widgets/
│  │
│  ├─ 📱 device/
│  │  └─ presentation/
│  │     ├─ pages/
│  │     │  ├─ device_page.dart
│  │     │  ├─ add_device_page.dart
│  │     │  └─ device_settings_page.dart
│  │     ├─ controllers/
│  │     │  ├─ device_list_controller.dart
│  │     │  └─ add_device_controller.dart
│  │     └─ widgets/
│  │        └─ device_card.dart
│  │
│  ├─ 💡 led/
│  │  └─ presentation/
│  │     ├─ pages/                  [13 個頁面]
│  │     │  ├─ led_main_page.dart
│  │     │  ├─ led_control_page.dart
│  │     │  ├─ led_scene_list_page.dart
│  │     │  ├─ led_scene_add_page.dart
│  │     │  ├─ led_scene_edit_page.dart
│  │     │  ├─ led_scene_delete_page.dart
│  │     │  ├─ led_schedule_list_page.dart
│  │     │  ├─ led_schedule_edit_page.dart
│  │     │  ├─ led_record_page.dart
│  │     │  ├─ led_record_setting_page.dart
│  │     │  ├─ led_record_time_setting_page.dart
│  │     │  ├─ led_setting_page.dart
│  │     │  └─ led_master_setting_page.dart
│  │     ├─ controllers/            [9 個控制器]
│  │     │  ├─ led_control_controller.dart
│  │     │  ├─ led_scene_list_controller.dart
│  │     │  ├─ led_scene_edit_controller.dart
│  │     │  ├─ led_schedule_list_controller.dart
│  │     │  ├─ led_schedule_summary_controller.dart
│  │     │  ├─ led_record_controller.dart
│  │     │  ├─ led_record_setting_controller.dart
│  │     │  ├─ led_record_time_setting_controller.dart
│  │     │  └─ led_master_setting_controller.dart
│  │     ├─ widgets/                [4 個 Widget]
│  │     │  ├─ scene_icon_picker.dart
│  │     │  ├─ led_spectrum_chart.dart
│  │     │  ├─ led_record_line_chart.dart
│  │     │  └─ led_schedule_timeline.dart
│  │     ├─ helpers/                [4 個 Helper]
│  │     │  └─ support/
│  │     │     ├─ led_record_icon_helper.dart
│  │     │     ├─ scene_icon_helper.dart
│  │     │     ├─ scene_channel_helper.dart
│  │     │     └─ scene_display_text.dart
│  │     └─ models/                 [2 個模型]
│  │        ├─ led_scene_summary.dart
│  │        └─ led_schedule_summary.dart
│  │
│  ├─ 💧 doser/
│  │  └─ presentation/
│  │     ├─ pages/                  [多個頁面]
│  │     │  ├─ dosing_main_page.dart
│  │     │  ├─ pump_head_detail_page.dart
│  │     │  ├─ pump_head_schedule_page.dart
│  │     │  ├─ pump_head_record_setting_page.dart
│  │     │  └─ ...
│  │     ├─ controllers/
│  │     └─ models/
│  │        ├─ pump_head_summary.dart
│  │        └─ ...
│  │
│  ├─ 📡 bluetooth/
│  │  └─ presentation/
│  │     └─ pages/
│  │        └─ bluetooth_page.dart
│  │
│  ├─ 🚀 splash/
│  │  └─ presentation/
│  │     └─ pages/
│  │        └─ splash_page.dart
│  │
│  ├─ 🏊 sink/
│  │  └─ presentation/
│  │     ├─ pages/
│  │     │  ├─ sink_manager_page.dart
│  │     │  └─ sink_position_page.dart
│  │     └─ controllers/
│  │        └─ sink_manager_controller.dart
│  │
│  └─ ⚠️ warning/
│     └─ presentation/
│        ├─ pages/
│        │  └─ warning_page.dart
│        └─ controllers/
│           └─ warning_controller.dart
│
├─ 🔗 shared/                        [純 UI 共用（無邏輯）]
│  ├─ widgets/                       [15 個 Widget]
│  │  ├─ reef_app_bar.dart          # AppBar
│  │  ├─ reef_device_card.dart      # 設備卡片
│  │  ├─ reef_backgrounds.dart      # 背景
│  │  ├─ empty_state_widget.dart    # 空狀態
│  │  ├─ error_state_widget.dart    # 錯誤狀態
│  │  ├─ loading_state_widget.dart  # 載入狀態
│  │  └─ ...
│  │
│  └─ theme/                         [5 個主題文件]
│     ├─ app_colors.dart            # 顏色（對應 res/values/colors.xml）
│     ├─ app_spacing.dart           # 間距（對應 res/values/dimens.xml）
│     ├─ app_radius.dart            # 圓角（對應 res/values/styles.xml）
│     ├─ app_text_styles.dart       # 文字樣式（對應 res/values/styles.xml）
│     └─ app_theme.dart             # 主題（對應 res/values/styles.xml）
│
├─ application/                     [應用層]
│  ├─ common/
│  │  ├─ app_context.dart
│  │  ├─ app_session.dart
│  │  └─ app_error_code.dart
│  ├─ device/
│  │  └─ device_snapshot.dart
│  └─ system/
│
├─ infrastructure/                  [基礎設施層]
│  └─ repositories/
│
├─ platform/                        [平台抽象層]
│  └─ contracts/
│
└─ l10n/                             [多語言]
   ├─ intl_en.arb                   # 英文
   ├─ intl_zh_Hant.arb              # 繁體中文
   ├─ intl_ar.arb                   # 阿拉伯文
   ├─ intl_de.arb                   # 德文
   ├─ intl_es.arb                   # 西班牙文
   ├─ intl_fr.arb                   # 法文
   ├─ intl_id.arb                   # 印尼文
   ├─ intl_ja.arb                   # 日文
   ├─ intl_ko.arb                   # 韓文
   ├─ intl_pt.arb                   # 葡萄牙文
   ├─ intl_ru.arb                   # 俄文
   ├─ intl_th.arb                   # 泰文
   └─ intl_vi.arb                   # 越南文

assets/
└─ icons/                            [99 個文件，統一在根目錄]
   ├─ ic_add_btn.svg
   ├─ ic_connect.svg
   ├─ ic_blue_light_thumb.svg
   ├─ ic_monday_select.svg
   ├─ img_drop_head_1.svg
   ├─ device_led.png
   ├─ device_doser.png
   ├─ dosing_main.png
   └─ ... (所有 icons 都在根目錄，無子分類)
```

---

## 📊 文件統計

| 層級 | 目錄 | 文件數 | 說明 |
|------|------|--------|------|
| **app/** | App 配置 | 2 | 啟動、導航、全域配置 |
| **core/ble/** | BLE 核心 | 2 | BLE 守衛、狀態管理 |
| **domain/** | 業務規則 | - | 業務邏輯、UseCase |
| **data/** | 資料來源 | - | Repository、Storage |
| **features/** | 功能模塊 | 71 | UI、Controller、Widget、Helper |
| **shared/** | 共享資源 | 21 | Widget、Theme |
| **l10n/** | 多語言 | 14 | ARB 文件（13 種語言 + 英文） |
| **assets/icons/** | Icons | 99 | 統一在根目錄（SVG + PNG） |

---

## 🔄 資料流

```
┌─────────────────────────────────────────────────────────┐
│              UI Layer (features/)                       │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │  Pages   │  │ Widgets  │  │Controllers│           │
│  │          │  │          │  │          │            │
│  │  UI展示  │  │ UI組件   │  │ 狀態管理 │            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
│       │             │             │                    │
│       └─────────────┼─────────────┘                    │
│                     │                                   │
│                     ▼                                   │
│              ┌──────────────┐                         │
│              │  Controllers │                         │
│              │  (只調用)    │                         │
│              └──────┬───────┘                         │
└─────────────────────┼──────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│        Business Logic Layer (domain/usecases/)         │
│                                                         │
│  ┌──────────────────────────────────────────┐          │
│  │         UseCases (唯一入口)              │          │
│  │  - connect_device                        │          │
│  │  - apply_led_scene                       │          │
│  │  - read_today_dose                       │          │
│  │  - write_doser_schedule                  │          │
│  └──────┬───────────────────────────────────┘          │
│         │                                               │
│         ▼                                               │
│  ┌──────────────┐                                      │
│  │ Domain Rules │                                      │
│  │ - Device     │                                      │
│  │ - LED        │                                      │
│  │ - Doser      │                                      │
│  └──────┬───────┘                                      │
└─────────┼───────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│              Data Layer (data/)                        │
│                                                         │
│  ┌──────────────────────────────────────────┐          │
│  │         Repositories                     │          │
│  │  - ble_device_repository                 │          │
│  │  - ble_led_repository                    │          │
│  │  - ble_doser_repository                  │          │
│  └──────┬───────────────────────────────────┘          │
│         │                                               │
│         ▼                                               │
│  ┌──────────────┐                                      │
│  │ Local Storage│                                      │
│  └──────┬───────┘                                      │
└─────────┼───────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│              Core Layer (core/ble/)                    │
│                                                         │
│  ┌──────────────────────────────────────────┐          │
│  │         BLE (平台能力)                   │          │
│  │  - ble_guard                             │          │
│  │  - ble_readiness_controller              │          │
│  │  (被 LED、Doser、Warning 共用)           │          │
│  └──────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Features 詳細結構

### home/
```
home/presentation/
├─ pages/
│  └─ home_page.dart              # 主頁
├─ controllers/
│  └─ home_controller.dart        # 主頁控制器
└─ widgets/
```

### device/
```
device/presentation/
├─ pages/
│  ├─ device_page.dart            # 設備列表頁
│  ├─ add_device_page.dart        # 添加設備頁
│  └─ device_settings_page.dart    # 設備設置頁
├─ controllers/
│  ├─ device_list_controller.dart # 設備列表控制器
│  └─ add_device_controller.dart  # 添加設備控制器
└─ widgets/
   └─ device_card.dart             # 設備卡片 Widget
```

### led/
```
led/presentation/
├─ pages/                         [13 個頁面]
│  ├─ led_main_page.dart
│  ├─ led_control_page.dart
│  ├─ led_scene_list_page.dart
│  ├─ led_scene_add_page.dart
│  ├─ led_scene_edit_page.dart
│  ├─ led_scene_delete_page.dart
│  ├─ led_schedule_list_page.dart
│  ├─ led_schedule_edit_page.dart
│  ├─ led_record_page.dart
│  ├─ led_record_setting_page.dart
│  ├─ led_record_time_setting_page.dart
│  ├─ led_setting_page.dart
│  └─ led_master_setting_page.dart
├─ controllers/                    [9 個控制器]
│  ├─ led_control_controller.dart
│  ├─ led_scene_list_controller.dart
│  ├─ led_scene_edit_controller.dart
│  ├─ led_schedule_list_controller.dart
│  ├─ led_schedule_summary_controller.dart
│  ├─ led_record_controller.dart
│  ├─ led_record_setting_controller.dart
│  ├─ led_record_time_setting_controller.dart
│  └─ led_master_setting_controller.dart
├─ widgets/                        [4 個 Widget]
│  ├─ scene_icon_picker.dart
│  ├─ led_spectrum_chart.dart
│  ├─ led_record_line_chart.dart
│  └─ led_schedule_timeline.dart
├─ helpers/                        [4 個 Helper]
│  └─ support/
│     ├─ led_record_icon_helper.dart
│     ├─ scene_icon_helper.dart
│     ├─ scene_channel_helper.dart
│     └─ scene_display_text.dart
└─ models/                         [2 個模型]
   ├─ led_scene_summary.dart
   └─ led_schedule_summary.dart
```

### doser/
```
doser/presentation/
├─ pages/                          [多個頁面]
│  ├─ dosing_main_page.dart
│  ├─ pump_head_detail_page.dart
│  ├─ pump_head_schedule_page.dart
│  ├─ pump_head_record_setting_page.dart
│  └─ ...
├─ controllers/
└─ models/
   └─ pump_head_summary.dart
```

---

## 🔗 對應關係

### reef-b-app → koralcore

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `MainActivity.kt` | `lib/app/main_scaffold.dart` | ✅ |
| `BLEManager.kt` | `lib/core/ble/ble_client.dart` | ✅ |
| `BleContainer.kt` | `lib/core/ble/` | ✅ |
| `HomeFragment.kt` | `lib/features/home/presentation/pages/home_page.dart` | ✅ |
| `DeviceFragment.kt` | `lib/features/device/presentation/pages/device_page.dart` | ✅ |
| `BluetoothFragment.kt` | `lib/features/bluetooth/presentation/pages/bluetooth_page.dart` | ✅ |
| `adapter_device_led.xml` | `lib/features/device/presentation/widgets/device_card.dart` | ✅ |
| `res/values/colors.xml` | `lib/shared/theme/app_colors.dart` | ✅ |
| `res/values/styles.xml` | `lib/shared/theme/app_theme.dart` | ✅ |
| `res/values/dimens.xml` | `lib/shared/theme/app_spacing.dart` | ✅ |
| `res/values/strings.xml` | `lib/l10n/intl_*.arb` | ✅ |
| `res/drawable/*.xml` | `assets/icons/*.svg` | ✅ |

---

## 🎯 架構規則

### ✅ 符合正規 IoT Flutter 架構

1. **BLE 在 core/** ✅
   - BLE 是平台能力，不是功能
   - 被 LED、Doser、Warning、Reconnect 共用
   - 位置：`lib/core/ble/`

2. **Controller 不直接處理業務規則** ✅
   - Controller 只能調用 `domain/usecases/`
   - 業務規則在 `domain/` 層
   - 位置：`lib/features/*/presentation/controllers/`

3. **兩層 Widget 結構** ✅
   - **Feature-local**: `lib/features/{feature}/presentation/widgets/`
   - **Shared**: `lib/shared/widgets/`

4. **shared 只能放無狀態 UI** ✅
   - ✅ 允許：AppBar, Loading, Empty State
   - ❌ 禁止：BLE, Controller, Device 狀態

5. **Icons 統一** ✅
   - 所有 icons 在 `assets/icons/` 根目錄
   - 無子分類（99 個文件）

---

## 📈 統計數據

- **總文件數**: ~200+ 個 Dart 文件
- **Features**: 8 個功能模塊
- **Pages**: ~40+ 個頁面
- **Controllers**: ~20+ 個控制器
- **Widgets**: ~30+ 個 Widget
- **Icons**: 99 個文件
- **Languages**: 14 種語言

---

**狀態**: 架構重構完成，符合正規 IoT Flutter 架構 ✅

**最後更新**: 2024-12-30

