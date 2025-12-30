# Splash Logo 和多語言系統修正

## 問題描述

1. **Logo 不對**: koralcore 使用的 logo 與 reef-b-app 不一致
2. **多語言系統完全沒有作用**: 不會隨手機的語言來變換

---

## 1. Logo 問題修正

### 1.1 reef-b-app 使用的 Logo

**activity_splash.xml**:
```xml
<ImageView
    android:src="@drawable/app_icon"
    android:scaleType="fitCenter"
    android:layout_margin="@dimen/dp_20"
    app:layout_constraintVertical_bias=".4" />
```

**app_icon.xml** (vector drawable):
- 尺寸: 1936dp × 1936dp
- 背景: `#008000` (綠色)
- Logo: 白色圖案（vector path）

### 1.2 koralcore 修正前

**SplashPage.dart**:
```dart
Image.asset('assets/images/splash/img_splash_logo.png')
```

**問題**: 使用 `img_splash_logo.png` 而不是 `ic_splash_logo.png`（對應 `app_icon`）

### 1.3 koralcore 修正後

**SplashPage.dart**:
```dart
Image.asset('assets/images/splash/ic_splash_logo.png') // PARITY: @drawable/app_icon
```

**修正內容**:
- ✅ 使用 `ic_splash_logo.png`（對應 reef-b-app 的 `app_icon.xml`）
- ✅ 保持相同的 fallback 機制
- ✅ 保持相同的尺寸和位置（40% 高度，20dp margin）

---

## 2. 多語言系統問題修正

### 2.1 問題分析

**修正前的問題**:
```dart
localeResolutionCallback: (locale, supportedLocales) {
  if (locale == null) {
    return supportedLocales.first; // ❌ 問題：locale 不會是 null
  }
  // ... 自定義匹配邏輯
}
```

**問題**:
1. `locale` 參數不會是 `null`，Flutter 會自動提供系統 locale
2. 自定義匹配邏輯可能不完整，導致無法正確匹配系統語言
3. 沒有使用 Flutter 的標準 locale 解析算法

### 2.2 修正方案

**使用 Flutter 的 `basicLocaleListResolution`**:
```dart
import 'package:flutter_localizations/src/utils.dart' show basicLocaleListResolution;

localeResolutionCallback: (locale, supportedLocales) {
  // Use Flutter's built-in resolution algorithm
  // This automatically handles system locale detection and matching
  return basicLocaleListResolution(
    locale != null ? [locale] : <Locale>[],
    supportedLocales,
  );
}
```

**優點**:
- ✅ 使用 Flutter 標準算法，自動處理系統 locale 檢測
- ✅ 自動匹配語言碼、國家碼、腳本碼
- ✅ 自動處理 fallback（如 `zh_TW` → `zh_Hant` → `zh` → `en`）
- ✅ 與 Flutter 官方推薦做法一致

---

## 3. 完整啟動流程模擬對照

### 3.1 步驟 1: 點擊 App 圖標

**reef-b-app**:
```
Android 系統
  ↓
讀取 AndroidManifest.xml
  ↓
找到 LAUNCHER intent → SplashActivity
  ↓
啟動 SplashActivity
```

**koralcore**:
```
Android 系統
  ↓
讀取 AndroidManifest.xml
  ↓
找到 LAUNCHER intent → MainActivity (Flutter)
  ↓
啟動 MainActivity
  ↓
Flutter Engine 初始化
  ↓
MaterialApp 構建
  ↓
home: SplashPage
```

**對照狀態**: ✅ **100% 對照**（最終都顯示 Splash 頁面）

---

### 3.2 步驟 2: Splash 頁面顯示

**reef-b-app**:
```
SplashActivity.onCreate()
  ↓
設置全屏模式
  ↓
顯示 activity_splash.xml
  ├─ 背景: #008000
  └─ ImageView: @drawable/app_icon
      ├─ 位置: 40% 高度
      ├─ margin: 20dp
      └─ scaleType: fitCenter
  ↓
延遲 1.5 秒
```

**koralcore（修正後）**:
```
SplashPage.initState()
  ↓
設置全屏模式 (SystemUiMode.immersiveSticky)
  ↓
顯示 SplashPage
  ├─ 背景: #008000 ✅
  └─ Image.asset: ic_splash_logo.png ✅
      ├─ 位置: 40% 高度 (Alignment(0, -0.2)) ✅
      ├─ margin: 20dp ✅
      └─ fit: BoxFit.contain ✅
  ↓
延遲 1.5 秒 ✅
```

**對照狀態**: ✅ **100% 對照**

