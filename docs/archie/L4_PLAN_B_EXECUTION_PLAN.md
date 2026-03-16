# L4 方案 B：完整合規 - 執行計劃與進度

**專案**: koralcore  
**開始日期**: 2026-01-03  
**預計工作量**: 10 小時  
**目標評分**: 71% → 92%+

---

## 📋 任務總覽

| 任務 | 預計時間 | 狀態 | 評分影響 |
|------|---------|------|---------|
| **1. 處理 92 處 TODO 字串** | 2 小時 | ⏳ 進行中 | +7% |
| **2. 建立完整 ARB ↔ Android 對照表** | 3 小時 | ⏳ 準備中 | +15% |
| **3. 補充 BLE 錯誤字串** | 1 小時 | ⏳ 待開始 | L4-3 評分 |
| **4. 驗證顯示時機一致性** | 4 小時 | ⏳ 待開始 | L4-2 評分 |
| **5. 產出最終報告** | - | ⏳ 待開始 | - |

---

## 1️⃣ 處理 92 處 TODO 字串 (2 小時)

### 1.1 TODO 字串統計

| 模組 | TODO 數量 | 優先級 |
|------|----------|--------|
| **Dosing** | 57 處 | P1 |
| **LED** | 30 處 | P1 |
| **Device** | 1 處 | P2 |
| **Sink** | 2 處 | P2 |
| **Bluetooth** | 2 處 | P2 |

### 1.2 Android strings.xml 字串查找

#### 已找到的字串對照 (前 20 個)

| TODO Key | Android strings.xml | English Value | 繁中 Value |
|----------|---------------------|---------------|-----------|
| `@string/cancel` | ✅ Line 18 | Cancel | 取消 |
| `@string/next` | ✅ Line 25 | Next | 下一步 |
| `@string/complete` | ✅ Line 21 | Done | 完成 |
| `@string/save` | ✅ Line 22 | Save | 儲存 |
| `@string/edit` | ✅ Line 23 | Edit | 編輯 |
| `@string/drop_volume` | ✅ Line 100 | Dosing Volume (ml) | 滴液量 (ml) |
| `@string/drop_type` | ✅ Line 76 | Schedule Type | 排程種類 |
| `@string/drop_times` | 🔍 需查找 | - | - |
| `@string/drop_start_time` | 🔍 需查找 | - | - |
| `@string/drop_end_time` | 🔍 需查找 | - | - |
| `@string/drop_head_rotating_speed` | ✅ Line 96-98 | Low/Medium/High Speed | 低/中/高 速度 |
| `@string/adjust_description` | 🔍 需查找 | - | - |
| `@string/adjust_step` | 🔍 需查找 | - | - |
| `@string/adjust_volume_hint` | 🔍 需查找 | - | - |
| `@string/complete_adjust` | 🔍 需查找 | - | - |
| `@string/adjusting` | 🔍 需查找 | - | - |
| `@string/device_is_not_connect` | ✅ Line 43 | Device not connected | 裝置未連線 |
| `@string/record_pause` | 🔍 需查找 | - | - |
| `@string/continue_record` | 🔍 需查找 | - | - |
| `@string/led_scene_add` | 🔍 需查找 | - | - |

### 1.3 執行步驟

#### Step 1.1: 從 Android strings.xml 提取所有字串 (15 分鐘)

**任務**:
- 完整掃描 Android strings.xml (375 個字串)
- 產出完整字串清單 (`docs/ANDROID_STRINGS_COMPLETE_LIST.md`)
- 建立 Key → Value (EN/ZH) 對照表

**腳本**:
```bash
#!/bin/bash
# 完整提取 Android strings.xml

ANDROID_STRINGS="/Users/Kaylen/Documents/GitHub/reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml"

# 提取所有字串
grep '<string name=' "$ANDROID_STRINGS" | while read line; do
  name=$(echo "$line" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
  value=$(echo "$line" | sed -n 's/.*>\(.*\)<\/string>/\1/p')
  echo "$name|$value"
done > android_strings_en.txt
```

