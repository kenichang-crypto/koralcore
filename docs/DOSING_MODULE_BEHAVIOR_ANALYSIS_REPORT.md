# Dosing 模組行為分析報告

**分析日期**：2025-02-11（更新：2025-02-11）  
**基準對照**：reef-b-app (Android / iOS)  
**模式**：靜態分析，不修改程式碼

---

## 1) 手動滴定 (Manual Dosing)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 入口 | Partial | 有兩條路徑，但 **ManualDosingPage 無導航入口** |
| Controller/UseCase | ✅ | ManualDosingController, SingleDoseImmediateUseCase |
| Store/State | Partial | Controller 內 _isSubmitting, _lastErrorCode；無全域 store |
| 可實際執行 | Partial | PumpHeadDetail 的 Manual 按鈕可觸發；DosingMain 的 Play 可觸發 |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/pages/manual_dosing_page.dart` | `ManualDosingPage`, `_ManualDosingView`, `_handleSubmit()` |
| 頁面 | `lib/features/doser/presentation/pages/pump_head_detail_page.dart` | 含 `PumpHeadDetailActionButtons` → `sendManualDose()` |
| 頁面 | `lib/features/doser/presentation/pages/dosing_main_page.dart` | `DosingMainPumpHeadList` → `onHeadPlay` → `toggleManualDrop()` |
| Controller | `lib/features/doser/presentation/controllers/manual_dosing_controller.dart` | `ManualDosingController.submit()` |
| Controller | `lib/features/doser/presentation/controllers/pump_head_detail_controller.dart` | `sendManualDose()` |
| Controller | `lib/features/doser/presentation/controllers/dosing_main_controller.dart` | `toggleManualDrop(int)` |
| UseCase | `lib/domain/usecases/doser/single_dose_immediate_usecase.dart` | `SingleDoseImmediateUseCase.execute()` |

### C. 是否可實際使用

**Partial**

- **DosingMainPage**：泵頭卡片上的 Play 按鈕 → `toggleManualDrop(index)` → 0x63/0x64 (開始/結束手動滴液) → ✅ 可執行
- **PumpHeadDetailPage**：Manual Dose 按鈕 → `sendManualDose()` → SingleDoseImmediateUseCase (0x6E 單次立即) → ✅ 可執行
- **ManualDosingPage**：頁面已實作，**無任何 Navigator.push 導航至此頁** → ❌ 無法從 UI 進入

### D. 與 reef-b-app 行為基準的差異

| 項目 | reef-b-app | koralcore |
|------|------------|-----------|
| 手動滴液方式 | DropMain: Play 按鈕 (0x63/0x64)；DropHeadMain: 單次滴液 (0x6E) | 對應存在 |
| ManualDosingActivity | reef-b-app **無** 此獨立 Activity | koralcore 有 ManualDosingPage 但**無導航入口**（孤立） |

### E. 缺失與最小修正建議

1. **ManualDosingPage 孤立**：若需與 reef-b-app 對齊，可考慮移除或隱藏；若 reef-b-app 有「選頭 + 輸入劑量」的進階手動頁，則需在 DosingMainPage 或 PumpHeadDetailPage 增加導航到 `ManualDosingPage` 的按鈕（例：`DosingMainEntryTile` 或 PumpHeadDetail 的額外按鈕）。

2. **diff patch 建議（若需增加 Manual 入口）**：

```diff
# dosing_main_page.dart - 在 layout_device 下方加入 DosingMainEntryTile
+ DosingMainEntryTile(
+   title: l10n.dosingEntryManual,
+   subtitle: l10n.dosingManualPageSubtitle,
+   enabled: session.isReady,
+   onTapWhenEnabled: () {
+     Navigator.of(context).push(
+       MaterialPageRoute(builder: (_) => const ManualDosingPage()),
+     );
+   },
+ ),
```

---

## 2) 排程滴定設定 (Schedule Dosing)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| Schedule List | ✅ | PumpHeadSchedulePage 顯示 entries |
| 新增排程按鈕 | ✅ | `dosingScheduleAddButton` → PumpHeadRecordSettingPage |
| Schedule 編輯頁 | ✅ | ScheduleEditPage (daily/custom) |
| Controller/UseCase | ✅ | PumpHeadScheduleController, ApplyScheduleUseCase, ReadScheduleUseCase |
| Store/State | ✅ | _entries, _remoteEntries, _localOverrides |
| Save/Persist | ✅ | applyScheduleUseCase → BLE 0x70/0x71/0x72/0x73/0x74 |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/pages/pump_head_schedule_page.dart` | `PumpHeadSchedulePage`, `_ScheduleEntryCard` |
| 頁面 | `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` | 新增排程 |
| 頁面 | `lib/features/doser/presentation/pages/schedule_edit_page.dart` | `ScheduleEditPage` |
| Controller | `lib/features/doser/presentation/controllers/pump_head_schedule_controller.dart` | `saveDailyAverageSchedule()`, `saveCustomWindowSchedule()`, `refresh()` |
| UseCase | `lib/domain/usecases/doser/apply_schedule_usecase.dart` | `ApplyScheduleUseCase.execute()` |
| UseCase | `lib/domain/usecases/doser/read_schedule.dart` | `ReadScheduleUseCase.execute()` |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊良好。reef-b-app DropHeadRecordSettingActivity / DropRecordDetailAdapter 對應 koralcore PumpHeadSchedulePage + ScheduleEditPage。

