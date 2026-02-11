# Ready Gate Implementation Report

## 依據 AUDIT-4 與 AUDIT-5 實作「ready 才可送 command」一致性對齊

**日期**: 2026-02-11  
**依據**: `docs/UI_FINAL_AUDIT_REPORT.md` AUDIT-4、AUDIT-5

---

## 1. 變更檔案清單

| 檔案 | 變更類型 |
|------|----------|
| `lib/features/led/presentation/pages/led_scene_list_page.dart` | isConnected→isReady UI gate + _SceneCard.isReady |
| `lib/features/led/presentation/controllers/led_scene_list_controller.dart` | startRecord/togglePreview 加入 session.isReady 檢查 |
| `lib/features/led/presentation/pages/led_schedule_edit_page.dart` | Save 按鈕改為 isReady gate + _handleSave 內檢查 |
| `lib/features/doser/presentation/pages/schedule_edit_page.dart` | Save 按鈕改為 isReady gate |
| `lib/features/doser/presentation/pages/manual_dosing_page.dart` | Submit 按鈕改為 isReady gate |
| `lib/features/doser/presentation/pages/pump_head_schedule_page.dart` | Add/Edit 按鈕與 ScheduleEntryCard 改為 isReady gate |
| `lib/features/doser/presentation/pages/dosing_main_page.dart` | onHeadPlay 改為 session.isReady ? callback : null、Reset 選單 gate、PopupMenu session |
| `lib/features/doser/presentation/controllers/dosing_main_controller.dart` | resetDevice() 加入 session.isReady 檢查 |
| `lib/features/doser/presentation/controllers/pump_head_adjust_controller.dart` | completeCalibration() 加入 session.isReady 檢查 |
| `lib/features/doser/presentation/pages/pump_head_adjust_page.dart` | 傳入 isReady 給 BottomButtons/RotatingSpeed/DropVolume |
| `lib/features/doser/presentation/pages/pump_head_detail_page.dart` | PopupMenu Manual/Timed ListTile 加入 enabled: isReady |
| `lib/features/doser/presentation/pages/drop_setting_page.dart` | Delay Time 按鈕、Save 按鈕改為 session.isReady gate |
| `lib/features/doser/presentation/pages/pump_head_settings_page.dart` | Rotating Speed 按鈕、Save 按鈕改為 session.isReady gate |
| `lib/features/device/presentation/pages/device_settings_page.dart` | Save 按鈕改為 session.isReady + _saveSettings 內檢查 |

---

## 2. 每個 Handler 的 Gating 條件

| Handler / 按鈕 | Gating 條件 |
|----------------|-------------|
| **LED Control** | |
| Slider (Channel) | `session.isReady && !controller.isApplying` |
| Apply 按鈕 | `session.isReady && !controller.isApplying && controller.hasChanges` |
| applyChanges() | `session.isReady` (controller 內) |
| **LED Scene List** | |
| Edit / FAB Add | `session.isReady && !controller.isBusy` |
| Apply Scene | `session.isReady && !controller.isBusy && scene.isEnabled && !scene.isActive` |
| onTap (Edit scene) | `session.isReady && !controller.isBusy && !scene.isPreset` |
| Favorite 按鈕 | `session.isReady && !controller.isBusy` |
| applyScene() | `session.isReady` (controller 內) |
| startRecord() | `session.isReady` (controller 內) |
| togglePreview() | `session.isReady` (controller 內) |
| **LED Schedule Edit** | |
| Save 按鈕 | `session.isReady && !_isSaving` |
| _handleSave() | `session.isReady` (內層檢查) |
| **LED Schedule List** | (若有用到 Save，已對齊) |
| **Dosing Schedule** | |
| schedule_edit Save | `session.isReady && !_isSaving` |
| pump_head_schedule Add/Edit | `session.isReady` |
| ScheduleEntryCard onTap | `session.isReady` (傳入為 isConnected 參數) |
| saveDailyAverageSchedule / saveCustomWindowSchedule | `session.isReady` (controller 內) |
| **Manual Dosing** | |
| Submit 按鈕 | `session.isReady && !controller.isSubmitting` |
| submit() | `session.isReady` (controller 內) |
| **Pump Head Detail** | |
| PopupMenu Manual Dose | `enabled: session.isReady` |
| PopupMenu Timed Dose | `enabled: session.isReady` |
| sendManualDose() | `session.isReady` (controller 內) |
| scheduleTimedDose() | `session.isReady` (controller 內) |
| **Pump Head Adjust** | |
| Start Calibration | `session.isReady` (傳入 BottomButtons) |
| Complete Calibration | `session.isReady` (傳入 BottomButtons) |
| startCalibration() | `session.isReady` (controller 內) |
| completeCalibration() | `session.isReady` (controller 內) |
| **Dosing Main** | |
| onHeadPlay (泵頭 Play) | `session.isReady ? callback : null` |
| Reset 選單項 | `controller.isConnected && session.isReady` |
| toggleManualDrop() | `session.isReady` (controller 內) |
| resetDevice() | `session.isReady` (controller 內) |
| **Drop Setting** | |
| Delay Time 按鈕 | `!session.isReady \|\| controller.isSaving` → disabled |
| Save 按鈕 | `!session.isReady \|\| controller.isSaving` → disabled |
| save() _updateDelayTime BLE path | `session.isReady` (controller 內) |
| **Pump Head Settings** | |
| Rotating Speed 按鈕 | `!session.isReady \|\| controller.isSaving` → disabled |
| Save 按鈕 | `!session.isReady \|\| controller.isSaving` → disabled |
| save() _updateRotatingSpeed BLE path | `session.isReady` (controller 內) |
| **Device Settings** | |
| Save 按鈕 | `!session.isReady \|\| _isLoading` → disabled |
| _saveSettings() | `session.isReady` (內層檢查) |

