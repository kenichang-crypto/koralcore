# BLE Scan Real Implementation Notes

**日期**: 2026-02-11  
**變更**: 將 mock BLE 掃描改為真實平台掃描 (FlutterBluePlus)

---

## 1) 變更摘要

| 項目 | 變更前 | 變更後 |
|------|--------|--------|
| 掃描來源 | `_generateDiscovered()` 固定測試裝置 | FlutterBluePlus 實際 BLE 掃描 |
| 資料來源 | 硬編碼 koralDOSE/coralLED 等 | 實機掃描結果 (deviceId, name, RSSI) |
| 即時更新 | 僅掃描結束後一次 | `onUpdate` 回調即時推送到 stream |

---

## 2) 權限與平台設定

### Android

- **AndroidManifest.xml** (通常已由 flutter_blue_plus 設定):
  - `BLUETOOTH`
  - `BLUETOOTH_ADMIN`
  - `BLUETOOTH_SCAN` (Android 12+)
  - `BLUETOOTH_CONNECT` (Android 12+)
  - `ACCESS_FINE_LOCATION` 或 `ACCESS_COARSE_LOCATION`（Android 10 以下掃描需要）
- **minSdkVersion**: 建議 21+
- **compileSdkVersion**: 建議 33+ 以支援 BLUETOOTH_SCAN/CONNECT
- **注意**: 舊版 Android 需開啟定位服務才能掃描（flutter_blue_plus 會檢查）

### iOS

- **Info.plist**:
  - `NSBluetoothAlwaysUsageDescription` - 必需
  - `NSBluetoothPeripheralUsageDescription` - 舊版相容
- **注意**: 需實機或模擬器支援 BLE，模擬器 BLE 支援有限

### macOS (若支援)

- 需啟用 Bluetooth 權限

---

## 3) 裝置名稱過濾 (PARITY)

reef-b-app 僅顯示符合以下名稱的裝置：

- `koralDOSE` / `coralDOSE`
- `koralLED` / `coralLED`

實作於 `lib/data/ble/device_name_filter.dart`，並由 `BleScanService` 套用。

---

## 4) 串流模型

- `DeviceRepositoryImpl.scanDevices()` 呼叫 `BleScanService.runScan(onUpdate: ...)`
- `onUpdate` 在每次掃描結果更新時：
  1. 更新 `_discoveredRecords`
  2. 呼叫 `_emitDiscovered()` 推送到 `_discoveredController`
- `ScanDevicesUseCase.observe()` 透過 `deviceRepository.observeDevices()` 訂閱
- `BluetoothTabPage` / `DeviceListController` 依此即時更新 UI

---

## 5) 未修改項目

- 連線邏輯：不變
- `BleAdapter` / `BlePlatformTransportWriter`：不變
- `DeviceRepository.connect()` / `disconnect()`：不變

---

## 6) 測試建議

1. 開啟 BluetoothTabPage，按 refresh → 應觸發真實掃描
2. 附近有 koralDOSE / koralLED / coralDOSE / coralLED 裝置時，應出現在「其他裝置」
3. 確認掃描過程中列表會即時更新
4. Android: 若掃描無結果，檢查定位服務與權限
5. iOS: 首次使用時確認藍牙權限提示
