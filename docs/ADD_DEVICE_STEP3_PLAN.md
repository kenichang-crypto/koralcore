# 步驟 3：實現計劃 - 「加入新設備」功能

## 1. 需要修改的文件清單

### 高優先級（必須實現）

#### 1.1 連接成功後自動導航到 AddDevicePage

**文件**：
- `lib/ui/features/device/controllers/device_list_controller.dart`
  - 修改 `connect()` 方法
  - 添加 `deviceExists()` 方法
  - 添加導航回調機制

**修改內容**：
1. 在 `DeviceListController` 中添加 `onDeviceConnected` 回調
2. 在 `connect()` 成功後檢查設備是否存在
3. 如果設備不存在，觸發導航回調

**使用方式**：
- 在 `BluetoothPage` 或 `DevicePage` 中監聽連接成功事件
- 如果設備不存在，導航到 `AddDevicePage`

---

#### 1.2 設備類型判斷：從設備名稱判斷

**文件**：
- `lib/ui/features/device/controllers/add_device_controller.dart`
  - 修改 `skip()` 方法
  - 修改 `addDevice()` 方法
  - 使用 `DeviceNameFilter` 工具類

**修改內容**：
1. 在 `skip()` 中：
   - 從 `session.activeDeviceName` 獲取設備名稱
   - 使用 `DeviceNameFilter.getDeviceType()` 判斷類型
   - 根據類型執行不同邏輯（LED vs DROP）

2. 在 `addDevice()` 中：
   - 同樣從設備名稱判斷類型
   - 如果已保存數據中有類型，優先使用（向後兼容）
   - 如果沒有，從設備名稱判斷

---

### 中優先級（應該實現）

#### 1.3 BLE 連接限制檢查

**文件**：
- `lib/application/common/app_error_code.dart`
  - 添加 `connectLimit` 錯誤代碼

- `lib/l10n/intl_en.arb`
  - 添加 `errorConnectLimit` 消息

- `lib/l10n/intl_zh_Hant.arb`
  - 添加 `errorConnectLimit` 消息（繁體中文）

- `lib/ui/components/app_error_presenter.dart`
  - 添加 `connectLimit` 錯誤處理

- `lib/ui/features/device/controllers/device_list_controller.dart`
  - 在 `connect()` 方法中添加連接限制檢查

**修改內容**：
1. 添加錯誤代碼 `AppErrorCode.connectLimit`
2. 添加本地化消息
3. 在 `connect()` 前檢查當前連接數
4. 如果已有設備連接，拋出錯誤

---

## 2. 實現步驟

### 步驟 1：設備類型判斷（高優先級）

**目標**：從設備名稱判斷類型，而不是從已保存數據讀取

**修改文件**：
- `lib/ui/features/device/controllers/add_device_controller.dart`

**具體修改**：

1. **導入 DeviceNameFilter**：
   ```dart
   import '../../../../infrastructure/ble/device_name_filter.dart';
   ```

2. **修改 `skip()` 方法**：
   ```dart
   Future<bool> skip() async {
     final String? deviceId = session.activeDeviceId;
     if (deviceId == null) {
       _setError(AppErrorCode.noActiveDevice);
       notifyListeners();
       return false;
     }

     _isLoading = true;
     notifyListeners();

     try {
       // Get device name from session (BLE connection)
       final String? deviceName = session.activeDeviceName;
       if (deviceName == null || deviceName.isEmpty) {
         _setError(AppErrorCode.noActiveDevice);
         return false;
       }

       // Determine device type from name (PARITY: reef-b-app)
       final String? deviceType = DeviceNameFilter.getDeviceType(deviceName);
       if (deviceType == null) {
         _setError(AppErrorCode.invalidParam);
         return false;
       }

       final String name = _deviceName.isEmpty ? deviceName : _deviceName;

       // Update device name if changed
       if (_deviceName.isNotEmpty) {
         await deviceRepository.updateDeviceName(deviceId, name);
       }

       // If DROP device, create pump heads
       if (deviceType == 'DROP') {
         await _createPumpHeads(deviceId);
       }

       _clearError();
       return true;
     } catch (e) {
       _setError(AppErrorCode.unknownError);
       return false;
     } finally {
       _isLoading = false;
       notifyListeners();
     }
   }
   ```

3. **修改 `addDevice()` 方法**：
   ```dart
   Future<bool> addDevice() async {
     // ... existing code ...

     try {
       // Get device name from session (BLE connection)
       final String? deviceName = session.activeDeviceName;
       if (deviceName == null || deviceName.isEmpty) {
         _setError(AppErrorCode.noActiveDevice);
         return false;
       }

       // Determine device type from name (PARITY: reef-b-app)
       // Try to get from saved data first (backward compatibility)
       final List<Map<String, dynamic>> devices = await deviceRepository
           .listSavedDevices();
       final Map<String, dynamic> device = devices.firstWhere(
         (d) => d['id'] == deviceId,
         orElse: () => <String, dynamic>{},
       );

       String? deviceType = device['type'] as String?;
       // If not in saved data, determine from device name
       if (deviceType == null || deviceType.isEmpty) {
         deviceType = DeviceNameFilter.getDeviceType(deviceName);
         if (deviceType == null) {
           _setError(AppErrorCode.invalidParam);
           return false;
         }
       }

       // ... rest of the method ...
     }
   }
   ```

---

### 步驟 2：連接成功後自動導航（高優先級）

