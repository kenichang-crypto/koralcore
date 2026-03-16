# 多語言資源對照與導入計畫

## 當前狀態

### ✅ koralcore 已實現多語言

1. **架構**：
   - ✅ 使用 Flutter 標準的 `l10n` 系統（ARB 文件）
   - ✅ 已在 `main.dart` 中正確配置 `localizationsDelegates` 和 `supportedLocales`
   - ✅ UI 層正確使用 `AppLocalizations.of(context)`

2. **支持語言**：
   - ✅ 支持 14 種語言：ar, de, en, es, fr, id, ja, ko, pt, ru, th, vi, zh, zh_Hant
   - ✅ 與 reef-b-app 支持相同的語言（除了 `in` vs `id`，但實際相同）

3. **文件結構**：
   ```
   lib/l10n/
   ├── intl_en.arb          # 英文模板
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
   ├── intl_zh_Hant.arb     # 繁體中文
   └── app_localizations.dart  # 生成的代碼
   ```

---

## reef-b-app 多語言資源

### 文件位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/
├── values/strings.xml          # 英文（默認）
├── values-ar/strings.xml       # 阿拉伯語
├── values-de/strings.xml       # 德語
├── values-es/strings.xml       # 西班牙語
├── values-fr/strings.xml       # 法語
├── values-in/strings.xml       # 印尼語
├── values-ja/strings.xml       # 日語
├── values-ko/strings.xml       # 韓語
├── values-pt/strings.xml       # 葡萄牙語
├── values-ru/strings.xml       # 俄語
├── values-th/strings.xml       # 泰語
├── values-vi/strings.xml       # 越南語
└── values-zh-rTW/strings.xml   # 繁體中文
```

### 資源數量
- **約 400+ 個字符串**（從 strings.xml 可見）
- 包括：權限相關、通用、LED、Dosing、設備管理等

---

## 架構對比

### reef-b-app（Android）
```
res/values-xx/strings.xml
  ↓
Android Resources API
  ↓
getString(R.string.app_name)
```

### koralcore（Flutter）
```
lib/l10n/intl_xx.arb
  ↓
Flutter l10n Generator
  ↓
AppLocalizations.of(context).appTitle
```

### 架構評估

| 項目 | reef-b-app | koralcore | 評估 |
|------|-----------|-----------|------|
| **格式** | XML strings.xml | ARB JSON | ✅ 不同但等效 |
| **生成方式** | Android 編譯時 | Flutter gen-l10n | ✅ 標準流程 |
| **使用方式** | `getString()` | `AppLocalizations.of()` | ✅ 正確 |
| **配置** | AndroidManifest.xml | main.dart | ✅ 正確 |
| **架構層級** | Platform 層 | UI 層 | ✅ 正確 |

**結論**：✅ **架構正確**，koralcore 使用 Flutter 標準的多語言系統，符合最佳實踐。

---

## 內容對照檢查

### 需要檢查的項目

1. **字符串數量**：
   - reef-b-app: 約 400+ 個字符串
   - koralcore: 約 100+ 個字符串（從 intl_en.arb 可見）
   - ⚠️ **可能有缺失**

2. **字符串對應**：
   - 需要檢查 reef-b-app 的字符串是否都在 koralcore 中
   - 需要檢查翻譯是否正確

3. **新功能字符串**：
   - koralcore 可能有一些新功能的字符串（如 BLE onboarding）
   - reef-b-app 可能有一些舊功能的字符串（如某些已移除的功能）

---

## 導入建議

### 方案 1: 手動對照導入（推薦）

#### 優點
- ✅ 可以確保翻譯質量
- ✅ 可以過濾不需要的字符串
- ✅ 可以添加新功能的翻譯

#### 步驟

1. **提取 reef-b-app 的字符串**：
   ```bash
   # 讀取所有 strings.xml 文件
   cat reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml
   cat reef-b-app/android/ReefB_Android/app/src/main/res/values-zh-rTW/strings.xml
   # ... 其他語言
   ```

2. **對照 koralcore 的 ARB 文件**：
   - 檢查哪些字符串在 reef-b-app 中但不在 koralcore 中
   - 檢查哪些字符串在 koralcore 中但不在 reef-b-app 中

3. **更新 ARB 文件**：
   - 添加缺失的字符串到 `intl_en.arb`
   - 添加對應的翻譯到其他語言的 ARB 文件

4. **重新生成**：
   ```bash
   flutter gen-l10n
   ```

---

### 方案 2: 自動轉換工具（可選）

#### 優點
- ✅ 快速批量導入
- ✅ 減少手動工作

#### 缺點
- ❌ 需要編寫轉換腳本
- ❌ 可能需要手動調整格式

#### 轉換腳本示例
```python
# xml_to_arb.py (示例)
import xml.etree.ElementTree as ET
import json

