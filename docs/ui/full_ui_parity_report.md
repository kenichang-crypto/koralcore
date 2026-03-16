# Full UI Parity Report

## Overview
This report captures the Flutter UI implementation relative to the Android `reef-b-app` reference. The comparison covers screens, widgets, interactions, and iconography. Missing gaps and follow-up recommendations are highlighted at the end.

## 1. Pages
| Module | Screen (Flutter) | Android equivalent | Status |
| --- | --- | --- | --- |
| LED | `LedSceneListPage` | `LedSceneActivity` | MATCH |
| LED | `LedScheduleListPage` | `LedSceneListActivity` (schedule view) | MATCH |
| LED | `LedRecordTimeSettingPage` | `LedRecordTimeSettingActivity` | MATCH (chart placeholder filled) |
| LED | `LedSceneDeletePage` | `LedSceneDeleteActivity` | MATCH |
| Dosing | `DosingMainPage` | `DropMainActivity` | MATCH |
| Dosing | `PumpHeadDetailPage` | `DropHeadMainActivity` | MATCH |
| Device / Bluetooth | `DeviceTabPage`, `BluetoothTabPage` | `DeviceFragment`, `BluetoothFragment` | MATCH |
| Settings/Dialogs | Add device / sink / settings pages | Corresponding Android activities/fragments | MATCH |

## 2. Widgets
| Widget | Purpose | Android equivalent | Status |
| --- | --- | --- | --- |
| `LedSpectrumChart` | Line chart for spectrum preview | `SpectrumUtil` chart view in Android | MATCH |
| `SceneCard`, `SceneIconPicker` | Scene list + icon selection | RecyclerView adapters in `LedSceneActivity` | MATCH |
| `PumpHeadCard` & `PumpHeadAdjustList` | Pump head tiles, adjust history list | `DropHeadMain` cards + `DropHeadAdjustList` | MATCH |
| `BleGuardBanner`, `ReefBlockingOverlay` | BLE gating overlays | Platform Toast/dialog handling in Android | MATCH |
| `CommonIconHelper` | Icons referencing `ic_*.svg` | Android `ic_*.xml` drawables | MATCH |

## 3. Interactions
| Screen | UI action | Controller / use case | BLE command | Status |
| --- | --- | --- | --- | --- |
| LED Scene apply | Apply preset/custom scene | `LedSceneListController.applyScene()` → `ApplySceneUseCase` | `0x28` / `0x29` | MATCH |
| LED Record preview | Toggle preview | `LedRecordController.togglePreview()` | `0x2A` | MATCH |
| LED Record save/edit | Save record | `LedRecordController.saveRecord()` → `BleLedRepositoryImpl.setRecord()` | `0x27` | MATCH |
| LED Record delete | Delete record | `LedRecordController.deleteRecord()` | `0x2F` | MATCH |
| Scene delete | Delete scene + clear records | `LedSceneDeleteController.deleteScene()` → `ClearLedSceneUseCase` | `0x30` | MATCH |
| Schedule save/apply | Save schedule & playback | `LedScheduleEditController` / `LedSceneEditController` → `SaveLedSceneUseCase` | `0x30`, `0x27`, `0x2B` | MATCH |
| Manual drop | Start/stop manual drop | `DosingMainController.toggleManualDrop()` | `0x63` / `0x64` | MATCH |
| Pump head settings | Save rotating speed | `PumpHeadSettingsController._updateRotatingSpeed()` | `0x62` | MATCH |
| Calibration | Start/complete | `PumpHeadAdjustController` | `0x75` / `0x76` | MATCH |
| Delay time | Save delay | `DropSettingController` | `0x61` | MATCH |

## 4. Iconography
All Flutter icons are loaded from `assets/icons/ic_*.svg` either through `CommonIconHelper` or direct `SvgPicture.asset`. No `Icons.*` or custom icons outside the mirrored Android set are used. Status: MATCH for all UI elements.

## 5. Gaps & Recommendations
- **Record Edit Spectrum Chart**: Previously stubbed, now wired to `LedSpectrumChart.fromChannelMap(controller.channelLevels)` so parity is restored. No outstanding gap remains.  
- **Scene Delete BLE Logging**: Added logging (`logger.info`) to `BleLedRepositoryImpl.clearScene()` to trace `0x30` commands.  
- **Suggestion**: Continue monitoring BLE command queue timings when schedules save multiple records (Android processes sequentially; Flutter already serializes, but keep recoil logging if issues emerge).  
- **Next Step**: Maintain this report whenever new UI screens are added or icons change to ensure parity remains consistent.

## Summary Statistics
- Screens audited: 8  
- Widgets mapped: 5 (Major reusable components)  
- Interaction parity: 9 key actions  
- Icon parity: 100% Android-derived assets
