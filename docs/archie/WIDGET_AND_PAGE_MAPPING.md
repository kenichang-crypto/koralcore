# Widget 和頁面對照表 - koralcore vs reef-b-app

## 目錄結構對照

### koralcore 目錄結構

```
lib/ui/
├── features/              # 功能頁面
│   ├── home/              # 主頁
│   ├── device/            # 設備管理
│   ├── bluetooth/         # 藍牙掃描
│   ├── led/               # LED 控制
│   ├── dosing/            # 滴定泵控制
│   ├── sink/              # 水槽管理
│   ├── warning/           # 警告頁面
│   └── splash/            # 啟動頁面
├── widgets/               # 可重用 Widget
├── components/            # UI 組件
└── app/                   # 應用級組件
```

### reef-b-app 目錄結構

```
android/ReefB_Android/app/src/main/
├── res/layout/            # XML 布局文件
│   ├── activity_*.xml     # Activity 布局
│   ├── fragment_*.xml     # Fragment 布局
│   └── adapter_*.xml      # Adapter 布局
└── java/.../ui/
    ├── activity/          # Activity 類
    └── fragment/          # Fragment 類
```

---

## 頁面對照表

### 1. 主頁面（Main Pages）

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/splash/pages/splash_page.dart` | `res/layout/activity_splash.xml`<br>`SplashActivity.kt` | 啟動頁面 |
| `lib/ui/app/main_scaffold.dart` | `res/layout/activity_main.xml`<br>`MainActivity.kt` | 主框架（底部導航） |
| `lib/ui/features/home/home_page.dart` | `res/layout/fragment_home.xml`<br>`HomeFragment.kt` | 主頁（設備列表） |
| `lib/ui/features/device/device_page.dart` | `res/layout/fragment_device.xml`<br>`DeviceFragment.kt` | 設備管理頁面 |
| `lib/ui/features/bluetooth/bluetooth_page.dart` | `res/layout/activity_bluetooth.xml`<br>`BluetoothActivity.kt` | 藍牙掃描頁面 |

---

### 2. LED 控制頁面

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/led/pages/led_main_page.dart` | `res/layout/activity_led_main.xml`<br>`LedMainActivity.kt` | LED 主頁面 |
| `lib/ui/features/led/pages/led_control_page.dart` | `res/layout/activity_led_control.xml`<br>`LedControlActivity.kt` | LED 控制頁面 |
| `lib/ui/features/led/pages/led_scene_list_page.dart` | `res/layout/activity_led_scene_list.xml`<br>`LedSceneListActivity.kt` | LED 場景列表 |
| `lib/ui/features/led/pages/led_scene_add_page.dart` | `res/layout/activity_led_scene_add.xml`<br>`LedSceneAddActivity.kt` | 添加場景 |
| `lib/ui/features/led/pages/led_scene_edit_page.dart` | `res/layout/activity_led_scene_edit.xml`<br>`LedSceneEditActivity.kt` | 編輯場景 |
| `lib/ui/features/led/pages/led_scene_delete_page.dart` | `res/layout/activity_led_scene_delete.xml`<br>`LedSceneDeleteActivity.kt` | 刪除場景 |
| `lib/ui/features/led/pages/led_record_page.dart` | `res/layout/activity_led_record.xml`<br>`LedRecordActivity.kt` | LED 記錄頁面 |
| `lib/ui/features/led/pages/led_record_setting_page.dart` | `res/layout/activity_led_record_setting.xml`<br>`LedRecordSettingActivity.kt` | 記錄設置 |
| `lib/ui/features/led/pages/led_record_time_setting_page.dart` | `res/layout/activity_led_record_time_setting.xml`<br>`LedRecordTimeSettingActivity.kt` | 記錄時間設置 |
| `lib/ui/features/led/pages/led_schedule_list_page.dart` | `res/layout/activity_led_schedule_list.xml`<br>`LedScheduleListActivity.kt` | 排程列表 |
| `lib/ui/features/led/pages/led_schedule_edit_page.dart` | `res/layout/activity_led_schedule_edit.xml`<br>`LedScheduleEditActivity.kt` | 編輯排程 |
| `lib/ui/features/led/pages/led_setting_page.dart` | `res/layout/activity_led_setting.xml`<br>`LedSettingActivity.kt` | LED 設置 |
| `lib/ui/features/led/pages/led_master_setting_page.dart` | `res/layout/activity_led_master_setting.xml`<br>`LedMasterSettingActivity.kt` | Master 設置 |

---