---

## 3. 風險已消除對照表（對應 AUDIT-5）

| AUDIT-5 項目 | 修正前 | 修正後 |
|--------------|--------|--------|
| `led_control_page.dart` Slider/Apply | isConnected | **session.isReady** |
| `led_control_controller.dart` applyChanges() | (已有 isReady) | 維持 |
| `led_scene_list_page.dart` onApply | isConnected | **session.isReady** |
| `led_scene_list_controller.dart` applyScene() | (已有 isReady) | 維持 |
| `led_scene_list_controller.dart` startRecord/togglePreview | 無 ready 檢查 | **加入 session.isReady** |
| `schedule_edit_page.dart` Save | isConnected | **session.isReady** |
| `pump_head_schedule_controller.dart` save*Schedule() | (已有 isReady) | 維持 |
| `manual_dosing_page.dart` Submit | isConnected | **session.isReady** |
| `manual_dosing_controller.dart` submit() | (已有 isReady) | 維持 |
| `pump_head_detail_controller.dart` sendManualDose/scheduleTimedDose | (已有 isReady) | 維持 |
| `pump_head_detail_page.dart` PopupMenu | 無 gate | **enabled: session.isReady** |
| `pump_head_adjust_controller.dart` start/completeCalibration | (start 已有) complete 補上 | **completeCalibration 加入 isReady** |
| `pump_head_adjust_page.dart` 按鈕 | isConnected | **isReady** |
| `dosing_main_controller.dart` toggleManualDrop/resetDevice | (toggle 已有) reset 補上 | **resetDevice 加入 isReady** |
| `dosing_main_page.dart` onHeadPlay | 無 UI gate | **session.isReady ? callback : null** |
| `dosing_main_page.dart` Reset 選單 | isConnected only | **isConnected && session.isReady** |
| `drop_setting_controller.dart` _updateDelayTime | (已有 isReady) | 維持 |
| `drop_setting_page.dart` 按鈕 | controller.isConnected | **session.isReady** |
| `pump_head_settings_controller.dart` _updateRotatingSpeed | (已有 isReady) | 維持 |
| `pump_head_settings_page.dart` 按鈕 | controller.isConnected | **session.isReady** |
| `led_schedule_edit_page.dart` Save | isConnected | **session.isReady** |
| `device_settings_page.dart` Save | isBleConnected | **session.isReady** |

---

## 4. 行為摘要

- **reconnect → initialize → ready 期間**：所有會送出 BLE/Repository command 的 UI 一律以 `session.isReady` 作 gate，按鈕 disabled 或 callback 為 null。
- **Ready 來源**：`CurrentDeviceSession.isReady`，由 `InitializeDeviceUseCase` 在連線後完成 init 時設為 true。
- **視覺**：不做調整，僅改 gating 邏輯。

---

## 5. Flutter analyze 與 flutter test

請在本機執行：

```bash
flutter analyze
flutter test
```

並回報結果。
