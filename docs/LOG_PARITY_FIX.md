# Log 使用修正文檔

## 問題描述

koralcore 使用的 log 不對，及內容不對。需要比對 reef-b-app 的 log 使用方式並修正。

---

## 1. reef-b-app 的 Log 使用

### 1.1 使用方式

**reef-b-app 使用 `android.util.Log`**：
```kotlin
import android.util.Log

private val TAG = "BLEManager"

// Debug log
Log.d("$TAG - 藍芽掃描", "掃描開始")
Log.d("$TAG - 藍芽掃描", "掃描結束")
Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 成功連線")
Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 斷線")
Log.d("$TAG - 藍芽命令", "---->寫入：${value.toHexString()}")

// Info log
Log.i("AppLifecycleTracker - 目前App狀態", "onActivityResumed")
Log.i("message_i_ble", "-----------------service-----------------")
```

### 1.2 Log 格式

**格式**: `Log.d(TAG, "message")`

**TAG 格式**:
- `"$TAG - 藍芽掃描"` - BLE 掃描相關
- `"$TAG - 藍芽連線"` - BLE 連線相關
- `"$TAG - 藍芽命令"` - BLE 命令相關
- `"AppLifecycleTracker - 目前App狀態"` - App 生命週期相關

**內容**: 使用中文訊息，如：
- "掃描開始"
- "掃描結束"
- "成功連線"
- "斷線"
- "掃描到裝置（權限不足，無法讀取名稱/位址）"

### 1.3 主要 Log 位置

1. **BLEManager.kt**:
   - `Log.d("$TAG - 藍芽掃描", "掃描開始")`
   - `Log.d("$TAG - 藍芽掃描", "掃描結束")`
   - `Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 成功連線")`
   - `Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 斷線")`
   - `Log.d("$TAG - 藍芽命令", "---->寫入：${value.toHexString()}")`

2. **MyApplication.kt (AppLifecycleTracker)**:
   - `Log.d("AppLifecycleTracker - 目前App狀態", "目前Activity:${activity.localClassName}--前景")`
   - `Log.i("AppLifecycleTracker - 目前App狀態", "onActivityResumed")`
   - `Log.d("AppLifecycleTracker - 目前App狀態", "目前Activity:${activity.localClassName}--背景")`

---

## 2. koralcore 的 Log 使用（修正前）

### 2.1 使用方式

**koralcore 使用 `print()`**：
```dart
print('[DeviceListController] refresh called');
print('[DeviceListController] Starting scan...');
print('[DeviceListController] Scan completed');
print('[BleReadinessController] Refreshing BLE status...');
```

### 2.2 問題

1. **使用 `print()` 而不是 `debugPrint()`**:
   - `print()` 在 release 模式下仍會輸出，可能影響性能
   - Flutter 推薦使用 `debugPrint()` 或 `developer.log()`

2. **Log 格式不對**:
   - 格式：`[ClassName] message`（英文）
   - 應該：`ClassName - 類別: 訊息`（中文，對照 reef-b-app）

3. **Log 內容不對**:
   - 內容：英文訊息，如 "refresh called", "Starting scan..."
   - 應該：中文訊息，如 "掃描開始", "掃描結束"

---

## 3. 修正內容

### 3.1 使用 `debugPrint()` 替代 `print()`

**修正前**:
```dart
print('[DeviceListController] refresh called');
```

**修正後**:
```dart
import 'package:flutter/foundation.dart';

debugPrint('DeviceListController - 藍芽掃描: 掃描開始');
```

### 3.2 對照 reef-b-app 的 Log 格式

**reef-b-app**:
```kotlin
Log.d("$TAG - 藍芽掃描", "掃描開始")
Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 成功連線")
```

**koralcore（修正後）**:
```dart
debugPrint('DeviceListController - 藍芽掃描: 掃描開始');
debugPrint('DeviceListController - 藍芽連線: $deviceId 成功連線');
```

### 3.3 對照 reef-b-app 的 Log 內容

| reef-b-app | koralcore（修正前） | koralcore（修正後） |
|-----------|------------------|------------------|
| "掃描開始" | "refresh called" | "掃描開始" |
| "掃描結束" | "Scan completed" | "掃描結束" |
| "成功連線" | "connect succeeded" | "成功連線" |
| "斷線" | "connect failed" | "斷線" |

---

## 4. 已修正的文件

### 4.1 `lib/ui/features/device/controllers/device_list_controller.dart`

**修正前**:
```dart
print('[DeviceListController] refresh called');
print('[DeviceListController] Starting scan...');
print('[DeviceListController] Scan completed');
print('[DeviceListController] connect called for device: $deviceId');
```

**修正後**:
```dart
debugPrint('DeviceListController - 藍芽掃描: 掃描開始');
debugPrint('DeviceListController - 藍芽掃描: 已在掃描中，跳過');
debugPrint('DeviceListController - 藍芽掃描: 掃描結束');
debugPrint('DeviceListController - 藍芽連線: 開始連線 $deviceId');
debugPrint('DeviceListController - 藍芽連線: $deviceId 成功連線');
debugPrint('DeviceListController - 藍芽連線: $deviceId 連線失敗，錯誤: ${error.code}');
```

### 4.2 `lib/application/system/ble_readiness_controller.dart`

**修正前**:
```dart
print('[BleReadinessController] Refreshing BLE status...');
print('[BleReadinessController] _loadStatus called, requestPermissions: $requestPermissions');
```

**修正後**:
```dart
debugPrint('BleReadinessController - 目前App狀態: 刷新 BLE 狀態');
debugPrint('BleReadinessController - 目前App狀態: _loadStatus 調用，requestPermissions: $requestPermissions');
debugPrint('BleReadinessController - 目前App狀態: 讀取系統狀態');
```

### 4.3 `lib/infrastructure/repositories/device_repository_impl.dart`

**修正前**:
```dart
print('[DeviceRepository] Generated ${_discoveredRecords.length} test devices for scanning');
print('[DeviceRepository] Device $deviceId not in saved records...');
```

**修正後**:
```dart
debugPrint('DeviceRepository - 藍芽掃描: 生成 ${_discoveredRecords.length} 個測試設備供掃描');
debugPrint('DeviceRepository - 藍芽掃描: 設備 $deviceId 不在已保存記錄中，檢查已發現記錄...');
debugPrint('DeviceRepository - 藍芽連線: 更新設備 $deviceId 狀態為: $state');
```

---

## 5. Log 格式對照表

| 類別 | reef-b-app TAG | koralcore TAG | 對照狀態 |
|------|---------------|--------------|---------|
| BLE 掃描 | `"$TAG - 藍芽掃描"` | `"DeviceListController - 藍芽掃描"` | ✅ 對照 |
| BLE 連線 | `"$TAG - 藍芽連線"` | `"DeviceListController - 藍芽連線"` | ✅ 對照 |
| BLE 命令 | `"$TAG - 藍芽命令"` | （待實現） | ⚠️ 待實現 |
| App 狀態 | `"AppLifecycleTracker - 目前App狀態"` | `"BleReadinessController - 目前App狀態"` | ✅ 對照 |

---

## 6. 結論

### ✅ 已修正

1. **使用 `debugPrint()` 替代 `print()`**: ✅
2. **Log 格式對照 reef-b-app**: ✅
3. **Log 內容使用中文**: ✅
4. **Log TAG 格式對照**: ✅

### ⚠️ 待實現

1. **BLE 命令 Log**: 需要在 BLE 命令發送時添加對應的 log（對照 `"$TAG - 藍芽命令"`）

**狀態**: ✅ **主要 Log 已修正，格式和內容已對照 reef-b-app**

