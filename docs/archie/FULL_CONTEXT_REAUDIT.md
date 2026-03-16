# Full Context Re-audit（全域回顧同步）— 唯一 Gate 依據

## 目的與範圍（本文件的「唯一性」）

本文件的目的：**把「Android（reef-b-app）事實」與「Flutter（koralcore）現況」同步到同一份可驗證的 Gate**，後續任何 Flutter Page parity 只能以此文件為準，不得憑印象或自行推論。

本次回顧的資料來源（已實際讀取/掃描）：
- **Android UI（盤點快照）**：`docs/reef_b_app_res/` 下的 `layout/`, `layout-land/`, `values/`, `values-*/`
- **Flutter 專案現況**：`lib/` 目錄結構、`lib/main.dart`、`lib/features/splash/presentation/pages/splash_page.dart`、`lib/l10n/*`、`l10n.yaml`
- **既有對照/檢查文檔**：`docs/REEF_B_APP_UI_STRUCTURE_ANALYSIS.md`、`docs/APP_INSTALLATION_FLOW_PARITY_CHECK.md`、`docs/SPLASH_TRANSITION_COMPARISON.md`、`docs/RES_RESOURCES_ALLOCATION_VERIFICATION.md`、`docs/L10N_SYSTEM_ARCHITECTURE_EXPLANATION.md` 等

> **重要限制**：本文件只描述「事實與約束」與「Gate 規則」。在完成此文件前/未被確認前，**不得進行任何新 Page parity**（此為流程 Gate）。

---

## 一、Android（reef-b-app）事實盤點（A–E 表：全量 UI 清單）

此處的 A–E 表是依 `docs/reef_b_app_res/layout/*.xml` 實際存在的檔案所分類（非臆測）。

### A. App 啟動 / 主框架

- **SplashActivity**
  - **layout**：`activity_splash.xml`
  - **根結構**：`ConstraintLayout` → 只有一個 `ImageView`
  - **可捲動**：否（無 ScrollView）
  - **include**：無
- **MainActivity（主框架）**
  - **layout**：`activity_main.xml`
  - **頂層順序（摘錄）**：`include(toolbar_app)` → `FragmentContainerView` → `BottomNavigationView` → `include(progress)`
  - **可捲動**：否（由 Fragment 自己決定）
  - **include**：`@layout/toolbar_app`、`@layout/progress`

### B. MainActivity 底部導航（Fragments）

- **HomeFragment**
  - **layout**：`fragment_home.xml`
  - **可捲動**：否（根是 ConstraintLayout；列表用 RecyclerView）
- **BluetoothFragment**
  - **layout**：`fragment_bluetooth.xml`
  - **可捲動**：**是**（根是 `ScrollView`）
- **DeviceFragment**
  - **layout**：`fragment_device.xml`
  - **可捲動**：否（根是 ConstraintLayout；列表用 RecyclerView）

### C. LED（Activities）

依 `layout/` 中 `activity_led_*.xml`：
- `activity_led_main.xml`（不可捲動）
- `activity_led_setting.xml`（不可捲動）
- `activity_led_master_setting.xml`（**可捲動：ScrollView**）
- `activity_led_record.xml`（不可捲動）
- `activity_led_record_setting.xml`（不可捲動）
- `activity_led_record_time_setting.xml`（**可捲動：ScrollView**）
- `activity_led_scene.xml`（不可捲動）
- `activity_led_scene_add.xml`（**可捲動：ScrollView**）
- `activity_led_scene_edit.xml`（**可捲動：ScrollView**）
- `activity_led_scene_delete.xml`（不可捲動）

### D. Dosing / Drop（Activities）

依 `layout/` 中 `activity_drop_*.xml`：
- `activity_drop_main.xml`（**可捲動：ScrollView**）
- `activity_drop_setting.xml`（不可捲動）
- `activity_drop_type.xml`（不可捲動）
- `activity_drop_head_main.xml`（不可捲動）
- `activity_drop_head_setting.xml`（不可捲動）
- `activity_drop_head_record_setting.xml`（**可捲動：ScrollView**）
- `activity_drop_head_record_time_setting.xml`（不可捲動）
- `activity_drop_head_adjust.xml`（不可捲動）
- `activity_drop_head_adjust_list.xml`（不可捲動）

### E. 其他（Sink / Warning / BottomSheet / Dialog / Adapter / Toolbar）

- **Sink**
  - `activity_sink_manager.xml`（不可捲動；RecyclerView）
  - `activity_sink_position.xml`（不可捲動；RecyclerView）
- **Warning**
  - `activity_warning.xml`（不可捲動；RecyclerView）
