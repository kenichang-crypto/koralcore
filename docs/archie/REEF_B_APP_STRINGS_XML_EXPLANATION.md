# reef-b-app strings.xml 內容及用法說明

## 概述

reef-b-app 使用 **Android Resource System** 來管理多語言字符串，所有字符串資源都定義在 `res/values-XX/strings.xml` 文件中。

---

## 1. 文件結構

### 1.1 文件位置

```
reef-b-app/android/ReefB_Android/app/src/main/res/
├── values/strings.xml              # 英文（預設語言）
├── values-ar/strings.xml           # 阿拉伯語
├── values-de/strings.xml           # 德語
├── values-es/strings.xml           # 西班牙語
├── values-fr/strings.xml           # 法語
├── values-in/strings.xml           # 印尼語
├── values-ja/strings.xml           # 日語
├── values-ko/strings.xml           # 韓語
├── values-pt/strings.xml           # 葡萄牙語
├── values-ru/strings.xml           # 俄語
├── values-th/strings.xml           # 泰語
├── values-vi/strings.xml            # 越南語
└── values-zh-rTW/strings.xml       # 繁體中文（台灣）
```

**注意**：
- ✅ **只有繁體中文**（`values-zh-rTW`），**沒有簡體中文**
- ✅ 預設語言是英文（`values/strings.xml`）

---

## 2. strings.xml 文件格式

### 2.1 基本結構

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- 字符串定義 -->
    <string name="key_name">String Value</string>
    
    <!-- 引用其他字符串 -->
    <string name="referenced_key">@string/other_key</string>
    
    <!-- 帶參數的字符串 -->
    <string name="formatted_string">Hello %1$s, you have %2$d messages</string>
</resources>
```

### 2.2 實際範例（values/strings.xml）

```xml
<resources>
    <!-- 應用名稱 -->
    <string name="app_name">ReefB</string>
    
    <!-- 權限相關 -->
    <string name="get_gps_permission">Please authorize GPS location permission</string>
    <string name="get_nerby_permission">Please authorize nearby device permission</string>
    
    <!-- 通用按鈕 -->
    <string name="confirm">OK</string>
    <string name="delete">Delete</string>
    <string name="cancel">Cancel</string>
    <string name="save">Save</string>
    
    <!-- 標籤頁 -->
    <string name="home">Home</string>
    <string name="bluetooth">Bluetooth</string>
    <string name="device">Device</string>
    
    <!-- 引用其他字符串 -->
    <string name="bottom_navigation_home">@string/home</string>
    <string name="menu_favorite">@string/favorite</string>
    
    <!-- 帶參數的字符串 -->
    <string name="text_device_amount">%1$d devices</string>
</resources>
```

### 2.3 繁體中文範例（values-zh-rTW/strings.xml）

```xml
<resources>
    <!-- 應用名稱 -->
    <string name="app_name">ReefB</string>
    
    <!-- 權限相關 -->
    <string name="get_gps_permission">請授權GPS定位權限</string>
    <string name="get_nerby_permission">請授權鄰近裝置</string>
    
    <!-- 通用按鈕 -->
    <string name="confirm">確定</string>
    <string name="delete">刪除</string>
    <string name="cancel">取消</string>
    <string name="save">儲存</string>
    
    <!-- 標籤頁 -->
    <string name="home">首頁</string>
    <string name="bluetooth">藍芽</string>
    <string name="device">裝置</string>
