# 多語系自動切換功能狀態

## 當前實現狀態

### ✅ koralcore 已實現多語系自動切換功能

koralcore 使用 Flutter 的標準本地化系統，**會自動根據手機系統語言切換語系**。

### 配置位置

1. **主應用配置** (`lib/main.dart`):
```dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  // 沒有設置 locale，會自動使用系統語言
)
```

2. **支持的語言列表** (`lib/l10n/app_localizations.dart`):
```dart
static const List<Locale> supportedLocales = <Locale>[
  Locale('ar'),      // 阿拉伯語
  Locale('de'),      // 德語
  Locale('en'),      // 英語
  Locale('es'),      // 西班牙語
  Locale('fr'),      // 法語
  Locale('id'),      // 印尼語
  Locale('ja'),      // 日語
  Locale('ko'),      // 韓語
  Locale('pt'),      // 葡萄牙語
  Locale('ru'),      // 俄語
  Locale('th'),      // 泰語
  Locale('vi'),      // 越南語
  Locale('zh'),      // 簡體中文
  Locale('zh', 'Hant'), // 繁體中文
];
```

### 自動切換機制

1. **系統語言檢測**：
   - Flutter 的 `MaterialApp` 會自動讀取設備的系統語言設置
   - 如果沒有明確設置 `locale` 屬性，會使用 `Localizations.localeOf(context)` 獲取系統語言

2. **語言匹配邏輯**：
   - 首先嘗試匹配完整的語言代碼（如 `zh_Hant`）
   - 如果沒有匹配，則回退到語言代碼（如 `zh`）
   - 如果都不匹配，則使用默認語言（`en`）

3. **語言查找實現** (`lookupAppLocalizations`):
   - 支持語言+腳本代碼（如 `zh_Hant`）
   - 支持僅語言代碼（如 `zh`, `en`）
   - 自動回退到最接近的語言

## 與 reef-b-app 的對比

### reef-b-app 支持的語言
- `values-ar` - 阿拉伯語
- `values-de` - 德語
- `values-es` - 西班牙語
- `values-fr` - 法語
- `values-in` - 印尼語
- `values-ja` - 日語
- `values-ko` - 韓語
- `values-pt` - 葡萄牙語
- `values-ru` - 俄語
- `values-th` - 泰語
- `values-vi` - 越南語
- `values-zh-rTW` - 繁體中文

### koralcore 支持的語言
- `intl_ar.arb` - 阿拉伯語 ✅
- `intl_de.arb` - 德語 ✅
- `intl_en.arb` - 英語 ✅
- `intl_es.arb` - 西班牙語 ✅
- `intl_fr.arb` - 法語 ✅
- `intl_id.arb` - 印尼語 ✅
- `intl_ja.arb` - 日語 ✅
- `intl_ko.arb` - 韓語 ✅
- `intl_pt.arb` - 葡萄牙語 ✅
- `intl_ru.arb` - 俄語 ✅
- `intl_th.arb` - 泰語 ✅
- `intl_vi.arb` - 越南語 ✅
- `intl_zh_Hant.arb` - 繁體中文 ✅
- `intl_zh.arb` - 簡體中文（reef-b-app 沒有）

### 對比結果

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 自動跟隨系統語言 | ✅ | ✅ | ✅ 一致 |
| 支持語言數量 | 12 | 14 | ✅ koralcore 更多 |
| 繁體中文支持 | ✅ | ✅ | ✅ 一致 |
| 簡體中文支持 | ❌ | ✅ | ℹ️ koralcore 額外支持 |
| 語言切換機制 | Android/iOS 系統 | Flutter 標準 | ✅ 功能一致 |

## 測試方法

### 測試自動切換

1. **Android**:
   - 設置 → 系統 → 語言和輸入法 → 語言
   - 更改系統語言
   - 重新啟動應用，應自動切換到對應語言

2. **iOS**:
   - 設置 → 通用 → 語言與地區 → iPhone 語言
   - 更改系統語言
   - 重新啟動應用，應自動切換到對應語言

3. **開發測試**:
   - 在模擬器/模擬器中更改系統語言
   - 重新啟動應用
   - 檢查 UI 文字是否已切換

## 結論

✅ **koralcore 已經實現了和 reef-b-app 一樣的多語系功能**

- ✅ 會自動跟隨手機系統語言
- ✅ 支持所有 reef-b-app 支持的語言
- ✅ 額外支持簡體中文
- ✅ 使用 Flutter 標準本地化系統，穩定可靠

**無需額外配置，應用會自動根據手機語言設置切換語系。**