### 3. 滴定泵控制頁面

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/dosing/pages/dosing_main_page.dart` | `res/layout/activity_drop_head_main.xml`<br>`DropHeadMainActivity.kt` | 滴定泵主頁面 |
| `lib/ui/features/dosing/pages/pump_head_detail_page.dart` | `res/layout/activity_drop_head_detail.xml`<br>`DropHeadDetailActivity.kt` | 泵頭詳情 |
| `lib/ui/features/dosing/pages/pump_head_schedule_page.dart` | `res/layout/activity_drop_head_schedule.xml`<br>`DropHeadScheduleActivity.kt` | 泵頭排程 |
| `lib/ui/features/dosing/pages/pump_head_settings_page.dart` | `res/layout/activity_drop_head_settings.xml`<br>`DropHeadSettingsActivity.kt` | 泵頭設置 |
| `lib/ui/features/dosing/pages/pump_head_calibration_page.dart` | `res/layout/activity_drop_head_calibration.xml`<br>`DropHeadCalibrationActivity.kt` | 泵頭校準 |
| `lib/ui/features/dosing/pages/pump_head_record_setting_page.dart` | `res/layout/activity_drop_head_record_setting.xml`<br>`DropHeadRecordSettingActivity.kt` | 記錄設置 |
| `lib/ui/features/dosing/pages/pump_head_record_time_setting_page.dart` | `res/layout/activity_drop_head_record_time_setting.xml`<br>`DropHeadRecordTimeSettingActivity.kt` | 記錄時間設置 |
| `lib/ui/features/dosing/pages/manual_dosing_page.dart` | `res/layout/activity_manual_dosing.xml`<br>`ManualDosingActivity.kt` | 手動滴定 |
| `lib/ui/features/dosing/pages/drop_type_page.dart` | `res/layout/activity_drop_type.xml`<br>`DropTypeActivity.kt` | 滴定類型 |
| `lib/ui/features/dosing/pages/drop_setting_page.dart` | `res/layout/activity_drop_setting.xml`<br>`DropSettingActivity.kt` | 滴定設置 |
| `lib/ui/features/dosing/pages/pump_head_adjust_list_page.dart` | `res/layout/activity_drop_head_adjust_list.xml`<br>`DropHeadAdjustListActivity.kt` | 調整列表 |
| `lib/ui/features/dosing/pages/schedule_edit_page.dart` | `res/layout/activity_schedule_edit.xml`<br>`ScheduleEditActivity.kt` | 排程編輯 |

---

### 4. 設備管理頁面

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/device/pages/add_device_page.dart` | `res/layout/activity_add_device.xml`<br>`AddDeviceActivity.kt` | 添加設備 |
| `lib/ui/features/device/pages/device_settings_page.dart` | `res/layout/activity_device_settings.xml`<br>`DeviceSettingsActivity.kt` | 設備設置 |

---

### 5. 水槽管理頁面

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/sink/pages/sink_manager_page.dart` | `res/layout/activity_sink_manager.xml`<br>`SinkManagerActivity.kt` | 水槽管理 |
| `lib/ui/features/sink/pages/sink_position_page.dart` | `res/layout/activity_sink_position.xml`<br>`SinkPositionActivity.kt` | 水槽位置 |

---

### 6. 其他頁面

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/warning/pages/warning_page.dart` | `res/layout/activity_warning.xml`<br>`WarningActivity.kt` | 警告頁面 |

---

## Widget 對照表

### 1. 設備相關 Widget

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/device/widgets/device_card.dart` | `res/layout/adapter_device_led.xml`<br>`res/layout/adapter_device_drop.xml`<br>`DeviceAdapter.kt` | 設備卡片 |
| `lib/ui/widgets/reef_device_card.dart` | `res/layout/adapter_device_led.xml`<br>`MaterialCardView` | 設備卡片容器 |

---

### 2. LED 相關 Widget

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/features/led/widgets/scene_icon_picker.dart` | `res/layout/adapter_scene_icon.xml`<br>`SceneIconAdapter.kt` | 場景圖標選擇器 |
| `lib/ui/features/led/widgets/led_record_line_chart.dart` | `res/layout/adapter_led_record.xml`<br>`LedRecordAdapter.kt` | LED 記錄折線圖 |
| `lib/ui/features/led/widgets/led_schedule_timeline.dart` | `res/layout/adapter_led_schedule.xml`<br>`LedScheduleAdapter.kt` | LED 排程時間軸 |
| `lib/ui/features/led/widgets/led_spectrum_chart.dart` | `res/layout/adapter_led_spectrum.xml`<br>`LedSpectrumAdapter.kt` | LED 光譜圖 |

---

