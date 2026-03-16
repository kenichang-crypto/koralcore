# UI 對齊主計劃 - koralcore 對齊 reef-b-app

**制定日期**: 2024-12-28  
**目標**: 將 koralcore 的 UI 完全對齊 reef-b-app 的視覺設計和交互行為

---

## 📋 我的理解確認

### 1. reef-b-app UI 架構理解

#### ✅ 我已經了解：

1. **整體結構**：
   - 主 Activity：`ConstraintLayout` + `Toolbar` + `FragmentContainerView` + `BottomNavigationView`
   - 三個主要 Fragment：Home、Bluetooth、Device
   - 所有頁面使用 `background_main` 漸變背景（`#EFEFEF` → 透明，225度）

2. **Home 頁面** (`fragment_home.xml`)：
   - ❌ **沒有 AppBar**
   - 頂部按鈕：左上角添加 Sink（通常隱藏）、右上角警告按鈕
   - Sink 選擇器：`Spinner`（101×26dp），支持動態切換數據源和布局
   - 設備列表：根據選擇動態切換（垂直列表 vs 2列網格）
   - 設備卡片：`MaterialCardView`（圓角 10dp，elevation 5dp，margin 6dp）

3. **Toolbar 系統**：
   - `toolbar_app.xml`：主頁面 Toolbar（白色背景，2dp 分隔線）
   - `toolbar_device.xml`：設備頁面 Toolbar（返回、標題、菜單、喜愛按鈕，2dp 分隔線）
   - 所有 Toolbar 下方都有 `MaterialDivider`（2dp，顏色 `bg_press`）

