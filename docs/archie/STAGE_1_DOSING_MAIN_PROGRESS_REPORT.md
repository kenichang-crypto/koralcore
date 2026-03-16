# 第一階段進度報告 - DosingMainPage 功能實施

**報告日期**: 2026-01-03  
**狀態**: Controller 完成，UI 更新待實施  
**實際時間**: ~2 小時  

---

## ✅ 已完成項目

### 1. Android 行為分析 (1 小時)

- ✅ 完整分析 `DropMainActivity.kt` (314 行)
- ✅ 完整分析 `DropMainViewModel.kt` (466 行)
- ✅ 盤點所有 BLE 指令序列
- ✅ 盤點所有 UI 互動行為
- ✅ 盤點所有 LiveData Observers
- ✅ 產出文件: `docs/STAGE_1_DOSING_MAIN_ANDROID_ANALYSIS.md`

### 2. DosingMainController 實施 (1 小時)

- ✅ 創建完整的 Controller (254 行)
- ✅ 100% 對照 `DropMainViewModel.kt`
- ✅ 實現所有核心方法:
  - `initialize(deviceId)` - 初始化裝置資料
  - `toggleManualDrop(pumpHeadIndex)` - 手動滴液 Play/Pause
  - `toggleFavorite()` - 切換喜愛狀態
  - `deleteDevice()` - 刪除裝置
  - `resetDevice()` - 重置裝置
  - `getPumpHeadModes()` - 獲取泵頭模式
  - `formatTodayTotalDrop(raw)` - 格式化今日總量
- ✅ 0 linter errors, 0 warnings

### 3. 架構檢查

- ✅ 確認 `BleDosingRepositoryImpl` 已實現所有 BLE 指令
- ✅ 確認 `DosingCommandBuilder` 已實現所有指令格式
- ✅ 確認 manual drop 指令 (0x63/0x64) 可用
- ✅ 確認所有依賴項可用

---

## ⏳ 待完成項目

### 1. DosingMainPage UI 更新 (預計 1-2 小時)

**需要修改的文件**:
- `lib/features/doser/presentation/pages/dosing_main_page.dart`

**修改內容**:
1. 從 `StatelessWidget` 改為使用 `ChangeNotifierProvider<DosingMainController>`
2. 添加 `initState()` 調用 `controller.initialize(deviceId)`
3. 啟用 Toolbar 按鈕:
   - Back button → `Navigator.pop()`
   - Settings button → `showPopupMenu()` (Edit/Delete/Reset)
   - BLE button → 移除（已在設備識別區）
4. 啟用設備識別區 BLE button → `controller.toggleBleConnection()`
5. 啟用泵頭卡片:
   - Card `onTap` → 導航到 `PumpHeadDetailPage`
   - Play button → `controller.toggleManualDrop(headIndex)`
6. 更新 Loading state → `controller.isLoading`
7. 更新 Connection state → `controller.isConnected`

### 2. Dialog Widgets 創建 (預計 1 小時)

**需要創建的 Dialogs**:
1. **Delete Confirmation Dialog**
   - 對應 Android `createDeleteDropDialog()`
   - 文案: `dialog_delete_drop_content` / `dialog_delete_drop_positive` / `dialog_delete_drop_negative`
   - 行為: 確認後調用 `controller.deleteDevice()` → 成功後 `Navigator.pop()` 並 Toast

2. **Reset Confirmation Dialog**
   - 對應 Android `createResetDropDialog()`
   - 文案: `dialog_reset_drop_title` / `dialog_reset_drop_content` / `dialog_reset_drop_positive` / `dialog_reset_drop_negative`
   - 行為: 確認後調用 `controller.resetDevice()` → 成功後 `Navigator.pop()` 並 Toast

3. **Drop Out of Range Dialog**
   - 對應 Android `createDropOutOfRangeDialog()`
   - 文案: `dialog_today_drop_out_of_range_title` / `dialog_today_drop_out_of_range_content` / `dialog_today_drop_out_of_range_positive`
   - 行為: 僅顯示訊息，無額外行為

### 3. PopupMenu 實施 (預計 30 分鐘)

**內容**:
- 3 個選項: Edit / Delete / Reset
- Edit → 導航到 `DosingSettingPage`
- Delete → 顯示 Delete Dialog
- Reset → 檢查連線狀態 → 顯示 Reset Dialog 或 Toast "device_is_not_connect"

### 4. Provider 配置 (預計 30 分鐘)

**需要修改的文件**:
- `lib/app/main.dart` (添加 `DosingMainController` 到 `MultiProvider`)

**依賴項**:
```dart
ChangeNotifierProvider(
  create: (context) => DosingMainController(
    session: context.read<AppSession>(),
    dosingRepository: context.read<DosingRepository>(),
    deviceRepository: context.read<DeviceRepository>(),
    sinkRepository: context.read<SinkRepository>(),
    pumpHeadRepository: context.read<PumpHeadRepository>(),
    bleAdapter: context.read<BleAdapter>(),
  ),
),
```

### 5. 字串資源檢查 (預計 30 分鐘)

**需要檢查的 ARB keys**:
- `dialog_delete_drop_content`
- `dialog_delete_drop_positive`
- `dialog_delete_drop_negative`
- `dialog_reset_drop_title`
- `dialog_reset_drop_content`
- `dialog_reset_drop_positive`
- `dialog_reset_drop_negative`
- `dialog_today_drop_out_of_range_title`
- `dialog_today_drop_out_of_range_content`
- `dialog_today_drop_out_of_range_positive`
- `device_is_not_connect`
- `toast_connect_successful`
- `toast_connect_failed`
- `toast_delete_device_successful`
- `toast_delete_device_failed`
- `toast_reset_device_successful`
- `toast_reset_device_failed`
- `toast_drophead_is_droping`

---

## 📊 預計剩餘時間

| 項目 | 預計時間 |
|------|---------|
| DosingMainPage UI 更新 | 1-2 小時 |
| Dialog Widgets 創建 | 1 小時 |
| PopupMenu 實施 | 30 分鐘 |
| Provider 配置 | 30 分鐘 |
| 字串資源檢查 | 30 分鐘 |
| 測試與驗證 | 1-2 小時 |
| **總計** | **4-6 小時** |

---

## 🎯 總進度

- **第零階段**: ✅ 完成 (5 小時)
- **第一階段 - DosingMainPage**: 🟡 進行中 (已完成 2/8 小時)
  - Controller: ✅ 完成
  - UI 更新: ⏳ 待實施
  - Dialogs: ⏳ 待實施
  - Provider: ⏳ 待實施
  - 測試: ⏳ 待實施
- **第一階段 - LedMainPage**: ⏳ 未開始 (預計 8-10 小時)

---

## 📝 建議

由於 DosingMainPage 的實施比預期複雜（需要 Dialogs、PopupMenu、Provider 配置等），建議:

1. **優先完成 DosingMainPage** (剩餘 4-6 小時)
2. **再開始 LedMainPage** (8-10 小時)
3. **總預計時間**: 12-16 小時 (第一階段完整)

或者，如果時間有限:

1. **完成 DosingMainPage Controller** (✅ 已完成)
2. **產出詳細實施文件** (✅ 已完成)
3. **等待使用者確認** 是否繼續完整實施

---

**報告完成日期**: 2026-01-03  
**下一步**: 等待使用者指示，決定是否繼續完整實施 DosingMainPage UI

