# koralcore UI 對齊行動計劃

**目標**: 將 koralcore UI 完全對齊 reef-b-app 的構成方式  
**分析日期**: 2024-12-28

---

## 🔍 關鍵發現

### 1. 主要架構差異

| 項目 | reef-b-app | koralcore 當前 | 需要對齊 |
|------|------------|----------------|----------|
| **主結構** | Toolbar + FragmentContainerView + BottomNavigationView | IndexedStack + NavigationBar | ⚠️ 需要檢查 |
| **Home 頁面** | ❌ 無 AppBar | ✅ 有 AppBar | ⚠️ **需要移除** |
| **Toolbar** | 白色背景 + 2dp 分隔線 | 需要檢查 | ⚠️ 需要對齊 |
| **Bottom Navigation** | BottomNavigationView (Material) | NavigationBar (Material 3) | ⚠️ 需要對齊樣式 |

### 2. Home 頁面差異

| 項目 | reef-b-app | koralcore 當前 | 需要對齊 |
|------|------------|----------------|----------|
| **AppBar** | ❌ 無 | ✅ 有 | ⚠️ **需要移除** |
| **頂部按鈕** | ImageView (56×44dp)，通常隱藏 | IconButton (56×44dp) | ✅ 已對齊 |
| **Sink 選擇器** | Spinner (101×26dp) | Text + Icon (臨時) | ⚠️ **需要實現** |
| **Sink 管理按鈕** | ImageView (30×30dp) | IconButton (30×30dp) | ✅ 已對齊 |
| **設備列表** | RecyclerView (Grid/Linear) | ListView | ⚠️ 需要檢查布局方式 |
| **設備卡片** | MaterialCardView (margin 6dp, radius 10dp) | Container (radius 20dp) | ⚠️ 需要對齊 |

### 3. 設備卡片差異

| 項目 | reef-b-app (`adapter_device_led.xml`) | koralcore 當前 | 需要對齊 |
|------|--------------------------------------|----------------|----------|
| **容器** | MaterialCardView | Container | ⚠️ 需要改為 Card |
| **圓角** | 10dp | 20dp (lg) | ⚠️ **需要改為 10dp** |
| **陰影** | 5dp elevation | 無 elevation | ⚠️ **需要添加** |
| **Margin** | 6dp (所有方向) | 無 margin | ⚠️ **需要添加** |
| **Padding** | 12dp (start/end), 10dp (top/bottom) | 16dp (水平), 12dp (垂直) | ⚠️ 需要對齊 |
| **設備圖標** | 50dp × 50dp | 32dp × 32dp | ⚠️ **需要改為 50dp** |
| **BLE 狀態圖標** | 14dp × 14dp，右上角 | 無 | ⚠️ **需要添加** |
| **喜愛圖標** | 14dp × 14dp，右上角 | 無 | ⚠️ **需要添加** |
| **Master 圖標** | 12dp × 12dp，右上角 | 無 | ⚠️ **需要添加** |
| **位置信息** | caption2 樣式，text_aa 顏色 | caption1 樣式 | ⚠️ 需要對齊 |
| **群組信息** | caption2 樣式，text_aa 顏色，可選 | 無 | ⚠️ 需要添加（可選） |
| **選中標記** | 20dp × 20dp，右下角，可選 | 無 | ⚠️ 需要添加（可選） |

---

## 📋 對齊行動計劃

### Phase 1: 主結構對齊（高優先級）

#### 1.1 檢查 MainScaffold 結構

**當前實現**:
```dart
Scaffold(
  body: IndexedStack(...),
  bottomNavigationBar: NavigationBar(...),
)
```

**reef-b-app 結構**:
- Toolbar (include @layout/toolbar_app)
- FragmentContainerView (NavHostFragment)
- BottomNavigationView

**需要檢查**:
- [ ] 確認是否需要 Toolbar（Home 頁面無 Toolbar，但其他頁面有）
- [ ] 確認 Bottom Navigation 樣式是否匹配
- [ ] 確認導航方式是否一致

#### 1.2 Bottom Navigation 對齊

