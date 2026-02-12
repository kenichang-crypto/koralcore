# UX Layout Parity 對照分析

koralcore (Flutter) 與 reef-b-app (Android) 版面結構對照，依 **L1–L4 Layout Parity Rules** 檢視。

---

## L1 – Section Ordering（區塊順序）

| 頁面 | reef-b-app | koralcore | 一致性 | 差異說明 |
|------|------------|-----------|--------|----------|
| **LED Main** | activity_led_main.xml | led_main_page.dart | ✅ Yes | 1.toolbar → 2.tv_name/btn_ble/tv_position/tv_group → 3.tv_record_title/layout_record → 4.tv_scene_title/btn_scene_more → 5.rv_favorite_scene → 6.progress |
| **Dosing Main** | activity_drop_main.xml | dosing_main_page.dart | ✅ Yes | 1.toolbar → 2.layout_device (tv_name, btn_ble, tv_position) → 3.rv_drop_head → progress |
| **Home** | fragment_home.xml | home_tab_page.dart | ⚠️ Partial | reef: btn_add_sink→sp_sink_type→rv_user_device 或 layout_no_device_in_sink；koralcore 有 SinkSelectorBar + GridView/EmptyState，結構相似但 Home 無 Spinner，改為 SinkSelectorBar |
| **Device Tab** | fragment_device.xml | device_tab_page.dart | ✅ Yes | rv_user_device / layout_no_device（空狀態圖 172×199 + 標題 marginTop 39dp + btn_add_device marginTop 8）|
| **Bluetooth Tab** | fragment_bluetooth.xml | bluetooth_tab_page.dart | ✅ Yes | rv_user_device → tv_other_device_title + btn_refresh → rv_other_device / layout_no_other_device |
| **Add Device** | activity_add_device.xml | add_device_page.dart | ✅ Yes | toolbar → tv_device_name_title → layout_name → tv_sink_position_title → layout_sink_position → progress |
| **Drop Setting** | activity_drop_setting.xml | drop_setting_page.dart | ✅ Yes | toolbar → tv_device_name → layout_name → tv_position → btn_position → tv_delay_time → btn_delay_time |
| **Pump Head Setting** | activity_drop_head_setting.xml | pump_head_settings_page.dart | ✅ Yes | toolbar → tv_drop_type → btn_drop_type → tv_rotating_speed → btn_rotating_speed |

---

## L2 – Fixed vs Scrollable Boundary（固定／捲動邊界）

| 頁面 | reef-b-app 固定區 | reef-b-app 捲動區 | koralcore | 一致性 |
|------|-------------------|-------------------|-----------|--------|
| **LED Main** | toolbar、tv_name~tv_group、layout_record、tv_scene_title、btn_scene_more | rv_favorite_scene (horizontal) | Column 固定 + Expanded(_FavoriteSceneArea) 僅場景橫捲 | ✅ Yes |
| **Dosing Main** | toolbar | layout_device + rv_drop_head 全在 ScrollView 內 | toolbar 固定 + Expanded(SingleChildScrollView) 包 layout_device + DosingMainPumpHeadList | ✅ Yes |
| **LED Main (land)** | 有 layout-land | - | led_main_page 有 landscape 變體 | ⚠️ 待對照 |
| **Add Device** | 全頁不可捲（ConstraintLayout 填滿） | 無 | Column + Expanded，無 ScrollView | ✅ Yes |
| **Drop Setting** | 全區固定 | 無 | Column，無 scroll | ✅ Yes |
| **Device Tab** | 無 toolbar | rv_user_device 或 layout_no_device | ListView/GridView 或 _EmptyState | ✅ Yes |
| **Bluetooth Tab** | 無 | ScrollView 包 rv_user_device + rv_other_device | ListView + RefreshIndicator | ✅ Yes |

---

## L3 – Primary CTA Placement（主按鈕位置）

| 頁面 | reef CTA 位置 | koralcore | 一致性 |
|------|---------------|-----------|--------|
| **LED Main** | btn_scene_more 右上、toolbar 右側 menu/favorite | _SceneHeader onMore 右側、_ToolbarDevice menu/favorite | ✅ Yes |
| **Dosing Main** | PopupMenu 在 toolbar 右側 | _showPopupMenu 同 | ✅ Yes |
| **Device Tab 空狀態** | btn_add_device 居中、marginTop 8 | FilledButton 居中、padding top 8 | ✅ Yes |
| **Add Device** | Skip 左、Done 右 (toolbar_two_action) | _ToolbarTwoAction onLeftPressed / onRightPressed | ✅ Yes |
| **LED Schedule List** | FAB 右下 | FloatingActionButton | ✅ Yes |
| **Drop Type** | FAB 右下 (fab_add_drop_type) | FAB | ✅ Yes |
| **Sink Position** | FAB 右下 16dp | FAB right 16, bottom 16 | ✅ Yes |

---

## L4 – Visual Density & Spacing（視覺密度）

| 維度 | reef-b-app | koralcore | 對照 |
|------|------------|-----------|------|
| **padding 主內容** | 16/12/16/12 dp (layout_add_device, layout_drop_setting, layout_led_setting) | EdgeInsets.fromLTRB(16, 12, 16, 12) / AppSpacing.md, AppSpacing.sm | ✅ |
| **section 間距** | marginTop 4dp (標題→輸入)、marginTop 16dp (section 之間) | SizedBox 4 / 16 | ✅ |
| **Card 圓角** | cardCornerRadius 10dp | AppRadius.md (10) | ✅ |
| **Card 陰影** | cardElevation 5dp | elevation: 5 | ✅ |
| **rv_favorite_scene padding** | paddingStart/End 8dp | padding horizontal 8 | ✅ |
| **空狀態圖** | 172×199 dp, marginTop 39 | 172×199, padding top 39 | ✅ |
| **空狀態按鈕** | marginTop 8, marginBottom 8 | padding top/bottom 8 | ✅ |
| **layout_record** | line_chart 242dp 高 | LedMainRecordChartSection 使用 flexible | ⚠️ reef 固定 242dp |
| **GridView (Home)** | paddingStart 10, paddingEnd 10, paddingTop 8 | left 10, right 10, top AppSpacing.xs (8) | ✅ |

