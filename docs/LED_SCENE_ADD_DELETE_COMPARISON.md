# LED 場景增加與刪除功能完整對照表

## 一、增加場景 (Add Scene) 功能對照

### 1.1 入口點

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **入口頁面** | `LedSceneActivity` (場景列表頁) | `LedSceneListPage` (場景列表頁) | ✅ |
| **觸發按鈕** | `btnAddScene` (FloatingActionButton) | 需要確認 | ⚠️ |
| **導航方式** | `startActivity(LedSceneAddActivity::class.java)` | `Navigator.push(LedSceneAddPage())` | ✅ |
| **前置檢查** | `viewModel.clickBtnAdd()` → 檢查場景數量是否 < 5 | `controller.isSceneLimitReached` | ✅ |

### 1.2 UI 界面對照

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **Activity/Page** | `LedSceneAddActivity` | `LedSceneAddPage` | ✅ |
| **Layout XML** | `activity_led_scene_add.xml` | `led_scene_add_page.dart` | ✅ |
| **Toolbar** | `toolbar_led_scene_add` (include `toolbar_two_action`) | `ReefAppBar` | ✅ |
| **Toolbar 標題** | `toolbar_title` → `@string/activity_led_scene_add_title` | `title: Text(l10n.ledSceneAddTitle)` | ✅ |
| **Toolbar 返回按鈕** | `btn_back` → `ic_close` | `leading: IconButton` → `Icons.close` | ✅ |
| **Toolbar 保存按鈕** | `btn_right` → `@string/save` | `FloatingActionButton.extended` → `l10n.actionSave` | ⚠️ (位置不同) |
| **場景名稱輸入** | `layout_name` → `edt_name` | `TextField` | ✅ |
| **場景名稱標題** | `tv_time_title` → `@string/led_scene_name` | `TextField.labelText` → `l10n.ledSceneNameLabel` | ✅ |
| **場景圖標選擇** | `rv_scene_icon` (RecyclerView) | `SceneIconPicker` | ✅ |
| **場景圖標標題** | `tv_scene_icon_title` → `@string/led_scene_icon` | `SceneIconPicker` 內部標題 | ✅ |
| **光譜圖表** | `chart_spectrum` (LineChart, 176dp, marginStart/End 22dp, marginTop 24dp) | `LedSpectrumChart` (72dp) | ⚠️ (高度和間距不同) |
| **通道滑塊** | `sl_uv_light`, `sl_purple_light`, etc. | `_buildChannelSliders()` | ✅ |
| **通道順序** | UV → Purple → Blue → Royal Blue → Green → Red → Cold White → Warm White (gone) → Moon | Cold White → Royal Blue → Blue → Red → Green → Purple → UV → Warm White → Moon | ⚠️ (順序不同) |
| **Warm White 通道** | `visibility="gone"` | 已過濾 | ✅ |
| **滑塊軌道顏色** | `trackColorActive` (各通道顏色) | `_getChannelColor()` | ✅ |
| **滑塊軌道高度** | `trackHeight="@dimen/dp_2"` | `trackHeight: 2.0` | ✅ |
| **滑塊自定義圖標** | `setCustomThumbDrawable(R.drawable.ic_xxx_light_thumb)` | `thumbColor: activeColor` | ✅ (顏色對照) |
| **Loading 指示器** | `progress` (full screen overlay) | `CircularProgressIndicator` (在 ListView 中) | ⚠️ (位置不同) |
| **組件間距** | ConstraintLayout (marginTop: 12dp, 24dp, 16dp 等) | `SizedBox(height: ReefSpacing.md)` | ⚠️ (需要對照) |

