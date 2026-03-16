# LED 場景編輯頁面進入流程資訊流對照

## 一、導航流程

### reef-b-app

**觸發點**: `LedSceneActivity.onClickScene()`
```kotlin
override fun onClickScene(data: Scene) {
    super.onClickScene(data)
    
    //TODO 換成bundle
    val intent = Intent(this, LedSceneEditActivity::class.java)
    intent.putExtra("scene_id", data.id)
    startActivity(intent)
}
```

**接收**: `LedSceneEditActivity.onCreate()`
```kotlin
private fun getSceneIdFromIntent(): Int {
    //TODO 換成bundle
    return intent.getIntExtra("scene_id", -1)
}

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(binding.root)
    
    setView()
    setListener()
    setObserver()
}

private fun setView() {
    val sceneId = getSceneIdFromIntent()
    if (sceneId == -1) {
        finish()
    }
    viewModel.setNowSceneId(sceneId)
    // ...
}
```

### koralcore

**觸發點**: `LedSceneListPage._SceneCard.onTap`
```dart
onTap: isConnected && !controller.isBusy
    ? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LedSceneEditPage(sceneId: scene.id),
          ),
        );
      }
    : null,
```

**接收**: `LedSceneEditPage.build()`
```dart
class LedSceneEditPage extends StatelessWidget {
  final String sceneId;
  
  const LedSceneEditPage({super.key, required this.sceneId});
  
  @override
  Widget build(BuildContext context) {
    // ...
    return FutureBuilder<_SceneEditData?>(
      future: _loadSceneData(deviceId, sceneId),
      // ...
    );
  }
}
```

**狀態**: ✅ **已對照**
- reef-b-app: 通過 Intent 傳遞 `scene_id` (Int)
- koralcore: 通過構造函數參數傳遞 `sceneId` (String)

---

## 二、數據加載流程

### reef-b-app

**步驟 1**: `LedSceneEditViewModel.setNowSceneId()`
```kotlin
fun setNowSceneId(id: Int) {
    _loadingLiveData.value = true
    val scene = dbGetSceneById(id)
    _sceneLiveData.value = scene
    _loadingLiveData.value = false
}
```

**步驟 2**: `LedSceneEditActivity.setObserver()` 觀察 `sceneLiveData`
```kotlin
viewModel.sceneLiveData.observe(this) { scene ->
    binding.apply {
        edtName.setText(scene.name)
        scene.uv?.let { slUvLight.value = it.toFloat() }
        scene.purple?.let { slPurpleLight.value = it.toFloat() }
        scene.blue?.let { slBlueLight.value = it.toFloat() }
        scene.royalBlue?.let { slRoyalBlueLight.value = it.toFloat() }
        scene.green?.let { slGreenLight.value = it.toFloat() }
        scene.red?.let { slRedLight.value = it.toFloat() }
        scene.coldWhite?.let { slColdWhiteLight.value = it.toFloat() }
        scene.warmWhite?.let { slWarmWhiteLight.value = it.toFloat() }
        scene.moon?.let { slMoonLight.value = it.toFloat() }
    }
    iconAdapter.setNowSelect(scene.icon)
    viewModel.bleDimming()  // 進入調光模式
}
```

**數據來源**: 從數據庫獲取場景數據
```kotlin
private fun dbGetSceneById(id: Int): Scene {
    return dbScene.getSceneById(id)
}
```

### koralcore

**步驟 1**: `LedSceneEditPage._loadSceneData()`
```dart
Future<_SceneEditData?> _loadSceneData(
  String? deviceId,
  String sceneIdString,
) async {
  if (deviceId == null) {
    throw Exception('No active device');
  }
  
  // Parse sceneId: "local_scene_1" -> 1
  final int? sceneId = _parseLocalSceneId(sceneIdString);
  if (sceneId == null) {
    throw Exception('Invalid scene ID format');
  }
  
  final sceneRepository = SceneRepositoryImpl();
  final sceneRecord = await sceneRepository.getSceneById(
    deviceId: deviceId,
    sceneId: sceneId,
  );
  
  if (sceneRecord == null) {
    throw Exception('Scene not found');
  }
  
  return _SceneEditData(
    sceneId: sceneId,
    name: sceneRecord.name,
    channelLevels: sceneRecord.channelLevels,
    iconId: sceneRecord.iconId,
  );
}
```

