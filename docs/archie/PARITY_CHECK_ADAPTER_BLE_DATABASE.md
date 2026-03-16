# Adapter, BLE, Database 對照檢查

本文檔對比 `reef-b-app` 和 `koralcore` 在 Adapter、BLE、Database 層面的實現。

---

## 1. BLE 層面對照

### 1.1 reef-b-app BLE 文件

#### BLEManager.kt
**功能**：
- BLE 掃描管理
- BLE 連接管理（連接、斷開、重連）
- 命令隊列管理（ConcurrentLinkedQueue）
- 通知（Notify）處理
- 寫入（Write）處理
- 滴液量格式能力檢測（DoseCapability: UNKNOWN, LEGACY_7A, DECIMAL_7E）
- 今日累計滴液量追蹤（todayDoseMl）
- 超時處理（掃描超時、連接超時）

**關鍵功能**：
- `scanLeDevice()` - 掃描設備
- `connectDevice()` - 連接設備
- `disConnect()` - 斷開連接
- `writeQueueCommand()` - 寫入命令到隊列
- `detectDoseFormat()` - 檢測滴液量格式（0x7E 命令）

#### BleContainer.kt
**功能**：
- 管理多個 BLEManager 實例（按 MAC 地址）
- 管理 LedInformation 和 DropInformation（按 MAC 地址）
- 單例模式
- 斷開所有連接

**關鍵方法**：
- `new(macAddress)` - 創建新的 BLEManager
- `getBleManager(macAddress)` - 獲取 BLEManager
- `getLedInformation(macAddress)` - 獲取 LED 信息
- `getDropInformation(macAddress)` - 獲取 Dosing 信息
- `disconnectAll()` - 斷開所有連接

#### CommandManager.kt
**功能**：
- 定義所有 BLE 命令的構建方法
- 定義命令 ID 枚舉（CommandID）
- LED 命令：0x20-0x34
- Dosing 命令：0x60-0x7E

**關鍵命令**：
- LED: 時間校正(0x20), 同步信息(0x21), 排程(0x27), 場景(0x28/0x29), 預覽(0x2A), 調光(0x32-0x34)
- Dosing: 時間校正(0x60), 延遲時間(0x61), 轉速(0x62), 單次滴液(0x6E/0x6F), 24小時排程(0x70/0x71), 客製化排程(0x72-0x74), 校正(0x75-0x77), 今日總量(0x7A/0x7E)

#### UUID.kt
**定義的 UUID**：
```kotlin
UUID_LED_SERVICE: "00010203-0405-0607-0809-0a0b0c0dffc0"
UUID_LED_WRITE: "00010203-0405-0607-0809-0a0b0c0dffc3"
UUID_LED_NOTIFY: "00010203-0405-0607-0809-0a0b0c0dffc1"

UUID_DROP_SERVICE: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
UUID_DROP_WRITE: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
UUID_DROP_NOTIFY: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
```

**設備名稱**：
- LED_NAME: "coralLED EX"
- DROP_NAME: "coralDOSE 4H"

### 1.2 koralcore BLE 實現

#### ble_adapter.dart / ble_adapter_impl.dart
**狀態**: ✅ **已實現**
- 抽象接口定義（BleAdapter）
- 平台實現（BleAdapterImpl）
- 寫入和讀取操作

**缺失對照**：
- ✅ **UUID 定義**：已創建 `ble_uuid.dart` 文件定義所有 UUID 常量
- ⚠️ **設備名稱過濾**：未看到 "coralLED EX" 和 "coralDOSE 4H" 的過濾邏輯（UUID 常量已定義，但過濾邏輯待實現）
- ✅ **命令隊列**：已實現，使用 `Queue<_QueuedCommand>` 和 `_processQueue()` 方法（在 `BleAdapterImpl` 中）
- ⚠️ **滴液量格式檢測**：未看到 detectDoseFormat 類似的邏輯（0x7E 命令）
- ⚠️ **今日累計滴液量追蹤**：未看到 todayDoseMl 類似的狀態追蹤

#### ble_led_repository_impl.dart / ble_dosing_repository_impl.dart
**狀態**: ✅ **已實現**
- BLE 命令發送和響應處理
- 各種 opcode 的處理

**缺失對照**：
- ✅ **BleContainer 類似的容器管理**：已實現 `BleContainer` 類（在 `lib/infrastructure/ble/ble_container.dart` 中）
- ✅ **LedInformation / DropInformation 狀態管理**：已實現（通過 `_LedInformationCache` 和 `_DeviceSession` 內部類）

---

## 2. Database 層面對照

### 2.1 reef-b-app Database 文件

