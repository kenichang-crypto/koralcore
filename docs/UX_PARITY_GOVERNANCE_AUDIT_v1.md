# UX Parity Governance Audit v1.0 — koralcore vs reef-b-app

依 **REEF B – UX Parity Governance Rules v1.0** 對 koralcore 進行全面審計。
reef-b-app 僅為對照基準，不進行任何修改。

---

## 摘要

| 規則類別 | 違規數 | 嚴重程度 |
|---------|--------|----------|
| **X1** - No Disabled Critical CTA | 28+ | 🔴 Critical |
| **X2** - No Placeholder in Production | 6 | 🔴 Critical |
| **C3** - No Hardcoded Production Copy | 20+ | 🟠 High |
| **C2** - Action Verb Consistency | 5+ | 🟡 Medium |
| **A1** - Icon from reef-b-app | 5 | 🟡 Medium |
| **I2** - Enable/Disable Gate | 待逐項對照 | 🟡 Medium |
| **L1** - Section Ordering | 待逐頁對照 | 🟢 Low |

---

## X1 – No Disabled Critical CTA

**規則**：若 reef 中某按鈕可操作，Flutter 不可 disabled、onPressed: null、comingSoon、TODO。

### 違規清單

| # | 檔案 | 行號 | 描述 | 最小修正 |
|---|------|------|------|----------|
| 1 | `lib/features/home/presentation/pages/home_tab_page.dart` | 56-62 | Sink Manager 按鈕顯示「功能開發中」snackbar，未導航 | 改為 `Navigator.push(SinkManagerPage())` |
| 2 | `lib/features/led/presentation/pages/led_record_page.dart` | 296,300,305,310,315 | 5 個 control buttons (add/minus/back/next/play) 皆 `onPressed: null` | 依 reef `adapter_led_record.xml` 對照綁定行為 |
| 3 | `lib/features/led/presentation/pages/led_record_page.dart` | 377 | Add record 按鈕 `onPressed: null` (Correction Mode) | 對照 reef 是否在該模式可新增，若可則綁定 |
| 4 | `lib/features/led/presentation/pages/led_setting_page.dart` | 317 | 某按鈕 `onPressed: null` (Correction Mode) | 對照 reef Correction Mode 行為 |
| 5 | `lib/features/led/presentation/pages/led_record_time_setting_page.dart` | 90,110,152 | 3 處 `onPressed: null` | 對照 reef 綁定對應行為 |
| 6 | `lib/features/led/presentation/pages/led_record_setting_page.dart` | 98,118,273,329 | 4 處 `onPressed: null` | 對照 reef record setting 行為 |
| 7 | `lib/features/led/presentation/pages/led_master_setting_page.dart` | 85,105,408 | 3 處 `onPressed: null` | 對照 reef master setting 行為 |
| 8 | `lib/features/doser/presentation/pages/drop_type_page.dart` | 89,129,143,214 | 4 處 `onPressed: null` (Parity Mode) | 對照 reef DropType activity 綁定 |
| 9 | `lib/features/doser/presentation/pages/pump_head_adjust_list_page.dart` | 98,112 | 2 處 `onPressed: null` | 對照 reef adjust list 行為 |
| 10 | `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` | 114,128,227,292,422 | 5 處 `onPressed: null` | 對照 reef record setting 綁定 |
| 11 | `lib/features/doser/presentation/pages/pump_head_calibration_page.dart` | 90,205 | 2 處 `onPressed: null` | 對照 reef calibration 行為 |
| 12 | `lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart` | 75,90,105,141,182,196 | 6 處 `onPressed: null` | 對照 reef record time setting |
| 13 | `lib/features/device/presentation/pages/add_device_page.dart` | 318 | Sink position InkWell `onTap: null` | 對照 reef 是否可選水槽，若可則綁定 SinkPositionPage |
| 14 | `lib/features/sink/presentation/pages/sink_manager_page.dart` | 64 | 某按鈕 `onPressed: null` | 對照 reef 綁定行為 |
| 15 | `lib/features/sink/presentation/pages/sink_position_page.dart` | 89,152 | 2 處 `onPressed: null` | 對照 reef sink position 行為 |
| 16 | `lib/features/led/presentation/pages/led_scene_page.dart` | 137,161 | 2 處 `onPressed: null` | 對照 reef scene add/delete 行為 |

