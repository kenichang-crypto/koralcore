# Reef-B-App L10N 對照分析報告

## 分析日期
2024-12-28

## 四個硬編碼字符串的對照結果

### 1. 'Spectrum' (led_record_time_setting_page.dart)

**reef-b-app 中的情況**:
- 在 `activity_led_record_time_setting.xml` 布局文件中，有 `chart_spectrum` 的 ID
- **沒有在 strings.xml 中找到 "Spectrum" 字符串**
- 布局文件中沒有顯示 "Spectrum" 文字標籤，只有圖表組件
- 這表明 reef-b-app **可能沒有顯示 "Spectrum" 標籤**，或者它根本不需要本地化

**koralcore 中的情況**:
- 在 `led_record_time_setting_page.dart` line 164 處有 `Text('Spectrum', style: ReefTextStyles.title3)`
- 這是作為圖表部分的標題顯示的

**結論**: 
- reef-b-app 可能沒有顯示這個標籤
- 但如果需要顯示，應該使用一個通用的本地化鍵，如 `ledControlChannelsSection` 或 `ledScheduleEditChannelsHeader`
- 建議：可以使用 `l10n.ledControlChannelsSection` 或創建新的鍵如 `ledRecordTimeSettingSpectrumLabel`

---

### 2. 'Default' (sink_manager_page.dart)

**reef-b-app 中的情況**:
- 在 `adapter_sink.xml` 布局文件中，**沒有找到 "Default" 文字標籤**
- 在 `SinkAdapter.kt` 中，只顯示 sink 名稱和設備數量，**沒有顯示 "Default" 標籤**
- **沒有在 strings.xml 中找到專門用於 "Default sink" 的字符串**
- 這表明 reef-b-app **可能沒有顯示 "Default" 標籤**

**koralcore 中的情況**:
- 在 `sink_manager_page.dart` line 246 處有 `const Chip(label: Text('Default'))`
- 用於標識默認 Sink

**結論**:
- reef-b-app 可能沒有顯示這個標籤
- 但如果需要顯示，應該創建一個新的本地化鍵
- 建議：創建 `sinkTypeDefault` 鍵

---

### 3. 'ID: ${scene.sceneIdString}' (led_scene_delete_page.dart)

**reef-b-app 中的情況**:
- 在 `adapter_scene.xml` 和 `SceneAdapter.kt` 中，**沒有顯示 scene ID**
- **沒有在 strings.xml 中找到用於顯示 scene ID 的字符串**
- Scene adapter 只顯示 scene 名稱和圖標，**不顯示 ID**

**koralcore 中的情況**:
- 在 `led_scene_delete_page.dart` line 227 處有 `subtitle: Text('ID: ${scene.sceneIdString}')`
- 這是用於顯示本地場景的 ID

**結論**:
- reef-b-app **沒有顯示 scene ID**
- 這是 koralcore 特有的功能
- 如果保留，應該創建帶參數的本地化鍵
- 建議：創建 `ledSceneIdLabel(id)` 帶參數的鍵，格式為 `"Scene ID: {id}"`

---

### 4. 'Cannot delete device scenes' / 'Device Scenes (Read-only)' (led_scene_delete_page.dart)

**reef-b-app 中的情況**:
- 在 `activity_led_scene_delete.xml` 布局文件中，**沒有找到這些文字**
- 在 `LedSceneDeleteActivity.kt` 中，只處理本地場景的刪除
- 在 `SceneAdapter.kt` 中，只顯示場景名稱和圖標
- 在 strings.xml 中找到 `toast_delete_now_scene`: "Cannot delete the currently in-use scene."
- **沒有找到 "Device Scenes (Read-only)" 或類似的字符串**

**koralcore 中的情況**:
- 在 `led_scene_delete_page.dart` line 97 處有 `Text('Device Scenes (Read-only)')`
- 在 line 315 處有 `Text('Cannot delete device scenes')`
- 這些是用於標識設備場景（只讀）的標籤

**結論**:
- reef-b-app **可能沒有這個功能**，或者實現方式不同
- 如果保留，應該創建對應的本地化鍵
- 建議：
  - 創建 `ledSceneDeleteDeviceScenesTitle`: "Device Scenes (Read-only)"
  - 創建 `ledSceneDeleteCannotDeleteDeviceScenes`: "Cannot delete device scenes"

---

## 實施建議

### 方案 A: 完全按照 reef-b-app（移除不存在的功能）
- 移除 'Spectrum' 標籤（如果布局允許）
- 移除 'Default' 標籤
- 移除 scene ID 顯示
- 移除 "Device Scenes (Read-only)" 部分（如果功能不需要）

### 方案 B: 保留功能但添加本地化（推薦）
- 為所有這些字符串創建對應的本地化鍵
- 這樣既保留了功能，又提供了本地化支持

---

## 需要添加的本地化鍵（方案 B）

1. `ledRecordTimeSettingSpectrumLabel`: "Spectrum"
2. `sinkTypeDefault`: "Default"
3. `ledSceneIdLabel`: "Scene ID: {id}" (帶參數)
4. `ledSceneDeleteDeviceScenesTitle`: "Device Scenes (Read-only)"
5. `ledSceneDeleteCannotDeleteDeviceScenes`: "Cannot delete device scenes"

---

## 下一步行動

建議採用**方案 B**，因為：
1. 這些功能可能對用戶有用
2. 添加本地化鍵的成本較低
3. 不會破壞現有功能

需要我實施方案 B 嗎？

