# XML Drawable 轉換狀態

## 問題

**Flutter 不能直接讀取 Android XML drawable 文件**，需要轉換為其他格式。

---

## 當前轉換狀態

### ✅ 已轉換的資源

#### 1. 常用圖標 → Material Icons

**位置**: `lib/ui/assets/reef_material_icons.dart`

**轉換方式**: XML drawable 圖標映射到 Flutter Material Icons

**已轉換的圖標**:
- `ic_add_black.xml` → `Icons.add`
- `ic_back.xml` → `Icons.arrow_back`
- `ic_check.xml` → `Icons.check`
- `ic_close.xml` → `Icons.close`
- `ic_delete.xml` → `Icons.delete`
- `ic_edit.xml` → `Icons.edit`
- 等等（約 50+ 個常用圖標）

**使用方式**:
```dart
import 'package:koralcore/ui/assets/reef_material_icons.dart';

Icon(ReefMaterialIcons.add)
Icon(ReefMaterialIcons.back)
```

---

#### 2. 背景和形狀 → Flutter Widget

**位置**: 
- `lib/ui/widgets/reef_backgrounds.dart`
- `lib/ui/widgets/reef_gradients.dart`

**轉換方式**: XML drawable 轉換為 Flutter Widget

**已轉換的資源**:
- `background_main.xml` → `ReefMainBackground` Widget
- `dialog_background.xml` → `ReefDialogBackground` Widget
- `rainbow_gradient.xml` → `ReefRainbowGradient` Widget

**使用方式**:
```dart
import 'package:koralcore/ui/widgets/reef_backgrounds.dart';

ReefMainBackground(
  child: YourWidget(),
)
```

---

### ⚠️ 未轉換的資源

#### XML Drawable 文件（約 100+ 個）

**位置**: `docs/reef_b_app_res/drawable/*.xml`

**狀態**: 尚未轉換為 SVG 或 Flutter Widget

**包括**:
- 複雜圖標 XML（約 50+ 個）
- 選擇器 XML（約 20+ 個）
- 其他形狀 XML（約 30+ 個）

---

## Flutter 讀取 XML 的限制

### ❌ Flutter 不能直接讀取

1. **Android XML Drawable**:
   - Flutter 不支持直接讀取 Android XML drawable 文件
   - 需要轉換為其他格式

2. **可用的替代方案**:
   - ✅ **SVG** - 使用 `flutter_svg` 包
   - ✅ **PNG/WebP** - 使用 `Image.asset()`
   - ✅ **Material Icons** - 使用內建圖標
   - ✅ **Flutter Widget** - 使用 `CustomPainter` 或 `Container`

---

## 轉換方案

### 方案 1: 轉換為 SVG（推薦用於複雜圖標）

#### 優點
- ✅ 矢量圖形，可縮放
- ✅ 文件小
- ✅ 支持顏色過濾

#### 步驟
1. 使用工具將 XML drawable 轉換為 SVG
2. 放置到 `assets/icons/` 目錄
3. 在 `pubspec.yaml` 中註冊
4. 使用 `flutter_svg` 包讀取