**目標**：連接成功 && 設備不存在 → 自動導航到 AddDevicePage

**修改文件**：
- `lib/ui/features/device/controllers/device_list_controller.dart`
- `lib/ui/features/bluetooth/bluetooth_page.dart` 或 `lib/ui/features/device/device_page.dart`

**具體修改**：

1. **在 `DeviceListController` 中添加回調機制**：
   ```dart
   class DeviceListController extends ChangeNotifier {
     // ... existing code ...
     
     // Callback for when device is connected and doesn't exist
     VoidCallback? onNewDeviceConnected;

     Future<void> connect(String deviceId) async {
       print('[DeviceListController] connect called for device: $deviceId');
       try {
         await _connectDeviceUseCase.execute(deviceId: deviceId);
         print('[DeviceListController] connect succeeded for device: $deviceId');
         
         // Check if device exists in saved devices (PARITY: reef-b-app)
         final bool deviceExists = _savedDevices.any((d) => d.id == deviceId);
         if (!deviceExists && onNewDeviceConnected != null) {
           // Device doesn't exist, trigger navigation
           onNewDeviceConnected!();
         }
       } on AppError catch (error) {
         print('[DeviceListController] connect failed for device: $deviceId, error: ${error.code}');
         _setError(error.code);
       }
     }
   }
   ```

2. **在 `BluetoothPage` 或 `DevicePage` 中設置回調**：
   ```dart
   // In BluetoothPage or DevicePage
   @override
   void initState() {
     super.initState();
     final controller = context.read<DeviceListController>();
     controller.onNewDeviceConnected = () {
       // Navigate to AddDevicePage
       Navigator.of(context).push(
         MaterialPageRoute(
           builder: (_) => const AddDevicePage(),
         ),
       );
     };
   }
   ```

---

### 步驟 3：BLE 連接限制檢查（中優先級）

**目標**：最多只能同時連接 1 個設備

**修改文件**：
- `lib/application/common/app_error_code.dart`
- `lib/l10n/intl_en.arb`
- `lib/l10n/intl_zh_Hant.arb`
- `lib/ui/components/app_error_presenter.dart`
- `lib/ui/features/device/controllers/device_list_controller.dart`

**具體修改**：

1. **添加錯誤代碼**：
   ```dart
   // lib/application/common/app_error_code.dart
   enum AppErrorCode {
     // ... existing codes ...
     connectLimit, // Maximum 1 device can be connected simultaneously
   }
   ```

2. **添加本地化消息**：
   ```json
   // lib/l10n/intl_en.arb
   "errorConnectLimit": "Maximum 1 device can be connected simultaneously."
   
   // lib/l10n/intl_zh_Hant.arb
   "errorConnectLimit": "最多可1個裝置同時連線"
   ```

3. **更新錯誤處理器**：
   ```dart
   // lib/ui/components/app_error_presenter.dart
   String describeAppError(AppLocalizations l10n, AppErrorCode code) {
     switch (code) {
       // ... existing cases ...
       case AppErrorCode.connectLimit:
         return l10n.errorConnectLimit;
       // ... rest ...
     }
   }
   ```

4. **在 `DeviceListController` 中添加檢查**：
   ```dart
   Future<void> connect(String deviceId) async {
     // Check if another device is already connected (PARITY: reef-b-app)
     final bool hasConnectedDevice = _savedDevices.any((d) => d.isConnected);
     if (hasConnectedDevice) {
       _setError(AppErrorCode.connectLimit);
       return;
     }

     // ... rest of connect logic ...
   }
   ```

---

## 3. 實現順序

### 第一階段：高優先級功能
1. ✅ **步驟 1**：設備類型判斷（從設備名稱）
2. ✅ **步驟 2**：連接成功後自動導航

### 第二階段：中優先級功能
3. ✅ **步驟 3**：BLE 連接限制檢查

---

## 4. 測試要點

### 步驟 1 測試
- [ ] 測試 LED 設備：設備名稱包含 "led" → 正確識別為 LED
- [ ] 測試 DROP 設備：設備名稱包含 "dose" → 正確識別為 DROP
- [ ] 測試 `skip()` 方法：不分配水槽，正確創建泵頭（DROP）
- [ ] 測試 `addDevice()` 方法：分配水槽，正確分配群組（LED）

### 步驟 2 測試
- [ ] 測試新設備連接：連接成功 && 設備不存在 → 自動導航到 AddDevicePage
- [ ] 測試已存在設備連接：連接成功 && 設備存在 → 不導航
- [ ] 測試連接失敗：連接失敗 → 不導航

### 步驟 3 測試
- [ ] 測試連接限制：已有設備連接 → 嘗試連接新設備 → 顯示錯誤
- [ ] 測試錯誤消息：錯誤消息正確顯示（英文/繁體中文）
- [ ] 測試斷開後連接：斷開現有連接 → 可以連接新設備

---

## 5. 注意事項

1. **設備名稱獲取**：
   - 需要確認 `session.activeDeviceName` 是否在連接時已設置
   - 如果沒有，可能需要從 BLE 連接狀態獲取

2. **導航時機**：
   - 確保在連接成功後立即檢查設備是否存在
   - 避免在連接過程中導航

3. **向後兼容**：
   - 設備類型判斷優先使用已保存數據（如果存在）
   - 如果沒有，再從設備名稱判斷

4. **錯誤處理**：
   - 確保所有錯誤情況都有適當的錯誤消息
   - 確保錯誤消息已本地化

