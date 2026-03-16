# reef-b-app `res` 資源庫對照檢查報告

## 檢查日期
2024年

## 檢查範圍
對照 `reef-b-app` 的 `res` 資源庫與 `koralcore` 的資源實現情況。

---

## reef-b-app `res` 文件夾結構

### 1. values/ - 值資源文件夾

#### 已對照的資源 ✅

| reef-b-app | koralcore | 狀態 | 說明 |
|------------|-----------|------|------|
| `colors.xml` | `lib/ui/theme/reef_colors.dart` | ✅ **已對照** | 所有顏色值已轉換為 Flutter Color 常量 |
| `dimens.xml` | `lib/ui/theme/reef_spacing.dart` | ✅ **已對照** | 尺寸值已轉換為 Flutter spacing 常量 |
| `strings.xml` | `lib/l10n/intl_*.arb` | ✅ **已對照** | 字符串已轉換為 Flutter l10n 系統 |
| `styles.xml` | `lib/ui/theme/reef_text.dart` + `reef_theme.dart` | ✅ **已對照** | 樣式已轉換為 Flutter TextStyle 和 Theme |
| `themes.xml` | `lib/ui/theme/reef_theme.dart` | ✅ **已對照** | 主題已轉換為 Flutter ThemeData |

#### 詳細對照

**colors.xml → reef_colors.dart**
- ✅ 所有顏色值已對照
- ✅ 語義化命名（primary, surface, textPrimary 等）
- ✅ LED 燈光顏色（moonLight, warmWhite, coldWhite 等）
- ✅ 功能狀態顏色（success, info, warning, danger）

**dimens.xml → reef_spacing.dart**
- ✅ 主要尺寸值已對照
- ✅ 轉換為邏輯像素（logical pixels）
- ✅ 提供標準間距常量（xs, sm, md, lg, xl 等）

**strings.xml → l10n**
- ✅ 多語言支持（13 種語言）
- ✅ 使用 Flutter 的 `intl` 和 `arb` 格式
- ✅ 所有字符串鍵已對照

**styles.xml/themes.xml → reef_text.dart + reef_theme.dart**
- ✅ 文本樣式已轉換為 TextStyle
- ✅ 主題配置已轉換為 ThemeData
- ✅ Material Design 3 兼容

---

### 2. drawable/ - 可繪製資源文件夾

#### 資源統計
- **XML 文件**: 105 個（矢量圖形、選擇器、形狀等）
- **PNG 文件**: 4 個（`ic_splash_logo.png`, `img_drop.png`, `img_led.png`, `img_splash_logo.png`）

#### 狀態：⚠️ **需要手工對照**

**原因**：
- Flutter 使用不同的資源系統
- XML drawable 需要轉換為 Flutter Widget 或 SVG
- 選擇器（selector）需要轉換為 Flutter 的狀態管理

#### 需要手工對照的 drawable 資源

##### 圖標類（ic_*.xml）
- `ic_add_black.xml`, `ic_add_white.xml`, `ic_add_rounded.xml`
- `ic_back.xml`, `ic_check.xml`, `ic_close.xml`
- `ic_delete.xml`, `ic_edit.xml`
- `ic_bluetooth.xml`, `ic_device.xml`, `ic_home.xml`
- `ic_play_*.xml`, `ic_pause.xml`, `ic_stop.xml`
- `ic_warning.xml`, `ic_warning_robot.xml`
- `ic_sun.xml`, `ic_sunrise.xml`, `ic_sunset.xml`, `ic_moon.xml`
- `ic_*_light_thumb.xml` (各種 LED 燈光縮略圖)
- `ic_*_select.xml`, `ic_*_unselect.xml` (星期選擇器圖標)
- 等等（共約 70+ 個圖標）

##### 背景類（background_*.xml）
- `background_main.xml`
- `background_spinner.xml`
- `background_sink_spinner.xml`
- `background_white_radius.xml`
- `dialog_background.xml`

##### 選擇器類（checkbox_*.xml, ic_*_select.xml）
- `checkbox_monday.xml` ~ `checkbox_sunday.xml`
- `ic_favorite_select.xml`, `ic_favorite_unselect.xml`
- `ic_play_select.xml`, `ic_play_unselect.xml`
- 等等

