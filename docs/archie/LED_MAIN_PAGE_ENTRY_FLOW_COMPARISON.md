# LED 主頁進入流程對照分析

## 一、導航流程對照

### reef-b-app

**從主頁/設備頁進入**：
```kotlin
// DeviceFragment.onClickDevice()
when (data.type) {
    DeviceType.LED -> {
        val intent = Intent(requireContext(), LedMainActivity::class.java)
        intent.putExtra("device_id", data.id)
        startActivity(intent)
    }
}
```

**流程**：
1. 點擊設備卡片
2. 創建 Intent，傳遞 `device_id`
3. 啟動 `LedMainActivity`

---

### koralcore

**從主頁進入**：
```dart
// home_page.dart _navigate()
void _navigate(BuildContext context, _DeviceKind kind) {
  final Widget page = kind == _DeviceKind.led
      ? const LedMainPage()
      : const DosingMainPage();
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
```

**問題**：
- ❌ **未傳遞 device_id**：reef-b-app 通過 Intent 傳遞 `device_id`，但 koralcore 沒有傳遞
- ❌ **未設置 activeDeviceId**：需要確保 `AppSession.activeDeviceId` 在進入頁面前已設置

---

## 二、生命週期對照

### reef-b-app: LedMainActivity

#### onCreate()
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(binding.root)
    
    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    
    setView()              // 設置視圖（RecyclerView、Chart 等）
    setListener()          // 設置點擊監聽器
    setObserver()          // 設置 LiveData 觀察者
    
    deviceId = getDeviceIdFromIntent()  // 從 Intent 獲取 device_id
    if (deviceId == -1) {
        finish()
    }
    
    viewModel.setDeviceById(deviceId)   // 設置設備並初始化
    UserConfig.setLedModified(false)    // 重置修改標記
}
```

#### onResume()
```kotlin
override fun onResume() {
    super.onResume()
    
    viewModel.setDeviceById(deviceId)        // 重新設置設備
    viewModel.getAllLedInfo()                // 獲取所有 LED 資訊
    viewModel.getNowRecords()                 // 獲取當前記錄
    viewModel.getAllFavoriteScene()          // 獲取所有喜愛場景
    UserConfig.setLedModified(false)         // 重置修改標記
    setBleStateUi(viewModel.isConnectNowDevice())  // 設置 BLE 狀態 UI
}
```

#### onStop()
```kotlin
override fun onStop() {
    viewModel.onStop()  // 停止預覽（如果正在預覽）
    super.onStop()
}
```

---

### koralcore: LedMainPage

#### build()
```dart
@override
Widget build(BuildContext context) {
  final appContext = context.read<AppContext>();
  final session = context.read<AppSession>();
  
  return ChangeNotifierProvider<LedSceneListController>(
    create: (_) => LedSceneListController(...)..initialize(),
    child: const _LedMainScaffold(),
  );
}
```

**問題**：
- ❌ **沒有對應 onResume**：koralcore 使用 Flutter 的 `StatefulWidget`，但沒有實現 `WidgetsBindingObserver` 來監聽 `AppLifecycleState.resumed`
- ❌ **沒有在頁面顯示時刷新數據**：reef-b-app 在 `onResume` 時會重新加載所有數據，但 koralcore 只在 `initialize()` 時加載一次

---

## 三、數據加載流程對照

### reef-b-app: LedMainViewModel

#### setDeviceById(id: Int)
```kotlin
fun setDeviceById(id: Int) {
    _loadingLiveData.value = true
    nowDevice = dbGetDeviceById(id)              // 從數據庫獲取設備
    _deviceLiveData.value = nowDevice            // 發送設備 LiveData
    _loadingLiveData.value = false
    
    // BLE 相關初始化
    if (!BleContainer.getInstance().isExistBleManager(nowDevice.macAddress)) {
        BleContainer.getInstance().new(nowDevice.macAddress)
    }
    bleManager = BleContainer.getInstance().getBleManager(nowDevice.macAddress)!!
    bleManager.setListener(this)                 // 設置 BLE 監聽器
    bleSyncInformation()                        // 同步 BLE 資訊
    
    getAllLedInfo()                              // 獲取所有 LED 資訊
}
```

#### getAllLedInfo()
```kotlin
fun getAllLedInfo() {
    ledInformation = BleContainer.getInstance().getLedInformation(nowDevice.macAddress)!!
    bleSyncInformation()  // 同步 BLE 資訊（獲取 LED 狀態、場景、排程等）
}
```

#### getNowRecords()
```kotlin
fun getNowRecords() {
    // 從 ledInformation 獲取記錄
    val records = ledInformation.getRecords()
    _recordsLiveData.value = records
}
```

#### getAllFavoriteScene()
```kotlin
fun getAllFavoriteScene() {
    _loadingLiveData.value = true
    val deviceId = if (::nowDevice.isInitialized) nowDevice.id else null
    
    val favoriteScene: List<Scene> =
        deviceId?.let { dbDeviceFavoriteScene.getFavoritesByDevice(it) } ?: emptyList()
    
    _favoriteSceneLiveData.value = favoriteScene
    _loadingLiveData.value = false
}
```

**數據加載順序**：
1. `setDeviceById()` → 設置設備、初始化 BLE、獲取 LED 資訊
2. `getAllLedInfo()` → 從 BLE 同步 LED 資訊（狀態、場景、排程）
3. `getNowRecords()` → 獲取記錄數據
4. `getAllFavoriteScene()` → 從數據庫獲取喜愛場景

---

### koralcore: LedSceneListController

#### initialize()
```dart
Future<void> initialize() async {
  if (_initialized) {
    return;
  }
  _initialized = true;
  
  await _bootstrapLedState();        // 引導 LED 狀態
  await _bootstrapRecordState();    // 引導記錄狀態
  await refresh();                   // 刷新場景列表
  _subscribeToLedState();           // 訂閱 LED 狀態變化
  _subscribeToRecordState();        // 訂閱記錄狀態變化
}
```

#### _bootstrapLedState()
```dart
Future<void> _bootstrapLedState() async {
  final String? deviceId = session.activeDeviceId;
  if (deviceId == null) {
    return;
  }
  
  try {
    final LedState state = await readLedStateUseCase.execute(deviceId: deviceId);
    _updateFromState(state);
  } catch (_) {
    // 處理錯誤
  }
}
```

#### _bootstrapRecordState()
```dart
Future<void> _bootstrapRecordState() async {
  final String? deviceId = session.activeDeviceId;
  if (deviceId == null) {
    return;
  }
  
  try {
    final LedRecordState state = await readLedRecordStateUseCase.execute(deviceId: deviceId);
    _updateFromRecordState(state);
  } catch (_) {
    // 處理錯誤
  }
}
```

#### refresh()
```dart
Future<void> refresh() async {
  _isLoading = true;
  notifyListeners();
  
  final String? deviceId = session.activeDeviceId;
  if (deviceId == null) {
    _scenes = const [];
    _setError(AppErrorCode.noActiveDevice);
    _isLoading = false;
    notifyListeners();
    return;
  }
  
  try {
    final List<LedSceneSummary> scenes = await readLedScenesUseCase.execute(deviceId: deviceId);
    _scenes = scenes;
    _lastErrorCode = null;
  } on AppError catch (error) {
    _scenes = const [];
    _setError(error.code);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**數據加載順序**：
1. `_bootstrapLedState()` → 讀取 LED 狀態（場景、排程、通道等級等）
2. `_bootstrapRecordState()` → 讀取記錄狀態（記錄列表）
3. `refresh()` → 刷新場景列表
4. `_subscribeToLedState()` → 訂閱 LED 狀態變化（實時更新）
5. `_subscribeToRecordState()` → 訂閱記錄狀態變化（實時更新）

---

## 四、資訊流對照

### reef-b-app

**數據來源**：
1. **設備資訊**：從數據庫 (`dbGetDeviceById`)
2. **LED 資訊**：從 BLE (`BleContainer.getLedInformation`) → 通過 `bleSyncInformation()` 同步
3. **記錄數據**：從 `LedInformation.getRecords()`
4. **喜愛場景**：從數據庫 (`dbDeviceFavoriteScene.getFavoritesByDevice`)

**更新時機**：
- **onCreate**：初始加載
- **onResume**：每次頁面顯示時重新加載（確保數據最新）

**BLE 同步**：
- `bleSyncInformation()` 會從 BLE 設備讀取：
  - LED 狀態（當前場景、排程、通道等級等）
  - 記錄數據
  - 設備連接狀態

---

### koralcore

**數據來源**：
1. **設備資訊**：從 `AppSession.activeDeviceId`（需要確保已設置）
2. **LED 狀態**：從 `ReadLedStateUseCase`（通過 BLE 讀取）
3. **記錄狀態**：從 `ReadLedRecordStateUseCase`（通過 BLE 讀取）
4. **場景列表**：從 `ReadLedScenesUseCase`（從數據庫讀取）

**更新時機**：
- **initialize()**：只在控制器創建時執行一次
- **訂閱流**：通過 `observeLedStateUseCase` 和 `observeLedRecordStateUseCase` 實時更新

**問題**：
- ❌ **沒有對應 onResume 的刷新**：koralcore 沒有在頁面顯示時重新加載數據
- ⚠️ **依賴 AppSession.activeDeviceId**：需要確保在進入頁面前已設置

---

## 五、關鍵差異總結

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **導航時傳遞 device_id** | ✅ 通過 Intent | ❌ 未傳遞 | ❌ |
| **onCreate 初始化** | ✅ setDeviceById + getAllLedInfo | ✅ initialize() | ✅ |
| **onResume 刷新** | ✅ 重新加載所有數據 | ❌ 沒有實現 | ❌ |
| **BLE 同步** | ✅ bleSyncInformation() | ✅ 通過 UseCase | ✅ |
| **數據訂閱** | ✅ LiveData 觀察者 | ✅ Stream 訂閱 | ✅ |
| **記錄數據獲取** | ✅ getNowRecords() | ✅ _bootstrapRecordState() | ✅ |
| **喜愛場景獲取** | ✅ getAllFavoriteScene() | ⚠️ 在 refresh() 中？ | ⚠️ |
| **屏幕常亮** | ✅ FLAG_KEEP_SCREEN_ON | ❌ 未實現 | ❌ |

---

## 六、需要修復的問題

### 高優先級

1. **實現 onResume 刷新邏輯**
   - **問題**：koralcore 沒有在頁面顯示時重新加載數據
   - **修復**：在 `_LedMainScaffoldState` 中實現 `WidgetsBindingObserver`，監聽 `AppLifecycleState.resumed`，調用 `controller.refresh()` 和相關刷新方法

2. **確保 device_id 傳遞**
   - **問題**：從主頁進入時沒有傳遞 device_id
   - **修復**：在導航前設置 `AppSession.activeDeviceId`，或在 `LedMainPage` 構造函數中接收 `deviceId` 參數

3. **實現屏幕常亮**
   - **問題**：reef-b-app 在 LED 主頁時保持屏幕常亮
   - **修復**：使用 `SystemChrome.setEnabledSystemUIMode` 或 `Wakelock` 插件

### 中優先級

4. **確認喜愛場景加載**
   - **問題**：需要確認 koralcore 是否正確加載喜愛場景
   - **檢查**：查看 `_FavoriteSceneSection` 的數據來源

5. **對照數據加載順序**
   - **問題**：確保數據加載順序與 reef-b-app 一致
   - **檢查**：對照 `setDeviceById` → `getAllLedInfo` → `getNowRecords` → `getAllFavoriteScene` 的順序

---

## 七、實現建議

### 1. 實現 onResume 刷新

```dart
class _LedMainScaffoldState extends State<_LedMainScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // PARITY: reef-b-app onResume() - 重新加載數據
      final controller = context.read<LedSceneListController>();
      controller.refresh();
      // 可能需要刷新其他數據（記錄、喜愛場景等）
    }
  }
}
```

### 2. 確保 device_id 傳遞

```dart
// 在 home_page.dart 中
void _navigate(BuildContext context, _DeviceKind kind, String deviceId) {
  // 設置 activeDeviceId
  final session = context.read<AppSession>();
  session.setActiveDevice(deviceId);
  
  final Widget page = kind == _DeviceKind.led
      ? const LedMainPage()
      : const DosingMainPage();
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
```

### 3. 實現屏幕常亮

```dart
import 'package:wakelock_plus/wakelock_plus.dart';

@override
void initState() {
  super.initState();
  // PARITY: reef-b-app FLAG_KEEP_SCREEN_ON
  WakelockPlus.enable();
}

@override
void dispose() {
  WakelockPlus.disable();
  super.dispose();
}
```

---

## 八、數據流圖

### reef-b-app

```
進入 LedMainActivity
    ↓
onCreate()
    ↓
setDeviceById(deviceId)
    ├─→ 從數據庫獲取設備
    ├─→ 初始化 BLE Manager
    ├─→ 設置 BLE 監聽器
    └─→ getAllLedInfo()
            └─→ bleSyncInformation() → 從 BLE 讀取 LED 資訊
    ↓
onResume()
    ├─→ setDeviceById(deviceId) → 重新設置設備
    ├─→ getAllLedInfo() → 重新同步 LED 資訊
    ├─→ getNowRecords() → 獲取記錄
    ├─→ getAllFavoriteScene() → 從數據庫獲取喜愛場景
    └─→ setBleStateUi() → 更新 BLE 狀態 UI
```

### koralcore

```
進入 LedMainPage
    ↓
build()
    ↓
ChangeNotifierProvider<LedSceneListController>
    ↓
initialize()
    ├─→ _bootstrapLedState() → 讀取 LED 狀態
    ├─→ _bootstrapRecordState() → 讀取記錄狀態
    ├─→ refresh() → 刷新場景列表
    ├─→ _subscribeToLedState() → 訂閱 LED 狀態變化
    └─→ _subscribeToRecordState() → 訂閱記錄狀態變化
    ↓
[缺少 onResume 刷新]
```

---

## 總結

**主要問題**：
1. ❌ 沒有實現 onResume 刷新邏輯
2. ❌ 沒有確保 device_id 傳遞
3. ❌ 沒有實現屏幕常亮

**數據加載**：
- ✅ 初始化流程基本對照
- ⚠️ 缺少頁面顯示時的刷新

**建議優先修復**：
1. 實現 onResume 刷新邏輯（最重要）
2. 確保 device_id 正確傳遞
3. 實現屏幕常亮功能

