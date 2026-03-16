# koralcore 多語言系統說明

## 概述

koralcore 使用 **Flutter 標準的 l10n（本地化）系統**，基於 **ARB（Application Resource Bundle）** 格式的 JSON 文件來管理多語言字符串。

---

## 1. 預設語言

### 預設語言：**英文（English）**

**原因**：
- `supportedLocales` 列表中，`Locale('en')` 是第一個（索引 0）
- `localeResolutionCallback` 的 fallback 邏輯：
  ```dart
  // Fallback to first supported locale (usually 'en')
  return supportedLocales.first;
  ```
- 當系統語言無法匹配任何支持的語言時，自動使用英文

**驗證**：
```dart
static const List<Locale> supportedLocales = <Locale>[
  Locale('ar'),      // 阿拉伯語
  Locale('de'),      // 德語
  Locale('en'),      // 英文 ← 預設語言（第一個）
  Locale('es'),      // 西班牙語
  // ...
];
```

---

## 2. 支持的語言種類

### 總共支持 **14 種語言**

| 語言代碼 | 語言名稱 | ARB 文件 | 對應 reef-b-app |
|---------|---------|---------|----------------|
| `ar` | 阿拉伯語 | `intl_ar.arb` | `values-ar/strings.xml` |
| `de` | 德語 | `intl_de.arb` | `values-de/strings.xml` |
| `en` | 英文（預設） | `intl_en.arb` | `values/strings.xml` |
| `es` | 西班牙語 | `intl_es.arb` | `values-es/strings.xml` |
| `fr` | 法語 | `intl_fr.arb` | `values-fr/strings.xml` |
| `id` | 印尼語 | `intl_id.arb` | `values-in/strings.xml` |
| `ja` | 日語 | `intl_ja.arb` | `values-ja/strings.xml` |
| `ko` | 韓語 | `intl_ko.arb` | `values-ko/strings.xml` |
| `pt` | 葡萄牙語 | `intl_pt.arb` | `values-pt/strings.xml` |
| `ru` | 俄語 | `intl_ru.arb` | `values-ru/strings.xml` |
| `th` | 泰語 | `intl_th.arb` | `values-th/strings.xml` |
| `vi` | 越南語 | `intl_vi.arb` | `values-vi/strings.xml` |
| `zh` | 簡體中文 | `intl_zh.arb` | `values-zh/strings.xml` |
| `zh_Hant` | 繁體中文 | `intl_zh_Hant.arb` | `values-zh-rTW/strings.xml` |

---

## 3. 資料來源

### 3.1 ARB 文件位置

```
lib/l10n/
├── intl_en.arb          # 英文（模板文件）
├── intl_ar.arb          # 阿拉伯語
├── intl_de.arb          # 德語
├── intl_es.arb          # 西班牙語
├── intl_fr.arb          # 法語
├── intl_id.arb          # 印尼語
├── intl_ja.arb          # 日語
├── intl_ko.arb          # 韓語
├── intl_pt.arb          # 葡萄牙語
├── intl_ru.arb          # 俄語
├── intl_th.arb          # 泰語
├── intl_vi.arb          # 越南語
├── intl_zh.arb          # 簡體中文
└── intl_zh_Hant.arb     # 繁體中文
```

### 3.2 ARB 文件格式

**範例：`intl_en.arb`**
```json
{
  "@@locale": "en",
  "appTitle": "KoralCore",
  "tabHome": "Home",
  "tabBluetooth": "Bluetooth",
  "deviceHeader": "Devices",
  "deviceDeleteConfirmMessage": "Delete the selected device?",
  "@deviceDeleteConfirmMessage": {
    "description": "Confirmation message for device deletion"
  },
  "homeStatusConnected": "Connected to {device}",
  "@homeStatusConnected": {
    "placeholders": {
      "device": {
        "type": "String"
      }
    }
  }
}
```

