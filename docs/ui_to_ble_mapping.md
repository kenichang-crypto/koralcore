# UI → BLE Mapping（koralcore）

本檔彙整目前 Flutter 的 UI 事件到 BLE 命令的完整路徑，並額外列出已定位但暫時不會觸發 BLE 命令的 UI。「路徑」欄位描述 Controller / UseCase / Repository 的串接順序。

## 1. LED 模組

| UI Widget / 事件 | Controller / UseCase | Command Builder | Opcode | BLE 執行點 | 路徑簡述 |
| --- | --- | --- | --- | --- | --- |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` SceneCard 的 `onApply()` | `LedSceneListController.applyScene()` → `ApplySceneUseCase` | `LedCommandBuilder.usePresetScene()` 或 `.useCustomScene()` | `0x28` / `0x29` | `BleLedRepositoryImpl.applyScene()` → `_bleAdapter.writeBytes()` | Scene 列表點「套用」時先透過 controller 停 preview，再透過 use case 檢查狀態，最後由 repository 送出 0x28/0x29 |
| `lib/features/led/presentation/pages/led_record_time_setting_page.dart` 儲存按鈕 (`onPressed` 呼叫 controller) | `LedRecordTimeSettingController.saveRecord()` | `LedCommandBuilder.setRecord(...)` | `0x27` | `LedRecordRepository.setRecord()` → `BleLedRepositoryImpl.setRecord()` | 透過 `LedRecordRepository` 連續處理時間檢查後呼叫 repository 送 0x27 |
| `lib/features/led/presentation/pages/led_record_page.dart` 預覽按鈕 | `LedRecordController.togglePreview()` → `StartLedPreviewUseCase` / `StopLedPreviewUseCase` | `LedCommandBuilder.preview(start: _)` | `0x2A` | `BleLedRepositoryImpl.startPreview()` / `stopPreview()` | 預覽開關直接由 repository 發 0x2A start/stop |
| `lib/features/led/presentation/pages/led_control_page.dart` slider 調整+`apply`按鈕 | `LedControlController.applyChanges()` → `SetChannelIntensityUseCase` | `LedCommandBuilder.dimming()`（需先送 0x32 進入調光模式） | `0x33` (+ 0x32/0x34) | `BleLedRepositoryImpl.setChannelLevels()` | 控制器會先呼叫 `SetChannelIntensityUseCase`，最後封裝 channel map 給 repository |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` `FloatingActionButton`（新增場景） | `LedSceneEditController`（編輯頁面會呼叫 `EnterDimmingModeUseCase` / `setChannelIntensityUseCase`） | `LedCommandBuilder.enterDimmingMode()` / `.exitDimmingMode()` | `0x32` / `0x34` | `BleAdapter.write()` | 進入/離開調光模式的命令直接由 use case 寫到 `BleAdapter`，不經 repository |
| `lib/features/led/presentation/pages/led_main_page.dart` 「重設設備」按鈕 | `ResetLedStateUseCase.execute()` | `LedCommandBuilder.resetLed()` | `0x2E` | `BleLedRepositoryImpl.resetToDefault()` | 透過 `LedRepository.resetToDefault()` 送出 0x2E，回傳後 repository 會呼叫 `_requestSync()` |

### Dead UI（暫未觸發 BLE 命令）

| UI Widget / 事件 | Controller | 理由 |
| --- | --- | --- |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` SceneCard 右上星星 (`IconButton` 的 `controller.toggleFavoriteScene(scene.id)`) | `LedSceneListController.toggleFavoriteScene()` | 只呼叫 `FavoriteRepositoryImpl` 儲存最愛清單，完全不進入任何 BLE command builder；按下星星只改本地收藏狀態。 |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` SceneCard 的 `onTap`（編輯自訂場景） | `LedSceneListController` 導導航至 `LedSceneEditPage`，目前 `edits` 只是 local state，並未自動送 BLE 命令。 | 目前漏斗僅在編輯頁完成後才存檔並呼叫 `ApplySceneUseCase`，單純點擊「進入編輯」無 BLE |

## 2. Dosing 模組

| UI Widget / 事件 | Controller / UseCase | Command Builder | Opcode | BLE 執行點 | 路徑簡述 |
| --- | --- | --- | --- | --- | --- |
| `lib/features/doser/presentation/pages/dosing_main_page.dart` 手動滴液按鈕 | `DosingMainController.toggleManualDrop()` | `DosingCommandBuilder.manualDropStart/End()` | `0x63` / `0x64` | 直接呼叫 `bleAdapter.writeBytes()` | 決定 pump head 狀態後馬上在 controller 內建 command（不通過 repository），確保手動滴液機制最低延遲。 |
| `lib/features/doser/presentation/pages/drop_setting_page.dart` 儲存按鈕 | `DropSettingController.save()` → `_updateDelayTime()` | `DosingCommandBuilder.setDelayTime()` | `0x61` | `BleAdapter.writeBytes()` | 先更新 DB，再向 `BleAdapter` 送命令；僅在 `session.isReady` 才會執行 BLE 發送。 |
| `lib/features/doser/presentation/pages/pump_head_settings_page.dart` 儲存速度按鈕 | `PumpHeadSettingsController._updateRotatingSpeed()` | `DosingCommandBuilder.setRotatingSpeed()` | `0x62` | `BleAdapter.writeBytes()` | 同樣需 `session.isReady`。 |
| `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` 提交 schedule | `PumpHeadRecordSettingController.saveSchedule()` → `DosingScheduleController.create*()` | 對應 `singleDropImmediately`~`customDropDetail` | `0x6E`~`0x74` | `BleAdapter.writeBytes()`（`DosingScheduleController`） | 根據 `recordType` 選擇排程類型，直接用 `DosingCommandBuilder` 計算 payload。 |
| `lib/features/doser/presentation/pages/pump_head_adjust_page.dart` 開始 / 完成校準 | `PumpHeadAdjustController.startCalibration()` / `completeCalibration()` | `DosingCommandBuilder.startAdjust()` / `.adjustResult()` | `0x75` / `0x76` | `BleAdapter.writeBytes()` | 依照跑表的 `headId` 轉成 pump id，`completeCalibration` 還會驗證 `volume` 範圍。 |

### Dead UI（暫未觸發 BLE 命令）

| UI Widget / 事件 | Controller | 理由 |
| --- | --- | --- |
| `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` 選擇 `PumpHeadRecordType.none` 後按 Save | `PumpHeadRecordSettingController.saveSchedule()` 的 `case PumpHeadRecordType.none` 分支 | 目前僅 `await Future.delayed(const Duration(milliseconds: 500))` 作為 placeholder，並未產生任何 BLE 命令，對應 Android 的「清除排程」尚未接上 `DosingScheduleController`。 |
| `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` 每次添加 `_recordDetails` | `PumpHeadRecordSettingController.addRecordDetail()` | 只更新 `_recordDetails` List，未送命令 | 這是 UI 上的細節編輯操作，不會即時觸發 BLE，僅在按 Save 時才進入 `DosingScheduleController`。 |