### 1.3 業務邏輯對照

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **ViewModel/Controller** | `LedSceneAddViewModel` | `LedSceneEditController` (共用) | ✅ |
| **進入調光模式** | `init { bleDimming() }` | `initState { enterDimmingMode() }` | ✅ |
| **退出調光模式** | `clickBtnBack()` → `bleExitDimmingMode()` | `dispose()` → `exitDimmingMode()` | ✅ |
| **場景名稱設置** | `setName(name)` | `setName(name)` | ✅ |
| **通道強度設置** | `setSlXxxLight(value)` → `bleDimming()` | `setChannelLevel(id, value)` → `_sendDimmingCommand()` | ✅ |
| **場景圖標設置** | `iconAdapter.getNowSelect()` | `setIconId(value)` | ✅ |
| **保存場景** | `addScene(iconId, nameIsEmpty)` | `saveScene()` | ✅ |
| **數據庫操作** | `dbAddScene(scene)` → `dbScene.insertScene(scene)` | `addSceneUseCase.execute()` → `sceneRepository.addScene()` | ✅ |
| **場景數量限制** | 檢查 `dbScene.getAllScene().size < 5` | 檢查 `sceneCount < 5` | ✅ |
| **成功回調** | `addSceneLiveData.value = true` → `toast_add_scene_successful` | `Navigator.pop(true)` → `SnackBar(l10n.ledSceneAddSuccess)` | ✅ |
| **失敗回調** | `addSceneLiveData.value = false` → `toast_scene_name_is_exist` | `SnackBar(describeAppError(...))` | ✅ |
| **名稱為空處理** | `nameIsEmpty()` → `toast_name_is_empty` | UI 層檢查 → `l10n.toastNameIsEmpty` | ✅ |
| **BLE 斷開處理** | `disconnectLiveData.observe()` → `finish()` | `didChangeDependencies` 監聽 `session.isBleConnected` | ✅ |

### 1.4 用戶流程對照

#### reef-b-app 流程：
1. 用戶在 `LedSceneActivity` 點擊 `btnAddScene` (FloatingActionButton)
2. `viewModel.clickBtnAdd()` 檢查場景數量 (`scenes.count { it.sceneId == null } < 5`)
3. 如果 < 5，導航到 `LedSceneAddActivity`
4. `LedSceneAddViewModel.init` 自動調用 `bleDimming()` 進入調光模式（通過 `bleEnterDimmingMode()`）
5. 用戶設置場景名稱、圖標、通道強度
6. 滑塊變更時，實時調用 `bleDimming()` 發送調光命令
7. 點擊 `btn_right` (保存) → `viewModel.addScene(iconId, nameIsEmpty)`
8. 檢查名稱是否為空，如果為空顯示 `toast_name_is_empty`
9. 調用 `dbAddScene()` → `dbScene.insertScene(scene)` 保存場景
10. 如果成功 (`id != -1L`)，顯示 `toast_add_scene_successful` 並調用 `clickBtnBack()` 關閉頁面
11. 如果失敗 (`id == -1L`)，顯示 `toast_scene_name_is_exist`
12. 點擊返回或 BLE 斷開時，調用 `bleExitDimmingMode()` 退出調光模式

#### koralcore 流程：
1. 用戶在 `LedSceneListPage` 點擊 `FloatingActionButton` (添加按鈕)
2. 檢查 `controller.isSceneLimitReached` (在 UI 層)
3. 如果未達上限，導航到 `LedSceneAddPage`
4. `initState` 自動調用 `controller.enterDimmingMode()` 進入調光模式
5. 用戶設置場景名稱、圖標、通道強度
6. 滑塊變更時，實時調用 `_sendDimmingCommand()` 發送調光命令
7. 點擊 `FloatingActionButton` (保存) → `controller.saveScene()`
8. UI 層檢查名稱是否為空，如果為空顯示 `l10n.toastNameIsEmpty`
9. 調用 `addSceneUseCase.execute()` → `sceneRepository.addScene()` 保存場景
10. 如果成功，顯示 `l10n.ledSceneAddSuccess` 並關閉頁面
11. 如果失敗，顯示錯誤信息
12. `dispose()` 時自動調用 `exitDimmingMode()` 退出調光模式

**狀態**: ⚠️ **基本對照，但 UI 布局、按鈕位置和通道順序有差異**

---

## 二、刪除場景 (Delete Scene) 功能對照

### 2.1 入口點

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **入口頁面** | `LedSceneActivity` (場景列表頁) | `LedSceneListPage` (場景列表頁) | ✅ |
| **觸發按鈕** | `btnEdit` (Toolbar) | `IconButton(icon: Icons.edit)` | ✅ |
| **導航方式** | `startActivity(LedSceneDeleteActivity::class.java)` | `Navigator.push(LedSceneDeletePage())` | ✅ |

