# 架構 Parity 調整總結報告

**生成時間**: 2025-01-XX  
**目標**: 以 reef-b-app 為唯一事實來源，完成 koralcore 架構低風險調整

---

## 執行結果

### ✅ Step 1: 架構檢查完成

已完成 koralcore 與 reef-b-app 的完整對照分析：

#### reef-b-app 結構
- **Activity**: 26 個
- **Fragment**: 3 個（HomeFragment, BluetoothFragment, DeviceFragment）

#### koralcore 結構
- **Features**: 8 個（home, device, doser, led, sink, warning, splash, **缺少 bluetooth**）
- **Pages**: 40+ 個頁面

### ✅ Step 2: 命名對齊檢查完成

#### 發現的命名差異（不影響功能）
1. **DropMainActivity** ↔ **DosingMainPage** - ✅ 功能對應，命名可接受
2. **DropHeadMainActivity** ↔ **PumpHeadDetailPage** - ✅ 功能對應，命名可接受
3. **DropHeadAdjustActivity** ↔ **PumpHeadCalibrationPage** - ✅ 功能對應，命名可接受

**結論**: 命名差異可接受，不影響 parity（使用者看不到檔案名稱）

### ✅ Step 3: Parity 驗證完成

#### Fragment 對應（MainActivity 底部導航）
- [x] `HomeFragment` → `HomePage` ✅
- [ ] `BluetoothFragment` → `DeviceScanPage` ⚠️ **位置不符**
- [x] `DeviceFragment` → `DevicePage` ✅

#### Activity 對應
- [x] 所有 26 個 Activity 都有對應的 Page ✅

**結論**: 所有頁面功能都有對應，僅有 1 個結構對齊問題

---

## 發現的問題

### ❌ 問題 1: BluetoothFragment 對應位置不符

**現狀**:
- `DeviceScanPage` 位於 `lib/features/device/presentation/pages/device_scan_page.dart`
- 功能完全對應 `BluetoothFragment`，但位置不對齊

**reef-b-app 依據**:
- `reef-b-app/android/ReefB_Android/app/src/main/res/navigation/main_navigation.xml` 中 `bluetoothFragment` 是獨立的 Fragment
- `reef-b-app/android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/bluetooth/BluetoothFragment.kt` 是獨立的 Fragment 類

**影響**:
- 結構不對齊 reef-b-app
- 功能完整，不影響使用者體驗

**修正方案**:
- 將 `DeviceScanPage` 移到 `lib/features/bluetooth/presentation/pages/bluetooth_page.dart`
- 更新 import 路徑（僅 1 個檔案：`main_scaffold.dart`）

**風險評估**: 低風險（僅檔案位置調整，不改變內容）

---

## 本輪實際調整

### ✅ 已完成的調整

1. **完成架構對照分析**
   - 檢查所有 Activity 和 Fragment 對應
   - 確認所有頁面都有對應實現
   - 識別命名差異（不影響功能）

2. **建立對照文檔**
   - `ARCHITECTURE_PARITY_CHECK.md` - 完整對照分析
   - `ARCHITECTURE_PARITY_ADJUSTMENT_SUMMARY.md` - 本報告

### ⚠️ 待執行的調整（需確認）

1. **將 `DeviceScanPage` 移到 `features/bluetooth/`**
   - **動作**: 
     - 創建 `lib/features/bluetooth/presentation/pages/` 目錄
     - 移動 `device_scan_page.dart` → `bluetooth_page.dart`
     - 更新 `main_scaffold.dart` 的 import
   - **風險**: 低（僅檔案位置調整）
   - **依據**: reef-b-app 的 `BluetoothFragment` 是獨立 Fragment

---

## 修正項目詳細說明

### 修正項目 1: BluetoothFragment 位置對齊

**Parity 依據**:
```
reef-b-app/android/ReefB_Android/app/src/main/res/navigation/main_navigation.xml
- bluetoothFragment (獨立 Fragment)

reef-b-app/android/ReefB_Android/app/src/main/java/.../fragment/bluetooth/BluetoothFragment.kt
- 獨立的 Fragment 類
```

**當前狀態**:
```
koralcore/lib/features/device/presentation/pages/device_scan_page.dart
- 功能對應 BluetoothFragment，但位置在 device/ 下
```

**修正後**:
```
koralcore/lib/features/bluetooth/presentation/pages/bluetooth_page.dart
- 對齊 reef-b-app 的結構
```

**需要更新的檔案**:
1. `lib/app/main_scaffold.dart` - 更新 import 路徑

---

## 不建議的調整

### ❌ 不重命名 `DosingMainPage` 為 `DropMainPage`
- **原因**: 功能已對應，命名差異可接受（domain 層使用 `doser`）
- **影響**: 不影響 parity（使用者看不到檔案名稱）

### ❌ 不重命名 feature 資料夾 `doser`
- **原因**: domain 層使用 `doser_dosing`，保持架構一致性
- **影響**: 不影響 parity

### ❌ 不重新設計架構
- **原因**: 用戶要求「不推倒、不重新設計」
- **影響**: 保持現有架構，僅做必要調整

---

## 總結

### ✅ 符合 Parity
- **所有頁面功能都有對應** ✅
- LED 相關頁面完整對應（13個）
- Dosing 相關頁面完整對應（13個）
- 設備、水槽、警告頁面都有對應

### ⚠️ 結構對齊問題
- **1 個問題**: BluetoothFragment 對應位置不符
- **影響**: 僅結構對齊，不影響功能
- **修正風險**: 低（僅檔案位置調整）

### 📋 下一步
1. 確認是否執行「將 DeviceScanPage 移到 features/bluetooth/」調整
2. 如需執行，按照上述修正方案進行

---

## 附錄：完整對照表

### Fragment 對應

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `HomeFragment` | `HomePage` | ✅ OK |
| `BluetoothFragment` | `DeviceScanPage` (在 device/) | ⚠️ **位置不符** |
| `DeviceFragment` | `DevicePage` | ✅ OK |

### Activity 對應（部分）

| reef-b-app | koralcore | 狀態 |
|-----------|-----------|------|
| `SplashActivity` | `SplashPage` | ✅ OK |
| `MainActivity` | `MainScaffold` | ✅ OK |
| `WarningActivity` | `WarningPage` | ✅ OK |
| `AddDeviceActivity` | `AddDevicePage` | ✅ OK |
| `SinkManagerActivity` | `SinkManagerPage` | ✅ OK |
| `SinkPositionActivity` | `SinkPositionPage` | ✅ OK |
| `LedMainActivity` | `LedMainPage` | ✅ OK |
| `DropMainActivity` | `DosingMainPage` | ✅ OK |
| `DropHeadMainActivity` | `PumpHeadDetailPage` | ✅ OK |
| ... (其他 17 個 Activity 都有對應) | ... | ✅ OK |

**結論**: 所有 Activity 和 Fragment 都有對應實現 ✅

