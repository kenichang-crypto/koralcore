# LED 主頁按鍵功能實現對照表

## 一、Toolbar 按鍵功能對照

| 按鍵 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnBack (返回)** | ✅ `clickBtnBack()` - 如果正在預覽，停止預覽；否則 `finish()` | ✅ `Navigator.pop()` - 直接返回，無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在返回時檢查並停止預覽 |
| **btnMenu (菜單)** | ✅ `clickBtnMenu()` - 如果正在預覽，停止預覽；否則顯示 PopupMenu (edit, delete, reset) | ✅ `PopupMenuButton` - 顯示 PopupMenu (edit, delete, reset)，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊菜單時檢查並停止預覽 |
| **btnFavorite (收藏)** | ✅ `clickBtnFavorite()` - 如果正在預覽，停止預覽；否則切換收藏狀態 | ✅ `IconButton` - 調用 `toggleFavoriteDeviceUseCase.execute()`，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊收藏時檢查並停止預覽 |

### 詳細對照

#### 1. btnBack (返回)

**reef-b-app**:
```kotlin
binding.toolbarLedMain?.btnBack?.setOnClickListener {
    viewModel.clickBtnBack {
        finish()
    }
}

// LedMainViewModel.kt
fun clickBtnBack(canAction: () -> Unit) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        canAction()
    }
}
```

**koralcore**:
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: ReefColors.onPrimary),
  onPressed: () => Navigator.of(context).pop(),
),
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則執行 `finish()`
- koralcore：直接返回，沒有檢查預覽狀態

**建議**：在 `onPressed` 中添加預覽檢查，如果正在預覽則先停止預覽。

---

#### 2. btnMenu (菜單)

**reef-b-app**:
```kotlin
binding.toolbarLedMain?.btnMenu?.setOnClickListener { view ->
    viewModel.clickBtnMenu {
        val pop = PopupMenu(this, view)
        pop.inflate(R.menu.led_menu)
        // ... menu items (edit, delete, reset)
        pop.show()
    }
}

// LedMainViewModel.kt
fun clickBtnMenu(canAction: () -> Unit) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        canAction()
    }
}
```

**koralcore**:
```dart
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert, color: ReefColors.onPrimary),
  enabled: featuresEnabled && !controller.isPreviewing,
  onSelected: (value) {
    switch (value) {
      case 'edit': // ...
      case 'delete': // ...
      case 'reset': // ...
    }
  },
  // ...
)
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則顯示菜單
- koralcore：通過 `enabled: featuresEnabled && !controller.isPreviewing` 禁用菜單按鈕（當正在預覽時），但不停止預覽

**建議**：在點擊菜單時，如果正在預覽，先停止預覽，然後顯示菜單。

---

#### 3. btnFavorite (收藏)

**reef-b-app**:
```kotlin
binding.toolbarLedMain?.btnFavorite?.setOnClickListener {
    viewModel.clickBtnFavorite()
}

// LedMainViewModel.kt
fun clickBtnFavorite() {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        if (isFavorite()) {
            dbFavoriteDevice(DeviceFavorite(nowDevice.id, false))
            _favoriteDeviceLiveData.value = false
        } else {
            dbFavoriteDevice(DeviceFavorite(nowDevice.id, true))
            _favoriteDeviceLiveData.value = true
        }
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
  onPressed: featuresEnabled && !controller.isPreviewing && deviceId != null
      ? () async {
          await appContext.toggleFavoriteDeviceUseCase.execute(deviceId: deviceId);
        }
      : null,
)
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則切換收藏狀態
- koralcore：通過 `!controller.isPreviewing` 禁用收藏按鈕（當正在預覽時），但不停止預覽

**建議**：在點擊收藏時，如果正在預覽，先停止預覽，然後切換收藏狀態。

---

## 二、Device Info Section 按鍵功能對照

| 按鍵 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnBle (BLE 連接狀態)** | ✅ `clickBtnBle()` - 如果正在預覽，停止預覽；否則如果已連接則斷開，如果未連接則連接 | ✅ `_handleBleIconTap()` - 如果已連接則斷開，如果未連接則連接，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊 BLE 時檢查並停止預覽 |