### 2.2 UI 界面對照

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **Activity/Page** | `LedSceneDeleteActivity` | `LedSceneDeletePage` | ✅ |
| **Layout XML** | `activity_led_scene_delete.xml` | `led_scene_delete_page.dart` | ✅ |
| **Toolbar** | `toolbar_led_record_scene_delete` (include `toolbar_two_action`) | `ReefAppBar` | ✅ |
| **Toolbar 標題** | `toolbar_title` → `@string/activity_led_scene_delete_title` | `title: Text(l10n.ledSceneDeleteTitle)` | ✅ |
| **Toolbar 返回按鈕** | `btn_back` → `ic_back` | `leading: IconButton` → `Icons.arrow_back` | ✅ |
| **場景列表** | `rv_scene` (RecyclerView, 垂直) | `ListView` | ✅ |
| **列表項布局** | `adapter_scene_select.xml` | `_SceneDeleteCard` | ✅ |
| **列表項結構** | MaterialCardView (bg_aaa, cornerRadius 8dp, elevation 0dp) | `Card` (surfaceMuted, cornerRadius sm, elevation 0) | ✅ |
| **列表項內邊距** | paddingStart 8dp, paddingTop 6dp, paddingEnd 12dp, paddingBottom 6dp | `padding: 8/6/12/6` | ✅ |
| **場景圖標** | `img_icon` (24×24dp) | `Icon` (size: 24) | ✅ |
| **場景名稱** | `tv_name` (body, text_aaaa, marginStart 8dp) | `Text` (body, textPrimary, marginStart 8dp) | ✅ |
| **選擇標記** | `img_check` (20×20dp, visibility gone) | `IconButton` (delete icon, 20×20dp) | ⚠️ (功能不同) |
| **觸發刪除** | `onLongClickScene()` (長按) | `onTap()` 或 `IconButton.onPressed()` (點擊) | ⚠️ (交互方式不同) |
| **Loading 指示器** | `progress` (full screen overlay) | `CircularProgressIndicator` (在 ListView 中) | ⚠️ (位置不同) |
| **空狀態** | 無（列表為空時不顯示） | `Text(l10n.ledSceneDeleteEmpty)` | ✅ |

### 2.3 業務邏輯對照

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **ViewModel/Controller** | `LedSceneDeleteViewModel` | `LedSceneListController` + `DeleteSceneUseCase` | ✅ |
| **加載場景列表** | `getAllScene()` → `dbGetAllScene()` → `dbScene.getAllScene()` | `_loadLocalScenes(deviceId)` → `sceneRepository.getScenes(deviceId)` | ✅ |
| **過濾場景** | `scenes.filter { it.sceneId == null }` (只顯示自定義場景) | `sceneRepository.getScenes(deviceId)` (只查詢本地場景) | ✅ |
| **檢查當前場景** | `data == ledInformation.getNowScene()` | ❌ **缺失** - 需要檢查 `sceneIdString == controller.activeSceneId` | ❌ |
| **獲取當前場景** | `ledInformation.getNowScene()` → `Scene` | `controller.activeSceneId` → `String?` (格式: `local_scene_${sceneId}`) | ⚠️ |
| **刪除場景** | `deleteScene(data, deleteNowScene)` | `deleteSceneUseCase.execute(deviceId, sceneId)` | ✅ |
| **刪除確認對話框** | `createDeleteLedDialog(data)` → `dialog_scene_delete_scene_content` | `AlertDialog` → `l10n.ledSceneDeleteConfirmMessage` | ✅ |
| **刪除成功** | `deleteSceneLiveData.value = true` → `toast_delete_scene_successful` | `SnackBar(l10n.ledSceneDeleteSuccess)` | ✅ |
| **刪除失敗** | `deleteSceneLiveData.value = false` → `toast_delete_scene_failed` | `SnackBar(l10n.ledSceneDeleteError)` | ✅ |
| **不能刪除當前場景** | `deleteNowScene()` → `toast_delete_now_scene` | ❌ **缺失** - 需要添加檢查和提示 | ❌ |
| **刷新列表** | `getAllScene()` (自動刷新) | `controller.refresh()` (手動刷新) | ✅ |
| **BLE 斷開處理** | `disconnectLiveData.observe()` → `finish()` | ❌ **缺失** - 需要監聽 `session.isBleConnected` | ❌ |
| **場景圖標顯示** | `getSceneIconById(data.icon)` → `ImageView.setImageResource()` | `Icons.light_mode` (臨時) | ⚠️ |
| **場景圖標映射** | 見下方詳細表格 | `SceneIconPicker._getIconForId()` (Material Icons) | ⚠️ (映射不一致) |