---

#### Step 1.2: 對照 TODO 字串並找出對應值 (30 分鐘)

**任務**:
- 逐一對照 92 個 TODO 字串
- 在 Android strings.xml 找出對應值
- 標註找到/未找到的字串

**產出**: `docs/TODO_STRINGS_MAPPING.md`

**格式**:
```markdown
| TODO Key | Found | Android Value (EN) | Android Value (ZH) | File:Line |
|----------|-------|-------------------|-------------------|-----------|
| `@string/cancel` | ✅ | Cancel | 取消 | pump_head_calibration_page.dart:167 |
| `@string/next` | ✅ | Next | 下一步 | pump_head_calibration_page.dart:183 |
| `@string/drop_start_time` | ❌ | - | - | pump_head_record_time_setting_page.dart:65 |
```

---

#### Step 1.3: 補充到 Flutter ARB 檔案 (45 分鐘)

**任務**:
- 將找到的字串補充到 `intl_en.arb` 和 `intl_zh_Hant.arb`
- 為每個字串添加適當的 key 名稱
- 執行 `flutter gen-l10n`

**範例**:
```json
// intl_en.arb
{
  "dosingStartTime": "Start Time",
  "@dosingStartTime": {
    "description": "Dosing start time label",
    "androidSource": "@string/drop_start_time"
  },
  "dosingEndTime": "End Time",
  "@dosingEndTime": {
    "description": "Dosing end time label",
    "androidSource": "@string/drop_end_time"
  }
}
```

---

#### Step 1.4: 更新 Flutter 頁面移除 TODO (30 分鐘)

**任務**:
- 逐一更新 92 處 TODO 字串
- 替換為 `l10n.xxxxx`
- 驗證編譯通過

**範例**:
```dart
// BEFORE
Text('TODO(android @string/cancel)')

// AFTER
Text(l10n.actionCancel)  // 或 l10n.generalCancel
```

---

### 1.4 預期成果

| 指標 | 執行前 | 執行後 | 改善 |
|------|--------|--------|------|
| **TODO 字串** | 92 處 | 0 處 | -92 |
| **ARB 字串數** | 605 個 | ~650 個 | +45 |
| **Parity 頁面字串完整度** | 85% | **92%** | +7% |

---

## 2️⃣ 建立完整 ARB ↔ Android 對照表 (3 小時)

### 2.1 任務說明

**目標**: 為所有 605 個 Flutter ARB 字串建立 Android 來源追溯

**挑戰**:
- Flutter 有 605 個字串
- Android 只有 375 個字串
- 需要識別 Flutter 新增的 230 個字串

### 2.2 執行步驟

#### Step 2.1: 自動對照已知字串 (1 小時)

**任務**:
- 使用腳本自動比對相似的 key
- 比對 value 文字相似度
- 產出初步對照表

**腳本邏輯**:
```python
# 偽代碼
for flutter_key, flutter_value in flutter_arb.items():
    # 1. 嘗試直接 key 對照
    if flutter_key in android_keys:
        match = "✅ Direct Match"
    
    # 2. 嘗試 value 文字比對 (fuzzy match)
    elif similar_value_found(flutter_value, android_values):
        match = "⚠️ Value Match (需人工確認)"
    
    # 3. 無對照
    else:
        match = "❌ No Match (Flutter 新增?)"
```

---

#### Step 2.2: 人工驗證與分類 (1.5 小時)

**任務**:
- 檢查 "Value Match" 的字串（需人工確認）
- 識別 Flutter 新增的字串
- 分類 Flutter 新增字串的原因

**Flutter 新增字串分類**:
1. **合理新增**: Flutter UI 框架需要（如 "Loading...", "Retry"）
2. **需確認**: Android 可能有但 key 名不同
3. **違規新增**: Flutter 自創文案（需移除）

---

#### Step 2.3: 產出完整對照表 (30 分鐘)

