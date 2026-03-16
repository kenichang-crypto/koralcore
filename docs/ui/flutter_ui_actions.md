## UI action → controller → use case → opcode

| UI element | Controller | Use case | BLE opcode |
| --- | --- | --- | --- |
| Manual drop toggle (play/stop) | `DosingMainController` | n/a (controller writes directly) | `DosingCommandBuilder.manualDropStart/End()` → `0x63` / `0x64` |
| Save delay time | `DropSettingController` | `SetDelayTimeUseCase` | `DosingCommandBuilder.setDelayTime()` → `0x61` |
| Save rotating speed | `PumpHeadSettingsController` | `SetRotatingSpeedUseCase` | `DosingCommandBuilder.setRotatingSpeed()` → `0x62` |
| Start calibration | `PumpHeadAdjustController` | `StartCalibrationUseCase` | `DosingCommandBuilder.startAdjust()` → `0x75` |
| Complete calibration | `PumpHeadAdjustController` | `CompleteCalibrationUseCase` | `DosingCommandBuilder.adjustResult()` → `0x76` |
| Create pump head schedule | `PumpHeadRecordSettingController` | `DosingScheduleController.*` | `DosingCommandBuilder` methods `0x6E-0x74`, depending on type |
| Clear pump head schedule | `PumpHeadRecordSettingController` | `DosingScheduleController.clearSchedule()` | `DosingCommandBuilder.clearRecord()` → `0x79` |
| Manual dosing submit | `ManualDosingPageController` | `SingleDoseImmediateUseCase` | `DosingCommandBuilder.singleDropImmediately()` → `0x6E` (or timed variant) |
| Delay slider change | `DropSettingController` | `SetDelayTimeUseCase` | none until save button pressed (`0x61`) |
| LED preview toggle | `LedRecordController` | `StartLedPreviewUseCase` / `StopLedPreviewUseCase` | `LedCommandBuilder.preview()` → `0x2A` |
| Apply scene (preset/custom) | `LedSceneListController` | `ApplySceneUseCase` | `LedCommandBuilder.applyScene()` → `0x28` / `0x29` |
| Save LED record | `LedRecordController` | `SaveLedRecordUseCase` | `LedCommandBuilder.setRecord()` → `0x27` |
| Delete LED record | `LedRecordController` | `DeleteLedRecordUseCase` | `LedCommandBuilder.deleteRecord()` → `0x2F` (or record clear `0x30`) |
| Enter dimming mode | `LedRecordTimeSettingController` | `EnterDimmingModeUseCase` | `LedCommandBuilder.enterDimmingMode()` → `0x32` |
| Send dimming channels | `SetChannelIntensityUseCase` | `LedCommandBuilder.dimming()` → `0x33` |
| Exit dimming mode | `LedRecordTimeSettingController` / `ExitDimmingModeUseCase` | `LedCommandBuilder.exitDimmingMode()` → `0x34` |
| Favorite LED scene | `LedSceneListController` | `ToggleFavoriteSceneUseCase` | none (local DB update) |
| Scene add/save | `LedSceneEditController` | `SaveSceneUseCase` | uses `LedCommandBuilder.setRecord()` + scene command (0x27 / 0x28/0x29) |
| Schedule save (LED) | `LedScheduleEditController` | `SaveLedScheduleUseCase` | reuses LED record/save path (`0x27` + related) |
| BLE guard retry | `BleGuard` helper | n/a | none |
| Device connect button | `DosingMainController` / `ConnectDeviceUseCase` | `ConnectDeviceUseCase` | connects → triggers lifecycle `0x60`, `0x65`, `0x7A`, `0x77` |
| Device delete confirm | `DeviceSettingsController` | `RemoveDeviceUseCase` | none |
