# UX Parity Principles

**版本**: 1.1  
**日期**: 2025-02-11  
**用途**: 比較 koralcore Flutter app 與 reef-b-app 原生 app 的 UX 一致性，作為靜態分析與驗證依據。

---

## 〇、核心 Layout 約束（Gate）

### 單頁無向下捲動
- **規則**：koralcore 所有主要頁面為**單頁**，不得向下捲動（無 `SingleChildScrollView` 或 `ListView` 包整頁）。
- **適用範圍**：限於單獨頁面；若 layout 有問題，僅能檢查與修正該頁面內的 UX。
- **除外**（以下不受此限制，可自備捲動）：
  - **警告**（AlertDialog、警告頁）
  - **下拉**（Dropdown、PopupMenu、BottomSheet）
  - **跳出輸入**（Dialog、BottomSheet 內輸入框等浮層）

### reef-b-app 對照使用規則
- reef-b-app **僅供對照**，**不可做任何修改或變動**。
- 僅以 reef-b-app 之 layout / 行為作為 koralcore 實作與驗證的參考來源。

---

## 一、UX Parity Principles 結構（原則清單）

### A. 元件層級（Component Level）

| 原則 ID | 原則名稱 | 對照標準 | 來源 |
|---------|----------|----------|------|
| A1 | Layout 與 Spacing | reef-b `dimens.xml` → koralcore `AppSpacing`；margin/padding 數值對應 | LAYOUT_PARITY_METHODOLOGY, reef_b_app_res/values/dimens.xml |
| A2 | Section Ordering | ConstraintLayout 子節點順序 = Column children 順序 | MANDATORY_PARITY_RULES RULE 1 |
| A3 | Scroll 行為 | koralcore 主要頁面：單頁無向下捲動；除外：警告、下拉、跳出輸入可自備捲動；對照 reef 時 reef 無 ScrollView → koralcore 無捲動 | 核心約束 §〇 |
| A4 | Toolbar 行為 | 固定頂部；有 divider (dp_2)；Device tab 顯示 btn_choose + btn_delete | activity_main.xml, toolbar_app.xml |
| A5 | Bottom Nav 行為 | 3 destinations (Home/Bluetooth/Device)；IndexedStack 保留 tab 狀態 | activity_main.xml, main_navigation.xml |
| A6 | Button Placement / Label | 主要 CTA 位置與 reef 一致；按鈕 label 對應 strings.xml | reef values/strings.xml, intl_*.arb |
| A7 | Visibility 語意 | gone → 條件式 widget；invisible → Visibility(visible: false, maintainSize: true) | MANDATORY_PARITY_RULES RULE 3 |

### B. 互動層級（Interaction Level）

| 原則 ID | 原則名稱 | 對照標準 | 來源 |
|---------|----------|----------|------|
| B1 | Tap 行為 | 單擊觸發與 reef 一致（連線、刪除、選擇） | reef-b-app_behavior.md, BLE_DEVICE_BEHAVIOR_PARITY_ANALYSIS |
| B2 | Long Press / Swipe | reef 若有長按或滑動 → koralcore 需對應 | 逐頁檢查 |
| B3 | Disabled / Enabled 條件 | 未連線、未 ready 時按鈕禁用 | BLE_DEVICE_BEHAVIOR_PARITY_ANALYSIS, session.isReady |
| B4 | Loading 狀態 | progress.xml 全屏遮罩；CircularProgressIndicator | progress.xml |
| B5 | Success / Error 狀態 | Toast / Snackbar 文案對應 | strings.xml toast_*, snackbar_* |
| B6 | Navigation Flow | 頁面跳轉順序與 reef 一致 | UI_PAGES_OVERVIEW 導航結構 |
| B7 | Confirmation Dialogs | 刪除/重置等確認對話框：標題、內容、按鈕 | DEVICE_DELETE_COMPARISON, createDeleteLedDialog |

### C. 字詞與文案（Copy / Text）