### 2.4 用戶流程對照

#### reef-b-app 流程：
1. 用戶在 `LedSceneActivity` 點擊 `btnEdit`
2. 導航到 `LedSceneDeleteActivity`
3. `LedSceneDeleteViewModel.init` 調用 `getAllScene()` 加載場景列表
4. `sceneListLiveData.observe()` 更新 UI，只顯示 `sceneId == null` 的自定義場景
5. 用戶長按場景項 → `onLongClickScene(data)`
6. 顯示確認對話框 `createDeleteLedDialog(data)`
7. 用戶確認刪除 → `viewModel.deleteScene(data, deleteNowScene)`
8. 檢查 `data == ledInformation.getNowScene()`，如果是當前場景，顯示 `toast_delete_now_scene` 並返回
9. 調用 `dbDeleteDeviceById(data.id)` 刪除場景
10. 調用 `getAllScene()` 刷新列表
11. 顯示 `toast_delete_scene_successful` 或 `toast_delete_scene_failed`
12. BLE 斷開時自動關閉頁面

#### koralcore 流程：
1. 用戶在 `LedSceneListPage` 點擊 `IconButton(icon: Icons.edit)`
2. 導航到 `LedSceneDeletePage`
3. `FutureBuilder` 調用 `_loadLocalScenes(deviceId)` 加載場景列表
4. 顯示本地場景列表（從 `SceneRepositoryImpl` 查詢）
5. 用戶點擊場景項或刪除按鈕 → `_confirmDelete(context, l10n)`
6. 顯示確認對話框 `AlertDialog`
7. 用戶確認刪除 → `deleteSceneUseCase.execute(deviceId, sceneId)`
8. ❌ **缺失**：未檢查是否為當前使用的場景（需要檢查 `sceneIdString == controller.activeSceneId`）
9. 調用 `sceneRepository.deleteScene()` 刪除場景
10. 調用 `controller.refresh()` 刷新列表
11. 顯示 `l10n.ledSceneDeleteSuccess` 或 `l10n.ledSceneDeleteError`
12. ❌ **缺失**：BLE 斷開時未自動關閉頁面（需要監聽 `session.isBleConnected`）

**狀態**: ⚠️ **基本對照，但缺少當前場景檢查和 BLE 斷開處理**

### 2.5 場景圖標映射對照

| Icon ID | reef-b-app (drawable) | koralcore (Material Icon) | 狀態 |
|---------|----------------------|--------------------------|------|
| 0 | `ic_thunder` | `Icons.flash_on` | ✅ |
| 1 | `ic_cloudy` | `Icons.wb_cloudy` | ✅ |
| 2 | `ic_sunny` | `Icons.wb_sunny` | ✅ |
| 3 | `ic_rainy` | `Icons.water_drop` | ⚠️ (需要確認) |
| 4 | `ic_dizzle` | `Icons.nightlight` | ⚠️ (需要確認) |
| 5 | `ic_none` | `Icons.circle_outlined` | ✅ |
| 6 | `ic_moon` | `Icons.palette` | ❌ (應該是 `Icons.nightlight` 或 `Icons.dark_mode`) |
| 7 | `ic_sunrise` | `Icons.color_lens` | ❌ (應該是 `Icons.wb_twilight` 或 `Icons.wb_sunny`) |
| 8 | `ic_sunset` | `Icons.auto_awesome` | ❌ (應該是 `Icons.wb_twilight` 或 `Icons.wb_sunny`) |
| 9 | `ic_mist` | `Icons.star` | ❌ (應該是 `Icons.cloud` 或 `Icons.foggy`) |
| 10 | `ic_light_off` | `Icons.favorite` | ❌ (應該是 `Icons.lightbulb_outline` 或 `Icons.power_off`) |