**步驟 2**: 使用 `FutureBuilder` 加載數據，然後創建 `LedSceneEditController`
```dart
return ChangeNotifierProvider<LedSceneEditController>(
  create: (_) => LedSceneEditController(
    session: session,
    // ...
    initialSceneId: sceneData.sceneId,
    initialName: sceneData.name,
    initialChannelLevels: sceneData.channelLevels,
    initialIconId: sceneData.iconId,
  ),
  child: _LedSceneEditView(sceneId: sceneData.sceneId),
);
```

**狀態**: ✅ **已對照**
- reef-b-app: 在 ViewModel 中加載數據，通過 LiveData 更新 UI
- koralcore: 使用 FutureBuilder 加載數據，然後初始化 Controller

---

## 三、初始化動作

### reef-b-app

**1. 設置場景 ID**
```kotlin
viewModel.setNowSceneId(sceneId)
```

**2. 設置圖標選擇器**
```kotlin
iconAdapter.setNowSelect(getSceneIdFromIntent())
```

**3. 初始化 SpectrumUtil**
```kotlin
val spectrumUtil = SpectrumUtil(
    binding.chartSpectrum,
    binding.slUvLight,
    binding.slPurpleLight,
    binding.slBlueLight,
    binding.slRoyalBlueLight,
    binding.slGreenLight,
    binding.slRedLight,
    binding.slColdWhiteLight,
    binding.slMoonLight
).init()
```

**4. 設置滑塊自定義圖標**
```kotlin
binding.slUvLight.setCustomThumbDrawable(R.drawable.ic_uv_light_thumb)
binding.slPurpleLight.setCustomThumbDrawable(R.drawable.ic_purple_light_thumb)
binding.slBlueLight.setCustomThumbDrawable(R.drawable.ic_blue_light_thumb)
binding.slRoyalBlueLight.setCustomThumbDrawable(R.drawable.ic_royal_blue_light_thumb)
binding.slGreenLight.setCustomThumbDrawable(R.drawable.ic_green_light_thumb)
binding.slRedLight.setCustomThumbDrawable(R.drawable.ic_red_light_thumb)
binding.slColdWhiteLight.setCustomThumbDrawable(R.drawable.ic_cold_white_light_thumb)
binding.slMoonLight.setCustomThumbDrawable(R.drawable.ic_moon_light_thumb)
```

**5. 設置名稱輸入框**
```kotlin
binding.edtName.apply {
    autoTrim(this)
    doAfterTextChanged {
        viewModel.setName(it.toString())
    }
}
```

**6. 當場景數據加載完成後，進入調光模式**
```kotlin
viewModel.sceneLiveData.observe(this) { scene ->
    // ... 設置 UI 數據
    viewModel.bleDimming()  // 進入調光模式
}
```

### koralcore

**1. 加載場景數據**
```dart
FutureBuilder<_SceneEditData?>(
  future: _loadSceneData(deviceId, sceneId),
  // ...
)
```

**2. 初始化 Controller**
```dart
ChangeNotifierProvider<LedSceneEditController>(
  create: (_) => LedSceneEditController(
    // ...
    initialSceneId: sceneData.sceneId,
    initialName: sceneData.name,
    initialChannelLevels: sceneData.channelLevels,
    initialIconId: sceneData.iconId,
  ),
  // ...
)
```

**3. 自動進入調光模式**
```dart
@override
void initState() {
  super.initState();
  _controller = context.read<LedSceneEditController>();
  // Auto-enter dimming mode when page opens
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _controller.enterDimmingMode();
  });
}
```