#### 示例
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/icons/ic_preview.svg',
  width: 24,
  height: 24,
)
```

---

### 方案 2: 使用 Material Icons（推薦用於簡單圖標）

#### 優點
- ✅ 無需額外資源文件
- ✅ 性能好
- ✅ 已實現（`reef_material_icons.dart`）

#### 缺點
- ❌ 可能沒有完全匹配的圖標
- ❌ 需要顏色過濾來匹配原始設計

---

### 方案 3: 轉換為 PNG（不推薦）

#### 優點
- ✅ 簡單直接

#### 缺點
- ❌ 不是矢量圖形
- ❌ 文件較大
- ❌ 需要多個分辨率

---

### 方案 4: 使用 CustomPainter（推薦用於複雜形狀）

#### 優點
- ✅ 完全控制
- ✅ 無需額外資源文件

#### 缺點
- ❌ 需要手動編寫代碼
- ❌ 維護成本高

---

## 當前使用的方案

### 已實現

1. **Material Icons 映射** (`reef_material_icons.dart`)
   - 用於常用圖標
   - 已映射約 50+ 個圖標

2. **Flutter Widget** (`reef_backgrounds.dart`, `reef_gradients.dart`)
   - 用於背景和漸變
   - 已實現核心背景和漸變

3. **PNG 圖片** (`assets/images/`, `assets/icons/`)
   - 用於複雜圖標和圖片
   - 已導入啟動頁面圖片和功能圖標

### 未實現

1. **SVG 轉換**
   - 尚未將 XML drawable 轉換為 SVG
   - 如果需要，可以使用工具轉換

2. **複雜圖標的 CustomPainter**
   - 尚未實現
   - 可以根據需要實現

---

## 是否需要轉換為 SVG？

### 建議

#### 優先級 1: 保持現狀（推薦）

**原因**:
- ✅ Material Icons 已覆蓋大部分常用圖標
- ✅ 性能好，無需額外資源
- ✅ 維護簡單

**適用於**: 大部分圖標

---

#### 優先級 2: 轉換特定圖標為 SVG

**何時需要**:
- 如果 Material Icons 沒有對應的圖標
- 如果需要完全匹配原始設計
- 如果需要自定義顏色和樣式

**步驟**:
1. 使用工具（如 Android Studio 或在線轉換器）將 XML 轉換為 SVG
2. 放置到 `assets/icons/`
3. 在 `pubspec.yaml` 中註冊
4. 使用 `flutter_svg` 讀取

---

## 轉換工具

### 1. Android Studio

1. 打開 XML drawable 文件
2. 右鍵 → "Convert to SVG"
3. 保存為 SVG 文件

### 2. 在線轉換器

- https://convertio.co/xml-svg/
- https://cloudconvert.com/xml-to-svg

### 3. 手動轉換

XML drawable 的 `<path>` 元素可以直接轉換為 SVG 的 `<path>` 元素。

---

## 總結

### 當前狀態

| 資源類型 | 轉換狀態 | 轉換方式 |
|---------|---------|---------|
| 常用圖標 | ✅ 已轉換 | Material Icons 映射 |
| 背景和漸變 | ✅ 已轉換 | Flutter Widget |
| 複雜圖標 | ⚠️ 未轉換 | 可轉換為 SVG |
| 選擇器 | ⚠️ 未轉換 | 使用 Flutter 狀態管理 |

### 建議

1. **保持現狀**: 大部分圖標已通過 Material Icons 映射解決
2. **按需轉換**: 如果特定圖標需要，可以轉換為 SVG
3. **不強制轉換**: 不需要轉換所有 XML drawable

---

## 如果需要轉換特定圖標

### 步驟

1. **識別需要轉換的圖標**
   ```bash
   # 查看所有 XML drawable
   ls docs/reef_b_app_res/drawable/*.xml
   ```

2. **轉換為 SVG**
   - 使用工具轉換
   - 或手動轉換（複製 `<path>` 元素）

3. **放置到 assets**
   ```bash
   # 放置到 assets/icons/
   cp converted.svg assets/icons/
   ```

4. **註冊資源**
   ```yaml
   # pubspec.yaml
   flutter:
     assets:
       - assets/icons/
   ```

5. **使用**
   ```dart
   import 'package:flutter_svg/flutter_svg.dart';
   
   SvgPicture.asset('assets/icons/ic_preview.svg')
   ```

---

## 結論

**Flutter 不能直接讀取 XML drawable 文件**。

**當前解決方案**:
- ✅ 常用圖標 → Material Icons（已實現）
- ✅ 背景和漸變 → Flutter Widget（已實現）
- ⚠️ 複雜圖標 → 可轉換為 SVG（按需）

**不需要強制轉換所有 XML 為 SVG**，因為：
- Material Icons 已覆蓋大部分需求
- 轉換為 SVG 需要額外工作
- 當前方案已足夠使用

如果需要轉換特定圖標，可以按需進行。

