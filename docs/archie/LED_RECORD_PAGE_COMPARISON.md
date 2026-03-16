# LED Record Page 對照文檔

## 一、頁面進入時的資訊流

### 1.1 reef-b-app 流程

1. **onCreate()**:
   - 設置 View、Listener、Observer
   - 初始化 RecyclerView 和 LineChart

2. **onResume()**:
   - 調用 `viewModel.getNowRecords()`
   - 從 `ledInformation.getRecords()` 獲取記錄列表

3. **recordsLiveData.observe()**:
   - 更新 RecyclerView adapter
   - 調用 `drawChart(list)` 繪製圖表
   - 設置 `tv_clock` 為當前時間 `getNowTimeToString("HH : mm")`
   - 在圖表上高亮當前時間 `lineChart.highlightValue(getNowTotalMinute().toFloat(), 8, false)`

### 1.2 koralcore 流程

1. **initialize()**:
   - 訂閱 `observeLedRecordStateUseCase`
   - 調用 `readLedRecordStateUseCase` 獲取初始狀態
   - 設置 `_selectedMinutes` 為當前時間

2. **_handleState()**:
   - 更新 `_state`
   - 如果正在預覽，設置 `_selectedRecordId` 和 `_selectedMinutes` 為預覽的記錄
   - 否則選擇第一個記錄

**對照狀態**: ⚠️ 部分對照
- ✅ 訂閱狀態流
- ✅ 獲取初始記錄
- ❌ 未設置時鐘顯示為當前時間
- ❌ 未在圖表上高亮當前時間

## 二、組件對照

### 2.1 Toolbar

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 返回按鈕 | `btn_back` (ic_back) | `IconButton` (Icons.arrow_back) | ⚠️ 圖標需對照 |
| 標題 | `toolbar_title` (activity_led_record_title) | `ReefAppBar.title` | ✅ |
| 清除按鈕 | `btn_icon` (refresh icon) | `IconButton` (Icons.delete_forever) | ⚠️ 圖標需對照 |
| 刷新按鈕 | 無 | `IconButton` (Icons.refresh) | ❌ koralcore 獨有 |

### 2.2 圖表區域 (layout_chart)

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 容器 | `layout_chart` (white, radius, padding 16/24) | `Container` (white, radius, padding 16/24) | ✅ |
| 時鐘顯示 | `tv_clock` (headline, text_aaaa, 居中) | `Text` (headline, textSecondary, 居中) | ⚠️ 顏色需對照 |
| 圖表 | `line_chart` (242dp 高, margin 8dp) | `LedRecordLineChart` (242dp 高, padding 8dp) | ✅ |
| 按鈕組 | `layout_btn` (5個按鈕, marginTop 16dp) | `Row` (5個按鈕, marginTop 16dp) | ✅ |

### 2.3 圖表按鈕

| 按鈕 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 添加 (btn_add) | `ic_add_black` (24×24dp, marginEnd 12dp) | `IconButton` (Icons.add, 24dp) | ⚠️ 圖標需對照，功能未實現 |
| 減去 (btn_minus) | `ic_minus` (24×24dp, marginStart/End 12dp) | `IconButton` (Icons.remove, 24dp) | ⚠️ 圖標需對照，功能未實現 |
| 上一個 (btn_prev) | `ic_back` (24×24dp, marginStart/End 12dp) | `IconButton` (Icons.chevron_left, 24dp) | ⚠️ 圖標需對照 |
| 下一個 (btn_next) | `ic_next` (24×24dp, marginStart/End 12dp) | `IconButton` (Icons.chevron_right, 24dp) | ⚠️ 圖標需對照 |
| 預覽 (btn_preview) | `ic_preview` / `ic_stop` (24×24dp, marginStart 12dp) | `IconButton` (Icons.play_arrow, 24dp) | ⚠️ 圖標需對照，未切換為 stop |

### 2.4 時間標題區域

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 標題 | `tv_time_title` (body_accent, text_aaaa, margin 16/24/16) | `Text` (bodyAccent, textSecondary, margin 16/24/16) | ⚠️ 顏色需對照 |
| 添加時間按鈕 | `btn_add_time` (ic_add_btn, 24×24dp, marginEnd 16dp) | `IconButton` (Icons.add, 24dp) | ⚠️ 圖標需對照 |

