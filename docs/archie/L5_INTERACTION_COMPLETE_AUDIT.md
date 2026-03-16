# L5｜UI ↔ 功能連結層 - 完整審核報告

**審核日期**: 2026-01-03  
**審核範圍**: 所有 Parity 頁面  
**審核重點**: 可操作 UI、點擊結果、點擊時機一致性

---

## 🚨 重大發現

### 當前狀態：所有 Parity 頁面處於「路徑 B - 完全 Parity 化」

**關鍵問題**：
- 所有 `onPressed` 回調設為 `null`
- 所有 `TextField` 設為 `enabled: false`
- 所有 `Radio`/`Checkbox` 的 `onChanged` 設為 `null`
- **結果**：所有可操作 UI 都被禁用 ❌

---

## L5-1｜可操作 UI 清單審核

### 審核標準

✅ Flutter 必須對齊 Android 所有可操作 UI：
- Button
- List item
- Icon button
- Toggle / Switch

❌ 不得新增
❌ 不得移除

---

### 審核結果：按模組

## 一、Dosing 模組

### 1. DosingMainPage

**Android (`activity_drop_main.xml`)**：

| UI 元素 | 類型 | 位置 | 點擊行為 |
|---------|------|------|---------|
| `btn_ble` | ImageView (Button) | Toolbar | 連線/斷線 BLE |
| Pump Head Card (4個) | CardView (List item) | RecyclerView | 進入 DropHeadMainActivity |
| `btn_play` (4個) | ImageView (Button) | Card內 | 立即執行單次滴液 (0x6E) |

**Flutter (`dosing_main_page.dart`)**：

| UI 元素 | 類型 | 狀態 | L5-1 | L5-2 | L5-3 |
|---------|------|------|------|------|------|
| BLE Button | `_BleButton` | ❌ `onPressed: null` | ✅ 存在 | ❌ 無行為 | N/A |
| Pump Head Card (4個) | `DosingMainPumpHeadCard` | ❌ `onTap: null` | ✅ 存在 | ❌ 無行為 | N/A |
| Play Button (4個) | `InkWell` | ❌ `onTap: null` | ✅ 存在 | ❌ 無行為 | N/A |

**L5 評分**：
- L5-1: ✅ 100% (所有 UI 存在)
- L5-2: ❌ 0% (所有點擊無效)
- L5-3: N/A (無行為可驗證)

---

### 2. DropSettingPage

**Android (`activity_drop_setting.xml`)**：

| UI 元素 | 類型 | 點擊行為 |
|---------|------|---------|
| `btn_back` | ImageView | 返回上一頁 |
| `btn_right` (儲存) | TextView | 儲存設定 + 發送延遲時間 (0x6F) |
| `edt_name` | EditText | 編輯裝置名稱 |
| `btn_position` | MaterialButton | 選擇水槽位置 → SinkPositionActivity |
| `btn_delay_time` | MaterialButton | 選擇延遲時間 → PopupMenu |

