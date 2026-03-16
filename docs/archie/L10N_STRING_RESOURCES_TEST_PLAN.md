# L10N 字符串資源測試計劃

## 測試目標

驗證 `reef-b-app` 的 `res/values/strings.xml` 中的字符串資源是否正確：
1. 轉換為 `koralcore` 的 `lib/l10n/intl_en.arb`
2. 在頁面中正確使用 `AppLocalizations`

---

## 測試範圍

### 1. 資源文件對照

#### reef-b-app 字符串資源
- **位置**: `reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml`
- **格式**: Android XML 字符串資源
- **結構**: `<string name="key">value</string>`

#### koralcore 本地化資源
- **位置**: `koralcore/lib/l10n/intl_en.arb`
- **格式**: ARB (Application Resource Bundle) JSON
- **結構**: `{"key": "value", "@key": {...}}`

### 2. 各國語言資源

#### reef-b-app 多語言資源
- 檢查是否存在 `values-XX/strings.xml`（如 `values-zh`, `values-ja` 等）

#### koralcore 多語言資源
- 檢查是否存在對應的 `intl_XX.arb` 文件

### 3. 頁面中的使用

#### 檢查項目
- [ ] 頁面是否正確使用 `AppLocalizations.of(context)`
- [ ] 字符串鍵是否與 `intl_en.arb` 中的鍵匹配
- [ ] 是否有硬編碼的字符串（應該使用本地化字符串）

---

## 測試方法

### 方法 1: 文件對照檢查

1. **提取 reef-b-app 的字符串鍵**
   ```bash
   grep -oP 'name="\K[^"]+' reef-b-app/.../strings.xml
   ```

2. **提取 koralcore 的字符串鍵**
   ```bash
   grep -oP '"\K[^"]+(?=":)' koralcore/lib/l10n/intl_en.arb | grep -v '@'
   ```

3. **對比兩者的差異**

### 方法 2: 使用情況檢查

1. **搜索硬編碼字符串**
   ```bash
   grep -rn '"[A-Z][^"]{10,}"' lib/ui/features --include="*.dart"
   ```

2. **檢查 AppLocalizations 使用**
   ```bash
   grep -rn "AppLocalizations.of" lib/ui/features --include="*.dart"
   ```

### 方法 3: 鍵名對照

檢查常見的字符串鍵是否都存在：
- `app_name`
- `action_save`, `action_cancel`, `action_delete`
- `device_*`, `led_*`, `dosing_*`
- `error_*`, `warning_*`

---

## 測試檢查清單

### 1. 資源文件完整性

- [ ] `intl_en.arb` 是否存在且可解析
- [ ] 主要字符串鍵是否存在
- [ ] 字符串值是否正確（無明顯錯誤）

### 2. 多語言支持

- [ ] 檢查是否存在其他語言的 ARB 文件
- [ ] 如果存在，檢查是否與英文版本同步

### 3. 頁面使用情況

#### 主要頁面檢查
- [ ] Home 頁面
- [ ] Bluetooth 頁面
- [ ] Device 頁面
- [ ] LED 主頁
- [ ] Dosing 主頁

#### 檢查內容
- [ ] 所有用戶可見的文字是否使用 `l10n.xxx`
- [ ] 是否有硬編碼的字符串
- [ ] 字符串鍵是否存在於 `intl_en.arb` 中

### 4. 常見字符串鍵

#### 操作相關
- [ ] `actionSave`, `actionCancel`, `actionDelete`, `actionEdit`
- [ ] `actionConfirm`, `actionRetry`, `actionApply`

#### 錯誤和狀態
- [ ] `errorGeneric`, `errorNetwork`, `errorUnknown`
- [ ] `deviceStateConnected`, `deviceStateDisconnected`
- [ ] `bleConnected`, `bleDisconnected`

#### 頁面標題
- [ ] `deviceHeader`, `bluetoothHeader`
- [ ] `ledMainTitle`, `dosingHeader`
- [ ] `sinkManagerTitle`, `warningTitle`

---

## 預期問題類型

### 1. 缺失的字符串鍵
- 頁面中使用了 `l10n.xxx`，但 `intl_en.arb` 中沒有定義

### 2. 硬編碼字符串
- 頁面中直接使用字符串字面量，而非本地化字符串

### 3. 鍵名不一致
- `reef-b-app` 中的鍵名與 `koralcore` 中的鍵名不匹配

### 4. 多語言缺失
- `reef-b-app` 有某種語言，但 `koralcore` 沒有對應的 ARB 文件

---

## 測試步驟

### Step 1: 資源文件檢查
1. 讀取 `reef-b-app/.../values/strings.xml`
2. 提取所有字符串鍵
3. 讀取 `koralcore/lib/l10n/intl_en.arb`
4. 提取所有字符串鍵
5. 對比差異

### Step 2: 頁面使用檢查
1. 選擇幾個代表性頁面
2. 檢查字符串使用情況
3. 記錄硬編碼字符串
4. 記錄缺失的本地化鍵

### Step 3: 常見鍵驗證
1. 列出常見的字符串鍵
2. 檢查它們是否都存在
3. 檢查值是否合理

### Step 4: 多語言檢查
1. 列出 `reef-b-app` 的所有語言
2. 檢查 `koralcore` 是否有對應文件
3. 如果存在，檢查同步情況

---

## 測試結果記錄

### 資源文件對照結果
| reef-b-app 鍵 | koralcore 鍵 | 狀態 | 備註 |
|--------------|-------------|------|------|
| - | - | ⏳ | - |

### 頁面使用檢查結果
| 頁面 | 硬編碼字符串數 | 缺失鍵數 | 狀態 |
|------|--------------|---------|------|
| Home | ⏳ | ⏳ | ⏳ |
| Bluetooth | ⏳ | ⏳ | ⏳ |
| Device | ⏳ | ⏳ | ⏳ |

### 多語言資源
| 語言 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| en | ✅ | ✅ | ⏳ |
| zh | ⏳ | ⏳ | ⏳ |

---

## 下一步行動

1. **執行測試** - 按照測試步驟進行檢查
2. **記錄問題** - 記錄發現的問題
3. **修復問題** - 修復缺失的字符串和硬編碼問題
4. **驗證修復** - 重新測試確認問題已解決