### E. 缺失

無顯著缺失。

---

## 3) 排程刪除 (Schedule Delete)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 刪除入口 | ✅ | _ScheduleEntryCard 有 IconButton delete |
| Delete flow | ✅ | 確認對話 → deleteLocalEntry → clearRecordOnDevice |
| Controller 方法 | ✅ | deleteLocalEntry(), clearRecordOnDevice() |
| Store/State 更新 | ✅ | _remoteEntries 移除後 _mergeEntries |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/pages/pump_head_schedule_page.dart` | `_confirmDeleteEntry()`, IconButton onDelete |
| Controller | `lib/features/doser/presentation/controllers/pump_head_schedule_controller.dart` | `deleteLocalEntry(String id)`, `clearRecordOnDevice()` |
| Repository | `lib/platform/contracts/dosing_repository.dart` | `clearRecord(deviceId, headNo)` |
| BLE | `lib/data/dosing/ble_dosing_repository_impl.dart` | `clearRecord()` → 0x79 |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊。reef-b-app 清除排程使用 0x79，koralcore 相同。

### E. 缺失

無。

---

## 4) 排程啟用/停用 (Enable/Disable Schedule)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 切換 | ✅ | _ScheduleEntryCard 有 Switch |
| Controller 方法 | ✅ | toggleLocalEnabled(id, enabled) |
| Store/State sync | Partial | 只更新 _localOverrides，**未送出 BLE** |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/pages/pump_head_schedule_page.dart` | Switch `onChanged: controller.toggleLocalEnabled(entry.id, v)` |
| Controller | `lib/features/doser/presentation/controllers/pump_head_schedule_controller.dart` | `toggleLocalEnabled(String id, bool enabled)` |

### C. 是否可實際使用

**Partial**：UI 可切換，狀態僅為 local override，未 sync 至裝置。

### D. 與 reef-b-app 行為基準的差異

| 項目 | reef-b-app | koralcore |
|------|------------|-----------|
| 啟用/停用 sync | 需確認是否透過重新 apply schedule 或專用 opcode | 僅 local 狀態，無 BLE 寫入 |

### E. 缺失與最小修正建議

- **問題**：`toggleLocalEnabled` 只改 `_localOverrides`，未呼叫 `applyScheduleUseCase` 或等效 BLE 寫入。
- **建議**：若 reef-b-app 有對應「寫入 enabled 至裝置」行為，需在 `toggleLocalEnabled` 內呼叫 apply 流程；否則需釐清 reef-b-app 的 enable/disable 是否僅為 local UI 狀態。

---