**說明**: `koralcore` 的 `SceneIconPicker` 目前使用 Material Icons 作為臨時方案，需要對照 `reef-b-app` 的實際圖標資源進行修正。

---

## 三、關鍵差異總結

### 3.1 增加場景功能差異

| 差異項目 | reef-b-app | koralcore | 優先級 |
|---------|-----------|-----------|--------|
| **保存按鈕位置** | Toolbar `btn_right` | `FloatingActionButton` | **高** |
| **光譜圖表高度** | 176dp | 72dp | **高** |
| **光譜圖表間距** | marginStart/End 22dp, marginTop 24dp | 需要確認 | **高** |
| **通道順序** | UV → Purple → Blue → Royal Blue → Green → Red → Cold White → Moon | Cold White → Royal Blue → Blue → Red → Green → Purple → UV → Warm White → Moon | **高** |
| **Loading 位置** | Full screen overlay | ListView 內部 | 中 |
| **組件間距** | ConstraintLayout (精確間距) | `SizedBox` (通用間距) | **高** |
| **場景數量顯示** | 無 | `_SceneCountIndicator` (額外功能) | 低 |
| **調光模式指示** | 無 | Toolbar 顯示 "Dimming Mode" (額外功能) | 低 |
| **場景名稱標題** | `tv_time_title` (顯示標題) | `TextField.labelText` (標籤) | 中 |

### 3.2 刪除場景功能差異

| 差異項目 | reef-b-app | koralcore | 優先級 |
|---------|-----------|-----------|--------|
| **觸發方式** | 長按場景項 (`onLongClickScene`) | 點擊場景項或刪除按鈕 (`IconButton`) | 中 |
| **當前場景檢查** | ✅ 檢查 `data == ledInformation.getNowScene()` | ❌ **缺失** - 需要檢查 `sceneIdString == controller.activeSceneId` | **高** |
| **不能刪除提示** | ✅ `toast_delete_now_scene` ("Cannot delete the currently in-use scene.") | ❌ **缺失** - 需要添加 `l10n.toastDeleteNowScene` | **高** |
| **BLE 斷開處理** | ✅ `disconnectLiveData.observe()` → `finish()` | ❌ **缺失** - 需要監聽 `session.isBleConnected` | **高** |
| **場景圖標顯示** | `getSceneIconById(data.icon)` → `ImageView.setImageResource()` | `Icons.light_mode` (臨時) | **高** |
| **場景圖標資源** | `ic_sunrise`, `ic_sunset`, etc. (根據 `icon` ID) | 需要實現 `getSceneIconById()` 對應邏輯 | **高** |
| **設備場景顯示** | 無（只顯示自定義場景，`sceneId == null`） | 顯示設備場景（只讀） | 低 |
| **列表項布局** | `adapter_scene_select.xml` (MaterialCardView) | `_SceneDeleteCard` (Card) | ✅ |

---

## 四、需要修復的問題

### 4.1 增加場景功能

1. **保存按鈕位置** - 需要將 `FloatingActionButton` 改為 Toolbar 的 `actions` 按鈕，對照 `reef-b-app` 的 `btn_right`
2. **光譜圖表高度** - 需要將高度從 72dp 改為 176dp，對照 `activity_led_scene_add.xml`
3. **光譜圖表間距** - 需要設置 marginStart/End 22dp, marginTop 24dp
4. **通道順序** - 需要調整為：UV → Purple → Blue → Royal Blue → Green → Red → Cold White → Moon（移除 Warm White）
5. **Loading 位置** - 需要改為 full screen overlay，對照 `progress.xml`
6. **組件間距** - 需要對照 `activity_led_scene_add.xml` 的 ConstraintLayout 間距：
   - 場景名稱標題：marginStart/End 16dp, marginTop 12dp
   - 場景名稱輸入：marginTop 4dp
   - 場景圖標標題：marginTop 24dp
   - 場景圖標列表：marginTop 4dp
   - 光譜圖表：marginStart/End 22dp, marginTop 24dp
   - 第一個通道標題：marginStart 6dp, marginTop 24dp