**reef-b-app 配置**:
- 使用 `BottomNavigationView` (Material Components)
- 顏色選擇器: `@color/bottom_navigation_color`
  - 選中: `bg_primary` (`#6F916F`)
  - 未選中: `text_a` (`#33000000`)

**koralcore 當前**:
- 使用 `NavigationBar` (Material 3)
- 顏色: `AppColors.ocean500` / `AppColors.grey500`

**需要對齊**:
- [ ] 確認顏色是否匹配
- [ ] 確認圖標是否正確
- [ ] 確認樣式是否一致

---

### Phase 2: Home 頁面對齊（高優先級）

#### 2.1 移除 AppBar

**當前**: HomePage 在 MainScaffold 中，可能有 AppBar  
**需要**: 確認 Home 頁面沒有 AppBar

#### 2.2 實現 Sink 選擇器

**reef-b-app 實現**:
```xml
<Spinner
    android:id="@+id/sp_sink_type"
    android:layout_width="@dimen/dp_101"
    android:layout_height="@dimen/dp_26"
    android:background="@android:color/transparent"
    ... />
```

**koralcore 需要**:
- [ ] 實現 `DropdownButton` 或 `DropdownButtonFormField`
- [ ] 寬度: 101dp
- [ ] 高度: 26dp
- [ ] 背景: 透明
- [ ] 選項: All Sinks, Favorite Devices, 特定 Sink, Unassigned Devices

#### 2.3 設備卡片對齊

**需要修改**:
- [ ] 改為 `Card` 組件
- [ ] 圓角: 10dp (不是 20dp)
- [ ] 添加 elevation: 5dp
- [ ] 添加 margin: 6dp
- [ ] 調整 padding: 12dp (水平), 10dp (垂直)
- [ ] 設備圖標: 50dp × 50dp
- [ ] 添加 BLE 狀態圖標 (14dp × 14dp)
- [ ] 添加喜愛圖標 (14dp × 14dp)
- [ ] 添加 Master 圖標 (12dp × 12dp)（如果適用）
- [ ] 位置信息樣式: caption2, text_aa 顏色

---

### Phase 3: Toolbar 對齊（中優先級）

#### 3.1 Toolbar App 樣式

**reef-b-app 結構**:
- 白色背景
- 2dp 分隔線在底部
- 按鈕: 56dp × 44dp
- Padding: 16dp (start/end), 8dp (top/bottom)

**需要對齊**:
- [ ] 確認 AppBar 背景色為白色
- [ ] 確認底部分隔線為 2dp
- [ ] 確認按鈕尺寸正確

#### 3.2 Toolbar Device 樣式

**reef-b-app 結構**:
- 返回按鈕 (左側)
- 標題 (居中，最大寬度 200dp)
- 菜單按鈕 (右側)
- 喜愛按鈕 (右側)

**需要對齊**:
- [ ] 確認按鈕布局正確
- [ ] 確認標題居中
- [ ] 確認標題最大寬度

---

### Phase 4: 顏色和樣式對齊（中優先級）

#### 4.1 顏色對齊檢查

**已對齊**:
- ✅ `ReefColors.textPrimary` = `text_aaaa` (`#000000`)
- ✅ `ReefColors.textSecondary` = `text_aaa` (`#BF000000`)
- ✅ `ReefColors.textTertiary` = `text_aa` (`#80000000`)
- ✅ `ReefColors.surface` = `bg_aaaa` (`#FFFFFF`)
- ✅ `ReefColors.primary` = `bg_primary` (`#6F916F`)

**需要檢查**:
- [ ] 確認所有顏色使用是否正確
- [ ] 確認透明度是否匹配

#### 4.2 文字樣式對齊

**已對齊**:
- ✅ `ReefTextStyles` 定義了所有樣式
- ✅ 字體大小匹配 (30/22/20/18/16/14/12dp)
- ✅ 字重匹配 (bold/normal)

**需要檢查**:
- [ ] 確認所有頁面使用正確的文字樣式
- [ ] 確認單行文字使用 `maxLines: 1` 和 `overflow: TextOverflow.ellipsis`

