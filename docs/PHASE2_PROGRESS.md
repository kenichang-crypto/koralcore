# Phase 2: 基礎組件調整進度

## 開始日期
2024-12-28

---

## 一、已完成的工作

### 1. ✅ 更新 ReefTheme 配置

已更新 `lib/ui/theme/reef_theme.dart`，添加了以下基礎組件主題：

#### ✅ Card Theme
- 背景顏色：`ReefColors.surface`（白色）
- 圓角：`ReefRadius.lg`（20dp）
- 陰影：`elevation: 0`

#### ✅ FilledButton Theme（主要按鈕）
- 背景顏色：`ReefColors.primary`（綠色）
- 文字顏色：白色
- 文字樣式：`ReefTextStyles.bodyAccent`
- 圓角：`ReefRadius.lg`（20dp）
- 間距：標準 buttonPadding

#### ✅ OutlinedButton Theme（次要按鈕）
- 邊框顏色：`ReefColors.primary`
- 文字顏色：`ReefColors.primary`
- 文字樣式：`ReefTextStyles.body`
- 圓角：`ReefRadius.lg`（20dp）

#### ✅ TextButton Theme（文字按鈕）
- 文字顏色：`ReefColors.primaryStrong`（深綠色）
- 文字樣式：`ReefTextStyles.body`

#### ✅ InputDecorationTheme（TextField 樣式）
- 背景顏色：`ReefColors.surfaceMuted`（`#F7F7F7`，對應 `bg_aaa`）
- 圓角：`ReefRadius.xs`（4dp，所有角落）
- 邊框：無邊框（`borderSide: BorderSide.none`）
- 內邊距：標準間距

**對照 reef-b-app 的 `TextInputLayout` 樣式**：
- ✅ `boxBackgroundColor: bg_aaa` → `fillColor: ReefColors.surfaceMuted`
- ✅ `boxCornerRadius: dp_4` → `borderRadius: ReefRadius.xs`
- ✅ `boxStrokeWidth: 0dp` → `borderSide: BorderSide.none`
- ✅ `hintEnabled: false` → 已在代碼中處理（如果需要）

---

## 二、待完成的工作

### 1. ⏳ 檢查實際使用情況

需要檢查以下頁面，確認組件是否正確使用 Theme 中定義的樣式：

- [ ] Card 組件是否使用 Theme 中的默認樣式
- [ ] Button 組件是否使用 Theme 中的默認樣式
- [ ] TextField 組件是否使用 Theme 中的默認樣式
- [ ] 是否有硬編碼的樣式覆蓋 Theme 配置

### 2. ⏳ 統一背景使用

需要將主要頁面的背景改為 `ReefMainBackground`：

- [ ] Bluetooth 頁面
- [ ] Device 頁面
- [ ] LED 主頁
- [ ] Dosing 主頁

### 3. ⏳ 調整 AppBar 樣式

如果背景改為淺色漸變，AppBar 樣式也需要調整：

- [ ] 確認 AppBar 背景顏色（可能需要改為白色或透明）
- [ ] 調整 AppBar 文字顏色（適配淺色背景）

---

## 三、下一步行動

1. **檢查實際使用情況** - 查看幾個代表性頁面，確認組件樣式是否正確
2. **統一背景使用** - 開始調整主要頁面的背景
3. **測試和驗證** - 確保所有組件在淺色背景上顯示正確

---

## 四、參考資料

### reef-b-app 樣式定義對照

| reef-b-app | koralcore Theme | 狀態 |
|-----------|----------------|------|
| `Card` (白色背景) | `CardTheme.color: ReefColors.surface` | ✅ |
| `Card` (圓角 dp_20) | `CardTheme.shape: ReefRadius.lg` | ✅ |
| `RoundedButton` (cornerRadius: dp_20) | `FilledButtonTheme: ReefRadius.lg` | ✅ |
| `MaterialButton` (primary color) | `FilledButtonTheme: ReefColors.primary` | ✅ |
| `TextInputLayout` (bg_aaa) | `InputDecorationTheme.fillColor: ReefColors.surfaceMuted` | ✅ |
| `TextInputLayout` (cornerRadius: dp_4) | `InputDecorationTheme.borderRadius: ReefRadius.xs` | ✅ |
| `TextInputLayout` (no border) | `InputDecorationTheme.borderSide: BorderSide.none` | ✅ |

---

## 五、檢查清單

### Theme 配置
- [x] Card Theme 配置完成
- [x] FilledButton Theme 配置完成
- [x] OutlinedButton Theme 配置完成
- [x] TextButton Theme 配置完成
- [x] InputDecorationTheme 配置完成

### 組件使用檢查
- [ ] 檢查 Card 組件的實際使用
- [ ] 檢查 Button 組件的實際使用
- [ ] 檢查 TextField 組件的實際使用
- [ ] 移除硬編碼的樣式（如果有的話）

### 背景統一
- [ ] Bluetooth 頁面背景調整
- [ ] Device 頁面背景調整
- [ ] LED 主頁背景調整
- [ ] Dosing 主頁背景調整

### AppBar 調整
- [ ] 確認 AppBar 樣式規範
- [ ] 調整 AppBar 背景和文字顏色

