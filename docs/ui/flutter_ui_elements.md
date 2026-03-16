## Dosing Main

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Dosing main | Pump head manual drop (Play) | `IconButton` | Play / Stop | `session.isReady && controller.isConnected` | `DosingMainController.toggleManualDrop()` | `0x63` (start) / `0x64` (stop) | `lib/features/doser/presentation/pages/dosing_main_page.dart` |
| Dosing main | Connect/Disconnect | `FilledButton` | `連線 / 斷線` | none | `DosingMainController.toggleBleConnection()` | none (connect lifecycle triggers `0x60` etc.) | same file |
| Dosing main | Calibration card entry | `InkWell` | `Calibration` label | `session.isReady` | `Navigator.push` → `PumpHeadCalibrationPage` | opacity/none | same file |
| Dosing main | Schedule card entry | `InkWell` | `Schedule` | `session.isReady` | `Navigator.push` → `PumpHeadSchedulePage` | none | same file |
| Dosing main | Manual dose slot | `FilledButton` | `Manual dose` | `session.isReady` | open `ManualDosingPage` | `0x63/0x64` (via manual page) | same file |

## Manual Dosing

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Manual dosing | Submit manual drop | `FilledButton` | `送出` | `session.isReady` | `ManualDosingPageController.submit()` → `SingleDoseImmediateUseCase` | `0x6E`~`0x74` depending schedule | `lib/features/doser/presentation/pages/manual_dosing_page.dart` |
| Manual dosing | Quick volume buttons | `TextButton` | `+1 ml` etc. | `session.isReady` | `controller.updateVolume()` | none | same file |

## Pump Head Settings

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Settings | Save rotating speed | `FilledButton` | `儲存` | `session.isReady && controller.isConnected` | `PumpHeadSettingsController._updateRotatingSpeed()` | `0x62` | `lib/features/doser/presentation/pages/pump_head_settings_page.dart` |
| Settings | Speed slider | `Slider` | value | session.isReady | `_updateRotatingSpeed` binding | none | same file |
| Settings | Head selector | `GestureDetector` / `BottomSheet` | head label | none | open `SelectionListBottomSheet` | none | same file |

## Pump Head Calibration

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Calibration | Start calibration | `FilledButton` | `下一步` | `session.isReady` | `PumpHeadAdjustController.startCalibration()` → `DosingCommandBuilder.startAdjust` | `0x75` | `lib/features/doser/presentation/pages/pump_head_calibration_page.dart` |
| Calibration | Complete calibration | `FilledButton` | `完成` | `controller.isReady` | `PumpHeadAdjustController.completeCalibration()` | `0x76` | same file |
| Calibration | Speed picker | `BottomSheet` list | speed label | none | `PumpHeadAdjustSpeedPicker` selection | none | widget file |

## Schedule / Record Flow

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Schedule list | Add schedule | `FloatingActionButton` | `新增排程` | `session.isReady` | `Navigator.push` → `ScheduleEditPage` | none | `lib/features/doser/presentation/pages/pump_head_schedule_page.dart` |
| Schedule edit | Create schedule | `FilledButton` | `儲存` | form valid | `PumpHeadRecordSettingController.saveSchedule()` | `0x6E`~`0x74` | `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` |
| Record setting | Clear record | `TextButton` | `清除` | session ready | `PumpHeadRecordSettingController.clearSchedule()` | `0x79` | same file |
| Record time | Save time detail | `FilledButton` | `完成` | valid data | `PumpHeadRecordTimeSettingController.saveTime()` | part of schedule commands | `lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart` |

## Drop Setting

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Drop setting | Delay slider | `Slider` | value label | session ready | `_updateDelayTime()` | `0x61` | `lib/features/doser/presentation/pages/drop_setting_page.dart` |
| Drop setting | Save button | `FilledButton` | `儲存` | session ready | `DropSettingController.save()` | `0x61` | same file |
| Drop setting | Reset dialog | `showDialog` | confirm text | none | resets internal state | none | same file |
| Drop type | Confirm type | `FilledButton` | `確認` | session ready | updates drop type controller | none | `lib/features/doser/presentation/pages/drop_type_page.dart` |

## LED Main

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| LED main | Preview toggle | `IconButton` | preview icon | `session.isReady` | `LedRecordController.togglePreview()` → `startLedPreviewUseCase` / `stopLedPreviewUseCase` | `0x2A` | `lib/features/led/presentation/pages/led_main_page.dart` |
| LED main | Scene more | `IconButton` | `場景` | session ready | `Navigator.push` → `LedSceneListPage` | none | same file |
| LED main | Record more | `IconButton` | `記錄` | session ready | `Navigator.push` → `LedRecordPage` | none | same file |
| LED main | Toolbar menu | `PopupMenuButton` | edit/reset/delete | session ready | shows menu → navigates to settings/delete | `0x2E/0x2B` etc depending action | same file |
| LED main | Favorite toggle | `IconButton` | heart | session ready | `LedMainController.toggleFavorite()` | none | same file |