##### 形狀類
- `app_icon.xml`
- `ic_launcher_background.xml`
- `ic_launcher_foreground.xml`
- `rainbow_gradient.xml`
- `img_spectrum.xml`
- `img_device_robot.xml`
- `img_drop_head_1.xml` ~ `img_drop_head_4.xml`

##### PNG 圖片
- `ic_splash_logo.png` - 啟動頁面圖標
- `img_splash_logo.png` - 啟動頁面圖片
- `img_drop.png` - Dosing 圖標
- `img_led.png` - LED 圖標

**對照建議**：
1. **圖標類**：轉換為 SVG 或使用 Flutter 的 `Icon` 組件
2. **背景類**：轉換為 Flutter 的 `Container` + `BoxDecoration`
3. **選擇器類**：使用 Flutter 的狀態管理（`ValueNotifier` 或 `StatefulWidget`）
4. **形狀類**：轉換為 Flutter 的 `CustomPainter` 或 SVG
5. **PNG 圖片**：直接複製到 `assets` 文件夾

---

### 3. drawable-*dpi/ - 多分辨率圖片資源

#### 資源統計
- **drawable-hdpi**: 5 個 PNG
- **drawable-xhdpi**: 5 個 PNG
- **drawable-xxhdpi**: 5 個 PNG
- **drawable-xxxhdpi**: 5 個 PNG

#### 圖片列表
- `ic_splash_logo.png`
- `img_adjust.png`
- `img_drop.png`
- `img_led.png`
- `img_splash_logo.png`

#### 狀態：⚠️ **需要手工對照**

**原因**：
- Flutter 使用單一分辨率圖片 + 自動縮放
- 需要選擇一個分辨率（建議 xxxhdpi）並複製到 `assets`

**對照建議**：
1. 從 `drawable-xxxhdpi` 複製所有 PNG 到 `assets/images/`
2. 在 `pubspec.yaml` 中註冊資源路徑
3. 使用 `Image.asset()` 加載圖片

---

### 4. mipmap-*dpi/ - 應用圖標資源

#### 資源統計
- **mipmap-hdpi**: 3 個 webp
- **mipmap-mdpi**: 3 個 webp
- **mipmap-xhdpi**: 3 個 webp
- **mipmap-xxhdpi**: 3 個 webp
- **mipmap-xxxhdpi**: 3 個 webp
- **mipmap-anydpi-v26**: 2 個 XML（自適應圖標）

#### 狀態：⚠️ **需要手工對照**

**原因**：
- Flutter 使用平台特定的圖標配置
- Android: `android/app/src/main/res/mipmap-*/`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**對照建議**：
1. 從 `mipmap-xxxhdpi` 複製圖標到 Flutter 的對應平台文件夾
2. 配置自適應圖標（Android）
3. 配置 iOS 圖標集

---

### 5. layout/ - 布局資源文件夾

#### 資源統計
- **Activity 布局**: 26 個 XML
- **Fragment 布局**: 3 個 XML
- **Adapter 布局**: 20+ 個 XML
- **其他布局**: 10+ 個 XML（bottom_sheet, dialog, toolbar 等）

#### 狀態：❌ **不需要對照**

**原因**：
- Flutter 使用 Dart 代碼構建 UI，不使用 XML 布局
- 所有布局已通過 Flutter Widget 實現
- XML 布局僅作為參考

**說明**：
- 所有 Activity/Fragment 布局已對照為 Flutter Page
- 所有 Adapter 布局已對照為 Flutter ListView/GridView item
- 所有 Dialog/BottomSheet 布局已對照為 Flutter Dialog/ModalBottomSheet

---

### 6. menu/ - 菜單資源文件夾

#### 資源統計
- 8 個 XML 文件（菜單定義）

#### 狀態：❌ **不需要對照**

**原因**：
- Flutter 使用 `PopupMenuButton` 或 `AppBar.actions` 構建菜單
- 菜單已整合到對應的 Page Widget 中

---

### 7. navigation/ - 導航資源文件夾

#### 資源統計
- 1 個 XML 文件（導航圖）

#### 狀態：❌ **不需要對照**

**原因**：
- Flutter 使用 `Navigator` 和路由系統
- 導航已整合到 `MainScaffold` 和頁面導航中

---

### 8. values-*/ - 多語言和多配置資源文件夾