---

## 各頁面 Layout 詳細對照

### 1. LED Main (activity_led_main.xml ↔ led_main_page.dart)

| reef XML id | reef 順序 | koralcore widget | 備註 |
|-------------|-----------|------------------|------|
| toolbar_led_main | 1 | _ToolbarDevice | toolbar_device.xml |
| tv_name | 2 | _DeviceIdentificationSection deviceName | 與 btn_ble 同行 |
| btn_ble | 2 | _DeviceIdentificationSection BLE icon | 48×32dp |
| tv_position | 3 | positionText | TODO: 從 session/repo 取水槽 |
| tv_group | 3 | 群組（visibility gone） | tools:text 群組Ａ |
| tv_record_title + btn_record_more | 4 | _SceneHeader (Record) | marginTop 20 |
| layout_record_background | 5 | LedMainRecordChartSection / Card | marginTop 4, card 10dp 圓角 |
| tv_scene_title + btn_scene_more | 6 | _SceneHeader (ledScene) | marginTop 24 |
| rv_favorite_scene | 7 | _FavoriteSceneArea | padding 8, horizontal scroll |
| progress | 8 | _ProgressOverlay | gone by default |

### 2. Dosing Main (activity_drop_main.xml ↔ dosing_main_page.dart)

| reef | koralcore | 備註 |
|------|-----------|------|
| toolbar_drop_main | _ToolbarDevice | - |
| ScrollView → layout_device | SingleChildScrollView → _DeviceIdentificationSection | 整頁可捲 |
| rv_drop_head | DosingMainPumpHeadList | paddingTop 12, paddingBottom 32 |
| progress | _ProgressOverlay | - |

### 3. Add Device (activity_add_device.xml ↔ add_device_page.dart)

| reef | koralcore | 備註 |
|------|-----------|------|
| toolbar_add_device | _ToolbarTwoAction | Skip/Done |
| tv_device_name_title | _DeviceNameSection caption | caption1 |
| layout_name (TextInputLayout) | TextField | marginTop 4 |
| tv_sink_position_title | _SinkPositionSection caption | marginTop 16 |
| layout_sink_position + view_sink_position | InputDecorator + InkWell overlay | edt enabled=false, overlay 可點 |
| progress | _ProgressOverlay | - |

### 4. Drop Setting (activity_drop_setting.xml ↔ drop_setting_page.dart)

| reef | koralcore | 備註 |
|------|-----------|------|
| tv_device_name_title | Text(caption1) | - |
| layout_name | TextField | marginTop 4 |
| tv_device_position_title | Text(caption1) | marginTop 16 |
| btn_position (MaterialButton) | _BackgroundMaterialButton | ic_next, marginTop 4 |
| tv_delay_time_title | Text(caption1) | marginTop 16 |
| btn_delay_time | _BackgroundMaterialButton | ic_down, marginTop 4 |

### 5. Device Tab 空狀態 (fragment_device layout_no_device)

| reef | koralcore device_tab_page _EmptyState |
|------|--------------------------------------|
| ImageView 172×199 (img_device_robot) | Image 172×199 |
| TextView marginTop 39 (text_no_device_title) | padding top 39 |
| MaterialButton marginTop 8, marginBottom 8 (btn_add_device) | padding top 8, bottom 8 |
| 註：reef rv 有 margin 10/8/10/8 | koralcore GridView padding 10/8/10 |

### 6. Home (fragment_home.xml ↔ home_tab_page.dart)

| reef | koralcore | 差異 |
|------|-----------|------|
| btn_add_sink (左上, visibility gone) | - | koralcore 用 SinkSelectorBar |
| sp_sink_type + img_down + btn_sink_manager | _SinkSelectorBar | reef 用 Spinner；koralcore 用 bar |
| rv_user_device (padding 10/8/10) | GridView / _buildAllSinksView | 相同 |
| layout_no_device_in_sink | _EmptyState (deviceInSinkEmpty*) | 相同 |

---

## 潛在 Layout 差異（已修正 / 待微調）

| 項目 | 位置 | 說明 | 狀態 |
|------|------|------|------|
| line_chart 高度 | activity_led_main layout_record | reef 固定 242dp | ✅ 已修正 minHeight 242 |
| img_device_robot | device_tab | reef drawable 172×199 | ✅ 已補 img_device_robot.svg |
| Home Sink 選擇器 | fragment_home | reef Spinner + img_down + btn_sink_manager | ⚠️ koralcore _SinkSelectorBar 功能對齊 |
| tv_group visibility | led_main | reef gone | ✅ koralcore Visibility(visible: false) |

---

## 總結

- **L1 Section Ordering**：主要頁面順序一致。
- **L2 Fixed/Scrollable**：LED Main 僅場景區捲動、Dosing Main 整頁捲動，皆符合 reef。
- **L3 CTA Placement**：toolbar、FAB、空狀態按鈕位置對齊。
- **L4 Spacing**：透過 AppSpacing、AppRadius 對應 reef dimens，容許 ±1–2dp。
