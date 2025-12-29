# 硬編碼字符串修復清單

## 需要立即修復的硬編碼字符串

### 1. 設備數量顯示（高優先級）

**文件**: `lib/ui/features/sink/pages/sink_manager_page.dart` (line 243)

**當前代碼**:
```dart
subtitle: Text(
  '${sink.deviceIds.length} ${sink.deviceIds.length == 1 ? 'device' : 'devices'}',
),
```

**reef-b-app 對照**:
- Android: `text_device_amount` = `"%1$d devices"` (使用複數形式)
- iOS: `sink_list_device_count` = `"%d devices"` (使用複數形式)
- 注意：reef-b-app 統一使用複數形式，無單數形式

**修復方案**:
1. 添加本地化鍵到 `intl_en.arb`:
   ```json
   "sinkDeviceCount": "{count} devices",
   "@sinkDeviceCount": {
     "placeholders": {
       "count": {
         "type": "int"
       }
     }
   }
   ```

2. 修改代碼為:
   ```dart
   subtitle: Text(l10n.sinkDeviceCount(sink.deviceIds.length)),
   ```

---

### 2. 錯誤消息（高優先級）

#### 2.1 `led_setting_page.dart` (line 98)

**當前代碼**:
```dart
SnackBar(content: Text('Failed to save settings: $error'))
```

**修復方案**:
```dart
SnackBar(content: Text(describeAppError(l10n, AppErrorCode.unknownError)))
```

#### 2.2 `led_main_page.dart` (line 166)

**當前代碼**:
```dart
content: Text('Failed to toggle favorite: $error')
```

**修復方案**:
```dart
showErrorSnackBar(context, AppErrorCode.unknownError)
```

---

### 3. Controller 錯誤消息（中優先級）

**文件**: `lib/ui/features/sink/controllers/sink_manager_controller.dart`

這些錯誤消息會顯示在 UI 上（通過 `ErrorStateWidget`），應該本地化。

**需要添加的本地化鍵**:
- `sinkManagerErrorLoadFailed`: "Failed to load sinks"
- `sinkManagerErrorAddFailed`: "Failed to add sink"
- `sinkManagerErrorEditFailed`: "Failed to edit sink"
- `sinkManagerErrorDeleteFailed`: "Failed to delete sink"

**修復方案**:
1. 將錯誤消息改為錯誤代碼（使用 `AppErrorCode`）
2. 或在 Controller 中接受 `AppLocalizations` 參數
3. 或使用 `describeAppError()` 在 UI 層處理

---

## 已完成修復的硬編碼字符串 ✅

### 1. Cancel/Discard 按鈕 ✅
- 所有 `'Cancel'` 和 `'Discard'` 已替換為 `l10n.actionCancel`

### 2. UI 標籤和選項 ✅
- `'Spectrum'` → `l10n.ledRecordTimeSettingSpectrumLabel`
- `'Default'` → `l10n.sinkTypeDefault`
- `'ID: ${scene.sceneIdString}'` → `l10n.ledSceneIdLabel(...)`
- `'Local Scenes'` → `l10n.ledSceneDeleteLocalScenesTitle`
- `'Device Scenes (Read-only)'` → `l10n.ledSceneDeleteDeviceScenesTitle`
- `'Cannot delete device scenes'` → `l10n.ledSceneDeleteCannotDeleteDeviceScenes`
- `'Preset Scene' / 'Device Scene'` → `l10n.ledScenePreset / l10n.ledSceneCustom`
- 所有下拉選項（No Schedule, 24-Hour Average, Single Dose, Custom）已本地化

### 3. 錯誤和成功消息 ✅
- 大部分錯誤消息已替換為 `describeAppError()` 或 `showErrorSnackBar()`
- 大部分成功消息已使用本地化字符串

---

## 下一步行動

1. ✅ **修復設備數量顯示** - 添加 `sinkDeviceCount` 本地化鍵 ✅ 完成
2. ✅ **修復剩餘錯誤消息** - 使用 `describeAppError()` 或 `showErrorSnackBar()` ✅ 完成
3. ✅ **處理 Controller 錯誤消息** - 使用錯誤代碼 (`AppErrorCode`) ✅ 完成
4. ✅ **驗證所有修復** - 確保所有更改都對應了 reef-b-app 的實現 ✅ 完成

---

## 修復完成總結 ✅

### 1. 設備數量顯示 ✅
- **文件**: `lib/ui/features/sink/pages/sink_manager_page.dart`
- **修復**: 添加 `sinkDeviceCount` 本地化鍵，使用 `l10n.sinkDeviceCount(sink.deviceIds.length)`
- **對應 reef-b-app**: 使用複數形式 `"%1$d devices"`

### 2. 錯誤消息 ✅
- **`led_setting_page.dart`** (line 98): 使用 `describeAppError(l10n, AppErrorCode.unknownError)`
- **`led_main_page.dart`** (line 166): 使用 `showErrorSnackBar(context, AppErrorCode.unknownError)`

### 3. Controller 錯誤消息 ✅
- **`sink_manager_controller.dart`**: 
  - 添加 `AppErrorCode? _errorCode` 字段
  - 所有錯誤設置為 `AppErrorCode.unknownError`
  - UI 層使用 `ErrorStateWidget` 的 `errorCode` 參數進行本地化顯示
  - 修復了 4 處錯誤消息：`_loadSinks`, `addSink`, `editSink`, `deleteSink`

### 統計
- **已修復**: 6 處硬編碼字符串
- **新增本地化鍵**: 1 個 (`sinkDeviceCount`)
- **所有修復都對應了 reef-b-app 的實現**

