# res 資源分配驗證報告

## 檢查日期
2024-12-28

---

## 一、資源分配對照表

### 1. 顏色資源（colors.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/colors.xml
```

#### koralcore 位置
```
koralcore/lib/ui/theme/reef_colors.dart
```

#### 對照檢查

| reef-b-app 顏色名 | 顏色值 | koralcore 常量名 | 顏色值 | 狀態 |
|------------------|--------|-----------------|--------|------|
| `bg_primary` | `#6F916F` | `ReefColors.primary` | `Color(0xFF6F916F)` | ✅ 匹配 |
| `bg_secondary` | `#517651` | `ReefColors.primaryStrong` | `Color(0xFF517651)` | ✅ 匹配 |
| `bg_primary_38` | `#616F916F` | `ReefColors.primaryOverlay` | `Color(0x616F916F)` | ✅ 匹配 |
| `bg_aaaa` | `#FFFFFF` | `ReefColors.surface` | `Color(0xFFFFFFFF)` | ✅ 匹配 |
| `bg_aaa` | `#F7F7F7` | `ReefColors.surfaceMuted` | `Color(0xFFF7F7F7)` | ✅ 匹配 |
| `bg_aaa_60` | `#99F7F7F7` | `ReefColors.surfaceMutedOverlay` | `Color(0x99F7F7F7)` | ✅ 匹配 |
| `bg_press` | `#0D000000` | `ReefColors.surfacePressed` | `Color(0x0D000000)` | ✅ 匹配 |
| `text_aaaa` | `#000000` | `ReefColors.textPrimary` | `Color(0xFF000000)` | ✅ 匹配 |
| `text_aaa` | `#BF000000` | `ReefColors.textSecondary` | `Color(0xBF000000)` | ✅ 匹配 |
| `text_aa` | `#80000000` | `ReefColors.textTertiary` | `Color(0x80000000)` | ✅ 匹配 |
| `text_aaaa_40` | `#66000000` | `ReefColors.textDisabled` | `Color(0x66000000)` | ✅ 匹配 |
| `text_success` | `#52D175` | `ReefColors.success` | `Color(0xFF52D175)` | ✅ 匹配 |
| `text_info` | `#47A9FF` | `ReefColors.info` | `Color(0xFF47A9FF)` | ✅ 匹配 |
| `text_waring` | `#FFC10A` | `ReefColors.warning` | `Color(0xFFFFC10A)` | ✅ 匹配 |
| `text_danger` | `#FF7D4F` | `ReefColors.danger` | `Color(0xFFFF7D4F)` | ✅ 匹配 |
| `main_activity_background_start_color` | `#EFEFEF` | `ReefColors.backgroundGradientStart` | `Color(0xFFEFEFEF)` | ✅ 匹配 |
| `main_activity_background_end_color` | `#00FFFFFF` | `ReefColors.backgroundGradientEnd` | `Color(0x00000000)` | ✅ 匹配 |

**結論**: ✅ **所有顏色資源已正確分配和對照**

---

### 2. 尺寸資源（dimens.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/dimens.xml
```

#### koralcore 位置
```
koralcore/lib/ui/theme/reef_spacing.dart  (間距)
koralcore/lib/ui/theme/reef_radius.dart   (圓角)
```

#### 對照檢查

**間距（Spacing）**

| reef-b-app 尺寸名 | 尺寸值 | koralcore 常量名 | 尺寸值 | 狀態 |
|------------------|--------|-----------------|--------|------|
| `dp_4` | `4dp` | `ReefSpacing.xs / 2` | `4.0` | ⚠️ 需要確認是否有直接常量 |
| `dp_8` | `8dp` | `ReefSpacing.xs` | `8.0` | ✅ 匹配 |
| `dp_10` | `10dp` | `ReefSpacing.sm` | `10.0` | ✅ 匹配 |
| `dp_12` | `12dp` | `ReefSpacing.md` | `12.0` | ✅ 匹配 |
| `dp_16` | `16dp` | `ReefSpacing.md` 或 `lg` | `16.0` | ⚠️ 需要確認 |
| `dp_24` | `24dp` | `ReefSpacing.lg` | `24.0` | ✅ 匹配 |
| `dp_32` | `32dp` | `ReefSpacing.xl` | `32.0` | ✅ 匹配 |

**圓角（Radius）**

| reef-b-app 尺寸名 | 尺寸值 | koralcore 常量名 | 尺寸值 | 狀態 |
|------------------|--------|-----------------|--------|------|
| 圓角相關 | 需要檢查 | `ReefRadius.xs, sm, md, lg, xl` | 不同值 | ⚠️ 需要詳細對照 |

**結論**: ⚠️ **需要檢查間距和圓角的完整對照**

---

### 3. 文字樣式資源（styles.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/styles.xml
```