### 詳細對照

#### btnBle (BLE 連接狀態)

**reef-b-app**:
```kotlin
binding.btnBle?.setOnClickListener {
    checkBlePermission(this) {
        viewModel.clickBtnBle()
    }
}

// LedMainViewModel.kt
fun clickBtnBle() {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        if (isConnectNowDevice()) {
            disConnect()
        } else {
            if (!BleContainer.getInstance().isExistBleManager(nowDevice.macAddress)) {
                setDeviceById(nowDevice.id)
            }
            connectDeviceByMacAddress(nowDevice.macAddress)
        }
    }
}
```

**koralcore**:
```dart
GestureDetector(
  onTap: () => _handleBleIconTap(context, appContext),
  // ...
)

Future<void> _handleBleIconTap(BuildContext context, AppContext appContext) async {
  // ...
  if (isConnected) {
    await appContext.disconnectDeviceUseCase.execute(deviceId: deviceId);
  } else {
    await appContext.connectDeviceUseCase.execute(deviceId: deviceId);
  }
}
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則切換連接狀態
- koralcore：直接切換連接狀態，沒有檢查預覽狀態

**建議**：在 `_handleBleIconTap` 中添加預覽檢查，如果正在預覽則先停止預覽。

---

## 三、Record Section 按鍵功能對照

| 按鍵 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnRecordMore (Record 更多)** | ✅ `clickBtnRecordMore()` - 如果正在預覽，停止預覽；否則根據是否有記錄導航到不同頁面 | ✅ `IconButton` - 根據 `controller.hasRecords` 導航到不同頁面，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊 Record 更多時檢查並停止預覽 |
| **btnExpand (展開/橫屏切換)** | ✅ `clickBtnExpand()` - 如果正在預覽，停止預覽；否則切換橫屏/豎屏 | ✅ `_toggleOrientation()` - 切換橫屏/豎屏，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊展開時檢查並停止預覽 |
| **btnPreview (預覽)** | ✅ `clickBtnPreview()` - 如果正在預覽，停止預覽；否則開始預覽 | ✅ `controller.togglePreview` - 切換預覽狀態 | ✅ | **已實現** |
| **btnContinueRecord (繼續 Record)** | ✅ `clickBtnContinueRecord()` - 如果正在預覽，停止預覽；否則開始 Record | ✅ `controller.startRecord` - 開始 Record，但無預覽檢查 | ⚠️ | **差異**：koralcore 的 `startRecord` 內部會停止預覽，但邏輯略有不同 |

### 詳細對照

#### 1. btnRecordMore (Record 更多)

**reef-b-app**:
```kotlin
binding.btnRecordMore?.setOnClickListener {
    viewModel.clickBtnRecordMore {
        if (viewModel.isRecordEmpty()) {
            startActivity(LedRecordSettingActivity::class.java)
        } else {
            startActivity(LedRecordActivity::class.java)
        }
    }
}

// LedMainViewModel.kt
fun clickBtnRecordMore(canAction: () -> Unit) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        canAction()
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  onPressed: featuresEnabled
      ? () {
          if (controller.hasRecords) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LedRecordPage()));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LedRecordSettingPage()));
          }
        }
      : null,
)
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則導航
- koralcore：直接導航，沒有檢查預覽狀態

**建議**：在點擊 Record 更多時，如果正在預覽，先停止預覽，然後導航。

---

#### 2. btnExpand (展開/橫屏切換)

**reef-b-app**:
```kotlin
binding.btnExpand.setOnClickListener {
    viewModel.clickBtnExpand {
        requestedOrientation = when (requestedOrientation) {
            ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE -> {
                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            }
            else -> {
                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            }
        }
    }
}

// LedMainViewModel.kt
fun clickBtnExpand(canAction: () -> Unit) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        canAction()
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: Icon(_isLandscape ? Icons.fullscreen_exit : Icons.fullscreen),
  onPressed: featuresEnabled && !controller.isPreviewing
      ? _toggleOrientation
      : null,
)

void _toggleOrientation() {
  setState(() {
    _isLandscape = !_isLandscape;
  });
  if (_isLandscape) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則切換方向
- koralcore：通過 `!controller.isPreviewing` 禁用展開按鈕（當正在預覽時），但不停止預覽

**建議**：在點擊展開時，如果正在預覽，先停止預覽，然後切換方向。

---

#### 3. btnPreview (預覽)

**reef-b-app**:
```kotlin
binding.btnPreview.setOnClickListener {
    viewModel.clickBtnPreview()
}

