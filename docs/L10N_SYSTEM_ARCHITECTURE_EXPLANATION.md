# Flutter 本地化系統架構說明

## 為什麼有兩種文件類型？

這**不是兩種語系系統**，而是 **Flutter 本地化系統的標準架構**，包含兩個部分：

### 1. **ARB 文件（源文件）** - `intl_*.arb`

**作用**：
- 這是**開發者編輯的源文件**
- 包含所有語言的翻譯字符串
- 使用 JSON 格式，易於編輯和管理

**文件列表**：
```
lib/l10n/
├── intl_en.arb          # 英文（模板）
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
└── intl_zh_Hant.arb     # 繁體中文
```

**格式範例**：
```json
{
  "@@locale": "zh_Hant",
  "tabHome": "首頁",
  "tabBluetooth": "藍芽",
  "deviceHeader": "裝置"
}
```

---

### 2. **Dart 文件（生成文件）** - `app_localizations_*.dart`

**作用**：
- 這是**Flutter 工具自動生成的代碼文件**
- 從 ARB 文件生成，提供類型安全的字符串訪問
- **不應該手動編輯**（會被覆蓋）

**文件列表**：
```
lib/l10n/
├── app_localizations.dart           # 抽象基類（生成）
├── app_localizations_en.dart        # 英文實現（生成）
├── app_localizations_ar.dart        # 阿拉伯語實現（生成）
├── app_localizations_de.dart        # 德語實現（生成）
├── app_localizations_es.dart        # 西班牙語實現（生成）
├── app_localizations_fr.dart        # 法語實現（生成）
├── app_localizations_id.dart        # 印尼語實現（生成）
├── app_localizations_ja.dart        # 日語實現（生成）
├── app_localizations_ko.dart        # 韓語實現（生成）
├── app_localizations_pt.dart        # 葡萄牙語實現（生成）
├── app_localizations_ru.dart        # 俄語實現（生成）
├── app_localizations_th.dart        # 泰語實現（生成）
└── app_localizations_vi.dart        # 越南語實現（生成）
```

**格式範例**：
```dart
class AppLocalizationsZhHant extends AppLocalizations {
  @override
  String get tabHome => '首頁';
  
  @override
  String get tabBluetooth => '藍芽';
  
  @override
  String get deviceHeader => '裝置';
}
```

---

## 工作流程

### 開發流程

```
1. 編輯 ARB 文件（源文件）
   ↓
   intl_zh_Hant.arb: {"tabHome": "首頁"}
   
2. 運行 Flutter 生成命令
   ↓
   flutter gen-l10n
   
3. 自動生成 Dart 文件
   ↓
   app_localizations_zh_hant.dart: String get tabHome => '首頁';
   
4. 在代碼中使用
   ↓
   AppLocalizations.of(context).tabHome  // 返回 "首頁"
```

---

## 配置

### `l10n.yaml` 配置文件

```yaml
arb-dir: lib/l10n                    # ARB 文件目錄
template-arb-file: intl_en.arb      # 模板文件（英文）
output-localization-file: app_localizations.dart  # 輸出文件名
output-class: AppLocalizations      # 生成的類名
nullable-getter: false              # 是否允許 null
```

### `pubspec.yaml` 配置

```yaml
flutter:
  generate: true  # 啟用自動生成
```

---

## 為什麼需要兩種文件？

### ✅ ARB 文件的優點

1. **易於編輯**：JSON 格式，簡單直觀
2. **版本控制友好**：文本格式，易於比較差異
3. **翻譯工具支持**：許多翻譯工具支持 ARB 格式
4. **與 Android 資源類似**：類似於 `strings.xml`

### ✅ Dart 文件的優點

1. **類型安全**：編譯時檢查，避免拼寫錯誤
2. **IDE 支持**：自動完成、重構支持
3. **性能優化**：編譯時優化，運行時高效
4. **代碼提示**：開發時可以看到所有可用的字符串

---

## 重要注意事項

### ⚠️ 不要手動編輯 Dart 文件

- Dart 文件是**自動生成的**
- 手動編輯會被 `flutter gen-l10n` 覆蓋
- **只編輯 ARB 文件**

### ✅ 正確的工作流程

1. **編輯 ARB 文件**（`intl_*.arb`）
2. **運行生成命令**：`flutter gen-l10n`
3. **使用生成的代碼**：`AppLocalizations.of(context).xxx`

### 🔄 生成命令

```bash
# 自動生成（當 ARB 文件改變時）
flutter gen-l10n

# 或者在運行時自動生成
flutter run  # 會自動檢查並生成
```

---

## 與 reef-b-app 的對照

### reef-b-app（Android）

```
res/values/strings.xml          # 英文
res/values-zh-rTW/strings.xml   # 繁體中文
```

### koralcore（Flutter）

```
lib/l10n/intl_en.arb           # 英文（源文件）
lib/l10n/intl_zh_Hant.arb      # 繁體中文（源文件）
↓ (自動生成)
lib/l10n/app_localizations_en.dart      # 英文（生成文件）
lib/l10n/app_localizations_zh_hant.dart # 繁體中文（生成文件）
```

---

## 總結

**這不是兩種語系系統，而是同一個系統的兩個部分**：

1. **ARB 文件** = 源文件（開發者編輯）
2. **Dart 文件** = 生成文件（Flutter 工具自動生成）

**工作流程**：
- 編輯 ARB → 生成 Dart → 使用 Dart

**對照 reef-b-app**：
- `strings.xml`（Android）↔ `intl_*.arb`（Flutter 源文件）
- Android 直接使用 XML → Flutter 需要生成 Dart 代碼

---

## 常見問題

### Q: 為什麼不能直接使用 ARB 文件？

A: Flutter 需要類型安全的 Dart 代碼，ARB 是 JSON 格式，無法直接使用。需要生成 Dart 類。

### Q: 可以刪除 Dart 文件嗎？

A: 可以，但需要運行 `flutter gen-l10n` 重新生成。建議將 Dart 文件加入 `.gitignore`（但 koralcore 目前保留它們以便追蹤）。

### Q: `.tmp` 文件是什麼？

A: 這些是生成過程中的臨時文件，可以安全刪除。它們會在下次生成時重新創建。

