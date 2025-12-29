# Layout 結構對照分析 - reef-b-app vs koralcore

## 概述

本文檔詳細分析 `reef-b-app` 的 Android XML layout 結構及其邏輯，並對照 `koralcore` 的 Flutter Widget 實現。

**關鍵差異**：
- `reef-b-app`：使用 XML layout 文件（靜態聲明式）
- `koralcore`：使用 Flutter Widget 樹（動態構建式）
- **koralcore 沒有對應的 XML layout 文件**，所有 UI 都是通過 Dart 代碼動態生成的

---

## 1. Home 頁面對照

### 1.1 reef-b-app: `fragment_home.xml`

#### Layout 結構
```xml
ConstraintLayout (根容器)
├── ImageView (btn_add_sink) - 左上角，通常隱藏
├── ImageView (btn_warning) - 右上角，通常隱藏
├── Spinner (sp_sink_type) - Sink 選擇器
├── ImageView (img_down) - 下拉箭頭
├── ImageView (btn_sink_manager) - Sink 管理按鈕
├── RecyclerView (rv_user_device) - 設備列表
└── LinearLayout (layout_no_device_in_sink) - 空狀態
```

#### 邏輯實現 (`HomeFragment.kt`)

**關鍵邏輯**：
1. **Spinner 選擇邏輯**（`setListener()`）：
   - **位置 0**：所有 Sink → 使用 `SinkWithDevicesAdapter` + `LinearLayoutManager`
   - **位置 1**：喜愛裝置 → 使用 `DeviceAdapter` + `GridLayoutManager(2列)`
   - **位置 2+**：特定 Sink → 使用 `DeviceAdapter` + `GridLayoutManager(2列)`
   - **最後位置**：未分配裝置 → 使用 `DeviceAdapter` + `GridLayoutManager(2列)`

2. **數據觀察**（`setObserver()`）：
   - `sinkListLiveData` → 更新 `SinkWithDevicesAdapter`
   - `deviceListLiveData` → 更新 `DeviceAdapter`（排序：favorite > master > group > sinkId）

3. **空狀態切換**（`sinkIsEmpty()`）：
   - `isEmpty = true` → 隱藏 RecyclerView，顯示空狀態
   - `isEmpty = false` → 顯示 RecyclerView，隱藏空狀態

#### Adapter Layout 對照

**`adapter_sink_with_devices.xml`**：
- 包含一個內嵌的 `RecyclerView`，用於顯示該 Sink 下的設備列表
- 使用 `adapter_device_led.xml` 或 `adapter_device_drop.xml` 作為 item layout

**`adapter_device_led.xml`**：
- `MaterialCardView`（圓角 10dp，elevation 5dp，margin 6dp）
- 包含：設備圖標、BLE 狀態圖標、喜愛圖標、Master 圖標、設備名稱、位置、群組

### 1.2 koralcore: `home_page.dart`

#### Widget 結構
```dart
Scaffold
└── ReefMainBackground
    └── SafeArea
        └── Column
            ├── _TopButtonBar (警告按鈕)
            ├── _SinkSelectorBar (Sink 選擇器 - 臨時實現)
            └── Expanded
                ├── ListView (設備列表) 或
                └── _EmptyState (空狀態)
```

#### 對照分析

| reef-b-app XML | reef-b-app 邏輯 | koralcore Widget | 狀態 |
|----------------|-----------------|------------------|------|
| `ConstraintLayout` | 根容器 | `Column` | ✅ 對應 |
| `ImageView btn_warning` | 右上角警告按鈕 | `_TopButtonBar` | ✅ 已實現 |
| `Spinner sp_sink_type` | Sink 選擇器 | `_SinkSelectorBar` | ⚠️ **臨時實現**（使用 Text，需改為 DropdownButton） |
| `ImageView img_down` | 下拉箭頭 | `_SinkSelectorBar` 內的 Icon | ✅ 已實現 |
| `ImageView btn_sink_manager` | Sink 管理按鈕 | `_SinkSelectorBar` 內的 IconButton | ✅ 已實現 |
| `RecyclerView rv_user_device` | 設備列表 | `ListView` | ⚠️ **差異**：未實現動態切換 Adapter/LayoutManager |
| `LinearLayout layout_no_device_in_sink` | 空狀態 | `_EmptyState` | ✅ 已實現 |

