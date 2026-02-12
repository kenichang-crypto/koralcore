# UX Parity Audit — REEF B Core Principles v1.0

**依據**: REEF B – UX Parity Core Principles v1.0  
**審計日期**: 2025-02-11  
**範圍**: koralcore 全部 UI vs reef-b-app  

---

## 一、原則對照表

| 層級 | 原則 ID | 原則名稱 | 判定 | 違反數 | 說明 |
|------|---------|----------|------|--------|------|
| 第一層 | P0 | Architecture Independence | ⚠️ | — | 架構可不同，但畫面/動作/回饋/順序須一致；下方違反項影響 P0 |
| 第二層 A | P1 | Section Ordering | ✅ | 0 | 依 UX_PARITY_PRINCIPLES §3，區塊順序已對照 |
| 第二層 A | P2 | CTA Placement | ⚠️ | 1 | Device Select 為 TextButton vs reef MaterialButton（docs 記載可接受） |
| 第二層 A | P3 | Navigation Contract | ✅ | 0 | 導航流程與 reef 對齊 |
| 第二層 B | P4 | Enablement Gate | ✅ | 0 | 已修正 §2.2 |
| 第二層 B | P5 | Async Feedback | ⚠️ | 0 | reef Toast vs koralcore Snackbar，可選補強 |
| 第二層 B | P6 | Gesture Contract | ✅ | 0 | 無新增 reef 沒有的 long press / swipe |
| 第二層 C | P7 | Copy Match Source | ⚠️ | 多處 | 見 §2.3 |
| 第二層 C | P8 | Dialog Semantics | ✅ | 0 | confirmation_dialog 結構對齊 |
| 第二層 D | P9 | Icon Ownership | ⚠️ | 1 | reef_material_icons 使用 Icons.*；reef 為 drawable；應優先 CommonIconHelper |
| 第二層 D | P10 | Color Semantics | ✅ | 0 | AppColors 對照 colors.xml |
| 第二層 E | P11 | BLE State Machine | ✅ | 0 | Scan→Add→Connect→Initialize→Ready 一致 |
| 第二層 E | P12 | Launch Readiness Order | ✅ | 0 | Splash→Permission→Scan→Connect→Ready |
| 第三層 | P13 | No Disabled Critical CTA | ✅ | 0 | 已修正 §2.2 |
| 第四層 | P14 | No Placeholder in Production | ❌ | 5+ | 見 §2.4 |

---

## 二、違規詳情

### 2.1 結構一致性（P1–P3）

| 項目 | 原則 | 現況 | reef 對照 | 建議 |
|------|------|------|-----------|------|
| Device Select CTA | P2 | main_shell_page TextButton | toolbar_app.xml btn_choose MaterialButton | 已記載可接受；若要嚴格對齊可改為 MaterialButton 樣式 |

### 2.2 Enablement Gate / Disabled CTA（P4, P13）

| 位置 | 違規 | reef 對照 | 建議 |
|------|------|-----------|------|
| **pump_head_calibration_page.dart** | TextField `enabled: false` | reef edt_adjust_drop_volume 無 android:enabled | ✅ 已修正：移除 enabled: false |
| **pump_head_record_time_setting_page.dart** | MaterialButton `onPressed: null` | reef btn_drop_times、btn_rotating_speed 可點擊 | ✅ 已修正：改為 Material+Padding，讓 PopupMenuButton 處理 tap |

### 2.3 Copy 一致性（P7）

| 位置 | 現況 | reef 對照 | 建議 |
|------|------|-----------|------|
| led_record_page.dart:360 | `ledChartPlaceholder` → "Chart Placeholder" | activity_led_record 若無對應 placeholder 文字 | 對照 reef 空狀態/圖表區文案 |
| led_record_time_setting_page.dart:261 | `ledSpectrumChartPlaceholder` → "Spectrum Chart Placeholder" | activity_led_record_time_setting | 對照 reef |
| led_scene_add_page.dart:232 | `ledSpectrumChartPlaceholder` | activity_led_scene_add | 對照 reef |
| led_scene_edit_page.dart:234 | `ledSpectrumChartPlaceholder` | activity_led_scene_edit | 對照 reef |
| 多處 Placeholder 字串 | dosingRecordTimePlaceholder、dosingTypeNamePlaceholder 等 | strings.xml | 若為空狀態/範例顯示，需對照 reef 對應字串；不得自創 |

### 2.4 Placeholder / Stub 禁止（P14）

