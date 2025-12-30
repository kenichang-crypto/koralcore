# 設備卡片圖標對照檢查報告

## 1. 圖標對照表

| 圖標用途 | reef-b-app (drawable) | koralcore (當前使用) | 實際文件 | 狀態 |
|---------|----------------------|---------------------|---------|------|
| 設備圖標 (LED) | `@drawable/img_led` | `assets/icons/device/device_led.png` | ✅ 存在 | ✅ 對照 |
| 設備圖標 (Dosing) | `@drawable/img_drop` | `assets/icons/device/device_doser.png` | ✅ 存在 | ✅ 對照 |
| BLE 連接狀態 (連接) | `@drawable/ic_connect` | `assets/icons/bluetooth/ic_connect.png` | ❌ **缺失** | ❌ **需修正** |
| BLE 連接狀態 (斷開) | `@drawable/ic_disconnect` | `assets/icons/bluetooth/ic_disconnect.png` | ❌ **缺失** | ❌ **需修正** |
| 喜愛圖標 (選中) | `@drawable/ic_favorite_select` | `assets/icons/ic_favorite_select.png` | ❌ **缺失** (有 .svg) | ❌ **需修正** |
| 喜愛圖標 (未選中) | `@drawable/ic_favorite_unselect` | `assets/icons/ic_favorite_unselect.png` | ❌ **缺失** (有 .svg) | ❌ **需修正** |
| Master 圖標 | `@drawable/ic_master` | `assets/icons/ic_master.png` | ❌ **缺失** (有 .svg) | ❌ **需修正** |
| 選擇圖標 | `@drawable/ic_check` | 未使用（主頁不需要） | - | ✅ 對照 |

## 2. 問題分析

### 2.1 BLE 狀態圖標
**問題**：
- 代碼使用：`assets/icons/bluetooth/ic_connect.png` 和 `assets/icons/bluetooth/ic_disconnect.png`
- 實際文件：不存在
- 有 SVG 版本：`assets/icons/common/ic_favorite_*.svg`（但路徑不同）

**reef-b-app 資源**：
- `ic_connect.xml` - 連接狀態圖標
- `ic_disconnect.xml` - 斷開狀態圖標

### 2.2 喜愛圖標
**問題**：
- 代碼使用：`assets/icons/ic_favorite_select.png` 和 `assets/icons/ic_favorite_unselect.png`
- 實際文件：不存在
- 有 SVG 版本：`assets/icons/common/ic_favorite_select.svg` 和 `assets/icons/common/ic_favorite_unselect.svg`

**reef-b-app 資源**：
- `ic_favorite_select.xml` - 選中狀態
- `ic_favorite_unselect.xml` - 未選中狀態

### 2.3 Master 圖標
**問題**：
- 代碼使用：`assets/icons/ic_master.png`（雖然不顯示，但 errorBuilder 中引用）
- 實際文件：不存在
- 有 SVG 版本：`assets/icons/common/ic_master.svg`

**reef-b-app 資源**：
- `ic_master.xml` - Master 標記圖標

## 3. 需要修正的問題

### 3.1 高優先級
1. **❌ BLE 狀態圖標路徑錯誤**：
   - 當前：`assets/icons/bluetooth/ic_connect.png`（不存在）
   - 應該：使用 SVG 版本或創建 PNG 版本
   - 建議：使用 `CommonIconHelper.getBluetoothIcon()` 或 SVG 版本

2. **❌ 喜愛圖標路徑錯誤**：
   - 當前：`assets/icons/ic_favorite_select.png`（不存在）
   - 應該：使用 SVG 版本 `assets/icons/common/ic_favorite_select.svg`
   - 或使用：`CommonIconHelper.getFavoriteSelectIcon()` / `getFavoriteUnselectIcon()`

3. **❌ Master 圖標路徑錯誤**：
   - 當前：`assets/icons/ic_master.png`（不存在）
   - 應該：使用 SVG 版本 `assets/icons/common/ic_master.svg`
   - 或使用：`CommonIconHelper.getMasterIcon()`

## 4. 修正建議

### 方案 1：使用 SVG 版本（推薦）
- 使用 `flutter_svg` 的 `SvgPicture.asset()` 載入 SVG 文件
- 所有圖標都有 SVG 版本，可以直接使用

### 方案 2：使用 CommonIconHelper
- BLE 圖標：`CommonIconHelper.getBluetoothIcon()`
- 喜愛圖標：`CommonIconHelper.getFavoriteSelectIcon()` / `getFavoriteUnselectIcon()`
- Master 圖標：`CommonIconHelper.getMasterIcon()`

### 方案 3：創建 PNG 版本
- 從 SVG 或 XML drawable 轉換為 PNG
- 不推薦（增加資源文件大小）

## 5. 當前錯誤處理

代碼中使用了 `errorBuilder` 作為後備方案：
- BLE 圖標：使用 `CommonIconHelper.getBluetoothIcon()` ✅
- 喜愛圖標：使用 `CommonIconHelper.getFavoriteSelectIcon()` / `getFavoriteUnselectIcon()` ✅
- Master 圖標：使用 `CommonIconHelper.getFavoriteSelectIcon()` ⚠️（應該使用 `getMasterIcon()`）

**問題**：雖然有 errorBuilder，但圖標路徑錯誤會導致每次載入都觸發錯誤處理，影響性能。

