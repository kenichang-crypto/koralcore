# iOS 圖標配置和 XML Drawable 轉換計畫

## 一、iOS 圖標配置

### 當前狀態
- ✅ Android 圖標已完整配置（所有分辨率）
- ⚠️ iOS 圖標待配置

### iOS 圖標需求
iOS 需要以下尺寸的 PNG 圖片：
- 20x20@1x, 20x20@2x, 20x20@3x
- 29x29@1x, 29x29@2x, 29x29@3x
- 40x40@1x, 40x40@2x, 40x40@3x
- 60x60@2x, 60x60@3x
- 76x76@1x, 76x76@2x
- 83.5x83.5@2x
- 1024x1024@1x

### 轉換方案
1. **使用 macOS 的 `sips` 工具**（如果可用）
2. **使用 ImageMagick**（如果已安裝）
3. **手動轉換**（使用設計工具）

### 實施步驟
1. 從 Android 的 `ic_launcher.webp` 或 `ic_launcher.png` 作為源文件
2. 轉換為 PNG 格式
3. 調整為所需尺寸
4. 複製到 `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
5. 更新 `Contents.json`

---

## 二、XML Drawable 轉換

### 當前狀態
- ⚠️ 約 109 個 XML drawable 文件待轉換
- ⚠️ 包括圖標、背景、形狀、選擇器等

### 轉換策略

#### 優先級 1：常用圖標（約 20-30 個）
使用 Flutter Material Icons 替代：
- `ic_add_black.xml` → `Icons.add`
- `ic_back.xml` → `Icons.arrow_back`
- `ic_check.xml` → `Icons.check`
- `ic_close.xml` → `Icons.close`
- `ic_delete.xml` → `Icons.delete`
- `ic_edit.xml` → `Icons.edit`
- 等等

#### 優先級 2：背景和形狀（約 5-8 個）
轉換為 Flutter Widget：
- `background_main.xml` → `Container` + `BoxDecoration`
- `dialog_background.xml` → `Container` + `BoxDecoration`
- `rainbow_gradient.xml` → `LinearGradient`
- 等等

#### 優先級 3：選擇器（約 20+ 個）
使用 Flutter 狀態管理：
- `checkbox_*.xml` → `Checkbox` + `StatefulWidget`
- `ic_*_select.xml` → `IconButton` + `ValueNotifier`
- 等等

#### 優先級 4：複雜圖標（約 50+ 個）
- 轉換為 SVG（如果可能）
- 或使用 `CustomPainter` 重新繪製
- 或保留為 PNG（如果已有對應圖片）

---

## 三、實施計畫

### Phase 1: iOS 圖標配置
1. 檢查可用的轉換工具
2. 從 Android 圖標轉換為 iOS 所需尺寸
3. 更新 `Contents.json`
4. 驗證圖標顯示

### Phase 2: 常用圖標轉換（Material Icons）
1. 創建圖標映射文件
2. 替換代碼中的圖標引用
3. 驗證顯示效果

### Phase 3: 背景和形狀轉換
1. 轉換背景 XML 為 Flutter Widget
2. 轉換形狀 XML 為 Flutter Widget
3. 更新相關 UI 代碼

### Phase 4: 選擇器轉換（可選）
1. 實現選擇器為 Flutter Widget
2. 更新相關 UI 代碼

---

## 四、注意事項

1. **iOS 圖標**：
   - 必須是 PNG 格式
   - 必須是正方形
   - 建議使用 1024x1024 作為源文件

2. **XML Drawable 轉換**：
   - 優先使用 Flutter Material Icons
   - 複雜圖標可以轉換為 SVG
   - 背景和形狀轉換為 Widget

3. **性能考慮**：
   - Material Icons 性能最好
   - SVG 次之
   - PNG 圖片需要額外加載

---

## 五、預估時間

- iOS 圖標配置：30-60 分鐘
- 常用圖標轉換：1-2 小時
- 背景和形狀轉換：1-2 小時
- 選擇器轉換：2-3 小時（可選）

**總計**：約 4-8 小時