**Flutter (`drop_setting_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 | L5-3 |
|---------|------|------|------|------|
| Back Button | ❌ `onPressed: null` | ✅ | ❌ | N/A |
| Save Button | ❌ `onPressed: null` | ✅ | ❌ | N/A |
| Name Field | ❌ `enabled: false` | ✅ | ❌ | N/A |
| Position Button | ❌ `onPressed: null` | ✅ | ❌ | N/A |
| Delay Time Button | ❌ `onPressed: null` | ✅ | ❌ | N/A |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%
- L5-3: N/A

---

### 3. PumpHeadDetailPage

**Android (`activity_drop_head_main.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_menu` | PopupMenu → 編輯 (進入 DropHeadSettingActivity) |
| `btn_record_more` | 進入 DropHeadRecordSettingActivity |
| `btn_adjust_more` | 進入 DropHeadAdjustListActivity |

**Flutter (`pump_head_detail_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| Back Button | ❌ `onPressed: null` | ✅ | ❌ |
| Menu Button | ❌ `onPressed: null` | ✅ | ❌ |
| Record More Button | ❌ `onPressed: null` | ✅ | ❌ |
| Adjust More Button | ❌ `onPressed: null` | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 4. PumpHeadSettingsPage

**Android (`activity_drop_head_setting.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (儲存) | 儲存 + 發送轉速 (0x73) |
| `btn_drop_type` | 選擇滴液種類 → DropTypeActivity |
| `sw_max_drop_per_day_switch` | Toggle 每日最大滴液量 |
| `edt_max_drop_per_day` | 編輯最大滴液量 (條件顯示) |
| `btn_rotating_speed` | 選擇轉速 → PopupMenu |

**Flutter (`pump_head_settings_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| Back Button | ❌ | ✅ | ❌ |
| Save Button | ❌ | ✅ | ❌ |
| Drop Type Button | ❌ | ✅ | ❌ |
| Max Drop Switch | ❌ `onChanged: null` | ✅ | ❌ |
| Max Drop Field | ❌ `enabled: false` | ✅ | ❌ |
| Rotating Speed Button | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 5. PumpHeadRecordSettingPage

**Android (`activity_drop_head_record_setting.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (執行) | 儲存排程 + 發送 BLE (0x6B-0x6E) |
| `btn_record_type` | 選擇排程類型 → PopupMenu |
| `btn_add_time` | 新增時段 → DropHeadRecordTimeSettingActivity |
| RecyclerView Items | 長按刪除時段 |
| `edt_drop_volume` | 編輯滴液量 |
| `btn_rotating_speed` | 選擇轉速 → PopupMenu |
| RadioGroup (4個) | 選擇執行時間類型 |
| CheckBox (7個) | 選擇星期 |

**Flutter (`pump_head_record_setting_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ `onPressed: null` | ✅ | ❌ |
| 所有 Radio | ❌ `onChanged: null` | ✅ | ❌ |
| 所有 Checkbox | ❌ `onChanged: null` | ✅ | ❌ |
| TextField | ❌ `enabled: false` | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 6. PumpHeadRecordTimeSettingPage

**Android (`activity_drop_head_record_time_setting.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (確認) | 儲存時段設定 |
| `btn_start_time` | 選擇開始時間 → PopupMenu |
| `btn_end_time` | 選擇結束時間 → PopupMenu |
| `btn_drop_times` | 選擇滴液次數 → PopupMenu |
| `edt_drop_volume` | 編輯滴液量 |
| `btn_rotating_speed` | 選擇轉速 → PopupMenu |

**Flutter (`pump_head_record_time_setting_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ | ✅ | ❌ |
| TextField | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 7. PumpHeadAdjustListPage

**Android (`activity_drop_head_adjust_list.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (校正) | 進入 DropHeadAdjustActivity |
| RecyclerView Items | 查看校正紀錄詳情 (無導航) |

**Flutter (`pump_head_adjust_list_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| Back Button | ❌ | ✅ | ❌ |
| Adjust Button | ❌ | ✅ | ❌ |
| List Items | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 8. PumpHeadCalibrationPage

**Android (`activity_drop_head_adjust.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_rotating_speed` | 選擇轉速 → PopupMenu |
| `edt_adjust_drop_volume` | 編輯校正滴液量 (步驟2顯示) |
| `btn_next` | 下一步 (步驟1) + 發送 BLE (0x74) |
| `btn_prev` | 取消 (步驟2) |
| `btn_complete` | 完成校正 (步驟2) + 發送 BLE (0x75) |

**Flutter (`pump_head_calibration_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ | ✅ | ❌ |
| TextField | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 9. DropTypePage

**Android (`activity_drop_type.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (確認) | 返回選擇結果 |
| RecyclerView Items | 選擇項目 (RadioButton) |
| Item Long Press | 刪除項目 |
| Edit Button | 編輯名稱 → BottomSheet |
| `fab_add_drop_type` | 新增項目 → BottomSheet |

**Flutter (`drop_type_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ | ✅ | ❌ |
| Radio | ❌ `onChanged: null` | ✅ | ❌ |
| FAB | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

## 二、LED 模組

### 1. LedMainPage (已部分實作)

**Android (`activity_led_main.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| Toolbar Buttons | 功能選單 |
| Scene List Items | 切換場景 + 發送 BLE (0x32/0x33) |

**Flutter (`led_main_page.dart`)**：

⚠️ **此頁面非完全 Parity 模式**，部分功能已實作

**L5 評分**：
- L5-1: ⚠️ 需檢查
- L5-2: ⚠️ 需檢查
- L5-3: ⚠️ 需檢查

---

### 2. LedScenePage

**Android (`activity_led_scene.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` | 功能選單 (新增/編輯/刪除) |
| Scene Items | 拖曳排序 |

**Flutter (`led_scene_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 3. LedSceneAddPage

**Android (`activity_led_scene_add.xml`)**：

| UI 元素 | 點擊行為 |
|---------|---------|
| `btn_back` | 返回 |
| `btn_right` (儲存) | 儲存場景 |
| `edt_scene_name` | 編輯場景名稱 |
| Scene Icon Grid | 選擇場景圖示 |

**Flutter (`led_scene_add_page.dart`)**：

| UI 元素 | 狀態 | L5-1 | L5-2 |
|---------|------|------|------|
| 所有 Button | ❌ | ✅ | ❌ |
| TextField | ❌ | ✅ | ❌ |

**L5 評分**：
- L5-1: ✅ 100%
- L5-2: ❌ 0%

---

### 4-7. LedSceneEditPage, LedSceneDeletePage, LedRecordPage, LedRecordTimeSettingPage, LedRecordSettingPage, LedSettingPage, LedMasterSettingPage

**狀態**: 全部為 Parity 模式，所有互動都禁用

**L5 評分**：
- L5-1: ✅ 100% (UI 元素存在)
- L5-2: ❌ 0% (所有互動無效)
- L5-3: N/A (無行為可驗證)

---

## 三、其他模組

### 1. SinkManagerPage, SinkPositionPage, AddDevicePage

**狀態**: Parity 模式，所有互動都禁用

**L5 評分**: L5-1: ✅, L5-2: ❌, L5-3: N/A

---

## 📊 L5 整體評分

### 按規則統計

| 規則 | 評分 | 說明 |
|------|------|------|
| **L5-1 可操作 UI 清單** | ✅ **100%** | 所有 Android UI 都已在 Flutter 實現 |
| **L5-2 點擊結果一致性** | ❌ **0%** | 所有點擊行為都被禁用 |
| **L5-3 點擊時機一致性** | N/A | 無行為可驗證 |

### 整體 L5 評分

```
L5-1: 100% ✅
L5-2: 0%   ❌
L5-3: N/A  ⚠️

━━━━━━━━━━━━━━━━━━━
  L5 整體: 33% ❌
━━━━━━━━━━━━━━━━━━━
```

---

## 🚨 關鍵問題

### 問題 1: 所有可操作 UI 都被禁用

**原因**: 「路徑 B - 完全 Parity 化」策略

**影響**:
- ❌ L5-2 完全不合格
- ❌ 無法驗證 L5-3
- ❌ UI 存在但無功能 = 功能退化

**範例**:
```dart
// 當前狀態 (Parity Mode):
MaterialButton(
  onPressed: null,  // ❌ 禁用
  child: Text('儲存'),
)

// Android 預期:
MaterialButton(
  onPressed: () {
    // ✅ 儲存邏輯 + BLE 發送
  },
  child: Text('儲存'),
)
```

---

### 問題 2: 點擊時機無法驗證

**原因**: 所有行為都被移除

**影響**:
- ⚠️ L5-3 無法評分
- ⚠️ 無法確認「何時觸發 BLE」的一致性

**範例**:
```dart
// 需要驗證但當前無法驗證:

// 情境 1: 立即發送 vs 確認後發送
// Android: 按「儲存」才發送 BLE (0x6F)
// Flutter: ❓ 無法驗證（onPressed: null）

// 情境 2: 值變更時發送 vs 離開焦點發送
// Android: TextField 失去焦點時更新
// Flutter: ❓ 無法驗證（enabled: false）
```

---

## 📋 詳細問題清單

### Dosing 模組 (9 個頁面)

| 頁面 | 禁用的可操作 UI 數量 | 主要問題 |
|------|---------------------|---------|
| DosingMainPage | 6 個 | BLE 連線、泵頭導航、立即執行 |
| DropSettingPage | 5 個 | 儲存設定、編輯名稱、選擇位置、延遲時間 |
| PumpHeadDetailPage | 4 個 | 功能導航 (編輯、排程、校正) |
| PumpHeadSettingsPage | 6 個 | 儲存設定、選擇種類、Switch、編輯量、轉速 |
| PumpHeadRecordSettingPage | 15+ 個 | 所有設定選項、Radio、Checkbox |
| PumpHeadRecordTimeSettingPage | 6 個 | 所有時段設定 |
| PumpHeadAdjustListPage | 3 個 | 導航、列表互動 |
| PumpHeadCalibrationPage | 5 個 | 校正流程所有步驟 |
| DropTypePage | 5+ 個 | 選擇、新增、編輯、刪除 |

**總計**: ~55 個可操作 UI 被禁用 ❌

---

### LED 模組 (8 個頁面)

| 頁面 | 禁用的可操作 UI 數量 |
|------|---------------------|
| LedMainPage | ⚠️ 部分實作 |
| LedScenePage | 3+ 個 |
| LedSceneAddPage | 4+ 個 |
| LedSceneEditPage | 4+ 個 |
| LedSceneDeletePage | 3+ 個 |
| LedRecordPage | 5+ 個 |
| LedRecordTimeSettingPage | 6+ 個 |
| LedRecordSettingPage | 8+ 個 |
| LedSettingPage | 5+ 個 |
| LedMasterSettingPage | 4+ 個 |

**總計**: ~40 個可操作 UI 被禁用 ❌

---

## 🔄 解決方案

### 方案 A: 維持 Parity 模式（不建議）

**說明**: 繼續「路徑 B」策略，UI 純展示

**優點**:
- ✅ UI 結構 100% 對齊

**缺點**:
- ❌ L5-2 永遠 0%
- ❌ L5-3 無法驗證
- ❌ 功能退化
- ❌ 無法實際使用

**建議**: ❌ 不採用（違反 L5 原則）

---

### 方案 B: 完整功能實現（建議）

**說明**: 從 Parity 模式轉為 Feature Implementation Mode

**步驟**:
1. 保留 UI 結構（已達 100%）
2. 實現業務邏輯（Controller、UseCase、Repository）
3. 恢復所有 `onPressed` 行為
4. 實現 BLE 指令發送
5. 驗證 L5-3 點擊時機

**優點**:
- ✅ L5-1 維持 100%
- ✅ L5-2 可達 90%+
- ✅ L5-3 可驗證
- ✅ 功能完整

**預計時間**: 
- Dosing 模組: 40-60 小時
- LED 模組: 30-50 小時

---

### 方案 C: 混合模式（折衷）

**說明**: 部分頁面實現功能，部分保持 Parity

**優先實現**:
1. 主要流程頁面 (DosingMainPage, LedMainPage)
2. 設定頁面 (DropSettingPage, PumpHeadSettingsPage)
3. 高頻使用頁面

**保持 Parity**:
1. 低頻頁面
2. 次要功能頁面

**優點**:
- ⚠️ 部分功能可用
- ⚠️ L5 分數提升至 40-60%

**缺點**:
- ⚠️ 功能不完整
- ⚠️ 用戶體驗割裂

---

## ✅ 建議行動

### 短期 (立即)

1. ✅ **產出 L5 審核報告**（本文件）
2. ✅ **向專案負責人說明 L5 現況**
3. ✅ **決策：Parity vs Feature Implementation**

### 中期 (1-2 週)

如選擇「方案 B - 完整功能實現」:

1. **Dosing 模組**:
   - DosingMainPage: BLE 連線、立即執行
   - DropSettingPage: 儲存設定、延遲時間
   - PumpHeadRecordSettingPage: 排程設定

2. **LED 模組**:
   - LedMainPage: 場景切換、BLE 發送
   - LedSettingPage: 設定儲存

### 長期 (1-2 個月)

- 完成所有頁面功能實現
- L5-2 達到 90%+
- L5-3 完整驗證
- 整合測試

---

## 📄 附錄

### A. L5 評分計算方式

```
L5-1 = (Flutter 實現的可操作 UI / Android 可操作 UI) × 100%
L5-2 = (有效的點擊行為 / 總可操作 UI) × 100%
L5-3 = (時機一致的行為 / 總行為) × 100%

L5 整體 = (L5-1 × 0.3) + (L5-2 × 0.5) + (L5-3 × 0.2)
```

### B. 可操作 UI 統計

| 模組 | Android 可操作 UI | Flutter 已實現 | Flutter 已啟用 |
|------|------------------|---------------|---------------|
| Dosing | ~55 個 | 55 個 (100%) | 0 個 (0%) |
| LED | ~40 個 | 40 個 (100%) | 0 個 (0%) |
| 其他 | ~10 個 | 10 個 (100%) | 0 個 (0%) |
| **總計** | **~105 個** | **105 個 (100%)** | **0 個 (0%)** |

---

**報告完成日期**: 2026-01-03  
**關鍵結論**: L5-1 完美 (100%)，L5-2 嚴重不合格 (0%)  
**建議**: 必須從 Parity Mode 轉為 Feature Implementation Mode