---

## X2 – No Placeholder in Production Flow

**規則**：主流程不可存在 Placeholder、Coming Soon、Mock only。

### 違規清單

| # | 檔案 | 行號 | 描述 | 最小修正 |
|---|------|------|------|----------|
| 1 | `lib/features/led/presentation/pages/led_scene_add_page.dart` | 232 | `'Spectrum Chart Placeholder'` | 以實際 spectrum widget 取代（參考 reef SpectrumUtil/SpectrumString） |
| 2 | `lib/features/led/presentation/pages/led_scene_edit_page.dart` | 234 | `'Spectrum Chart Placeholder'` | 同上 |
| 3 | `lib/features/led/presentation/pages/led_record_time_setting_page.dart` | 202 | `'Spectrum Chart Placeholder'` | 同上 |
| 4 | `lib/features/home/presentation/pages/home_tab_page.dart` | 58-60 | SnackBar `'功能開發中 / Feature under development'` | 移除 placeholder，改為實際導航 |
| 5 | `lib/l10n/intl_en.arb` | `ledDetailFavoriteTooltip`, `sinkPositionFeatureComingSoon` | 文案含 "coming soon" | 若 reef 該功能已上線，改為實際操作說明 |
| 6 | `lib/features/doser/presentation/pages/pump_head_settings_page.dart` | 199 | `'TODO: Navigate to DropTypePage'` | 改為 `Navigator.push(DropTypePage(...))` |

---

## C3 – No Hardcoded Production Copy

**規則**：不允許 hardcoded string、TODO string、Placeholder text；全部須進 l10n。

### 違規清單

| # | 檔案 | 行號 | 描述 | 最小修正 |
|---|------|------|------|----------|
| 1 | `lib/features/home/presentation/pages/home_tab_page.dart` | 60 | `'功能開發中 / Feature under development'` | 移除或改用 l10n |
| 2 | `lib/features/led/presentation/pages/led_main_page.dart` | 338 | `'群組Ａ'` (Placeholder from Android XML) | 抽到 ARB，或從 session/repo 取得實際值 |
| 3 | `lib/features/doser/presentation/pages/drop_type_page.dart` | 54,134,145 | `'TODO(android @string/...)'` | 對照 reef strings.xml 取 key，補 ARB 後使用 |
| 4 | `lib/features/doser/presentation/pages/pump_head_adjust_list_page.dart` | 103,114,159,183,207 | `'TODO(android @string/...)'` | 同上 |
| 5 | `lib/features/doser/presentation/pages/pump_head_record_setting_page.dart` | 119,130,172,216,278,391,411,451,495,531 | 多處 TODO string | 對照 reef strings.xml，補 ARB |
| 6 | `lib/features/doser/presentation/pages/pump_head_calibration_page.dart` | 62,72,80,104,119,213,264,360 | TODO string | 同上 |
| 7 | `lib/features/doser/presentation/pages/pump_head_record_time_setting_page.dart` | 65,80,95,110,131,187 | TODO string | 同上 |
| 8 | `lib/features/doser/presentation/pages/pump_head_settings_page.dart` | 126,187,199,223-225 | `'Init Rotating Speed'`, `'TODO(l10n)...'`, `'低速'` 等 | 補 ARB：initRotatingSpeed, toastSettingFailed, lowRotatingSpeed 等 |
| 9 | `lib/features/doser/presentation/pages/drop_setting_page.dart` | 256,260,264,280,304-310 | TODO(l10n)、hardcoded 延遲字串 | 補 ARB |
| 10 | `lib/features/led/presentation/pages/led_record_setting_page.dart` | 162,262,318,397 | `'Initial Intensity'`, `'Sunrise'`, `'Sunset'`, `'Slow Start'` | 補 ARB：initStrength, sunrise, sunset, slowStart |
| 11 | `lib/features/doser/presentation/controllers/drop_setting_controller.dart` | 233-245 | `'15 秒'`, `'30 秒'` 等 | 改用 l10n |
| 12 | `lib/features/doser/presentation/controllers/pump_head_settings_controller.dart` | 207-211 | `'低速'`, `'中速'`, `'高速'` | 改用 l10n |
| 13 | `lib/features/bluetooth/presentation/pages/bluetooth_tab_page.dart` | 254,344 | `''` (TODO ARB 缺少 drop) | 補 ARB key `drop`，對照 reef |
| 14 | `lib/features/sink/presentation/pages/sink_manager_page.dart` | 185 | TODO(android @string/text_no_sink_*) | 補 ARB |
| 15 | `lib/features/sink/presentation/pages/sink_position_page.dart` | 61 | TODO sink_position | 補 ARB 後使用 |

