# LED Record Setting Page 對照文檔

## 一、圖標對照

### 1.1 頁面圖標

| 圖標 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 關閉按鈕 | `ic_close` | `Icons.close` | ⚠️ 需檢查 XML |
| 太陽圖標 | `ic_sun` | `Icons.wb_sunny` | ❌ 需轉換為 SVG |
| 日出圖標 | `ic_sunrise` | `Icons.wb_twilight` | ❌ 需使用 SVG（已有） |
| 日落圖標 | `ic_sunset` | `Icons.wb_twilight` | ❌ 需使用 SVG（已有） |
| 慢啟動圖標 | `ic_slow_start` | `Icons.timer_outlined` | ❌ 需轉換為 SVG |
| 月光圖標 | `ic_moon_round` | `Icons.nightlight_round` | ❌ 需轉換為 SVG |
| 下拉圖標 | `ic_down` | `Icons.keyboard_arrow_down` | ❌ 需轉換為 SVG |

### 1.2 滑塊 Thumb 圖標

| 滑塊 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 強度滑塊 | `ic_strength_thumb` | 未設置 | ❌ 需轉換為 SVG 並設置 |
| 慢啟動滑塊 | `ic_default_thumb` | 未設置 | ❌ 需轉換為 SVG 並設置 |
| 月光滑塊 | `ic_moon_light_thumb` | 未設置 | ❌ 需轉換為 SVG 並設置 |

## 二、Layout 結構對照

### 2.1 整體結構

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 根布局 | `ConstraintLayout` | `Scaffold` | ✅ |
| 內容布局 | `ConstraintLayout` (padding 16/12) | `ListView` (padding 16/12) | ✅ |
| 背景色 | `bg_led_record_setting_background_color` | `ReefColors.surfaceMuted` | ✅ |

### 2.2 初始強度區域

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 太陽圖標 | `img_sun` (20dp) | `Icon` (20dp) | ⚠️ 圖標需對照 |
| 標題文字 | `tv_sun_title` (body, text_aaaa) | `Text` (body, textPrimary) | ✅ |
| 儀表板 | `CustomDashBoard` (123dp 高) | `SemiCircleDashboard` (123dp) | ✅ |
| 百分比文字 | `tv_strength` (headline, text_aaa) | 未顯示 | ❌ 需添加 |
| 滑塊 | `sl_strength` (0-100, trackHeight 2dp) | `Slider` (0-100) | ⚠️ 需設置 trackHeight 和 thumb |

### 2.3 日出/日落區域

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 容器 | `layout_sunrise_sunset` (white, radius 10dp, padding 12dp) | `Container` (white, radius 10dp, padding 12dp) | ✅ |
| 日出圖標 | `img_sunrise` (20dp) | `Icon` (20dp) | ⚠️ 圖標需對照 |
| 日出標題 | `tv_sunrise_title` (caption1, text_aaaa) | `Text` (caption1, textPrimary) | ✅ |
| 日出按鈕 | `btn_sunrise` (MaterialButton, bg_aaa, icon ic_down) | `FilledButton.icon` (surfaceMuted, keyboard_arrow_down) | ⚠️ 圖標需對照 |
| 日落圖標 | `img_sunset` (20dp) | `Icon` (20dp) | ⚠️ 圖標需對照 |
| 日落標題 | `tv_sunset_title` (caption1, text_aaaa) | `Text` (caption1, textPrimary) | ✅ |
| 日落按鈕 | `btn_sunset` (MaterialButton, bg_aaa, icon ic_down) | `FilledButton.icon` (surfaceMuted, keyboard_arrow_down) | ⚠️ 圖標需對照 |

### 2.4 慢啟動/月光區域

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 容器 | `layout_slow_start_moon_light` (white, radius 10dp, padding 12dp) | `Container` (white, radius 10dp, padding 12dp) | ✅ |
| 慢啟動圖標 | `img_slow_start` (20dp) | `Icon` (20dp) | ⚠️ 圖標需對照 |
| 慢啟動標題 | `tv_slow_start_title` (caption1, text_aaaa) | `Text` (caption1, textPrimary) | ✅ |
| 慢啟動數值 | `tv_slow_start` (caption1, text_aaa) | `Text` (caption1, textSecondary) | ✅ |
| 慢啟動滑塊 | `sl_slow_start` (10-60, step 10, trackHeight 2dp) | `Slider` (10-60, divisions 5) | ⚠️ 需設置 trackHeight 和 thumb |
| 刻度標籤 | `progress_10` ~ `progress_60` (caption1, text_aa) | `Text` (caption1, textTertiary) | ✅ |
| 月光圖標 | `img_moon_light` (20dp, marginStart 6dp) | `Icon` (20dp, width 6dp) | ⚠️ 圖標需對照 |
| 月光標題 | `tv_moon_light_title` (caption1, text_aaaa) | `Text` (caption1, textPrimary) | ✅ |
| 月光數值 | `tv_moon_light` (caption1, text_aaa) | `Text` (caption1, textSecondary) | ✅ |
| 月光滑塊 | `sl_moon_light` (0-100, trackHeight 2dp) | `Slider` (0-100) | ⚠️ 需設置 trackHeight 和 thumb |
| 刻度標籤 | `progress_start` (0), `progress_end` (100) | `Text` (0, 100) | ✅ |

