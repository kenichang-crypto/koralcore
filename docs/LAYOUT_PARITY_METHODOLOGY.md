# Layout 對照方法論：reef-b-app → koralcore

**目的**：在 Flutter 架構下對照 reef-b-app 的 UX layout，確保體驗一致。  
**原則**：僅檢視與分析，不改動 reef-b-app（res/layout/*.xml）。

---

## 一、reef-b-app Layout 結構總覽

### 1.1 檔案對應表

| reef 路徑 | reef 用途 | koralcore 對應 |
|-----------|-----------|----------------|
| **Activities（單頁）** | | |
| activity_main.xml | 主框架（toolbar + NavHost + BottomNav） | MainScaffold / BottomNav |
| activity_led_main.xml | LED 主頁 | led_main_page.dart |
| activity_drop_main.xml | Dosing 主頁 | dosing_main_page.dart |
| activity_add_device.xml | 新增設備 | add_device_page.dart |
| activity_drop_setting.xml | 滴液設定 | drop_setting_page.dart |
| activity_drop_head_setting.xml | 泵頭設定 | pump_head_settings_page.dart |
| activity_drop_type.xml | 滴液類型列表 | drop_type_page.dart |
| activity_sink_position.xml | 水槽位置 | sink_position_page.dart |
| activity_sink_manager.xml | 水槽管理 | sink_manager_page.dart |
| activity_drop_head_adjust.xml | 校正頁 | pump_head_calibration_page.dart |
| activity_drop_head_adjust_list.xml | 校正紀錄列表 | pump_head_adjust_list_page.dart |
| activity_drop_head_record_setting.xml | 紀錄設定 | pump_head_record_setting_page.dart |
| activity_drop_head_record_time_setting.xml | 紀錄時間設定 | pump_head_record_time_setting_page.dart |
| activity_led_setting.xml | LED 設定 | led_setting_page.dart |
| activity_led_record.xml | LED 紀錄 | led_record_page.dart |
| activity_led_record_setting.xml | LED 紀錄設定 | led_record_setting_page.dart |
| activity_led_record_time_setting.xml | LED 紀錄時間設定 | led_record_time_setting_page.dart |
| activity_led_scene.xml | LED 場景頁 | led_scene_page.dart |
| activity_led_scene_add.xml | 新增場景 | led_scene_add_page.dart |
| activity_led_scene_edit.xml | 編輯場景 | led_scene_edit_page.dart |
| activity_led_scene_delete.xml | 刪除場景 | led_scene_delete_page.dart |
| activity_led_master_setting.xml | Master 設定 | led_master_setting_page.dart |
| activity_warning.xml | 警報 | warning_page.dart |
| **Fragments（Tab 內容）** | | |
| fragment_home.xml | Home Tab | home_tab_page.dart |
| fragment_device.xml | Device Tab | device_tab_page.dart |
| fragment_bluetooth.xml | Bluetooth Tab | bluetooth_tab_page.dart |
| **Adapters（列表項目）** | | |
| adapter_*.xml | RecyclerView item | ListTile / Card / Custom widget |
| **共用** | | |
| toolbar_device.xml | 設備 toolbar | ReefAppBar / _ToolbarDevice |
| toolbar_two_action.xml | 雙按鈕 toolbar | _ToolbarTwoAction |
| progress.xml | 載入遮罩 | _ProgressOverlay |

---

## 二、對照維度與 Flutter 對應

### 2.1 維度 A：頁面是否有 ScrollView

| reef 結構 | Flutter 對應 | 說明 |
|-----------|--------------|------|
| **無 ScrollView**（ ConstraintLayout 填滿） | `Column` + `Expanded`，無 `SingleChildScrollView` | 單頁，內容需在一屏內 |
| **有 ScrollView 包整頁** | `SingleChildScrollView` 或 `ListView` | 頁面可捲動 |
| **RecyclerView 獨立**（height=0dp 填滿） | `ListView` / `GridView` | 僅列表區可捲動 |

**reef 有 ScrollView 的 layout**：
- activity_drop_main.xml（整頁 ScrollView）
- fragment_bluetooth.xml（整頁 ScrollView）
- activity_drop_head_record_setting.xml
- activity_led_record_time_setting.xml
- activity_led_scene_add.xml / edit.xml
- activity_led_master_setting.xml

**reef 無 ScrollView 的 layout**（單頁固定）：
- activity_led_main.xml
- activity_add_device.xml
- activity_drop_setting.xml
- activity_drop_type.xml
- activity_sink_position.xml
- fragment_home.xml
- fragment_device.xml

### 2.2 維度 B：固定 vs 捲動邊界

| reef 模式 | 說明 | koralcore 作法 |
|-----------|------|----------------|
| Toolbar 固定 | `app:layout_constraintTop_toTopOf="parent"` | `Scaffold.appBar` 固定 |
| 主內容填滿 (layout_height=0dp) | ConstraintLayout 填滿剩餘空間 | `Expanded(child: ...)` |
| ScrollView 內為捲動區 | ScrollView 的子 view | `SingleChildScrollView` / `ListView` |
| RecyclerView 可捲 | rv 在 ScrollView 內或獨立 | `ListView.builder` / `ListView` |

### 2.3 維度 C：下拉（Spinner / PopupMenu）

**reef 中的「下拉」來源**：
- `Spinner`：fragment_home.xml `sp_sink_type`（水槽選擇）
- `PopupMenu`：由程式碼觸發，如 delay_time、toolbar menu

**對照原則**：
- reef 用 **Spinner** → koralcore 應對應 **DropdownButton** 或 **SinkSelectorBar**（依 reef 實際 UX）
- reef 用 **PopupMenu**（如 delay 選單）→ koralcore 用 **showModalBottomSheet** 合規
- 若 koralcore 用 `DropdownButtonFormField` 而 reef 用 PopupMenu → 需確認 UX 是否等效

**需對照的「下拉」情境**：
| reef | koralcore | 對照狀態 |
|------|-----------|----------|
| fragment_home Spinner | SinkSelectorBar（非 Dropdown） | 功能等效，UI 略異 |
| delay time PopupMenu | showModalBottomSheet + ListTile | ✅ 等效 |
| schedule type | DropdownButtonFormField | reef 可能為 PopupMenu，需確認 |
| rotating speed | showModalBottomSheet | ✅ 等效 |

---

## 三、單頁判定規則

**「單頁」定義**：主要內容不需捲動即可完整顯示。

| 情境 | 是否算單頁 | 備註 |
|------|------------|------|
| Add Device、Drop Setting | ✅ 是 | 欄位少，ConstraintLayout 填滿 |
| Dosing Main | ❌ 否 | reef 有 ScrollView，泵頭列表可長 |
| Bluetooth Tab | ❌ 否 | reef 有 ScrollView，列表可長 |
| LED Main | ✅ 是 | 無 ScrollView，僅 rv_favorite_scene 橫向捲動 |
| Device Tab 空狀態 | ✅ 是 | 固定圖+文+按鈕 |
| Drop Type、Sink Position | ✅ 是 | RecyclerView 填滿，列表自捲 |

**若 koralcore 某頁有額外捲動，而 reef 沒有** → 需回頭對照，可能是 layout 設計不同。

---

## 四、對照檢查清單（每頁適用）

```
□ 1. reef layout 檔：res/layout/activity_xxx.xml 或 fragment_xxx.xml
□ 2. koralcore 檔：lib/features/.../xxx_page.dart
□ 3. reef 有無 ScrollView？
     □ 無 → koralcore 不得有 SingleChildScrollView 包整頁
     □ 有 → koralcore 需有對應捲動
□ 4. reef 區塊順序（ConstraintLayout 的 constraint 鏈）：
     □ toolbar → section1 → section2 → ...
     □ koralcore Column children 順序一致
□ 5. reef 有無 Spinner / 下拉？
     □ 有 → koralcore 需對照（Dropdown / BottomSheet / 自訂 Bar）
□ 6. reef 固定區（toolbar、標題）：
     □ koralcore 對應 Widget 不在 ScrollView 內
□ 7. reef 可捲區（ScrollView 內、RecyclerView）：
     □ koralcore 對應在 SingleChildScrollView / ListView 內
□ 8. reef dimens（dp_16, dp_8, marginTop 等）：
     □ koralcore AppSpacing / EdgeInsets 對應
```

---

## 五、逐頁快速對照結果

| 頁面 | reef Scroll | koralcore Scroll | reef 下拉 | 狀態 |
|------|-------------|------------------|-----------|------|
| LED Main | 無 | 無（僅場景區橫捲） | 無 | ✅ |
| Dosing Main | ScrollView | SingleChildScrollView | 無 | ✅ |
| Add Device | 無 | 無 | 無 | ✅ |
| Drop Setting | 無 | 無 | btn_delay → BottomSheet | ✅ |
| Pump Head Setting | 無 | 無 | rotating speed → BottomSheet | ✅ |
| Drop Type | 無 | ListView (rv_drop_type) | 無 | ✅ |
| Sink Position | 無 | ListView.builder | 無 | ✅ |
| Home | 無 | GridView/ListView | Spinner (sp_sink_type) | ⚠️ SinkSelectorBar |
| Device Tab | 無 | GridView/ListView | 無（Spinner 註解掉） | ✅ |
| Bluetooth Tab | ScrollView | ListView | 無 | ✅ |
| Pump Head Record Setting | ScrollView | SingleChildScrollView | 多處 | ✅ |
| LED Scene Add/Edit | ScrollView | ListView | 無 | ✅ |
| Schedule Edit | - | ListView + DropdownButtonFormField | - | ⚠️ 對照 reef schedule 頁 |
| Manual Dosing | - | ListView + DropdownButtonFormField | - | ⚠️ 對照 reef |

---

## 六、對照方法執行步驟

1. **選定 reef layout 檔**：從 `res/layout/*.xml` 找到對應 activity/fragment。
2. **解析 XML 結構**：
   - 根節點：ConstraintLayout / ScrollView
   - 子節點順序與約束（constraint 鏈）
   - 是否有 Spinner、PopupMenu 觸發元件
3. **映射到 Flutter**：
   - ConstraintLayout → Column / Row / Stack
   - ScrollView → SingleChildScrollView
   - RecyclerView → ListView / GridView
   - include toolbar → Scaffold.appBar / 自訂 AppBar
4. **對照 koralcore 實作**：比對 widget 樹的順序、捲動邊界、padding。
5. **下拉特別處理**：若 reef 有 Spinner 或 PopupMenu，確認 koralcore 用何種元件實現，UX 是否等效。

---

## 七、結論

- **體感一致** 重於 **結構一模一樣**：Flutter 與 Android XML 的 layout 模型不同，重點是區塊順序、固定/捲動邊界、主 CTA 位置與「下拉」行為。
- **若有下拉或額外捲動**：標記為需對照，回頭比對 reef 的 layout 與實際操作流程。
- **dimens 對照**：reef `dimens.xml` → koralcore `AppSpacing`、`AppRadius`。
