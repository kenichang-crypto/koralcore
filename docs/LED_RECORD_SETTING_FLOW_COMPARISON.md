# LED Record Setting Flow Comparison

## 一、用戶操作流程對照

### reef-b-app 流程

1. **LED 主頁點擊 `btnRecordMore`**
   - 位置：`LedMainActivity.kt` line 190-198
   - 邏輯：`viewModel.clickBtnRecordMore { ... }`
   - 檢查：`viewModel.isRecordEmpty()`
   - 如果為空：導航到 `LedRecordSettingActivity`
   - 如果不為空：導航到 `LedRecordActivity`

2. **LedRecordSettingActivity 設定參數**
   - 起始強度（`initStrength`）：默認 50%
   - 日出時間（`sunriseHour`, `sunriseMinute`）：默認 6:00
   - 日落時間（`sunsetHour`, `sunsetMinute`）：默認 18:00
   - 緩啟動（`slowStart`）：默認 30 分鐘
   - 月光（`moonlight`）：默認 0%

3. **點擊保存按鈕**
   - 位置：`LedRecordSettingActivity.kt` line 55-59
   - 調用：`viewModel.saveLedRecord()`
   - 驗證：日出時間必須早於日落時間

4. **保存流程**
   - `saveLedRecord()` → `initLedRecord()`
   - `initLedRecord()` 創建 5 個 SET_RECORD 命令：
     1. 午夜（0:00）：所有通道 0，月光 `moonlight`
     2. 日出開始（`sunriseHour:sunriseMinute`）：所有通道 0，月光 `moonlight`
     3. 日出結束（`sunriseHour:sunriseMinute + slowStart`）：所有通道 `initStrength`，月光 0
     4. 日落開始（`sunsetHour:sunsetMinute - slowStart`）：所有通道 `initStrength`，月光 0
     5. 日落結束（`sunsetHour:sunsetMinute`）：所有通道 0，月光 `moonlight`
   - 逐個發送命令，每個命令成功後添加到 `LedInformation.records`
   - 所有命令完成後，如果當前模式不是 `CUSTOM_SCENE` 或 `PRESET_SCENE`，則發送 `START_RECORD` 命令
   - 成功後導航到 `LedRecordActivity`

### koralcore 流程

1. **LED 主頁點擊 `btnRecordMore`**
   - 位置：`led_main_page.dart` line 1154-1171
   - 邏輯：檢查 `controller.hasRecords`
   - 如果為空：導航到 `LedRecordSettingPage`
   - 如果不為空：導航到 `LedRecordPage`

2. **LedRecordSettingPage 設定參數**
   - 起始強度（`initStrength`）：默認 50%
   - 日出時間（`sunriseHour`, `sunriseMinute`）：默認 6:00
   - 日落時間（`sunsetHour`, `sunsetMinute`）：默認 18:00
   - 緩啟動（`slowStart`）：默認 30 分鐘
   - 月光（`moonlight`）：默認 0%

3. **點擊保存按鈕**
   - 位置：`led_record_setting_page.dart` line 435-463
   - 調用：`controller.saveLedRecord()`
   - 驗證：日出時間必須早於日落時間

4. **保存流程**
   - `saveLedRecord()` 驗證時間
   - **問題**：只調用 `startLedRecordUseCase.execute()`，**沒有發送 SET_RECORD 命令**
   - 成功後導航到 `LedRecordPage`

## 二、數據流對照

### reef-b-app 數據流

```
用戶點擊保存
  ↓
saveLedRecord() 驗證時間
  ↓
initLedRecord() 創建 5 個 SET_RECORD 命令
  ↓
發送第一個命令 → BLE → 設備
  ↓
收到 SUCCESS ACK
  ↓
解析命令數據 → 創建 LedRecord → 添加到 LedInformation.records
  ↓
發送下一個命令（重複直到所有命令完成）
  ↓
所有命令完成
  ↓
檢查當前模式
  ↓
如果不是 CUSTOM_SCENE 或 PRESET_SCENE → 發送 START_RECORD 命令
  ↓
收到 SUCCESS ACK → 導航到 LedRecordActivity
```

### koralcore 數據流

```
用戶點擊保存
  ↓
saveLedRecord() 驗證時間
  ↓
計算時間點（但未使用）
  ↓
調用 startLedRecordUseCase.execute()
  ↓
導航到 LedRecordPage
```

## 三、問題分析

### 主要問題

1. **缺少 SET_RECORD 命令發送**
   - `reef-b-app` 會發送 5 個 SET_RECORD 命令來設定記錄點
   - `koralcore` 只調用 `startLedRecordUseCase.execute()`，沒有發送 SET_RECORD 命令
   - 這導致設備沒有實際的記錄數據

2. **缺少記錄數據添加到本地狀態**
   - `reef-b-app` 在每個 SET_RECORD 成功後，會將記錄添加到 `LedInformation.records`
   - `koralcore` 沒有這個邏輯

3. **缺少模式檢查和 START_RECORD 命令**
   - `reef-b-app` 在所有 SET_RECORD 完成後，會檢查當前模式
   - 如果不是 CUSTOM_SCENE 或 PRESET_SCENE，則發送 START_RECORD 命令
   - `koralcore` 沒有這個邏輯

### 次要問題

1. **錯誤處理**
   - `reef-b-app` 在 SET_RECORD 失敗時會設置 `_initRecordLiveData.postValue(false)`
   - `koralcore` 的錯誤處理可能不完整

2. **BLE 斷開處理**
   - `reef-b-app` 在 BLE 斷開時會關閉頁面（`finish()`）
   - `koralcore` 應該也有類似的處理

## 四、需要修復的內容

1. **實現 SET_RECORD 命令發送邏輯**
   - 在 `LedRecordSettingController.saveLedRecord()` 中實現發送 5 個 SET_RECORD 命令
   - 每個命令成功後，將記錄添加到本地狀態

2. **實現記錄數據添加到本地狀態**
   - 在每個 SET_RECORD 成功後，調用 `ledRecordRepository` 添加記錄

3. **實現模式檢查和 START_RECORD 命令**
   - 在所有 SET_RECORD 完成後，檢查當前 LED 模式
   - 如果不是 CUSTOM_SCENE 或 PRESET_SCENE，則發送 START_RECORD 命令

4. **實現 BLE 斷開處理**
   - 在 `LedRecordSettingPage` 中監聽 BLE 連接狀態
   - 如果斷開，則關閉頁面

5. **實現錯誤處理**
   - 在 SET_RECORD 失敗時顯示錯誤消息
   - 在 START_RECORD 失敗時顯示錯誤消息

## 五、對照評分

- **用戶流程**: 80%（缺少實際的 SET_RECORD 命令發送）
- **數據流**: 40%（缺少 SET_RECORD 命令和記錄數據添加）
- **錯誤處理**: 60%（基本錯誤處理存在，但缺少詳細處理）
- **BLE 斷開處理**: 待確認

**總體評分**: 60%

## 六、修復優先級

1. **高優先級**：實現 SET_RECORD 命令發送邏輯
2. **高優先級**：實現記錄數據添加到本地狀態
3. **中優先級**：實現模式檢查和 START_RECORD 命令
4. **中優先級**：實現 BLE 斷開處理
5. **低優先級**：完善錯誤處理

