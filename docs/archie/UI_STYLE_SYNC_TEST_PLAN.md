# UI 樣式同步測試計劃

## 測試目標

驗證以下內容是否正確同步並符合 `reef-b-app` 的設計規範：

1. ✅ AppBar/Toolbar 樣式
2. ✅ 卡片和容器（白色背景）
3. ✅ 間距和尺寸（使用常量）
4. ✅ 組件樣式（按鈕、輸入框、列表項）

---

## 測試範圍

### 已完成的更改（Phase 2-4）

根據文檔，以下工作已經完成：
- ✅ Phase 2: 基礎組件 Theme 配置（Card、Button、TextField）
- ✅ Phase 3: 主要頁面背景統一（ReefMainBackground）
- ✅ Phase 4: 子頁面背景和樣式調整

### 需要測試的頁面

#### 主要頁面（5個）
1. ✅ Home 頁面 (`home_page.dart`)
2. ✅ Bluetooth 頁面 (`bluetooth_page.dart`)
3. ✅ Device 頁面 (`device_page.dart`)
4. ✅ LED 主頁 (`led_main_page.dart`)
5. ✅ Dosing 主頁 (`dosing_main_page.dart`)

#### 子頁面（約 24個，抽取關鍵頁面測試）
- LED 相關：`led_setting_page.dart`, `led_scene_list_page.dart`, `led_record_page.dart`
- Dosing 相關：`pump_head_schedule_page.dart`, `pump_head_calibration_page.dart`
- Device 相關：`device_settings_page.dart`
- Sink 相關：`sink_manager_page.dart`
- 其他：`warning_page.dart`

---

## 測試檢查清單

### 1. AppBar/Toolbar 樣式 ✅