**狀態**: ⚠️ **有差異**
- reef-b-app: 在場景數據加載完成後才進入調光模式（`viewModel.bleDimming()`）
- koralcore: 在頁面初始化時就進入調光模式（`initState` 中的 `addPostFrameCallback`）

**建議**: 應該在場景數據加載完成後再進入調光模式，對照 reef-b-app 的行為。

---

## 四、BLE 調光模式

### reef-b-app

**進入調光模式**: `LedSceneEditViewModel.bleDimming()`
```kotlin
fun bleDimming() {
    bleManager.addQueue(CommandManager.getLedEnterDimmingModeCommand())
}
```

**退出調光模式**: `LedSceneEditViewModel.clickBtnBack()`
```kotlin
fun clickBtnBack() {
    bleExitDimmingMode()
}

private fun bleExitDimmingMode() {
    bleManager.addQueue(CommandManager.getLedExitDimmingModeCommand())
}
```

**觀察退出事件**: `LedSceneEditActivity.setObserver()`
```kotlin
viewModel.exitDimmingModeLiveData.observe(this) {
    finish()
}
```

### koralcore

**進入調光模式**: `LedSceneEditController.enterDimmingMode()`
```dart
Future<void> enterDimmingMode() async {
  // ...
  await enterDimmingModeUseCase.execute(deviceId: deviceId);
  // ...
}
```

**退出調光模式**: `_LedSceneEditViewState.dispose()`
```dart
@override
void dispose() {
  // Auto-exit dimming mode when page closes
  _controller.exitDimmingMode();
  super.dispose();
}
```

**狀態**: ✅ **已對照**
- reef-b-app: 在數據加載完成後進入調光模式，返回時退出
- koralcore: 在頁面初始化時進入調光模式，dispose 時退出

---

## 五、UI 數據綁定

### reef-b-app

**場景數據綁定**:
```kotlin
viewModel.sceneLiveData.observe(this) { scene ->
    binding.apply {
        edtName.setText(scene.name)
        scene.uv?.let { slUvLight.value = it.toFloat() }
        scene.purple?.let { slPurpleLight.value = it.toFloat() }
        scene.blue?.let { slBlueLight.value = it.toFloat() }
        scene.royalBlue?.let { slRoyalBlueLight.value = it.toFloat() }
        scene.green?.let { slGreenLight.value = it.toFloat() }
        scene.red?.let { slRedLight.value = it.toFloat() }
        scene.coldWhite?.let { slColdWhiteLight.value = it.toFloat() }
        scene.warmWhite?.let { slWarmWhiteLight.value = it.toFloat() }
        scene.moon?.let { slMoonLight.value = it.toFloat() }
    }
    iconAdapter.setNowSelect(scene.icon)
    viewModel.bleDimming()
}
```

**滑塊監聽**:
```kotlin
binding.slUvLight.addOnChangeListener { _, value, _ ->
    val valueInt = value.toInt()
    binding.tvUvLight.text = "$valueInt"
    viewModel.setSlUvLight(valueInt)
}
// ... 其他滑塊類似
```

### koralcore

**場景數據綁定**:
```dart
ChangeNotifierProvider<LedSceneEditController>(
  create: (_) => LedSceneEditController(
    // ...
    initialSceneId: sceneData.sceneId,
    initialName: sceneData.name,
    initialChannelLevels: sceneData.channelLevels,
    initialIconId: sceneData.iconId,
  ),
  // ...
)
```

**滑塊監聽**:
```dart
Slider(
  value: value.toDouble(),
  min: 0,
  max: 100,
  divisions: 100,
  label: '$value%',
  onChanged: enabled && controller.isDimmingMode
      ? (newValue) => controller.setChannelLevel(id, newValue.toInt())
      : null,
),
```