#### 關鍵差異

1. **Sink 選擇器功能不完整**：
   - reef-b-app：完整的 Spinner，支持動態切換 Adapter 和 LayoutManager
   - koralcore：臨時使用 Text 顯示，未實現下拉選擇和數據切換邏輯

2. **設備列表顯示方式**：
   - reef-b-app：根據 Spinner 選擇動態切換：
     - 所有 Sink：垂直列表（`SinkWithDevicesAdapter`）
     - 其他選項：2列網格（`DeviceAdapter`）
   - koralcore：固定使用垂直列表（`ListView`），未實現網格布局

3. **設備卡片樣式**：
   - reef-b-app：`MaterialCardView`（圓角 10dp，elevation 5dp，margin 6dp）
   - koralcore：`Container`（圓角 `ReefRadius.lg`，無 elevation，padding 不同）

---

## 2. Bluetooth 頁面對照

### 2.1 reef-b-app: `fragment_bluetooth.xml`

#### Layout 結構
```xml
ScrollView (根容器)
└── ConstraintLayout
    ├── RecyclerView (rv_user_device) - 已保存設備列表
    ├── TextView (tv_other_device_title) - "其他裝置"標題
    ├── TextView (btn_refresh) - "重新整理"按鈕
    ├── CircularProgressIndicator (progress_scan) - 掃描進度
    ├── RecyclerView (rv_other_device) - 掃描到的設備列表
    └── LinearLayout (layout_no_other_device) - 空狀態
```

#### 邏輯實現

**Adapter**：
- `rv_user_device`：使用 `BLEMyDeviceAdapter`（顯示已保存設備）
- `rv_other_device`：使用 `BLEAdapter`（顯示掃描到的設備，使用 `adapter_ble_scan.xml`）

**`adapter_ble_scan.xml`**：
- `ConstraintLayout`（背景 `bg_aaaa`，padding 16dp）
- 包含：BLE 類型（LED/DROP）、設備名稱
- 底部有分隔線（`MaterialDivider`，高度 1dp）

### 2.2 koralcore: `bluetooth_page.dart`

#### Widget 結構
```dart
Scaffold
├── AppBar
└── ReefMainBackground
    └── SafeArea
        └── ListView
            ├── 警告文字
            ├── BleGuardBanner (如果 BLE 未就緒)
            ├── _ScanButton
            └── _DeviceSections
                ├── _SectionHeader ("裝置")
                ├── _BtDeviceTile[] (已保存設備)
                ├── _SectionHeader ("藍牙")
                └── _DiscoveredSection
                    ├── _ScanningRow (掃描中) 或
                    ├── _BtDeviceTile[] (掃描到的設備) 或
                    └── _DiscoveredEmptyCard (空狀態)
```

#### 對照分析

| reef-b-app XML | reef-b-app 邏輯 | koralcore Widget | 狀態 |
|----------------|-----------------|------------------|------|
| `ScrollView` | 可滾動容器 | `ListView` | ✅ 對應 |
| `RecyclerView rv_user_device` | 已保存設備 | `_BtDeviceTile[]` | ✅ 已實現 |
| `TextView tv_other_device_title` | "其他裝置"標題 | `_SectionHeader` | ✅ 已實現 |
| `TextView btn_refresh` | 重新整理按鈕 | `_ScanButton` | ✅ 已實現 |
| `CircularProgressIndicator` | 掃描進度 | `_ScanningRow` | ✅ 已實現 |
| `RecyclerView rv_other_device` | 掃描到的設備 | `_BtDeviceTile[]` | ✅ 已實現 |
| `LinearLayout layout_no_other_device` | 空狀態 | `_DiscoveredEmptyCard` | ✅ 已實現 |

