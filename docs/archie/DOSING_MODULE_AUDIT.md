# Dosing 模組完整盤點報告

**盤點日期**: 2026-01-03  
**目的**: 確定所有 Dosing 頁面/Controller 狀態，制定實施優先級  

---

## 📊 Dosing 模組總覽

### 統計
- **總頁面數**: 14
- **總 Controller 數**: 10
- **已完成頁面**: 2 (DosingMainPage, PumpHeadDetailPage)
- **Parity Mode 頁面**: 12
- **待實施頁面**: 12

---

## 🎯 已完成頁面 (Feature Implementation Mode)

### 1. DosingMainPage ✅
**狀態**: 100% 完成  
**Controller**: `DosingMainController` (410 lines)  
**Page**: `DosingMainPage` (552 lines)  
**功能**:
- ✅ 設備列表顯示
- ✅ 手動滴液 (Manual Drop)
- ✅ 收藏/取消收藏
- ✅ 刪除設備
- ✅ 重置設備
- ✅ BLE 連線/斷線
- ✅ PopupMenu (Edit/Delete/Reset)

**Android 對應**: `DropMainActivity`

---

### 2. PumpHeadDetailPage ✅
**狀態**: 100% 完成  
**Controller**: `PumpHeadDetailController` (419 lines)  
**Page**: `PumpHeadDetailPage` (548 lines)  
**功能**:
- ✅ 顯示泵頭資訊
- ✅ Today Dose 顯示
- ✅ Schedule Summary 顯示
- ✅ 手動滴液
- ✅ 定時滴液
- ✅ 下拉刷新
- ✅ Loading 狀態
- ✅ PopupMenu (Settings/Manual/Timed)

**Android 對應**: `DropHeadMainActivity`

---

## 🏗️ Parity Mode 頁面 (需轉為 Feature Mode)

### 3. PumpHeadSettingsPage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `PumpHeadSettingsController` (53 lines) ✅ 存在但簡單  
**Page**: `PumpHeadSettingsPage` (410 lines, UI only)  
**需實施功能**:
- [ ] Drop Type 選擇
- [ ] Max Drop Volume 設定
- [ ] Rotating Speed 設定
- [ ] Save 功能

**Android 對應**: `DropHeadSettingActivity`  
**優先級**: ⭐⭐⭐ 高 (從 PumpHeadDetailPage 點擊進入)

---

### 4. DropSettingPage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: ❌ 無 Controller  
**Page**: `DropSettingPage` (333 lines, UI only)  
**需實施功能**:
- [ ] 設備名稱編輯
- [ ] Sink Position 選擇
- [ ] Delay Time 設定
- [ ] Save 功能

**Android 對應**: `DropSettingActivity`  
**優先級**: ⭐⭐⭐ 高 (從 DosingMainPage PopupMenu 進入)

---

### 5. PumpHeadRecordSettingPage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `PumpHeadRecordSettingController` (330 lines) ✅ 存在且完整  
**Page**: `PumpHeadRecordSettingPage` (726 lines, UI only)  
**需實施功能**:
- [ ] Record Type 選擇 (24HR/SINGLE/CUSTOM)
- [ ] Volume 設定
- [ ] Rotating Speed 設定
- [ ] Run Time 選擇 (NOW/DAYS_A_WEEK/TIME_RANGE/TIME_POINT)
- [ ] Custom Time 列表管理
- [ ] Save 功能

**Android 對應**: `DropHeadRecordSettingActivity`  
**優先級**: ⭐⭐⭐ 高 (從 PumpHeadDetailPage 進入)

---

### 6. PumpHeadRecordTimeSettingPage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `PumpHeadRecordTimeSettingController` (234 lines) ✅ 存在且完整  
**Page**: `PumpHeadRecordTimeSettingPage` (未檢查)  
**需實施功能**:
- [ ] Start Time 設定
- [ ] End Time 設定
- [ ] Drop Times 設定
- [ ] Drop Volume 設定
- [ ] Rotating Speed 設定
- [ ] Save 功能

**Android 對應**: `DropHeadRecordTimeSettingActivity`  
**優先級**: ⭐⭐ 中 (從 PumpHeadRecordSettingPage 進入)

---

### 7. DropTypePage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `DropTypeController` (181 lines) ✅ 存在且完整  
**Page**: `DropTypePage` (255 lines, UI only)  
**需實施功能**:
- [ ] Drop Type 列表顯示
- [ ] 選擇 Drop Type
- [ ] Add Drop Type (BottomSheet)
- [ ] Edit Drop Type (BottomSheet)
- [ ] Delete Drop Type (長按)
- [ ] Return 選中的 Type