| 原則 ID | 原則名稱 | 對照標準 | 來源 |
|---------|----------|----------|------|
| C1 | 按鈕 label | confirm, cancel, save, delete, select, skip, complete | strings.xml |
| C2 | 區塊標題 | device_name, sink_position, delay_time, led_scene_name 等 | strings.xml, ARB |
| C3 | 錯誤提示 | toast_connect_failed, toast_delete_device_successful 等 | UX_ASSETS_PARITY_ANALYSIS |
| C4 | Confirm Dialog 文案 | dialog_device_delete, dialog_device_delete_led_master_* | DEVICE_DELETE_COMPARISON |

### D. 圖像資源（Image / Icon）

| 原則 ID | 原則名稱 | 對照標準 | 來源 |
|---------|----------|----------|------|
| D1 | Icon 名稱與語意 | reef drawable id → koralcore CommonIconHelper / assets/icons/*.svg | UX_ASSETS_PARITY_ANALYSIS |
| D2 | Color Theme | app_color, bg_primary, text_success, text_warning, text_danger | colors.xml, AppColors |
| D3 | LED 光譜顏色 | moon_light_color, cold_white_light_color 等 | AppColors lighting presets |

### E. BLE / 功能邏輯一致性

| 原則 ID | 原則名稱 | 對照標準 | 來源 |
|---------|----------|----------|------|
| E1 | Scan 觸發 | 權限通過後自動掃描 | MainActivity.onCreate → scanLeDevice() |
| E2 | 連線狀態回饋 | Connecting / Connected / Disconnected | BLE_DEVICE_BEHAVIOR_PARITY_ANALYSIS |
| E3 | Ready Gate | 連線 + Initialize 完成後才開放 LED/Dosing | reef-b-app_behavior.md 4-5 |
| E4 | 刪除時 BLE 斷線 | 刪除已連線裝置前先 disconnect | DeviceViewModel.kt |
| E5 | 主燈刪除限制 | LED 群組內多裝置時主燈不可刪 | canDeleteDevice |

---

## 二、原則清單（JSON 格式）

```json
{
  "version": "1.1",
  "gate": {
    "single_page_no_scroll": "主要頁面單頁、無向下捲動",
    "exclusions": ["警告", "下拉", "跳出輸入"],
    "reef_b_app": "僅可對照使用，不可修改"
  },
  "categories": {
    "A_component": [
      {"id": "A1", "name": "Layout & Spacing", "rule": "dimens → AppSpacing"},
      {"id": "A2", "name": "Section Ordering", "rule": "XML constraint chain = Column children order"},
      {"id": "A3", "name": "Scroll Behavior", "rule": "單頁無向下捲動；除外：警告/下拉/跳出輸入"},
      {"id": "A4", "name": "Toolbar", "rule": "Fixed top, divider, Device tab btn_choose+btn_delete"},
      {"id": "A5", "name": "Bottom Nav", "rule": "3 tabs, IndexedStack"},
      {"id": "A6", "name": "Button Placement/Label", "rule": "CTA position, strings.xml"},
      {"id": "A7", "name": "Visibility", "rule": "gone ↔ conditional, invisible ↔ maintainSize"}
    ],
    "B_interaction": [
      {"id": "B1", "name": "Tap", "rule": "Single tap triggers match reef"},
      {"id": "B2", "name": "Long Press/Swipe", "rule": "Match reef if exists"},
      {"id": "B3", "name": "Disabled/Enabled", "rule": "Not connected/ready → disabled"},
      {"id": "B4", "name": "Loading", "rule": "progress overlay"},
      {"id": "B5", "name": "Success/Error", "rule": "Toast/Snackbar copy"},
      {"id": "B6", "name": "Navigation Flow", "rule": "Page transition order"},
      {"id": "B7", "name": "Confirmation Dialogs", "rule": "Title, content, buttons"}
    ],
    "C_copy": [
      {"id": "C1", "name": "Button Labels", "rule": "confirm/cancel/save/delete/select"},
      {"id": "C2", "name": "Section Titles", "rule": "device_name, sink_position, etc."},
      {"id": "C3", "name": "Error Messages", "rule": "toast_*, snackbar_*"},
      {"id": "C4", "name": "Confirm Dialog Copy", "rule": "dialog_device_delete, etc."}
    ],
    "D_assets": [
      {"id": "D1", "name": "Icon Semantics", "rule": "drawable → CommonIconHelper/SVG"},
      {"id": "D2", "name": "Color Theme", "rule": "colors.xml → AppColors"},
      {"id": "D3", "name": "LED Spectrum Colors", "rule": "Lighting preset colors"}
    ],
    "E_ble": [
      {"id": "E1", "name": "Auto Scan", "rule": "Permission granted → scanLeDevice"},
      {"id": "E2", "name": "Connection Feedback", "rule": "Connecting/Connected/Disconnected"},
      {"id": "E3", "name": "Ready Gate", "rule": "LED/Dosing only when ready"},
      {"id": "E4", "name": "Delete + Disconnect", "rule": "Disconnect before remove"},
      {"id": "E5", "name": "Master LED Delete", "rule": "canDeleteDevice restriction"}
    ]
  }
}
```

---

## 三、主要 UX 行為對照（Parity Matrix）

### 3.1 LED 模組

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| Quick preview | LedMainActivity, rv_favorite_scene | led_main_page.dart, LedMainFavoriteSceneSection | A2,A3 | Yes | — | — |
| Scene list | LedSceneActivity | led_scene_list_page.dart | A2,B6 | Yes | — | — |
| Add scene | activity_led_scene_add.xml | led_scene_add_page.dart | A2,A3,C2 | Yes | — | — |
| Edit scene | activity_led_scene_edit.xml | led_scene_edit_page.dart | A1,A2,A6,B4,C2 | Partial | 圖標尺寸 40dp、滑塊 thumb/顏色未完全對齊 | led_scene_edit_page.dart: SceneIconPicker 尺寸、Slider 自定義 thumb |
| Delete scene | activity_led_scene_delete.xml | led_scene_delete_page.dart | B7,C4 | Yes | — | — |
| Favorites | adapter_favorite_scene.xml | LedMainFavoriteSceneCard | A2,D1 | Yes | — | — |
| Schedule | LedRecordActivity, schedule list | led_schedule_list_page, led_schedule_edit_page | A3,B6 | Partial | schedule type Dropdown vs PopupMenu 需確認 | 對照 reef schedule 頁 |
| Scene name hint | 無 | led_scene_edit_page hintText | C2 | Partial | koralcore 有額外 hint | 可保留（改善 UX）或移除以嚴格對齊 |

### 3.2 Dosing 模組

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| Manual dosing | ManualDosingActivity | manual_dosing_page.dart | B3,B6,C1 | Yes | — | — |
| Schedule create/edit | ScheduleEditActivity | schedule_edit_page.dart | A3,C1,C2 | Yes | — | — |
| Schedule delete | Delete 按鈕 | PumpHeadSchedulePage Delete | B7,C4 | Yes | — | — |
| Pump heads list | activity_drop_main.xml | dosing_main_page.dart | A2,A3 | Yes | — | — |
| Drop setting | activity_drop_setting.xml | drop_setting_page.dart | A2,A6 | Yes | delay_time → BottomSheet | — |
| Pump head setting | activity_drop_head_setting.xml | pump_head_settings_page.dart | A2,D1 | Yes | — | — |
| Calibration | activity_drop_head_adjust.xml | pump_head_calibration_page.dart | A2,B4 | Yes | — | — |
| Drop type | activity_drop_type.xml | drop_type_page.dart | A2,A3 | Yes | — | — |

### 3.3 Device List & Pairing

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| Device list | fragment_device.xml, rv_user_device | device_tab_page.dart, DeviceCard | A2,A5 | Yes | — | — |
| Add device 按鈕 | btn_add_device | Empty state FAB/Button | A6,C1 | Yes | — | — |
| Pairing 流程 | BluetoothFragment → connectBle → AddDeviceActivity | bluetooth_tab_page → add_device_page | B6,E2 | Yes | — | — |
| 掃描結果 | rv_other_device, adapter_ble_scan | _OtherDevicesList, _BtDeviceTile | A2,D1 | Yes | — | — |
| Refresh 按鈕 | btn_refresh, @string/rearrangement | _OtherDevicesHeader refresh | A6,C1 | Yes | — | — |
| 空狀態 | layout_no_device, img_device_robot | device_tab_page empty state | A2,D1 | Yes | — | — |

### 3.4 Device Settings（Rename, Delete Device）

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| Rename | DeviceSettingActivity | device_settings_page.dart | C1,C2 | Yes | — | — |
| Delete（選擇模式） | btn_choose, btn_delete | main_shell_page.dart _ToolbarContent | A4,A6 | Partial | reef btn_choose 在 Toolbar 左側 MaterialButton；koralcore 為 TextButton | docs 記載 koralcore 已用 deviceSelectMode 對應 fragment_device_select，位置為 Toolbar 左側，可接受 |
| 主燈刪除限制 | createDeleteLedMasterDialog | main_shell_page.dart _onDeletePressed | B7,C4,E5 | Yes | — | — |
| 刪除確認 | createDeleteLedDialog | AlertDialog deviceDeleteConfirm* | B7,C4 | Yes | — | — |
| 刪除後 Snackbar | toast_delete_device_successful | snackbarDeviceRemoved | C3 | Yes | — | — |

### 3.5 BLE Connect / Disconnect

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| 點選連線 | BluetoothFragment onClickScanResult | bluetooth_tab_page _BtDeviceTile onTap | B1,E2 | Yes | — | — |
| Connecting 狀態 | loadingLiveData | DeviceSnapshot.isConnected, loading | B4,E2 | Yes | — | — |
| Connected 回饋 | toast_connect_successful | 透過 stream 更新 UI | B5,C3 | Partial | reef 有 Toast；koralcore 可能無明確 Toast | 可補強 Snackbar |
| 斷線回饋 | disconnectLiveData, getAllDevice | observeSavedDevices stream | B5,E2 | Partial | reef 無 Snackbar；koralcore 也未顯示 | 可選補強 |
| 手動刷新 | btn_refresh → startScan | controller.refresh() | B1,E1 | Yes | — | — |
| 已配對列表 | rv_user_device | _MyDevicesList | A2 | Yes | — | — |

### 3.6 App Launch & BLE Readiness

| UX 行為 | reef-b-app URI | koralcore 對應 | 原則 | 一致性 | 差異描述 | 最小修正建議 |
|---------|----------------|----------------|------|--------|----------|--------------|
| Splash | SplashActivity, 1.5s | splash_page.dart | B6 | Yes | — | — |
| Main 導航 | MainActivity | MainScaffold, MainShellPage | A4,A5 | Yes | — | — |
| BLE 權限檢查 | checkBlePermission | BleReadinessController | E1 | Yes | — | — |
| 權限通過後自動掃描 | MainActivity.onCreate → scanLeDevice | MainShellPage.initState _setupBleAutoScan | E1 | Yes | 已於 MainShellPage 實作 | — |
| BLE Not Ready Banner | 各 Activity 依權限/藍牙 | BleGuardBanner | B3,D1 | Yes | — | — |
| Tab 結構 | Home / Bluetooth / Device | HomeTabPage, BluetoothTabPage, DeviceTabPage | A5 | Yes | — | — |

---

## 四、檔案與行號對照（差異定位）

| 差異項 | reef-b-app | koralcore | 行號 / 位置 |
|--------|------------|-----------|-------------|
| LED Scene Edit 圖標尺寸 | adapter_scene_icon.xml 40×40dp | SceneIconPicker _IconItem | led_scene_edit_page.dart, scene_icon_picker.dart |
| LED Scene Edit 滑塊 thumb | setCustomThumbDrawable | 預設 Slider | led_scene_edit_page.dart Slider |
| Device Select 按鈕位置 | toolbar_app.xml btn_choose | _ToolbarContent TextButton | main_shell_page.dart:136-180 |
| fragment_device_select 文案 | @string/select | deviceSelectMode | intl_*.arb, app_localizations_*.dart |
| 斷線 Snackbar | 無 | 無 | app_session.dart, CurrentDeviceSession |
| BLE 自動掃描 | MainActivity.onCreate | MainShellPage._setupBleAutoScan | main_shell_page.dart:59-84 |

---

## 五、總結

### 已對齊項目（Yes）
- LED：Quick preview, scene list, add/delete scene, favorites
- Dosing：Manual dosing, schedule CRUD, pump heads, drop setting, calibration, drop type
- Device：List, pairing, add device, empty state, refresh
- Device Settings：Rename, delete flow, master LED restriction, confirm dialog
- BLE：Connect, disconnect, scan, refresh, ready gate
- App Launch：Splash, Main, BLE permission, BLE banner, tab structure

### 部分對齊（Partial）
- LED Scene Edit：圖標尺寸、滑塊 thumb/顏色
- LED Schedule：Schedule type 下拉元件對照
- BLE：Connected/Disconnected Toast 可選補強

### 無重大差異
- 整體結構、導航、文案、顏色、BLE 邏輯已達高度對齊。

---

## 六、全頁面 UX 對照 Audit

依 UX Parity Principles（含 §〇 單頁無向下捲動、A–E 原則）逐一檢查 koralcore 所有頁面。  
**判定**：✅ Pass｜⚠️ Review（需檢查）｜❌ Fail（違反原則）

### 6.1 判定說明

- **A3 單頁無向下捲動**：reef 無 ScrollView → koralcore 不得有 `SingleChildScrollView` 包整頁；reef 有 ScrollView 或「RecyclerView 填滿」→ 僅列表區可捲動（ListView/GridView 作為 Expanded 子項，非整頁包覆）。
- **除外**：warning_page（警告）、BottomSheet、Dialog、scene_icon_picker（下拉/選取）等可自備捲動。
- **橫向捲動**：`scrollDirection: Axis.horizontal` 不屬「向下捲動」，視為 Pass。

### 6.2 全頁面檢查表（依 reef layout 逐項對照）

**reef 有 ScrollView 的 layout**（依 grep 結果）：activity_drop_main, fragment_bluetooth, activity_drop_head_record_setting, activity_led_record_time_setting, activity_led_scene_add, activity_led_scene_edit, activity_led_master_setting  
**reef 無 ScrollView**：其餘皆為 ConstraintLayout 或 RecyclerView 填滿

| # | 頁面 | reef-b layout | reef Scroll | koralcore 捲動 | A3 判定 | A1-A2 | B-E | 差異 / 位置 |
|---|------|---------------|-------------|----------------|---------|-------|-----|-------------|
| 1 | splash_page | activity_splash | 無 | 無 | ✅ | ✅ | B6✅ | — |
| 2 | home_tab_page | fragment_home | 無 | GridView/ListView body | ✅ | A2✅ A5✅ | — | rv 填滿→列表自捲 L68,L77,L121 |
| 3 | device_tab_page | fragment_device | 無 | GridView.builder body | ✅ | A2✅ A5✅ | — | rv_user_device 填滿 L48 |
| 4 | bluetooth_tab_page | fragment_bluetooth | **有** | ListView.builder body | ✅ | A2✅ | E2✅ | L223 |
| 5 | add_device_page | activity_add_device | 無 | 無 Column | ✅ | A2✅ | C2✅ | — |
| 6 | device_settings_page | (LedSetting 類似) | 無 | 無 Column | ✅ | A2✅ | C1✅ | reef 無獨立 layout，對照 LedSetting |
| 7 | led_main_page | activity_led_main | 無 | 橫向 SingleChildScrollView | ✅ | A2✅ A3✅ | — | 橫向除外 L427 |
| 8 | led_control_page | (無對應 layout) | — | ListView body | ⚠️ | A2✅ | — | reef 無 activity_led_control；可能為 LedMain 子流程 |
| 9 | led_scene_list_page | activity_led_scene | 無 | ListView body | ✅ | A2✅ | B6✅ | rv_scene 填滿 L162 |
| 10 | led_scene_add_page | activity_led_scene_add | **有** | ListView body | ✅ | A2✅ | C2✅ | L41 |
| 11 | led_scene_edit_page | activity_led_scene_edit | **有** | ListView body | ✅ | A1⚠️ A2✅ | B4✅ C2✅ | 圖標/滑塊 Partial |
| 12 | led_scene_delete_page | activity_led_scene_delete | 無 | ListView body | ✅ | A2✅ | B7✅ C4✅ | rv_scene 填滿，列表自捲 L111 |
| 13 | led_schedule_list_page | (activity_led_record 區塊) | 無 | ListView body | ✅ | A3✅ | B6✅ | 排程列表區 L88 |
| 14 | led_schedule_edit_page | (ScheduleEdit 區塊) | — | ListView body | ⚠️ | A3✅ | C1✅ | reef 無獨立 activity，對照 pump schedule |
| 15 | led_record_page | activity_led_record | 無 | ListView.builder 區塊內 | ✅ | A2✅ | — | rv_led_record 填滿 L66 |
| 16 | led_record_setting_page | activity_led_record_setting | 無 | 無 Column | ✅ | A2✅ | — | ConstraintLayout 填滿 |
| 17 | led_record_time_setting_page | activity_led_record_time_setting | **有** | ListView body | ✅ | A2✅ | — | L40 |
| 18 | led_setting_page | activity_led_setting | 無 | 無 Column | ✅ | A2✅ | — | ConstraintLayout 填滿 |
| 19 | led_master_setting_page | activity_led_master_setting | **有** | ListView body | ✅ | A2✅ | — | L37 |
| 20 | dosing_main_page | activity_drop_main | **有** | SingleChildScrollView | ✅ | A2✅ | — | L142 |
| 21 | pump_head_detail_page | activity_drop_head_main | 無 | SingleChildScrollView | ❌ | A2✅ | — | reef 無 ScrollView；koralcore 有整頁捲動 L104 |
| 22 | pump_head_schedule_page | (drop_head_main rv_record_detail) | 無 | ListView body | ✅ | A2✅ | B7✅ | 排程列表 L76 |
| 23 | pump_head_record_setting_page | activity_drop_head_record_setting | **有** | SingleChildScrollView | ✅ | A2✅ | — | L71 |
| 24 | pump_head_record_time_setting_page | activity_drop_head_record_time_setting | **無** | SingleChildScrollView | ❌ | A2✅ | — | reef ConstraintLayout 無 Scroll；koralcore 有 L66 |
| 25 | pump_head_settings_page | activity_drop_head_setting | 無 | 無 Column | ✅ | A2✅ | D1✅ | — |
| 26 | pump_head_calibration_page | activity_drop_head_adjust | 無 | 無 | ✅ | A2✅ | B4✅ | — |
| 27 | pump_head_adjust_page | activity_drop_head_adjust | 無 | 無 | ✅ | A2✅ | B4✅ | 校正執行頁 |
| 28 | pump_head_adjust_list_page | activity_drop_head_adjust_list | 無 | ListView body | ✅ | A2✅ | — | rv 填滿 L52 |
| 29 | drop_setting_page | activity_drop_setting | 無 | 無 Column | ✅ | A2✅ | A6✅ | — |
| 30 | manual_dosing_page | (無對應 activity) | — | ListView body | ⚠️ | A2✅ | B3✅ B6✅ | reef 無獨立 layout，可能為 Drop 子流程 |
| 31 | schedule_edit_page | (pump schedule 區塊) | — | ListView body | ⚠️ | A3✅ | C1✅ | reef 無獨立 activity |
| 32 | drop_type_page | activity_drop_type | 無 | ListView.builder Expanded | ✅ | A2✅ | — | RecyclerView 填滿 L86 |
| 33 | sink_position_page | activity_sink_position | 無 | ListView.builder Expanded | ✅ | A2✅ | — | RecyclerView 填滿 L71 |
| 34 | sink_manager_page | activity_sink_manager | 無 | ListView.builder body | ✅ | A2✅ | — | rv_sink_manager 填滿 L234 |
| 35 | warning_page | activity_warning | 無 | ListView.builder | ✅ | — | B5✅ | **除外** 警告頁 L89 |
| 36 | main_shell_page | activity_main | — | 無 | ✅ | A4✅ A5✅ | — | 主框架，含 Toolbar/BottomNav |

### 6.3 逐頁原則對照（A–E）

| 頁面 | A 元件 | B 互動 | C 文案 | D 圖像 | E BLE |
|------|--------|--------|--------|--------|-------|
| splash_page | A2 | B6 導航 | — | — | — |
| home_tab_page | A2,A5 區塊順序、BottomNav | — | — | D1 icon | E3 ready gate |
| device_tab_page | A2,A5 | B1 tap 選裝置 | — | D1 | E3 |
| bluetooth_tab_page | A2 | B1,B4,E2 連線、loading | — | D1 | E1,E2 |
| add_device_page | A2 | B3  disabled when loading | C1,C2 | — | E2 |
| device_settings_page | A2 | B3,B7 | C1,C2 | D1 | E3 |
| led_main_page | A2,A3,A4 toolbar | B3,B4 | C2 | D1,D3 | E3 |
| led_control_page | A2 | B3,B4 | C2 | D1,D3 | E3 |
| led_scene_list_page | A2 | B6 | C2 | D1 | E3 |
| led_scene_add_page | A2 | B3,B4 | C2 | D1 | E3 |
| led_scene_edit_page | A1⚠️ A2,A6 | B4 | C2 | D1⚠️ D3 | E3 |
| led_scene_delete_page | A2 | B7 | C4 | D1 | E3 |
| led_schedule_list_page | A2 | B6 | C2 | D1 | E3 |
| led_schedule_edit_page | A2 | B3 | C1,C2 | D1 | E3 |
| led_record_page | A2 | B4 | C2 | D1 | E3 |
| led_record_setting_page | A2 | B3,B4 | C2 | D1 | E3 |
| led_record_time_setting_page | A2 | B3,B4 | C2 | D1 | E3 |
| led_setting_page | A2 | B3 | C1,C2 | D1 | E3 |
| led_master_setting_page | A2 | B3,B4 | C2 | D1 | E3 |
| dosing_main_page | A2,A4 | B3,B4,B7 | C1,C2 | D1 | E3 |
| pump_head_detail_page | A2 | B3,B4 | C2 | D1 | E3 |
| pump_head_schedule_page | A2 | B3,B7 | C1,C2 | D1 | E3 |
| pump_head_record_setting_page | A2 | B3,B4 | C2 | D1 | E3 |
| pump_head_record_time_setting_page | A2 | B3,B4 | C2 | D1 | E3 |
| pump_head_settings_page | A2 | B3 | C2 | D1 | E3 |
| pump_head_calibration_page | A2 | B4 | C2 | D1 | E3 |
| pump_head_adjust_page | A2 | B4 | C2 | D1 | E3 |
| pump_head_adjust_list_page | A2 | B4 | — | D1 | E3 |
| drop_setting_page | A2 | B3,B7 | C2 | D1 | E3 |
| manual_dosing_page | A2 | B3,B6 | C1,C2 | D1 | E3 |
| schedule_edit_page | A2 | B3,B7 | C1,C2 | D1 | E3 |
| drop_type_page | A2 | B3 | C2 | D1 | E3 |
| sink_position_page | A2 | — | C2 | D1 | — |
| sink_manager_page | A2 | B7 | C2 | D1 | — |
| warning_page | — | B5 | — | D1 | — |
| main_shell_page | A4,A5,A6 | B1 | C1 | D1 | — |

### 6.4 違反 A3（單頁無向下捲動）修正建議

| 頁面 | reef 結構 | koralcore 現況 | 建議 |
|------|-----------|----------------|------|
| pump_head_detail_page | activity_drop_head_main：ConstraintLayout，**無** ScrollView | SingleChildScrollView 包整頁 L104 | 改為 Column + Expanded；泵頭資訊區塊固定，排程/校正區以 ListView 填滿 |
| pump_head_record_time_setting_page | activity_drop_head_record_time_setting：ConstraintLayout，**無** ScrollView | SingleChildScrollView L66 | 改為 Column 固定區塊；若欄位多無法一屏，需與 reef 對照是否 reef 有小屏截斷或換行 |

### 6.5 需對照 reef 的頁面（無對應 layout）

| 頁面 | 說明 | 建議 |
|------|------|------|
| led_control_page | reef 無 activity_led_control | 可能為 LedMain 內嵌或 LedControlActivity 無獨立 layout；若 reef 為單頁固定→移除 ListView |
| led_schedule_edit_page | reef 無獨立 activity | 對照 pump schedule edit 或 drop_record 區塊 |
| manual_dosing_page | reef 無獨立 layout | 對照 DropMain 或 ManualDosing 流程 |
| schedule_edit_page | reef 無獨立 activity | 對照 activity_drop_head_record_setting 內排程編輯區 |
| led_schedule_edit_page | reef 無獨立 activity | 對照 LED record/schedule 區塊 |

### 6.6 Widget 與浮層（非主要頁面）

| Widget | 捲動 | 判定 | 說明 |
|--------|------|------|------|
| scene_icon_picker | ListView.builder 橫向 | ✅ | 除外：選取/下拉情境 |
| led_main_favorite_scene_section | SingleChildScrollView 橫向 | ✅ | 橫向，非向下捲動 |
| selection_list_bottom_sheet | ListView.builder | ✅ | 除外：BottomSheet |
| ble_guard | SingleChildScrollView | ✅ | 僅於 BleGuardBanner 說明區，非主要頁面 |

### 6.7 Audit 總結

| 判定 | 數量 | 頁面 |
|------|------|------|
| ✅ Pass | 30 | splash, home, device, bluetooth, add_device, device_settings, led_main, led_scene_list/add/edit/delete, led_schedule_list, led_record, led_record_setting, led_record_time_setting, led_setting, led_master_setting, dosing_main, pump_head_schedule/record_setting/settings/calibration/adjust/adjust_list, drop_setting, drop_type, sink_position, sink_manager, warning, main_shell |
| ⚠️ Review | 4 | led_control_page, led_schedule_edit_page, manual_dosing_page, schedule_edit_page（reef 無對應 layout） |
| ❌ Fail | 2 | pump_head_detail_page, pump_head_record_time_setting_page（reef 無 ScrollView，koralcore 有整頁捲動） |

- **reef 有 ScrollView**（7）：activity_drop_main, fragment_bluetooth, activity_drop_head_record_setting, activity_led_record_time_setting, activity_led_scene_add, activity_led_scene_edit, activity_led_master_setting
- **reef 無 ScrollView**：其餘 ConstraintLayout 或 RecyclerView 填滿
- **A3 違反**：pump_head_detail_page、pump_head_record_time_setting_page 需依 §6.4 修正

---

## 七、參考文件

- `docs/reef_b_app_behavior.md` - 設備生命週期行為
- `docs/LAYOUT_PARITY_METHODOLOGY.md` - Layout 對照方法
- `docs/MANDATORY_PARITY_RULES.md` - 強制對照規則
- `docs/BLE_DEVICE_BEHAVIOR_PARITY_ANALYSIS.md` - BLE 行為對照
- `docs/LED_SCENE_EDIT_FULL_COMPARISON.md` - LED 場景編輯對照
- `docs/DEVICE_DELETE_COMPARISON.md` - 設備刪除對照
- `docs/ADD_DEVICE_PARITY_ANALYSIS.md` - 新增設備對照
- `docs/UX_ASSETS_PARITY_ANALYSIS.md` - Icon/文字/顏色對照
- `docs/reef_b_app_res/` - reef-b XML 資源