4. **顏色系統** (`colors.xml`)：
   - 文字：`text_aaaa` (#000000)、`text_aaa` (#BF000000)、`text_aa` (#80000000)
   - 背景：`bg_primary` (#6F916F)、`bg_aaaa` (#FFFFFF)、`bg_aaa` (#F7F7F7)
   - 分隔線：`bg_press` (#0D000000)

5. **尺寸系統** (`dimens.xml`)：
   - 標準間距：4dp, 6dp, 8dp, 10dp, 12dp, 16dp, 20dp, 24dp
   - 卡片圓角：10dp
   - 卡片 elevation：5dp
   - 卡片 margin：6dp

6. **文字樣式系統** (`styles.xml`)：
   - `headline`: 30dp, bold
   - `title1`: 22dp, bold
   - `title2`: 20dp, bold
   - `subheader_accent`: 18dp, bold
   - `body_accent`: 16dp, bold
   - `body`: 16dp, normal
   - `caption1_accent`: 14dp, bold
   - `caption1`: 14dp, normal
   - `caption2`: 12dp, normal

7. **自定義組件**：
   - `CustomDashBoard`：半圓形儀表盤（用於 Initial Intensity 顯示）

---

## 🎯 對齊目標

### 視覺對齊度目標：100%

| 類別 | 當前狀態 | 目標狀態 |
|------|----------|----------|
| 頁面結構 | ~70% | 100% |
| 組件樣式 | ~60% | 100% |
| 顏色系統 | ~80% | 100% |
| 尺寸系統 | ~70% | 100% |
| 文字樣式 | ~80% | 100% |
| 交互行為 | ~90% | 100% |

---

## 📅 三階段實施計劃

### 🔴 階段 1：核心視覺對齊（優先級最高）

**目標**：修復最明顯的視覺差異，確保基本視覺一致性

**時間**：1-2 週

#### 任務 1.1：實現 Toolbar 分隔線系統

**問題**：
- 所有頁面的 AppBar 下方都缺少 2dp 分隔線
- 影響所有頁面的視覺一致性

**解決方案**：
1. 創建 `ReefAppBar` 組件（包含 AppBar + Divider）
2. 替換所有頁面的 `AppBar` 為 `ReefAppBar`
3. 設置 Divider：高度 2dp，顏色 `bg_press`

**影響範圍**：
- 所有使用 AppBar 的頁面（約 25+ 個頁面）

**驗證標準**：
- ✅ 所有頁面 AppBar 下方都有 2dp 分隔線
- ✅ 分隔線顏色為 `bg_press` (#0D000000)

---

#### 任務 1.2：對齊設備卡片樣式

**問題**：
- 當前使用 `Container`，無 elevation
- 圓角、margin、padding 不匹配

**解決方案**：
1. 創建 `ReefDeviceCard` 組件
2. 使用 `Card`（elevation 5dp）
3. 設置圓角 10dp、margin 6dp
4. 替換所有設備卡片組件

**影響範圍**：
- `HomePage`：`_HomeDeviceTile`
- `DevicePage`：`DeviceCard`
- `BluetoothPage`：`_BtDeviceTile`

**驗證標準**：
- ✅ 所有設備卡片使用 `Card` 組件
- ✅ 圓角：10dp
- ✅ Elevation：5dp
- ✅ Margin：6dp（所有方向）

---

#### 任務 1.3：實現 CustomDashBoard（半圓形儀表盤）

**問題**：
- `LedRecordSettingPage` 缺少半圓形儀表盤組件
- 影響 Initial Intensity 的視覺顯示

**解決方案**：
1. 創建 `SemiCircleDashboard` 組件（使用 `CustomPainter`）
2. 實現半圓形進度條繪製
3. 支持百分比顯示（0-100%）
4. 顏色：`dashboard_progress` (#5599FF)

**影響範圍**：
- `LedRecordSettingPage`

**驗證標準**：
- ✅ 半圓形儀表盤正確顯示
- ✅ 進度條顏色為藍色 (#5599FF)
- ✅ 百分比文字居中顯示

---

#### 任務 1.4：實現 Home 頁面 Sink 選擇器

**問題**：
- 當前使用臨時 `Text` 顯示
- 缺少下拉選擇功能
- 缺少動態數據源切換

**解決方案**：
1. 實現完整的 `SinkSelector` Widget
2. 使用 `DropdownButton` 或 `PopupMenuButton`
3. 支持選項：
   - "所有 Sink"（位置 0）
   - "喜愛裝置"（位置 1）
   - 特定 Sink（位置 2+）
   - "未分配裝置"（最後位置）
4. 實現數據源切換邏輯

**影響範圍**：
- `HomePage`

**驗證標準**：
- ✅ Sink 選擇器可以下拉選擇
- ✅ 選擇後數據源正確切換
- ✅ 布局正確切換（垂直列表 vs 2列網格）

---

### 🟡 階段 2：布局結構對齊（優先級中）

**目標**：對齊布局結構和交互行為

**時間**：1-2 週

#### 任務 2.1：實現 Home 頁面動態布局切換

**問題**：
- 當前固定使用 `ListView`（垂直列表）
- 缺少 2列網格布局

**解決方案**：
1. 根據 Sink 選擇器選擇動態切換布局
2. "所有 Sink"：使用 `ListView`（垂直列表）
3. 其他選項：使用 `GridView`（2列網格）
4. 實現 `SinkWithDevicesAdapter` 對應的嵌套列表

**影響範圍**：
- `HomePage`

**驗證標準**：
- ✅ "所有 Sink" 顯示為垂直列表
- ✅ 其他選項顯示為 2列網格
- ✅ 切換流暢無閃爍

---

#### 任務 2.2：添加 LED Main 頁面設備信息區域

**問題**：
- 缺少 BLE 狀態圖標
- 缺少位置和群組顯示

**解決方案**：
1. 在 AppBar 下方添加設備信息區域
2. 顯示：設備名稱、BLE 狀態圖標、位置、群組
3. 對齊 `activity_led_main.xml` 的布局結構

**影響範圍**：
- `LedMainPage`

**驗證標準**：
- ✅ 設備信息區域正確顯示
- ✅ BLE 狀態圖標正確顯示連接狀態
- ✅ 位置和群組信息正確顯示

---

#### 任務 2.3：對齊主要 Adapter 樣式

**問題**：
- 多個 Adapter 組件的樣式細節不匹配

**解決方案**：
1. 對齊 `adapter_ble_scan.xml` 樣式（簡化背景 `bg_aaaa`）
2. 對齊 `adapter_favorite_scene.xml` 樣式
3. 對齊 `adapter_scene.xml` 樣式
4. 對齊其他主要 Adapter 樣式

**影響範圍**：
- 所有列表項組件

**驗證標準**：
- ✅ 所有 Adapter 樣式與 reef-b-app 一致
- ✅ 顏色、尺寸、間距正確

---

### 🟢 階段 3：細節完善（優先級低）

**目標**：完善所有細節，達到 100% 對齊

**時間**：2-3 週

#### 任務 3.1：對齊所有 Adapter 樣式細節

**問題**：
- 21 個 Adapter 組件的樣式細節需要逐一對齊

**解決方案**：
1. 逐一檢查每個 Adapter 的 XML layout
2. 對齊顏色、尺寸、間距、圓角等所有細節
3. 確保視覺完全一致

**影響範圍**：
- 所有 Adapter 組件（21 個）

---

#### 任務 3.2：對齊所有頁面布局細節

**問題**：
- 25 個 Activity 頁面的布局細節需要逐一對齊

**解決方案**：
1. 逐一檢查每個 Activity 的 XML layout
2. 對齊布局結構、組件位置、間距等
3. 確保布局完全一致

**影響範圍**：
- 所有 Activity 頁面（25 個）

---

#### 任務 3.3：視覺回歸測試

**問題**：
- 需要確保所有修改後視覺正確

**解決方案**：
1. 創建視覺對照檢查清單
2. 逐一對照每個頁面
3. 截圖對比驗證

---

## 📊 實施時間表

| 階段 | 任務 | 預計時間 | 優先級 |
|------|------|----------|--------|
| **階段 1** | 任務 1.1：Toolbar 分隔線 | 2 小時 | 🔴 最高 |
| | 任務 1.2：設備卡片樣式 | 4 小時 | 🔴 最高 |
| | 任務 1.3：CustomDashBoard | 6 小時 | 🔴 最高 |
| | 任務 1.4：Sink 選擇器 | 4 小時 | 🔴 最高 |
| **小計** | | **16 小時（2 天）** | |
| **階段 2** | 任務 2.1：動態布局切換 | 4 小時 | 🟡 中 |
| | 任務 2.2：LED Main 設備信息 | 2 小時 | 🟡 中 |
| | 任務 2.3：主要 Adapter 樣式 | 8 小時 | 🟡 中 |
| **小計** | | **14 小時（2 天）** | |
| **階段 3** | 任務 3.1：所有 Adapter 樣式 | 16 小時 | 🟢 低 |
| | 任務 3.2：所有頁面布局 | 20 小時 | 🟢 低 |
| | 任務 3.3：視覺回歸測試 | 8 小時 | 🟢 低 |
| **小計** | | **44 小時（6 天）** | |
| **總計** | | **74 小時（約 2 週）** | |

---

## ✅ 驗證檢查清單

### 階段 1 驗證

- [ ] 所有頁面 AppBar 下方都有 2dp 分隔線
- [ ] 所有設備卡片使用 Card（圓角 10dp，elevation 5dp，margin 6dp）
- [ ] CustomDashBoard 正確顯示半圓形進度條
- [ ] Home 頁面 Sink 選擇器可以下拉選擇並切換數據源

### 階段 2 驗證

- [ ] Home 頁面可以動態切換布局（垂直列表 vs 2列網格）
- [ ] LED Main 頁面顯示設備信息區域（BLE 狀態、位置、群組）
- [ ] 主要 Adapter 樣式與 reef-b-app 一致

### 階段 3 驗證

- [ ] 所有 21 個 Adapter 樣式完全對齊
- [ ] 所有 25 個 Activity 頁面布局完全對齊
- [ ] 視覺回歸測試通過

---

## 🚀 立即開始

### 建議執行順序

1. **今天**：任務 1.1（Toolbar 分隔線）- 影響最大，工作量最小
2. **明天**：任務 1.2（設備卡片樣式）- 影響多個頁面
3. **後天**：任務 1.3（CustomDashBoard）- 需要自定義繪製
4. **大後天**：任務 1.4（Sink 選擇器）- 需要完整功能實現

### 需要我開始實施嗎？

我可以立即開始：
1. ✅ 創建 `ReefAppBar` 組件（包含分隔線）
2. ✅ 創建 `ReefDeviceCard` 組件
3. ✅ 創建 `SemiCircleDashboard` 組件
4. ✅ 實現 `SinkSelector` 組件

**準備好了嗎？我可以立即開始階段 1 的實施！**