#### 關鍵差異

1. **布局結構**：
   - reef-b-app：使用 `ScrollView` + `ConstraintLayout`（固定布局）
   - koralcore：使用 `ListView`（動態列表，更靈活）

2. **設備卡片樣式**：
   - reef-b-app：`adapter_ble_scan.xml`（簡單的 ConstraintLayout，背景 `bg_aaaa`）
   - koralcore：`_BtDeviceTile`（Container，背景 `ReefColors.surface`，圓角）

---

## 3. Device 頁面對照

### 3.1 reef-b-app: `fragment_device.xml`

#### Layout 結構
```xml
ConstraintLayout (根容器)
└── RecyclerView (rv_user_device) - 設備列表
    └── LinearLayout (layout_no_device) - 空狀態（包含機器人圖標和"新增裝置"按鈕）
```

**注意**：`fragment_device.xml` 中 Spinner 相關代碼被註釋掉了。

### 3.2 koralcore: `device_page.dart`

#### Widget 結構
```dart
Scaffold
├── AppBar (支持選擇模式)
└── ReefMainBackground
    └── SafeArea
        └── RefreshIndicator
            └── CustomScrollView
                ├── SliverToBoxAdapter (BleGuardBanner)
                ├── SliverToBoxAdapter (_ActionsBar)
                ├── SliverToBoxAdapter (_SectionHeader "裝置")
                ├── SliverGrid (已保存設備 - 2列網格) 或
                │   └── SliverToBoxAdapter (_EmptyState)
                ├── SliverToBoxAdapter (_SectionHeader "藍牙")
                └── SliverList (掃描到的設備)
```

#### 對照分析

| reef-b-app XML | reef-b-app 邏輯 | koralcore Widget | 狀態 |
|----------------|-----------------|------------------|------|
| `RecyclerView` | 設備列表 | `SliverGrid` (2列) | ✅ 已實現 |
| `LinearLayout layout_no_device` | 空狀態 | `_EmptyState` | ✅ 已實現 |

**差異**：
- reef-b-app：簡單的垂直列表
- koralcore：使用 2列網格布局（`SliverGrid`），更符合現代設計

---

## 4. LED Main 頁面對照

### 4.1 reef-b-app: `activity_led_main.xml`

#### Layout 結構
```xml
ConstraintLayout (根容器)
├── include toolbar_device (toolbar_led_main)
├── TextView (tv_name) - 設備名稱
├── ImageView (btn_ble) - BLE 狀態圖標
├── TextView (tv_position) - 位置
├── TextView (tv_group) - 群組（可隱藏）
├── TextView (tv_record_title) - "記錄"標題
├── ImageView (btn_record_more) - 記錄更多按鈕
├── CardView (layout_record_background) - 記錄卡片
│   ├── TextView (tv_record_state) - 未連接狀態
│   └── ConstraintLayout (layout_record) - 記錄內容
│       ├── LineChart (line_chart)
│       ├── ImageView (btn_expand) - 展開按鈕
│       ├── ImageView (btn_preview) - 預覽按鈕
│       └── ConstraintLayout (layout_record_pause) - 暫停覆蓋層
├── TextView (tv_scene_title) - "LED 場景"標題
├── ImageView (btn_scene_more) - 場景更多按鈕
├── RecyclerView (rv_favorite_scene) - 喜愛場景列表
└── include progress (進度指示器)
```

#### Toolbar 結構 (`toolbar_device.xml`)
```xml
ConstraintLayout
├── AppBarLayout
│   └── Toolbar
│       ├── ImageView (btn_back) - 返回按鈕
│       ├── TextView (toolbar_title) - 標題
│       ├── ImageView (btn_menu) - 菜單按鈕
│       └── ImageView (btn_favorite) - 喜愛按鈕
└── MaterialDivider (divider) - 2dp 分隔線
```

### 4.2 koralcore: `led_main_page.dart`