### 3. 滴定泵相關 Widget

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| （內嵌在頁面中） | `res/layout/adapter_drop_head.xml`<br>`DropHeadAdapter.kt` | 泵頭卡片 |
| （內嵌在頁面中） | `res/layout/adapter_drop_head_schedule.xml`<br>`DropHeadScheduleAdapter.kt` | 泵頭排程卡片 |

---

### 4. 通用 Widget

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `lib/ui/widgets/reef_app_bar.dart` | `res/layout/toolbar_app.xml`<br>`res/layout/toolbar_device.xml`<br>`AppBarLayout` | 應用欄 |
| `lib/ui/widgets/reef_backgrounds.dart` | `res/drawable/background_main.xml` | 背景 |
| `lib/ui/components/empty_state_widget.dart` | `res/layout/layout_no_device.xml`<br>`LinearLayout` | 空狀態 |
| `lib/ui/components/error_state_widget.dart` | `res/layout/layout_error.xml`<br>`LinearLayout` | 錯誤狀態 |
| `lib/ui/components/ble_guard.dart` | `res/layout/bottom_sheet_ble_guard.xml`<br>`BottomSheetFragment` | BLE 守衛 |

---

## 頁面內部組件對照

### Home Page 組件

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `_TopButtonBar` (內嵌) | `ImageView btn_warning` | 頂部按鈕欄 |
| `_SinkSelectorBar` (內嵌) | `Spinner sp_sink_type`<br>`ImageView img_down`<br>`ImageView btn_sink_manager` | Sink 選擇器欄 |
| `_HomeDeviceGridTile` (內嵌) | `adapter_device_led.xml` | 設備網格項 |
| `_EmptyState` (內嵌) | `LinearLayout layout_no_device_in_sink` | 空狀態 |

---

### Device Page 組件

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `DeviceCard` | `adapter_device_led.xml`<br>`adapter_device_drop.xml` | 設備卡片 |
| `_EmptyState` (內嵌) | `LinearLayout layout_no_device` | 空狀態 |

---

### LED Main Page 組件

| koralcore | reef-b-app | 說明 |
|-----------|------------|------|
| `_DeviceInfoSection` (內嵌) | `TextView tv_name`<br>`TextView tv_position`<br>`ImageView btn_ble` | 設備信息區 |
| `_LedRecordCard` (內嵌) | `CardView layout_record_background` | 記錄卡片 |
| `_FavoriteScenesList` (內嵌) | `RecyclerView rv_favorite_scene` | 喜愛場景列表 |

---

## 文件統計

### koralcore

- **頁面文件**: ~35 個
- **Widget 文件**: ~10 個
- **組件文件**: ~5 個
- **總計**: ~50 個 UI 文件

### reef-b-app

- **Activity Layout**: ~25 個
- **Fragment Layout**: ~3 個
- **Adapter Layout**: ~21 個
- **其他 Layout**: ~8 個
- **總計**: ~57 個 XML 布局文件

---

## 對應關係總結

### ✅ 已完全對應（100%）

1. **主頁面**: 所有主要頁面都已實現
2. **LED 控制**: 所有 LED 相關頁面都已實現
3. **滴定泵控制**: 所有滴定泵相關頁面都已實現
4. **設備管理**: 所有設備管理頁面都已實現
5. **水槽管理**: 所有水槽管理頁面都已實現

### ⚠️ 部分對應（~80%）

1. **Widget 組件**: 部分組件內嵌在頁面中，未單獨提取
2. **Adapter 布局**: 部分 Adapter 布局直接內嵌在頁面中

### 📝 備註

- koralcore 使用 Flutter Widget 樹結構，而 reef-b-app 使用 XML 布局文件
- koralcore 的某些組件內嵌在頁面中，而 reef-b-app 使用獨立的 Adapter 布局
- 功能上 100% 對應，但文件組織方式不同（Flutter vs Android）

---

## 目錄映射規則

### koralcore → reef-b-app

| koralcore 路徑 | reef-b-app 路徑 | 映射規則 |
|---------------|----------------|---------|
| `lib/ui/features/{feature}/pages/{name}_page.dart` | `res/layout/activity_{name}.xml`<br>`{Name}Activity.kt` | 頁面文件 |
| `lib/ui/features/{feature}/widgets/{name}.dart` | `res/layout/adapter_{name}.xml`<br>`{Name}Adapter.kt` | Widget 文件 |
| `lib/ui/widgets/reef_{name}.dart` | `res/layout/{name}.xml` | 通用 Widget |
| `lib/ui/components/{name}_widget.dart` | `res/layout/layout_{name}.xml` | 組件 Widget |

---

**最後更新**: 2024-12-30