**產出**: `docs/FLUTTER_ARB_ANDROID_COMPLETE_MAPPING.md`

**格式**:
```markdown
| Flutter ARB Key | Flutter Value (EN) | Android Key | Android Value | Match Status |
|----------------|-------------------|-------------|---------------|--------------|
| `appTitle` | KoralCore | `app_name` | ReefB | ⚠️ Value Different |
| `tabHome` | Home | `home` | Home | ✅ Matched |
| `homeStatusConnected` | Connected to {device} | ❌ | - | ❌ Flutter New |
| `bleDisconnectedWarning` | Connect via Bluetooth... | `device_is_not_connect` | Device not connected | ⚠️ Semantic Match |
```

---

### 2.3 預期成果

| 指標 | 數量 | 百分比 |
|------|------|--------|
| **✅ 完全匹配** | ~300 個 | 50% |
| **⚠️ 需確認** | ~100 個 | 16% |
| **❌ Flutter 新增** | ~205 個 | 34% |

---

## 3️⃣ 補充 BLE 錯誤字串 (1 小時)

### 3.1 Android BLE 錯誤字串調查

**任務**: 在 Android strings.xml 找出所有 BLE 相關錯誤字串

**預期字串**:
- `@string/ble_error` / `@string/toast_connect_failed`
- `@string/ble_timeout`
- `@string/ble_not_supported`
- `@string/ble_busy`
- `@string/toast_disconnect`

### 3.2 補充到 Flutter ARB

**範例**:
```json
{
  "bleErrorConnectionFailed": "Connection failed, please try again.",
  "@bleErrorConnectionFailed": {
    "description": "BLE connection failed error message",
    "androidSource": "@string/toast_connect_failed"
  },
  "bleErrorDisconnected": "Device disconnected",
  "@bleErrorDisconnected": {
    "description": "BLE device disconnected message",
    "androidSource": "@string/toast_disconnect"
  }
}
```

### 3.3 預期成果

| 指標 | 執行前 | 執行後 |
|------|--------|--------|
| **BLE 錯誤字串** | 0 個 | ~10 個 |
| **L4-3 評分** | 未評分 | **70%+** |

---

## 4️⃣ 驗證顯示時機一致性 (4 小時)

### 4.1 驗證範圍

**需驗證的頁面** (優先 Parity 頁面):
1. Dosing 模組 (10 個頁面)
2. LED 模組 (8 個頁面)
3. Device/Sink/Bluetooth 模組 (5 個頁面)

### 4.2 驗證項目

#### 4.2.1 標題 (Title) 顯示時機

**檢查項目**:
- Android Toolbar title 顯示條件
- Flutter AppBar title 顯示條件
- 是否完全一致？

**範例**:
```
Android: toolbar_two_action.xml
- toolbar_title visibility="gone" (預設隱藏)
- Activity.kt 中動態設定 visibility 和 text

Flutter: _ToolbarTwoAction
- title 固定顯示
- ❌ 不一致 → 需修正
```

---

#### 4.2.2 Button 文案顯示時機

**檢查項目**:
- Android Button text 變化條件
- Flutter Button text 變化條件
- 狀態一致性

**範例**:
```
Android: LED Record Page
- btn_play 根據 isRecording 狀態變化
  - true: "暫停記錄" (@string/record_pause)
  - false: "繼續記錄" (@string/continue_record)

Flutter: led_record_page.dart
- 目前固定顯示 "Play"
- ❌ 不一致 → 需修正
```

---

#### 4.2.3 Empty State 顯示時機

**檢查項目**:
- Android Empty View 顯示條件
- Flutter EmptyStateWidget 顯示條件
- 文字內容一致性

**範例**:
```
Android: RecyclerView + Empty View
- 當 list.isEmpty() → show Empty View
- Empty View text: @string/no_records

Flutter: ListView.builder + EmptyStateWidget
- 當 items.isEmpty → show EmptyStateWidget
- Text: l10n.noRecords
- ✅ 一致
```

