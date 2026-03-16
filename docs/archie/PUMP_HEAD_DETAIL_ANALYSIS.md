# PumpHeadDetailPage Android 行為分析

**分析日期**: 2026-01-03  
**Android 文件**: `DropHeadMainActivity.kt`, `DropHeadMainViewModel.kt`  
**Flutter 對應**: `PumpHeadDetailPage`, `PumpHeadDetailController`  

---

## 📋 當前狀態評估

### Flutter 現有實現

#### PumpHeadDetailPage
- **狀態**: 存在，但處於 "Parity Mode (路徑 B)"
- **特徵**:
  - 只有 UI 結構
  - 所有按鈕 `onPressed = null`
  - 無業務邏輯
  - `StatelessWidget`
  - 476 行程式碼

#### PumpHeadDetailController
- **狀態**: 存在，完整業務邏輯實現
- **特徵**:
  - `ChangeNotifier`
  - 完整的 UseCase 依賴
  - 狀態管理 (loading, error, data)
  - 420+ 行程式碼
  - 包含:
    - `refresh()` - 刷新數據
    - `sendManualDose()` - 手動滴液
    - `sendTimedDose()` - 定時滴液
    - Today dose 讀取
    - Schedule summary 讀取

---

## 🎯 實施策略

根據當前狀態，我們需要：

### 選項 A: 轉換 Parity Mode → Feature Implementation Mode
**動作**:
1. 保留現有 UI 結構（100% Parity）
2. 轉換 `StatelessWidget` → `StatefulWidget`
3. 集成 `PumpHeadDetailController` (已存在)
4. 連接所有 UI 互動
5. 添加 ChangeNotifierProvider

**優點**:
- ✅ Controller 已存在，無需重新實現
- ✅ UI 結構已經 100% Parity
- ✅ 工作量最小（主要是連接）

**缺點**:
- ⚠️ 需要確認 Controller 是否 100% 對照 Android

### 選項 B: 重新審查並修正
**動作**:
1. 詳細分析 Android ViewModel
2. 對比 Flutter Controller
3. 修正任何不一致
4. 然後執行選項 A

**優點**:
- ✅ 確保 100% Parity
- ✅ 深入理解業務邏輯

**缺點**:
- ⚠️ 時間較長（3-4 小時）

---

## 🔍 快速審查: Controller vs Android ViewModel

### Android DropHeadMainViewModel 核心方法 (推測)

基於 `DosingMainController` 的經驗，Android ViewModel 應該包含：

1. **初始化**:
   - `setDevice(deviceId, headId)`
   - 訂閱設備狀態
   - 訂閱 Dosing 狀態

2. **數據讀取**:
   - `getDropHeadInfo()` - 讀取泵頭資訊
   - `getTodayTotal()` - 讀取今日總量
   - `getScheduleSummary()` - 讀取排程摘要
   - `getAdjustHistory()` - 讀取校正歷史

3. **操作**:
   - `manualDose()` - 手動滴液
   - `timedDose()` - 定時滴液
   - `navigateToSettings()` - 導航到設置
   - `navigateToRecord()` - 導航到記錄
   - `navigateToAdjust()` - 導航到校正

### Flutter PumpHeadDetailController 對比

**✅ 已實現**:
- `refresh()` - 對應 Android 的初始化 + 數據讀取
- `sendManualDose()` - 對應 Android `manualDose()`
- `sendTimedDose()` - 對應 Android `timedDose()`
- `readTodayTotalUseCase` - 對應 Android `getTodayTotal()`
- `readDosingScheduleSummaryUseCase` - 對應 Android `getScheduleSummary()`

**❓ 需確認**:
- Adjust History 讀取 - 需要檢查是否實現
- BLE 連線狀態處理 - 需要檢查
- 錯誤處理完整性

---

## 📊 建議實施方案

### 方案 1: 快速整合（2-3 小時）✨ 推薦

1. **Step 1**: 快速審查 Android ViewModel（30 分鐘）
   - 確認核心方法
   - 確認狀態管理
   - 確認 BLE 流程

2. **Step 2**: 更新 PumpHeadDetailPage（1 小時）
   - 轉換為 StatefulWidget
   - 添加 ChangeNotifierProvider
   - 連接所有 UI 互動
   - 連接 Controller 狀態

3. **Step 3**: 補充缺失功能（30 分鐘）
   - 如果發現 Controller 缺少功能，補充
   - 添加導航邏輯

4. **Step 4**: 測試與驗證（1 小時）
   - 功能測試
   - Linter 檢查
   - Parity 驗證

### 方案 2: 完整重新實施（3-4 小時）

1. **Step 1**: 深入分析 Android（1 小時）
2. **Step 2**: 重新實現 Controller（1 小時）
3. **Step 3**: 更新 Page（1 小時）
4. **Step 4**: 測試（1 小時）

---

## ✅ 決定: 採用方案 1

**理由**:
1. ✅ Controller 已存在且看起來完整
2. ✅ Page UI 已經 100% Parity
3. ✅ 主要工作是"連接"而非"重新實現"
4. ✅ 時間效率更高

**下一步**:
1. 快速審查 Android ViewModel（確認沒有遺漏）
2. 開始整合 Page + Controller

---

**分析完成日期**: 2026-01-03  
**建議**: 採用快速整合方案