#### 4.3 間距對齊

**已對齊**:
- ✅ `ReefSpacing` 定義了所有間距值
- ✅ 標準間距匹配 (8/10/12/16/20/24dp)

**需要檢查**:
- [ ] 確認所有頁面使用正確的間距值
- [ ] 確認卡片 margin 為 6dp
- [ ] 確認卡片 padding 為 12dp (水平), 10dp (垂直)

---

### Phase 5: 圖標對齊（中優先級）

#### 5.1 圖標映射檢查

**已實現**:
- ✅ `ReefMaterialIcons` 提供了圖標映射

**需要檢查**:
- [ ] 確認所有圖標是否正確映射
- [ ] 確認圖標尺寸是否正確
- [ ] 確認圖標狀態（啟用/禁用/選中/未選中）是否正確

#### 5.2 圖標尺寸對齊

**標準尺寸**:
- 小圖標: 24dp × 24dp
- 中等圖標: 30dp × 30dp
- 大圖標按鈕: 56dp × 44dp (Toolbar)
- 設備圖標: 50dp × 50dp

**需要檢查**:
- [ ] 確認所有圖標使用正確尺寸

---

## 🎯 立即行動項目（本週）

### 1. Home 頁面緊急修復

**優先級**: 🔴 **最高**

1. **移除 AppBar**
   - 確認 Home 頁面沒有 AppBar
   - 如果 MainScaffold 有 AppBar，需要條件顯示

2. **實現 Sink 選擇器**
   - 使用 `DropdownButton` 或 `DropdownButtonFormField`
   - 寬度: 101dp
   - 高度: 26dp
   - 實現選項切換邏輯

3. **修復設備卡片**
   - 改為 `Card` 組件
   - 圓角: 10dp
   - 添加 elevation: 5dp
   - 添加 margin: 6dp
   - 調整 padding
   - 設備圖標: 50dp × 50dp
   - 添加狀態圖標（BLE、喜愛、Master）

### 2. 檢查 Bottom Navigation

**優先級**: 🟡 **高**

1. **檢查顏色**
   - 選中: `ReefColors.primary` (`#6F916F`)
   - 未選中: `ReefColors.textDisabled` 或自定義 (`#33000000`)

2. **檢查圖標**
   - 確認使用正確的圖標
   - 確認圖標尺寸為 24dp

### 3. 檢查 Toolbar

**優先級**: 🟡 **高**

1. **檢查 AppBar 樣式**
   - 背景色: 白色
   - 底部分隔線: 2dp

2. **檢查按鈕尺寸**
   - 確認按鈕為 56dp × 44dp
   - 確認 padding 正確

---

## 📊 對齊狀態總覽

### ✅ 已對齊項目

1. **顏色系統**: ✅ 已對齊
2. **文字樣式系統**: ✅ 已對齊
3. **間距系統**: ✅ 已對齊
4. **背景**: ✅ 已對齊 (`ReefMainBackground`)
5. **基本組件**: ✅ 大部分已對齊

### ⚠️ 需要對齊項目

1. **Home 頁面結構**: ⚠️ 需要移除 AppBar，實現 Sink 選擇器
2. **設備卡片**: ⚠️ 需要改為 Card，調整樣式
3. **Bottom Navigation**: ⚠️ 需要檢查顏色和樣式
4. **Toolbar**: ⚠️ 需要檢查樣式
5. **圖標系統**: ⚠️ 需要檢查映射和尺寸

---

## 🔧 實施步驟

### Step 1: 修復 Home 頁面（立即）

1. 檢查並移除 AppBar
2. 實現 Sink 選擇器
3. 修復設備卡片樣式

### Step 2: 檢查導航（本週）

1. 檢查 Bottom Navigation 顏色
2. 檢查 Toolbar 樣式
3. 檢查頁面切換邏輯

### Step 3: 全面對齊（1-2 週）

1. 檢查所有頁面的 layout 結構
2. 檢查所有組件的樣式
3. 檢查所有圖標的使用

---

**最後更新**: 2024-12-28  
**維護者**: UI 對齊工程師  
**狀態**: 進行中

