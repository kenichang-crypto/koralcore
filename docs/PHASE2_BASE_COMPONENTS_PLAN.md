# Phase 2: 基礎組件調整計劃

## 目標

統一基礎組件的樣式，確保它們正確使用 reef-b-app 的設計規範，並適配淺色背景。

---

## 一、背景使用規範

### 1. 背景使用規範

#### 主要頁面（應使用 `ReefMainBackground`）
- ✅ HomePage
- ❌ Bluetooth 頁面 - 需要改為 `ReefMainBackground`
- ❌ Device 頁面 - 需要改為 `ReefMainBackground`
- ❌ LED 主頁 - 需要改為 `ReefMainBackground`
- ❌ Dosing 主頁 - 需要改為 `ReefMainBackground`

#### 設置頁面（可能需要使用 `ReefMainBackground` 或 `surfaceMuted`）
- 需要確認：Device Settings, LED Settings, Dosing Settings 等

#### 特殊背景
- 對話框：使用 `ReefDialogBackground`
- 圓角卡片背景：使用 `ReefWhiteRoundedBackground`
- 下拉選擇器：使用 `ReefSpinnerBackground`

---

## 二、基礎組件檢查清單

### 1. Card 組件

#### reef-b-app 規範
- 背景顏色：白色（`bg_aaaa` = `#FFFFFF`）
- 圓角：通常使用 `dp_4` 或 `dp_8`（對應 `ReefRadius.xs`）
- 間距：根據內容使用標準間距（`dp_8`, `dp_12`, `dp_16` 等）
- 陰影：通常無陰影或輕微陰影（`elevation: 0`）

#### koralcore 檢查項目
- [ ] Card 是否使用 `ReefColors.surface`（白色背景）？
- [ ] Card 是否使用 `ReefRadius` 常量？
- [ ] Card 的內邊距是否使用 `ReefSpacing` 常量？
- [ ] Card 的 `elevation` 是否設置為 `0` 或適當的值？

---

### 2. Button 組件

#### reef-b-app 規範
- **FilledButton（主要按鈕）**:
  - 背景顏色：`bg_primary` (`#6F916F`)
  - 文字顏色：白色
  - 圓角：`dp_20`（對應 `ReefRadius.lg`）
  - 文字樣式：`caption1`（14sp）或 `body`（16sp）
  - 間距：根據按鈕尺寸調整

- **OutlinedButton（次要按鈕）**:
  - 邊框顏色：`bg_primary` (`#6F916F`)
  - 文字顏色：`bg_primary`
  - 圓角：`dp_20`
  - 背景：透明

- **TextButton（文字按鈕）**:
  - 文字顏色：`bg_secondary` (`#517651`)
  - 無背景、無邊框
  - 文字樣式：根據用途調整

#### koralcore 檢查項目
- [ ] FilledButton 是否使用 `ReefColors.primary`？
- [ ] FilledButton 是否使用 `ReefRadius.lg`？
- [ ] FilledButton 文字樣式是否使用 `ReefTextStyles`？
- [ ] OutlinedButton 是否正確設置邊框和文字顏色？
- [ ] TextButton 是否使用正確的文字顏色？
- [ ] 所有按鈕是否在 `ReefTheme` 中統一配置？

---

### 3. TextField 組件

#### reef-b-app 規範（參考 `TextInputLayout` 樣式）
- 背景顏色：`bg_aaa` (`#F7F7F7`)
- 圓角：`dp_4`（所有角落）
- 邊框：無邊框（`boxStrokeWidth: 0dp`）
- 提示文字：禁用（`hintEnabled: false`）
- 文字顏色：`text_aaaa`（黑色）

#### koralcore 檢查項目
- [ ] TextField 背景是否使用 `ReefColors.surfaceMuted`？
- [ ] TextField 圓角是否使用 `ReefRadius.xs`？
- [ ] TextField 是否無邊框或使用適當的邊框樣式？
- [ ] TextField 的文字顏色是否使用 `ReefColors.textPrimary`？
- [ ] TextField 是否在 `ReefTheme` 中統一配置？

