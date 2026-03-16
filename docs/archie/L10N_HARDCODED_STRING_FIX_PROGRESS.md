# L10N 硬編碼字符串修復進度

## 修復日期
2024-12-28

## 已完成修復

### 1. Cancel 按鈕 ✅

已將以下文件中的硬編碼 `'Cancel'` 或 `'Discard'` 替換為 `l10n.actionCancel`：

1. ✅ `lib/ui/features/warning/pages/warning_page.dart` (line 120)
2. ✅ `lib/ui/features/led/pages/led_scene_delete_page.dart` (line 249)
3. ✅ `lib/ui/features/sink/pages/sink_position_page.dart` (line 143)
4. ✅ `lib/ui/features/dosing/pages/drop_type_page.dart` (3 處：lines 200, 255, 315)
5. ✅ `lib/ui/features/led/pages/led_control_page.dart` (line 104 - 'Discard' 改為 actionCancel)

**總計**: 6 處修復完成 ✅

**驗證**: 所有硬編碼 `const Text('Cancel')` 已全部清除（0 處剩餘）

---

## 待修復項目

### 2. 錯誤和成功消息 ✅

已修復以下錯誤和成功消息：

#### 錯誤消息
- ✅ `'Failed to save settings: $error'` - 3 處
  - `device_settings_page.dart` (line 98) - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
  - `led_setting_page.dart` (line 100) - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
  - `drop_setting_page.dart` (line 112) - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
  
- ✅ `'Failed to toggle favorite: $error'` - 2 處
  - `led_main_page.dart` (line 166) - 改為 `showErrorSnackBar(context, AppErrorCode.unknownError)`
  - `dosing_main_page.dart` (line 90) - 改為 `showErrorSnackBar(context, AppErrorCode.unknownError)`

#### 成功消息
- ✅ `'Device reset successfully'` - `led_main_page.dart` (line 1237) - 改為 `showSuccessSnackBar(context, l10n.deviceResetSuccess)`
- ✅ `'Schedule saved'` - `pump_head_record_setting_page.dart` (line 572) - 改為 `l10n.dosingScheduleEditSuccess`

#### Dosing Main Page Helpers
- ✅ `'Failed to reset device: ${error.toString()}'` - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
- ✅ `'Dosing started for head $headId'` - 改為使用 `l10n.dosingPumpHeadStatusReady`
- ✅ `'Failed to start dosing: ${error.toString()}'` - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
- ✅ `'Device connected successfully'` - 改為 `l10n.snackbarDeviceConnected`
- ✅ `'Failed to connect: ${error.toString()}'` - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`
- ✅ `'Device disconnected'` - 改為 `l10n.snackbarDeviceDisconnected`
- ✅ `'Failed to disconnect: ${error.toString()}'` - 改為 `describeAppError(l10n, AppErrorCode.unknownError)`

**總計**: 13 處修復完成 ✅

### 3. UI 標籤和選項 ⏳

以下錯誤消息需要修復或檢查是否有對應的本地化鍵：

#### 錯誤消息
- ⏳ `'Failed to save settings: $error'` - 3 處
  - `device_settings_page.dart` (line 98)
  - `led_setting_page.dart` (line 100)
  - `drop_setting_page.dart` (line 112)
  
- ⏳ `'Failed to toggle favorite: $error'` - 2 處
  - `led_main_page.dart` (line 166)
  - `dosing_main_page.dart` (line 90)

#### 成功消息
- ⏳ `'Device reset successfully'` - `led_main_page.dart` (line 1237)
- ⏳ `'Schedule saved'` - `pump_head_record_setting_page.dart` (line 572)
- ⏳ `'Dosing started for head $headId'` - `dosing_main_page_helpers.dart`
- ⏳ `'Device connected successfully'` - `dosing_main_page_helpers.dart`
- ⏳ `'Device disconnected'` - `dosing_main_page_helpers.dart`

#### Dosing Main Page Helpers
- ⏳ `'Failed to reset device: ${error.toString()}'`
- ⏳ `'Failed to start dosing: ${error.toString()}'`
- ⏳ `'Failed to connect: ${error.toString()}'`
- ⏳ `'Failed to disconnect: ${error.toString()}'`

### 3. UI 標籤和選項 ✅

已修復以下 UI 標籤：

- ✅ `'No Schedule'` - `pump_head_record_setting_page.dart` - 改為 `l10n.dosingScheduleTypeNone`
- ✅ `'24-Hour Average'` - `pump_head_record_setting_page.dart` - 改為 `l10n.dosingScheduleType24h`
- ✅ `'Single Dose'` - `pump_head_record_setting_page.dart` - 改為 `l10n.dosingScheduleTypeSingle`
- ✅ `'Custom'` - `pump_head_record_setting_page.dart` - 改為 `l10n.dosingScheduleTypeCustom`
- ✅ `'Spectrum'` - `led_record_time_setting_page.dart` - 改為 `l10n.ledRecordTimeSettingSpectrumLabel`
- ✅ `'Default'` - `sink_manager_page.dart` - 改為 `l10n.sinkTypeDefault`
- ✅ `'ID: ${scene.sceneIdString}'` - `led_scene_delete_page.dart` - 改為 `l10n.ledSceneIdLabel(scene.sceneIdString)`
- ✅ `'Local Scenes'` - `led_scene_delete_page.dart` - 改為 `l10n.ledSceneDeleteLocalScenesTitle`
- ✅ `'Device Scenes (Read-only)'` - `led_scene_delete_page.dart` - 改為 `l10n.ledSceneDeleteDeviceScenesTitle`
- ✅ `'Cannot delete device scenes'` - `led_scene_delete_page.dart` - 改為 `l10n.ledSceneDeleteCannotDeleteDeviceScenes`
- ✅ `'Preset Scene' / 'Device Scene'` - `led_scene_delete_page.dart` - 改為 `l10n.ledScenePreset / l10n.ledSceneCustom`

**總計**: 11 處修復完成 ✅

**新增本地化鍵**:
- `ledRecordTimeSettingSpectrumLabel`: "Spectrum"
- `sinkTypeDefault`: "Default"
- `ledSceneIdLabel`: "Scene ID: {id}" (帶參數)
- `ledSceneDeleteLocalScenesTitle`: "Local Scenes"
- `ledSceneDeleteDeviceScenesTitle`: "Device Scenes (Read-only)"
- `ledSceneDeleteCannotDeleteDeviceScenes`: "Cannot delete device scenes"

### 4. Splash Page ⏳

- ⏳ `'Reef Aquarium Control System'` - `splash_page.dart` (line 86)
  - 備註: `'KoralCore'` 是品牌名稱，可能可以保留

---

## 下一步行動

1. ⏳ **檢查並添加缺失的本地化鍵** - 檢查 `intl_en.arb` 是否有對應的鍵
2. ⏳ **修復錯誤和成功消息** - 將硬編碼的錯誤消息替換為本地化字符串
3. ⏳ **修復 UI 標籤** - 將硬編碼的 UI 標籤替換為本地化字符串
4. ⏳ **更新所有語言的 ARB 文件** - 添加新的本地化字符串到所有語言文件

---

## 修復統計

- ✅ **已完成**: 6 處（Cancel 按鈕）
- ⏳ **待修復**: 約 25+ 處
- **總計**: 約 31+ 處硬編碼字符串

