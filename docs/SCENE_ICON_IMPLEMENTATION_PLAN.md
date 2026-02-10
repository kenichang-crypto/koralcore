# Scene Icon 實現計劃

**建立日期**: 2026-01-03  
**優先級**: P2 (非阻塞)  
**預計工作量**: ~2 小時

---

## 📋 Android Scene Icon 清單

從 `ReefBUtil.kt:15-52` 找到 **11 個 Scene Icon**:

| ID | Android Drawable | Flutter Asset Path | 說明 | 尺寸 |
|----|-----------------|-------------------|------|------|
| 0 | `ic_thunder.xml` | `assets/icons/ic_thunder.svg` | 雷電 | 40x40dp |
| 1 | `ic_cloudy.xml` | `assets/icons/ic_cloudy.svg` | 多雲 | 40x40dp |
| 2 | `ic_sunny.xml` | `assets/icons/ic_sunny.svg` | 晴天 | 40x40dp |
| 3 | `ic_rainy.xml` | `assets/icons/ic_rainy.svg` | 雨天 | 40x40dp |
| 4 | `ic_dizzle.xml` | `assets/icons/ic_dizzle.svg` | 小雨 | 40x40dp |
| 5 | `ic_none.xml` | `assets/icons/ic_none.svg` | 無 | 40x40dp |
| 6 | `ic_moon.xml` | `assets/icons/ic_moon.svg` | 月亮 | 40x40dp |
| 7 | `ic_sunrise.xml` | `assets/icons/ic_sunrise.svg` | 日出 | 40x40dp |
| 8 | `ic_sunset.xml` | `assets/icons/ic_sunset.svg` | 日落 | 40x40dp |
| 9 | `ic_mist.xml` | `assets/icons/ic_mist.svg` | 霧 | 40x40dp |
| 10 | `ic_light_off.xml` | `assets/icons/ic_light_off.svg` | 燈關閉 | 40x40dp |

**來源**: `reef-b-app/res/drawable/`  
**使用位置**: `adapter_scene_icon.xml:15-19` (img_icon, 40x40dp, padding 8dp)

---

## 🎯 實現步驟

### Step 1: 提取 Android Drawable (30 分鐘)

1. 從 `reef-b-app/android/ReefB_Android/app/src/main/res/drawable/` 提取 11 個 XML Vector Drawable
2. 轉換為 SVG 格式 (使用工具或手動轉換 path data)
3. 放入 `koralcore/assets/icons/`
4. 更新 `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/ic_thunder.svg
    - assets/icons/ic_cloudy.svg
    - assets/icons/ic_sunny.svg
    - assets/icons/ic_rainy.svg
    - assets/icons/ic_dizzle.svg
    - assets/icons/ic_none.svg
    - assets/icons/ic_moon.svg
    - assets/icons/ic_sunrise.svg
    - assets/icons/ic_sunset.svg
    - assets/icons/ic_mist.svg
    - assets/icons/ic_light_off.svg
```

---

### Step 2: 建立 SceneIconHelper (15 分鐘)

建立 `lib/shared/helpers/scene_icon_helper.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Scene Icon Helper - 100% Parity with Android ReefBUtil.getSceneIconById()
/// PARITY SOURCE: ReefBUtil.kt:15-52
class SceneIconHelper {
  /// 根據 Scene Icon ID 取得對應的 Icon Widget
  /// 
  /// [id] Scene Icon ID (0-10)
  /// [size] Icon 尺寸，預設 40dp (與 adapter_scene_icon.xml 一致)
  /// [color] Icon 顏色 (可選)
  /// 
  /// PARITY SOURCE: 
  /// - Android: ReefBUtil.kt:15-52 (getSceneIconById)
  /// - Layout: adapter_scene_icon.xml:15-19 (img_icon, 40x40dp, padding 8dp)
  static Widget getSceneIcon(
    int id, {
    double size = 40, // dp_40 from adapter_scene_icon.xml
    Color? color,
  }) {
    final iconPath = _getIconPath(id);
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// 取得 Scene Icon 的 asset 路徑
  /// PARITY SOURCE: ReefBUtil.kt:16-51
  static String _getIconPath(int id) {
    switch (id) {
      case 0:
        return 'assets/icons/ic_thunder.svg'; // R.drawable.ic_thunder
      case 1:
        return 'assets/icons/ic_cloudy.svg'; // R.drawable.ic_cloudy
      case 2:
        return 'assets/icons/ic_sunny.svg'; // R.drawable.ic_sunny
      case 3:
        return 'assets/icons/ic_rainy.svg'; // R.drawable.ic_rainy
      case 4:
        return 'assets/icons/ic_dizzle.svg'; // R.drawable.ic_dizzle
      case 5:
        return 'assets/icons/ic_none.svg'; // R.drawable.ic_none
      case 6:
        return 'assets/icons/ic_moon.svg'; // R.drawable.ic_moon
      case 7:
        return 'assets/icons/ic_sunrise.svg'; // R.drawable.ic_sunrise
      case 8:
        return 'assets/icons/ic_sunset.svg'; // R.drawable.ic_sunset
      case 9:
        return 'assets/icons/ic_mist.svg'; // R.drawable.ic_mist
      case 10:
        return 'assets/icons/ic_light_off.svg'; // R.drawable.ic_light_off
      default:
        return 'assets/icons/ic_none.svg'; // Fallback (Android returns null)
    }
  }

  /// 取得所有 Scene Icon ID 列表
  /// PARITY SOURCE: ReefBUtil.kt supports ID 0-10
  static List<int> getAllSceneIconIds() => List.generate(11, (i) => i);

  /// 取得 Scene Icon 的 Android drawable 名稱 (用於 debug/trace)
  static String getDrawableName(int id) {
    switch (id) {
      case 0:
        return 'ic_thunder';
      case 1:
        return 'ic_cloudy';
      case 2:
        return 'ic_sunny';
      case 3:
        return 'ic_rainy';
      case 4:
        return 'ic_dizzle';
      case 5:
        return 'ic_none';
      case 6:
        return 'ic_moon';
      case 7:
        return 'ic_sunrise';
      case 8:
        return 'ic_sunset';
      case 9:
        return 'ic_mist';
      case 10:
        return 'ic_light_off';
      default:
        return 'ic_none';
    }
  }
}
```

