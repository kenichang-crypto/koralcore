# 硬編碼字符串全面審計報告

## 審計日期
2024-12-28

## 審計範圍
- `lib/ui/features/` 目錄下的所有 Dart 文件
- 重點檢查：`Text('...')`, `Text("...")`, `const Text(...)` 中的硬編碼字符串
- 排除項：已使用 `l10n.` 的字符串、技術標識符、錯誤代碼

---

## 已修復的硬編碼字符串 ✅

### 1. Cancel/Discard 按鈕 ✅
- `warning_page.dart`, `led_scene_delete_page.dart`, `sink_position_page.dart`, `drop_type_page.dart`, `led_control_page.dart`
- 全部已替換為 `l10n.actionCancel`

### 2. 錯誤和成功消息 ✅
- 設備設置、LED 設置、Dosing 設置等頁面的錯誤/成功消息
- 全部已替換為 `describeAppError()` 或本地化字符串

### 3. UI 標籤和選項 ✅
- `'No Schedule'`, `'24-Hour Average'`, `'Single Dose'`, `'Custom'` → 已本地化
- `'Spectrum'` → `l10n.ledRecordTimeSettingSpectrumLabel`
- `'Default'` → `l10n.sinkTypeDefault`
- `'ID: ${scene.sceneIdString}'` → `l10n.ledSceneIdLabel(...)`
- `'Local Scenes'` → `l10n.ledSceneDeleteLocalScenesTitle`
- `'Device Scenes (Read-only)'` → `l10n.ledSceneDeleteDeviceScenesTitle`
- `'Cannot delete device scenes'` → `l10n.ledSceneDeleteCannotDeleteDeviceScenes`
- `'Preset Scene' / 'Device Scene'` → `l10n.ledScenePreset / l10n.ledSceneCustom`

---

## 待檢查的硬編碼字符串 🔍

### 發現的硬編碼（需要修復）

1. **`sink_manager_page.dart`** (line 243):
   ```dart
   subtitle: Text(
     '${sink.deviceIds.length} ${sink.deviceIds.length == 1 ? 'device' : 'devices'}',
   ),
   ```
   - **reef-b-app 對照**: 
     - Android: `text_device_amount` = `"%1$d devices"` (使用複數形式，無單數)
     - iOS: `sink_list_device_count` = `"%d devices"`
   - **需要本地化**: ✅ 是，應該使用帶參數的本地化鍵 `sinkDeviceCount`

2. **`led_setting_page.dart`** (line 98):
   ```dart
   SnackBar(content: Text('Failed to save settings: $error'))
   ```
   - **狀態**: ⚠️ 這個應該已經修復，但代碼中仍然存在
   - **需要本地化**: ✅ 是，應該使用 `describeAppError()`

3. **`led_main_page.dart`** (line 166):
   ```dart
   content: Text('Failed to toggle favorite: $error')
   ```
   - **狀態**: ⚠️ 這個應該已經修復，但代碼中仍然存在
   - **需要本地化**: ✅ 是，應該使用 `showErrorSnackBar()`

---

## 需要添加的本地化鍵

### 1. Device Count (設備數量)

**當前硬編碼**:
```dart
'${sink.deviceIds.length} ${sink.deviceIds.length == 1 ? 'device' : 'devices'}'
```

**reef-b-app 中的實現**:
- 字符串鍵: `text_device_amount` = `"%1$d devices"`
- 用法: `context.getString(R.string.text_device_amount, data.devices.size)`
- 注意：reef-b-app 使用複數形式，沒有單數形式

**建議的本地化鍵**:
- `sinkDeviceCount`: `"{count} devices"`
- 或者重用已有的設備相關鍵（如果存在）

---

## 其他潛在硬編碼檢查清單

### 需要檢查的常見位置：
1. ✅ SnackBar 消息 - 已檢查並修復
2. ✅ Dialog 內容 - 已檢查並修復
3. ✅ Button 標籤 - 已檢查並修復
4. 🔍 複數形式字符串（如 device/devices）- **發現 1 處**
5. ✅ 錯誤消息 - 已檢查並修復
6. ✅ 成功消息 - 已檢查並修復
7. ✅ UI 標籤 - 已檢查並修復

### 合理的硬編碼（不需要本地化）：
- 技術標識符（ID、UUID等）
- 調試消息
- 註釋中的字符串
- 正則表達式模式
- 文件路徑
- URL

---

## 下一步行動

1. ⏳ **修復 device/devices 複數形式**
   - 文件: `lib/ui/features/sink/pages/sink_manager_page.dart`
   - 添加本地化鍵: `sinkDeviceCount`
   - 對照 reef-b-app 的實現

2. ⏳ **全面搜索其他複數形式**
   - 搜索所有包含單數/複數判斷的字符串
   - 檢查是否還有其他類似的硬編碼

3. ✅ **驗證所有已修復的字符串**
   - 確保所有更改都對應了 reef-b-app 的實現

---

## 其他發現的硬編碼（Controller 層）

以下是在 Controller 中的硬編碼錯誤消息（用於內部狀態管理，可能需要本地化）：

4. **`sink_manager_controller.dart`**:
   - Line 44: `'Failed to load sinks: $e'`
   - Line 93: `'Failed to add sink: $e'`
   - Line 141: `'Failed to edit sink: $e'`
   - Line 172: `'Failed to delete sink: $e'`
   - **備註**: 這些是 Controller 內部的錯誤消息，會顯示在 UI 上，應該本地化

---

## 統計

- **已修復**: ~25+ 處硬編碼字符串
- **待修復**: 6 處硬編碼字符串
  - 1 處設備數量顯示（device/devices 複數形式）
  - 2 處錯誤消息（led_setting_page, led_main_page）
  - 4 處 Controller 錯誤消息（sink_manager_controller）
- **合理硬編碼**: 無需本地化的技術字符串（品牌名稱、技術標識符等）

