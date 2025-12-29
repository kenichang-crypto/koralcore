# Widget Previews

這個目錄包含了主要 UI 組件的預覽文件，用於在 IDE 中查看組件外觀，無需在手機上運行應用。

## ⚠️ 重要：如何讓 Preview 正常顯示

### 必要條件

1. **@Preview() annotation**：必須使用 `@Preview()` 註解
2. **Import**：必須有 `import 'package:flutter/widgets.dart';`
3. **Top-level function**：必須是 top-level function，不是 class method，也不是 main()
4. **返回 Widget**：函數必須返回 `Widget`
5. **MaterialApp**：必須包 `MaterialApp`
6. **在 lib/ 目錄下**：必須在 `lib/` 目錄下（不是 test）

### 使用方式

#### 步驟 1: 打開 Preview 面板

在 VS Code 左側：
- 點擊 **Flutter → Flutter Widget Preview**

#### 步驟 2: 如果看不到 Preview

如果寫了 Preview 但看不到，照順序做：

1. **存檔 Preview 所在的 .dart 文件**
2. **Cmd + Shift + P**（Mac）或 **Ctrl + Shift + P**（Windows/Linux）
3. 輸入：`Flutter: Restart Analysis Server`
4. 等待 5-10 秒，Preview 面板會刷新

這一步可以解決「明明寫對但 Preview 不出來」的 80% 問題。

#### 步驟 3: 確認 Preview 格式

每個 Preview 文件都應該是這樣的格式：

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';  // ⚠️ 必須有這個

@Preview()  // ⚠️ 必須有這個 annotation
Widget myWidgetPreview() {  // ⚠️ 必須是 top-level function
  return MaterialApp(  // ⚠️ 必須包 MaterialApp
    theme: ReefTheme.base(),
    home: Scaffold(
      body: MyWidget(),  // 你的組件
    ),
  );
}
```

### ⚠️ 常見錯誤

❌ **不要在 Preview 中做這些事**：
- 直接讀取 BLE
- 使用 `ref.watch()` 但沒有 Provider
- 使用 `MediaQuery.of(context)` 但沒有 MaterialApp
- 使用 `Navigator.of(context)` 但沒有 Navigator
- 執行 async init 或讀取 runtime-only state

✅ **正確做法**：
- Preview 只包「純 UI Widget」
- 不要 preview 整頁（Page），只 preview 組件本身
- 使用 mock 數據，不要依賴真實狀態

## Preview 文件列表

### 基礎組件

- **`feature_entry_card_preview.dart`** - FeatureEntryCard 組件預覽
  - 顯示啟用/禁用狀態
  - 多種場景示例

- **`reef_device_card_preview.dart`** - ReefDeviceCard 組件預覽
  - 卡片樣式（elevation, margin, radius）
  - 有/無點擊處理器的示例
  - 多個卡片列表展示

### 頁面布局

- **`home_page_layout_preview.dart`** - Home 頁面布局預覽
  - 頂部按鈕欄
  - Sink 選擇器
  - 設備列表區域
  - 完整頁面結構示例

## 對齊目標

這些 preview 用於確保 UI 組件與 `reef-b-app` 的設計保持一致：

- ✅ 卡片樣式：圓角 10dp，elevation 5dp，margin 6dp
- ✅ 間距系統：使用 `ReefSpacing` 統一間距
- ✅ 顏色系統：使用 `ReefColors` 統一顏色
- ✅ 文字樣式：使用 `ReefTextStyles` 統一文字樣式
- ✅ 背景：使用 `ReefMainBackground` 匹配漸變背景

## 添加新的 Preview

要為新組件創建 preview：

1. 在此目錄創建新文件 `[component_name]_preview.dart`
2. 創建一個 `StatelessWidget` 類
3. 使用 `MaterialApp` 包裹並應用 `ReefTheme.base()`
4. 創建組件的不同狀態示例
5. 添加到此 README 的文件列表中

## 注意事項

- Preview 文件不應包含實際業務邏輯，只展示 UI 結構
- 使用 placeholder 數據和 mock 回調
- 確保使用正確的主題和樣式系統
- 與 `reef-b-app` 的對齊要求保持一致