#### 檢查項目
- [ ] **背景顏色**: 應為 `ReefColors.primary` (綠色 #6F916F)
- [ ] **前景顏色**: 應為 `ReefColors.onPrimary` (白色)
- [ ] **Elevation**: 應為 `0`
- [ ] **標題樣式**: 應使用 `ReefTextStyles.title2` (20sp, bold)
- [ ] **圖標顏色**: 應為白色（`ReefColors.onPrimary`）

#### 測試頁面
- [ ] Bluetooth 頁面
- [ ] Device 頁面
- [ ] LED 主頁
- [ ] Dosing 主頁
- [ ] 至少 3 個子頁面（LED Settings, Pump Head Schedule, Device Settings）

#### 預期結果
```
AppBar(
  backgroundColor: ReefColors.primary,  // #6F916F
  foregroundColor: ReefColors.onPrimary, // 白色
  elevation: 0,
  title: Text(..., style: ReefTextStyles.title2),
)
```

---

### 2. 卡片和容器（白色背景）✅

#### 檢查項目
- [ ] **背景顏色**: 應為 `ReefColors.surface` (白色 #FFFFFF)
- [ ] **圓角**: 應使用 `ReefRadius.lg` (20dp)
- [ ] **Elevation**: 應為 `0`（無陰影）
- [ ] **內邊距**: 應使用 `ReefSpacing` 常量

#### 測試位置
- [ ] 主頁面的卡片列表
- [ ] 設置頁面的表單卡片
- [ ] 列表頁面的項目卡片

#### 預期結果
```dart
Card(
  // 使用 Theme 的 cardTheme
  // color: ReefColors.surface (自動應用)
  // shape: ReefRadius.lg (自動應用)
  // elevation: 0 (自動應用)
  child: Padding(
    padding: EdgeInsets.all(ReefSpacing.lg),
    ...
  ),
)
```

#### 需要檢查的代碼
- [ ] 確認沒有硬編碼的 `color`、`shape`、`elevation`
- [ ] 確認所有 Card 都依賴 `ReefTheme` 的 `cardTheme`

---

### 3. 間距和尺寸（使用常量）✅

#### 檢查項目
- [ ] **間距**: 應使用 `ReefSpacing` 常量（xs, sm, md, lg, xl, xxl）
- [ ] **圓角**: 應使用 `ReefRadius` 常量（xs, sm, md, lg）
- [ ] **字體大小**: 應使用 `ReefTextStyles`（不直接使用 `fontSize`）

#### 不應出現的情況
- [ ] ❌ `SizedBox(height: 16)` → 應為 `const SizedBox(height: ReefSpacing.md)`
- [ ] ❌ `BorderRadius.circular(8)` → 應為 `BorderRadius.circular(ReefRadius.sm)`
- [ ] ❌ `fontSize: 16` → 應使用 `ReefTextStyles.body`

#### 測試範圍
- [ ] 所有頁面的間距使用
- [ ] 所有圓角使用
- [ ] 所有文字樣式使用

---

### 4. 組件樣式（按鈕、輸入框、列表項）✅

#### 4.1 按鈕樣式

##### FilledButton (主要按鈕)
- [ ] **背景顏色**: `ReefColors.primary` (綠色 #6F916F)
- [ ] **文字顏色**: `ReefColors.onPrimary` (白色)
- [ ] **圓角**: `ReefRadius.lg` (20dp)
- [ ] **文字樣式**: `ReefTextStyles.bodyAccent` (16sp, bold)
- [ ] **內邊距**: `EdgeInsets.symmetric(horizontal: ReefSpacing.lg, vertical: ReefSpacing.sm)`

##### OutlinedButton (次要按鈕)
- [ ] **邊框顏色**: `ReefColors.primary`
- [ ] **文字顏色**: `ReefColors.primary`
- [ ] **圓角**: `ReefRadius.lg` (20dp)
- [ ] **背景**: 透明

##### TextButton (文字按鈕)
- [ ] **文字顏色**: `ReefColors.primaryStrong` (#517651)
- [ ] **無背景、無邊框**

#### 4.2 TextField 樣式
- [ ] **背景顏色**: `ReefColors.surfaceMuted` (#F7F7F7)
- [ ] **圓角**: `ReefRadius.xs` (4dp)
- [ ] **邊框**: 無邊框 (`borderSide: BorderSide.none`)
- [ ] **內邊距**: `EdgeInsets.symmetric(horizontal: ReefSpacing.md, vertical: ReefSpacing.sm)`
- [ ] **提示文字顏色**: `ReefColors.textSecondary`
- [ ] **文字顏色**: `ReefColors.textPrimary`

#### 4.3 ListTile 樣式
- [ ] **背景顏色**: 在卡片中為白色，或透明
- [ ] **間距**: 使用 `ReefSpacing` 常量
- [ ] **文字顏色**: 使用 `ReefColors.textPrimary` 或 `textSecondary`

#### 測試位置
- [ ] 表單頁面（至少 3 個）的 TextField
- [ ] 包含按鈕的頁面（至少 3 個）
- [ ] 列表頁面的 ListTile

---

## 測試方法

### 方法 1: 代碼檢查（快速）

使用 `grep` 搜索不符合規範的代碼模式：

```bash
# 搜索硬編碼的間距
grep -r "SizedBox(height: [0-9]" lib/ui/features

# 搜索硬編碼的圓角
grep -r "BorderRadius.circular([0-9]" lib/ui/features

# 搜索硬編碼的顏色
grep -r "Color(0x" lib/ui/features

# 搜索 Card 的硬編碼樣式
grep -r "Card(" lib/ui/features | grep -E "color:|shape:|elevation:"
```

### 方法 2: 視覺檢查（推薦）

在實際設備或模擬器上運行應用，檢查：
1. AppBar 是否為綠色背景、白色文字
2. Card 是否為白色背景、20dp 圓角
3. TextField 是否為淺灰背景、無邊框
4. 按鈕樣式是否符合規範
5. 間距是否一致

### 方法 3: 對照 reef-b-app

將 `koralcore` 的 UI 與 `reef-b-app` 進行對照：
1. 打開相同功能的頁面
2. 對比顏色、間距、圓角
3. 記錄差異

---

## 測試步驟

### Step 1: 準備測試環境
1. [ ] 確保應用可以正常運行
2. [ ] 準備測試設備或模擬器
3. [ ] 準備 `reef-b-app` 作為對照

### Step 2: 執行代碼檢查
1. [ ] 運行代碼檢查腳本
2. [ ] 記錄發現的問題
3. [ ] 修復硬編碼問題

### Step 3: 執行視覺檢查
1. [ ] 檢查主要頁面的 AppBar
2. [ ] 檢查主要頁面的 Card
3. [ ] 檢查表單頁面的 TextField
4. [ ] 檢查包含按鈕的頁面
5. [ ] 記錄發現的問題

### Step 4: 對照測試
1. [ ] 對照 Home 頁面
2. [ ] 對照 Bluetooth 頁面
3. [ ] 對照 Device 頁面
4. [ ] 對照 LED 主頁
5. [ ] 對照 Dosing 主頁
6. [ ] 對照至少 3 個子頁面

### Step 5: 修復問題
1. [ ] 修復發現的問題
2. [ ] 重新測試
3. [ ] 確認所有問題已解決

---

## 測試結果記錄

### AppBar/Toolbar 樣式
| 頁面 | 背景顏色 | 前景顏色 | Elevation | 標題樣式 | 狀態 |
|------|---------|---------|-----------|---------|------|
| Bluetooth | | | | | ⏳ |
| Device | | | | | ⏳ |
| LED 主頁 | | | | | ⏳ |
| Dosing 主頁 | | | | | ⏳ |
| LED Settings | | | | | ⏳ |
| Pump Head Schedule | | | | | ⏳ |
| Device Settings | | | | | ⏳ |

### 卡片和容器
| 頁面 | 背景顏色 | 圓角 | Elevation | 硬編碼檢查 | 狀態 |
|------|---------|------|-----------|-----------|------|
| Home | | | | | ⏳ |
| Device | | | | | ⏳ |
| LED 主頁 | | | | | ⏳ |
| Pump Head Schedule | | | | | ⏳ |

### 間距和尺寸
| 檢查項目 | 發現問題數 | 已修復 | 狀態 |
|---------|-----------|--------|------|
| 硬編碼間距 | | | ⏳ |
| 硬編碼圓角 | | | ⏳ |
| 硬編碼字體大小 | | | ⏳ |

### 組件樣式
| 組件類型 | 檢查頁面數 | 發現問題數 | 已修復 | 狀態 |
|---------|-----------|-----------|--------|------|
| FilledButton | | | | ⏳ |
| OutlinedButton | | | | ⏳ |
| TextButton | | | | ⏳ |
| TextField | | | | ⏳ |
| ListTile | | | | ⏳ |

---

## 已知問題記錄

（在此記錄測試過程中發現的問題）

---

## 測試完成標準

- [ ] 所有主要頁面的 AppBar 樣式正確
- [ ] 所有 Card 使用 Theme 定義的樣式（無硬編碼）
- [ ] 所有間距使用 `ReefSpacing` 常量
- [ ] 所有圓角使用 `ReefRadius` 常量
- [ ] 所有按鈕樣式符合規範
- [ ] 所有 TextField 樣式符合規範
- [ ] 與 `reef-b-app` 的對照測試通過

---

## 下一步行動

1. **執行測試** - 按照測試步驟進行測試
2. **記錄結果** - 記錄測試結果和發現的問題
3. **修復問題** - 修復發現的問題
4. **最終驗證** - 再次測試確認所有問題已解決