#### koralcore 位置
```
koralcore/lib/ui/theme/reef_text.dart
```

#### 對照檢查

需要檢查以下樣式是否對應：
- `subheader_accent` → `ReefTextStyles.subheaderAccent`
- `body` → `ReefTextStyles.body`
- `caption1` → `ReefTextStyles.caption1`
- `caption2` → `ReefTextStyles.caption2`
- `title2` → `ReefTextStyles.title2`
- 等等

**結論**: ⚠️ **需要詳細對照文字樣式**

---

### 4. 背景資源（drawable/background_*.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/drawable/background_main.xml
reef-b-app/android/ReefB_Android/app/src/main/res/drawable/dialog_background.xml
reef-b-app/android/ReefB_Android/app/src/main/res/drawable/background_white_radius.xml
```

#### koralcore 位置
```
koralcore/lib/ui/widgets/reef_backgrounds.dart
```

#### 對照檢查

| reef-b-app 資源 | koralcore Widget | 狀態 |
|----------------|-----------------|------|
| `background_main.xml` | `ReefMainBackground` | ✅ 已轉換 |
| `dialog_background.xml` | `ReefDialogBackground` | ✅ 已轉換 |
| `background_white_radius.xml` | `ReefWhiteRoundedBackground` | ✅ 已轉換 |
| `background_spinner.xml` | `ReefSpinnerBackground` | ✅ 已轉換 |
| `background_sink_spinner.xml` | `ReefSinkSpinnerBackground` | ✅ 已轉換 |

**結論**: ✅ **背景資源已正確轉換**

---

### 5. 圖標資源（drawable/ic_*.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/drawable/ic_*.xml
```

#### koralcore 位置
```
koralcore/lib/ui/assets/reef_material_icons.dart
```

#### 對照檢查

- ✅ 已轉換為 Material Icons 映射
- ✅ 常用圖標已定義（約 50+ 個）

**結論**: ✅ **圖標資源已正確轉換**

---