---

### 3.3 步驟 3: 系統語言檢測

**reef-b-app**:
```
Android 系統
  ↓
讀取系統語言設置
  ↓
應用自動使用對應語言的 strings.xml
  ├─ values/strings.xml (英文)
  ├─ values-zh-rTW/strings.xml (繁體中文)
  └─ values-ja/strings.xml (日語)
```

**koralcore（修正後）**:
```
Flutter 系統
  ↓
讀取系統語言設置
  ↓
MaterialApp.localeResolutionCallback
  ↓
basicLocaleListResolution()
  ├─ 自動匹配系統 locale
  ├─ 處理語言碼匹配 (zh_TW → zh_Hant)
  └─ 處理 fallback (zh_Hant → zh → en)
  ↓
AppLocalizations.delegate.load(locale)
  ↓
加載對應語言的 ARB 文件
  ├─ intl_en.arb (英文)
  ├─ intl_zh_Hant.arb (繁體中文)
  └─ intl_ja.arb (日語)
```

**對照狀態**: ✅ **100% 對照**

---

### 3.4 步驟 4: 跳轉到主頁

**reef-b-app**:
```
SplashActivity (1.5 秒後)
  ↓
MainActivity.start()
  ↓
MainActivity.onCreate()
  ├─ 設置 Navigation
  ├─ 設置 View/Listener/Observer
  └─ checkBlePermission() → 啟動 BLE 掃描
  ↓
主界面顯示（使用系統語言）
```

**koralcore（修正後）**:
```
SplashPage (1.5 秒後)
  ↓
Navigator.pushReplacement(MainScaffold)
  ↓
MainScaffold.initState()
  ├─ 設置 Navigation
  └─ _initializeAndRequestPermissions() → 啟動 BLE 掃描
  ↓
主界面顯示（使用系統語言）✅
```

**對照狀態**: ✅ **100% 對照**

---

## 4. 測試步驟

### 4.1 Logo 測試

1. **啟動應用**
   - 點擊 app 圖標
   - 觀察 Splash 頁面

2. **驗證 Logo**
   - ✅ 背景色應為 `#008000`（綠色）
   - ✅ Logo 應顯示在 40% 高度位置
   - ✅ Logo 應為白色圖案（對應 `app_icon.xml`）
   - ✅ Logo 應有 20dp margin

### 4.2 多語言測試

1. **設置系統語言為繁體中文**
   ```
   設置 → 系統 → 語言和輸入法 → 語言
   → 選擇「繁體中文（台灣）」
   → 重啟應用
   ```

2. **驗證多語言**
   - ✅ 應用應自動顯示繁體中文
   - ✅ 檢查主頁標題、按鈕文字等是否為繁體中文
   - ✅ 檢查所有 UI 文字是否使用對應語言

3. **測試其他語言**
   - 重複上述步驟，測試：
     - 簡體中文
     - 日語
     - 韓語
     - 英語

---

## 5. 修正總結

### ✅ Logo 修正

| 項目 | reef-b-app | koralcore（修正前） | koralcore（修正後） |
|------|-----------|------------------|------------------|
| Logo 資源 | `@drawable/app_icon` | `img_splash_logo.png` ❌ | `ic_splash_logo.png` ✅ |
| 背景色 | `#008000` | `#008000` ✅ | `#008000` ✅ |
| 位置 | 40% 高度 | 40% 高度 ✅ | 40% 高度 ✅ |
| Margin | 20dp | 20dp ✅ | 20dp ✅ |

### ✅ 多語言系統修正

| 項目 | reef-b-app | koralcore（修正前） | koralcore（修正後） |
|------|-----------|------------------|------------------|
| 語言檢測 | Android 自動 | 自定義邏輯 ❌ | `basicLocaleListResolution` ✅ |
| 系統語言跟隨 | ✅ 自動 | ❌ 不工作 | ✅ 自動 |
| 語言匹配 | Android 標準 | 自定義（可能不完整） | Flutter 標準 ✅ |
| Fallback | Android 標準 | 自定義 | Flutter 標準 ✅ |

---

## 6. 結論

### ✅ Logo 修正完成

- 使用 `ic_splash_logo.png` 對照 reef-b-app 的 `app_icon.xml`
- 保持相同的顯示效果（背景、位置、尺寸）

### ✅ 多語言系統修正完成

- 使用 Flutter 標準的 `basicLocaleListResolution`
- 自動跟隨系統語言
- 正確處理語言匹配和 fallback

**狀態**: ✅ **已修正，等待測試驗證**

