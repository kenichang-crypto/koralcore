# 第零階段實施狀態

**更新日期**: 2026-01-03  
**階段**: 第零階段 - 基礎框架  
**目標**: 啟用 5 個頁面的基本功能

---

## 📊 現狀分析

### ✅ UI Parity 完成度：100%

所有 5 個頁面的 UI 結構已達到 100% Android Parity：

| 頁面 | 路徑 | UI Parity | 功能狀態 |
|------|------|----------|---------|
| SplashPage | `lib/features/splash/presentation/pages/splash_page.dart` | ✅ 100% | ⚠️ 導航目標錯誤 |
| MainShellPage | `lib/app/main_shell_page.dart` | ✅ 100% | ✅ 基本功能完整 |
| HomeTabPage | `lib/features/home/presentation/pages/home_tab_page.dart` | ✅ 100% | ❌ 所有互動禁用 |
| BluetoothTabPage | `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` | ✅ 100% | ❌ 所有互動禁用 |
| DeviceTabPage | `lib/features/device/presentation/pages/device_tab_page.dart` | ✅ 100% | ❌ 所有互動禁用 |

---

## 🎯 實施任務

### 0.1 SplashPage（預計 0.5 小時）✅

**當前狀態**: 
- ✅ UI Parity 100%
- ⚠️ 導航到 `MainScaffold` 而非 `MainShellPage`

**需修改**:
```dart
// 當前 (line 62):
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const MainScaffold()),  // ❌
  (_) => false,
);

// 修改為:
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const MainShellPage()),  // ✅
  (_) => false,
);
```

**驗收標準**:
- [x] 啟動延遲 1.5 秒
- [ ] 導航到 `MainShellPage`
- [x] 無返回鍵可回到 Splash
- [x] 全螢幕模式 (immersiveSticky)

---

### 0.2 MainShellPage（預計 0.5 小時）✅

**當前狀態**: 
- ✅ UI Parity 100%
- ✅ Tab 切換功能正常
- ✅ 使用 `NavigationController` + `Provider`

**需確認**:
- [ ] `NavigationController` 是否已實現
- [ ] Provider 是否已在 `main.dart` 註冊
- [ ] Tab 狀態是否保持（IndexedStack）

**驗收標準**:
- [ ] Bottom Navigation 正常切換
- [ ] Tab 內容正常顯示
- [ ] Tab 狀態保持（不重建）
- [ ] 無 Scaffold-in-Scaffold

---

### 0.3 HomeTabPage（預計 4-6 小時）

**當前狀態**: 
- ✅ UI Parity 100%
- ✅ `HomeController` 已實現
- ❌ 所有 `onTap` 都是 `null`

**需實現功能**:
1. **Sink Selector 互動**:
   - [ ] PopupMenu 選擇水槽
   - [ ] 切換顯示模式（All Sinks / 單個水槽）
   - [ ] 更新裝置列表

2. **Sink Manager 按鈕**:
   - [ ] 導航到 `SinkManagerPage`（第二階段實現）
   - [ ] 目前可暫時顯示 Toast "功能開發中"

3. **Device Card 點擊**:
   - [ ] LED 裝置 → 導航到 `LedMainPage`
   - [ ] Dosing 裝置 → 導航到 `DosingMainPage`

**需修改檔案**:
- `home_tab_page.dart`: 啟用 `onManagerTap`, `onTap` (device cards)
- `controllers/home_controller.dart`: 確認功能完整

**驗收標準**:
- [ ] Sink Selector 可選擇
- [ ] 裝置列表正確過濾
- [ ] 裝置卡片可點擊導航
- [ ] 空狀態正確顯示

---

### 0.4 BluetoothTabPage（預計 3-4 小時）

**當前狀態**: 
- ✅ UI Parity 100%
- ❌ 所有 `onTap` 都是 `null`
- ❌ 無 BLE 掃描功能

**需實現功能**:
1. **掃描按鈕**:
   - [ ] 點擊刷新按鈕觸發 BLE 掃描
   - [ ] 顯示掃描進度指示器

2. **已配對裝置列表**:
   - [ ] 點擊裝置卡片 → 連線/斷線
   - [ ] 顯示連線狀態

3. **其他裝置列表**:
   - [ ] 點擊裝置卡片 → 顯示配對對話框
   - [ ] 配對成功 → 移至已配對列表

**需修改檔案**:
- `bluetooth_tab_page.dart`: 啟用 `onTap`
- **需新建**: `controllers/bluetooth_controller.dart`
- **需新建**: `domain/bluetooth/usecases/scan_devices_usecase.dart`

**驗收標準**:
- [ ] 掃描按鈕可觸發 BLE 掃描
- [ ] 已配對裝置可連線/斷線
- [ ] 其他裝置可配對
- [ ] 連線狀態正確顯示

---

### 0.5 DeviceTabPage（預計 2-3 小時）

**當前狀態**: 
- ✅ UI Parity 100%
- ❌ 所有 `onTap` 都是 `null`

**需實現功能**:
1. **Device Card 點擊**:
   - [ ] LED 裝置 → 導航到 `LedMainPage`
   - [ ] Dosing 裝置 → 導航到 `DosingMainPage`

2. **空狀態**:
   - [ ] "新增裝置" 按鈕 → 導航到 `AddDevicePage`（第五階段實現）
   - [ ] 目前可暫時顯示 Toast "功能開發中"

**需修改檔案**:
- `device_tab_page.dart`: 啟用 `onTap`

**驗收標準**:
- [ ] 裝置卡片可點擊導航
- [ ] 空狀態按鈕可點擊
- [ ] 導航目標正確

---

## 📈 進度追蹤

| 任務 | 預計時間 | 實際時間 | 狀態 | 完成日期 |
|------|---------|---------|------|---------|
| 0.1 SplashPage | 0.5h | - | ⏳ 進行中 | - |
| 0.2 MainShellPage | 0.5h | - | ⏳ 待開始 | - |
| 0.3 HomeTabPage | 4-6h | - | ⏳ 待開始 | - |
| 0.4 BluetoothTabPage | 3-4h | - | ⏳ 待開始 | - |
| 0.5 DeviceTabPage | 2-3h | - | ⏳ 待開始 | - |
| **總計** | **10-14h** | **-** | **0%** | **-** |

---

## 🚀 立即行動

### 今日 (2026-01-03)

**目標**: 完成 0.1 + 0.2（基礎導航流程）

1. ⏳ 修改 `SplashPage` 導航目標
2. ⏳ 檢查 `NavigationController` 實現
3. ⏳ 確認 Provider 註冊
4. ⏳ 測試啟動流程

---

**更新時間**: 2026-01-03 14:00  
**下一步**: 修改 `SplashPage` 導航目標