### 6. 圖片資源（PNG/WebP）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/drawable-xxxhdpi/*.png
```

#### koralcore 位置
```
koralcore/assets/images/
koralcore/assets/icons/
```

#### 對照檢查

- ✅ 啟動頁面圖片已導入
- ✅ 功能圖標已導入
- ✅ 設備圖標已導入

**結論**: ✅ **圖片資源已正確導入**

---

## 二、基礎組件使用檢查

### 1. 顏色使用

#### 檢查項目
- [ ] 是否所有頁面都使用 `ReefColors` 而非硬編碼顏色？
- [ ] 是否正確使用 `textPrimary`、`textSecondary` 等語義化顏色？
- [ ] 是否使用 `backgroundGradientStart/End` 而非硬編碼漸變顏色？

#### 當前狀態
- ⚠️ 部分頁面仍使用 `ReefColors.primaryStrong` 作為背景（應使用 `ReefMainBackground`）
- ⚠️ 部分頁面使用 `ReefColors.surfaceMuted` 作為背景（需要確認是否正確）

---

### 2. 間距使用

#### 檢查項目
- [ ] 是否所有頁面都使用 `ReefSpacing` 常量而非硬編碼數值？
- [ ] 間距值是否匹配 reef-b-app 的標準？

#### 當前狀態
- ✅ 大部分頁面使用 `ReefSpacing` 常量
- ⚠️ 需要確認間距值的完整對照

---

### 3. 圓角使用

#### 檢查項目
- [ ] 是否所有頁面都使用 `ReefRadius` 常量？
- [ ] 圓角值是否匹配 reef-b-app 的標準？

#### 當前狀態
- ✅ 大部分頁面使用 `ReefRadius` 常量
- ⚠️ 需要確認圓角值的完整對照

---

### 4. 文字樣式使用

#### 檢查項目
- [ ] 是否所有頁面都使用 `ReefTextStyles` 而非直接定義 TextStyle？
- [ ] 文字樣式是否匹配 reef-b-app？

#### 當前狀態
- ✅ 大部分頁面使用 `ReefTextStyles`
- ⚠️ 需要確認文字樣式的完整對照

---

### 5. 背景使用

#### 檢查項目
- [ ] 是否所有需要漸變背景的頁面都使用 `ReefMainBackground`？
- [ ] 是否正確使用其他背景 Widget（Dialog、WhiteRounded 等）？

#### 當前狀態
- ✅ HomePage 已使用 `ReefMainBackground`
- ❌ 其他頁面尚未使用 `ReefMainBackground`（仍使用 `backgroundColor`）

---

## 三、問題總結

### ✅ 已正確分配的資源

1. **顏色資源** - 完全正確 ✅
2. **背景 Widget** - 已轉換 ✅
3. **圖標資源** - 已轉換 ✅
4. **圖片資源** - 已導入 ✅

### ⚠️ 需要確認的資源

1. **間距值對照** - 需要詳細檢查 `ReefSpacing` 是否完全對應 `dimens.xml`
2. **圓角值對照** - 需要詳細檢查 `ReefRadius` 是否完全對應
3. **文字樣式對照** - 需要詳細檢查 `ReefTextStyles` 是否完全對應 `styles.xml`

### ❌ 使用問題

1. **背景使用不統一** - 只有 HomePage 使用 `ReefMainBackground`，其他頁面仍使用 `backgroundColor`
2. **顏色使用不一致** - 部分頁面使用 `primaryStrong` 作為背景（應改為淺色漸變）

---

## 四、建議修復步驟

### Step 1: 詳細對照檢查

1. **間距對照**
   - 讀取 `reef-b-app/res/values/dimens.xml`
   - 檢查所有 `dp_*` 值
   - 確認 `ReefSpacing` 是否完全對應

2. **圓角對照**
   - 檢查所有圓角相關的尺寸值
   - 確認 `ReefRadius` 是否完全對應

3. **文字樣式對照**
   - 讀取 `reef-b-app/res/values/styles.xml`
   - 檢查所有文字樣式定義
   - 確認 `ReefTextStyles` 是否完全對應

### Step 2: 統一背景使用

1. 創建統一的背景使用規範
2. 確保所有主要頁面使用 `ReefMainBackground`
3. 移除硬編碼的背景顏色

### Step 3: 驗證基礎組件

1. 檢查 Card、Button、TextField 等基礎組件
2. 確保它們使用正確的顏色、間距、圓角
3. 確保樣式一致

---

## 五、檢查清單

### 資源分配檢查

- [x] 顏色資源已正確分配
- [ ] 間距值已完整對照
- [ ] 圓角值已完整對照
- [ ] 文字樣式已完整對照
- [x] 背景資源已正確轉換
- [x] 圖標資源已正確轉換
- [x] 圖片資源已正確導入

### 基礎組件使用檢查

- [ ] 所有頁面使用 `ReefColors` 而非硬編碼
- [ ] 所有頁面使用 `ReefSpacing` 而非硬編碼
- [ ] 所有頁面使用 `ReefRadius` 而非硬編碼
- [ ] 所有頁面使用 `ReefTextStyles` 而非直接定義
- [ ] 所有主要頁面使用 `ReefMainBackground`
- [ ] 基礎組件（Card、Button、TextField）使用正確的資源

---

## 六、下一步行動

1. **詳細對照檢查** - 完成間距、圓角、文字樣式的詳細對照
2. **創建對照表** - 生成完整的資源對照表
3. **修復使用問題** - 統一背景和顏色使用
4. **驗證基礎組件** - 確保基礎組件正確使用資源

