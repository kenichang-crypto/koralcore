# Scene Add/Edit/Delete UI 完整版實作計畫

## 當前狀態（簡化版）

### ✅ 已完成
1. **基礎架構**
   - ✅ 調光模式命令（`enterDimmingMode` / `exitDimmingMode`）
   - ✅ 場景本地存儲層（`SceneRepositoryImpl`）
   - ✅ 場景管理 UseCases（Add/Update/Delete/EnterDimming/ExitDimming）
   - ✅ AppContext 整合

2. **簡化版 UI（當前實作）**
   - ✅ 基本 Controller（`LedSceneEditController`）
   - ✅ 場景名稱輸入
   - ✅ 9 個通道滑塊（Cold White, Royal Blue, Blue, Red, Green, Purple, UV, Warm White, Moon Light）
   - ✅ 調光模式進入/退出
   - ✅ 保存場景功能
   - ✅ 刪除場景功能

### ⏳ 待實作（完整版）

## 完整版功能清單

### 1. 光譜圖表（Spectrum Chart）
- **優先級**: 高
- **依賴**: 現有 `LedSpectrumChart` widget
- **實作內容**:
  - 整合 `LedSpectrumChart` 到 Scene Add/Edit 頁面
  - 實時更新圖表（當滑塊改變時）
  - 顯示當前通道強度的視覺化

### 2. 圖標選擇器（Icon Picker）
- **優先級**: 中
- **依賴**: 無
- **實作內容**:
  - 創建 `SceneIconPicker` widget
  - 水平滾動的圖標列表（類似 `reef-b-app` 的 `RecyclerView`）
  - 支持 11 種圖標（0-10，對應 `reef-b-app` 的 icon 定義）
  - 圖標預覽和選擇狀態

### 3. 調光模式優化
- **優先級**: 中
- **依賴**: 無
- **實作內容**:
  - 自動進入調光模式（頁面打開時）
  - 自動退出調光模式（頁面關閉時）
  - 調光模式狀態指示器
  - 錯誤處理和重試機制

### 4. 場景限制檢查
- **優先級**: 低
- **依賴**: 無
- **實作內容**:
  - 顯示當前場景數量（X/5）
  - 達到上限時的提示
  - 阻止添加新場景（如果已達上限）

### 5. 場景預覽功能
- **優先級**: 低
- **依賴**: 無
- **實作內容**:
  - "預覽"按鈕（應用場景但不保存）
  - 預覽狀態指示

## 執行計畫

### Phase 1: 簡化版 UI（當前階段）✅
**目標**: 基本可用的場景管理功能
**時間**: 已完成
**交付物**:
- ✅ 場景名稱輸入
- ✅ 9 個通道滑塊
- ✅ 調光模式控制
- ✅ 保存/刪除功能

### Phase 2: 光譜圖表整合（優先級：高）
**目標**: 添加視覺化反饋
**時間**: 1-2 天
**前置條件**: 
- ✅ `LedSpectrumChart` widget 已存在
- ✅ 簡化版 UI 已完成
**實作步驟**:
1. 在 `LedSceneEditController` 中添加圖表數據計算邏輯
2. 在 Scene Add/Edit 頁面中整合 `LedSpectrumChart`
3. 實現實時更新（當滑塊改變時更新圖表）
4. 測試圖表顯示和更新

**驗收標準**:
- [ ] 圖表正確顯示當前通道強度
- [ ] 滑塊改變時圖表實時更新
- [ ] 圖表樣式與 `reef-b-app` 一致

### Phase 3: 圖標選擇器（優先級：中）
**目標**: 完整的圖標選擇功能
**時間**: 2-3 天
**前置條件**:
- ✅ Phase 1 完成
- ✅ 圖標資源準備完成
**實作步驟**:
1. 創建 `SceneIconPicker` widget
2. 準備 11 種圖標資源（或使用 Material Icons 作為替代）
3. 實現水平滾動列表
4. 實現選擇狀態和視覺反饋
5. 整合到 Scene Add/Edit 頁面

**驗收標準**:
- [ ] 圖標選擇器正常顯示
- [ ] 可以選擇圖標
- [ ] 選擇狀態正確顯示
- [ ] 與 `reef-b-app` 行為一致

### Phase 4: 調光模式優化（優先級：中）
**目標**: 自動化和更好的用戶體驗
**時間**: 1 天
**前置條件**:
- ✅ Phase 1 完成
**實作步驟**:
1. 在頁面 `initState` 時自動進入調光模式
2. 在頁面 `dispose` 時自動退出調光模式
3. 添加調光模式狀態指示器
4. 實現錯誤處理和重試機制

**驗收標準**:
- [ ] 打開頁面時自動進入調光模式
- [ ] 關閉頁面時自動退出調光模式
- [ ] 調光模式狀態正確顯示
- [ ] 錯誤時有適當的提示和重試

### Phase 5: 場景限制和預覽（優先級：低）
**目標**: 完善功能和用戶體驗
**時間**: 1-2 天
**前置條件**:
- ✅ Phase 1-3 完成
**實作步驟**:
1. 添加場景數量顯示
2. 實現上限檢查和提示
3. 實現場景預覽功能
4. 添加預覽狀態指示

**驗收標準**:
- [ ] 場景數量正確顯示
- [ ] 達到上限時有適當提示
- [ ] 預覽功能正常工作
- [ ] 預覽狀態正確顯示

## 完整版實作時機建議

### 建議時機
1. **Phase 2（光譜圖表）**: 在簡化版 UI 穩定運行後立即實作
   - 理由: 提供視覺化反饋，提升用戶體驗
   - 時間: 簡化版完成後 1-2 週內

2. **Phase 3（圖標選擇器）**: 在 Phase 2 完成後
   - 理由: 完善場景創建體驗
   - 時間: Phase 2 完成後 1-2 週內

3. **Phase 4（調光模式優化）**: 與 Phase 3 並行或稍後
   - 理由: 提升自動化程度
   - 時間: Phase 3 完成後 1 週內

4. **Phase 5（場景限制和預覽）**: 最後實作
   - 理由: 非核心功能，可以後續完善
   - 時間: 其他功能穩定後

### 總體時間線
- **簡化版**: ✅ 已完成
- **Phase 2（光譜圖表）**: 1-2 週後
- **Phase 3（圖標選擇器）**: 3-4 週後
- **Phase 4（調光模式優化）**: 4-5 週後
- **Phase 5（場景限制和預覽）**: 5-6 週後

## 技術債務和注意事項

1. **場景數據同步**
   - 當前: 場景只存在本地（內存）
   - 未來: 需要與設備同步（如果設備支持場景存儲）
   - 注意: `reef-b-app` 中場景只存在本地數據庫，不與設備同步

2. **圖標資源**
   - 當前: 使用 Material Icons 作為替代
   - 未來: 需要準備對應的圖標資源文件
   - 注意: `reef-b-app` 使用自定義圖標（ic_thunder, ic_cloudy, ic_sunny 等）

3. **數據持久化**
   - 當前: 內存實現（重啟後丟失）
   - 未來: 需要實現數據庫持久化（SQLite/Hive）
   - 注意: 這是一個獨立的任務，不影響 UI 功能

## 參考資料

- `reef-b-app` Android:
  - `LedSceneAddActivity.kt`
  - `LedSceneEditActivity.kt`
  - `LedSceneDeleteViewModel.kt`
  - `SceneDao.kt`
  - `Scene.kt`

- `koralcore` 現有組件:
  - `LedSpectrumChart` widget
  - `LedSceneEditController` controller
  - `SceneRepositoryImpl` repository