## LED Scene Flow

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Scene list | Apply preset | `FilledButton` | `Apply` | session ready | `LedSceneListController.applyScene()` → `BleLedRepositoryImpl.applyScene()` | `0x28/0x29` | `lib/features/led/presentation/pages/led_scene_list_page.dart` |
| Scene list | Favorite icon | `IconButton` | star | none | `controller.toggleFavoriteScene()` | none | same file |
| Scene add/edit | Save | `FilledButton` | `儲存` | session ready | `LedSceneEditController.saveScene()` | `0x27/0x28/0x29` | `lib/features/led/presentation/pages/led_scene_edit_page.dart` |
| Scene add/edit | Delete | `TextButton` | `刪除` | session ready | `LedSceneEditController.deleteScene()` | `0x2F`? (record delete) | same file |

## LED Record Flow

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Record list | Preview selected | `IconButton` | `預覽` | session ready | `LedRecordController.togglePreview()` | `0x2A` | `lib/features/led/presentation/pages/led_record_page.dart` |
| Record list | Next / previous | `IconButton` | arrows | session ready | `controller.goToNextRecord()` | none | same file |
| Record setting | Save record | `FilledButton` | `儲存` | form valid | `LedRecordController.saveRecord()` → `BleLedRepositoryImpl.setRecord()` | `0x27/0x2B` | `lib/features/led/presentation/pages/led_record_setting_page.dart` |
| Record setting | Cancel | `TextButton` | `取消` | none | `Navigator.pop` | none | same file |
| Record time | Save time | `FilledButton` | `完成` | valid | `LedRecordTimeSettingController.saveTime()` | part of record commands | `lib/features/led/presentation/pages/led_record_time_setting_page.dart` |

## LED Schedule Flow

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Schedule list | Add schedule | `FloatingActionButton` | `新增` | session ready | `Navigator.push` → `LedScheduleEditPage` | none | `lib/features/led/presentation/pages/led_schedule_list_page.dart` |
| Schedule edit | Save / delete | `FilledButton` / `TextButton` | `儲存` / `刪除` | form valid | `LedScheduleEditController.save()` | `0x27` etc via record path | `lib/features/led/presentation/pages/led_schedule_edit_page.dart` |

## LED Settings

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| settings | Save | `FilledButton` | `儲存` | session ready | `LedSettingController.save()` | none (metadata) | `lib/features/led/presentation/pages/led_setting_page.dart` |
| settings | Factory reset | `TextButton` | `重置` | connected | `showDialog` → `controller.resetDevice()` | `0x2E/0x30` per action | same file |
| master setting | Add master | `IconButton` | plus icon | none | `LedMasterSettingController.add()` | none | `lib/features/led/presentation/pages/led_master_setting_page.dart` |

## Device / Home / Bluetooth

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Home tab | Device card | `InkWell` | device name | none | `HomeController.selectDevice()` | triggers connect lifecycle (0x60) | `lib/features/home/presentation/pages/home_tab_page.dart` |
| Device tab | Add device FAB | `FloatingActionButton` | `+` | none | opens `AddDevicePage` | none | `lib/features/device/presentation/pages/device_tab_page.dart` |
| Device tab | Delete mode | `IconButton` | delete icon | selection count>0 | `controller.deleteDevice()` | none | same file |
| Bluetooth tab | Refresh | `FilledButton` | `刷新` | none | `BluetoothController.refresh()` | none | `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` |
| Bluetooth tab | Device tile tap | `GestureDetector` | device name/addr | none | connect/disconnect via controller | none (connection triggers BLE) | same file |

## Shared Overlays

| Screen | Element | Widget | Text | Condition | Action | BLE opcode | Flutter location |
| Confirmation | `FilledButton` | `確認` | generic confirm | depends on caller | caller controller callback | depends on context | `lib/shared/widgets/confirmation_dialog.dart` |
| BLE guard | `FilledButton` | `重試` | BLE guard message | BLE not ready | `BleGuard.show` callback | none | `lib/core/ble/ble_guard.dart` |
| Selection bottom sheet | `ListTile` | sink/head labels | available items | none | set selection | none | `lib/shared/widgets/selection_list_bottom_sheet.dart` |
