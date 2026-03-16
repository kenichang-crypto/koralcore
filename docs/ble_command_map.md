# REEF B BLE Command Map

整理 `koralcore` 中建立於 `LedCommandBuilder` 與 `DosingCommandBuilder` 的主要 BLE payload，並追蹤 UI → controller → use case → repository（或 controller/adapter 直寫）→ command builder → `BleAdapterImpl.writeBytes()` 的路徑。表格下方再補充協定檢核與所觀察到的命令路徑特性。

## 1. LED 模組命令

LED 相關命令都在 `led/data/ble/led_command_builder.dart` 定義，對應到 `BleLedRepositoryImpl`（則被 `LedRepository`、`LedRecordRepository` 封裝）與各類用例/控制器。常見旅程如下：

| opcode | 語意 | Builder | Repository / UseCase | 常見 UI 觸發（頁面 + 控制器） | 備註 |
| --- | --- | --- | --- | --- | --- |
| `0x21` | `syncInformation()` | `LedCommandBuilder.syncInformation()` | `BleLedRepositoryImpl._requestSync()`（`session` 建立、`refresh()`、`applyScene()` 完成後、手動同步）| 無 UI，連線後 repository 自發；`Refresh` 拉動 `LedSceneListController.refresh()` 時也會觸發 `ledRepository.refresh()` | 代表 `SYNC_START/END`，LED 以 `data[2]` 維持：`0x01=START`、`0x02=END`、`0x00=FAILED` |
| `0x27` | `setRecord()` | `LedCommandBuilder.setRecord(...)` | `BleLedRepositoryImpl.setRecord()` | `LedRecordTimeSettingPage` 的「儲存」按鈕 → `LedRecordTimeSettingController.saveRecord()` → `LedRecordRepository.setRecord()` | `InitLedRecordUseCase` 也會連續呼叫這條路徑建立預設五筆紀錄；使用者可在新增/編輯時間儲存 |
| `0x28 / 0x29` | `usePresetScene()` / `useCustomScene()` | `LedCommandBuilder.usePresetScene()` / `...useCustomScene()` | `BleLedRepositoryImpl.applyScene()` via `ApplySceneUseCase` | `LedSceneListPage` 中 Scene 卡片的 `onApply` → `LedSceneListController.applyScene()` | 預設場景使用 0x28、客製場景 0x29； Controller 會在送命令前強制停止預覽 |
| `0x2A` | `preview(start: true/false)` | `LedCommandBuilder.preview(start: bool)` | `BleLedRepositoryImpl.startPreview()` / `stopPreview()`（`LedRecordLookup` 主要狀態） | `LedRecordController.togglePreview()`（也被 `LedSceneListController` 在資料載入前呼叫） | 開始/停止預覽以 `recordId` 或 `null` 決定 |
| `0x2B` | `startRecordPlayback()` | `LedCommandBuilder.startRecordPlayback()` | `BleLedRepositoryImpl.startRecord()` | `LedSceneListController.startRecord()` → `StartLedRecordUseCase` | 對應 Android `getLedStartRecordCommand` |
| `0x30` | `clearRecords()` | `LedCommandBuilder.clearRecords()` | `BleLedRepositoryImpl.clearRecords()` | `LedRecordController.clearRecords()`，透過 `EndLedRecordUseCase` 等用例 | 清空所有記錄後 repository 會呼叫 `session.beginRecordMutation()` 等 |
| `0x32 / 0x33 / 0x34` | 進入 / 調光 / 離開 | `LedCommandBuilder.enterDimmingMode()` / `dimming()` / `exitDimmingMode()` | `EnterDimmingModeUseCase` / `SetChannelIntensityUseCase` / `ExitDimmingModeUseCase` → `BleLedRepositoryImpl.setChannelLevels()` | `LedRecordTimeSettingController` 或 `LedControlController` 透過滑桿、按鈕進出調光模式 | 0x33 需要在 0x32 成功後使用；`setChannelLevels` 會更新 `LedState.channelLevels` |
| `0x2E` | `resetLed()` | `LedCommandBuilder.resetLed()` | `BleLedRepositoryImpl.resetToDefault()`（透過 `ResetLedStateUseCase`） | LED 設備設定頁的「重設」按鈕（例如 `LedMasterSettingController`） | 重置後會清空快取並再度 `_requestSync()` |

### LED 命令路徑重點
- UI：`LedSceneListPage` / `LedRecordTimeSettingPage` / `LedControlPage` 等頁面以 `Controller`/`UseCase` 為橋接。
- 用例：`ApplySceneUseCase`、`SetChannelIntensityUseCase`、`StartLedRecordUseCase`、`ResetLedStateUseCase`，最後都呼叫 `BleLedRepositoryImpl`。
- Repository：動作發送命令後呼叫 `_bleAdapter.writeBytes()`，再由 `BleAdapterImpl` 管理 queue、notification guard。

## 2. Dosing 模組命令

`DosingCommandBuilder` 將 0x60~0x7F 的 payload 封裝，`BleDosingRepositoryImpl`、`DosingScheduleController`、`PumpHead*Controller`（直寫 `BleAdapter`）負責送出，包括 lifecycle、設定、手動滴液、排程、校準等行為。

