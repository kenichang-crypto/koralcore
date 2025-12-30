# 字符串對照修正報告

## 問題發現

在使用不同變數名（例如 `tabHome` 而不是 `home`）的情況下，部分字符串在繁體中文中**未正確對照**到 reef-b-app。

---

## 已修正的問題

### ✅ 修正 1: 標籤頁字符串

#### 修正前

```json
{
  "tabHome": "Home",           // ❌ 錯誤：應該是 "首頁"
  "tabBluetooth": "Bluetooth", // ❌ 錯誤：應該是 "藍芽"
  "tabDevice": "Devices"       // ❌ 錯誤：應該是 "裝置"
}
```

#### 修正後

```json
{
  "tabHome": "首頁",           // ✅ 正確對照 reef-b-app 的 home
  "tabBluetooth": "藍芽",     // ✅ 正確對照 reef-b-app 的 bluetooth
  "tabDevice": "裝置"          // ✅ 正確對照 reef-b-app 的 device
}
```

**對照關係**:
- `tabHome` → reef-b-app `home` → "首頁" ✅
- `tabBluetooth` → reef-b-app `bluetooth` → "藍芽" ✅
- `tabDevice` → reef-b-app `device` → "裝置" ✅

---

### ✅ 修正 2: 通用操作按鈕

#### 修正前

```json
{
  "actionCancel": "Cancel",    // ❌ 錯誤：應該是 "取消"
  "actionConfirm": "Confirm"  // ❌ 錯誤：應該是 "確定"
}
```

#### 修正後

```json
{
  "actionCancel": "取消",      // ✅ 正確對照 reef-b-app 的 cancel
  "actionConfirm": "確定"      // ✅ 正確對照 reef-b-app 的 confirm
}
```

**對照關係**:
- `actionCancel` → reef-b-app `cancel` → "取消" ✅
- `actionConfirm` → reef-b-app `confirm` → "確定" ✅

---

### ✅ 修正 3: 設備頁面標題

#### 修正前

```json
{
  "deviceHeader": "設備"  // ⚠️ 部分對照：使用了 "設備" 而不是 "裝置"
}
```

#### 修正後

```json
{
  "deviceHeader": "裝置"  // ✅ 正確對照 reef-b-app 的 device
}
```

**對照關係**:
- `deviceHeader` → reef-b-app `fragment_device_title` → `device` → "裝置" ✅

---

## 對照表

### 標籤頁字符串

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文 | 狀態 |
|-------------|--------------|------|---------|------|
| `tabHome` | `home` | "Home" | "首頁" | ✅ 已修正 |
| `tabBluetooth` | `bluetooth` | "Bluetooth" | "藍芽" | ✅ 已修正 |
| `tabDevice` | `device` | "Devices" | "裝置" | ✅ 已修正 |

### 通用操作按鈕

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文 | 狀態 |
|-------------|--------------|------|---------|------|
| `actionConfirm` | `confirm` | "OK" | "確定" | ✅ 已修正 |
| `actionCancel` | `cancel` | "Cancel" | "取消" | ✅ 已修正 |
| `actionDelete` | `delete` | "Delete" | "刪除" | ✅ 已對照 |
| `actionSave` | `save` | "Save" | "儲存" | ✅ 已對照 |
| `actionEdit` | `edit` | "Edit" | "編輯" | ✅ 已對照 |

### 設備頁面

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文 | 狀態 |
|-------------|--------------|------|---------|------|
| `deviceHeader` | `fragment_device_title` → `device` | "Device" | "裝置" | ✅ 已修正 |
| `deviceSelectMode` | `select` | "Select" | "選取" | ✅ 已對照 |
| `deviceDeleteConfirmPrimary` | `delete` | "Delete" | "刪除" | ✅ 已對照 |
| `deviceDeleteConfirmSecondary` | `cancel` | "Cancel" | "取消" | ✅ 已對照 |

---

## 其他需要檢查的字符串

### ⚠️ 可能未對照的字符串

檢查以下字符串是否在所有語言中都正確對照：

1. **狀態字符串**:
   - `deviceStateConnected`: "Connected" → 應該是 "已連線" 或 "連線中"？
   - `deviceStateDisconnected`: "Disconnected" → 應該是 "未連線" 或 "斷線"？
   - `deviceStateConnecting`: "Connecting" → 應該是 "連線中"？

2. **操作字符串**:
   - `deviceActionConnect`: "Connect" → 應該是 "連線"？
   - `deviceActionDisconnect`: "Disconnect" → 應該是 "斷線"？
   - `deviceDeleteMode`: "Delete" → 應該是 "刪除"？
   - `deviceActionDelete`: "Delete selected" → 應該是 "刪除所選"？

3. **其他字符串**:
   - `deviceEmptySubtitle`: "Use the Bluetooth tab to discover hardware." → 應該是繁體中文？
   - `homeStatusConnected`: "Connected to {device}" → 應該是 "已連線至 {device}"？
   - `homeStatusDisconnected`: "No active device" → 應該是 "目前尚無裝置"？

---

## 修正總結

### ✅ 已修正

1. `tabHome`: "Home" → "首頁" ✅
2. `tabBluetooth`: "Bluetooth" → "藍芽" ✅
3. `tabDevice`: "Devices" → "裝置" ✅
4. `actionCancel`: "Cancel" → "取消" ✅
5. `actionConfirm`: "Confirm" → "確定" ✅
6. `deviceHeader`: "設備" → "裝置" ✅

### ⚠️ 需要進一步檢查

- 狀態字符串（Connected, Disconnected, Connecting）
- 操作字符串（Connect, Disconnect, Delete selected）
- 其他英文字符串是否在繁體中文中正確翻譯

---

## 結論

**部分字符串已修正**，但可能還有其他字符串需要檢查和修正。建議：

1. 檢查所有語言的 ARB 文件
2. 確保所有字符串都正確對照到 reef-b-app
3. 特別注意使用不同變數名的字符串（例如 `tabHome` vs `home`）

