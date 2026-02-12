# LED 模組行為分析報告：koralcore vs reef-b-app

本報告針對 koralcore 專案中 LED 模組的 9 項功能逐一對照 reef-b-app 的 UI/UX 基準，進行靜態分析。**僅做靜態分析，不修改程式碼。**

---

## 1. 一分鐘快速預覽 (Quick Preview)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI 入口** | ✅ 存在 | Record/Chart 區塊有預覽按鈕 |
| **Controller 方法** | ✅ 存在 | `LedSceneListController.togglePreview()` |
| **UseCase** | ✅ 存在 | `StartLedPreviewUseCase`、`StopLedPreviewUseCase` |
| **Store/State** | ✅ 存在 | `LedRecordState.status == previewing`、`previewingRecordId`、`_isRecordPreviewing` |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| UI 入口 | `lib/features/led/presentation/widgets/led_main_record_chart_section.dart` |
| Controller | `lib/features/led/presentation/controllers/led_scene_list_controller.dart` (L234-273) |
| UseCase | `lib/domain/usecases/led/start_led_preview_usecase.dart`、`stop_led_preview_usecase.dart` |
| Repository | `lib/platform/contracts/led_record_repository.dart`（`startPreview`/`stopPreview`） |
| State | `lib/domain/led_lighting/led_record_state.dart`（`LedRecordStatus.previewing`） |

### C. 是否可實際使用

**Yes** — 已修正：無 record 時傳 `recordId: null` 發送 BLE 指令（reef-b-app 無 record 檢查）

### D. 差異與修正建議

| 差異 | 說明 | 建議 |
|------|------|------|
| ~~record 為空時無預覽~~ | ~~reef-b-app 無 record 檢查~~ | ✅ **已修正** |
| 預覽時長 | reef-b-app L10n 為 "One-minute quick preview"；koralcore 以 BLE 0x2A 驅動，時長由韌體決定 | 無需修改，行為由韌體控制 |

---

## 2. 場景列表 (Scene List)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI** | ✅ 存在 | 場景列表頁、主頁場景區塊 |
| **Controller** | ✅ 存在 | `LedSceneListController` |
| **UseCase** | ✅ 存在 | `ReadLedScenesUseCase` |
| **Store/State** | ✅ 存在 | `controller.scenes`、`dynamicScenes`、`staticScenes` |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| 場景列表頁 | `lib/features/led/presentation/pages/led_scene_list_page.dart` |
| 主頁場景區 | `lib/features/led/presentation/pages/led_main_page.dart`（`_FavoriteSceneArea`） |
| Controller | `lib/features/led/presentation/controllers/led_scene_list_controller.dart` |
| UseCase | `lib/domain/usecases/led/read_led_scenes.dart` |

### C. 是否可實際使用

**Yes**

### D. 差異與修正建議

| 差異 | 說明 | 建議 |
|------|------|------|
| ~~主頁場景不可點擊~~ | 已改採 `_FavoriteSceneArea` | ✅ **已修正** |

---

## 3. 新增場景 (Scene Create)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI 新增按鈕** | ✅ 存在 | LedSceneListPage FAB、靜態場景區的「新增」按鈕 |
| **Controller** | ✅ 存在 | `LedSceneEditController`（新增/編輯共用） |
| **UseCase** | ✅ 存在 | `AddSceneUseCase` |
| **輸入名稱/選擇燈/確認** | ✅ 存在 | 名稱 TextField、SceneIconPicker、通道滑塊、儲存 FAB |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| 新增頁 | `lib/features/led/presentation/pages/led_scene_add_page.dart` |
| Controller | `lib/features/led/presentation/controllers/led_scene_edit_controller.dart` |
| UseCase | `lib/domain/usecases/led/add_scene_usecase.dart` |

### C. 是否可實際使用

**Yes**

### D. 差異與修正建議

- 與 reef-b-app 對照：場景數量上限 5、名稱為空檢查、進入/退出調光模式、BLE 斷開處理均已對齊。
- 通道順序、光譜圖表高度/間距有 minor 差異，不影響功能。

---

## 4. 刪除場景 (Scene Delete)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI 刪除入口** | ✅ 存在 | LedSceneListPage Toolbar 的 Edit 按鈕 → LedSceneDeletePage |
| **UseCase** | ✅ 存在 | `DeleteSceneUseCase` |
| **選取/多選** | ✅ 存在 | `_selectedIds`，支援多選刪除 |
| **刪除後更新列表** | ✅ 存在 | `Navigator.pop(result: true)` 觸發 refresh |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| 刪除頁 | `lib/features/led/presentation/pages/led_scene_delete_page.dart` |
| UseCase | `lib/domain/usecases/led/delete_scene_usecase.dart` |
| 入口 | `lib/features/led/presentation/pages/led_scene_list_page.dart` |

### C. 是否可實際使用

**Yes**

### D. 差異與修正建議

