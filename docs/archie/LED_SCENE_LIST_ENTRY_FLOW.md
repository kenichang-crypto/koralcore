# LED 主頁進入場景列表流程分析

## 📋 概述

本文檔分析從 LED 主頁面點擊進入場景列表的完整流程和資訊流，對照 reef-b-app 和 koralcore 的實現。

---

## 一、reef-b-app 流程

### 1. 觸發點：點擊 btn_scene_more

**位置**: `LedMainActivity.kt` - `setListener()`

```kotlin
binding.btnSceneMore?.setOnClickListener {
    viewModel.clickBtnSceneMore {
        val intent = Intent(this, LedSceneActivity::class.java)
        intent.putExtra("device_id", viewModel.getNowDevice().id)
        startActivity(intent)
    }
}
```

**流程**：
1. 點擊 `btn_scene_more` 按鈕
2. 調用 `viewModel.clickBtnSceneMore { ... }`
3. 創建 Intent，傳遞 `device_id`
4. 啟動 `LedSceneActivity`

### 2. LedSceneActivity.onCreate()

**位置**: `LedSceneActivity.kt`

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(binding.root)
    
    setView()
    setListener()
    setObserver()
    
    deviceId = getDeviceIdFromIntent()
    if (deviceId == -1) {
        finish()
    }
    
    viewModel.setDeviceById(deviceId)
}
```

**流程**：
1. 設置視圖 (`setView()`)
2. 設置監聽器 (`setListener()`)
3. 設置觀察者 (`setObserver()`)
4. 從 Intent 獲取 `device_id`
5. 驗證 `device_id`（如果為 -1，則 finish）
6. 調用 `viewModel.setDeviceById(deviceId)`

### 3. LedSceneViewModel.setDeviceById()

**位置**: `LedSceneViewModel.kt`

```kotlin
fun setDeviceById(deviceId: Int) {
    _deviceIdLiveData.value = deviceId
    _deviceLiveData.value = deviceRepository.getDeviceById(deviceId)
    
    // 初始化 BLE 連接
    bleRepository.setDeviceById(deviceId)
    
    // 獲取 LED 資訊
    getAllLedInfo()
    
    // 獲取所有場景
    getAllScene()
}
```

**流程**：
1. 設置 `deviceId` 到 LiveData
2. 從數據庫獲取設備資訊
3. 初始化 BLE 連接 (`bleRepository.setDeviceById(deviceId)`)
4. 獲取 LED 資訊 (`getAllLedInfo()`)
5. 獲取所有場景 (`getAllScene()`)

### 4. LedSceneViewModel.getAllScene()

**位置**: `LedSceneViewModel.kt`

```kotlin
fun getAllScene() {
    viewModelScope.launch {
        _loadingLiveData.value = true
        try {
            val scenes = sceneRepository.getAllScene()
            _sceneLiveData.value = scenes
        } catch (e: Exception) {
            // 處理錯誤
        } finally {
            _loadingLiveData.value = false
        }
    }
}
```

**流程**：
1. 設置 loading 狀態為 true
2. 從 `sceneRepository` 獲取所有場景
3. 更新 `_sceneLiveData`
4. 設置 loading 狀態為 false

### 5. LedSceneActivity.setObserver()

**位置**: `LedSceneActivity.kt`

```kotlin
private fun setObserver() {
    viewModel.loadingLiveData.observe(this) {
        // 顯示/隱藏 loading
    }
    
    viewModel.sceneLiveData.observe(this) { scenes ->
        // 更新 RecyclerView adapter
        sceneAdapter.submitList(scenes)
    }
    
    viewModel.deviceLiveData.observe(this) { device ->
        // 更新設備資訊
    }
    
    viewModel.ledModeLiveData.observe(this) { mode ->
        // 更新 LED 模式
    }
}
```

**流程**：
1. 觀察 loading 狀態
2. 觀察場景列表 (`sceneLiveData`)
3. 觀察設備資訊 (`deviceLiveData`)
4. 觀察 LED 模式 (`ledModeLiveData`)

### 6. onResume()

**位置**: `LedSceneActivity.kt`

```kotlin
override fun onResume() {
    super.onResume()
    
    viewModel.setDeviceById(deviceId)
    viewModel.getAllLedInfo()
    viewModel.getAllScene()
    UserConfig.setLedModified(false)
}
```

**流程**：
1. 重新設置設備 ID
2. 重新獲取 LED 資訊
3. 重新獲取所有場景
4. 重置 LED 修改標記

---

## 二、koralcore 流程

### 1. 觸發點：點擊 btn_scene_more

**位置**: `led_main_page.dart`

```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  iconSize: 24,
  onPressed: featuresEnabled
      ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LedSceneListPage(),
            ),
          );
        }
      : null,
),
```

**流程**：
1. 點擊 `btn_scene_more` 按鈕
2. 檢查 `featuresEnabled`（BLE 連接狀態）
3. 如果啟用，導航到 `LedSceneListPage`
4. **注意**：沒有傳遞 `device_id`（使用 `AppSession.activeDeviceId`）

### 2. LedSceneListPage.build()

**位置**: `led_scene_list_page.dart`

```dart
@override
Widget build(BuildContext context) {
  final session = context.read<AppSession>();
  final appContext = context.read<AppContext>();
  return ChangeNotifierProvider<LedSceneListController>(
    create: (_) => LedSceneListController(
      session: session,
      readLedScenesUseCase: appContext.readLedScenesUseCase,
      applySceneUseCase: appContext.applySceneUseCase,
      observeLedStateUseCase: appContext.observeLedStateUseCase,
      readLedStateUseCase: appContext.readLedStateUseCase,
      stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
      observeLedRecordStateUseCase: appContext.observeLedRecordStateUseCase,
      readLedRecordStateUseCase: appContext.readLedRecordStateUseCase,
      startLedPreviewUseCase: appContext.startLedPreviewUseCase,
      startLedRecordUseCase: appContext.startLedRecordUseCase,
    )..initialize(),
    child: const _LedSceneListView(),
  );
}
```

**流程**：
1. 創建 `LedSceneListController`
2. 傳入所有必要的 UseCase
3. 調用 `initialize()` 初始化

### 3. LedSceneListController.initialize()

**位置**: `led_scene_list_controller.dart`

```dart
Future<void> initialize() async {
  await _bootstrapLedState();
  await _bootstrapRecordState();
  await refresh();
}
```

**流程**：
1. 初始化 LED 狀態 (`_bootstrapLedState()`)
2. 初始化記錄狀態 (`_bootstrapRecordState()`)
3. 刷新場景列表 (`refresh()`)

### 4. LedSceneListController.refresh()

**位置**: `led_scene_list_controller.dart`

```dart
Future<void> refresh() async {
  final deviceId = session.activeDeviceId;
  if (deviceId == null) {
    return;
  }
  
  _isLoading = true;
  notifyListeners();
  
  try {
    // 讀取場景列表
    final scenes = await readLedScenesUseCase.execute(deviceId: deviceId);
    _scenes = scenes;
    
    // 更新喜愛場景
    final favoriteIds = await _favoriteRepository.getFavoriteSceneIds(deviceId);
    _favoriteSceneIds = favoriteIds;
    
  } catch (e) {
    // 處理錯誤
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**流程**：
1. 從 `AppSession` 獲取 `activeDeviceId`
2. 設置 loading 狀態為 true
3. 調用 `readLedScenesUseCase.execute()` 獲取場景列表
4. 從 `FavoriteRepository` 獲取喜愛場景 ID
5. 更新內部狀態
6. 設置 loading 狀態為 false

### 5. onResume 處理

**位置**: `led_scene_list_page.dart`

**當前實現**：koralcore 沒有實現 `onResume` 刷新邏輯

**reef-b-app 行為**：
- 在 `onResume()` 時重新加載所有數據

---

## 三、對照比較

### 1. 導航流程

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **觸發點** | `btn_scene_more` 點擊 | `btn_scene_more` 點擊 | ✅ |
| **傳遞 device_id** | Intent.putExtra("device_id", ...) | 使用 AppSession.activeDeviceId | ⚠️ |
| **目標頁面** | LedSceneActivity | LedSceneListPage | ✅ |

### 2. 初始化流程

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **onCreate/initialize** | setView() + setListener() + setObserver() + setDeviceById() | ChangeNotifierProvider + initialize() | ✅ |
| **設置 device_id** | 從 Intent 獲取 | 從 AppSession 獲取 | ⚠️ |
| **初始化 BLE** | bleRepository.setDeviceById(deviceId) | 通過 AppSession | ⚠️ |
| **獲取 LED 資訊** | getAllLedInfo() | _bootstrapLedState() | ✅ |
| **獲取場景列表** | getAllScene() | refresh() | ✅ |

### 3. 數據加載

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **場景列表來源** | sceneRepository.getAllScene() | readLedScenesUseCase.execute() | ✅ |
| **喜愛場景** | 從場景列表中過濾 | 從 FavoriteRepository 獲取 | ⚠️ |
| **Loading 狀態** | loadingLiveData | _isLoading | ✅ |
| **數據訂閱** | LiveData 觀察者 | ChangeNotifier | ✅ |

### 4. onResume 刷新

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **onResume 刷新** | 重新加載所有數據 | ✅ WidgetsBindingObserver + refresh() | ✅ |

---

## 四、資訊流圖

### reef-b-app 資訊流

```
用戶點擊 btn_scene_more
    ↓
LedMainActivity.setListener()
    ↓
viewModel.clickBtnSceneMore { ... }
    ↓
創建 Intent (device_id)
    ↓
啟動 LedSceneActivity
    ↓
LedSceneActivity.onCreate()
    ├── setView()
    ├── setListener()
    ├── setObserver()
    └── viewModel.setDeviceById(deviceId)
        ├── 設置 deviceId 到 LiveData
        ├── 從數據庫獲取設備資訊
        ├── bleRepository.setDeviceById(deviceId)
        ├── getAllLedInfo()
        └── getAllScene()
            └── sceneRepository.getAllScene()
                └── 更新 sceneLiveData
                    └── RecyclerView adapter 更新
```

### koralcore 資訊流

```
用戶點擊 btn_scene_more
    ↓
led_main_page.dart IconButton.onPressed
    ↓
Navigator.push(LedSceneListPage)
    ↓
LedSceneListPage.build()
    ↓
創建 LedSceneListController
    ↓
controller.initialize()
    ├── _bootstrapLedState()
    ├── _bootstrapRecordState()
    └── refresh()
        ├── 從 AppSession 獲取 activeDeviceId
        ├── readLedScenesUseCase.execute()
        └── 從 FavoriteRepository 獲取喜愛場景
            └── 更新 _scenes 和 _favoriteSceneIds
                └── notifyListeners()
                    └── UI 更新
```

---

## 五、差異分析

### 1. device_id 傳遞方式

**reef-b-app**：
- 使用 Intent 明確傳遞 `device_id`
- 在 `onCreate()` 中從 Intent 獲取

**koralcore**：
- 使用 `AppSession.activeDeviceId`
- 依賴全局狀態，可能為 null

**影響**：
- 如果 `AppSession.activeDeviceId` 為 null，場景列表無法加載
- 需要確保在導航前設置 `activeDeviceId`

### 2. onResume 刷新

**reef-b-app**：
- 在 `onResume()` 時重新加載所有數據
- 確保數據最新

**koralcore**：
- 沒有實現 `onResume` 刷新邏輯
- 如果用戶在場景列表頁面時，其他頁面修改了場景，返回時不會刷新

**影響**：
- 數據可能不是最新的
- 需要實現 `WidgetsBindingObserver` 來監聽 `AppLifecycleState.resumed`

### 3. 喜愛場景獲取方式

**reef-b-app**：
- 從場景列表中過濾喜愛場景

**koralcore**：
- 從 `FavoriteRepository` 獲取喜愛場景 ID
- 然後在場景列表中標記

**影響**：
- 邏輯不同，但結果應該一致

---

## 六、需要修復的問題

### ✅ 1. 實現 onResume 刷新邏輯（已實現）

**實現**：
- 在 `_LedSceneListViewState` 中實現 `WidgetsBindingObserver`
- 監聽 `AppLifecycleState.resumed`
- 調用 `controller.refresh()` 刷新數據

**代碼位置**：`lib/ui/features/led/pages/led_scene_list_page.dart`

### ✅ 2. 確保 device_id 正確傳遞（已實現）

**實現**：
- 在 `LedSceneListPage.build()` 中檢查 `AppSession.activeDeviceId`
- 如果為 null，顯示錯誤頁面
- 確保在導航前 `activeDeviceId` 已設置（在 `LedMainPage` 中已確保）

**代碼位置**：`lib/ui/features/led/pages/led_scene_list_page.dart`

### 3. 對照 reef-b-app 的數據加載順序

**問題**：數據加載順序可能不同

**解決方案**：
- 確保數據加載順序與 reef-b-app 一致：
  1. 設置 device_id
  2. 初始化 BLE
  3. 獲取 LED 資訊
  4. 獲取場景列表

---

## 七、實施建議

### Phase 1: 實現 onResume 刷新邏輯

1. 在 `LedSceneListPage` 中實現 `WidgetsBindingObserver`
2. 監聽 `AppLifecycleState.resumed`
3. 調用 `controller.refresh()` 刷新數據

### Phase 2: 確保 device_id 正確傳遞

1. 在導航前檢查 `AppSession.activeDeviceId`
2. 如果為 null，顯示錯誤或返回

### Phase 3: 對照數據加載順序

1. 檢查 `initialize()` 方法的數據加載順序
2. 確保與 reef-b-app 一致

---

## 八、總結

### ✅ 已實現

1. 導航流程：點擊 `btn_scene_more` 導航到場景列表頁面
2. 初始化流程：創建 Controller 並初始化
3. 數據加載：從 UseCase 獲取場景列表

### ⚠️ 部分實現

1. device_id 傳遞：使用 `AppSession.activeDeviceId`，但沒有明確傳遞
2. 喜愛場景：獲取方式不同，但結果應該一致

### ✅ 已實現

1. onResume 刷新：已實現 `WidgetsBindingObserver` 來監聽 `AppLifecycleState.resumed`，並調用 `controller.refresh()` 刷新數據
2. device_id 驗證：已實現檢查 `AppSession.activeDeviceId` 是否為 null，如果為 null 則顯示錯誤

---

## 九、參考文檔

- `LedMainActivity.kt` - reef-b-app LED 主頁 Activity
- `LedSceneActivity.kt` - reef-b-app 場景列表 Activity
- `LedSceneViewModel.kt` - reef-b-app 場景列表 ViewModel
- `led_main_page.dart` - koralcore LED 主頁
- `led_scene_list_page.dart` - koralcore 場景列表頁面
- `led_scene_list_controller.dart` - koralcore 場景列表 Controller