---

## C2 – Action Verb Consistency

**規則**：Apply/Save/Delete/Cancel 在相同情境必須一致。

### 違規清單

| # | 檔案 | 行號 | 描述 | 最小修正 |
|---|------|------|------|----------|
| 1 | `lib/features/doser/presentation/pages/pump_head_settings_page.dart` | 199 | CTA 顯示 TODO 而非實際導航 | 綁定導航後，按鈕文案對照 reef |
| 2 | `lib/features/doser/presentation/pages/drop_setting_page.dart` | 280 | 同上 | 同上 |
| 3 | 多處 dialogs | - | 確認 reef 使用 Delete vs Remove 用語 | 對照 reef strings.xml 統一 |
| 4 | `lib/features/led/presentation/pages/led_scene_page.dart` | 75,77 | menu_delete, led_scene_add 註解 | 確認動詞與 reef 一致 |

---

## C1 – Copy Ownership Rule

**規則**：文字來源以 reef-b-app 為主權；不得改動語氣、動詞、大小寫、句型。

### 違規清單

| # | 檔案 | 描述 | 最小修正 |
|---|------|------|----------|
| 1 | 多處 | `ledDetailFavoriteTooltip` 含 "Mark as favorite (coming soon)" | 若 reef 已上線 favorite，改為 reef 對應字串 |
| 2 | `lib/l10n/intl_en.arb` | `ledScenesPlaceholderSubtitle` 等 placeholder 文案 | 對照 reef 實際文案 |
| 3 | `dosingPumpHeadSettingsTankPlaceholder` | "Link additives from the Reef B app." | 對照 reef 用語 |
| 4 | `sinkPositionFeatureComingSoon` | "Coming soon" | 若 reef 已上線則改為實際說明 |

---

## A1 – Icon Must Come From reef-b-app

**規則**：所有 icon 須來自 Android vector drawable / iOS asset，Flutter 不得自創。

### 違規清單

| # | 檔案 | 行號 | 描述 | 最小修正 |
|---|------|------|------|----------|
| 1 | `lib/features/doser/presentation/pages/dosing_main_page.dart` | 201,218,227 | `Icon(Icons.edit)`, `Icon(Icons.delete)`, `Icon(Icons.refresh)` | 改用 CommonIconHelper 或 reef SVG（對照 drawable） |
| 2 | `lib/features/doser/presentation/pages/pump_head_calibration_page.dart` | 142-143 | `Icon(Icons.tune)` 註解為 error placeholder | 改用 reef 對應 drawable |
| 3 | `lib/features/led/presentation/helpers/support/scene_icon_helper.dart` | 107,138,187 | `Icons.circle_outlined` 作為 fallback | 確認 reef 有對應 fallback，或導入缺失 drawable |
| 4 | `lib/features/led/presentation/pages/led_scene_list_page.dart` | 601,668 | `Icons.auto_awesome`, `Icons.auto_awesome_motion` 等 | 對照 reef dynamic scene 圖示 |
| 5 | `lib/shared/widgets/ble_guard.dart` | - | 若有 Material Icons | 對照 reef BLE 相關 drawable |

---

## A2 – Icon Semantics Must Match

**規則**：Delete/Favorite/Warning 圖形語意須一致。

### 違規清單