- 與 reef-b-app 對照：刪除邏輯已實作。reef-b-app 使用長按觸發刪除，koralcore 以點擊/選取模式實作，為 UX 差異，功能等同。

---

## 5. 最愛 (Favorites)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **加入/取消最愛按鈕** | ✅ 存在 | LedSceneListPage 的 `_SceneCard` 內 favorite 圖示按鈕 |
| **Controller 方法** | ✅ 存在 | `LedSceneListController.toggleFavoriteScene(sceneId)` |
| **Store/State** | ✅ 存在 | `FavoriteRepositoryImpl.toggleFavoriteScene`、`LedSceneSummary.isFavorite` |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| UI | `lib/features/led/presentation/pages/led_scene_list_page.dart` (L550 等) |
| Controller | `lib/features/led/presentation/controllers/led_scene_list_controller.dart` (L368) |
| Repository | `lib/data/repositories/favorite_repository_impl.dart` |

### C. 是否可實際使用

**Yes**

### D. 差異與修正建議

- 主頁 `LedMainPage` 未顯示最愛區塊（`LedMainFavoriteSceneSection` 雖存在但未使用），僅場景列表頁有最愛功能。
- 若 reef-b-app 主頁有獨立最愛區塊，可將 `LedMainFavoriteSceneSection` 整合進 LedMainPage。

---

## 6. 快速排程設定 (Quick Schedule)

**定義**：Quick Schedule = LedRecordSetting，用於無排程時快速建立每日程式（init strength、日出、日落等）。

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **入口 1：無排程** | ✅ 存在 | LedMainRecordChartSection hasRecords=false → LedRecordSettingPage |
| **入口 2：清除按鈕** | ❌ 缺失 | reef-b-app LedRecord/LEDScheduleDetail 右上角有清除→Quick Schedule，koralcore LedRecordPage 無 |
| **Quick Schedule 頁** | ✅ 存在 | LedRecordSettingPage（結構有，邏輯需接） |

### B. 對應檔案

| 類型 | reef-b-app | koralcore |
|------|------------|-----------|
| Quick Schedule 頁 | LedRecordSettingActivity / LedRecordSettingViewController | LedRecordSettingPage |
| 清除入口 | LedRecordActivity btnIcon / LEDScheduleDetail resetBarButtonItem | **缺** |

### C. 是否可實際使用

**Partial** — 入口 1 可用；入口 2（清除後進入 Quick Schedule）尚未實作。

### D. 差異與修正建議

- **入口 1**：已對照，無排程時會導向 LedRecordSettingPage。
- **入口 2**：LedRecordPage 需在 toolbar 右上加入清除按鈕，對應 reef-b-app btnIcon，點擊→確認→clearRecords()→成功後導向 LedRecordSettingPage。
- 詳見 `LED_QUICK_SCHEDULE_PARITY_ANALYSIS.md`。

---

## 7. 排程編輯 (Schedule Edit)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI 編輯入口** | ✅ 存在 | LedScheduleListPage 的 `_ScheduleCard` 點擊 → LedScheduleEditPage |
| **Controller** | ✅ 存在 | LedScheduleEditPage 內建編輯邏輯 |
| **UseCase** | ✅ 存在 | `SaveLedScheduleUseCase`（支援 update） |
| **編輯流程** | ✅ 存在 | `initialSchedule` 傳入既有排程，完成後 `pop(true)` 觸發 refresh |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| 編輯頁 | `lib/features/led/presentation/pages/led_schedule_edit_page.dart` |
| 列表頁 | `lib/features/led/presentation/pages/led_schedule_list_page.dart` (L126-139, onTap) |
| UseCase | `lib/domain/usecases/led/save_led_schedule_usecase.dart` |

### C. 是否可實際使用

**Partial** — 依 SaveLedScheduleUseCase 實作而定：

- 若為 `.unavailable()`：會拋出 `AppErrorCode.notSupported`，**無法完成儲存**。
- 若為 `.local(repository)`：可在本地儲存，但**不寫入裝置**（BLE 排程寫入尚未實作）。

### D. 差異與修正建議

| 差異 | 說明 | 建議 |
|------|------|------|
| BLE 寫入 | koralcore 註解標註 "firmware limitation" | 若韌體支援，需補上 BLE schedule write |
| 編輯入口 | 列表 `onTap` 已正確導向 LedScheduleEditPage(initialSchedule) | 無需修改 |

---

## 8. 新增排程 (Schedule Create)

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **UI 新增按鈕** | ✅ 存在 | LedScheduleListPage 的 FAB |
| **UseCase** | ✅ 存在 | `SaveLedScheduleUseCase`（`scheduleId == null` 時 add） |
| **觸發 create/edit** | ✅ 存在 | FAB → LedScheduleEditPage()；卡片 onTap → LedScheduleEditPage(initialSchedule) |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| 列表頁 | `lib/features/led/presentation/pages/led_schedule_list_page.dart` |
| 編輯頁 | `lib/features/led/presentation/pages/led_schedule_edit_page.dart` |
| UseCase | `lib/domain/usecases/led/save_led_schedule_usecase.dart` |