---

### 4.3 執行計劃

| 步驟 | 任務 | 時間 |
|------|------|------|
| **4.1** | 列出所有需驗證的文字顯示點 | 30 分鐘 |
| **4.2** | 逐頁比對 Android 和 Flutter | 2.5 小時 |
| **4.3** | 標註不一致處並產出報告 | 1 小時 |

### 4.4 預期成果

| 指標 | 數量 |
|------|------|
| **驗證頁面** | 23 個 |
| **驗證文字點** | ~150 處 |
| **發現不一致** | ~20 處 (估計) |
| **L4-2 評分** | **80%+** |

---

## 5️⃣ 產出最終報告

### 5.1 報告內容

**產出**: `docs/L4_STRING_FINAL_REPORT.md`

**包含**:
1. 執行摘要
2. L4-1/L4-2/L4-3/L4-4 最終評分
3. 92 處 TODO 字串處理結果
4. Flutter ARB ↔ Android 完整對照表
5. BLE 錯誤字串補充清單
6. 顯示時機驗證報告
7. 剩餘問題和建議

---

## 📊 預期最終結果

### 評分提升

| L4 規則 | 執行前 | 執行後 | 提升 |
|---------|--------|--------|------|
| **L4-1 字串來源** | 85% | **95%** | +10% |
| **L4-2 顯示時機** | 未評分 | **80%** | +80% |
| **L4-3 錯誤字串** | 未評分 | **70%** | +70% |
| **L4-4 來源追溯** | 57.5% | **95%** | +37.5% |

### 整體評分計算

```
L4 = (L4-1 × 30% + L4-2 × 25% + L4-3 × 20% + L4-4 × 25%)
   = (95% × 0.3 + 80% × 0.25 + 70% × 0.2 + 95% × 0.25)
   = 28.5% + 20% + 14% + 23.75%
   = 86.25%
```

**執行前**: 71%  
**執行後**: **86%~92%**  
**評分提升**: **+15~21%** 🎉

---

## ⚠️ 重要提示

### 工作量說明

**方案 B 是一個龐大的工程**:
- 需要手動比對 605 個 Flutter 字串
- 需要逐頁驗證 23 個頁面的顯示時機
- 需要處理 92 處 TODO 字串
- **實際工作量可能超過 10 小時**

### 建議執行方式

#### 選項 A: 分階段執行 ✅ (推薦)

**階段 1** (2 小時): 處理 92 處 TODO 字串  
→ 立即提升 7%，達到 78%

**階段 2** (2 小時): 補充高頻字串 + BLE 錯誤  
→ 再提升 5%，達到 83%

**階段 3** (4 小時): 建立完整對照表  
→ 再提升 5%，達到 88%

**階段 4** (2 小時): 驗證顯示時機（重點頁面）  
→ 最終達到 92%+

---

#### 選項 B: 一次完成 ⏰ (10 小時+)

**優點**: 一次性達到 90%+ 評分  
**缺點**: 工作量大，需要長時間專注

---

#### 選項 C: 自動化優先 🤖 (3 小時 + 後續)

**階段 1** (3 小時): 建立自動化工具  
- 自動比對 Flutter ↔ Android 字串
- 自動生成對照表
- 自動檢測 TODO 字串

**階段 2**: 使用工具加速後續工作

---

## ✅ 下一步行動

### 立即可執行 (30 分鐘)

1. ✅ 執行 Android strings.xml 完整提取腳本
2. ✅ 產出 TODO 字串完整清單
3. ✅ 開始處理前 10 個 TODO 字串（示範）

### 需決策

**請選擇執行方式**:
- [ ] 選項 A: 分階段執行 (推薦)
- [ ] 選項 B: 一次完成 (10 小時+)
- [ ] 選項 C: 自動化優先
- [ ] 暫停，先審核其他層級

---

**計劃建立日期**: 2026-01-03  
**預計開始時間**: 待決策  
**預計完成時間**: 待決策

