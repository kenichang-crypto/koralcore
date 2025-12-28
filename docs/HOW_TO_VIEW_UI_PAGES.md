# 如何查看 UI 頁面

## 方式 1: 在 IDE 中查看代碼

### 使用 VS Code / Cursor

1. **打開文件**：
   - 按 `Cmd+P` (Mac) 或 `Ctrl+P` (Windows/Linux)
   - 輸入頁面名稱，例如：`home_page.dart`
   - 選擇文件打開

2. **快速導航**：
   - 使用 `Cmd+Shift+O` (Mac) 或 `Ctrl+Shift+O` (Windows/Linux) 查看文件中的符號
   - 使用 `Cmd+P` 然後輸入 `@` 查看文件中的類和方法

3. **查看頁面結構**：
   - 所有頁面都在 `lib/ui/features/` 目錄下
   - 每個功能模塊都有自己的文件夾

### 頁面文件位置

```
lib/ui/features/
├── home/
│   └── home_page.dart
├── splash/
│   └── pages/
│       └── splash_page.dart
├── device/
│   ├── device_page.dart
│   └── pages/
│       ├── device_settings_page.dart
│       └── add_device_page.dart
├── led/
│   └── pages/
│       ├── led_main_page.dart
│       ├── led_control_page.dart
│       └── ... (其他 LED 頁面)
├── dosing/
│   └── pages/
│       ├── dosing_main_page.dart
│       ├── pump_head_detail_page.dart
│       └── ... (其他 Dosing 頁面)
├── sink/
│   └── pages/
│       ├── sink_manager_page.dart
│       └── sink_position_page.dart
├── warning/
│   └── pages/
│       └── warning_page.dart
└── bluetooth/
    └── bluetooth_page.dart
```

---

## 方式 2: 運行 Flutter 應用查看實際 UI

### 前置條件

1. **確保 Flutter 已安裝**：
   ```bash
   flutter doctor
   ```

2. **連接設備或啟動模擬器**：
   - **Android**: 啟動 Android Studio 的 AVD 或連接實體設備
   - **iOS**: 啟動 Xcode 的模擬器或連接實體設備
   - **Web**: 不需要額外設置

### 運行應用

#### 在終端中運行

```bash
# 進入項目目錄
cd /Users/Kaylen/Documents/GitHub/koralcore

# 運行應用（會自動選擇可用設備）
flutter run

# 或指定設備
flutter run -d <device-id>

# 查看可用設備
flutter devices
```

#### 在 IDE 中運行

**VS Code / Cursor**:
1. 打開項目文件夾
2. 按 `F5` 或點擊「運行」按鈕
3. 選擇目標設備（Android/iOS/Web）

**Android Studio**:
1. 打開項目
2. 點擊「運行」按鈕（綠色三角形）
3. 選擇目標設備

### 熱重載功能

運行應用後，可以使用熱重載快速查看更改：

- **VS Code / Cursor**: 按 `Cmd+\` (Mac) 或 `Ctrl+\` (Windows/Linux)
- **終端**: 按 `r` 鍵
- **保存文件**: 自動觸發熱重載（如果啟用）

---

## 方式 3: 使用 Flutter DevTools

### 啟動 DevTools

1. **在應用運行時**：
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

2. **或在 VS Code 中**：
   - 打開命令面板 (`Cmd+Shift+P`)
   - 輸入 "Flutter: Open DevTools"
   - 選擇 "Widget Inspector" 查看 UI 樹

### DevTools 功能

- **Widget Inspector**: 查看 UI 組件樹
- **Performance**: 性能分析
- **Network**: 網絡請求
- **Logging**: 日誌查看

---

## 方式 4: 查看特定頁面

### 直接導航到頁面

在應用運行時，可以通過代碼修改來直接導航到特定頁面：

1. **修改 `main.dart`**：
   ```dart
   // 臨時修改，直接顯示特定頁面
   home: const LedMainPage(),  // 替換 SplashPage
   ```

2. **或修改 `SplashPage`**：
   ```dart
   // 在 SplashPage 中，直接導航到目標頁面
   Navigator.of(context).pushReplacement(
     MaterialPageRoute(builder: (_) => const LedMainPage()),
   );
   ```

### 使用路由名稱（如果已配置）

```dart
Navigator.pushNamed(context, '/led-main');
```

---

## 方式 5: 查看頁面文檔

### 已創建的文檔

1. **`docs/UI_PAGES_OVERVIEW.md`** - 完整的頁面概覽
2. **`docs/RESOURCE_LINKAGE_VERIFICATION.md`** - 資源連結驗證
3. **`docs/RESOURCE_LINKAGE_TEST_RESULTS.md`** - 資源測試結果

### 查看方式

- 在 IDE 中直接打開 Markdown 文件
- 使用 Markdown 預覽功能查看格式化的文檔

---

## 方式 6: 使用 Flutter Widget Inspector

### 在運行時檢查 UI

1. **啟動應用**
2. **打開 Widget Inspector**：
   - VS Code: `Cmd+Shift+P` → "Flutter: Open DevTools"
   - 或點擊應用右上角的調試按鈕

3. **選擇 Widget**：
   - 在 DevTools 中點擊 UI 元素
   - 查看對應的代碼位置和屬性

---

## 推薦工作流程

### 開發時

1. **在 IDE 中打開頁面文件**查看代碼結構
2. **運行應用** (`flutter run`) 查看實際 UI
3. **使用熱重載**快速迭代更改
4. **使用 Widget Inspector**檢查 UI 層次結構

### 調試時

1. **使用 DevTools** 進行性能分析
2. **查看日誌** 了解頁面狀態
3. **使用斷點** 調試頁面邏輯

---

## 快速命令參考

```bash
# 查看可用設備
flutter devices

# 運行應用
flutter run

# 運行並啟用熱重載
flutter run --hot

# 運行在特定設備
flutter run -d <device-id>

# 構建 APK (Android)
flutter build apk

# 構建 iOS
flutter build ios

# 運行測試
flutter test

# 分析代碼
flutter analyze
```

---

## 常見問題

### Q: 如何查看特定頁面的代碼？

A: 使用 `Cmd+P` 然後輸入頁面名稱，例如：
- `home_page.dart`
- `led_main_page.dart`
- `dosing_main_page.dart`

### Q: 如何快速導航到頁面定義？

A: 在代碼中：
- 右鍵點擊頁面類名 → "Go to Definition"
- 或使用 `Cmd+Click` (Mac) / `Ctrl+Click` (Windows)

### Q: 如何查看頁面的導航關係？

A: 查看 `docs/UI_PAGES_OVERVIEW.md` 中的「頁面導航結構」部分

### Q: 如何測試頁面？

A: 
1. 運行 `flutter test` 運行單元測試
2. 使用 Widget 測試測試 UI 組件
3. 手動運行應用進行集成測試

---

## 總結

**最推薦的方式**：
1. **開發時**: 在 IDE 中查看代碼 + 運行應用查看實際 UI
2. **調試時**: 使用 DevTools 的 Widget Inspector
3. **文檔**: 查看 `docs/UI_PAGES_OVERVIEW.md` 了解整體結構

這樣可以全面了解 UI 頁面的代碼和實際效果。