| 位置 | 違規 | 說明 |
|------|------|------|
| **led_record_page.dart:360** | `l10n.ledChartPlaceholder` → "Chart Placeholder" | 生產流程中顯示 "Chart Placeholder" 字樣 |
| **led_record_time_setting_page.dart:261** | `l10n.ledSpectrumChartPlaceholder` → "Spectrum Chart Placeholder" | 同上 |
| **led_scene_add_page.dart:232** | `l10n.ledSpectrumChartPlaceholder` | 同上 |
| **led_scene_edit_page.dart:234** | `l10n.ledSpectrumChartPlaceholder` | 同上 |
| **sinkPositionFeatureComingSoon** | "Coming soon"（l10n 已定義） | 若 sink_position 流程有顯示「Coming soon」→ P14 違規；需確認 reef 是否有此功能/文案 |
| **comingSoon** | l10n 有定義 | 若任何生產流程顯示 → 違規 |

**pump_head_detail_page.dart 程式碼**:
- L445: `// TODO: 根據實際的 DosingScheduleSummary 結構返回正確的文字` — `_getScheduleTypeText` 固定回傳 `dosingScheduleTypeNone`
- L475: `// TODO: 顯示校正歷史數據` — 連線時顯示 `dosingCalibrationHistoryEmptySubtitle` 而非真實校正紀錄

若 reef 有顯示實際排程類型與校正歷史，則屬 stub，需實作。

### 2.5 Icon 所有權（P9）

| 位置 | 現況 | reef 對照 | 建議 |
|------|------|-----------|------|
| reef_material_icons.dart | Icons.add, Icons.delete, Icons.edit, Icons.close, Icons.refresh 等 | reef 使用 ic_add_black.xml, ic_delete.xml, ic_edit.xml 等 drawable | 依 UX_ASSETS_PARITY_ANALYSIS §1.4：Replace `ReefMaterialIcons.xxx` → `CommonIconHelper.getXxxIcon()`；需清查所有 ReefMaterialIcons 使用處 |

---

## 三、Layout / Scroll 對照（單頁無向下捲動）

依 UX_PARITY_PRINCIPLES §6，以下已修正：
- pump_head_detail_page：已移除 SingleChildScrollView ✅
- pump_head_record_time_setting_page：已移除 SingleChildScrollView ✅

**reef 有 ScrollView 的 layout**（koralcore 可保留對應捲動）:
- activity_drop_main, fragment_bluetooth, activity_drop_head_record_setting, activity_led_record_time_setting, activity_led_scene_add, activity_led_scene_edit, activity_led_master_setting

**需逐頁對照 reef 的頁面**（reef 無對應 layout 或需再確認）:
- led_control_page, led_schedule_edit_page, manual_dosing_page, schedule_edit_page

---

## 四、修正順序（依原則 §⑤）

1. **1️⃣ 先修 CTA 可用性**
   - pump_head_record_time_setting_page: MaterialButton onPressed（驗證 PopupMenuButton 是否可點）
   - pump_head_calibration_page: TextField enabled（對照 reef activity_drop_head_adjust）

2. **2️⃣ 再修 Copy 對齊**
   - ledChartPlaceholder、ledSpectrumChartPlaceholder → 對照 reef 對應字串
   - dosingRecordTimePlaceholder 等 → 對照 strings.xml

3. **3️⃣ 再修 Navigation Flow**
   - 目前無明顯違規

4. **4️⃣ 再修 Enable/Disable Gate**
   - 完成 1️⃣ 後一併確認

5. **5️⃣ 最後才修 Spacing / 細節 UI**
   - Device Select 按鈕樣式、led_scene_edit 圖標尺寸等

---

## 五、ReefMaterialIcons / Icons 使用清查

- **ReefMaterialIcons**：僅定義於 reef_material_icons.dart，專案內無直接使用 `ReefMaterialIcons.xxx`
- **Icons.*** 直接引用：reef_material_icons.dart 內部使用 Icons.add、Icons.delete 等作為常數
- **結論**：reef_material_icons 為備用別名層，目前 UI 多使用 CommonIconHelper。若未來新增圖標，應優先使用 CommonIconHelper，避免使用 Icons.* 或 ReefMaterialIcons。

---

## 六、總結

| 類別 | 數量 | 優先級 |
|------|------|--------|
| P13 禁用 CTA | 0 ✅ | 已修正 |
| P14 Placeholder | 5+ | 高 |
| P7 Copy | 多處 | 中 |
| P9 Icon | 1 來源 + 多處使用 | 中 |
| P4 Enablement Gate | 2 | 中（與 P13 重疊） |
| P2 CTA 樣式 | 1 | 低 |

**建議**：依修正順序 §④，先處理 CTA 可用性與 Placeholder 禁止，再處理 Copy 與 Icon。