### 2.5 記錄列表

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| RecyclerView | `rv_time` (marginTop 8dp, divider bg_press) | `Column` (marginTop 8dp) | ⚠️ 無 divider |
| 記錄項 | `adapter_led_record` (bg_aaaa, padding 16/12/16/12) | `_LedRecordTile` (surface, padding 16/12/16/12) | ✅ |
| 時間文字 | `tv_time` (body, text_aaaa) | `Text` (body, textPrimary) | ⚠️ 顏色需對照 |
| 更多按鈕 | `img_next` (ic_more_enable, 24×24dp, marginStart 8dp) | `Image.asset` (fallback Icons.chevron_right) | ⚠️ 圖標需對照 |

## 三、按鍵功能對照

### 3.1 返回按鈕 (btn_back)

**reef-b-app**:
- `clickBtnBack()`: 如果正在預覽，停止預覽；否則 `finish()`

**koralcore**:
- `handleBackNavigation()`: 如果正在預覽，停止預覽；然後 `Navigator.pop()`

**對照狀態**: ✅ 完全對照

### 3.2 清除按鈕 (btn_icon)

**reef-b-app**:
- `clickBtnIcon()`: 如果正在預覽，停止預覽；否則顯示清除確認對話框
- 清除成功後：導航到 `LedRecordSettingActivity` 並 `finish()`

**koralcore**:
- `_confirmClear()`: 顯示清除確認對話框
- 清除成功後：顯示成功消息，但**未導航到 LedRecordSettingPage**

**對照狀態**: ❌ 清除成功後未導航到設定頁面

### 3.3 添加按鈕 (btn_add)

**reef-b-app**:
- `clickBtnAdd()`: 如果正在預覽，停止預覽
- 檢查記錄數量 < 24
- 檢查 `canAddRecord()` (時間有效性、是否已存在)
- 如果可添加，導航到 `LedRecordTimeSettingActivity` 並傳遞 `hour, minute`

**koralcore**:
- `onPressed: null` - **功能未實現**

**對照狀態**: ❌ 功能未實現

### 3.4 減去按鈕 (btn_minus)

**reef-b-app**:
- `clickBtnMinus()`: 如果正在預覽，停止預覽
- 檢查當前選擇的時間是否有記錄
- 如果有，顯示刪除確認對話框

**koralcore**:
- `onPressed: null` - **功能未實現**

**對照狀態**: ❌ 功能未實現

### 3.5 上一個按鈕 (btn_prev)

**reef-b-app**:
- `clickBtnPrev()`: 如果正在預覽，停止預覽
- 找到當前時間所在區間的上一個記錄時間
- 更新 `nowTimeLiveData` 和 `tv_clock`

**koralcore**:
- `goToPreviousRecord()`: 找到當前選擇的上一個記錄時間
- 更新 `_selectedMinutes` 和 `_selectedRecordId`

**對照狀態**: ✅ 功能對照，但需檢查邏輯是否完全一致

### 3.6 下一個按鈕 (btn_next)

**reef-b-app**:
- `clickBtnNext()`: 如果正在預覽，停止預覽
- 找到當前時間所在區間的下一個記錄時間
- 更新 `nowTimeLiveData` 和 `tv_clock`

**koralcore**:
- `goToNextRecord()`: 找到當前選擇的下一個記錄時間
- 更新 `_selectedMinutes` 和 `_selectedRecordId`

**對照狀態**: ✅ 功能對照，但需檢查邏輯是否完全一致

### 3.7 預覽按鈕 (btn_preview)

**reef-b-app**:
- `clickBtnPreview()`: 如果正在預覽，停止預覽；否則開始預覽
- 開始預覽時：
  - 圖標切換為 `ic_stop`
  - 圖表設置 `setTouchEnabled(false)`
  - 啟動 Timer (每 41ms 更新一次高亮)
  - 設置 `FLAG_KEEP_SCREEN_ON`
- 停止預覽時：
  - 圖標切換為 `ic_preview`
  - 恢復當前時間顯示
  - 圖表設置 `setTouchEnabled(true)`
  - 清除 `FLAG_KEEP_SCREEN_ON`
  - 停止 Timer

