# LED Quick Schedule 對照分析：reef-b-app vs koralcore

## 一、reef-b-app 的 Quick Schedule 定義

**Quick Schedule** 即 **LedRecordSetting**（LED 排程初始設定頁），用於「無排程時」快速建立每日程式。

### 入口 1：無排程時進入

| 平台 | 觸發條件 | 導向頁面 |
|------|----------|----------|
| **Android** | LedMain `clickBtnRecordMore` 且 `isRecordEmpty()` | LedRecordSettingActivity |
| **iOS** | `showScheduleDetail()` 且 `ledDevice.details.isEmpty` | LedRecordSettingViewController |

### 入口 2：排程列表右上角「清除」按鈕

| 平台 | 觸發位置 | 行為 |
|------|----------|------|
| **Android** | LedRecordActivity toolbar `btnIcon` | 點擊 → 確認對話 → `clearRecord()` → 成功後 `startActivity(LedRecordSettingActivity)` + `finish()` |
| **iOS** | LEDScheduleDetailViewController `resetBarButtonItem` (右 Bar) | 點擊 → 確認對話 → `resetSchedule()` → `clearLEDSchedules()` → 成功後 `clearAllScheduleCompletion` → 導回 LedRecordSettingViewController |

### 對應程式碼位置（reef-b-app，僅供對照）

| 項目 | Android | iOS |
|------|---------|-----|
| Quick Schedule 頁 | LedRecordSettingActivity | LedRecordSettingViewController |
| 無排程導航 | LedMainActivity L191-196: `isRecordEmpty()` → LedRecordSettingActivity | LEDViewController L430-434: showInitLEDScheduleDetailEvent → LedRecordSettingViewController |
| 有排程導航 | LedMainActivity L194-195: LedRecordActivity | LEDViewController L436-442: showLEDScheduleDetailEvent → LEDScheduleDetailViewController |
| 清除按鈕 | LedRecordActivity L111: `binding.toolbarLedRecord.btnIcon` | LEDScheduleDetailViewController L201: `navigationItem.rightBarButtonItem = resetBarButtonItem` |
| 清除邏輯 | LedRecordViewModel.clearRecord() → bleClearRecord (0x30) | LEDScheduleDetailViewModel.resetSchedule() → peripheral.clearLEDSchedules() |
| 清除成功後 | LedRecordActivity L205-209: clearRecordLiveData → startActivity(LedRecordSettingActivity) + finish() | LEDScheduleDetailViewController L321: clearAllScheduleEvent → clearAllScheduleCompletion → showInitLEDScheduleDetail() |

---

## 二、Quick Schedule 頁面內容（reef-b-app）

| 組件 | Android LedRecordSettingActivity | iOS LedRecordSettingViewController |
|------|----------------------------------|-------------------------------------|
| 初始強度 | `sl_strength` (Slider 0–100%), `db_strength` (半圓儀表) | initStrengthSlider, initStrengthProgressView |
| 日出時間 | `btn_sunrise` | sunriseButton |
| 日落時間 | `btn_sunset` | sunsetButton |
| 緩啟動 | `sl_slow_start` | - |
| 月光 | `sl_moon_light` | - |
| 儲存 | toolbar btn_right (Save) | saveButton |
| 邏輯 | initLedRecord() 依 sunrise/sunset 產生多個 LedRecord，透過 BLE 0x41 寫入 | LedRecordSettingViewModel 產生 LightScheduleDetail 並 updateLEDSchedule/startLEDSchedule |

---

## 三、koralcore 現況

### 入口 1：無排程導航 ✅

- LedMainRecordChartSection：`!controller.hasRecords` → LedRecordSettingPage
- 與 reef-b-app 一致

### 入口 2：LedRecordPage 清除按鈕 ❌

| 項目 | reef-b-app | koralcore |
|------|------------|-----------|
| Toolbar 清除按鈕 | btnIcon（右上） | **無**：註解為 "REMOVED: Icons.settings" |
| 清除後導航 | LedRecordSettingActivity | LedRecordController 有 `clearRecords()` 與 `LedRecordEvent.clearSuccess`，但 LedRecordPage 未處理 |

### Quick Schedule 頁面（LedRecordSettingPage）

| 項目 | reef-b-app | koralcore |
|------|------------|-----------|
| 初始強度區 | ✅ | ✅ `_InitStrengthSection` |
| 日出／日落 | ✅ | ✅ `_SunriseSunsetSection` |
| 緩啟動／月光 | ✅ | ✅ `_SlowStartMoonLightSection` |
| 儲存／執行 | 有邏輯 | 按鈕 `onPressed: null`（Correction Mode） |
| BLE 寫入 | initLedRecord → 0x41 | 需確認是否已接上 UseCase |

---

## 四、koralcore 待補項目（對照 reef-b-app）

1. **LedRecordPage Toolbar 清除按鈕**
   - 位置：toolbar 右側（對應 reef-b-app `btnIcon`）
   - 行為：點擊 → 確認對話「是否要清空排程？」→ 呼叫 `controller.clearRecords()`
   - 成功後：`Navigator.pushReplacement(LedRecordSettingPage)` 或 `pop` 後 `push`

2. **LedRecordPage 對 clearSuccess 的處理**
   - 監聽 `LedRecordEvent.clearSuccess`
   - 導航至 LedRecordSettingPage（replace 當前 LedRecordPage）

3. **LedRecordSettingPage 業務邏輯**
   - 接上 init strength、sunrise、sunset 等 UseCase
   - 儲存時透過 BLE 寫入排程（對應 reef-b-app 的 initLedRecord）

---

## 五、建議修正步驟

1. 在 LedRecordPage `_ToolbarTwoAction` 右側加入清除按鈕（對應 reef-b-app btnIcon）
2. 點擊時顯示 `dialog_led_clear_record_content` 確認對話
3. 確認後呼叫 `controller.clearRecords()`
4. 處理 `LedRecordEvent.clearSuccess`：`Navigator.pushReplacement(MaterialPageRoute(builder: (_) => LedRecordSettingPage()))`
5. 確認 LedRecordSettingPage 有 ChangeNotifierProvider 並接上 LedRecordSettingController／相關 UseCase