---

### Step 3: 替換 Material Icons (15 分鐘)

替換以下檔案中的 `Icons.image`:

#### 1. `led_scene_add_page.dart`

```dart
// BEFORE (Material Icon violation)
Icon(Icons.image, size: 40)

// AFTER (Android parity)
SceneIconHelper.getSceneIcon(
  sceneIconId ?? 2, // 預設 ic_sunny (ID=2)
  size: 40, // dp_40 from adapter_scene_icon.xml
)
// Android: ReefBUtil.kt:24 (ic_sunny), adapter_scene_icon.xml:15
```

#### 2. `led_scene_edit_page.dart`

```dart
// BEFORE
Icon(Icons.image, size: 40)

// AFTER
SceneIconHelper.getSceneIcon(scene.iconId, size: 40)
// Android: ReefBUtil.kt:15-51, adapter_scene_icon.xml:15
```

#### 3. `led_scene_delete_page.dart`

```dart
// BEFORE (ListTile)
leading: Icon(Icons.image)

// AFTER
leading: SceneIconHelper.getSceneIcon(scene.iconId, size: 24)
// Android: adapter_scene.xml (ListItem icon, 通常小一點)
```

#### 4. `led_scene_list_page.dart`

```dart
// BEFORE
Icon(Icons.auto_awesome) // Dynamic scene icon
Icon(Icons.pie_chart_outline) // Static scene icon
Icon(Icons.image) // Scene icon

// AFTER
// TODO: 需確認 Android 如何顯示 Dynamic/Static scene 的 icon
SceneIconHelper.getSceneIcon(scene.iconId, size: 40)
```

---

### Step 4: 實現 Scene Icon Selector (45 分鐘)

建立 Scene Icon 選擇器 BottomSheet (參考 Android `adapter_scene_icon.xml`):

#### `lib/features/led/presentation/widgets/scene_icon_selector.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../shared/helpers/scene_icon_helper.dart';

/// Scene Icon Selector BottomSheet
/// PARITY SOURCE: 
/// - Android: SceneIconAdapter.kt
/// - Layout: adapter_scene_icon.xml
/// - RecyclerView: activity_led_scene_add.xml / activity_led_scene_edit.xml
class SceneIconSelector {
  /// 顯示 Scene Icon 選擇器
  static Future<int?> show(
    BuildContext context, {
    int? selectedIconId,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => _SceneIconSelectorContent(
        selectedIconId: selectedIconId,
      ),
    );
  }
}

class _SceneIconSelectorContent extends StatelessWidget {
  final int? selectedIconId;

  const _SceneIconSelectorContent({this.selectedIconId});

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_scene_icon.xml:2-12
    // - MaterialCardView: cardCornerRadius=24dp, cardBackgroundColor=bg_aaa
    // - img_icon: 40x40dp, padding=8dp
    