- **BottomSheet（2）**
  - `bottom_sheet_edittext.xml`
  - `bottom_sheet_recyclerview.xml`
- **Dialog / Progress**
  - `dialog_loading.xml`
  - `progress.xml`
- **Toolbar（3）**
  - `toolbar_app.xml`
  - `toolbar_device.xml`
  - `toolbar_two_action.xml`

---

## 二、Android layout 的「可捲動」事實（直接校正 Gate 規則）

**掃描結果（layout 中包含 ScrollView 的頁面）共 7 個：**
- `activity_drop_head_record_setting.xml`
- `activity_drop_main.xml`
- `activity_led_master_setting.xml`
- `activity_led_record_time_setting.xml`
- `activity_led_scene_add.xml`
- `activity_led_scene_edit.xml`
- `fragment_bluetooth.xml`

**因此：**
- 任何「一頁不整頁捲動」的工程規則，若被當成全域禁止，會與 Android 事實衝突。
- 正確 Gate 應是：**Flutter 必須對齊 Android 的 scrollability（Android 可捲動 → Flutter 可捲動；Android 不可捲動 → Flutter 禁止整頁捲動）。**

---

## 三、Android toolbar 的實際結構與使用（不可憑印象）

### 1) toolbar 結構事實

- **`toolbar_app.xml`**
  - `AppBarLayout` + `Toolbar`
  - 可選按鈕：`btn_choose` / `btn_delete` / `btn_right`
  - **固定底部分隔線**：`MaterialDivider`，高度 **2dp**（`@dimen/dp_2`），顏色 `@color/bg_press`

- **`toolbar_device.xml`**
  - 左：`btn_back`
  - 中：`toolbar_title`
  - 右：`btn_menu` 與 `btn_favorite`
  - **固定底部分隔線**：2dp `MaterialDivider`

- **`toolbar_two_action.xml`**
  - 左：`btn_left`（文字按鈕，常用於「返回/取消」語意）
  - 右：`btn_right`（文字按鈕，常用於「完成/儲存」語意）
  - 或右側 icon：`btn_icon`
  - **固定底部分隔線**：2dp `MaterialDivider`

### 2) toolbar include 使用覆蓋（layout 掃描）

- `@layout/toolbar_app`：**1**（只用在 `activity_main.xml`）
- `@layout/toolbar_device`：**3**（`activity_drop_main.xml`, `activity_drop_head_main.xml`, `activity_led_main.xml`）
- `@layout/toolbar_two_action`：**20**（大多數二級頁）
- `@layout/progress`：**24**（幾乎所有 Activity layout 都 include）

**Gate 意涵：**
- Flutter parity 不能「用任意 AppBar 取代 toolbar」，至少要在**結構語意**與**行為**上對齊（特別是：返回/右側按鈕/分隔線/是否可見）。

---

## 四、Android strings.xml（多語言完整性事實）

### 1) key 覆蓋

以 `docs/reef_b_app_res/values/strings.xml` 為 base：
- base（values）string keys：**375**
- `values-zh-rTW`：**375**（缺口 0）
- `values-ja/de/fr/es`：皆 **375**（缺口 0）

結論：**reef-b-app 的多語言 strings 在 key 層級是完整對齊的**（每個語系都有同一組 key）。

### 2) Gate 意涵（文字不可自創）

後續 Flutter parity 的文字來源必須滿足：
- **Android layout 若沒有文字 → Flutter 也不得新增文字**（例如 `activity_splash.xml`）
- **Android layout 有文字 → Flutter 必須使用「已存在且語意等價」的字串資源**（不能 hardcode）

> 注意：Android strings key 命名與 Flutter ARB key 命名目前並不一致（見下節風險），所以 Gate 需要「mapping」而不是要求 key 同名。

---

## 五、Flutter（koralcore）現況事實（結構 / l10n / 資源）

### 1) 專案結構（既有實際目錄）

`lib/` 目前是分層結構：
- `app/`：應用層（MainScaffold、導航控制、UseCases 組裝）
- `core/`：純技術核心（BLE readiness、errors、extensions）
- `data/`：BLE/DB/Repository 實作
- `domain/`：純模型 + 用例接口/領域規則
- `features/`：各 feature 的 presentation（pages/controllers/widgets）
- `shared/`：共享 widgets/theme/assets helper
- `l10n/`：ARB 與 generated localizations

### 2) l10n 架構（已存在、且必須遵守）

- `l10n.yaml` 指定：
  - `arb-dir: lib/l10n`
  - `template-arb-file: intl_en.arb`
  - `output-localization-file: app_localizations.dart`
- `supportedLocales`（含 `zh` 與 `zh_Hant`）存在於 `lib/l10n/app_localizations.dart`

