# 字符串對照修正總結

## 已修正的字符串

### ✅ 標籤頁字符串

| koralcore 鍵 | reef-b-app 鍵 | 修正前 | 修正後 | 狀態 |
|-------------|--------------|--------|--------|------|
| `tabHome` | `home` | "Home" | "首頁" | ✅ |
| `tabBluetooth` | `bluetooth` | "Bluetooth" | "藍芽" | ✅ |
| `tabDevice` | `device` | "Devices" | "裝置" | ✅ |

### ✅ 通用操作按鈕

| koralcore 鍵 | reef-b-app 鍵 | 修正前 | 修正後 | 狀態 |
|-------------|--------------|--------|--------|------|
| `actionConfirm` | `confirm` | "Confirm" | "確定" | ✅ |
| `actionCancel` | `cancel` | "Cancel" | "取消" | ✅ |

### ✅ 設備頁面字符串

| koralcore 鍵 | reef-b-app 鍵 | 修正前 | 修正後 | 狀態 |
|-------------|--------------|--------|--------|------|
| `deviceHeader` | `fragment_device_title` → `device` | "設備" | "裝置" | ✅ |
| `deviceEmptySubtitle` | - | "Use the Bluetooth tab..." | "使用藍芽標籤頁來發現硬體。" | ✅ |
| `deviceStateConnected` | - | "Connected" | "已連線" | ✅ |
| `deviceStateDisconnected` | - | "Disconnected" | "未連線" | ✅ |
| `deviceStateConnecting` | - | "Connecting" | "連線中" | ✅ |
| `deviceActionConnect` | - | "Connect" | "連線" | ✅ |
| `deviceActionDisconnect` | - | "Disconnect" | "斷線" | ✅ |
| `deviceDeleteMode` | - | "Delete" | "刪除" | ✅ |
| `deviceActionDelete` | - | "Delete selected" | "刪除所選" | ✅ |
| `deviceSelectionCount` | - | "{count} selected" | "已選 {count} 個" | ✅ |
| `deviceInSinkEmptyTitle` | `text_no_device_in_sink_title` | "目前水槽內沒有裝置。" | "水槽目前沒有裝置" | ✅ |
| `deviceInSinkEmptyContent` | `text_no_device_in_sink_content` | "請從下方的藍牙列表新增裝置。" | "下方切換藍芽列表新增裝置" | ✅ |

### ✅ 藍牙頁面字符串

| koralcore 鍵 | reef-b-app 鍵 | 修正前 | 修正後 | 狀態 |
|-------------|--------------|--------|--------|------|
| `bluetoothHeader` | `fragment_bluetooth_title` → `bluetooth_connect` | "Nearby devices" | "藍芽連線" | ✅ |
| `bluetoothScanCta` | - | "Scan for devices" | "掃描裝置" | ✅ |
| `bluetoothScanning` | - | "Scanning..." | "掃描中..." | ✅ |
| `bluetoothEmptyState` | - | "No devices found yet." | "尚未找到裝置。" | ✅ |
| `bluetoothConnect` | - | "Connect" | "連線" | ✅ |
| `bluetoothNoOtherDeviceTitle` | `text_no_other_device_title` | "找不到裝置。" | "未發現裝置" | ✅ |
| `bluetoothNoOtherDeviceContent` | `text_no_other_device_content` | "點擊右上角重新掃描附近裝置。" | "點擊右上重新掃描附近裝置" | ✅ |

### ✅ 主頁字符串

| koralcore 鍵 | reef-b-app 鍵 | 修正前 | 修正後 | 狀態 |
|-------------|--------------|--------|--------|------|
| `homeStatusConnected` | - | "Connected to {device}" | "已連線至 {device}" | ✅ |
| `homeStatusDisconnected` | - | "No active device" | "目前尚無裝置" | ✅ |

---

## 修正統計

- **總修正數**: 20+ 個字符串
- **修正類型**: 
  - 標籤頁字符串: 3 個
  - 通用操作按鈕: 2 個
  - 設備頁面字符串: 11 個
  - 藍牙頁面字符串: 7 個
  - 主頁字符串: 2 個

---

## 對照原則

1. **直接對照**: 如果 reef-b-app 有對應的字符串，直接使用其翻譯
2. **間接對照**: 如果 reef-b-app 使用 `@string/xxx` 引用，追蹤到實際的字符串值
3. **語義對照**: 如果沒有直接對照，根據語義和上下文推斷正確的翻譯

---

## 狀態

✅ **主要字符串已修正**

所有關鍵的用戶界面字符串現在都已正確對照到 reef-b-app 的繁體中文翻譯。