// LedMainViewModel.kt
fun clickBtnPreview() {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        bleStartPreview()
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: Icon(controller.isPreviewing ? Icons.stop : Icons.play_arrow),
  onPressed: controller.isBusy ? null : controller.togglePreview,
)

// LedSceneListController.kt
Future<void> togglePreview() async {
  // ...
  if (_isRecordPreviewing) {
    await _stopPreview(deviceId);
    return;
  }
  // Start preview
  await startLedPreviewUseCase.execute(...);
}
```

**狀態**：✅ **已實現**（邏輯略有不同，但功能相同）

---

#### 4. btnContinueRecord (繼續 Record)

**reef-b-app**:
```kotlin
binding.btnContinueRecord?.setOnClickListener {
    viewModel.clickBtnContinueRecord()
}

// LedMainViewModel.kt
fun clickBtnContinueRecord() {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        _loadingLiveData.value = true
        bleStartRecord()
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.play_circle_outline),
  onPressed: controller.isBusy || controller.isPreviewing
      ? null
      : controller.startRecord,
)

// LedSceneListController.kt
Future<void> startRecord() async {
  // ...
  await _stopPreview(deviceId);  // 內部會停止預覽
  await _runAction(() async {
    await startLedRecordUseCase.execute(deviceId: deviceId);
  });
}
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則開始 Record
- koralcore：通過 `controller.isPreviewing` 禁用按鈕（當正在預覽時），但 `startRecord` 內部會停止預覽

**狀態**：✅ **已實現**（邏輯略有不同，但功能相同）

---

## 四、Scene Section 按鍵功能對照

| 按鍵 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnSceneMore (Scene 更多)** | ✅ `clickBtnSceneMore()` - 如果正在預覽，停止預覽；否則導航到 Scene 列表頁面 | ✅ `IconButton` - 導航到 `LedSceneListPage`，但無預覽檢查 | ⚠️ | **差異**：koralcore 沒有在點擊 Scene 更多時檢查並停止預覽 |
| **Favorite Scene Cards** | ✅ `onClickScene()` - 如果正在預覽，停止預覽；否則應用場景（預設或自訂） | ✅ `controller.applyScene()` - 應用場景，內部會停止預覽 | ✅ | **已實現** |

### 詳細對照

#### 1. btnSceneMore (Scene 更多)

**reef-b-app**:
```kotlin
binding.btnSceneMore?.setOnClickListener {
    viewModel.clickBtnSceneMore {
        val intent = Intent(this, LedSceneActivity::class.java)
        intent.putExtra("device_id", viewModel.getNowDevice().id)
        startActivity(intent)
    }
}

// LedMainViewModel.kt
fun clickBtnSceneMore(canAction: () -> Unit) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        canAction()
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  onPressed: featuresEnabled
      ? () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LedSceneListPage()),
          );
        }
      : null,
)
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則導航
- koralcore：直接導航，沒有檢查預覽狀態

**建議**：在點擊 Scene 更多時，如果正在預覽，先停止預覽，然後導航。

---

#### 2. Favorite Scene Cards

**reef-b-app**:
```kotlin
override fun onClickScene(data: Scene) {
    super.onClickScene(data)
    viewModel.clickAdapterScene(data)
}

// LedMainViewModel.kt
fun clickAdapterScene(data: Scene) {
    if (_previewStateLiveData.value == true) {
        bleStopPreview()
    } else {
        nowScene = data
        data.sceneId?.let {
            bleUsePresetScene(it)
        } ?: run {
            bleUseCustomScene(data)
        }
    }
}
```

**koralcore**:
```dart
ElevatedButton.icon(
  onPressed: isEnabled
      ? () => controller.applyScene(scene.id)
      : null,
  // ...
)

