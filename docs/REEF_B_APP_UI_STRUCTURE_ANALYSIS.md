# reef-b-app UI 構成完整分析

**分析日期**: 2024-12-28  
**目標**: 完整分析 reef-b-app 的 UI 構成方式，包括 layout、組件、圖標、樣式等，作為 koralcore UI 對齊的依據

---

## 📋 目錄

1. [整體架構](#1-整體架構)
2. [Layout 結構](#2-layout-結構)
3. [顏色系統](#3-顏色系統)
4. [文字樣式系統](#4-文字樣式系統)
5. [間距系統](#5-間距系統)
6. [組件樣式](#6-組件樣式)
7. [圖標系統](#7-圖標系統)
8. [背景和形狀](#8-背景和形狀)
9. [頁面構成模式](#9-頁面構成模式)
10. [對齊檢查清單](#10-對齊檢查清單)

---

## 1. 整體架構

### 1.1 主 Activity 結構

**文件**: `activity_main.xml`

```xml
ConstraintLayout (根容器)
├── Toolbar (include @layout/toolbar_app)
├── FragmentContainerView (NavHostFragment)
│   └── 導航圖: @navigation/main_navigation
└── BottomNavigationView
    └── Menu: @menu/main_menu
```

**關鍵特點**:
- ✅ 使用 `ConstraintLayout` 作為根容器
- ✅ Toolbar 固定在頂部
- ✅ FragmentContainerView 用於頁面切換
- ✅ BottomNavigationView 固定在底部
- ✅ 三個主要 Fragment: Home, Bluetooth, Device

### 1.2 Bottom Navigation

**文件**: `main_menu.xml`

**三個主要頁面**:
1. **Home** (`homeFragment`)
   - 圖標: `@drawable/ic_home`
   - 標題: `@string/bottom_navigation_home`

2. **Bluetooth** (`bluetoothFragment`)
   - 圖標: `@drawable/ic_bluetooth`
   - 標題: `@string/bottom_navigation_bluetooth`

3. **Device** (`deviceFragment`)
   - 圖標: `@drawable/ic_device`
   - 標題: `@string/bottom_navigation_device`

**顏色配置**: `@color/bottom_navigation_color` (選擇器)

---

## 2. Layout 結構

### 2.1 Home Fragment (`fragment_home.xml`)

**結構**:
```
ConstraintLayout (背景: @drawable/background_main)
├── ImageView (btn_add_sink) - 左上角，通常隱藏
├── ImageView (btn_warning) - 右上角，通常隱藏
├── Spinner (sp_sink_type) - Sink 選擇器
├── ImageView (img_down) - 下拉箭頭
├── ImageView (btn_sink_manager) - Sink 管理按鈕
├── RecyclerView (rv_user_device) - 設備列表
└── LinearLayout (layout_no_device_in_sink) - 空狀態
```

**關鍵尺寸**:
- `btn_add_sink`: 56dp × 44dp
- `btn_warning`: 56dp × 44dp
- `sp_sink_type`: 101dp × 26dp
- `img_down`: 24dp × 24dp
- `btn_sink_manager`: 30dp × 30dp

**間距**:
- 頂部按鈕 padding: 16dp (start/end), 10dp (top/bottom)
- Sink 選擇器 margin: 16dp (start), 10dp (top)
- RecyclerView padding: 10dp (start/end), 8dp (top)

### 2.2 LED Main Activity (`activity_led_main.xml`)

**結構**:
```
ConstraintLayout
├── Toolbar (include @layout/toolbar_device)
├── TextView (tv_name) - 設備名稱
├── ImageView (btn_ble) - BLE 連接狀態
├── TextView (tv_position) - 位置信息
├── TextView (tv_group) - 群組信息（可選）
├── TextView (tv_record_title) - "Record" 標題
├── ImageView (btn_record_more) - Record 更多按鈕
├── CardView (layout_record_background) - Record 卡片
│   ├── TextView (tv_record_state) - 連接狀態提示
│   └── ConstraintLayout (layout_record) - Record 內容
│       ├── LineChart (line_chart) - 圖表
│       ├── ImageView (btn_expand) - 展開按鈕
│       ├── ImageView (btn_preview) - 預覽按鈕
│       └── ConstraintLayout (layout_record_pause) - 暫停覆蓋層
├── TextView (tv_scene_title) - "LED Scene" 標題
├── ImageView (btn_scene_more) - Scene 更多按鈕
├── RecyclerView (rv_favorite_scene) - 喜愛場景列表
└── Progress (include @layout/progress) - 加載指示器
```

**關鍵尺寸**:
- `btn_ble`: 48dp × 32dp
- `btn_record_more`: 24dp × 24dp
- `btn_scene_more`: 24dp × 24dp
- `line_chart`: 高度 242dp
- `btn_expand`: 24dp × 24dp
- `btn_preview`: 24dp × 24dp

**間距**:
- 設備名稱 margin: 16dp (start), 8dp (top), 4dp (end)
- Record 標題 margin: 20dp (top)
- Scene 標題 margin: 24dp (top)
- 卡片 margin: 4dp (top)
- 卡片內部 padding: 12dp (所有方向)

### 2.3 Toolbar 結構

#### Toolbar App (`toolbar_app.xml`)
```
ConstraintLayout
├── AppBarLayout
│   └── Toolbar
│       ├── MaterialButton (btn_choose) - 選取按鈕（可選）
│       ├── ImageView (btn_delete) - 刪除按鈕（可選）
│       ├── TextView (toolbar_title) - 標題（可選）
│       └── ImageView (btn_right) - 右側按鈕（可選）
└── MaterialDivider - 底部分隔線 (2dp)
```

#### Toolbar Device (`toolbar_device.xml`)
```
ConstraintLayout
├── AppBarLayout
│   └── Toolbar
│       ├── ImageView (btn_back) - 返回按鈕
│       ├── TextView (toolbar_title) - 標題（居中）
│       ├── ImageView (btn_menu) - 菜單按鈕
│       └── ImageView (btn_favorite) - 喜愛按鈕
└── MaterialDivider - 底部分隔線 (2dp)
```

**關鍵尺寸**:
- 按鈕: 56dp × 44dp
- 按鈕 padding: 16dp (start/end), 8dp (top/bottom)
- 分隔線: 2dp 高度

---

## 3. 顏色系統

### 3.1 文字顏色

| 顏色名稱 | 值 | 用途 |
|---------|-----|------|
| `text_aaaa` | `#000000` | 主要文字（黑色） |
| `text_aaaa_40` | `#66000000` | 主要文字 40% 透明度 |
| `text_aaa` | `#BF000000` | 次要文字（75% 不透明度） |
| `text_aa` | `#80000000` | 禁用文字（50% 不透明度） |
| `text_a` | `#33000000` | 極淡文字（20% 不透明度） |

### 3.2 背景顏色

| 顏色名稱 | 值 | 用途 |
|---------|-----|------|
| `bg_aaaa` | `#FFFFFF` | 白色背景（卡片、表面） |
| `bg_aaa` | `#F7F7F7` | 淺灰背景 |
| `bg_aaa_60` | `#99F7F7F7` | 淺灰背景 60% 透明度 |
| `bg_primary` | `#6F916F` | 主色（綠色） |
| `bg_secondary` | `#517651` | 次色（深綠色） |
| `bg_press` | `#0D000000` | 按壓效果（5% 黑色） |
| `white` | `#FFFFFFFF` | 純白色 |
| `white_20` | `#CCFFFFFF` | 白色 80% 不透明度 |

### 3.3 狀態顏色

| 顏色名稱 | 值 | 用途 |
|---------|-----|------|
| `text_success` | `#52D175` | 成功狀態（綠色） |
| `text_info` | `#47A9FF` | 信息狀態（藍色） |
| `text_waring` | `#FFC10A` | 警告狀態（黃色） |
| `text_danger` | `#FF7D4F` | 危險狀態（橙色） |

### 3.4 背景漸變

**主背景** (`background_main.xml`):
- 起始色: `#EFEFEF` (`main_activity_background_start_color`)
- 結束色: `#00FFFFFF` (透明) (`main_activity_background_end_color`)
- 角度: 225 度

---

## 4. 文字樣式系統

### 4.1 文字樣式定義

| 樣式名稱 | 字體大小 | 字重 | 用途 |
|---------|---------|------|------|
| `headline` | 30dp | bold | 大標題 |
| `title1` | 22dp | bold | 標題 1 |
| `title2` | 20dp | bold | 標題 2 |
| `subheader_accent` | 18dp | bold | 副標題（強調） |
| `subheader` | 18dp | normal | 副標題 |
| `body_accent` | 16dp | bold | 正文（強調） |
| `body` | 16dp | normal | 正文 |
| `caption1_accent` | 14dp | bold | 說明文字（強調） |
| `caption1` | 14dp | normal | 說明文字 |
| `caption2_accent` | 12dp | bold | 小說明文字（強調） |
| `caption2` | 12dp | normal | 小說明文字 |

### 4.2 文字樣式使用模式

**單行文字樣式** (`SingleLine`):
- `maxLines="1"`
- `ellipsize="end"`

**可點擊文字樣式** (`TextViewCanClick`):
- `clickable="true"`
- `focusable="true"`
- `maxLines="1"`
- `ellipsize="end"`
- `background="?attr/selectableItemBackground"`

---

## 5. 間距系統

### 5.1 常用間距值

| 尺寸名稱 | 值 | 用途 |
|---------|-----|------|
| `dp_0` | 0dp | 無間距 |
| `dp_1` | 1dp | 細線、邊框 |
| `dp_2` | 2dp | 小間距 |
| `dp_3` | 3dp | 小間距 |
| `dp_4` | 4dp | 小間距 |
| `dp_5` | 5dp | 小間距 |
| `dp_6` | 6dp | 小間距 |
| `dp_7` | 7dp | 小間距 |
| `dp_8` | 8dp | 標準間距 |
| `dp_10` | 10dp | 標準間距 |
| `dp_12` | 12dp | 標準間距 |
| `dp_16` | 16dp | 標準間距 |
| `dp_20` | 20dp | 中等間距 |
| `dp_24` | 24dp | 中等間距 |

### 5.2 組件尺寸

| 尺寸名稱 | 值 | 用途 |
|---------|-----|------|
| `dp_24` | 24dp | 小圖標按鈕 |
| `dp_30` | 30dp | 中等圖標按鈕 |
| `dp_32` | 32dp | 中等按鈕高度 |
| `dp_44` | 44dp | 標準按鈕高度 |
| `dp_48` | 48dp | 大按鈕 |
| `dp_56` | 56dp | 大按鈕（Toolbar） |
| `dp_50` | 50dp | 設備圖標 |
| `dp_101` | 101dp | Sink 選擇器寬度 |
| `dp_26` | 26dp | Sink 選擇器高度 |
| `dp_242` | 242dp | 圖表高度 |

---

## 6. 組件樣式

### 6.1 按鈕樣式

#### ImageviewButton
```xml
<style name="ImageviewButton">
    <item name="android:background">?attr/actionBarItemBackground</item>
    <item name="android:scaleType">fitCenter</item>
</style>
```
- 使用系統的 `actionBarItemBackground` 作為背景
- 圖標居中顯示

#### RoundedButton
```xml
<style name="RoundedButton" parent="Widget.MaterialComponents.Button">
    <item name="cornerRadius">@dimen/dp_20</item>
    <item name="android:textSize">@dimen/dp_12</item>
    <item name="android:insetBottom">@dimen/dp_0</item>
    <item name="android:insetLeft">@dimen/dp_0</item>
    <item name="android:insetRight">@dimen/dp_0</item>
    <item name="android:insetTop">@dimen/dp_0</item>
</style>
```
- 圓角半徑: 20dp
- 文字大小: 12dp
- 無內邊距

#### BackgroundMaterialButton
```xml
<style name="BackgroundMaterialButton">
    <item name="backgroundTint">@color/btn_color_primary_selector</item>
    <item name="shapeAppearance">@style/BackgroundMaterialButton.SmallComponent</item>
    <item name="cornerSize">4dp</item>
    <item name="android:textAppearance">@style/body</item>
</style>
```
- 圓角半徑: 4dp
- 使用選擇器顏色
- 文字樣式: body

### 6.2 卡片樣式

**CardView 標準配置**:
- `cardCornerRadius`: 10dp
- `cardElevation`: 5dp
- 背景: 白色 (`bg_aaaa`)

### 6.3 輸入框樣式

**TextInputLayout**:
- 背景色: `bg_aaa` (`#F7F7F7`)
- 圓角: 4dp (所有角)
- 無邊框 (`boxStrokeWidth="0dp"`)
- 無提示 (`hintEnabled="false"`)

---

## 7. 圖標系統

### 7.1 常用圖標

#### 基本操作
- `ic_add_black.xml` - 添加（黑色）
- `ic_add_rounded.xml` - 添加（圓形）
- `ic_back.xml` - 返回
- `ic_check.xml` - 確認
- `ic_close.xml` - 關閉
- `ic_delete.xml` - 刪除
- `ic_down.xml` - 下拉箭頭
- `ic_menu.xml` - 菜單
- `ic_more_enable.xml` - 更多（啟用）
- `ic_more_disable.xml` - 更多（禁用）

#### 播放控制
- `ic_play_enabled.xml` - 播放（啟用）
- `ic_play_disable.xml` - 播放（禁用）
- `ic_play_select.xml` - 播放（選中）
- `ic_play_unselect.xml` - 播放（未選中）
- `ic_pause.xml` - 暫停
- `ic_stop.xml` - 停止
- `ic_preview.xml` - 預覽

#### 設備和連接
- `ic_home.xml` - 首頁
- `ic_device.xml` - 設備
- `ic_bluetooth.xml` - 藍牙
- `ic_connect_background.xml` - 連接狀態（背景）
- `ic_disconnect_background.xml` - 斷開狀態（背景）
- `ic_disconnect.xml` - 斷開狀態

#### 狀態和功能
- `ic_warning.xml` - 警告
- `ic_warning_robot.xml` - 警告（機器人）
- `ic_favorite_unselect.xml` - 喜愛（未選中）
- `ic_favorite_select.xml` - 喜愛（選中）
- `ic_master.xml` - Master 標記
- `ic_master_big.xml` - Master 標記（大）
- `ic_manager.xml` - 管理

#### 燈光場景
- `ic_sunny.xml` - 晴天
- `ic_cloudy.xml` - 多雲
- `ic_rainy.xml` - 雨天
- `ic_thunder.xml` - 雷電
- `ic_mist.xml` - 霧
- `ic_sunset.xml` - 日落
- `ic_sun_strength.xml` - 陽光強度
- `ic_moon.xml` - 月亮
- `ic_moon_round.xml` - 月亮（圓形）
- `ic_light_off.xml` - 燈關閉

#### 燈光顏色縮圖
- `ic_cold_white_light_thumb.xml` - 冷白光
- `ic_warm_white_light_thumb.xml` - 暖白光
- `ic_royal_blue_light_thumb.xml` - 皇家藍
- `ic_blue_light_thumb.xml` - 藍光
- `ic_green_light_thumb.xml` - 綠光
- `ic_default_thumb.xml` - 默認縮圖

#### 其他
- `ic_calendar.xml` - 日曆
- `ic_zoom_in.xml` - 放大
- `ic_zoom_out.xml` - 縮小
- `ic_none.xml` - 無

### 7.2 圖標使用模式

**圖標按鈕標準尺寸**:
- 小圖標: 24dp × 24dp
- 中等圖標: 30dp × 30dp
- 大圖標按鈕: 56dp × 44dp (Toolbar)
- 設備圖標: 50dp × 50dp

**圖標狀態**:
- 啟用/禁用狀態使用不同的圖標文件
- 選中/未選中狀態使用不同的圖標文件

---

## 8. 背景和形狀

### 8.1 背景資源

#### 主背景 (`background_main.xml`)
```xml
<shape>
    <gradient
        android:angle="225"
        android:startColor="#EFEFEF"
        android:endColor="#00FFFFFF" />
</shape>
```
- 類型: 漸變
- 角度: 225 度
- 起始色: `#EFEFEF` (淺灰)
- 結束色: 透明

#### 白色圓角背景 (`background_white_radius.xml`)
- 白色背景
- 圓角

#### 對話框背景 (`dialog_background.xml`)
- 白色背景
- 圓角

#### Sink 選擇器背景 (`background_sink_spinner.xml`)
- 用於 Spinner 組件

### 8.2 形狀資源

#### 彩虹漸變 (`rainbow_gradient.xml`)
- 用於場景圖標

---

## 9. 頁面構成模式

### 9.1 標準頁面結構

#### 模式 1: 帶 Toolbar 的頁面
```
ConstraintLayout
├── Toolbar (include @layout/toolbar_device 或 toolbar_app)
├── 內容區域
│   ├── 標題/副標題
│   ├── 主要內容（RecyclerView / CardView）
│   └── 操作按鈕
└── Progress (include @layout/progress) - 可選
```

#### 模式 2: Fragment 頁面
```
ConstraintLayout (背景: @drawable/background_main)
├── 頂部操作區（可選）
├── 主要內容
└── 空狀態（可選）
```

### 9.2 列表項模式

#### 設備卡片 (`adapter_device_led.xml`)
```
MaterialCardView
└── ConstraintLayout
    ├── ImageView (img_led) - 設備圖標
    ├── ImageView (img_ble_state) - BLE 狀態
    ├── ImageView (img_favorite) - 喜愛標記
    ├── ImageView (img_led_master) - Master 標記
    ├── TextView (tv_name) - 設備名稱
    ├── TextView (tv_position) - 位置信息
    ├── TextView (tv_group) - 群組信息（可選）
    └── ImageView (img_check) - 選中標記（可選）
```

**卡片配置**:
- `cardCornerRadius`: 10dp
- `cardElevation`: 5dp
- `margin`: 6dp (所有方向)
- `padding`: 12dp (start/end), 10dp (top/bottom)

#### BLE 掃描項 (`adapter_ble_scan.xml`)
```
ConstraintLayout (背景: ?android:selectableItemBackground)
├── ConstraintLayout (背景: @color/bg_aaaa)
│   ├── TextView (tv_ble_type) - 設備類型
│   └── TextView (tv_ble_name) - 設備名稱
└── MaterialDivider - 分隔線
```

**配置**:
- 背景: 白色 (`bg_aaaa`)
- Padding: 16dp (start/end), 8dp (top/bottom)
- 分隔線: 1dp 高度

### 9.3 空狀態模式

**標準空狀態結構**:
```
LinearLayout (垂直方向，居中)
├── TextView (標題) - subheader_accent 樣式
└── TextView (內容) - body 樣式，text_aaa 顏色
```

**間距**:
- 標題和內容之間: 8dp
- 整體居中對齊

---

## 10. 對齊檢查清單

### 10.1 Layout 結構對齊

#### Home 頁面
- [ ] 是否使用 `ReefMainBackground` 作為背景
- [ ] 是否沒有 AppBar
- [ ] 是否有 Sink 選擇器（Spinner）
- [ ] 是否有 Sink 管理按鈕
- [ ] 設備列表是否使用 RecyclerView
- [ ] 空狀態是否正確顯示

#### LED Main 頁面
- [ ] 是否使用 `toolbar_device` 樣式的 Toolbar
- [ ] 設備名稱顯示是否正確
- [ ] BLE 連接狀態圖標是否正確
- [ ] Record 卡片是否使用 CardView
- [ ] 圖表高度是否為 242dp
- [ ] 場景列表是否使用 RecyclerView

### 10.2 顏色對齊

- [ ] 文字顏色是否使用 `ReefColors.textPrimary` (對應 `text_aaaa`)
- [ ] 次要文字是否使用 `ReefColors.textSecondary` (對應 `text_aaa`)
- [ ] 禁用文字是否使用 `ReefColors.textSecondary` 降低透明度 (對應 `text_aa`)
- [ ] 背景是否使用 `ReefColors.surface` (對應 `bg_aaaa`)
- [ ] 主色是否使用 `ReefColors.primary` (對應 `bg_primary`)

### 10.3 文字樣式對齊

- [ ] 是否使用 `ReefTextStyles` 中定義的樣式
- [ ] 字體大小是否匹配（30/22/20/18/16/14/12dp）
- [ ] 字重是否匹配（bold/normal）
- [ ] 單行文字是否使用 `maxLines: 1` 和 `overflow: TextOverflow.ellipsis`

### 10.4 間距對齊

- [ ] 是否使用 `ReefSpacing` 中定義的間距值
- [ ] 標準間距是否為 8dp, 10dp, 12dp, 16dp
- [ ] 卡片 margin 是否為 6dp
- [ ] 卡片 padding 是否為 12dp (水平), 10dp (垂直)

### 10.5 組件樣式對齊

#### 按鈕
- [ ] 圖標按鈕是否使用 `IconButton` 並設置正確尺寸
- [ ] 圓角按鈕是否使用 `cornerRadius: 20dp`
- [ ] 按鈕文字大小是否為 12dp

#### 卡片
- [ ] 是否使用 `Card` 組件
- [ ] 圓角是否為 10dp (`ReefRadius.md`)
- [ ] 陰影是否為 5dp elevation

#### 輸入框
- [ ] 是否使用 `TextField` 或 `TextFormField`
- [ ] 背景色是否為 `#F7F7F7` (`bg_aaa`)
- [ ] 圓角是否為 4dp

### 10.6 圖標對齊

- [ ] 是否使用 `ReefMaterialIcons` 中定義的圖標
- [ ] 圖標尺寸是否正確（24dp/30dp/48dp/56dp）
- [ ] 圖標狀態（啟用/禁用/選中/未選中）是否正確

### 10.7 背景對齊

- [ ] 主頁面是否使用 `ReefMainBackground`
- [ ] 卡片是否使用白色背景
- [ ] 漸變角度是否為 225 度
- [ ] 漸變起始色是否為 `#EFEFEF`

---

## 11. 關鍵差異總結

### 11.1 koralcore 當前實現 vs reef-b-app

| 項目 | reef-b-app | koralcore 當前 | 狀態 |
|------|------------|----------------|------|
| 主背景 | 漸變 `#EFEFEF` → 透明 | `ReefMainBackground` | ✅ 已對齊 |
| Home AppBar | ❌ 無 | ✅ 有 | ⚠️ 需要移除 |
| Sink 選擇器 | ✅ Spinner | ❌ 無 | ⚠️ 需要添加 |
| 文字顏色 | `text_aaaa` / `text_aaa` / `text_aa` | `ReefColors.textPrimary` 等 | ✅ 已對齊 |
| 文字樣式 | 30/22/20/18/16/14/12dp | `ReefTextStyles` | ✅ 已對齊 |
| 卡片圓角 | 10dp | `ReefRadius.md` (10dp) | ✅ 已對齊 |
| 卡片陰影 | 5dp elevation | `elevation: 5` | ✅ 已對齊 |
| 圖標系統 | XML drawable | Material Icons | ⚠️ 需要檢查映射 |
| 按鈕尺寸 | 56dp × 44dp (Toolbar) | 需要檢查 | ⚠️ 需要對齊 |

---

## 12. 下一步行動

### 立即開始（高優先級）

1. **檢查 Home 頁面**
   - [ ] 移除 AppBar
   - [ ] 添加 Sink 選擇器
   - [ ] 添加 Sink 管理按鈕
   - [ ] 調整設備列表顯示方式

2. **檢查 Toolbar**
   - [ ] 確認 Toolbar 樣式是否匹配
   - [ ] 確認按鈕尺寸是否正確
   - [ ] 確認分隔線是否正確

3. **檢查圖標映射**
   - [ ] 確認所有圖標是否正確映射到 Material Icons
   - [ ] 確認圖標尺寸是否正確

### 短期目標（1-2 週）

1. 完成所有頁面的 layout 對齊
2. 完成所有組件的樣式對齊
3. 完成所有圖標的映射和對齊

---

**最後更新**: 2024-12-28  
**維護者**: UI 對齊工程師  
**狀態**: 進行中