---

### 4. ListTile 組件

#### reef-b-app 規範
- 背景顏色：白色（卡片中）或透明
- 高度：根據內容調整
- 間距：使用標準間距
- 分隔線：可能需要分隔線（`Divider`）

#### koralcore 檢查項目
- [ ] ListTile 是否使用正確的背景顏色？
- [ ] ListTile 的間距是否使用 `ReefSpacing`？
- [ ] ListTile 是否需要分隔線？

---

### 5. AppBar/Toolbar

#### reef-b-app 規範
- 背景顏色：
  - Home 頁面：無 AppBar
  - 其他頁面：需要確認（可能是 `bg_primary` 或 `bg_secondary`）
- 文字顏色：白色（如果使用深色背景）
- 文字樣式：`title2`（20sp, bold）

#### koralcore 檢查項目
- [ ] AppBar 背景顏色是否正確？
- [ ] AppBar 文字樣式是否使用 `ReefTextStyles.title2`？
- [ ] AppBar 文字顏色是否正確（適配背景）？

---

## 三、實施步驟

### Step 1: 檢查當前 Theme 配置

1. 檢查 `ReefTheme` 的當前配置
2. 確認 Button、TextField 等組件的主題配置
3. 記錄需要調整的地方

### Step 2: 更新 ReefTheme

1. 確保 FilledButton 使用正確的顏色、圓角、文字樣式
2. 確保 OutlinedButton 使用正確的樣式
3. 確保 TextField 使用正確的背景、圓角、邊框
4. 確保其他基礎組件使用正確的樣式

### Step 3: 檢查實際使用

1. 檢查幾個代表性頁面，確認組件樣式
2. 對照 reef-b-app 的實際樣式
3. 記錄不一致的地方

### Step 4: 統一背景使用（與 Phase 3 相關）

1. 將主要頁面的背景改為 `ReefMainBackground`
2. 調整 AppBar 樣式（如果需要）
3. 調整文字顏色（適配淺色背景）

---

## 四、參考資料

### reef-b-app 樣式定義

#### Button 樣式（styles.xml）
- `MaterialButton` - 基本按鈕
- `RoundedButton` - 圓角按鈕（`cornerRadius: dp_20`）
- `BackgroundMaterialButton` - 背景按鈕（使用 `bg_aaa`）
- `ToolBarTextButton` - Toolbar 文字按鈕

#### TextField 樣式（styles.xml）
- `TextInputLayout` - 輸入框布局
  - `boxBackgroundColor: bg_aaa` (`#F7F7F7`)
  - `boxCornerRadius: dp_4`（所有角落）
  - `boxStrokeWidth: 0dp`（無邊框）
  - `hintEnabled: false`

#### Card 樣式
- 背景：白色（`bg_aaaa`）
- 圓角：通常 `dp_4` 或 `dp_8`

---

## 五、檢查清單

### Theme 配置
- [ ] FilledButton 樣式正確
- [ ] OutlinedButton 樣式正確
- [ ] TextButton 樣式正確
- [ ] TextField 樣式正確
- [ ] Card 默認樣式正確（如果有的話）

### 組件使用
- [ ] 所有頁面使用 Theme 中定義的樣式
- [ ] 沒有硬編碼的顏色、間距、圓角
- [ ] 文字顏色適配背景顏色

### 背景使用
- [ ] 主要頁面使用 `ReefMainBackground`
- [ ] 設置頁面使用適當的背景
- [ ] AppBar 樣式適配背景

---

## 六、預計工作量

- Theme 配置更新：1-2 小時
- 組件檢查和調整：2-3 小時
- 背景統一調整：與 Phase 3 一起進行
- **總計**：約 3-5 小時