#### Widget 結構
```dart
Scaffold
├── AppBar
│   ├── leading (返回按鈕)
│   ├── title (設備名稱)
│   └── actions (喜愛、展開、菜單按鈕)
└── ReefMainBackground
    └── SafeArea
        └── CustomScrollView
            ├── SliverToBoxAdapter (設備信息區域)
            ├── SliverToBoxAdapter (記錄卡片)
            └── SliverToBoxAdapter (場景列表)
```

#### 對照分析

| reef-b-app XML | reef-b-app 邏輯 | koralcore Widget | 狀態 |
|----------------|-----------------|------------------|------|
| `include toolbar_device` | Toolbar | `AppBar` | ✅ 已實現 |
| `MaterialDivider` | 2dp 分隔線 | ❌ **缺失** | ⚠️ 需添加 |
| `TextView tv_name` | 設備名稱 | `AppBar.title` | ✅ 已實現 |
| `ImageView btn_ble` | BLE 狀態 | ❌ **缺失** | ⚠️ 需添加 |
| `TextView tv_position` | 位置 | ❌ **缺失** | ⚠️ 需添加 |
| `TextView tv_group` | 群組 | ❌ **缺失** | ⚠️ 需添加 |
| `CardView layout_record_background` | 記錄卡片 | `_LedRecordCard` | ✅ 已實現 |
| `RecyclerView rv_favorite_scene` | 場景列表 | `_FavoriteScenesList` | ✅ 已實現 |

---

## 5. 通用組件對照

### 5.1 Toolbar

#### reef-b-app: `toolbar_app.xml` / `toolbar_device.xml`

**`toolbar_app.xml`**（主頁面使用）：
- `AppBarLayout` + `Toolbar`（白色背景）
- 可選按鈕：`btn_choose`、`btn_delete`、`btn_right`（警告圖標）
- `MaterialDivider`（2dp 分隔線，顏色 `bg_press`）

**`toolbar_device.xml`**（設備頁面使用）：
- `AppBarLayout` + `Toolbar`（白色背景）
- 固定按鈕：`btn_back`、`toolbar_title`、`btn_menu`、`btn_favorite`
- `MaterialDivider`（2dp 分隔線，顏色 `bg_press`）

#### koralcore

**主頁面**：
- 使用 `MainScaffold`，**沒有 AppBar**（符合 reef-b-app 設計）

**設備頁面**：
- 使用 `AppBar`（Material Design 標準組件）
- **缺失**：2dp 分隔線

### 5.2 Bottom Navigation

#### reef-b-app: `main_menu.xml`

```xml
<menu>
    <item android:id="@+id/nav_home" ... />
    <item android:id="@+id/nav_bluetooth" ... />
    <item android:id="@+id/nav_device" ... />
</menu>
```

#### koralcore: `main_scaffold.dart`

```dart
NavigationBar
├── NavigationDestination (Home)
├── NavigationDestination (Bluetooth)
└── NavigationDestination (Device)
```

✅ **已對齊**

---

## 6. Layout 邏輯映射總結

### 6.1 XML → Widget 映射規則

| reef-b-app XML | koralcore Widget | 說明 |
|----------------|------------------|------|
| `ConstraintLayout` | `Column` / `Row` / `Stack` | 根據約束關係選擇對應 Widget |
| `LinearLayout` | `Row` / `Column` | 根據 `orientation` 選擇 |
| `RecyclerView` | `ListView` / `GridView` / `SliverList` / `SliverGrid` | 根據 LayoutManager 選擇 |
| `CardView` | `Card` | Material Design 組件 |
| `ImageView` | `Image` / `Icon` | 根據用途選擇 |
| `TextView` | `Text` | 文本顯示 |
| `Spinner` | `DropdownButton` | 下拉選擇器 |
| `MaterialDivider` | `Divider` | 分隔線 |
| `include` | 自定義 Widget | 重用組件 |

### 6.2 狀態管理映射