**範例：`intl_zh_Hant.arb`**
```json
{
  "@@locale": "zh_Hant",
  "appTitle": "KoralCore",
  "tabHome": "首頁",
  "tabBluetooth": "藍芽",
  "deviceHeader": "設備",
  "deviceDeleteConfirmMessage": "是否刪除所選設備?",
  "homeStatusConnected": "已連線至 {device}",
  "@homeStatusConnected": {
    "placeholders": {
      "device": {
        "type": "String"
      }
    }
  }
}
```

### 3.3 資料來源對照

| koralcore | reef-b-app |
|-----------|-----------|
| `intl_en.arb` | `values/strings.xml` |
| `intl_zh_Hant.arb` | `values-zh-rTW/strings.xml` |
| `intl_ja.arb` | `values-ja/strings.xml` |
| `intl_ko.arb` | `values-ko/strings.xml` |
| ... | ... |

**對照規則**：
- ✅ 所有字符串鍵（key）必須 100% 對照 reef-b-app
- ✅ 所有翻譯內容必須 100% 對照 reef-b-app
- ✅ 使用相同的多語言系統（Flutter l10n vs Android Resource System）

---

## 4. 多語言系統的運作方式

### 4.1 配置（`main.dart`）

```dart
MaterialApp(
  // 1. 設置本地化委託
  localizationsDelegates: const [
    AppLocalizations.delegate,              // 應用自定義本地化
    GlobalMaterialLocalizations.delegate,    // Material 組件本地化
    GlobalWidgetsLocalizations.delegate,     // Flutter 基礎組件本地化
    GlobalCupertinoLocalizations.delegate,  // iOS 風格組件本地化
  ],
  
  // 2. 設置支持的語言列表
  supportedLocales: AppLocalizations.supportedLocales,
  
  // 3. 設置語言解析回調（自動匹配系統語言）
  localeResolutionCallback: (locale, supportedLocales) {
    // 自動匹配系統語言到支持的語言
    // 處理中文變體（zh_TW → zh_Hant）
    // Fallback 到英文（en）
  },
)
```

### 4.2 語言匹配邏輯

**匹配順序**：
1. **精確匹配**：語言碼 + 國家碼 + 腳本碼
   - 例如：`zh_TW` → `zh_Hant`
2. **中文變體特殊處理**：
   - `zh_TW` / `zh_HK` / `zh_Hant` → `zh_Hant`（繁體中文）
   - `zh_CN` / `zh` → `zh`（簡體中文）
3. **語言碼匹配**：只匹配語言碼
   - 例如：`ja_JP` → `ja`（日語）
4. **Fallback**：如果都不匹配，使用英文（`en`）

**範例**：
```
系統語言：繁體中文（台灣）zh_TW
  ↓
匹配邏輯：
  1. 精確匹配：zh_TW → 未找到
  2. 中文變體：zh_TW → zh_Hant ✅ 匹配成功
  ↓
使用：intl_zh_Hant.arb
```

### 4.3 在 UI 中使用

**基本用法**：
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 獲取當前語言的本地化字符串
    final l10n = AppLocalizations.of(context);
    
    return Text(l10n.deviceHeader); // 顯示 "設備" 或 "Devices"
  }
}
```

**帶參數的字符串**：
```dart
Text(l10n.homeStatusConnected('LED-001'))
// 顯示："已連線至 LED-001" 或 "Connected to LED-001"
```

**實際範例**（`home_page.dart`）：
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final controller = context.watch<HomeController>();
  
  return Scaffold(
    body: Column(
      children: [
        Text(l10n.tabHome),        // "首頁" 或 "Home"
        Text(l10n.deviceHeader),  // "設備" 或 "Devices"
      ],
    ),
  );
}
```

---

## 5. 生成代碼

### 5.1 配置文件（`l10n.yaml`）

```yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

### 5.2 生成命令

```bash
flutter gen-l10n
```

### 5.3 生成的文件

```
lib/l10n/
├── app_localizations.dart          # 抽象類（定義所有字符串鍵）
├── app_localizations_en.dart       # 英文實現
├── app_localizations_zh_Hant.dart # 繁體中文實現
├── app_localizations_ja.dart      # 日語實現
└── ...                             # 其他語言實現
```

---

## 6. 工作流程

### 6.1 添加新字符串

1. **在 `intl_en.arb` 添加英文版本**：
   ```json
   {
     "newStringKey": "New String Value",
     "@newStringKey": {
       "description": "Description of this string"
     }
   }
   ```

2. **在所有其他語言的 ARB 文件中添加翻譯**：
   ```json
   // intl_zh_Hant.arb
   {
     "newStringKey": "新字符串值"
   }
   ```

3. **運行生成命令**：
   ```bash
   flutter gen-l10n
   ```

4. **在代碼中使用**：
   ```dart
   final l10n = AppLocalizations.of(context);
   Text(l10n.newStringKey);
   ```

### 6.2 更新翻譯

1. **直接編輯對應語言的 ARB 文件**
2. **運行 `flutter gen-l10n` 重新生成**
3. **重新運行應用**

---

## 7. 系統語言自動切換

### 7.1 工作原理

1. **應用啟動時**：
   - Flutter 讀取系統語言設置
   - 調用 `localeResolutionCallback`
   - 匹配到對應的語言
   - 加載對應的 ARB 文件

2. **運行時**：
   - `AppLocalizations.of(context)` 自動返回當前語言的字符串
   - 無需手動切換語言

### 7.2 測試方法

1. **設置系統語言**：
   ```
   設置 → 系統 → 語言和輸入法 → 語言
   → 選擇目標語言（例如：繁體中文）
   → 重啟應用
   ```

2. **驗證**：
   - 應用應自動顯示對應語言
   - 所有 UI 文字應使用對應語言

---

## 8. 與 reef-b-app 的對照

### 8.1 對照表

| 項目 | reef-b-app | koralcore |
|------|-----------|-----------|
| **格式** | Android XML (`strings.xml`) | Flutter ARB (`intl_*.arb`) |
| **位置** | `res/values-XX/strings.xml` | `lib/l10n/intl_XX.arb` |
| **模板** | `values/strings.xml` (英文) | `intl_en.arb` (英文) |
| **生成** | Android 自動 | `flutter gen-l10n` |
| **使用** | `getString(R.string.key)` | `AppLocalizations.of(context).key` |
| **語言檢測** | Android Resource System | `localeResolutionCallback` |

### 8.2 對照規則

1. **字符串鍵（key）**：必須 100% 對照
2. **翻譯內容**：必須 100% 對照
3. **語言支持**：必須 100% 對照（14 種語言）
4. **預設語言**：都是英文

---

## 9. 總結

### ✅ 預設語言
- **英文（English）** - `Locale('en')`

### ✅ 支持的語言
- **14 種語言**：ar, de, en, es, fr, id, ja, ko, pt, ru, th, vi, zh, zh_Hant

### ✅ 資料來源
- **ARB 文件**：`lib/l10n/intl_*.arb`
- **模板文件**：`intl_en.arb`
- **對照來源**：`reef-b-app` 的 `values-XX/strings.xml`

### ✅ 運作方式
- **自動檢測系統語言**
- **自動匹配支持的語言**
- **自動 fallback 到英文**
- **在 UI 中使用 `AppLocalizations.of(context)`**

### ✅ 生成代碼
- **命令**：`flutter gen-l10n`
- **生成文件**：`app_localizations.dart` 和 `app_localizations_XX.dart`

---

## 10. 注意事項

1. **不要硬編碼字符串**：所有 UI 文字必須使用 `AppLocalizations.of(context)`
2. **保持 ARB 文件同步**：添加新字符串時，必須在所有語言的 ARB 文件中添加
3. **運行生成命令**：修改 ARB 文件後，必須運行 `flutter gen-l10n`
4. **對照 reef-b-app**：所有字符串鍵和翻譯內容必須 100% 對照

