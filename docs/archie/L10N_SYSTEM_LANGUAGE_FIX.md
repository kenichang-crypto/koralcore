# 多語言系統修正文檔

## 問題描述

koralcore 的多語言系統沒有實現，不會隨手機的語言來變換。

## 問題分析

### 1. 現行多語言系統確認

#### ✅ 已實現的部分
1. **ARB 文件**: 已創建所有語言的 ARB 文件（14 種語言）
2. **LocalizationsDelegate**: 已正確配置 `AppLocalizations.delegate`
3. **SupportedLocales**: 已正確配置 `AppLocalizations.supportedLocales`
4. **依賴項**: 已安裝 `flutter_localizations` 和 `intl`

#### ❌ 缺失的部分
1. **localeResolutionCallback**: `MaterialApp` 缺少 `localeResolutionCallback`，導致無法正確解析系統語言
2. **iOS Info.plist**: 缺少 `CFBundleLocalizations` 配置，iOS 無法識別支持的多語言

---

## 修正內容

### 1. 修正 `main.dart` - 添加 `localeResolutionCallback`

**問題**: Flutter 的 `MaterialApp` 需要 `localeResolutionCallback` 來正確解析系統語言，特別是當系統語言不完全匹配支持語言時（例如 `zh_TW` → `zh_Hant`）。

**修正**:
```dart
MaterialApp(
  // ... 其他配置
  supportedLocales: AppLocalizations.supportedLocales,
  localeResolutionCallback: (locale, supportedLocales) {
    // 處理語言匹配邏輯
    // 1. 精確匹配（語言碼 + 國家碼 + 腳本碼）
    // 2. 中文特殊處理（zh_Hant vs zh）
    // 3. 語言碼匹配
    // 4. 回退到默認語言（en）
  },
)
```

**匹配邏輯**:
1. **精確匹配**: 檢查語言碼、國家碼、腳本碼是否完全匹配
2. **中文特殊處理**: 
   - 系統語言為 `zh_Hant` 或 `zh_TW` → 匹配 `zh_Hant`
   - 系統語言為 `zh` 或 `zh_CN` → 匹配 `zh`（簡體中文）
3. **語言碼匹配**: 如果精確匹配失敗，嘗試匹配語言碼
4. **回退**: 如果都不匹配，回退到第一個支持語言（通常是 `en`）

### 2. 修正 `ios/Runner/Info.plist` - 添加 `CFBundleLocalizations`

**問題**: iOS 需要 `CFBundleLocalizations` 來聲明應用支持的多語言。

**修正**:
```xml
<key>CFBundleLocalizations</key>
<array>
    <string>ar</string>
    <string>de</string>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
    <string>id</string>
    <string>ja</string>
    <string>ko</string>
    <string>pt</string>
    <string>ru</string>
    <string>th</string>
    <string>vi</string>
    <string>zh-Hans</string>
    <string>zh-Hant</string>
</array>
```

**注意**: iOS 使用 `zh-Hans` 和 `zh-Hant` 格式，而 Flutter 使用 `zh` 和 `zh_Hant` 格式。

---

## 測試方法

### 1. Android 測試

1. **設置系統語言為繁體中文**:
   - 設置 → 系統 → 語言和輸入法 → 語言
   - 選擇「繁體中文（台灣）」
   - 重啟應用

2. **驗證**:
   - 應用應自動顯示繁體中文
   - 檢查主頁標題、按鈕文字等是否為繁體中文

3. **測試其他語言**:
   - 重複上述步驟，測試其他支持語言（日語、韓語、英語等）

### 2. iOS 測試

1. **設置系統語言為繁體中文**:
   - 設置 → 一般 → 語言與地區 → iPhone 語言
   - 選擇「繁體中文（台灣）」
   - 重啟應用

2. **驗證**:
   - 應用應自動顯示繁體中文
   - 檢查主頁標題、按鈕文字等是否為繁體中文

3. **測試其他語言**:
   - 重複上述步驟，測試其他支持語言

---

## 支持的語言列表

| 語言代碼 | 語言名稱 | ARB 文件 | iOS 配置 |
|---------|---------|---------|---------|
| `ar` | 阿拉伯語 | `intl_ar.arb` | `ar` |
| `de` | 德語 | `intl_de.arb` | `de` |
| `en` | 英語 | `intl_en.arb` | `en` |
| `es` | 西班牙語 | `intl_es.arb` | `es` |
| `fr` | 法語 | `intl_fr.arb` | `fr` |
| `id` | 印尼語 | `intl_id.arb` | `id` |
| `ja` | 日語 | `intl_ja.arb` | `ja` |
| `ko` | 韓語 | `intl_ko.arb` | `ko` |
| `pt` | 葡萄牙語 | `intl_pt.arb` | `pt` |
| `ru` | 俄語 | `intl_ru.arb` | `ru` |
| `th` | 泰語 | `intl_th.arb` | `th` |
| `vi` | 越南語 | `intl_vi.arb` | `vi` |
| `zh` | 簡體中文 | `intl_zh.arb` | `zh-Hans` |
| `zh_Hant` | 繁體中文 | `intl_zh_Hant.arb` | `zh-Hant` |

---

## 修正後的流程

### 應用啟動流程

```
1. 應用啟動
   ↓
2. Flutter Engine 初始化
   ↓
3. MaterialApp 構建
   ↓
4. 系統語言檢測
   - Android: 從系統設置讀取語言
   - iOS: 從系統設置讀取語言
   ↓
5. localeResolutionCallback 執行
   - 匹配系統語言到支持語言
   - 處理特殊情況（如 zh_TW → zh_Hant）
   ↓
6. AppLocalizations.delegate 加載對應語言
   ↓
7. UI 顯示對應語言文字
```

---

## 驗證清單

- [x] 添加 `localeResolutionCallback` 到 `MaterialApp`
- [x] 添加 `CFBundleLocalizations` 到 iOS `Info.plist`
- [ ] 測試 Android 繁體中文切換
- [ ] 測試 Android 簡體中文切換
- [ ] 測試 Android 日語切換
- [ ] 測試 Android 韓語切換
- [ ] 測試 Android 英語切換
- [ ] 測試 iOS 繁體中文切換
- [ ] 測試 iOS 簡體中文切換
- [ ] 測試 iOS 日語切換
- [ ] 測試 iOS 韓語切換
- [ ] 測試 iOS 英語切換

---

## 結論

修正後，koralcore 的多語言系統將能夠：
1. ✅ 自動檢測系統語言
2. ✅ 正確匹配支持語言
3. ✅ 處理特殊情況（如中文變體）
4. ✅ 在 Android 和 iOS 上正常工作

**狀態**: ✅ **已修正**