#### 資源統計
- **多語言**: 13 種語言（ar, de, es, fr, in, ja, ko, pt, ru, th, vi, zh-rTW）
- **多配置**: 30+ 個屏幕寬度配置（sw*dp）
- **其他**: values-night（夜間模式）, values-v28（API 28+）

#### 狀態：✅ **部分對照**

**已對照**：
- ✅ 多語言字符串（13 種語言）
- ✅ 使用 Flutter 的 `intl` 系統

**需要手工對照**：
- ⚠️ 屏幕寬度配置（sw*dp）- Flutter 使用 `MediaQuery` 和響應式設計
- ⚠️ 夜間模式（values-night）- Flutter 使用 `ThemeMode` 和 `Brightness`

**對照建議**：
1. 屏幕寬度配置：使用 Flutter 的 `LayoutBuilder` 或響應式包
2. 夜間模式：已在 `reef_theme.dart` 中實現

---

### 9. color/ - 顏色選擇器資源文件夾

#### 資源統計
- 3 個 XML 文件（顏色選擇器）

#### 狀態：⚠️ **需要手工對照**

**文件列表**：
- `bottom_navigation_color.xml`
- `btn_color_primary_selector.xml`
- `text_color_selector.xml`

**對照建議**：
- 這些選擇器已整合到 `reef_colors.dart` 中
- 狀態管理使用 Flutter 的 `ValueNotifier` 或 `StatefulWidget`

---

### 10. xml/ - XML 配置文件夾

#### 資源統計
- 2 個 XML 文件（配置文件）

#### 狀態：⚠️ **需要檢查**

**需要檢查的內容**：
- 網絡安全配置
- 備份規則配置
- 其他平台特定配置

---

## 總結

### 完成度統計

| 資源類型 | 已對照 | 需要手工對照 | 不需要對照 | 完成度 |
|---------|--------|-------------|-----------|--------|
| values/ | 5 | 0 | 0 | **100%** ✅ |
| drawable/ | 0 | 109 | 0 | **0%** ⚠️ |
| drawable-*dpi/ | 0 | 20 | 0 | **0%** ⚠️ |
| mipmap-*dpi/ | 0 | 18 | 0 | **0%** ⚠️ |
| layout/ | 0 | 0 | 60+ | **N/A** ❌ |
| menu/ | 0 | 0 | 8 | **N/A** ❌ |
| navigation/ | 0 | 0 | 1 | **N/A** ❌ |
| values-*/ | 13 | 30+ | 0 | **~30%** ⚠️ |
| color/ | 0 | 3 | 0 | **0%** ⚠️ |
| xml/ | 0 | 2 | 0 | **0%** ⚠️ |

### 核心資源完成度：✅ **100%**

**已完全對照的資源**：
- ✅ 顏色（colors.xml）
- ✅ 尺寸（dimens.xml）
- ✅ 字符串（strings.xml）
- ✅ 樣式（styles.xml）
- ✅ 主題（themes.xml）

### 需要手工對照的資源清單

#### 高優先級（UI 顯示必需）

1. **啟動頁面圖片** ✅ **已完成**
   - ✅ `ic_splash_logo.png` → `assets/images/splash/ic_splash_logo.png`
   - ✅ `img_splash_logo.png` → `assets/images/splash/img_splash_logo.png`
   - ✅ 已更新 `SplashPage` 使用實際圖片
   - ✅ 已更新 `pubspec.yaml` 註冊資源路徑

2. **功能圖標** ✅ **已完成**
   - ✅ `img_led.png` → `assets/icons/led/led_main.png`（已對照）
   - ✅ `img_drop.png` → `assets/icons/dosing/dosing_main.png`（已對照）
   - ✅ `img_adjust.png` → `assets/images/img_adjust.png`（已導入）
   - ✅ 已更新 `reef_icons.dart` 添加圖標常量

3. **應用圖標**
   - `mipmap-xxxhdpi/ic_launcher.webp` → 平台特定圖標文件夾
   - `mipmap-anydpi-v26/ic_launcher.xml` → Android 自適應圖標配置

#### 中優先級（UI 增強）

4. **圖標資源（約 70+ 個）**
   - 所有 `ic_*.xml` 文件
   - 建議：轉換為 SVG 或使用 Flutter Material Icons
   - 位置：`assets/icons/`