</resources>
```

---

## 3. 字符串分類

### 3.1 分類結構（根據註釋）

根據 `values/strings.xml` 的註釋，字符串分為以下類別：

1. **權限相關** (`/**     權限相關 **/`)
   - `get_gps_permission`
   - `get_nerby_permission`
   - `get_camera_storage_permission`
   - `please_open_gps`
   - `please_open_ble`
   - `toast_connect_failed`
   - `toast_connect_successful`
   - `toast_disconnect`

2. **通用** (`/**     通用 **/`)
   - `confirm`, `delete`, `cancel`, `select`, `skip`, `complete`, `save`, `edit`
   - `i_konw`, `next`, `close`, `back`, `no`, `run`, `rearrangement`

3. **設備類型**
   - `led` - LED
   - `drop` - Dosing Pump（滴液泵）

4. **標籤頁**
   - `home` - Home（首頁）
   - `bluetooth` - Bluetooth（藍芽）
   - `device` - Device（裝置）

5. **預設場景** (`/**     預設場景 **/`)
   - `preset_scene_off`, `preset_scene_30`, `preset_scene_60`, `preset_scene_100`
   - `preset_scene_moon`, `preset_scene_thunder`

6. **光譜名字** (`/**     光譜名字 **/`)
   - `uv`, `purple`, `blue`, `royal_blue`, `green`, `red`
   - `cold_white`, `warm_white`, `moon`
   - `light_uv`, `light_purple`, `light_blue`, ...

7. **滴液泵排程種類** (`/**     滴液泵排程種類 **/`)
   - `drop_record_type_custom`, `drop_record_type_single`
   - `drop_record_type_24`, `drop_record_type_none`

8. **單位** (`/**     單位 **/`)
   - `minute`, `init_minute`, `times`, `group`

9. **主從設定**
   - `master_setting`, `setting_master`, `master_pairing`
   - `master_slave`, `set_master`, `move_group`, `choose_group`

10. **Toast 消息** (`/**     toast **/`)
    - `toast_connect_limit`, `toast_name_is_empty`
    - `toast_add_sink_successful`, `toast_delete_device_successful`
    - `toast_delete_device_failed`, ...

11. **Activity/Fragment 特定字符串**
    - `/**     MainActivity **/`
    - `/**     HomeFragment **/`
    - `/**     DeviceFragment **/`
    - `/**     BluetoothFragment **/`
    - `/**     WarningActivity **/`
    - `/**     SinkManagerActivity **/`
    - `/**     LedMainActivity **/`
    - `/**     LedSettingActivity **/`
    - `/**     DropSettingActivity **/`
    - ...

---

## 4. reef-b-app 中的用法

### 4.1 在 Kotlin 代碼中使用

#### 基本用法

```kotlin
// 在 Activity/Fragment 中
class LedMainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 方法 1: 使用 getString()
        val deviceName = getString(R.string.device)
        // 結果：英文 "Device"，繁體中文 "裝置"
        
        // 方法 2: 直接在 XML 中使用
        // <TextView android:text="@string/device" />
    }
}
```

#### 實際範例（LedMainActivity.kt）

```kotlin
// 設置文本
binding.tvPosition?.text = getString(R.string.unassigned_device)
// 結果：英文 "Unallocated Devices"，繁體中文 "未分配裝置"

binding.tvGroup?.text = "${getString(R.string.group)}$it"
// 結果：英文 "Group1"，繁體中文 "群組1"

// 顯示 Toast
(R.string.toast_delete_device_successful).toast(this)
// 結果：英文 "Successfully deleted device."
//      繁體中文 "刪除設備成功"

(R.string.toast_connect_successful).toast(this)
// 結果：英文 "Connection successful."
//      繁體中文 "連線成功"

// 設置圖表數據集標籤
val uvDataSet = LineDataSet(mutableListOf(), getString(R.string.uv))
val purpleDataSet = LineDataSet(mutableListOf(), getString(R.string.purple))
val blueDataSet = LineDataSet(mutableListOf(), getString(R.string.blue))
// 結果：英文 "UV", "Purple", "Blue"
//      繁體中文 "UV", "紫色", "藍色"
```

#### 帶參數的字符串

```kotlin
// 定義（strings.xml）
<string name="text_device_amount">%1$d devices</string>

// 使用（Kotlin）
val deviceCount = 5
val message = getString(R.string.text_device_amount, deviceCount)
// 結果：英文 "5 devices"
//      繁體中文 "5 個裝置"
```

### 4.2 在 XML Layout 中使用

```xml
<!-- activity_led_main.xml -->
<TextView
    android:id="@+id/tvPosition"
    android:text="@string/unassigned_device" />

<TextView
    android:id="@+id/tvGroup"
    android:text="@string/group" />

<Button
    android:text="@string/delete" />
```

### 4.3 字符串引用（@string/）

reef-b-app 使用 `@string/` 來引用其他字符串：

```xml
<!-- 定義基礎字符串 -->
<string name="home">Home</string>
<string name="bluetooth">Bluetooth</string>
<string name="device">Device</string>

<!-- 引用基礎字符串 -->
<string name="bottom_navigation_home">@string/home</string>
<string name="bottom_navigation_bluetooth">@string/bluetooth</string>
<string name="bottom_navigation_device">@string/device</string>