#### DBManager.kt (Room Database)
**Entities**：
- Sink
- Scene
- Device
- DropHead
- DropType
- DeviceFavoriteScene

**Version**: 2

**Migration**: 1->2 添加 device_favorite_scene 表

#### MainDbHelper.kt (SQLiteOpenHelper)
**功能**：
- 舊的 SQLite 操作
- 創建 BUFFER 表

#### DAO 文件

##### DeviceDao.kt
**關鍵查詢**：
- `getDeviceBySinkId(sinkId)` - 根據水槽 ID 獲取設備
- `getFavoriteDevice()` - 獲取最愛設備
- `getUnassignedDevice()` - 獲取未分配設備（sinkId 為 null）
- `getMasterDeviceBySinkIdAndGroup(sinkId, group)` - 獲取主燈
- `getDeviceBySinkIdAndGroup(sinkId, group)` - 根據水槽和群組獲取設備
- `getDropInSinkBySinkId(sinkId)` - 獲取水槽內的滴液泵
- `getDeviceByMacAddress(macAddress)` - 根據 MAC 地址獲取設備

**更新操作**：
- `resetDevice()` - 設備返回預設值
- `favoriteDevice()` - 設備加入/移除最愛
- `editDevice()` - 設備編輯
- `editDeviceMaster()` - 變更主燈
- `moveGroupDevice()` - 移動群組
- `editDeviceDelayTime()` - 變更延遲時間

##### DropHeadDao.kt
**關鍵查詢**：
- `getAllDropHead()` - 獲取所有泵頭
- `getDropHeadById(id)` - 根據 ID 獲取泵頭
- `getDropHeadByDropId(deviceId)` - 根據滴液泵 ID 獲取泵頭列表

**更新操作**：
- `editDropHead()` - 泵頭編輯
- `editDropHeadDropType()` - 修改泵頭滴液種類
- `editDropHeadRotatingSpeed()` - 修改泵頭轉速
- `resetDropHead()` - 泵頭返回預設值

##### SceneDao.kt
**關鍵查詢**：
- `getSceneById(id)` - 根據 ID 獲取場景
- `getAllScene()` - 獲取所有場景
- `getFavoriteScene()` - 獲取最愛場景
- `getSceneBySceneId(code)` - 根據場景編號獲取場景
- `getSceneByLight(...)` - 根據燈光強度獲取場景

**更新操作**：
- `favoriteScene()` - 場景加入/移除最愛
- `editScene()` - 場景編輯

##### SinkDao.kt
**關鍵查詢**：
- `getSinkById(id)` - 根據 ID 獲取水槽
- `getSinkByName(name)` - 根據名稱獲取水槽
- `getAllSink()` - 獲取所有水槽
- `getAllSinkName()` - 獲取所有水槽名稱
- `getAllSinkWithDevices()` - 獲取所有水槽及水槽內裝置列表

##### DropTypeDao.kt
**功能**：管理滴液種類

##### DeviceFavoriteSceneDao.kt
**功能**：管理設備最愛場景關係

### 2.2 koralcore Database 實現

#### database_helper.dart
**狀態**: ✅ **已實現**
- SQLite 數據庫管理
- 表：devices, scenes, favorite_scenes, favorite_devices, drop_type
- Version: 3
- Migration: 1->2 (devices), 2->3 (drop_type)

**缺失對照**：
- ⚠️ **DropHead/PumpHead 表**：koralcore 沒有 drop_head 表
- ⚠️ **DeviceFavoriteScene 表**：koralcore 使用 favorite_scenes 表，但結構可能不同
- ⚠️ **Device 表的字段**：
  - reef-b-app: id, name, macAddress, sinkId, type, group, master, favorite, delayTime 等
  - koralcore: id, name, rssi, state, provisioned, is_master, is_favorite, created_at, updated_at
  - **缺失字段**：macAddress, sinkId, type, group, delayTime
- ⚠️ **Sink 表**：koralcore 沒有 sink 表（使用 SinkRepository 的內存實現）

#### Repository 實現對照

##### DeviceRepositoryImpl
**狀態**: ✅ **已實現**
- SQLite 持久化
- 基本 CRUD 操作

**缺失對照**：
- ⚠️ **根據 sinkId 查詢**：未實現
- ⚠️ **根據 MAC 地址查詢**：未實現
- ⚠️ **群組相關查詢**：未實現
- ⚠️ **主燈相關查詢**：未實現
- ⚠️ **延遲時間更新**：未實現

##### PumpHeadRepositoryImpl
**狀態**: ✅ **已實現**
- 內存實現（未持久化）

**缺失對照**：
- ⚠️ **SQLite 持久化**：koralcore 的 PumpHead 沒有數據庫表
- ⚠️ **根據 deviceId 查詢泵頭列表**：需要檢查實現

