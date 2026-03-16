# 字串與圖標遷移狀態

## 總體統計

- **reef-b-app 總字串數**: 375
- **koralcore 總字串數**: 515
- **缺失字串數**: 366（需要對照檢查）
- **reef-b-app 總圖標數**: 85
- **已轉換圖標數**: 45
- **待轉換圖標數**: 40

## 字串遷移進度

### 已對照的 LED 相關字串

以下字串已在 koralcore 中，但需要驗證是否對照 reef-b-app：

- `ledSettingTitle` → 對照 `activity_led_setting_title` (@string/led_setting)
- `ledRecordSettingTitle` → 對照 `activity_led_record_setting_title` (@string/record_setting)
- `ledRecordTimeSettingTitle` → 對照 `activity_led_record_time_setting_title` (@string/record_time)
- `ledSceneAddTitle` → 對照 `activity_led_scene_add_title` (@string/led_scene_add)
- `ledSceneEditTitle` → 對照 `activity_led_scene_edit_title` (@string/led_scene_edit)
- `ledSceneDeleteTitle` → 對照 `activity_led_scene_delete_title` (@string/led_scene_delete)
- `ledMasterSettingTitle` → 對照 `activity_led_master_setting_title` (@string/master_pairing)

### 缺失的 LED 相關字串（需要添加）

#### Activity 標題和按鈕
- `activity_led_record_title` → "Schedule" / "排程"
- `activity_led_scene_title` → "Scene" / "場景"
- `activity_led_scene_toolbar_right_btn` → "Edit" / "編輯"

#### Dialog 字串
- `dialog_led_delete_time_content` → "Do you want to delete this time point?" / "是否要刪除此時間點？"
- `dialog_led_delete_time_positive` → "Delete" / "刪除"
- `dialog_led_delete_time_negative` → "Cancel" / "取消"
- `dialog_led_clear_record_content` → "Do you want to clear the schedule?" / "是否要清除排程？"
- `dialog_led_clear_record_positive` → "OK" / "確定"
- `dialog_led_clear_record_negative` → "Cancel" / "取消"
- `dialog_led_move_master_title` → "Master-Slave Settings" / "主從設定"
- `dialog_led_move_master_content` → "To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light." / "要將此裝置移至其他水槽，請先修改主從設定，將其他從燈設為主燈。"
- `dialog_led_move_master_positive` → "OK" / "確定"
- `dialog_led_move_master_negative` → "Cancel" / "取消"
- `dialog_scene_delete_scene_content` → "Do you want to delete the scene?" / "是否要刪除場景？"
- `dialog_scene_delete_scene_positive` → "Delete" / "刪除"
- `dialog_scene_delete_scene_negative` → "Cancel" / "取消"

#### 其他 LED 相關字串
- `led_scene` → "Scene" / "場景"
- `led_scene_add` → "Add Scene" / "新增場景"
- `led_scene_edit` → "Scene Settings" / "場景設定"
- `led_scene_delete` → "Delete Scene" / "刪除場景"
- `led_scene_name` → "Scene Name" / "場景名稱"
- `led_scene_icon` → "Scene Icon" / "場景圖標"
- `led_dynamic_scene` → "Dynamic Scene" / "動態場景"
- `led_static_scene` → "Static Scene" / "靜態場景"
- `led_setting` → "LED Settings" / "LED設定"
- `record_setting` → "Schedule Settings" / "排程設定"
- `record` → "Schedule" / "排程"
- `record_time` → "Scheduled Time Point" / "排程時間點"
- `record_pause` → "The schedule is paused." / "排程已暫停。"
- `continue_record` → "Resume execution." / "繼續執行。"
- `preset_scene_off` → "OFF"
- `preset_scene_30` → "30%"
- `preset_scene_60` → "60%"
- `preset_scene_100` → "100%"
- `preset_scene_moon` → "Moonlight" / "月光"
- `preset_scene_thunder` → "Thunder" / "閃電"

## 圖標遷移進度

### 已轉換的圖標（45 個）

#### 場景圖標（11 個）
- ✅ ic_thunder, ic_cloudy, ic_sunny, ic_rainy, ic_dizzle, ic_none, ic_moon, ic_sunrise, ic_sunset, ic_mist, ic_light_off

#### LED Record 圖標（7 個）
- ✅ ic_sun, ic_slow_start, ic_moon_round, ic_down, ic_strength_thumb, ic_default_thumb, ic_moon_light_thumb

#### 通用圖標（24 個）
- ✅ ic_add_black, ic_back, ic_bluetooth, ic_calendar, ic_check, ic_close, ic_delete, ic_device, ic_edit, ic_favorite_select, ic_favorite_unselect, ic_home, ic_master, ic_master_big, ic_menu, ic_minus, ic_moon_round, ic_more_enable, ic_next, ic_pause, ic_play_enabled, ic_play_select, ic_play_unselect, ic_preview, ic_reset, ic_stop, ic_warning, ic_zoom_in, ic_zoom_out

### 待轉換的圖標（40 個）

#### 基本動作圖標（3 個）
- ⏳ ic_add_btn
- ⏳ ic_add_rounded
- ⏳ ic_add_white

#### 光通道拇指圖標（9 個）
- ⏳ ic_blue_light_thumb
- ⏳ ic_cold_white_light_thumb
- ⏳ ic_green_light_thumb
- ⏳ ic_purple_light_thumb
- ⏳ ic_red_light_thumb
- ⏳ ic_royal_blue_light_thumb
- ⏳ ic_uv_light_thumb
- ⏳ ic_warm_white_light_thumb
- ⏳ ic_sun_strength

#### 週選擇圖標（14 個）
- ⏳ ic_monday_select, ic_monday_unselect
- ⏳ ic_tuesday_select, ic_tuesday_unselect
- ⏳ ic_wednesday_select, ic_wednesday_unselect
- ⏳ ic_thursday_select, ic_thursday_unselect
- ⏳ ic_friday_select, ic_friday_unselect
- ⏳ ic_saturday_select, ic_saturday_unselect
- ⏳ ic_sunday_select, ic_sunday_unselect

#### 連接狀態圖標（4 個）
- ⏳ ic_connect
- ⏳ ic_connect_background
- ⏳ ic_disconnect
- ⏳ ic_disconnect_background

#### 其他圖標（10 個）
- ⏳ ic_drop
- ⏳ ic_green_check
- ⏳ ic_manager
- ⏳ ic_more_disable
- ⏳ ic_play_disable
- ⏳ ic_solid_add
- ⏳ ic_warning_robot
- ⏳ ic_launcher_background
- ⏳ ic_launcher_foreground

## 下一步行動

1. **字串遷移**：
   - [ ] 提取所有缺失字串的翻譯（12 種語言）
   - [ ] 添加到所有語言的 ARB 文件
   - [ ] 驗證內容對照 reef-b-app

2. **圖標遷移**：
   - [ ] 轉換剩餘 40 個圖標為 SVG
   - [ ] 替換 koralcore 中所有使用 Material Icons 的地方（64 處）
   - [ ] 更新 pubspec.yaml

3. **驗證**：
   - [ ] 重新生成本地化文件
   - [ ] 檢查編譯錯誤
   - [ ] 驗證 UI 對照