## 5) 校正 / Reset 流程 (Calibration / Reset)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 校正按鈕 | ✅ | PumpHeadCalibrationPage → 下一步 → PumpHeadAdjustPage |
| UI Reset 按鈕 | ✅ | DosingMainPage PopupMenu → Reset |
| Controller/UseCase | ✅ | PumpHeadAdjustController, DosingMainController.resetDevice() |
| 實際滴液流程 | ✅ | 0x75 開始校正、0x76 結束；Reset 0x7D |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/pages/pump_head_calibration_page.dart` | 校正 intro |
| 頁面 | `lib/features/doser/presentation/pages/pump_head_adjust_page.dart` | 實際校正 (0x75/0x76) |
| 頁面 | `lib/features/doser/presentation/pages/dosing_main_page.dart` | _showResetDialog → resetDevice |
| Controller | `lib/features/doser/presentation/controllers/pump_head_adjust_controller.dart` | `startCalibration()`, `endCalibration()` |
| Controller | `lib/features/doser/presentation/controllers/dosing_main_controller.dart` | `resetDevice()` |
| BLE | `lib/data/ble/dosing/dosing_command_builder.dart` | startAdjust(0x75), endAdjust(0x76) |
| BLE | `lib/data/dosing/ble_dosing_repository_impl.dart` | Reset 0x7D |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊。reef-b-app DropHeadAdjustActivity / DropHeadAdjustViewModel 對應 PumpHeadAdjustPage / PumpHeadAdjustController。

### E. 缺失

無。

---

## 6) 滴定儀頭控制 (Pump Head Control)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 選擇 pump head | ✅ | DosingMain 泵頭列表；ManualDosing 下拉；PumpHeadDetail 以 headId 區分 |
| Controller/UseCase | ✅ | DosingMainController, PumpHeadDetailController, ManualDosingController |
| Store/State | ✅ | DosingState, PumpHead, session.pumpHeads |
| 單頭/多頭指令 | ✅ | toggleManualDrop(index), sendManualDose(headId), SingleDoseImmediate(pumpId) |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/widgets/dosing_main_pump_head_list.dart` | 泵頭列表 |
| 頁面 | `lib/features/doser/presentation/pages/manual_dosing_page.dart` | DropdownButtonFormField headIds |
| Controller | `lib/features/doser/presentation/controllers/dosing_main_controller.dart` | toggleManualDrop(pumpHeadIndex) |
| Controller | `lib/features/doser/presentation/controllers/pump_head_detail_controller.dart` | headId, sendManualDose() |
| Domain | `lib/domain/doser_dosing/pump_head.dart` | PumpHead |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊良好。

### E. 缺失

無。

---

## 7) 滴定歷史紀錄/狀態 (Dosing History/Status)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| UI 歷史/狀態 | ✅ | PumpHeadDetailTodayDoseCard (今日總量)；PumpHeadDetailCalibrationHistoryTile |
| Store/State | ✅ | TodayDoseSummary, PumpHead.todayDispensedMl, 校正紀錄 |

### B. 對應檔案與位置

| 類型 | 路徑 | 類別/方法 |
|------|------|-----------|
| 頁面 | `lib/features/doser/presentation/widgets/pump_head_detail_today_dose_card.dart` | 今日總量 (total/scheduled/manual) |
| 頁面 | `lib/features/doser/presentation/widgets/pump_head_detail_calibration_history_tile.dart` | 校正歷史 |
| UseCase | `lib/domain/usecases/doser/read_today_total.dart` | ReadTodayTotalUseCase |
| Domain | `lib/domain/doser_dosing/` | TodayDoseSummary, PumpHeadAdjustHistory |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊。reef-b-app tvTodayRecordDropVolume、校正歷史 對應 koralcore 今日劑量與校正歷史。

### E. 缺失

無。

---

## 8) BLE 指令傳送 (真正觸發 BLE Write)

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| Controller/UseCase dispatch | ✅ | 多數經 UseCase → bleAdapter.writeBytes |
| 成功/失敗回饋 | ✅ | AppError, lastErrorCode, SnackBar |

### B. 對應檔案與位置

| 功能 | BLE Opcode | 發送位置 |
|------|------------|----------|
| 手動滴液 開始/結束 | 0x63/0x64 | DosingMainController.toggleManualDrop → DosingCommandBuilder → bleAdapter |
| 單次立即滴液 | 0x6E | SingleDoseImmediateUseCase.execute → ImmediateSingleDoseEncoder → bleAdapter |
| 排程 apply | 0x70/71/72/73/74 | ApplyScheduleUseCase → ScheduleSender |
| 清除排程 | 0x79 | DosingRepository.clearRecord → DosingCommandBuilder.clearRecord |
| 校正 開始/結束 | 0x75/0x76 | PumpHeadAdjustController → commandBuilder.startAdjust/endAdjust |
| Reset | 0x7D | DosingMainController.resetDevice → dosingRepository |
| 今日總量 | 0x7A/0x7E | ReadTodayTotalUseCase → TodayTotalsDataSource |

