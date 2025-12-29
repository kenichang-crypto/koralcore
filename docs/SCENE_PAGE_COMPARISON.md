# 場景頁面完整對照表

## 一、預設場景對照

### 1.1 預設場景來源

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **預設場景來源** | 本地數據庫（通過`getPresetScene`初始化） | BLE設備狀態（通過`SceneCatalog`定義） | ⚠️ |
| **預設場景列表** | 6個預設場景（0x00-0x05） | 6個預設場景（0x00-0x05） | ✅ |
| **預設場景存儲** | `Scene`表，`sceneId`不為null | BLE狀態中的`LedStateScene`，`presetCode`不為null | ⚠️ |
| **預設場景顯示** | 從數據庫查詢並顯示 | 從BLE狀態獲取並顯示 | ⚠️ |

### 1.2 預設場景列表

| Code | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 0x00 | `preset_scene_off` (icon: 5, ic_none) | `Lights Off` (iconKey: ic_none) | ✅ |
| 0x01 | `preset_scene_30` (icon: 5, ic_none) | `30% Intensity` (iconKey: ic_none) | ✅ |
| 0x02 | `preset_scene_60` (icon: 5, ic_none) | `60% Intensity` (iconKey: ic_none) | ✅ |
| 0x03 | `preset_scene_100` (icon: 5, ic_none) | `100% Intensity` (iconKey: ic_none) | ✅ |
| 0x04 | `preset_scene_moon` (icon: 6, ic_moon) | `Moonlight` (iconKey: ic_moon) | ✅ |
| 0x05 | `preset_scene_thunder` (icon: 0, ic_thunder, isDynamic: true) | `Thunderstorm` (iconKey: ic_thunder, isDynamic: true) | ✅ |

### 1.3 預設場景操作

| 操作 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **播放預設場景** | `clickSceneBtnPlay()` → `bleUsePresetScene(code)` | `applyScene(sceneId)` → `applySceneUseCase` | ✅ |
| **編輯預設場景** | 預設場景不可編輯（`sceneId != null`時不顯示編輯按鈕） | 預設場景不可編輯（`isPreset == true`時不顯示編輯按鈕） | ✅ |
| **設定最愛** | 預設場景可以設定最愛（通過`DeviceFavoriteSceneDao`） | 需要確認預設場景是否可以設定最愛 | ⚠️ |

---

## 二、最愛場景對照

### 2.1 最愛場景存儲

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **存儲方式** | `device_favorite_scene`表（deviceId, sceneId） | `favorite_scenes`表（device_id, scene_id） | ✅ |
| **場景ID格式** | `scene.id` (Int) | `sceneId` (String, 格式: `preset_00` 或 `local_scene_1`) | ⚠️ |
| **預設場景最愛** | 支持（使用`scene.id`） | 需要確認（使用`sceneId`字符串） | ⚠️ |
| **自訂場景最愛** | 支持（使用`scene.id`） | 支持（使用`local_scene_${sceneId}`） | ✅ |

### 2.2 最愛場景設定

| 操作 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **觸發方式** | `onClickFavoriteScene()` → `viewModel.favoriteScene(data)` | `toggleFavoriteScene(sceneId)` | ✅ |
| **數據庫操作** | `dbDeviceFavoriteScene.insert/delete(deviceId, scene.id)` | `favoriteRepository.toggleFavoriteScene(deviceId, sceneId)` | ✅ |
| **刷新列表** | `getAllScene()` | `refresh()` | ✅ |
| **UI更新** | `favorite`字段更新（暫態值） | `isFavorite`字段更新 | ✅ |

### 2.3 LED主頁最愛場景顯示

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **數據來源** | `getAllFavoriteScene()` → `dbDeviceFavoriteScene.getFavoritesByDevice(deviceId)` | `controller.scenes.where((scene) => scene.isFavorite)` | ✅ |
| **顯示位置** | `rvFavoriteScene` (RecyclerView, 水平) | `_FavoriteSceneSection` (SingleChildScrollView, 水平) | ✅ |
| **卡片樣式** | `adapter_favorite_scene.xml` (MaterialButton) | `_FavoriteSceneCard` (ElevatedButton) | ✅ |
| **場景操作** | `onClickScene(data)` → `clickAdapterScene(data)` → `bleUsePresetScene/CustomScene` | `controller.applyScene(scene.id)` | ✅ |
| **當前場景高亮** | `setNowSceneId(id)` → 背景色變為`bg_primary` | `isActive` → 背景色變為`ReefColors.primary` | ✅ |

---

## 三、場景頁面圖標對照

### 3.1 播放按鈕圖標

| 狀態 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **未選中** | `ic_play_unselect` (XML vector drawable) | `assets/icons/ic_play_unselect.png` (fallback: `Icons.play_arrow_outlined`) | ⚠️ |
| **已選中** | `ic_play_select` (XML vector drawable) | `assets/icons/ic_play_select.png` (fallback: `Icons.play_arrow`) | ⚠️ |

### 3.2 最愛按鈕圖標

| 狀態 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **未選中** | `ic_favorite_unselect` (XML vector drawable) | `assets/icons/ic_favorite_unselect.png` (fallback: `Icons.favorite_border`) | ⚠️ |
| **已選中** | `ic_favorite_select` (XML vector drawable) | `assets/icons/ic_favorite_select.png` (fallback: `Icons.favorite`) | ⚠️ |

### 3.3 場景圖標

| Icon ID | reef-b-app | koralcore | 狀態 |
|---------|-----------|-----------|------|
| 0-10 | XML vector drawable | SVG (已轉換) | ✅ |

---

## 四、需要修復的問題

### 4.1 預設場景顯示

1. **預設場景來源差異** - reef-b-app從本地數據庫獲取，koralcore從BLE狀態獲取
   - **影響**：如果BLE未連接，koralcore無法顯示預設場景
   - **修復建議**：需要確認koralcore是否在BLE未連接時也能顯示預設場景（從`SceneCatalog`獲取）

### 4.2 最愛場景設定

1. **預設場景最愛設定** - 需要確認預設場景是否可以設定為最愛
   - **reef-b-app**：支持（使用`scene.id`）
   - **koralcore**：需要確認（使用`sceneId`字符串，格式為`preset_00`）

2. **場景ID格式差異** - reef-b-app使用`scene.id`（Int），koralcore使用`sceneId`（String）
   - **影響**：最愛場景的存儲和查詢可能不一致
   - **修復建議**：確保`FavoriteRepositoryImpl`正確處理預設場景的`sceneId`格式

### 4.3 圖標資源

1. **播放按鈕圖標** - 需要將`ic_play_select`和`ic_play_unselect`從XML轉換為SVG
2. **最愛按鈕圖標** - 需要將`ic_favorite_select`和`ic_favorite_unselect`從XML轉換為SVG

### 4.4 LED主頁最愛場景

1. **最愛場景數據獲取** - 需要確認是否正確獲取預設場景的最愛狀態
2. **最愛場景操作** - 需要確認預設場景是否可以從LED主頁操作

---

## 五、實現狀態評分

### 預設場景功能
- **功能實現**: 80% ⚠️
- **數據來源**: 60% ⚠️
- **操作流程**: 90% ✅

**總體評分**: **77%** ⚠️

### 最愛場景功能
- **功能實現**: 85% ⚠️
- **預設場景支持**: 70% ⚠️
- **LED主頁顯示**: 90% ✅

**總體評分**: **82%** ⚠️

### 圖標對照
- **場景圖標**: 100% ✅
- **播放按鈕**: 60% ⚠️
- **最愛按鈕**: 60% ⚠️

**總體評分**: **73%** ⚠️

