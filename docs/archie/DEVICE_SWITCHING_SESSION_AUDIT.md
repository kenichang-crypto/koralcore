# Device Switching and Session Readiness Consistency Audit

**日期**: 2026-02-11  
**對照**: reef-b-app（僅參考，不修改）  
**範圍**: koralcore AppSession、CurrentDeviceSession 同步

---

## 1) 使用點清單

### AppSession.setActiveDevice(deviceId)

| 檔案 | 行號 | 情境 |
|------|------|------|
| `lib/features/home/presentation/pages/home_tab_page.dart` | 595 | 點選裝置 → 導航至 LedMainPage / DosingMainPage |
| `lib/features/device/presentation/pages/device_tab_page.dart` | 108 | 點選裝置 → 導航至 LedMainPage / DosingMainPage |
| `lib/features/doser/presentation/controllers/dosing_main_controller.dart` | 125 | `initialize(deviceId)` 時設定活動裝置 |

### currentDeviceSession.switchTo(deviceId)

| 檔案 | 行號 | 說明 |
|------|------|------|
| `lib/app/device/switch_current_device_usecase.dart` | 34 | SwitchCurrentDeviceUseCase.execute() 內呼叫 |

**SwitchCurrentDeviceUseCase 從未被呼叫**（未納入 AppContext DI）。

### CurrentDeviceSession.start(context)

| 檔案 | 行號 | 說明 |
|------|------|------|
| `lib/app/device/initialize_device_usecase.dart` | 94 | InitializeDeviceUseCase 完成時，將裝置標記為 ready |

### CurrentDeviceSession.clear()

| 檔案 | 行號 | 說明 |
|------|------|------|
| `lib/app/device/disconnect_device_usecase.dart` | 39 | 斷線時清除 session |
| `lib/app/device/remove_device_usecase.dart` | 52 | 移除裝置時清除 session |

---

## 2) 不一致點分析

### 問題：AppSession 與 CurrentDeviceSession 不同步

| 狀況 | AppSession | CurrentDeviceSession | 結果 |
|------|------------|----------------------|------|
| 使用者從裝置 A 切換到 B（尚未連接） | `setActiveDevice(B)` → _activeDeviceId=B | 未呼叫 switchTo → _context 仍為 A、isReady=true | **stale ready** |
| 命令流程 | UI 顯示裝置 B | `requireContext` 回傳裝置 A 的 context | **命令可能送往錯誤裝置** |

### 問題：_onDevices 直接更新 _activeDeviceId

`AppSession._onDevices()` 在 BLE 掃描結果變更時，會直接設定 `_activeDeviceId`（含 null），但**未**呼叫 `currentDeviceSession.switchTo()` 或 `clear()`，可能造成 session 與實際連接狀態不同步。

---

## 3) reef-b-app 對照

reef-b-app 透過 `DeviceUtil.setCurrentDevice()` / Intent.putExtra("device_id") 設定當前裝置。koralcore 以 `AppSession.setActiveDevice()` 對應。兩者皆需在切換裝置時重置 ready 狀態，避免使用舊裝置的 context。

---

## 4) 修正方案

### 4.1 AppSession.setActiveDevice() 內部呼叫 switchTo

```dart
void setActiveDevice(String deviceId) {
  // ... existing device name lookup ...

  if (_activeDeviceId == deviceId && _activeDeviceName == deviceName) {
    return;
  }

  // KC-A-FINAL: Sync with CurrentDeviceSession lifecycle.
  // Switching device resets isReady to false until InitializeDeviceUseCase runs.
  context.currentDeviceSession.switchTo(deviceId);

  _activeDeviceId = deviceId;
  _activeDeviceName = deviceName;
  _resubscribePumpHeads(_activeDeviceId);
  _resubscribeLedState(_activeDeviceId);
  notifyListeners();
}
```

### 4.2 AppSession._onDevices() 在 active 變為 null 時呼叫 clear

當 `nextId == null`（無連接裝置）時，呼叫 `context.currentDeviceSession.clear()`。  
當 `nextId` 非 null 時，不呼叫 `switchTo`，因 DeviceConnectionCoordinator 已在連線時執行 InitializeDeviceUseCase，session 可能已為 ready。

---

## 5) 影響範圍

- **修改檔案**: `lib/app/common/app_session.dart`
- **不修改**: BLE protocol、DeviceRepository、InitializeDeviceUseCase、SwitchCurrentDeviceUseCase
- **行為變更**:
  - 切換裝置時 `isReady` 會立即變為 false
  - 需等 BLE 連接並完成 InitializeDeviceUseCase 後才恢復為 true
  - 符合 Ready Gate 設計：reconnect → initialize → ready