## 三、間距對照

| 位置 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 內容 padding | 16dp (start/end), 12dp (top/bottom) | 16dp (horizontal), 12dp (vertical) | ✅ |
| 太陽圖標到標題 | 4dp | 4dp | ✅ |
| 標題到儀表板 | 自動 | 8dp | ⚠️ 需檢查 |
| 儀表板到滑塊 | 自動 | 8dp | ⚠️ 需檢查 |
| 滑塊到日出區域 | 16dp | 16dp | ✅ |
| 日出區域 padding | 12dp | 12dp | ✅ |
| 日出圖標到標題 | 4dp | 4dp | ✅ |
| 日出到日落 | 8dp (marginTop) | 8dp | ✅ |
| 日出區域到慢啟動區域 | 16dp | 16dp | ✅ |
| 慢啟動區域 padding | 12dp | 12dp | ✅ |
| 慢啟動圖標到標題 | 4dp | 4dp | ✅ |
| 慢啟動標題到滑塊 | 自動 | 8dp | ⚠️ 需檢查 |
| 慢啟動滑塊到刻度 | 自動 | 無 | ⚠️ 需檢查 |
| 刻度到月光 | 16dp (marginTop) | 16dp | ✅ |
| 月光圖標到標題 | 6dp | 6dp | ✅ |
| 月光標題到滑塊 | 自動 | 8dp | ⚠️ 需檢查 |
| 月光滑塊到刻度 | 自動 | 無 | ⚠️ 需檢查 |

## 四、顏色對照

| 元素 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 背景色 | `bg_led_record_setting_background_color` | `ReefColors.surfaceMuted` | ✅ |
| 容器背景 | `background_white_radius` (white) | `ReefColors.surface` | ✅ |
| 文字主色 | `text_aaaa` | `ReefColors.textPrimary` | ✅ |
| 文字次色 | `text_aaa` | `ReefColors.textSecondary` | ✅ |
| 文字第三色 | `text_aa` | `ReefColors.textTertiary` | ✅ |
| 強度滑塊激活色 | `dashboard_progress` | `ReefColors.dashboardProgress` | ✅ |
| 強度滑塊非激活色 | `text_aa` | `ReefColors.textTertiary` | ✅ |
| 慢啟動滑塊激活色 | `bg_primary` | `ReefColors.primary` | ✅ |
| 慢啟動滑塊非激活色 | `bg_press` | `ReefColors.surfacePressed` | ✅ |
| 月光滑塊激活色 | `moon_light_color` | `ReefColors.moonLight` | ✅ |
| 月光滑塊非激活色 | `bg_press` | `ReefColors.surfacePressed` | ✅ |

## 五、需要修復的問題

### 高優先級

1. **圖標轉換**：將以下 XML drawable 轉換為 SVG：
   - `ic_sun.xml` → `ic_sun.svg`
   - `ic_slow_start.xml` → `ic_slow_start.svg`
   - `ic_moon_round.xml` → `ic_moon_round.svg`
   - `ic_down.xml` → `ic_down.svg`
   - `ic_strength_thumb.xml` → `ic_strength_thumb.svg`
   - `ic_default_thumb.xml` → `ic_default_thumb.svg`
   - `ic_moon_light_thumb.xml` → `ic_moon_light_thumb.svg`

2. **使用 SVG 圖標**：更新 `led_record_setting_page.dart` 使用 SVG 圖標而不是 Material Icons

3. **滑塊 Thumb 圖標**：為三個滑塊設置自定義 thumb 圖標

4. **儀表板百分比文字**：在 `SemiCircleDashboard` 中顯示百分比文字（如 "50 %"）

### 中優先級

5. **滑塊 trackHeight**：設置所有滑塊的 `trackHeight` 為 2dp

6. **間距調整**：檢查並調整組件間距以完全對照 XML layout

### 低優先級

7. **按鈕樣式**：檢查日出/日落按鈕的樣式是否完全對照 `BackgroundMaterialButton`

## 六、實現狀態

- **圖標對照**: 0% ❌（所有圖標都使用 Material Icons，未使用 SVG）
- **Layout 對照**: 85% ⚠️（結構基本對照，但間距和細節需調整）
- **顏色對照**: 100% ✅
- **功能對照**: 100% ✅

**總體評分**: 60%