### C. 是否可實際使用

**Yes**

### D. 與 reef-b-app 行為基準的差異

對齊。opcode 與 reef-b-app CommandManager 一致。

### E. 缺失

無。

---

## 9) 欄位驗證與錯誤 Handling

### A. 行為存在性

| 檢查項 | 狀態 | 說明 |
|-------|------|------|
| 表單驗證 | Partial | ManualDosingPage 有 dose 驗證；ScheduleEditPage 有欄位 |
| 錯誤提示 UI | ✅ | showErrorSnackBar、describeAppError；**dosing_main_page 已改用 l10n** |

### B. 對應檔案與位置

| 類型 | 路徑 | 說明 |
|------|------|------|
| 驗證 | `manual_dosing_page.dart` | `_parseDose()`, `dose <= 0` → `_doseError` |
| 驗證 | `schedule_edit_page.dart` | 數值欄位、時間範圍 |
| 錯誤 | `manual_dosing_page.dart` | controller.lastErrorCode → describeAppError |
| 錯誤 | `dosing_main_page.dart` | `_showErrorToast` → showErrorSnackBar；Delete/Reset 對話 → l10n |

### C. 是否可實際使用

**Yes**（dosing_main_page L10n 已補齊）

### D. 與 reef-b-app 行為基準的差異

| 項目 | reef-b-app | koralcore |
|------|------------|-----------|
| 劑量驗證 | 有 | ManualDosingPage 有 |
| 錯誤訊息 | strings.xml | ✅ 已用 l10n（dosingDeleteDeviceConfirm, dosingResetDeviceConfirm, deviceNotConnected 等） |

### E. 缺失與最小修正建議

- **剩餘**：`manual_dosing_page.dart` 可考慮統一使用 `showErrorSnackBar` / `showSuccessSnackBar`（目前為 SnackBar + describeAppError）。

---

## 總表：行為對照

| 項目 | UI | Controller | UseCase | Store/State | 可執行 | reef-b-app 對齊 |
|------|----|-----------|---------|-------------|--------|----------------|
| 1. 手動滴定 | Partial (ManualDosing 無入口，reef-b-app 亦無) | ✅ | ✅ | Partial | Partial | ✅ |
| 2. 排程設定 | ✅ | ✅ | ✅ | ✅ | Yes | ✅ |
| 3. 排程刪除 | ✅ | ✅ | ✅ | ✅ | Yes | ✅ |
| 4. 啟用/停用 | ✅ | ✅ | - | Partial (local only) | Partial | ✅ |
| 5. 校正/Reset | ✅ | ✅ | - | ✅ | Yes | ✅ |
| 6. 泵頭控制 | ✅ | ✅ | ✅ | ✅ | Yes | ✅ |
| 7. 歷史/狀態 | ✅ | - | ✅ | ✅ | Yes | ✅ |
| 8. BLE 指令 | - | ✅ | ✅ | - | Yes | ✅ |
| 9. 驗證/錯誤 | Partial | ✅ | - | - | Yes | ✅ |

---

## 結論與優先修正建議

### reef-b-app 對照結論 (2025-02-11)

1. **ManualDosingPage 入口**：reef-b-app Android `activity_drop_main.xml` 僅有 `layout_device` + `rv_drop_head`（泵頭列表），**無**獨立 Manual 入口。手動滴液透過泵頭卡片的 Play 按鈕 (0x63/0x64) 執行。koralcore 行為已對齊，**不需**新增 ManualDosingPage 入口。

2. **排程啟用/停用**：reef-b-app `DropHeadMode.runDay` 為星期執行日，於 apply schedule 時一併送出。**無**獨立的 enable/disable toggle 寫入 BLE。koralcore `toggleLocalEnabled` 僅更新 local 為合理設計。

3. **L10n 已完成**：Delete/Reset 對話框與錯誤字串已改為使用 l10n，對齊 reef-b-app 多語言（en, zh, zh_Hant, ja, ko, es, de, fr, vi, th, ru, pt, id, ar）。

### 中優先

4. **統一錯誤提示**：manual_dosing_page 等頁面改用 `showErrorSnackBar` / `showSuccessSnackBar`。

### 低優先

5. **ManualDosingPage 表單**：已含 dose 驗證與確認流程，可微調 UI/UX。