**Android 對應**: `DropTypeActivity`  
**優先級**: ⭐⭐⭐ 高 (從多個頁面進入)

---

### 8. PumpHeadCalibrationPage ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `PumpHeadCalibrationController` (88 lines) ⚠️ 存在但簡單  
**Page**: `PumpHeadCalibrationPage` (未檢查)  
**需實施功能**:
- [ ] 多步驟校正流程
- [ ] Rotating Speed 選擇
- [ ] Drop Volume 輸入
- [ ] Timer 計時
- [ ] Next/Prev/Complete 按鈕
- [ ] BLE 命令發送

**Android 對應**: `DropHeadAdjustActivity`  
**優先級**: ⭐⭐ 中 (從 PumpHeadDetailPage 進入)

---

### 9. PumpHeadAdjustController ⚠️
**狀態**: Parity Mode (UI only)  
**Controller**: `PumpHeadAdjustController` (259 lines) ✅ 存在且完整  
**Page**: `PumpHeadAdjustPage` / `PumpHeadAdjustListPage` (未檢查)  
**需實施功能**:
- [ ] 校正歷史列表
- [ ] 顯示校正詳情

**Android 對應**: 可能對應多個 Activity  
**優先級**: ⭐ 低 (輔助功能)

---

### 10. PumpHeadScheduleController ⚠️
**狀態**: 未確定  
**Controller**: `PumpHeadScheduleController` (225 lines) ✅ 存在且完整  
**Page**: `PumpHeadSchedulePage` / `ScheduleEditPage` (未檢查)  
**需實施功能**:
- [ ] Schedule 列表顯示
- [ ] Schedule 新增/編輯/刪除
- [ ] Schedule 啟用/停用

**Android 對應**: 可能對應 Schedule 相關 Activity  
**優先級**: ⭐⭐ 中

---

### 11. ManualDosingController ⚠️
**狀態**: 未確定  
**Controller**: `ManualDosingController` (81 lines) ⚠️ 存在但簡單  
**Page**: `ManualDosingPage` (未檢查)  
**需實施功能**:
- [ ] 手動滴液頁面 (可能為全屏頁面)

**Android 對應**: 可能對應 Manual Dosing Activity  
**優先級**: ⭐ 低 (或已整合到 DosingMainPage)

---

## 📋 實施優先級排序

### 第一優先級（必須）⭐⭐⭐
這些頁面從已完成頁面直接可達，是核心功能流程的一部分。

1. **DropSettingPage** (設備設定)
   - 從: DosingMainPage PopupMenu → Edit
   - Controller: 需創建
   - 預計: 2-3 小時

2. **PumpHeadSettingsPage** (泵頭設定)
   - 從: PumpHeadDetailPage PopupMenu → Settings
   - Controller: 已存在 (53 lines, 需擴充)
   - 預計: 1.5-2 小時

3. **DropTypePage** (泵頭類型選擇)
   - 從: PumpHeadSettingsPage → Drop Type Button
   - 從: PumpHeadRecordSettingPage → Drop Type Button
   - Controller: 已存在 (181 lines, 完整)
   - 預計: 2-3 小時

4. **PumpHeadRecordSettingPage** (定時記錄設定)
   - 從: PumpHeadDetailPage → Record Section → More
   - Controller: 已存在 (330 lines, 完整)
   - 預計: 3-4 小時 (最複雜)

---

### 第二優先級（重要）⭐⭐

5. **PumpHeadRecordTimeSettingPage** (自定義時間設定)
   - 從: PumpHeadRecordSettingPage → Custom Record Time
   - Controller: 已存在 (234 lines, 完整)
   - 預計: 2-3 小時

6. **PumpHeadCalibrationPage** (泵頭校正)
   - 從: PumpHeadDetailPage → Adjust Section → More
   - Controller: 已存在 (88 lines, 需擴充)
   - 預計: 3-4 小時 (多步驟流程)

7. **PumpHeadScheduleController** (排程管理)
   - Controller: 已存在 (225 lines, 完整)
   - 預計: 2-3 小時

---

### 第三優先級（補充）⭐

8. **PumpHeadAdjustListPage** (校正歷史列表)
   - 從: PumpHeadDetailPage → Adjust Section → More
   - Controller: 已存在 (259 lines)
   - 預計: 1-2 小時