**koralcore**:
- `togglePreview()`: 如果正在預覽，停止預覽；否則開始預覽
- **未實現**：
  - 圖標切換
  - 圖表觸摸禁用
  - Timer 更新
  - 保持屏幕常亮

**對照狀態**: ❌ 預覽功能不完整

### 3.8 添加時間按鈕 (btn_add_time)

**reef-b-app**:
- `clickBtnAddTime()`: 如果正在預覽，停止預覽
- 檢查記錄數量 < 24
- 如果可添加，導航到 `LedRecordTimeSettingActivity`

**koralcore**:
- 導航到 `LedRecordTimeSettingPage`
- **未檢查**記錄數量限制

**對照狀態**: ⚠️ 未檢查記錄數量限制

### 3.9 記錄項點擊

**reef-b-app**:
- `onClickLedRecord()`: 如果正在預覽，停止預覽；否則導航到 `LedRecordTimeSettingActivity` 並傳遞記錄數據

**koralcore**:
- `onTap`: 選擇記錄並導航到 `LedRecordTimeSettingPage`
- **未檢查**是否正在預覽

**對照狀態**: ⚠️ 未檢查預覽狀態

### 3.10 記錄項長按

**reef-b-app**:
- `onLongClickLedRecord()`: 如果正在預覽，停止預覽；否則顯示刪除確認對話框

**koralcore**:
- `onLongPress`: 顯示刪除確認對話框
- **未檢查**是否正在預覽

**對照狀態**: ⚠️ 未檢查預覽狀態

## 四、光譜組件 (LineChart) 對照

### 4.1 圖表配置

| 配置項 | reef-b-app | koralcore | 狀態 |
|--------|-----------|-----------|------|
| 高度 | 242dp | 242dp | ✅ |
| 邊距 | 8dp | 8dp (padding) | ✅ |
| X軸範圍 | 0-1440 (分鐘) | 0-1440 | ✅ |
| Y軸範圍 | 0-100 | 0-100 | ✅ |
| X軸標籤 | 7個標籤 (XAxisFormatter) | 每4小時一個標籤 | ⚠️ 需對照 |
| Y軸標籤 | 5個標籤 | 每25一個標籤 | ⚠️ 需對照 |
| 網格線 | Y軸網格線 (bg_press, 1f) | Y軸網格線 | ✅ |
| 觸摸交互 | `setTouchEnabled(true)` | `interactive` 參數 | ✅ |

### 4.2 通道線條

| 通道 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| Cold White | 有 | 有 | ✅ |
| Royal Blue | 有 | 有 | ✅ |
| Blue | 有 | 有 | ✅ |
| Red | 有 | 有 | ✅ |
| Green | 有 | 有 | ✅ |
| Purple | 有 | 有 | ✅ |
| UV | 有 | 有 | ✅ |
| Moon Light | 有 | 有 | ✅ |
| Warm White | 無 (註釋掉) | 無 | ✅ |
| 高亮線 | 有 (透明, 虛線) | 有 (垂直線, 虛線) | ✅ |

### 4.3 圖表交互

**reef-b-app**:
- `onValueSelected()`: 當點擊圖表時，更新 `nowSelectTime` 和 `tv_clock`
- 高亮線：使用 `highLightDataSet` (透明線條，虛線高亮指示器)

**koralcore**:
- `onTap`: 當點擊圖表時，調用 `controller.selectTime(minutes)`
- 高亮線：使用 `ExtraLinesData.verticalLines` (垂直虛線)

**對照狀態**: ✅ 功能對照

## 五、資訊流對照

### 5.1 記錄更新流程

**reef-b-app**:
1. `getNowRecords()` → `ledInformation.getRecords()`
2. `recordsLiveData.postValue(records)`
3. Observer: 更新 RecyclerView、繪製圖表、更新時鐘、高亮當前時間

**koralcore**:
1. `observeLedRecordStateUseCase.execute()` → Stream
2. `_handleState(state)` → 更新 `_state`、選擇記錄
3. UI 自動重建（通過 `notifyListeners()`）

**對照狀態**: ✅ 基本對照，但 koralcore 未更新時鐘顯示

### 5.2 時間選擇流程