#### ARB 覆蓋現況（必須面對的事實）
- `intl_en.arb` keys：**537**
- `intl_zh_Hant.arb` keys：**339**
- `zh_Hant` 相對 `en`：**缺 201 個翻譯**（`flutter gen-l10n` 也會報告這個缺口）

### 3) Android strings → Flutter ARB 的「同名 key 重疊」非常低（風險）

粗略比對（僅同名 key，不含 mapping）：
- Android strings keys：375
- Flutter `intl_en.arb` keys：537
- **同名重疊只有 8**

**Gate 意涵：**
- 後續 parity 若要求「文字來自 Android strings」：在 Flutter 端**必須依賴既有 mapping / 導入策略**，不可期待 key 同名。
- 任何頁面 parity 前，必須先確認該頁面所需文字是否已存在於 ARB（且在 `zh_Hant` 有翻譯），否則應先補齊「既有資源導入」而不是在 UI 內硬寫。

### 4) 已移入的 Android 資源（事實）

依既有文檔：
- `docs/RES_RESOURCES_IMPORTED.md`：已導入 Splash 圖片等資源（`assets/images/splash/*`）
- `docs/RES_RESOURCES_ALLOCATION_VERIFICATION.md`：顏色（`colors.xml`）已對照到 Flutter 的語意色盤（AppColors/ReefColors）；dimens/text styles 仍有需要補齊的對照工作

---

## 六、已實作內容中「與 Android 事實不一致」的典型風險（必須避免）

此段不是要求立刻修，而是把「之後 parity 會踩的坑」先固定為 Gate 規則：

- **（風險 1）把「不整頁捲動」當成全域禁止**
  - Android 本身就有 7 個 layout 使用 ScrollView（見第二節）
  - Gate 必須改為：**匹配 Android 的 scrollability**

- **（風險 2）用 Flutter 自己的 UI 設計替代 Android 結構**
  - Gate 明確要求：**Flutter UI 結構必須對照 Android layout（順序/區塊/是否 include toolbar/progress）**

- **（風險 3）文字來源不受控（hardcode 或 placeholder）**
  - Android strings 在多語言 key 是齊的，但 Flutter `zh_Hant` 仍缺 201 翻譯
  - Gate：**未導入/未翻譯不得硬塞文字到 UI**；要先補資源

- **（風險 4）導航堆疊不等價**
  - Android 常見模式：`startActivity()` + `finish()`
  - Gate：Flutter 必須確保「不會回到不該回到的頁面」（例如 splash）

- **（風險 5）Fragment 對應位置不一致（結構性 parity）**
  - 既有文檔已指出：`BluetoothFragment` 的對應在 Flutter 端位置存在不一致風險（需以 MainActivity 底部導航結構為準）
  - Gate：**結構對齊（feature/route 位置）也是 parity 的一部分**，但必須在「全域 Gate」中先定義清楚再動手

---

## 七、後續逐頁 Flutter Page parity 的「唯一 Gate 作業流程」

每一頁 parity 必須按以下步驟（不得跳步）：

### 1) 鎖定 Android 事實
- **對應 Activity/Fragment/layout 檔名**
- **頂層結構順序**（根容器 + top-level child 順序）
- **是否可捲動**（Android layout 是否包含 ScrollView）
- **include 了哪些 toolbar/progress/bottom sheet/dialog**
- **文字來源**（layout 是否有文字；文字對應 strings key 的語意）

### 2) 鎖定 Flutter 目標與限制
- **只改允許的單一 Page**（除非 Gate 明確允許必要導航修正）
- **禁止新增 UI 元件/禁止改 shared/theme**（若任務如此限制）
- **禁止新增文字**（除非 Android layout 有對應文字且 ARB 已存在）

### 3) 實作對齊（只做結構與行為，不做美化）
- 結構以 Android layout「功能語意區塊」為最小單位
- scrollability 只做 Android 同步（不多、不少）
- toolbar 行為依 toolbar_* 的實際結構語意對齊（返回/右側動作/分隔線）
- 導航使用「不可回退到不該回退頁」的 stack 策略（對齊 start+finish）

### 4) 檢核與輸出
- 更新/新增該頁的 parity 佐證（對照表、行為描述）
- 不通過 Gate（缺資源/缺翻譯/缺對照事實）→ **先補資源，不做 UI**

---

## 八、狀態宣告（流程 Gate）

在本文件被你確認為「唯一 Gate」之前：
- ❌ 不進行任何新 Flutter Page parity
- ❌ 不進行任何新頁面實作
- ✅ 只允許補齊「Gate 必要資料」（例如 strings mapping、資源導入報告、對照表）


