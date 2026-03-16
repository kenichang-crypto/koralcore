# 首頁重新設計計劃 - 匹配 reef-b-app

## 當前設計 vs reef-b-app 設計差異

### reef-b-app 的設計特點

#### 1. **布局結構**
- ❌ **沒有 AppBar**（頂部沒有標題欄）
- ✅ **頂部按鈕區域**：
  - 左上角：添加 Sink 按鈕（通常隱藏）
  - 右上角：警告按鈕
- ✅ **Sink 選擇區域**：
  - 左側：Sink 下拉選擇器（Spinner）
  - 中間：下拉箭頭圖標
  - 右側：Sink 管理按鈕（圖標按鈕）
- ✅ **設備列表區域**：
  - RecyclerView 顯示設備
  - 根據選擇的 Sink 類型動態切換顯示內容

#### 2. **Sink 選擇器功能**
從 HomeFragment.kt 可以看到，Spinner 支持以下選項：
1. **位置 0**：所有 Sink（All Sinks）
   - 使用 `SinkWithDevicesAdapter`
   - LinearLayoutManager（垂直列表）
   - 顯示 Sink 及其包含的設備

2. **位置 1**：喜愛裝置（Favorite Devices）
   - 使用 `DeviceAdapter`
   - GridLayoutManager（2列網格）
   - 只顯示標記為喜愛的設備

3. **位置 2+**：特定 Sink
   - 使用 `DeviceAdapter`
   - GridLayoutManager（2列網格）
   - 顯示該 Sink 下的所有設備

4. **最後一個位置**：未分配裝置（Unassigned Devices）
   - 使用 `DeviceAdapter`
   - GridLayoutManager（2列網格）
   - 顯示未分配到任何 Sink 的設備

#### 3. **背景**
- 使用 `@drawable/background_main`（淺色背景）

### 當前 koralcore 設計

#### 1. **布局結構**
- ✅ **有 AppBar**（顯示 "Home" 標題和警告圖標）
- ✅ **My Reef 卡片**：
  - 顯示設備數量
  - 連接狀態
  - "Connect" 按鈕
- ✅ **設備列表區域**：
  - 顯示所有設備（列表形式）
- ✅ **功能卡片**：
  - LED 功能卡片
  - Dosing 功能卡片

#### 2. **主要差異**

| 項目 | reef-b-app | 當前 koralcore |
|------|------------|----------------|
| AppBar | ❌ 無 | ✅ 有 |
| Sink 選擇器 | ✅ 有（Spinner） | ❌ 無 |
| 設備顯示方式 | ✅ 根據 Sink 動態切換 | ❌ 固定顯示所有設備 |
| 功能卡片 | ❌ 無 | ✅ 有（LED/Dosing） |
| 背景色 | ✅ 淺色 | ✅ 深色（primaryStrong） |

---

## 改造計劃

### Phase 1: 移除 AppBar，添加頂部按鈕區域

**需要修改**：
- 移除 `AppBar`
- 在 `SafeArea` 內添加頂部按鈕區域
- 左側：添加 Sink 按鈕（可選，可先隱藏）
- 右側：警告按鈕

**代碼位置**：`lib/ui/features/home/home_page.dart`

### Phase 2: 添加 Sink 選擇器

**需要實現**：
1. 創建 Sink 下拉選擇器（使用 Flutter 的 `DropdownButton` 或 `PopupMenuButton`）
2. 選項包括：
   - "所有 Sink"
   - "喜愛裝置"
   - 每個 Sink 的選項
   - "未分配裝置"
3. 添加下拉箭頭圖標
4. 添加 Sink 管理按鈕（跳轉到 `SinkManagerPage`）

**需要數據**：
- 所有 Sink 列表
- 當前選中的 Sink
- 設備列表（按 Sink 分組）

### Phase 3: 實現動態設備列表

**需要實現**：
1. 根據選擇的 Sink 類型切換顯示模式：
   - **所有 Sink**：顯示 Sink 卡片，每個 Sink 下顯示其設備（類似 `adapter_sink_with_devices`）
   - **特定 Sink**：網格顯示該 Sink 下的設備（2列）
   - **喜愛裝置**：網格顯示所有喜愛的設備（2列）
   - **未分配裝置**：網格顯示未分配的設備（2列）

2. 創建對應的 Widget：
   - `_SinkWithDevicesView`：顯示 Sink 及其設備
   - `_DeviceGridView`：網格顯示設備（2列）

### Phase 4: 調整背景和樣式

**需要修改**：
- 背景色改為淺色（匹配 reef-b-app 的 `background_main`）
- 調整文字顏色以適應淺色背景
- 移除 "My Reef" 卡片
- 移除 LED/Dosing 功能卡片

### Phase 5: 處理空狀態

**需要實現**：
- 當沒有設備時顯示空狀態
- 標題：`text_no_device_in_sink_title`
- 副標題：`text_no_device_in_sink_content`

---

## 實施步驟建議

### 步驟 1：了解數據結構

需要確認：
1. 如何獲取所有 Sink 列表？
2. 如何獲取每個 Sink 下的設備？
3. 如何獲取喜愛的設備？
4. 如何獲取未分配的設備？

### 步驟 2：創建 ViewModel/Controller

可能需要創建 `HomeController` 來管理：
- Sink 列表
- 當前選中的 Sink
- 設備列表（根據選擇動態更新）

### 步驟 3：逐步實現

1. 先移除 AppBar 和功能卡片
2. 添加頂部按鈕和 Sink 選擇器
3. 實現動態設備列表
4. 調整樣式和背景

---

## 注意事項

1. **保持功能完整性**：移除功能卡片後，需要確保用戶仍然可以訪問 LED 和 Dosing 功能（可能通過設備列表進入）

2. **Sink 數據**：需要確認 Sink 相關的 Repository 和 UseCase 是否已實現

3. **設備分組**：需要實現按 Sink 分組設備的邏輯

4. **導航邏輯**：點擊設備後應該導航到對應的主頁（LED 或 Dosing）

---

## 相關文件

- **reef-b-app 參考**：
  - `android/ReefB_Android/app/src/main/res/layout/fragment_home.xml`
  - `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/home/HomeFragment.kt`
  - `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/fragment/home/HomeViewModel.kt`

- **當前實現**：
  - `lib/ui/features/home/home_page.dart`

- **相關適配器（reef-b-app）**：
  - `adapter_sink_with_devices.xml`
  - `SinkWithDevicesAdapter.kt`
  - `DeviceAdapter.kt`

