# MANDATORY PARITY RULES — ANDROID ↔ FLUTTER
Version: 1.0 (Frozen)  
Scope: LED Module (initial), extensible to all modules  
Status: ENFORCED

---

## 🎯 核心原則（不可違反）

### RULE 0 — Android XML 是唯一事實來源
- Android XML（Activity / Fragment / Adapter）是 UI 結構的唯一事實
- Flutter **不得**根據「合理性 / UX / 習慣」自行簡化或重組
- 若 Flutter 無法 100% 對齊，必須：
  - 明確標註差異
  - 停止實作（Parity Blocked）

---

## 🧱 結構對齊規則（Layout）

### RULE 1 — 節點 1:1 映射
- Android XML 中的 **每一個 View 節點**：
  - Toolbar / TextView / ImageView / Slider / RecyclerView / Progress
- Flutter 中必須：
  - 有對應 Widget
  - 不可合併、不可省略、不可「用一個 widget 表示一組」

---

### RULE 2 — Scroll 行為必須完全一致
- Android 使用 ConstraintLayout（不可捲動）
  → Flutter **不可**使用 ListView / SingleChildScrollView
- Android 使用 ScrollView
  → Flutter **必須**使用可捲動容器
- Android 僅 RecyclerView 可捲動
  → Flutter 僅 ListView / Sliver 區段可捲動，其餘固定

> ❌ 「Flutter 加 fallback scroll 比較安全」  
> ⛔ 一律禁止（除非 Android 也可捲動）

---

### RULE 3 — visibility 語意嚴格對齊
Android：
- `visibility="gone"` → 不顯示、不佔空間
- `visibility="invisible"` → 不顯示、但佔空間

Flutter 對應：
- `gone` → **條件式 widget（if）**，不可用 SizedBox 佔位
- `invisible` → `Visibility(visible: false, maintainSize: true)`

> ❌ 禁止用 SizedBox 模擬 gone  
> ❌ 禁止為了「對齊」而人為佔位

---

## 🎛 元件行為規則（Interaction）

### RULE 4 — Parity 階段禁止任何業務邏輯
在「Parity 實作階段」：

- 所有互動必須為：
  - `onPressed: null`
  - `onTap: null`
  - `onChanged: null`
- ❌ 禁止：
  - controller 綁定
  - BLE / API / state 監聽
  - navigation / dialog / bottom sheet
  - 預設行為假實作

Parity = 結構，不是功能。

---

## 🎨 視覺規則（Visual）

### RULE 5 — margin / padding / size 必須對齊 XML
- XML 中的 dp 數值：
  - padding / margin / height / width
- Flutter 必須明確對應（EdgeInsets / SizedBox / constraints）

> ❌ 不可用「看起來差不多」

---

### RULE 6 — 圖表與特殊 View
- Android 使用 LineChart / CustomView：
  - Flutter 以 **placeholder 對齊結構**
  - 不畫實際資料
- 高度規則：
  - Android 固定高度 → Flutter 可用固定 height 或等價容器
  - 若 Flutter 無法固定，需明確標註差異

---

## 🧪 Parity Gate 流程（強制）

### RULE 7 — Parity Gate 必須逐頁執行

每一頁都必須經過：

1. **Step 1**：Android XML 事實盤點（完整節點清單）
2. **Step 2**：Flutter 現況逐項對照
3. **Step 3**：Parity Gate 判定
   - PASS
   - 或 BLOCKED（並說明原因）
4. **Step 4**：修正後重新 Gate

❌ 禁止跳步  
❌ 禁止「先做再說」

---

## 🛑 停工規則（非常重要）

### RULE 8 — 發現下列情況必須立即停工
- Android XML 不存在或不確定
- 指令描述與 Android XML 不一致
- 發現「疑似簡化 / 合併 / 推測行為」

必須：
- 明確回報
- 等待人類決策
- 不得自行選擇「比較合理的版本」

---

## 🧩 Edit / Add / Mode 規則

### RULE 9 — 無對應 Android XML，不得新增 Page
- Android 若無：
  - `activity_xxx_edit.xml`
- Flutter：
  - 不得建立 `xxx_edit_page.dart`
- Edit / Add 差異：
  - 僅能透過參數（mode / flag）
  - 不得新增 UI 結構

---

## 📌 結語

Parity ≠ UX 優化  
Parity ≠ Flutter 最佳實踐  

**Parity = Android XML 的忠實映射**

任何偏離，必須被標註、被審核、被決策。

---

## 📊 稽核狀態

### LED Module（已完成）
- ✅ LedSceneEditPage
- ✅ LedSceneAddPage
- ✅ LedRecordPage
- ✅ LedScenePage
- ✅ LedMainPage
- ✅ LedSceneDeletePage

所有頁面均已通過 Parity Gate，遵守本規則 100%。

---

END OF DOCUMENT