### C. 是否可實際使用

**No**（與排程編輯相同限制）

- 預設 `SaveLedScheduleUseCase.unavailable()` 會拋出 `AppErrorCode.notSupported`。
- 需改為 `SaveLedScheduleUseCase.local(repository)` 才能有本地儲存；裝置端儲存仍需 BLE 支援。

### D. 差異與修正建議

| 差異 | 說明 | 建議 |
|------|------|------|
| UseCase 預設 | `.unavailable()` | 若需本地儲存，改為註冊 `.local(ScheduleRepositoryImpl())` |
| BLE 寫入 | 未實作 | 依韌體規格決定是否補上 |

---

## 9. LED 名稱顯示

### A. 存在性

| 項目 | 狀態 | 說明 |
|------|------|------|
| **List/Cell 顯示** | ✅ 存在 | LedMainPage toolbar、_DeviceIdentificationSection 顯示 deviceName |
| **詳細頁顯示** | ✅ 存在 | 多個 LED 頁面使用 `session.activeDeviceName` |
| **與 Device 同步** | ✅ 存在 | `session.activeDeviceName`、`deviceRepository.getDevice()` |

### B. 對應檔案

| 類型 | 檔案路徑 |
|------|----------|
| Toolbar | `lib/features/led/presentation/pages/led_main_page.dart`（`_ToolbarDevice(title: deviceName)`） |
| Device 資訊區 | `lib/features/led/presentation/pages/led_main_page.dart`（`_DeviceIdentificationSection`） |
| LedMainDeviceInfoSection | `lib/features/led/presentation/widgets/led_main_device_info_section.dart`（未使用於 LedMainPage） |
| Session | `lib/app/common/app_session.dart`（`activeDeviceName`） |

### C. 是否可實際使用

**Yes**

### D. 差異與修正建議

- 名稱來源與 reef-b-app 對齊，無重大差異。
- `LedMainDeviceInfoSection` 目前未被 LedMainPage 使用， LedMainPage 使用 `_DeviceIdentificationSection`。

---

## 總結對照表

| 功能 | UI | Controller/UseCase | Store/State | 可實際使用 | 備註 |
|------|----|-------------------|-------------|------------|------|
| 1. 一分鐘快速預覽 | ✅ | ✅ | ✅ | Yes | 已修正無 record 預覽 |
| 2. 場景列表 | ✅ | ✅ | ✅ | Yes | 主頁 _FavoriteSceneArea 可點擊 |
| 3. 新增場景 | ✅ | ✅ | ✅ | Yes | - |
| 4. 刪除場景 | ✅ | ✅ | ✅ | Yes | - |
| 5. 最愛 | ✅ | ✅ | ✅ | Yes | 主頁 _FavoriteSceneArea 顯示最愛可點擊 |
| 6. 快速排程 | Partial | ✅ | ✅ | Partial | 入口 1 有，入口 2（清除按鈕）缺 |
| 7. 排程編輯 | ✅ | ✅ | ✅ | Partial | SaveLedScheduleUseCase 預設 unavailable |
| 8. 新增排程 | ✅ | ✅ | ✅ | No | 同上 |
| 9. LED 名稱顯示 | ✅ | N/A | ✅ | Yes | - |

---

## 優先修正建議（依 reef-b-app 基準）

1. **Quick Schedule 入口 2**：LedRecordPage 需加入 toolbar 清除按鈕，成功後導向 LedRecordSettingPage（對照 reef-b-app btnIcon / resetBarButtonItem）。入口 1（無排程→LedRecordSetting）已對照。
2. ~~**主頁場景點擊**~~：✅ **已修正** – 改採 `_FavoriteSceneArea`，顯示最愛場景並支援點擊套用（對照 reef-b-app FavoriteSceneAdapter.setEnabled + onClickScene）。
3. ~~**Schedule Create/Edit 可用性**~~：✅ **對照 reef-b-app** – reef-b-app 不本地儲存排程（LedInformation/LedDevice 僅記憶體），koralcore 改為 `SaveLedScheduleUseCase.unavailable()`。
4. ~~**預覽無 record 時**~~：✅ **已修正** – `togglePreview()` 改為在無 record 時傳入 `recordId: null` 發送 BLE 指令（對照 reef-b-app clickBtnPreview 無 record 檢查）。
5. ~~**Record 更多按鈕**~~：✅ **已修正** – 預覽中點擊時先 `stopPreview()` 不導航（對照 reef-b-app clickBtnRecordMore）。

**剩餘待確認**：BLE 圖示點擊（_DeviceIdentificationSection 無 onTap，可改用 LedMainDeviceInfoSection）。
