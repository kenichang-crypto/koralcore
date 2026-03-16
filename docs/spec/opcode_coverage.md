# BLE Opcode Coverage

This table records the Flutter UI entry point that ultimately triggers each expected LED/Dosing opcode (or the lifecycle component that fires it). “Status” reflects whether the opcode is reached from the current UI stack (`OK`) or still lacks a direct hook/mapping (`MISSING`).

| Opcode | Feature | Controller / Repository | UI entry | Status |
| ------ | ------- | ---------------------- | -------- | ------ |
| 0x20 | LED time correction | `DeviceConnectionCoordinator` → `DosingCommandBuilder.timeCorrection()` | device connect (any LED/Dosing entry) | OK |
| 0x21 | LED sync information | `BleLedRepositoryImpl.syncRecords()` | LED main prerequisites (connect ready) | OK |
| 0x27 | LED set record / schedule | `LedRecordController.saveRecord()` → `SaveLedRecordUseCase` → `BleLedRepositoryImpl.setRecord()` | `LedRecordSettingPage` “儲存” | OK |
| 0x28 | LED apply preset scene | `LedSceneListController.applyScene()` → `BleLedRepositoryImpl.applyScene()` | `LedSceneListPage` “Apply” button | OK |
| 0x29 | LED apply custom scene | same as 0x28 | `LedSceneListPage` “Apply” on custom scenes | OK |
| 0x2A | LED preview toggle | `LedRecordController.togglePreview()` → `startLedPreviewUseCase` | `LedMainPage` preview button / record preview card | OK |
| 0x30 | LED clear records | `LedRecordController.clearRecords()` | `LedRecordPage` “清除” | OK |
| 0x32 | LED enter dimming mode | `LedRecordTimeSettingController.enterDimmingMode()` → `EnterDimmingModeUseCase` | `LedRecordPage` / record editor preview slider entry | OK |
| 0x33 | LED dimming data (channel update) | `SetChannelIntensityUseCase.execute()` triggered from slider | `_ChannelSlider` on `LedRecordTimeSettingPage` | OK |
| 0x34 | LED exit dimming mode | `LedRecordTimeSettingController.exitDimmingMode()` | `LedRecordTimeSettingPage` “完成” / exit actions | OK |
| 0x61 | Dosing set delay time | `DropSettingController._updateDelayTime()` → `SetDelayTimeUseCase` | `DropSettingPage` “儲存” | OK |
| 0x62 | Dosing set speed | `PumpHeadSettingsController._updateRotatingSpeed()` | `PumpHeadSettingsPage` “儲存” | OK |
| 0x63 | Manual drop start | `DosingMainController.toggleManualDrop()` | Dosing main pump head play button | OK |
| 0x64 | Manual drop stop | same as 0x63 (toggle) | same button (stop state) | OK |
| 0x6E–0x74 | Schedule commands (single, 24hr, custom) | `PumpHeadRecordSettingController` + `DosingScheduleController.create*()` → `BleDosingRepositoryImpl` | `PumpHeadRecordSettingPage` save sections / `ManualDosingPage` immediate drop | OK |
| 0x75 | Calibration start | `PumpHeadAdjustController.startCalibration()` | `PumpHeadCalibrationPage` “下一步” | OK |
| 0x76 | Calibration result | `PumpHeadAdjustController.completeCalibration()` | same page “完成” | OK |
| 0x77 | Adjust history query | `BleDosingRepositoryImpl._requestNextAdjustHistory()` (lifecycle) | `PumpHeadAdjustListPage` (view results) + `PumpHeadDetailPage` “Recent Calibration” card | OK |
| 0x7A | Today total volume | `BleDosingRepositoryImpl._startTodayTotalsSequence()` | Device detail / UI unlocked after lifecycle (affects `PumpHeadDetailPage` summary) | OK |