##### SceneRepositoryImpl
**狀態**: ✅ **已實現**
- SQLite 持久化
- 基本 CRUD 操作

**缺失對照**：
- ⚠️ **根據場景編號查詢**：需要檢查實現
- ⚠️ **根據燈光強度查詢**：未實現

##### SinkRepositoryImpl
**狀態**: ⚠️ **內存實現**
- 未使用 SQLite 持久化

**缺失對照**：
- ⚠️ **SQLite 持久化**：koralcore 的 Sink 沒有數據庫表
- ⚠️ **SinkWithDevices 查詢**：未實現

##### DropTypeRepositoryImpl
**狀態**: ✅ **已實現**
- SQLite 持久化
- 基本 CRUD 操作

---

## 3. Adapter 層面對照

### 3.1 reef-b-app Adapter 文件

**說明**：reef-b-app 的 adapter 是 Android RecyclerView Adapter，用於列表顯示。

**Adapter 列表**：
- BLEMyDeviceAdapter.kt
- BLEScanResultAdapter.kt
- DeviceAdapter.kt
- DropAdjustHistoryAdapter.kt
- DropCustomRecordDetailAdapter.kt
- DropHeadAdapter.kt
- DropTypeAdapter.kt
- FavoriteSceneAdapter.kt
- GroupAdapter.kt
- LedMasterAdapter.kt
- LedRecordAdapter.kt
- SceneAdapter.kt
- SceneIconAdapter.kt
- SceneSelectAdapter.kt
- SinkAdapter.kt
- SinkSelectAdapter.kt
- SinkWithDevicesAdapter.kt
- WarningAdapter.kt

### 3.2 koralcore Adapter 對應

**說明**：在 Flutter 中，Adapter 對應的是 Widget/List 實現。

**對應關係**：
- ✅ **UI Pages/Widgets**：koralcore 有對應的 UI 頁面實現
- ✅ **List 顯示**：使用 Flutter 的 ListView/GridView 等

**狀態**: ✅ **已實現**（通過 UI 層實現）

---

## 4. 總結

### 4.1 BLE 層面缺失

1. **UUID 常量定義文件**：需要創建類似 UUID.kt 的文件
2. ✅ **設備名稱過濾**：已實現設備名稱過濾（在 `DeviceNameFilter` 和 `DeviceRepositoryImpl.scanDevices` 中）
3. **命令隊列管理**：需要實現類似 ConcurrentLinkedQueue 的隊列
4. **滴液量格式檢測**：需要實現 detectDoseFormat (0x7E) 邏輯
5. ✅ **今日累計滴液量追蹤**：已實現 todayDoseMl 狀態追蹤（在 `BleDosingRepositoryImpl._DeviceSession` 中）
6. ✅ **BleContainer 類似的容器**：已實現 `BleContainer` 類
7. ✅ **LedInformation/DropInformation 狀態管理**：已實現（通過 `BleLedRepositoryImpl._LedInformationCache` 和 `BleDosingRepositoryImpl._DeviceSession`）

### 4.2 Database 層面缺失

1. **DropHead/PumpHead 表**：需要創建 drop_head 表並實現 DAO
2. **Device 表字段**：需要添加 macAddress, sinkId, type, group, delayTime 字段
3. **Sink 表**：需要創建 sink 表並實現 SQLite 持久化
4. **DeviceFavoriteScene 表**：需要確認結構是否一致
5. **查詢方法**：
   - 根據 sinkId 查詢設備
   - 根據 MAC 地址查詢設備
   - 群組相關查詢
   - 主燈相關查詢
   - SinkWithDevices 查詢
   - 根據場景編號查詢場景
   - 根據燈光強度查詢場景

### 4.3 Adapter 層面

**狀態**: ✅ **已實現**（通過 Flutter UI 層實現）

---

## 5. 優先級建議

### 高優先級
1. ✅ **Device 表字段擴展**：添加 macAddress, sinkId, type, group, delayTime（已完成）
2. ✅ **Sink 表 SQLite 持久化**：實現 Sink 的數據庫表（已完成）
3. ✅ **DropHead/PumpHead 表**：實現泵頭的數據庫持久化（已完成）
4. ✅ **UUID 常量定義**：創建 UUID 定義文件（已完成）

### 中優先級
1. **命令隊列管理**：實現 BLE 命令隊列
2. **滴液量格式檢測**：實現 0x7E 命令檢測
3. **BleContainer 類似的容器**：管理多設備 BLE 連接

### 低優先級
1. **今日累計滴液量追蹤**：實現狀態追蹤
2. ✅ **LedInformation/DropInformation 狀態管理**：已實現（通過內部狀態管理類）

