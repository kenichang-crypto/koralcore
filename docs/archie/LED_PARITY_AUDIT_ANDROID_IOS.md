# LED 模組對照表：koralcore vs reef-b-app（Android + iOS）

本文件針對 koralcore LED 模組與 reef-b-app 雙平台逐一對照，避免單一平台誤判。

---

## 一、主頁 (LedMain / LEDViewController)

| 功能 | reef-b-app Android | reef-b-app iOS | koralcore | 狀態 | 備註 |
|------|-------------------|----------------|-----------|------|------|
| Record 區域 | layout_record + rv | scheduleContainerView + lineChart | LedMainRecordChartSection | ✅ | |
| Record 更多按鈕 | btn_record_more | (無獨立按鈕，schedule 區塊點擊) | IconButton (more) | ✅ | iOS 為整塊 schedule 點擊 |
| Record 更多邏輯 | 預覽中→停止預覽<br>否則 空→Setting<br>有→Record | details.isEmpty→Init<br>否則→Detail | hasRecords→Record<br>否→Setting | ⚠️ | **差1**：KC 缺「預覽中先停止」 |
| 預覽按鈕 | btn_preview, 無 record 檢查 | previewButton | togglePreview | ✅ | 已修正：無 record 也可預覽 |
| 繼續記錄 | btn_continue_record | resumeScheduleButton | startRecord | ✅ | |
| 場景區 | rv_favorite_scene | sceneCollectionView | _FavoriteSceneArea | ✅ | 已修正：最愛可點擊套用 |
| 場景更多 | btn_scene_more→LedSceneActivity | sceneListButton→SceneList | onMore→LedSceneListPage | ✅ | |
| BLE 圖示 | btn_ble 可點擊 | disconnectButton | _DeviceIdentificationSection | ⚠️ | KC 僅顯示狀態，未綁定點擊 |

---

## 二、Record / Schedule 流程對照

| 項目 | reef-b-app Android | reef-b-app iOS | koralcore |
|------|-------------------|----------------|-----------|
| 空→設定頁 | LedRecordSettingActivity | showInitLEDScheduleDetail | LedRecordSettingPage |
| 有→列表/詳情 | LedRecordActivity | LEDScheduleDetailViewController | LedRecordPage |
| 術語 | Record | Schedule (led_schedule) | Record |
| 儲存 | BLE only, 不本地存 | BLE only, 不本地存 | BLE only, 不本地存 |

**注意**：reef-b-app 的 LED Schedule = 每日程式（time points），等同 koralcore 的 Record。koralcore 另有 LedScheduleListPage（daily/custom/scene-based）為擴展設計。

---

## 三、排程儲存

| 項目 | reef-b-app Android | reef-b-app iOS | koralcore |
|------|-------------------|----------------|-----------|
| 本地 DB 儲存 | ❌ 無 | ❌ 無 | ❌ 無 |
| 資料來源 | LedInformation (BLE) | LedDevice.details (BLE) | LedState.schedules (BLE) |
| SaveLedScheduleUseCase | N/A | N/A | unavailable() ✅ |

---

## 四、場景 (Scene)

| 功能 | reef-b-app Android | reef-b-app iOS | koralcore | 狀態 |
|------|-------------------|----------------|-----------|------|
| 場景列表 | LedSceneActivity | SceneDetailViewController | LedSceneListPage | ✅ |
| 新增場景 | LedSceneAddActivity | SceneAddViewController | LedSceneAddPage | ✅ |
| 刪除場景 | LedSceneDeleteActivity | SceneDeleteViewController | LedSceneDeletePage | ✅ |
| 編輯場景 | LedSceneEditActivity | SceneEditorViewController | LedSceneEditPage | ✅ |
| 最愛 | DeviceFavoriteSceneDao | dbManager.fetchAllScene favorite | FavoriteRepositoryImpl | ✅ |
| 主頁最愛可點擊 | FavoriteSceneAdapter.setEnabled | SceneCellViewModel 點擊 apply | LedMainFavoriteSceneCard | ✅ |

---

## 五、待修正差異清單

| # | 差異 | reef-b-app 行為 | koralcore 現狀 | 修正動作 |
|---|------|-----------------|----------------|----------|
| 1 | ~~Record 更多按鈕~~ | 預覽中點擊→僅停止預覽，不導航 | ~~直接導航~~ | ✅ **已修正** |
| 2 | 展開按鈕位置 | layout_record 內 | RecordChartSection 內 | 低優先，UI 位置差異 |
| 3 | BLE 圖示點擊 | 可連接/斷開 | _DeviceIdentificationSection 無 onTap | 可改用 LedMainDeviceInfoSection（有 _handleBleIconTap） |

---

## 六、已修正項目（本次會話）

| 項目 | 修正內容 |
|------|----------|
| 主頁場景可點擊 | _SceneList→_FavoriteSceneArea，最愛場景可點擊套用 |
| 預覽無 record | togglePreview 傳 recordId: null 支援無 record 預覽 |
| 排程不本地儲存 | SaveLedScheduleUseCase.unavailable() |
| Record 更多按鈕 | 預覽中先 stopPreview 不導航（reef-b-app clickBtnRecordMore 對照） |

---

## 七、Quick Schedule 對照（reef-b-app 確有此功能）

| 項目 | reef-b-app Android | reef-b-app iOS | koralcore |
|------|-------------------|----------------|-----------|
| Quick Schedule 頁 | LedRecordSettingActivity | LedRecordSettingViewController | LedRecordSettingPage |
| 入口 1：無排程 | isRecordEmpty → LedRecordSetting | details.isEmpty → LedRecordSetting | hasRecords=false → LedRecordSetting ✅ |
| 入口 2：清除按鈕 | LedRecord btnIcon → 確認 → clearRecord → 成功 → LedRecordSetting | LEDScheduleDetail resetBarButtonItem → 確認 → clearLEDSchedules → 成功 → LedRecordSetting | **缺**：LedRecordPage 無清除按鈕 ❌ |

詳見 `LED_QUICK_SCHEDULE_PARITY_ANALYSIS.md`。

---

## 八、頁面對照總表

| reef-b-app Android | reef-b-app iOS | koralcore |
|-------------------|----------------|-----------|
| LedMainActivity | LEDViewController | LedMainPage |
| LedRecordActivity | LEDScheduleDetailViewController | LedRecordPage |
| LedRecordSettingActivity | (Init flow) | LedRecordSettingPage |
| LedRecordTimeSettingActivity | LEDScheduleTimeSetting | LedRecordTimeSettingPage |
| LedSceneActivity | SceneDetailViewController | LedSceneListPage |
| LedSceneAddActivity | SceneAddViewController | LedSceneAddPage |
| LedSceneEditActivity | SceneEditorViewController | LedSceneEditPage |
| LedSceneDeleteActivity | SceneDeleteViewController | LedSceneDeletePage |
| LedSettingActivity | (設定整合) | LedSettingPage |
| LedMasterSettingActivity | LEDMasterSlaveSetting | LedMasterSettingPage |
| - | - | LedScheduleListPage (KC 擴展) |
| - | - | LedScheduleEditPage (KC 擴展) |
| - | - | LedControlPage (KC 擴展) |