**reef-b-app**:
1. 點擊圖表 → `onValueSelected()` → `setNowSelectTime()` → 更新 `hour, minute` → 更新按鈕狀態
2. 點擊上一個/下一個 → `clickBtnPrev/Next()` → 更新 `nowTimeLiveData` → Observer 更新 `tv_clock` 和圖表高亮

**koralcore**:
1. 點擊圖表 → `selectTime()` → `_updateSelectionByMinutes()` → 更新 `_selectedMinutes, _selectedRecordId`
2. 點擊上一個/下一個 → `goToPrevious/NextRecord()` → 更新選擇

**對照狀態**: ✅ 功能對照，但 koralcore 未更新時鐘顯示

### 5.3 預覽流程

**reef-b-app**:
1. 點擊預覽 → `bleStartPreview()` → 發送 BLE 命令
2. `ledPreview` callback → `COMMAND_STATUS.START` → `previewStateLiveData.postValue(true)`
3. Observer: 開始 Timer、更新圖標、禁用圖表觸摸、保持屏幕常亮
4. Timer: 每 41ms 更新圖表高亮位置
5. 停止預覽 → `bleStopPreview()` → `COMMAND_STATUS.END` → 恢復狀態

**koralcore**:
1. 點擊預覽 → `startLedPreviewUseCase.execute()` → 發送 BLE 命令
2. Stream 更新 → `_handleState()` → 檢測 `previewingRecordId`
3. **缺失**：
   - Timer 更新
   - 圖標切換
   - 圖表觸摸禁用
   - 保持屏幕常亮

**對照狀態**: ❌ 預覽功能不完整

## 六、需要修復的問題

### 高優先級

1. **時鐘顯示更新**：
   - 進入頁面時顯示當前時間
   - 選擇時間時更新時鐘顯示
   - 對照 `reef-b-app` 的 `tv_clock` 更新邏輯

2. **圖表高亮當前時間**：
   - 進入頁面時在圖表上高亮當前時間
   - 對照 `reef-b-app` 的 `lineChart.highlightValue(getNowTotalMinute().toFloat(), 8, false)`

3. **添加/減去按鈕功能**：
   - 實現 `btn_add` 功能（檢查記錄數量、時間有效性、導航到時間設定頁面）
   - 實現 `btn_minus` 功能（檢查當前選擇、顯示刪除對話框）

4. **預覽功能完整實現**：
   - Timer 更新圖表高亮（每 41ms）
   - 圖標切換（play_arrow ↔ stop）
   - 圖表觸摸禁用/啟用
   - 保持屏幕常亮

5. **清除成功後導航**：
   - 清除成功後導航到 `LedRecordSettingPage` 並關閉當前頁面

### 中優先級

6. **圖標對照**：
   - 所有按鈕圖標需使用 `reef-b-app` 的 XML drawable 轉換為 SVG

7. **按鈕狀態管理**：
   - `btn_add` 和 `btn_minus` 的啟用/禁用狀態需根據當前選擇的時間動態更新
   - 對照 `reef-b-app` 的 `btnAddStateLiveData` 和 `btnMinusStateLiveData`

8. **記錄數量限制檢查**：
   - `btn_add_time` 需檢查記錄數量 < 24

9. **預覽狀態檢查**：
   - 所有操作前需檢查是否正在預覽，如果是則先停止預覽

### 低優先級

10. **顏色對照**：
    - `tv_clock`: `text_aaaa` → `textPrimary`
    - `tv_time_title`: `text_aaaa` → `textPrimary`
    - `tv_time`: `text_aaaa` → `textPrimary`

11. **X/Y軸標籤對照**：
    - X軸：7個標籤（使用 XAxisFormatter）
    - Y軸：5個標籤

12. **RecyclerView Divider**：
    - 添加 divider（顏色：bg_press）

## 七、實現狀態

- **組件對照**: 85% ⚠️（結構基本對照，但圖標和顏色需調整）
- **按鍵功能**: 60% ❌（添加/減去按鈕未實現，預覽功能不完整）
- **光譜組件**: 90% ⚠️（基本對照，但軸標籤需調整）
- **資訊流**: 70% ⚠️（基本對照，但時鐘更新和預覽功能不完整）

**總體評分**: 75%