7. **場景名稱標題** - 需要添加 `tv_time_title` 對應的標題顯示（在 `TextField` 上方）

### 4.2 刪除場景功能

1. **當前場景檢查** - 需要檢查場景是否為當前使用的場景：
   - 獲取 `LedSceneListController.activeSceneId`
   - 比較 `sceneIdString == controller.activeSceneId`
   - 如果匹配，則不能刪除
2. **不能刪除提示** - 需要添加 `toast_delete_now_scene` 的對應提示：
   - 在 ARB 文件中添加 `toastDeleteNowScene: "Cannot delete the currently in-use scene."`
   - 在刪除前檢查並顯示此提示
3. **BLE 斷開處理** - 需要監聽 `session.isBleConnected` 變化，斷開時自動關閉頁面：
   - 在 `didChangeDependencies` 中監聽 `session.isBleConnected`
   - 當從 `true` 變為 `false` 時，調用 `Navigator.pop()`
4. **場景圖標顯示** - 需要使用實際場景圖標：
   - 實現 `getSceneIconById(int iconId)` 對應邏輯
   - 對照 `reef-b-app` 的圖標映射：
     - 0: `ic_thunder` → `Icons.flash_on` ✅
     - 1: `ic_cloudy` → `Icons.wb_cloudy` ✅
     - 2: `ic_sunny` → `Icons.wb_sunny` ✅
     - 3: `ic_rainy` → `Icons.water_drop` ⚠️ (需要確認)
     - 4: `ic_dizzle` → `Icons.nightlight` ⚠️ (需要確認)
     - 5: `ic_none` → `Icons.circle_outlined` ✅
     - 6: `ic_moon` → `Icons.palette` ❌ (應該是 `Icons.nightlight` 或 `Icons.dark_mode`)
     - 7: `ic_sunrise` → `Icons.color_lens` ❌ (應該是 `Icons.wb_twilight` 或 `Icons.wb_sunny`)
     - 8: `ic_sunset` → `Icons.auto_awesome` ❌ (應該是 `Icons.wb_twilight` 或 `Icons.wb_sunny`)
     - 9: `ic_mist` → `Icons.star` ❌ (應該是 `Icons.cloud` 或 `Icons.foggy`)
     - 10: `ic_light_off` → `Icons.favorite` ❌ (應該是 `Icons.lightbulb_outline` 或 `Icons.power_off`)
5. **觸發方式** - 可以保留點擊方式，但需要確認是否符合 UX 要求（reef-b-app 使用長按）

---

## 五、實現狀態評分

### 增加場景功能
- **功能實現**: 90% ✅
- **UI 對照**: 70% ⚠️
- **布局對照**: 60% ⚠️
- **文字對照**: 100% ✅

**總體評分**: **80%** ⚠️

### 刪除場景功能
- **功能實現**: 80% ⚠️
- **UI 對照**: 85% ✅
- **業務邏輯**: 70% ⚠️
- **文字對照**: 100% ✅

**總體評分**: **84%** ⚠️

---

## 六、修復優先級

### 高優先級（功能相關）

1. **刪除場景 - 當前場景檢查** - 確保不能刪除當前使用的場景
2. **刪除場景 - 不能刪除提示** - 添加對應的錯誤提示
3. **刪除場景 - BLE 斷開處理** - 確保 BLE 斷開時正確關閉頁面

### 中優先級（UI 對照）

4. **增加場景 - 保存按鈕位置** - 改為 Toolbar 按鈕
5. **增加場景 - 光譜圖表高度** - 改為 176dp
6. **增加場景 - Loading 位置** - 改為 full screen overlay
7. **刪除場景 - 場景圖標顯示** - 使用實際場景圖標

### 低優先級（細節優化）

8. **增加場景 - 組件間距** - 對照 ConstraintLayout 間距
9. **刪除場景 - 觸發方式** - 確認是否需要改為長按