    return Container(
      padding: const EdgeInsets.all(16), // dp_16
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TODO(android @string/xxx)', // Scene Icon 選擇標題
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16), // dp_16
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // TODO: 確認 Android RecyclerView 的 span count
              crossAxisSpacing: 16, // dp_16 (marginStart + marginEnd)
              mainAxisSpacing: 16,
            ),
            itemCount: SceneIconHelper.getAllSceneIconIds().length,
            itemBuilder: (context, index) {
              final iconId = index;
              final isSelected = selectedIconId == iconId;
              
              return GestureDetector(
                onTap: () => Navigator.pop(context, iconId),
                child: Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // dp_24 cardCornerRadius
                  ),
                  elevation: 0, // dp_0 cardElevation
                  child: Padding(
                    padding: const EdgeInsets.all(8), // dp_8 padding
                    child: SceneIconHelper.getSceneIcon(
                      iconId,
                      size: 40, // dp_40
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

#### 使用範例 (在 Scene Add/Edit Page)

```dart
// Scene Add/Edit Page
GestureDetector(
  onTap: () async {
    final selectedIconId = await SceneIconSelector.show(
      context,
      selectedIconId: currentIconId,
    );
    if (selectedIconId != null) {
      setState(() {
        currentIconId = selectedIconId;
      });
    }
  },
  child: SceneIconHelper.getSceneIcon(currentIconId ?? 2, size: 40),
)
```

---

### Step 5: 測試與驗證 (15 分鐘)

#### 測試項目

1. ✅ 確認 11 個 Scene Icon SVG 正確顯示
2. ✅ 確認 Icon 尺寸與 Android 一致 (40x40dp)
3. ✅ 確認 Scene Icon Selector 可以選擇並回傳 ID
4. ✅ 確認 Scene Add/Edit/Delete/List 頁面顯示正確的 Icon
5. ✅ 確認 Material Icons 違規已全部移除

#### 驗證清單

```bash
# 檢查 Material Icons 是否已全部移除
grep -rn "Icons\\.image" lib/features/led --include="*.dart"
grep -rn "Icons\\.auto_awesome" lib/features/led --include="*.dart"
grep -rn "Icons\\.pie_chart_outline" lib/features/led --include="*.dart"

# 應該全部沒有結果 (或只有 TODO comment)
```

---

## 📊 工作量估計

| 步驟 | 工作項目 | 預計時間 |
|------|---------|---------|
| **Step 1** | 提取 11 個 Android Drawable | 15 分鐘 |
| **Step 1** | 轉換為 SVG 格式 | 15 分鐘 |
| **Step 2** | 建立 SceneIconHelper | 15 分鐘 |
| **Step 3** | 替換 Material Icons (4 個檔案) | 15 分鐘 |
| **Step 4** | 實現 Scene Icon Selector | 45 分鐘 |
| **Step 5** | 測試與驗證 | 15 分鐘 |
| **總計** | | **2 小時** |

---

## 🎯 優先級決策

### 建議: 暫緩實現

**原因**:

1. **L3 規則核心已完成**: 
   - L3-1 Icon 來源: 86% ✅
   - L3-2 Icon 對齊: 100% ✅
   - L3-3 Icon 追溯: 100% ✅ (對照表完成)

2. **Scene Icon 是功能性需求**: 
   - 不影響 L3 規則合規性
   - 只是 Material Icons 的替換工作
   - 可以在「Feature Implementation Mode」階段實現

3. **當前 TODO 標註完整**: 
   - Material Icons 違規已識別並標註
   - 已有完整實現計劃
   - 不會遺漏

4. **時間效益**: 
   - 2 小時實現 vs. L3 評分提升有限 (+5%)
   - 優先處理更高價值的工作 (如 L0/L1/L2 審核)

---

### 後續處理時機

**建議時機**: 在「LED Scene 功能實現」階段一併處理

**理由**:
- Scene Icon 選擇器是 Scene Add/Edit 功能的一部分
- 功能實現時需要完整測試 Scene Icon 互動
- 避免重複工作 (現在只做 UI，未來還要加業務邏輯)

---

## 📝 L3 規則合規性說明

### 當前狀態

**L3-1 Icon 來源**:
- CommonIconHelper: 118 處 ✅
- Material Icons: 19 處 (已標註 TODO) ⚠️
- **評分**: 86%

**L3-2 Icon 對齊**:
- 位置: 100% ✅
- 對齊: 100% ✅
- 間距: 95% ✅
- **評分**: 98%

**L3-3 Icon 追溯**:
- 對照表: 100% ✅
- 文件: 100% ✅
- **評分**: 100%

### Scene Icon 實現後

**L3-1 Icon 來源**:
- CommonIconHelper + SceneIconHelper: 137 處 ✅
- Material Icons: 0 處 ✅
- **評分**: 100%

**整體 L3 評分**: 86% → **99%** (+13%)

---

## ✅ 結論

### 當前決策

**暫緩實現** - 將 Scene Icon 功能列入「Feature Implementation Mode」待辦清單

### 替代方案 (如需立即實現)

如果決定立即實現，建議執行順序:

1. ✅ Step 1-2: 提取 Android Drawable + 建立 SceneIconHelper (30 分鐘)
2. ✅ Step 3: 替換 Material Icons (15 分鐘)
3. ⏸️ Step 4-5: 暫緩 Scene Icon Selector (留待功能實現階段)

**快速達標方案**: ~45 分鐘可將 L3 評分提升至 **99%**

---

**文件建立日期**: 2026-01-03  
**狀態**: 計劃完成，待決策執行  
**下一步**: 產出 L3 最終報告