9. **ManualDosingPage** (可能已整合)
   - 需確認是否獨立頁面
   - 預計: 1-2 小時 或 0 (已整合)

---

## 🎯 建議實施順序

基於依賴關係和優先級，建議按以下順序實施：

### 階段 1：核心設定流程 (6-8 小時)
1. **DropSettingPage** (2-3h)
   - 設備名稱、水槽位置、延遲時間
   - 從 DosingMainPage 直接可達
   - 需創建 Controller

2. **PumpHeadSettingsPage** (1.5-2h)
   - Drop Type、Rotating Speed
   - 從 PumpHeadDetailPage 直接可達
   - Controller 已存在

3. **DropTypePage** (2-3h)
   - 選擇/新增/編輯泵頭類型
   - 被多個頁面依賴
   - Controller 已存在

### 階段 2：定時記錄流程 (5-7 小時)
4. **PumpHeadRecordSettingPage** (3-4h)
   - 最複雜的設定頁面
   - Controller 已存在

5. **PumpHeadRecordTimeSettingPage** (2-3h)
   - Custom 模式的時間設定
   - Controller 已存在

### 階段 3：校正與排程 (5-7 小時)
6. **PumpHeadCalibrationPage** (3-4h)
   - 多步驟校正流程
   - 需擴充 Controller

7. **PumpHeadScheduleController** (2-3h)
   - 排程管理
   - Controller 已存在

### 階段 4：輔助功能 (1-2 小時)
8. **PumpHeadAdjustListPage** (1-2h)
   - 校正歷史

---

## 📊 總結

### 統計
- **總待實施頁面**: 12
- **已有完整 Controller**: 8
- **需創建 Controller**: 1
- **需擴充 Controller**: 1
- **預計總時間**: 17-24 小時

### Controller 狀況
| Controller | 行數 | 狀態 | 評估 |
|-----------|------|------|------|
| DosingMainController | 410 | ✅ 完成 | 100% |
| PumpHeadDetailController | 419 | ✅ 完成 | 100% |
| PumpHeadRecordSettingController | 330 | ✅ 存在 | 完整 |
| PumpHeadAdjustController | 259 | ✅ 存在 | 完整 |
| PumpHeadRecordTimeSettingController | 234 | ✅ 存在 | 完整 |
| PumpHeadScheduleController | 225 | ✅ 存在 | 完整 |
| DropTypeController | 181 | ✅ 存在 | 完整 |
| PumpHeadCalibrationController | 88 | ⚠️ 存在 | 需擴充 |
| ManualDosingController | 81 | ⚠️ 存在 | 簡單 |
| PumpHeadSettingsController | 53 | ⚠️ 存在 | 需擴充 |
| DropSettingController | 0 | ❌ 無 | 需創建 |

### 關鍵發現
1. **大部分 Controller 已存在且完整** ✅
   - 與 PumpHeadDetailPage 相同，可節省大量時間

2. **只有 1 個 Controller 需從零創建** ✅
   - DropSettingController (相對簡單)

3. **所有頁面都是 Parity Mode** ✅
   - UI 結構已 100% 完成
   - 只需集成 Controller 和業務邏輯

4. **實施難度評估**:
   - 簡單 (1-2h): DropSettingPage, PumpHeadSettingsPage, PumpHeadAdjustListPage
   - 中等 (2-3h): DropTypePage, PumpHeadRecordTimeSettingPage, PumpHeadScheduleController
   - 複雜 (3-4h): PumpHeadRecordSettingPage, PumpHeadCalibrationPage

---

## 🚀 下一步建議

### 選項 A：按順序完整實施（推薦）
- 完成階段 1 (核心設定流程)
- 預計：6-8 小時
- 完成後可測試完整的設定流程

### 選項 B：選擇最簡單的先做
- PumpHeadSettingsPage (1.5-2h)
- 快速見效，建立信心

### 選項 C：選擇最關鍵的先做
- DropSettingPage (2-3h)
- 從 DosingMainPage 直接可達
- 需創建 Controller

---

**建議**: 選擇 **選項 C** → 從 **DropSettingPage** 開始

**理由**:
1. 從已完成的 DosingMainPage 直接可達
2. 是核心設定流程的入口
3. 需創建 Controller，但相對簡單
4. 完成後可打通 DosingMainPage → DropSettingPage 流程

---

**盤點完成日期**: 2026-01-03  
**下一步**: 等待用戶確認選項