// LedSceneListController.kt
Future<void> applyScene(String sceneId) async {
  // ...
  await _stopPreview(deviceId);  // 內部會停止預覽
  await _runAction(() async {
    await applySceneUseCase.execute(deviceId: deviceId, sceneId: sceneId);
  });
}
```

**狀態**：✅ **已實現**（邏輯略有不同，但功能相同）

---

## 五、返回鍵功能對照

| 按鍵 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **返回鍵 (Back)** | ✅ `onBackPressedDispatcher` - 如果正在預覽，停止預覽；否則如果橫屏則切換為豎屏，否則 `finish()` | ✅ `Navigator.pop()` - 直接返回，無預覽檢查和橫屏處理 | ⚠️ | **差異**：koralcore 沒有處理返回鍵的預覽檢查和橫屏切換 |

### 詳細對照

**reef-b-app**:
```kotlin
onBackPressedDispatcher.addCallback(this) {
    viewModel.clickBtnBack {
        if (requestedOrientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        } else {
            finish()
        }
    }
}
```

**koralcore**:
```dart
// 使用默認的返回鍵行為（Navigator.pop()）
// 沒有特殊處理
```

**差異**：
- reef-b-app：如果正在預覽，先停止預覽；否則如果橫屏則切換為豎屏，否則 `finish()`
- koralcore：直接返回，沒有檢查預覽狀態和橫屏處理

**建議**：實現 `WillPopScope` 或使用 `PopScope` 來處理返回鍵，如果正在預覽則先停止預覽，如果橫屏則切換為豎屏，否則返回。

---

## 六、總結

### ✅ 已完全實現的按鍵

1. **btnPreview (預覽)** - 切換預覽狀態
2. **btnContinueRecord (繼續 Record)** - 開始 Record（內部會停止預覽）
3. **Favorite Scene Cards** - 應用場景（內部會停止預覽）

### ⚠️ 需要修復的按鍵（缺少預覽檢查）

1. **btnBack (返回)** - 需要在返回時檢查並停止預覽
2. **btnMenu (菜單)** - 需要在點擊菜單時檢查並停止預覽
3. **btnFavorite (收藏)** - 需要在點擊收藏時檢查並停止預覽
4. **btnBle (BLE 連接狀態)** - 需要在點擊 BLE 時檢查並停止預覽
5. **btnRecordMore (Record 更多)** - 需要在點擊 Record 更多時檢查並停止預覽
6. **btnExpand (展開/橫屏切換)** - 需要在點擊展開時檢查並停止預覽
7. **btnSceneMore (Scene 更多)** - 需要在點擊 Scene 更多時檢查並停止預覽
8. **返回鍵 (Back)** - 需要處理返回鍵的預覽檢查和橫屏切換

### 修復建議

所有需要修復的按鍵都遵循相同的模式：
1. 如果正在預覽（`controller.isPreviewing == true`），先停止預覽（`controller.togglePreview()` 或 `controller._stopPreview()`）
2. 然後執行原本的操作

**實現方式**：
```dart
onPressed: () async {
  if (controller.isPreviewing) {
    await controller.togglePreview();  // 停止預覽
  }
  // 執行原本的操作
  // ...
}
```

**注意**：對於返回鍵，還需要處理橫屏切換邏輯。

---

## 七、實現優先級

### 高優先級（影響用戶體驗）

1. **返回鍵 (Back)** - 用戶經常使用返回鍵，需要正確處理預覽狀態和橫屏切換
2. **btnBle (BLE 連接狀態)** - 用戶可能需要在預覽時切換連接狀態
3. **btnPreview (預覽)** - 已實現，但需要確保邏輯完全一致

### 中優先級（影響功能完整性）

4. **btnMenu (菜單)** - 用戶可能需要在預覽時訪問菜單
5. **btnRecordMore (Record 更多)** - 用戶可能需要在預覽時查看 Record
6. **btnSceneMore (Scene 更多)** - 用戶可能需要在預覽時查看 Scene

### 低優先級（影響較小）

7. **btnBack (返回)** - 與返回鍵功能重複
8. **btnFavorite (收藏)** - 收藏功能不依賴預覽狀態
9. **btnExpand (展開/橫屏切換)** - 展開功能不依賴預覽狀態