| # | 檔案 | 描述 | 最小修正 |
|---|------|------|----------|
| 1 | `dosing_main_page.dart` | Icons.delete vs reef ic_delete | 改用 CommonIconHelper.getDeleteIcon |
| 2 | `dosing_main_page.dart` | Icons.edit vs reef ic_edit | 改用 CommonIconHelper.getEditIcon |
| 3 | `dosing_main_page.dart` | Icons.refresh vs reef | 對照 reef refresh/reset drawable |

---

## A3 – Color Semantics Must Match

**規則**：Primary/Warning/Error/Success/Connected/Disconnected 語意一致。

### 檢查結果

- `AppColors` 已對照 reef `colors.xml`：danger, success, warning 等存在。
- 個別 widget 使用需逐頁對照，未發現明顯違規。

---

## I2 – Enable/Disable Gate Must Match

**規則**：按鈕 enabled 條件（BLE connected、isReady、loading、preset vs custom）須一致。

### 待對照項目

| 頁面 | 檢查點 | 最小修正 |
|------|--------|----------|
| LED main | toolbar menu/favorite 是否僅在 isReady 開放 | 已實施 `session.isReady` gate |
| Dosing main | manual dose、schedule 按鈕 | 對照 reef 條件 |
| Scene list | preset 不可編輯、custom 可編輯 | 已實施 |
| AddDevice | Skip/Done 是否需 BLE connected | 已實施 |
| Device settings | Delete 是否需 connected | 已實施 `session.isBleConnected` |
| Led record | 5 個 control buttons | 需對照 reef 在 correction mode 的 enable 規則 |

---

## I4 – Navigation Flow Must Match

**規則**：頁面跳轉順序須一致。

### 違規 / 待確認

| # | 描述 | 最小修正 |
|---|------|----------|
| 1 | Home Sink Manager tap → 目前 snackbar | 應改為 push SinkManagerPage |
| 2 | Pump head settings → DropType | 目前 snackbar，應 push DropTypePage |
| 3 | Drop setting → SinkPosition | 目前 snackbar，應 push SinkPositionPage |
| 4 | AddDevice sink position → 目前 onTap: null | 若 reef 可選，應 push SinkPositionPage |

---

## B1 / B2 – BLE State Parity

**規則**：State machine、Feature gating 須對照 reef。

### 檢查結果

- `MainScaffold`、`DeviceListController`、`AppSession` 流程大致對齊。
- 各 feature 頁 `session.isReady` gate 已普遍實施。
- 需逐頁確認 reef 的 ready/error 時序與 gate 是否完全一致。

---

## L1 – Section Ordering Must Match

**規則**：頁面區塊順序須與 reef 完全一致。

### 待逐頁對照

- LED main、Dosing main、Device list、Device settings 等已依 parity 報告對齊。
- 新增/編輯頁（scene add/edit、schedule edit、pump head record setting）需逐 section 對照 reef XML。

---

## 修正優先順序（依 Governance 要求）

1. **補齊 CTA 可用性**（X1）  
   - Home Sink Manager  
   - Pump head settings → DropType  
   - Drop setting → SinkPosition  
   - AddDevice sink position  
   - LED record control buttons  
   - 其餘 onPressed: null 逐項對照 reef  

2. **修正 Navigation Flow**（I4）  
   - 將 snackbar/TODO 改為實際 push  

3. **修正 Enable/Disable Gate**（I2）  
   - 逐頁對照 reef 條件  

4. **修正 Copy 對齊**（C3, C2, C1）  
   - 移除 hardcoded、補 ARB、對照 reef strings  

5. **Layout spacing 細節**（L1, L4）  
   - 最後處理  

---

## 附錄：reef-b-app 對照資源

| 類型 | 路徑 |
|------|------|
| Strings | `android/ReefB_Android/app/src/main/res/values/strings.xml` |
| Drawables | `android/ReefB_Android/app/src/main/res/drawable/` |
| Layouts | `android/ReefB_Android/app/src/main/res/layout/` |
| Colors | `android/ReefB_Android/app/src/main/res/values/colors.xml` |