| opcode | 語意 | Builder | 呼叫者 | UI 入口 | 備註 |
| --- | --- | --- | --- | --- | --- |
| `0x60` | `timeCorrection` | `DosingCommandBuilder.timeCorrection()` | `DeviceConnectionCoordinator._sendTimeCorrection()` | 連線成功且 `BleAdapterImpl.isNotificationReady` 為 true 後自動下達 | 要等首次已接收到 dosing notify 才送 |
| `0x65` | `syncInformation()` | `DosingCommandBuilder.syncInformation()` | `BleDosingRepositoryImpl._requestSync()`（在 `0x60` ACK 後） | 無 UI；`initializeDeviceUseCase` 會在 `DeviceConnectionCoordinator` 完成 `timeCorrection` 之後間接觸發 | sync 會收到 0x65 回傳 `START/END`; `finalizeSync()` 接著啟動 0x7A/0x77 |
| `0x7A` | 今日總量查詢 | `DosingCommandBuilder.getTodayTotalVolume(headNo)` | `BleDosingRepositoryImpl._requestNextTodayTotal()`（`pumpHeadCount` 決定） | 無 UI，sync 結束時自動按頭輪詢 | 每個 pump head 執行 timeout guard |
| `0x77` | 調整歷史查詢 | `DosingCommandBuilder.getAdjustHistory(headNo)` | `BleDosingRepositoryImpl._requestNextAdjustHistory()` | 同上 | 完成後會 log `BLE_DEVICE_READY`，讓 `session.isReady` 保持 true |
| `0x61` | `setDelayTime(seconds)` | `DosingCommandBuilder.setDelayTime()` | `DropSettingController._updateDelayTime()` | `DropSettingPage` 的 Save toolbar (`FilledButton.onPressed`) | 會先更新 DB，若 BLE 連線且 ready 才下命令 |
| `0x62` | `setRotatingSpeed(headNo, speed)` | `DosingCommandBuilder.setRotatingSpeed()` | `PumpHeadSettingsController._updateRotatingSpeed()` | 設定頁的「儲存」或單純在頁面切換速度滑桿時觸發 | 需在 `session.isReady` 且 BLE 已連線時才發送 |
| `0x63 / 0x64` | Manual Drop start/end | `commandBuilder.manualDropStart/end()` | `DosingMainController.toggleManualDrop()` | Dosing 主頁（`DosingMainPage`）手動投藥按鈕 | 直接呼叫 `bleAdapter.writeBytes()`，不透過 repository |
| `0x6E~0x74` | 單次/週期/自訂排程 | 對應 `singleDropImmediately`, `h24DropWeekly`, `customDropWeekly`, `customDropRange`, `customDropDetail` 等 | `DosingScheduleController`（直寫 `BleAdapter`） | `PumpHeadRecordSettingPage` 的 Save 會呼叫 `DosingScheduleController` 對應 create* 方法 | 每個方法會先轉 `volumeMl * 10`、再送命令 |
| `0x75 / 0x76` | 校準開始 / 結果回報 | `DosingCommandBuilder.startAdjust()`、`adjustResult()` | `PumpHeadAdjustController.startCalibration()` / `completeCalibration()` | 校準頁按鈕：開始 / 完成 | `startAdjust` 觸發倒數 21 秒，完成後 `adjustResult` 送實測 ml ×10 |

### Dosing 命令路徑重點
- `DeviceConnectionCoordinator` 與 `BleDosingRepositoryImpl` 共同維護生命周期，前者負責連線、notification guard、0x60 time correction、`InitializeDeviceUseCase`；後者在 `0x60` ACK 後啟動 0x65 / 0x7A / 0x77 序列。
- UI 層由 controllers（`DropSettingController`、`PumpHeadSettingsController`、`PumpHeadAdjustController`、`DosingMainController`）或 `DosingScheduleController`（排程）直接呼叫 `BleAdapter.writeBytes()`。有些路徑會經 `UseCase`（如 `ApplySceneUseCase` 與 `DropSettingController` 使用的 `UpdateDeviceNameUseCase`），但 BLE 命令仍由上游 builder 實際產生。
- `BleDosingRepositoryImpl.sendCommand()` 在發 0x60 以上的命令前會先延遲 200 ms（對應 Android）並在 `_ensureDoseCapabilityConfirmed` 時插入 0x7E 探測命令。

## 3. 協定檢核

- LED repository 中只會建立 0x20~0x3F 的 payload（`rg "0x6" lib/data/led/ble_led_repository_impl.dart` 沒有任何 match）。
- Dosing repository 只呼叫 0x60~0x7F，且 UI controller 也沒有在 LED 協定範圍內發送資料。
- 兩者未交叉發射（也沒有硬coded `0x21` 送到 `BleDosingRepositoryImpl`、`0x65` 發自 `BleLedRepositoryImpl`），因此目前未觀察到 `⚠ protocol violation`。

## 4. 命令通道概覽

各命令最終都經 `BleAdapterImpl.writeBytes()` 送進 `_queue`，由 `_processQueue()` 透過 `_executeCommand()` 串行化；`BleAdapterImpl.clearQueue()` 會在斷線時清空 `_queue` 並取消當前命令，避免殘留。 BLE 命令返回時則由 `BleNotifyBus` 驅動的 `_handleDevicePacket()` 依 opcode 分流，更新 repository state。