def convert_xml_to_arb(xml_file, arb_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    arb_data = {"@@locale": "en"}
    
    for string in root.findall('string'):
        name = string.get('name')
        value = string.text or ""
        # 轉換為 ARB 格式
        arb_data[name] = value
    
    with open(arb_file, 'w', encoding='utf-8') as f:
        json.dump(arb_data, f, ensure_ascii=False, indent=2)
```

---

## 實施計畫

### Phase 1: 檢查對照（優先）

1. **提取 reef-b-app 字符串列表**：
   - 讀取所有 `values-xx/strings.xml` 文件
   - 列出所有字符串 key

2. **對照 koralcore ARB 文件**：
   - 檢查哪些字符串缺失
   - 檢查哪些字符串需要更新

3. **生成對照報告**：
   - 列出缺失的字符串
   - 列出需要更新的字符串

### Phase 2: 導入翻譯（按需）

1. **優先導入常用字符串**：
   - 通用（confirm, cancel, save, edit 等）
   - LED 相關
   - Dosing 相關
   - 設備管理相關

2. **導入其他語言翻譯**：
   - 從 reef-b-app 的 `values-xx/strings.xml` 提取翻譯
   - 更新對應的 ARB 文件

3. **驗證翻譯**：
   - 檢查翻譯是否正確
   - 檢查格式是否正確

### Phase 3: 測試（必須）

1. **測試多語言切換**：
   - 切換不同語言
   - 檢查 UI 是否正確顯示

2. **測試缺失翻譯**：
   - 檢查是否有未翻譯的字符串
   - 檢查是否有格式錯誤

---

## 架構正確性確認

### ✅ 架構正確

1. **分層架構**：
   - ✅ 多語言資源在 `lib/l10n/`（資源層）
   - ✅ UI 層使用 `AppLocalizations.of(context)`（正確的依賴方向）
   - ✅ 沒有跨越 Domain/Application 層

2. **Flutter 標準**：
   - ✅ 使用 `flutter gen-l10n` 生成代碼
   - ✅ 使用 ARB 文件格式
   - ✅ 符合 Flutter 最佳實踐

3. **配置正確**：
   - ✅ `main.dart` 中配置了 `localizationsDelegates`
   - ✅ `main.dart` 中配置了 `supportedLocales`
   - ✅ UI 中正確使用 `AppLocalizations.of(context)`

---

## 結論

### ✅ 架構正確
- koralcore 使用 Flutter 標準的 l10n 系統
- 架構符合 Clean Architecture 原則
- 配置和使用方式正確

### ⚠️ 內容可能需要補充
- reef-b-app 有約 400+ 個字符串
- koralcore 目前約 100+ 個字符串
- 可能需要導入缺失的翻譯內容

### 📋 建議
1. **保持當前架構**：不需要修改架構
2. **按需導入翻譯**：如果發現 UI 中缺少某些翻譯，再導入
3. **優先導入常用字符串**：先導入最常用的字符串

---

## 下一步行動

1. **檢查對照**：列出 reef-b-app 和 koralcore 的字符串對照
2. **識別缺失**：找出哪些字符串在 reef-b-app 中但不在 koralcore 中
3. **按需導入**：根據實際需要導入翻譯內容