**狀態**: ✅ **已對照**
- reef-b-app: 通過 LiveData 觀察者模式更新 UI
- koralcore: 通過 ChangeNotifier 和 Controller 更新 UI

---

## 六、完整流程對照

### reef-b-app 流程

1. **點擊場景卡片** → `LedSceneActivity.onClickScene()`
2. **創建 Intent** → `Intent.putExtra("scene_id", data.id)`
3. **啟動 Activity** → `startActivity(intent)`
4. **onCreate** → `getSceneIdFromIntent()` → `viewModel.setNowSceneId(sceneId)`
5. **ViewModel 加載數據** → `dbGetSceneById(id)` → `_sceneLiveData.value = scene`
6. **觀察者更新 UI** → `sceneLiveData.observe()` → 設置所有 UI 元素
7. **進入調光模式** → `viewModel.bleDimming()` → 發送 BLE 命令

### koralcore 流程

1. **點擊場景卡片** → `_SceneCard.onTap`
2. **導航到編輯頁面** → `Navigator.push(LedSceneEditPage(sceneId: scene.id))`
3. **FutureBuilder 加載數據** → `_loadSceneData(deviceId, sceneId)`
4. **創建 Controller** → `LedSceneEditController(initialSceneId, initialName, ...)`
5. **initState** → `addPostFrameCallback(() => _controller.enterDimmingMode())`
6. **UI 綁定** → Controller 的 ChangeNotifier 更新 UI

---

## 七、差異總結

### ✅ 已對照

1. **導航流程** - 傳遞 scene_id
2. **數據加載** - 從數據庫/Repository 獲取場景數據
3. **UI 數據綁定** - 設置場景名稱、通道強度、圖標
4. **滑塊監聽** - 實時更新通道強度
5. **退出調光模式** - 在頁面關閉時退出

### ⚠️ 需要修復

1. **進入調光模式的時機**
   - **reef-b-app**: 在場景數據加載完成後才進入調光模式（`viewModel.bleDimming()`）
   - **koralcore**: 在頁面初始化時就進入調光模式（`initState` 中的 `addPostFrameCallback`）
   - **建議**: 應該在場景數據加載完成後再進入調光模式，對照 reef-b-app 的行為

2. **場景 ID 格式**
   - **reef-b-app**: 使用 Int 類型的 scene_id
   - **koralcore**: 使用 String 類型的 sceneId（格式：`"local_scene_1"`），需要解析為 Int
   - **狀態**: 已處理（通過 `_parseLocalSceneId` 解析）

---

## 八、修復建議

### 高優先級

1. **修復進入調光模式的時機**
   - 應該在場景數據加載完成後再進入調光模式
   - 修改 `_LedSceneEditViewState.initState()`，將 `enterDimmingMode()` 移到數據加載完成後

### 中優先級

2. **確保數據加載順序**
   - 確保場景數據完全加載後再初始化 Controller
   - 確保 UI 元素都設置完成後再進入調光模式

---

## 九、實現狀態總結

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **導航傳遞 scene_id** | ✅ Intent.putExtra("scene_id", data.id) | ✅ LedSceneEditPage(sceneId: scene.id) | ✅ |
| **數據加載** | ✅ ViewModel.setNowSceneId() → dbGetSceneById() | ✅ FutureBuilder → _loadSceneData() | ✅ |
| **UI 數據綁定** | ✅ sceneLiveData.observe() → 設置所有 UI | ✅ Controller 初始化時設置 initial 值 | ✅ |
| **進入調光模式** | ✅ 數據加載完成後 bleDimming() | ⚠️ initState 中立即進入 | ⚠️ |
| **退出調光模式** | ✅ clickBtnBack() → bleExitDimmingMode() | ✅ dispose() → exitDimmingMode() | ✅ |
| **滑塊監聽** | ✅ addOnChangeListener → setSlXxxLight() | ✅ onChanged → setChannelLevel() | ✅ |

**整體狀態**: ⚠️ **需要修復進入調光模式的時機**