<!-- 引用通用按鈕 -->
<string name="menu_favorite">@string/favorite</string>
<string name="menu_edit">@string/edit</string>
<string name="menu_delete">@string/delete</string>
```

**優點**：
- 避免重複定義
- 統一管理
- 修改一處，所有引用自動更新

---

## 5. Android Resource System 自動語言切換

### 5.1 工作原理

1. **系統語言檢測**：
   - Android 系統讀取設備語言設置
   - 例如：繁體中文（台灣）→ `zh_TW`

2. **資源文件匹配**：
   - Android 自動查找對應的 `values-XX/strings.xml`
   - `zh_TW` → `values-zh-rTW/strings.xml`
   - 如果找不到，使用 `values/strings.xml`（英文）

3. **自動加載**：
   - `getString(R.string.key)` 自動返回對應語言的字符串
   - 無需手動切換語言

### 5.2 語言匹配規則

| 系統語言 | 匹配的資源文件 |
|---------|--------------|
| 英文（en） | `values/strings.xml` |
| 繁體中文（zh_TW） | `values-zh-rTW/strings.xml` |
| 日語（ja） | `values-ja/strings.xml` |
| 韓語（ko） | `values-ko/strings.xml` |
| 其他語言 | `values/strings.xml`（fallback） |

---

## 6. 字符串鍵命名規則

### 6.1 命名模式

1. **通用按鈕**：直接使用動作名稱
   - `confirm`, `delete`, `cancel`, `save`, `edit`

2. **Toast 消息**：`toast_` 前綴
   - `toast_connect_successful`
   - `toast_delete_device_successful`
   - `toast_delete_device_failed`

3. **Fragment/Activity 特定**：`fragment_` 或 `activity_` 前綴
   - `fragment_device_title`
   - `activity_warning_title`
   - `activity_led_setting_title`

4. **Dialog**：`dialog_` 前綴
   - `dialog_device_delete`
   - `dialog_delete_warning_content`
   - `dialog_delete_sink_title`

5. **文本內容**：`text_` 前綴
   - `text_no_device_title`
   - `text_no_device_content`
   - `text_no_warning_title`

6. **Bottom Sheet**：`bottom_sheet_` 前綴
   - `bottom_sheet_add_sink_title`
   - `bottom_sheet_edit_sink_title`

---

## 7. 與 koralcore 的對照

### 7.1 語言對照

| reef-b-app | koralcore | 說明 |
|-----------|-----------|------|
| `values/strings.xml` | `intl_en.arb` | 英文（預設） |
| `values-zh-rTW/strings.xml` | `intl_zh_Hant.arb` | 繁體中文 |
| `values-ja/strings.xml` | `intl_ja.arb` | 日語 |
| `values-ko/strings.xml` | `intl_ko.arb` | 韓語 |
| ... | ... | ... |

**注意**：
- ✅ reef-b-app **只有繁體中文**（`values-zh-rTW`），**沒有簡體中文**
- ✅ koralcore 應該**移除簡體中文**（`intl_zh.arb`），只保留繁體中文（`intl_zh_Hant.arb`）

### 7.2 使用方式對照

| reef-b-app | koralcore |
|-----------|-----------|
| `getString(R.string.key)` | `AppLocalizations.of(context).key` |
| `@string/key` (XML) | `l10n.key` (Dart) |
| `getString(R.string.key, arg1, arg2)` | `l10n.key(arg1, arg2)` |

---

## 8. 總結

### ✅ reef-b-app strings.xml 特點

1. **文件位置**：`res/values-XX/strings.xml`
2. **預設語言**：英文（`values/strings.xml`）
3. **支持的語言**：13 種（**沒有簡體中文**，只有繁體中文）
4. **格式**：Android XML 字符串資源
5. **使用方式**：
   - Kotlin: `getString(R.string.key)`
   - XML: `@string/key`
6. **自動語言切換**：Android Resource System 自動處理

### ✅ 字符串分類

- 權限相關
- 通用按鈕
- 設備類型
- 標籤頁
- 預設場景
- 光譜名字
- 滴液泵排程
- Toast 消息
- Activity/Fragment 特定字符串

### ✅ 命名規則

- 通用：直接使用動作名稱
- Toast：`toast_` 前綴
- Fragment/Activity：`fragment_` / `activity_` 前綴
- Dialog：`dialog_` 前綴
- 文本：`text_` 前綴

