# 字符串鍵對照問題分析

## 問題描述

koralcore 使用了不同的變數名（例如 `tabHome` 而不是 `home`），需要確認在對照 reef-b-app 的字符串和語系時，是否正確轉換過來。

---

## 發現的問題

### ❌ 問題 1: `tabHome`, `tabBluetooth`, `tabDevice` 在繁體中文中未正確對照

#### reef-b-app (values-zh-rTW/strings.xml)

```xml
<string name="home">首頁</string>
<string name="bluetooth">藍芽</string>
<string name="device">裝置</string>
```

#### koralcore (intl_zh_Hant.arb)

```json
{
  "tabHome": "Home",        // ❌ 錯誤：應該是 "首頁"
  "tabBluetooth": "Bluetooth",  // ❌ 錯誤：應該是 "藍芽"
  "tabDevice": "Devices"     // ❌ 錯誤：應該是 "裝置"
}
```

**問題**: 繁體中文版本中，`tabHome`, `tabBluetooth`, `tabDevice` 仍然使用英文，沒有對照到 reef-b-app 的繁體中文翻譯。

---

### ❌ 問題 2: `deviceHeader` 在繁體中文中未正確對照

#### reef-b-app (values-zh-rTW/strings.xml)

```xml
<string name="fragment_device_title">@string/device</string>
<!-- device = "裝置" -->
```

#### koralcore (intl_zh_Hant.arb)

```json
{
  "deviceHeader": "設備"  // ⚠️ 部分對照：使用了 "設備" 而不是 "裝置"
}
```

**問題**: `deviceHeader` 使用了 "設備"，但 reef-b-app 使用 "裝置"。

---

### ✅ 正確對照的範例

#### `actionConfirm`, `actionCancel`, `actionDelete`, `actionSave`

**reef-b-app (values-zh-rTW/strings.xml)**:
```xml
<string name="confirm">確定</string>
<string name="cancel">取消</string>
<string name="delete">刪除</string>
<string name="save">儲存</string>
```

**koralcore (intl_zh_Hant.arb)**:
```json
{
  "actionConfirm": "確定",    // ✅ 正確對照
  "actionCancel": "取消",     // ✅ 正確對照
  "actionDelete": "刪除",     // ✅ 正確對照
  "actionSave": "儲存"        // ✅ 正確對照
}
```

---

## 需要修正的字符串

### 1. 標籤頁字符串

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `tabHome` | `home` | "Home" | "首頁" | ❌ "Home" |
| `tabBluetooth` | `bluetooth` | "Bluetooth" | "藍芽" | ❌ "Bluetooth" |
| `tabDevice` | `device` | "Devices" | "裝置" | ❌ "Devices" |

### 2. 設備頁面字符串

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `deviceHeader` | `fragment_device_title` → `device` | "Device" | "裝置" | ⚠️ "設備" |

---

## 修正方案

### 修正 `intl_zh_Hant.arb`

需要將以下字符串更新為正確的繁體中文翻譯：

```json
{
  "tabHome": "首頁",           // 修正：從 "Home" → "首頁"
  "tabBluetooth": "藍芽",     // 修正：從 "Bluetooth" → "藍芽"
  "tabDevice": "裝置",        // 修正：從 "Devices" → "裝置"
  "deviceHeader": "裝置"      // 修正：從 "設備" → "裝置"（與 reef-b-app 一致）
}
```

---

## 其他語言檢查

需要檢查所有語言的 ARB 文件，確保：
1. `tabHome` 對照到 `home`
2. `tabBluetooth` 對照到 `bluetooth`
3. `tabDevice` 對照到 `device`
4. `deviceHeader` 對照到 `fragment_device_title` → `device`

---

## 總結

### ❌ 發現的問題

1. **`tabHome`**: 繁體中文使用 "Home" 而不是 "首頁"
2. **`tabBluetooth`**: 繁體中文使用 "Bluetooth" 而不是 "藍芽"
3. **`tabDevice`**: 繁體中文使用 "Devices" 而不是 "裝置"
4. **`deviceHeader`**: 繁體中文使用 "設備" 而不是 "裝置"（與 reef-b-app 一致）

### ✅ 正確對照的

- `actionConfirm` → "確定" ✅
- `actionCancel` → "取消" ✅
- `actionDelete` → "刪除" ✅
- `actionSave` → "儲存" ✅

### 📝 結論

**部分字符串未正確對照**，特別是標籤頁相關的字符串（`tabHome`, `tabBluetooth`, `tabDevice`）在繁體中文中仍然使用英文，需要修正。

