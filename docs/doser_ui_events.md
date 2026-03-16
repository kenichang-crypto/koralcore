| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/doser/presentation/pages/dosing_main_page.dart` | `DosingMainPumpHeadList` (pump head Play button) | `onHeadPlay` | `controller.toggleManualDrop(index)` |
| `lib/features/doser/presentation/pages/dosing_main_page.dart` | `_DeviceIdentificationSection` (BLE button) | `onBle` | `controller.toggleBleConnection()` |
| `lib/features/doser/presentation/pages/drop_setting_page.dart` | `FilledButton` (Save toolbar button) | `onPressed` | `controller.save()` → eventually `controller.setDelayTime()` |
| `lib/features/doser/presentation/pages/pump_head_settings_page.dart` | `FilledButton` (Save) | `onPressed` | `controller.save()` → `_updateRotatingSpeed()` sends `0x62` |
| `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` | Toolbar Save button | `onPressed` | `_onSave(...)` → `controller.saveSchedule()` → `DosingScheduleController` sends `0x6E-0x74` |
| `lib/features/doser/presentation/pages/manual_dosing_page.dart` | `FilledButton` (Manual dose submit) | `onPressed` | `_handleSubmit(context)` → `controller.submit()` (manual drop command) |
| `lib/features/doser/presentation/widgets/pump_head_adjust_bottom_buttons.dart` | Primary “Next” button (when not complete) | `onPressed` | `controller.startCalibration(context)` → sends `0x75` |
| `lib/features/doser/presentation/widgets/pump_head_adjust_bottom_buttons.dart` | “Complete Calibration” button (after timer) | `onPressed` | `controller.completeCalibration(context)` → sends `0x76` |

## LED module UI events

| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` | `_SceneCard` “Apply” button | `onApply` | `controller.applyScene(scene.id)` |
| `lib/features/led/presentation/pages/led_scene_list_page.dart` | `_SceneCard` favorite icon | `onPressed` | `controller.toggleFavoriteScene(scene.id)` |
| `lib/features/led/presentation/pages/led_record_page.dart` | Toolbar “Clear” button | `onPressed` | `controller.clearRecords()` |
| `lib/features/led/presentation/pages/led_record_page.dart` | Record navigation buttons | `onPressed` | `controller.goToPreviousRecord()` / `controller.goToNextRecord()` |
| `lib/features/led/presentation/pages/led_record_page.dart` | Preview button | `onPressed` | `controller.togglePreview()` |
| `lib/features/led/presentation/pages/led_schedule_edit_page.dart` | Save button (`FilledButton`) | `onPressed` | `_handleSave()` → `controller.saveSchedule()` |

## Home & Device navigation events

| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/home/presentation/pages/home_tab_page.dart` | `_SinkSelectorBar` dropdown | `onSelected` | `controller.selectSinkOption(index, l10n)` |
| `lib/features/home/presentation/pages/home_tab_page.dart` | `_SinkSelectorBar` manager icon | `onPressed` | `Navigator.of(context).push(...)` (open `SinkManagerPage`) |
| `lib/features/home/presentation/pages/home_tab_page.dart` | `_HomeDeviceGridTile` device card | `onTap` | `_navigateToDeviceMainPage(context, device)` (sets `AppSession` active device and pushes LED/Dosing main page) |
| `lib/features/device/presentation/pages/device_tab_page.dart` | `_DeviceCardWithSink` card | `onSelect` | `controller.toggleSelection(device.id)` (selection mode) |
| `lib/features/device/presentation/pages/device_tab_page.dart` | `_DeviceCardWithSink` card | `onTap` | `_navigateToDeviceMainPage(context, device)` |
| `lib/features/device/presentation/pages/device_tab_page.dart` | `_EmptyState` “Add Device” button | `onPressed` | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddDevicePage()))` |

## Add Device page events

| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/device/presentation/pages/add_device_page.dart` | `_ToolbarTwoAction` left “Skip” | `onPressed` | `controller.skip()` (aborts setup and pops) |
| `lib/features/device/presentation/pages/add_device_page.dart` | `_ToolbarTwoAction` right “Done” | `onPressed` | `controller.addDevice()` (saves device) |
| `lib/features/device/presentation/pages/add_device_page.dart` | `_DeviceNameSection` text field | `onChanged` | `controller.setDeviceName` |
| `lib/features/device/presentation/pages/add_device_page.dart` | `_SinkPositionSection` input | `onTap` | push `SinkPositionPage` → `controller.setSelectedSinkId(result)` |

## Device settings events

| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/device/presentation/pages/device_settings_page.dart` | AppBar “Save” button | `onPressed` | `_saveSettings()` |
| `lib/features/device/presentation/pages/device_settings_page.dart` | Delete device `OutlinedButton` | `onPressed` | `_showDeleteConfirmDialog(context)` (launches confirm -> `removeDeviceUseCase`) |

## Bluetooth tab events

| File | Widget | Event | Function |
| --- | --- | --- | --- |
| `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` | `_OtherDevicesHeader` refresh label | `onTap` | `controller.refresh()` (triggers BLE scan refresh) |
| `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` | `_PairedDevicesList` my-device tile | `onTap` | `_handleDeviceTap()` → `controller.connect()/disconnect()` |
| `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` | `_OtherDevicesBody` discovered tile | `onTap` | `_handleDeviceTap()` → `controller.connect(device.id)` |
