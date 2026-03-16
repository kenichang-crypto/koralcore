# 移除簡體中文

## 規則

1. **不要再建簡體字**（簡體中文）
2. **不要自建**（所有內容必須對照 reef-b-app）

---

## 已執行的操作

### ✅ 1. 刪除簡體中文 ARB 文件

**刪除**:
- `lib/l10n/intl_zh.arb` ❌ 已刪除

**保留**:
- `lib/l10n/intl_zh_Hant.arb` ✅ 繁體中文（對照 reef-b-app 的 `values-zh-rTW/strings.xml`）

---

### ✅ 2. 刪除簡體中文實現文件

**刪除**:
- `lib/l10n/app_localizations_zh.dart` ❌ 已刪除

**保留**:
- `lib/l10n/app_localizations_zh_hant.dart` ✅ 繁體中文實現

---

### ✅ 3. 更新 app_localizations.dart

**修正前**:
```dart
import 'app_localizations_zh.dart';  // ❌ 簡體中文

// Lookup logic
case 'zh':
  return AppLocalizationsZh();  // ❌ 簡體中文
```

**修正後**:
```dart
import 'app_localizations_zh_hant.dart';  // ✅ 繁體中文

// Lookup logic
// PARITY: reef-b-app only has Traditional Chinese (values-zh-rTW), no Simplified Chinese
// Removed: case 'zh': return AppLocalizationsZh(); - Simplified Chinese
// Traditional Chinese is handled above with scriptCode 'Hant'
```

---

### ✅ 4. 更新 supportedLocales

**已確認**:
```dart
static const List<Locale> supportedLocales = <Locale>[
  // ...
  // PARITY: reef-b-app only has Traditional Chinese (values-zh-rTW), no Simplified Chinese
  // Removed: Locale('zh') - Simplified Chinese
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // Traditional Chinese ✅
];
```

---

### ✅ 5. 更新 localeResolutionCallback

**已確認**:
```dart
// Simplified Chinese (zh_CN, zh) - fallback to Traditional Chinese
// PARITY: reef-b-app only has Traditional Chinese, so we use it as fallback
for (final supportedLocale in supportedLocales) {
  if (supportedLocale.languageCode == 'zh' &&
      supportedLocale.scriptCode == 'Hant') {
    return supportedLocale;  // ✅ 簡體中文 fallback 到繁體中文
  }
}
```

---

## 當前狀態

### ✅ 已移除

1. ❌ `intl_zh.arb` - 簡體中文 ARB 文件
2. ❌ `app_localizations_zh.dart` - 簡體中文實現文件
3. ❌ `lookupAppLocalizations` 中的 `case 'zh': return AppLocalizationsZh();`
4. ❌ `supportedLocales` 中的 `Locale('zh')`

### ✅ 已保留（對照 reef-b-app）

1. ✅ `intl_zh_Hant.arb` - 繁體中文 ARB 文件（對照 `values-zh-rTW/strings.xml`）
2. ✅ `app_localizations_zh_hant.dart` - 繁體中文實現文件
3. ✅ `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')` - 繁體中文 Locale

---

## 語言支持列表

### ✅ 支持的語言（13 種，與 reef-b-app 一致）

| 語言 | Locale | ARB 文件 | 對照 reef-b-app |
|------|--------|---------|----------------|
| 阿拉伯語 | `Locale('ar')` | `intl_ar.arb` | `values-ar/strings.xml` ✅ |
| 德語 | `Locale('de')` | `intl_de.arb` | `values-de/strings.xml` ✅ |
| 英文 | `Locale('en')` | `intl_en.arb` | `values/strings.xml` ✅ |
| 西班牙語 | `Locale('es')` | `intl_es.arb` | `values-es/strings.xml` ✅ |
| 法語 | `Locale('fr')` | `intl_fr.arb` | `values-fr/strings.xml` ✅ |
| 印尼語 | `Locale('id')` | `intl_id.arb` | `values-in/strings.xml` ✅ |
| 日語 | `Locale('ja')` | `intl_ja.arb` | `values-ja/strings.xml` ✅ |
| 韓語 | `Locale('ko')` | `intl_ko.arb` | `values-ko/strings.xml` ✅ |
| 葡萄牙語 | `Locale('pt')` | `intl_pt.arb` | `values-pt/strings.xml` ✅ |
| 俄語 | `Locale('ru')` | `intl_ru.arb` | `values-ru/strings.xml` ✅ |
| 泰語 | `Locale('th')` | `intl_th.arb` | `values-th/strings.xml` ✅ |
| 越南語 | `Locale('vi')` | `intl_vi.arb` | `values-vi/strings.xml` ✅ |
| 繁體中文 | `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')` | `intl_zh_Hant.arb` | `values-zh-rTW/strings.xml` ✅ |

### ❌ 已移除

- ❌ 簡體中文（`Locale('zh')`）- reef-b-app 沒有，已移除

---

## 結論

✅ **所有簡體中文相關內容已移除**

- ❌ 不再有簡體中文 ARB 文件
- ❌ 不再有簡體中文實現文件
- ❌ 不再有簡體中文 Locale
- ✅ 只保留繁體中文（對照 reef-b-app 的 `values-zh-rTW/strings.xml`）
- ✅ 簡體中文系統語言會 fallback 到繁體中文

**狀態**: ✅ **已完成，符合規則**

