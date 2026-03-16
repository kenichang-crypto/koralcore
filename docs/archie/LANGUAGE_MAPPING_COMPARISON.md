# 多語言系統對照表

## 一、語言對應關係

### reef-b-app 語言資源

| Android 資源目錄 | 語言 | koralcore ARB 文件 | 狀態 |
|-----------------|------|-------------------|------|
| `values/` | 英文 (en) | `intl_en.arb` | ✅ |
| `values-zh-rTW/` | 繁體中文 (zh_Hant) | `intl_zh_Hant.arb` | ✅ |
| `values-ar/` | 阿拉伯語 (ar) | `intl_ar.arb` | ✅ |
| `values-de/` | 德語 (de) | `intl_de.arb` | ✅ |
| `values-es/` | 西班牙語 (es) | `intl_es.arb` | ✅ |
| `values-fr/` | 法語 (fr) | `intl_fr.arb` | ✅ |
| `values-in/` | 印尼語 (id) | `intl_id.arb` | ✅ |
| `values-ja/` | 日語 (ja) | `intl_ja.arb` | ✅ |
| `values-ko/` | 韓語 (ko) | `intl_ko.arb` | ✅ |
| `values-pt/` | 葡萄牙語 (pt) | `intl_pt.arb` | ✅ |
| `values-ru/` | 俄語 (ru) | `intl_ru.arb` | ✅ |
| `values-th/` | 泰語 (th) | `intl_th.arb` | ✅ |
| `values-vi/` | 越南語 (vi) | `intl_vi.arb` | ✅ |

**總計**: 13 種語言

### koralcore 語言資源

| ARB 文件 | 語言 | 對應 reef-b-app | 狀態 |
|---------|------|----------------|------|
| `intl_en.arb` | 英文 | `values/strings.xml` | ✅ |
| `intl_zh_Hant.arb` | 繁體中文 | `values-zh-rTW/strings.xml` | ✅ |
| `intl_ar.arb` | 阿拉伯語 | `values-ar/strings.xml` | ✅ |
| `intl_de.arb` | 德語 | `values-de/strings.xml` | ✅ |
| `intl_es.arb` | 西班牙語 | `values-es/strings.xml` | ✅ |
| `intl_fr.arb` | 法語 | `values-fr/strings.xml` | ✅ |
| `intl_id.arb` | 印尼語 | `values-in/strings.xml` | ✅ |
| `intl_ja.arb` | 日語 | `values-ja/strings.xml` | ✅ |
| `intl_ko.arb` | 韓語 | `values-ko/strings.xml` | ✅ |
| `intl_pt.arb` | 葡萄牙語 | `values-pt/strings.xml` | ✅ |
| `intl_ru.arb` | 俄語 | `values-ru/strings.xml` | ✅ |
| `intl_th.arb` | 泰語 | `values-th/strings.xml` | ✅ |
| `intl_vi.arb` | 越南語 | `values-vi/strings.xml` | ✅ |
| `intl_zh.arb` | 簡體中文 | ❌ 不在 reef-b-app 中 | ⚠️ |

**總計**: 14 種語言（13 種對應 reef-b-app + 1 種簡體中文）

---

## 二、新增字符串對照（LED 場景編輯頁面）

### 需要從 reef-b-app 轉換的字符串

| reef-b-app 字符串 ID | 英文值 | 繁體中文值 | koralcore 字符串 ID | 狀態 |
|---------------------|--------|-----------|-------------------|------|
| `@string/led_scene_icon` | "Scene Icon" | "場景圖示" | `ledSceneIcon` | ✅ |
| `@string/light_uv` | "UV Light" | "UV" | `lightUv` | ✅ |
| `@string/light_purple` | "Purple Light" | "紫光" | `lightPurple` | ✅ |
| `@string/light_blue` | "Blue Light" | "藍光" | `lightBlue` | ✅ |
| `@string/light_royal_blue` | "Royal Blue Light" | "皇家藍光" | `lightRoyalBlue` | ✅ |
| `@string/light_green` | "Green Light" | "綠光" | `lightGreen` | ✅ |
| `@string/light_red` | "Red Light" | "紅光" | `lightRed` | ✅ |
| `@string/light_cold_white` | "Cool White Light" | "冷白光" | `lightColdWhite` | ✅ |
| `@string/light_warm_white` | "Warm White Light" | "暖白光" | `lightWarmWhite` | ✅ |
| `@string/light_moon` | "Moonlight" | "月光" | `lightMoon` | ✅ |
| `@string/toast_name_is_empty` | "Name cannot be empty." | "名稱不得為空" | `toastNameIsEmpty` | ✅ |
| `@string/toast_setting_successful` | "Settings successful." | "設定成功" | `toastSettingSuccessful` | ✅ |
| `@string/toast_scene_name_is_exist` | "Scene name already exists." | "場景名稱重複" | `toastSceneNameIsExist` | ✅ |

---

## 三、檢查所有語言文件的完整性

需要確認所有語言文件都包含這些新增的字符串。

### 檢查方法

1. 檢查每個 ARB 文件是否包含所有新增的字符串
2. 檢查每個 `app_localizations_*.dart` 文件是否實現了所有新增的 getter
3. 確認翻譯內容來自對應的 reef-b-app 語言文件

---

## 四、語言文件對照檢查清單

### 英文 (en)
- ✅ `intl_en.arb` - 已添加所有字符串
- ✅ `app_localizations_en.dart` - 已實現所有 getter

### 繁體中文 (zh_Hant)
- ✅ `intl_zh_Hant.arb` - 已添加所有字符串
- ✅ `app_localizations_zh.dart` - 已實現所有 getter

### 其他語言
需要檢查以下語言文件是否都包含新增的字符串：
- ⚠️ `intl_ar.arb` - 需要檢查
- ⚠️ `intl_de.arb` - 需要檢查
- ⚠️ `intl_es.arb` - 需要檢查
- ⚠️ `intl_fr.arb` - 需要檢查
- ⚠️ `intl_id.arb` - 需要檢查
- ⚠️ `intl_ja.arb` - 需要檢查
- ⚠️ `intl_ko.arb` - 需要檢查
- ⚠️ `intl_pt.arb` - 需要檢查
- ⚠️ `intl_ru.arb` - 需要檢查
- ⚠️ `intl_th.arb` - 需要檢查
- ⚠️ `intl_vi.arb` - 需要檢查

---

## 五、下一步行動

1. **檢查所有語言文件**：確認所有 ARB 文件都包含新增的字符串
2. **從 reef-b-app 轉換翻譯**：對於每個語言，從對應的 `values-XX/strings.xml` 中提取翻譯
3. **更新所有 `app_localizations_*.dart` 文件**：確保所有語言實現都包含新增的 getter