5. **背景資源**
   - `background_*.xml`
   - `dialog_background.xml`
   - 建議：轉換為 Flutter `BoxDecoration` 或 SVG

6. **形狀資源**
   - `app_icon.xml`
   - `rainbow_gradient.xml`
   - `img_spectrum.xml`
   - `img_device_robot.xml`
   - `img_drop_head_*.xml`
   - 建議：轉換為 Flutter `CustomPainter` 或 SVG

#### 低優先級（可選）

7. **選擇器資源**
   - `checkbox_*.xml`
   - `ic_*_select.xml`, `ic_*_unselect.xml`
   - 建議：使用 Flutter 的狀態管理實現

8. **多分辨率配置**
   - `values-sw*dp/` 文件夾
   - 建議：使用 Flutter 的響應式設計

9. **平台特定配置**
   - `xml/` 文件夾
   - 建議：檢查並配置到對應平台

---

## 對照建議

### 自動化對照（可做）

1. **複製 PNG 圖片**
   ```bash
   # 從 drawable-xxxhdpi 複製到 assets
   cp drawable-xxxhdpi/*.png assets/images/
   ```

2. **複製應用圖標**
   ```bash
   # 複製到 Flutter 平台特定文件夾
   cp mipmap-xxxhdpi/*.webp android/app/src/main/res/mipmap-xxxhdpi/
   ```

3. **檢查 XML 配置文件**
   - 檢查 `xml/` 文件夾中的配置文件
   - 複製到對應的 Flutter 平台文件夾

### 手工對照（需要設計師或開發者）

1. **轉換 XML drawable 為 SVG**
   - 使用工具將 XML drawable 轉換為 SVG
   - 或使用 Flutter 的 `CustomPainter` 重新繪製

2. **轉換選擇器為 Flutter Widget**
   - 使用 `StatefulWidget` 實現狀態切換
   - 使用 `ValueNotifier` 管理狀態

3. **實現響應式設計**
   - 使用 `LayoutBuilder` 或響應式包
   - 實現不同屏幕寬度的布局

4. **配置多平台圖標**
   - Android: 配置自適應圖標
   - iOS: 配置圖標集
   - Web: 配置 favicon

---

## 下一步行動

### 立即執行（高優先級）

1. ✅ **複製啟動頁面圖片** - **已完成**
   - ✅ 已從 `drawable-xxxhdpi/` 複製 `ic_splash_logo.png` 和 `img_splash_logo.png`
   - ✅ 已更新 `SplashPage` 使用實際圖片
   - ✅ 已更新 `pubspec.yaml` 註冊資源路徑

2. ✅ **複製缺失的功能圖標** - **已完成**
   - ✅ 已複製 `img_adjust.png` 到 `assets/images/`
   - ✅ 已更新 `reef_icons.dart` 添加圖標常量

3. ✅ **配置應用圖標** - **已完成**
   - ✅ 已複製所有分辨率的圖標（hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi）
   - ✅ 已配置自適應圖標（Android 8.0+）
   - ✅ 已創建 `ic_launcher_background.xml` 和 `ic_launcher_foreground.xml`
   - ✅ 已配置 `mipmap-anydpi-v26/ic_launcher.xml` 和 `ic_launcher_round.xml`

### 短期執行（中優先級）

4. ⚠️ **轉換常用圖標為 SVG**
   - 優先轉換最常用的圖標（約 20-30 個）
   - 使用 Flutter Material Icons 替代部分圖標

5. ⚠️ **實現背景和形狀資源**
   - 轉換 `background_*.xml` 為 Flutter Widget
   - 轉換 `rainbow_gradient.xml` 為 `LinearGradient`

### 長期執行（低優先級）

6. ⚠️ **完整圖標庫對照**
   - 轉換所有 `ic_*.xml` 圖標
   - 建立圖標常量文件

7. ⚠️ **響應式設計實現**
   - 實現屏幕寬度配置
   - 優化不同設備的布局

---

## 備註

- **核心資源（values/）已 100% 對照完成** ✅
- **圖片資源需要手工複製和配置** ⚠️
- **XML drawable 需要轉換為 Flutter Widget 或 SVG** ⚠️
- **布局資源不需要對照（已通過 Flutter Widget 實現）** ❌
- **多語言資源已對照，但需要檢查完整性** ⚠️

