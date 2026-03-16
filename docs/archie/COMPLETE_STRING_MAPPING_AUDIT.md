# 完整字符串對照審計報告

## 審計範圍

全面檢查 koralcore 的所有 ARB 文件中的字符串是否正確對照到 reef-b-app 的 strings.xml。

---

## 發現的問題

### ❌ 問題 1: 繁體中文中仍有大量英文字符串未翻譯

以下字符串在 `intl_zh_Hant.arb` 中仍然是英文，需要對照到 reef-b-app 的繁體中文翻譯：

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
   - `bluetoothHeader`: "Nearby devices" → 應該是 "附近裝置"？
   - `bluetoothScanCta`: "Scan for devices" → 應該是 "掃描裝置"？
   - `bluetoothScanning`: "Scanning..." → 應該是 "掃描中..."？
   - `bluetoothEmptyState`: "No devices found yet." → 應該是 "尚未找到裝置。"？
   - `bluetoothConnect`: "Connect" → 應該是 "連線"？

---

## 需要對照的字符串列表

### 基礎字符串（已部分修正）

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `tabHome` | `home` | "Home" | "首頁" | ✅ 已修正 |
| `tabBluetooth` | `bluetooth` | "Bluetooth" | "藍芽" | ✅ 已修正 |
| `tabDevice` | `device` | "Devices" | "裝置" | ✅ 已修正 |
| `actionConfirm` | `confirm` | "OK" | "確定" | ✅ 已修正 |
| `actionCancel` | `cancel` | "Cancel" | "取消" | ✅ 已修正 |
| `deviceHeader` | `fragment_device_title` → `device` | "Device" | "裝置" | ✅ 已修正 |

### 設備頁面字符串（需要修正）

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `deviceEmptyTitle` | `text_no_device_title` | "No devices currently available." | "目前尚無裝置" | ✅ 已對照 |
| `deviceEmptySubtitle` | - | "Use the Bluetooth tab to discover hardware." | ❌ 英文 | ⚠️ 需要修正 |
| `deviceInSinkEmptyTitle` | `text_no_device_in_sink_title` | "The tank currently has no devices." | "目前水槽內沒有裝置。" | ✅ 已對照 |
| `deviceInSinkEmptyContent` | `text_no_device_in_sink_content` | "Add devices from the Bluetooth list below." | "請從下方的藍牙列表新增裝置。" | ✅ 已對照 |
| `deviceStateConnected` | - | "Connected" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceStateDisconnected` | - | "Disconnected" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceStateConnecting` | - | "Connecting" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceActionConnect` | - | "Connect" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceActionDisconnect` | - | "Disconnect" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceDeleteMode` | - | "Delete" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceSelectMode` | `fragment_device_select` → `select` | "Select" | "選取" | ✅ 已對照 |
| `deviceActionDelete` | - | "Delete selected" | ❌ 英文 | ⚠️ 需要修正 |
| `deviceSelectionCount` | - | "{count} selected" | ❌ 英文 | ⚠️ 需要修正 |

### 藍牙頁面字符串（需要修正）

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `bluetoothHeader` | `fragment_bluetooth_title` → `bluetooth_connect` | "Nearby devices" | "藍芽連線" | ⚠️ 需要修正 |
| `bluetoothScanCta` | - | "Scan for devices" | ❌ 英文 | ⚠️ 需要修正 |
| `bluetoothScanning` | - | "Scanning..." | ❌ 英文 | ⚠️ 需要修正 |
| `bluetoothEmptyState` | - | "No devices found yet." | ❌ 英文 | ⚠️ 需要修正 |
| `bluetoothConnect` | - | "Connect" | ❌ 英文 | ⚠️ 需要修正 |
| `bluetoothOtherDevice` | `fragment_other_device_title` → `other_device` | "Other Devices" | "其他裝置" | ✅ 已對照 |
| `bluetoothNoOtherDeviceTitle` | `text_no_other_device_title` | "No devices found." | "找不到裝置。" | ✅ 已對照 |
| `bluetoothNoOtherDeviceContent` | `text_no_other_device_content` | "Tap on the top right to rescan nearby devices." | "點擊右上角重新掃描附近裝置。" | ✅ 已對照 |
| `bluetoothDisconnectDialogContent` | `dialog_disconnect_bluetooth_content` | "Do you want to disconnect Bluetooth?" | "是否中斷藍芽連線?" | ✅ 已對照 |
| `bluetoothDisconnectDialogPositive` | `dialog_disconnect_bluetooth_positive` → `confirm` | "OK" | "確定" | ✅ 已對照 |
| `bluetoothDisconnectDialogNegative` | `dialog_disconnect_bluetooth_negative` → `cancel` | "Cancel" | "取消" | ✅ 已對照 |

### 主頁字符串（需要修正）

| koralcore 鍵 | reef-b-app 鍵 | 英文 | 繁體中文（應該） | 當前狀態 |
|-------------|--------------|------|----------------|---------|
| `homeStatusConnected` | - | "Connected to {device}" | ❌ 英文 | ⚠️ 需要修正 |
| `homeStatusDisconnected` | - | "No active device" | ❌ 英文 | ⚠️ 需要修正 |
| `homeSpinnerAllSink` | `home_spinner_all_sink` | "All Tanks" | "所有水槽" | ✅ 已對照 |
| `homeSpinnerFavorite` | `home_spinner_favorite` → `favorite_device` | "Favorite Devices" | "喜愛裝置" | ✅ 已對照 |
| `homeSpinnerUnassigned` | `home_spinner_unassigned` → `unassigned_device` | "Unallocated Devices" | "未分配設備" | ✅ 已對照 |

---

## 修正計劃

### 優先級 1: 基礎操作字符串

需要對照到 reef-b-app 的通用字符串：
- `confirm` → "確定"
- `cancel` → "取消"
- `delete` → "刪除"
- `save` → "儲存"
- `select` → "選取"
- `connect` → "連線" (如果存在)
- `disconnect` → "斷線" (如果存在)

### 優先級 2: 狀態字符串

需要檢查 reef-b-app 是否有對應的狀態字符串，如果沒有，需要根據上下文推斷正確的翻譯。

### 優先級 3: 其他字符串

需要逐一檢查並對照到 reef-b-app 的對應字符串。

---

## 下一步行動

1. 檢查 reef-b-app 的 strings.xml 中是否有對應的狀態和操作字符串
2. 如果沒有，需要根據上下文和 reef-b-app 的用法推斷正確的翻譯
3. 逐一修正所有未正確對照的字符串
4. 驗證所有語言的 ARB 文件都正確對照

