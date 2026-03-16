# 「加入新設備」功能完整對照分析報告

## 1. 相關文件清單

### 1.1 reef-b-app (Android)

#### UI 界面文件
- **布局文件**: `android/ReefB_Android/app/src/main/res/layout/activity_add_device.xml`
  - 主要布局：ConstraintLayout
  - 包含：Toolbar、設備名稱輸入框、水槽位置選擇器
- **Activity**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/add_device/AddDeviceActivity.kt`
  - 處理 UI 交互和導航
- **水槽位置選擇頁面**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/sink_position/SinkPositionActivity.kt`
  - 用於選擇設備要分配到的水槽

#### 業務邏輯文件
- **ViewModel**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/add_device/AddDeviceViewModel.kt`
  - 核心業務邏輯：設備添加、群組分配、泵頭創建
- **藍牙連接邏輯**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/bluetooth/BluetoothViewModel.kt`
  - 處理藍牙連接和設備存在性檢查
- **數據庫操作**: 
  - `DeviceDao`: 設備數據庫操作
  - `DropHeadDao`: 泵頭數據庫操作
  - `SinkDao`: 水槽數據庫操作

#### 導航觸發點
- **MainActivity**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/main/MainActivity.kt`
  - 監聽 `startAddDeviceLiveData` 並啟動 AddDeviceActivity
- **BluetoothFragment**: `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/bluetooth/BluetoothFragment.kt`
  - 當設備連接成功且設備不存在時，觸發導航到 AddDeviceActivity

### 1.2 reef-b-app (iOS)

#### UI 界面文件
- **ViewController**: `ios/ReefB_iOS/Reefb/Scenes/AddDevice/AddDeviceViewController.swift`
  - UI 實現（但業務邏輯較簡單，主要邏輯在連接時處理）
- **ViewModel**: `ios/ReefB_iOS/Reefb/Scenes/AddDevice/AddDeviceViewModel.swift`
  - 目前為空實現

#### 業務邏輯文件
- **藍牙連接處理**: `ios/ReefB_iOS/Reefb/Scenes/Main/Bluetooth/BluetoothSettingViewModel.swift`
  - 在 `handleConnectSuccess` 中直接添加設備到數據庫
- **數據庫操作**: `ios/ReefB_iOS/Reefb/Manager/DataBase/DBManager.swift`
  - `addDevice` 方法處理設備添加和泵頭創建

#### 導航觸發點
- **BluetoothSettingViewController**: `ios/ReefB_iOS/Reefb/Scenes/Main/Bluetooth/BluetoothSettingViewController.swift`
  - 在藍牙設備選擇時顯示 AddDeviceViewController

### 1.3 koralcore (Flutter)

#### UI 界面文件
- **頁面**: `lib/ui/features/device/pages/add_device_page.dart`
  - Flutter 實現的添加設備頁面
- **水槽位置選擇頁面**: `lib/ui/features/sink/pages/sink_position_page.dart`
  - 水槽選擇界面

#### 業務邏輯文件
- **Controller**: `lib/ui/features/device/controllers/add_device_controller.dart`
  - 處理設備添加邏輯
- **UseCase**: `lib/application/device/add_device_usecase.dart`
  - 設備添加用例（目前實現較簡單）
- **Repository**: `lib/infrastructure/repositories/device_repository_impl.dart`
  - 設備數據庫操作實現

## 2. 完整用戶流程

### 2.1 Android (reef-b-app)

#### 流程 A：從藍牙掃描添加新設備

1. **藍牙掃描階段**
   - 用戶在 `BluetoothFragment` 中點擊掃描按鈕
   - `BluetoothViewModel.startScan()` 開始掃描
   - 掃描結果顯示在列表中

2. **連接設備**
   - 用戶點擊掃描到的設備
   - `BluetoothFragment.onClickScanResult()` 被調用
   - `BluetoothViewModel.connectBle()` 開始連接
   - 如果設備不存在，設置 `BleContainer.setMacAddressForAdd(device.address)`

3. **連接成功處理**
   - `BluetoothViewModel.isConnectedLiveData` 觸發
   - 檢查設備是否存在：`viewModel.deviceIsExist()`
   - 如果設備不存在，觸發 `mainViewModel.startAddDeviceLiveData.value = Unit`
   - `MainActivity` 監聽到事件，啟動 `AddDeviceActivity`

4. **AddDeviceActivity 初始化**
   - `AddDeviceActivity.onCreate()` 執行
   - 從 `BleManager` 獲取連接的設備名稱
   - 如果沒有連接設備，直接關閉 Activity
   - 初始化 ViewModel，傳入 `macAddress`

5. **用戶輸入設備信息**
   - 設備名稱輸入框：預填藍牙設備名稱，用戶可修改
   - 水槽位置選擇：點擊後打開 `SinkPositionActivity`
   - 用戶可以選擇：
     - "無"（未分配水槽，sinkId = 0）
     - 現有水槽
     - 或添加新水槽

6. **完成添加**
   - **選項 A：點擊「略過」按鈕**
     - `AddDeviceViewModel.skip()` 被調用
     - 直接添加設備，不分配水槽
     - 如果是 DROP 設備，創建 4 個泵頭
     - 顯示成功提示，關閉 Activity
   
   - **選項 B：點擊「完成」按鈕**
     - `AddDeviceViewModel.clickBtnRight()` 被調用
     - 驗證設備名稱不為空
     - 根據設備類型（LED/DROP）執行不同邏輯：
       - **LED 設備**：
         - 如果未分配水槽（sinkId = 0）：直接添加，不設置群組
         - 如果分配水槽：調用 `addToWhichGroup()` 找到可用群組（A-E，每組最多 4 個設備）
         - 如果所有群組都滿了，返回失敗
         - 設置 `master = false`（新設備不是主燈）
       - **DROP 設備**：
         - 如果分配水槽：檢查水槽中是否已有 4 個 DROP 設備
         - 如果已滿，返回失敗
         - 創建 4 個泵頭（headId: 0-3）
     - 顯示成功/失敗提示，關閉 Activity

7. **返回處理**
   - 如果用戶按返回鍵，調用 `AddDeviceViewModel.disconnect()` 斷開藍牙連接
   - 關閉 Activity

#### 流程 B：從已保存設備列表連接

1. 用戶在 `BluetoothFragment` 中點擊已保存的設備
2. `BluetoothFragment.onClickDevice()` 被調用
3. 如果設備已連接，顯示斷開對話框
4. 如果設備未連接，調用 `BluetoothViewModel.connectDeviceByMacAddress()`
5. 連接成功後，如果設備已存在，刷新設備列表；如果不存在，導航到 AddDeviceActivity

### 2.2 iOS (reef-b-app)

#### 流程：藍牙連接時自動添加

1. **藍牙連接**
   - 用戶在 `BluetoothSettingViewController` 中選擇設備
   - `BluetoothSettingViewModel` 處理連接

2. **連接成功處理**
   - `handleConnectSuccess()` 被調用
   - 從 `peripheral.name` 判斷設備類型（LED/DROP）
   - 創建 `Device` 對象
   - 調用 `dbManager.addDevice()` 直接添加到數據庫
   - 如果是 DROP 設備，在 `addDevice` 中自動創建 4 個泵頭
   - 觸發 `deviceFirstConnectSuccessEvent`

3. **顯示添加設備頁面**（可選）
   - 在 `BluetoothSettingViewController` 中，點擊設備時顯示 `AddDeviceViewController`
   - 但 iOS 版本的 AddDeviceViewController 實現較簡單，主要用於顯示

### 2.3 koralcore (Flutter)

#### 流程：從設備頁面添加

1. **導航到添加設備頁面**
   - 用戶在 `DevicePage` 中連接設備
   - 連接成功後，如果設備不存在，導航到 `AddDevicePage`

2. **AddDevicePage 初始化**
   - 檢查是否有活動設備：`session.activeDeviceId`
   - 獲取設備名稱：`controller.connectedDeviceName`
   - 如果沒有連接設備，自動關閉頁面

3. **用戶輸入**
   - 設備名稱：預填連接的設備名稱
   - 水槽位置：點擊後打開 `SinkPositionPage`

4. **完成添加**
   - **選項 A：點擊「略過」**
     - `AddDeviceController.skip()` 被調用
     - 更新設備名稱（如果修改）
     - 如果是 DROP 設備，創建泵頭
     - 返回成功
   
   - **選項 B：點擊「完成」**
     - `AddDeviceController.addDevice()` 被調用
     - 驗證設備名稱
     - 根據設備類型和是否分配水槽執行邏輯：
       - **LED + 分配水槽**：找到可用群組（A-E，每組最多 4 個）
       - **DROP + 分配水槽**：檢查水槽中 DROP 設備數量（最多 4 個）
     - 更新設備信息到數據庫
     - 如果是 DROP 設備，創建泵頭

5. **返回處理**
   - 按返回鍵時，調用 `controller.disconnect()` 斷開連接

## 3. UI 界面詳細對照

### 3.1 Android XML 布局結構

```xml
activity_add_device.xml
├── toolbar_add_device (include toolbar_two_action)
│   ├── toolbarTitle: "新增裝置"
│   ├── btnLeft: "略過"
│   └── btnRight: "完成"
├── layout_add_device (ConstraintLayout, padding 16/12/16/12dp)
│   ├── tv_device_name_title (TextView, caption1)
│   ├── layout_name (TextInputLayout)
│   │   └── edt_name (TextInputEditText, body)
│   ├── tv_sink_position_title (TextView, caption1, marginTop 16dp)
│   ├── layout_sink_position (TextInputLayout, endIcon=ic_next)
│   │   └── edt_sink_position (TextInputEditText, enabled=false)
│   └── view_sink_position (View, selectableItemBackground overlay)
└── progress (include progress, visibility=gone)
```

### 3.2 Flutter 實現對照

- ✅ Toolbar：使用 `ReefAppBar`，左側「略過」，右側「完成」
- ✅ 設備名稱輸入：`TextField` 與 `TextInputLayout` 對應
- ✅ 水槽位置選擇：`TextField` (enabled=false) + `InkWell` 覆蓋層
- ✅ 布局間距：padding 16/12/16/12dp，元素間距 4dp/16dp
- ✅ 樣式：背景色、文字樣式、圓角等已對照

### 3.3 iOS 實現

- UI 使用 SnapKit 手動布局
- 包含設備名稱輸入框和水槽位置選擇按鈕
- 但業務邏輯主要在連接時處理，AddDeviceViewController 較簡單

## 4. 業務邏輯詳細對照

### 4.1 設備類型判斷

#### Android (reef-b-app)
```kotlin
// 通過藍牙設備名稱判斷
if (bleManager?.getConnectDeviceName()?.contains("led", ignoreCase = true) == true) {
    // LED 設備
} else if (bleManager?.getConnectDeviceName()?.contains("dose", ignoreCase = true) == true) {
    // DROP 設備
}
```

#### koralcore (Flutter)
```dart
// 從已保存的設備信息中獲取類型
final String? deviceType = device['type'] as String?;
if (deviceType == 'LED') {
    // LED 設備邏輯
} else if (deviceType == 'DROP') {
    // DROP 設備邏輯
}
```

**差異**：
- reef-b-app：從藍牙設備名稱動態判斷
- koralcore：從已保存的設備數據中讀取（設備應在連接時已保存基本信息）

### 4.2 LED 設備群組分配

#### Android (reef-b-app)
```kotlin
private fun addToWhichGroup(id: Int): LedGroup? {
    val deviceGroupInSink = dbGetDeviceBySinkId(id).map { it.group }
    // 按順序檢查 A, B, C, D, E，找到第一個未滿的群組（每組最多 4 個）
    if (deviceGroupInSink.count { it == LedGroup.A } < 4) return LedGroup.A
    else if (deviceGroupInSink.count { it == LedGroup.B } < 4) return LedGroup.B
    // ... C, D, E
    return null // 所有群組都滿了
}
```

#### koralcore (Flutter)
```dart
Future<String?> _findAvailableGroup(String sinkId) async {
    // 獲取該水槽的所有 LED 設備
    final sinkDevices = devices.where((d) => 
        d['sink_id'] == sinkId && d['type'] == 'LED').toList();
    
    // 統計每個群組的設備數量
    final Map<String, int> groupCounts = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'E': 0};
    for (final device in sinkDevices) {
        final String? group = device['device_group'] as String?;
        if (group != null && groupCounts.containsKey(group)) {
            groupCounts[group] = (groupCounts[group] ?? 0) + 1;
        }
    }
    
    // 找到第一個未滿的群組
    for (final entry in groupCounts.entries) {
        if (entry.value < 4) return entry.key;
    }
    return null;
}
```

**對照結果**：✅ 邏輯一致

### 4.3 DROP 設備限制檢查

#### Android (reef-b-app)
```kotlin
val dropInSinkAmount = dbGetDropInSinkBySinkId(selectSinkId).size
if (dropInSinkAmount >= 4) {
    addDeviceResult(false) // 水槽已滿
    return
}
```

#### koralcore (Flutter)
```dart
final int dropCount = await _getDropCountInSink(_selectedSinkId!);
if (dropCount >= 4) {
    _setError(AppErrorCode.invalidParam);
    return false;
}
```

**對照結果**：✅ 邏輯一致（每個水槽最多 4 個 DROP 設備）

### 4.4 DROP 設備泵頭創建

#### Android (reef-b-app)
```kotlin
val deviceId = getLastDeviceId()
for (i in 0..3) {
    dbAddDropHead(
        DropHead(
            deviceId = deviceId,
            headId = i, // 0, 1, 2, 3
        )
    )
}
```

#### koralcore (Flutter)
```dart
for (int i = 0; i < 4; i++) {
    final String headId = String.fromCharCode(65 + i); // A, B, C, D
    final PumpHead newHead = PumpHead(
        headId: headId,
        pumpId: i + 1, // 1, 2, 3, 4
        // ... 其他默認值
    );
    await pumpHeadRepository.savePumpHeads(deviceId, allHeads);
}
```

**差異**：
- reef-b-app：使用數字 headId (0-3)
- koralcore：使用字母 headId (A-D)，pumpId 為 1-4
- **需要確認**：數據庫結構是否一致

### 4.5 設備存在性檢查

#### Android (reef-b-app)
```kotlin
fun deviceIsExist(macAddress: String? = null): Boolean {
    val address = macAddress ?: bleManager.getConnectDeviceMacAddress()
    return dbGetDeviceByMacAddress(address) != null
}
```

#### koralcore (Flutter)
- 在連接時檢查設備是否在 `savedDevices` 列表中
- 如果不在，導航到 AddDevicePage

**對照結果**：✅ 邏輯一致

### 4.6 略過功能（不分配水槽）

#### Android (reef-b-app)
```kotlin
fun skip() {
    // 直接添加設備，sinkId = null
    dbAddDevice(Device(
        name = bleManager.getConnectDeviceName() ?: return,
        macAddress = bleManager.getConnectDeviceMacAddress() ?: return,
        sinkId = null,
        type = DeviceType.LED/DROP,
    ))
    // 如果是 DROP，創建泵頭
}
```

#### koralcore (Flutter)
```dart
Future<bool> skip() async {
    // 更新設備名稱（如果修改）
    if (_deviceName.isNotEmpty) {
        await deviceRepository.updateDeviceName(deviceId, name);
    }
    // 如果是 DROP，創建泵頭
    if (deviceType == 'DROP') {
        await _createPumpHeads(deviceId);
    }
    return true;
}
```

**差異**：
- reef-b-app：在 skip 時直接創建新設備記錄
- koralcore：設備應已在連接時保存，skip 只更新名稱和創建泵頭
- **需要確認**：koralcore 的設備是否在連接時已保存基本信息

## 5. 數據庫操作對照

### 5.1 設備添加

#### Android (reef-b-app)
```kotlin
private fun dbAddDevice(device: Device): Long {
    return dbDevice.insertDevice(device)
}
```

#### koralcore (Flutter)
```dart
Future<void> addSavedDevice(Map<String, dynamic> device) async {
    // 檢查設備是否已存在
    final index = _savedRecords.indexWhere((r) => r.id == device['id']);
    if (index >= 0) {
        // 更新現有設備
        _savedRecords[index] = _DeviceRecord.fromMap(device);
        await _updateDeviceInDatabase(_savedRecords[index]);
    } else {
        // 插入新設備
        _savedRecords.add(_DeviceRecord.fromMap(device));
        await _insertDeviceToDatabase(_savedRecords.last);
    }
}
```

**差異**：
- reef-b-app：直接插入，如果已存在可能報錯
- koralcore：檢查是否存在，存在則更新，不存在則插入
- **koralcore 的實現更安全**

### 5.2 泵頭創建

#### Android (reef-b-app)
```kotlin
private fun dbAddDropHead(dropHead: DropHead): Long {
    return dbDropHead.insertDropHead(dropHead)
}
```

#### koralcore (Flutter)
```dart
Future<void> _createPumpHeads(String deviceId) async {
    // 檢查泵頭是否已存在
    final existingHeads = await pumpHeadRepository.listPumpHeads(deviceId);
    if (existingHeads.length >= 4) return; // 已創建
    
    // 創建缺失的泵頭
    for (int i = 0; i < 4; i++) {
        final String headId = String.fromCharCode(65 + i); // A, B, C, D
        if (!existingHeadIds.contains(headId)) {
            // 創建新泵頭
            await pumpHeadRepository.savePumpHeads(deviceId, allHeads);
        }
    }
}
```

**差異**：
- reef-b-app：直接插入 4 個泵頭
- koralcore：檢查是否已存在，只創建缺失的
- **koralcore 的實現更安全，避免重複創建**

## 6. 差異分析和需要修改的部分

### 6.1 ✅ 已實現且對照正確的部分

1. **UI 布局**：Flutter 實現已對照 XML 布局
2. **LED 群組分配邏輯**：邏輯一致
3. **DROP 設備限制**：每個水槽最多 4 個，邏輯一致
4. **設備存在性檢查**：邏輯一致
5. **水槽位置選擇**：SinkPositionPage 已實現

### 6.2 ⚠️ 需要確認的部分

1. **設備類型判斷時機**
   - reef-b-app：從藍牙設備名稱動態判斷
   - koralcore：從已保存的設備數據讀取
   - **問題**：koralcore 在連接時是否已保存設備基本信息（包括類型）？
   - **建議**：檢查 `ConnectDeviceUseCase` 或連接流程

2. **泵頭 ID 格式**
   - reef-b-app：使用數字 headId (0-3)
   - koralcore：使用字母 headId (A-D)
   - **問題**：數據庫結構是否支持兩種格式？
   - **建議**：確認數據庫 schema 和業務邏輯要求

3. **略過功能的設備創建時機**
   - reef-b-app：在 skip 時創建設備記錄
   - koralcore：假設設備已在連接時保存
   - **問題**：koralcore 的設備是否在連接時已保存？
   - **建議**：檢查連接流程，確保設備基本信息已保存

### 6.3 ❌ 需要新增或修改的部分

1. **錯誤提示消息**
   - reef-b-app：顯示 "水槽已滿" (`toast_sink_is_full`)
   - koralcore：使用通用錯誤碼 `AppErrorCode.invalidParam`
   - **建議**：添加更明確的錯誤消息，如 "水槽已滿"、"所有群組已滿"

2. **BLE 斷開連接實現**
   - koralcore 的 `AddDeviceController.disconnect()` 目前是 TODO
   - **建議**：實現 BLE 斷開連接邏輯

3. **設備名稱預填邏輯**
   - reef-b-app：從 `BleManager.getConnectDeviceName()` 獲取
   - koralcore：從 `session.activeDeviceName` 獲取
   - **建議**：確認 `session.activeDeviceName` 是否正確設置

4. **連接成功後的自動導航**
   - reef-b-app：在 `BluetoothFragment` 中，連接成功且設備不存在時自動導航
   - koralcore：需要檢查 `DevicePage` 或 `BluetoothPage` 中是否有類似邏輯
   - **建議**：檢查連接成功後的處理邏輯

5. **iOS 版本的完整實現**
   - iOS 版本的 AddDeviceViewController 實現較簡單
   - **建議**：如果需要對照 iOS，可能需要補充實現

## 7. 測試建議

### 7.1 功能測試場景

1. **LED 設備添加**
   - [ ] 不分配水槽（略過）
   - [ ] 分配到空水槽（應分配到群組 A）
   - [ ] 分配到已有設備的水槽（應分配到未滿的群組）
   - [ ] 分配到所有群組都滿的水槽（應顯示錯誤）

2. **DROP 設備添加**
   - [ ] 不分配水槽（略過）
   - [ ] 分配到空水槽
   - [ ] 分配到已有 1-3 個 DROP 設備的水槽
   - [ ] 分配到已有 4 個 DROP 設備的水槽（應顯示錯誤）

3. **邊界情況**
   - [ ] 設備名稱為空時點擊完成（應顯示錯誤）
   - [ ] 沒有連接設備時打開頁面（應自動關閉）
   - [ ] 按返回鍵（應斷開連接）

### 7.2 數據一致性測試

1. **設備記錄**
   - [ ] 設備正確保存到數據庫
   - [ ] 設備名稱正確更新
   - [ ] 水槽 ID 正確設置

2. **LED 群組分配**
   - [ ] 群組按 A-E 順序分配
   - [ ] 每個群組最多 4 個設備
   - [ ] 群組分配正確保存

3. **DROP 泵頭創建**
   - [ ] 創建 4 個泵頭
   - [ ] 泵頭 ID 格式正確（A-D 或 0-3）
   - [ ] 不會重複創建泵頭

## 8. 總結

### 8.1 實現完成度

- **UI 界面**：✅ 90% 完成，已對照 XML 布局
- **業務邏輯**：✅ 85% 完成，核心邏輯已實現
- **數據庫操作**：✅ 90% 完成，但需要確認格式一致性
- **錯誤處理**：⚠️ 60% 完成，需要更明確的錯誤消息
- **BLE 集成**：⚠️ 70% 完成，斷開連接需要實現

### 8.2 優先級建議

1. **高優先級**：
   - 確認設備類型判斷時機和設備基本信息保存時機
   - 實現 BLE 斷開連接
   - 添加更明確的錯誤消息

2. **中優先級**：
   - 確認泵頭 ID 格式一致性
   - 檢查連接成功後的自動導航邏輯

3. **低優先級**：
   - iOS 版本的完整實現對照（如果需要）