| reef-b-app | koralcore | 說明 |
|------------|-----------|------|
| `LiveData` | `ChangeNotifier` / `Stream` | 狀態觀察 |
| `ViewModel` | `Controller` / `Provider` | 業務邏輯 |
| `Fragment` | `StatelessWidget` / `StatefulWidget` | UI 組件 |
| `Adapter` | `ListView.builder` / `GridView.builder` | 列表渲染 |

---

## 7. 需要對齊的關鍵差異

### 7.1 高優先級

1. **Home 頁面 Sink 選擇器**：
   - ❌ koralcore 使用臨時 Text 實現
   - ✅ 需實現完整的 `DropdownButton`，支持動態切換數據源和布局

2. **Home 頁面設備列表布局切換**：
   - ❌ koralcore 固定使用垂直列表
   - ✅ 需實現根據 Sink 選擇動態切換：垂直列表（所有 Sink）vs 2列網格（其他選項）

3. **設備卡片樣式**：
   - ❌ koralcore 使用 `Container`，無 elevation
   - ✅ 需改為 `Card`，設置圓角 10dp、elevation 5dp、margin 6dp

4. **Toolbar 分隔線**：
   - ❌ koralcore 所有頁面都缺失 2dp 分隔線
   - ✅ 需在 AppBar 下方添加 `Divider`（高度 2dp，顏色 `bg_press`）

### 7.2 中優先級

5. **LED Main 頁面設備信息區域**：
   - ❌ koralcore 缺失 BLE 狀態圖標、位置、群組顯示
   - ✅ 需添加設備信息區域（類似 reef-b-app 的 `tv_name`、`btn_ble`、`tv_position`、`tv_group`）

6. **Bluetooth 頁面設備卡片樣式**：
   - ⚠️ koralcore 使用較複雜的卡片樣式
   - ✅ 需簡化為類似 `adapter_ble_scan.xml` 的簡單樣式（背景 `bg_aaaa`，簡單布局）

---

## 8. 實現建議

### 8.1 創建對應的 Widget 組件

建議在 `koralcore/lib/ui/widgets/` 下創建以下組件：

1. **`reef_toolbar.dart`**：對應 `toolbar_device.xml`
   - 包含返回按鈕、標題、菜單按鈕、喜愛按鈕
   - 底部包含 2dp 分隔線

2. **`sink_selector.dart`**：對應 `Spinner sp_sink_type`
   - 實現完整的下拉選擇功能
   - 支持動態數據源切換

3. **`device_card_home.dart`**：對應 `adapter_device_led.xml`
   - 使用 `Card`（圓角 10dp，elevation 5dp，margin 6dp）
   - 包含所有必要的信息顯示

### 8.2 修改現有頁面

1. **`home_page.dart`**：
   - 替換 `_SinkSelectorBar` 為完整的 `SinkSelector` Widget
   - 實現設備列表的動態布局切換（垂直列表 vs 2列網格）
   - 將 `_HomeDeviceTile` 改為使用 `Card` 組件

2. **`led_main_page.dart`**：
   - 在 `AppBar` 下方添加 `Divider`（2dp）
   - 添加設備信息區域（BLE 狀態、位置、群組）

3. **`bluetooth_page.dart`**：
   - 簡化 `_BtDeviceTile` 樣式，對齊 `adapter_ble_scan.xml`

---

## 9. 總結

**核心發現**：
- koralcore **沒有對應的 XML layout 文件**，所有 UI 都是通過 Dart 代碼動態生成
- 需要通過分析 reef-b-app 的 XML layout 和 Fragment/Activity 邏輯，來理解 UI 結構和行為
- 然後在 koralcore 中實現對應的 Flutter Widget 樹

**對齊策略**：
1. 分析 reef-b-app 的 XML layout 結構
2. 分析 Fragment/Activity 的邏輯實現
3. 在 koralcore 中創建對應的 Widget 組件
4. 確保視覺樣式和交互行為一致

**下一步行動**：
1. 優先修復 Home 頁面的 Sink 選擇器和設備列表布局切換
2. 統一設備卡片樣式（使用 Card，設置正確的圓角、elevation、margin）
3. 在所有頁面的 AppBar 下方添加 2dp 分隔線

