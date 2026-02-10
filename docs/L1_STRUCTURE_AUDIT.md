# L1｜UI 結構層（Layout / Structure）檢查報告

**執行日期**: 2026-01-03  
**檢查範圍**: Dosing 模組 9 個頁面  
**檢查重點**:
1. Root 結構（ConstraintLayout vs Column）
2. Scroll 結構（只有 list scroll？還是整頁 scroll？）
3. 區塊順序（Toolbar, 狀態區, 主功能區, 底部 action）
4. 常見錯誤：Android 固定 header + RecyclerView vs Flutter 整頁 ListView

---

## 📊 檢查總結

| # | 頁面 | Android Scroll | Flutter Scroll | 結構對齊 | 狀態 |
|---|------|---------------|---------------|---------|------|
| 1 | DosingMainPage | **整頁 ScrollView** | **整頁 SingleChildScrollView** | 100% | ✅ |
| 2 | DropSettingPage | **不可捲動** (固定高度) | **Expanded + Column** (固定高度) | 100% | ✅ |
| 3 | PumpHeadDetailPage | **不可捲動** (固定高度) | **SingleChildScrollView** (實用妥協) | 95% | ⚠️ |
| 4 | PumpHeadSettingsPage | **不可捲動** (固定高度) | **Expanded + Column** (固定高度) | 100% | ✅ |
| 5 | DropTypePage | **不可捲動** (RecyclerView only) | **Expanded + ListView** | 100% | ✅ |
| 6 | PumpHeadRecordSettingPage | **整頁 ScrollView** | **整頁 SingleChildScrollView** | 100% | ✅ |
| 7 | PumpHeadRecordTimeSettingPage | **不可捲動** (固定高度) | **Expanded + Column** (固定高度) | 100% | ✅ |
| 8 | PumpHeadAdjustListPage | **不可捲動** (RecyclerView only) | **Expanded + ListView** | 100% | ✅ |
| 9 | PumpHeadCalibrationPage | **不可捲動** (固定高度) | **Expanded + Column** (固定高度) | 100% | ✅ |

**總結**: 9 個頁面中，**8 個 100% 對齊**，**1 個實用妥協（95%）**。

---

## 📋 詳細檢查報告

### 1️⃣ DosingMainPage (DropMainActivity)

**Android XML 結構** (`activity_drop_main.xml`):
```
ConstraintLayout (bg_aaa)
├─ Toolbar (toolbar_device, 固定)
├─ ScrollView (整頁可捲動, layout_height="0dp")
│  └─ ConstraintLayout (wrap_content)
│     ├─ layout_device (設備識別區)
│     └─ RecyclerView (泵頭列表)
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarDevice (固定)
   │  └─ Expanded(SingleChildScrollView( // 整頁可捲動
   │       Column(
   │         ├─ _DeviceIdentificationSection
   │         └─ DosingMainPumpHeadList
   │       )
   │     ))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**整頁 ScrollView** ↔ **整頁 SingleChildScrollView**
- ✅ 區塊順序：Toolbar → Device Section → List → Overlay
- ✅ 無常見錯誤（不是固定 header + 整頁 ListView）

---

### 2️⃣ DropSettingPage (DropSettingActivity)

**Android XML 結構** (`activity_drop_setting.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ ConstraintLayout (Main Content, layout_height="0dp", 固定高度，不可捲動)
│  ├─ Device Name (TextView + TextInputLayout)
│  ├─ Sink Position (TextView + MaterialButton)
│  └─ Delay Time (TextView + MaterialButton)
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(Padding(Column( // 固定高度，不可捲動
   │       ├─ Device Name Section
   │       ├─ Sink Position Section
   │       └─ Delay Time Section
   │     )))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**不可捲動** ↔ **Expanded + Column（無 ScrollView）**
- ✅ 區塊順序：Toolbar → Form Sections → Overlay
- ✅ 完美對齊 Android 固定高度設計

---

### 3️⃣ PumpHeadDetailPage (DropHeadMainActivity)

**Android XML 結構** (`activity_drop_head_main.xml`):
```
ConstraintLayout (bg_aaa)
├─ Toolbar (toolbar_device, 固定)
├─ ConstraintLayout (Main Content, layout_height="0dp", 固定高度，不可捲動)
│  ├─ Drop Head Info Card (CardView)
│  ├─ Record Section (Title + Button + CardView)
│  └─ Adjust Section (Title + Button + CardView)
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarDevice (固定)
   │  └─ Expanded(SingleChildScrollView( // ⚠️ 實用妥協
   │       Padding(Column(
   │         ├─ _DropHeadInfoCard
   │         ├─ Record Section
   │         └─ Adjust Section
   │       ))
   │     ))
   └─ _ProgressOverlay
```

**⚠️ L1 結構對齊度：95%（實用妥協）**
- ⚠️ Scroll 範圍：**不可捲動** ↔ **SingleChildScrollView**
- ✅ 區塊順序：Toolbar → Cards → Overlay
- **說明**: Android 為固定高度，但內容過多時會被裁切。Flutter 使用 `SingleChildScrollView` 確保所有內容可見，這是一個**實用性妥協**（已在代碼註釋說明）。

---

### 4️⃣ PumpHeadSettingsPage (DropHeadSettingActivity)

**Android XML 結構** (`activity_drop_head_setting.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ ConstraintLayout (Main Content, layout_height="0dp", 固定高度，不可捲動)
│  ├─ Drop Type Section (visibility部分gone)
│  ├─ Max Drop Section (visibility=gone)
│  └─ Rotating Speed Section
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(Padding(Column( // 固定高度，不可捲動
   │       ├─ Drop Type Section
   │       ├─ Max Drop Section (Visibility gone)
   │       └─ Rotating Speed Section
   │     )))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**不可捲動** ↔ **Expanded + Column（無 ScrollView）**
- ✅ 區塊順序：Toolbar → Form Sections → Overlay

---

### 5️⃣ DropTypePage (DropTypeActivity)

**Android XML 結構** (`activity_drop_type.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ RecyclerView (rv_drop_type, layout_height="0dp", 只有列表可捲動)
├─ FAB (fab_add_drop_type, 固定右下角)
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(ListView( // 只有列表可捲動
   │       itemBuilder: ...
   │     ))
   ├─ Positioned(FAB) (右下角)
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**RecyclerView only** ↔ **Expanded + ListView**
- ✅ 區塊順序：Toolbar → List → FAB (fixed) → Overlay
- ✅ 完美對齊：固定 Toolbar + 可捲動 List + 固定 FAB

---

### 6️⃣ PumpHeadRecordSettingPage (DropHeadRecordSettingActivity)

**Android XML 結構** (`activity_drop_head_record_setting.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ ScrollView (整頁可捲動, layout_height="0dp")
│  └─ ConstraintLayout (wrap_content)
│     ├─ Drop Type Info Card
│     ├─ Record Type Section
│     ├─ Volume Section (with RecyclerView)
│     └─ Run Time Section
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(SingleChildScrollView( // 整頁可捲動
   │       Column(
   │         ├─ _DropTypeInfoCard
   │         ├─ _RecordTypeSection
   │         ├─ _VolumeSection
   │         └─ _RunTimeSection
   │       )
   │     ))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**整頁 ScrollView** ↔ **整頁 SingleChildScrollView**
- ✅ 區塊順序：Toolbar → Form Sections → Overlay

---

### 7️⃣ PumpHeadRecordTimeSettingPage (DropHeadRecordTimeSettingActivity)

**Android XML 結構** (`activity_drop_head_record_time_setting.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ ConstraintLayout (Main Content, layout_height="0dp", 固定高度，不可捲動)
│  ├─ Start Time Section
│  ├─ End Time Section
│  ├─ Drop Times Section
│  ├─ Drop Volume Section
│  └─ Rotating Speed Section
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(Padding(Column( // 固定高度，不可捲動
   │       ├─ Start Time Section
   │       ├─ End Time Section
   │       ├─ Drop Times Section
   │       ├─ Drop Volume Section
   │       └─ Rotating Speed Section
   │     )))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**不可捲動** ↔ **Expanded + Column（無 ScrollView）**
- ✅ 區塊順序：Toolbar → Form Sections → Overlay

---

### 8️⃣ PumpHeadAdjustListPage (DropHeadAdjustListActivity)

**Android XML 結構** (`activity_drop_head_adjust_list.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ RecyclerView (rv_adjust, layout_height="0dp", 只有列表可捲動)
└─ Progress (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(ListView( // 只有列表可捲動
   │       itemBuilder: ...
   │     ))
   └─ _ProgressOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**RecyclerView only** ↔ **Expanded + ListView**
- ✅ 區塊順序：Toolbar → List → Overlay

---

### 9️⃣ PumpHeadCalibrationPage (DropHeadAdjustActivity)

**Android XML 結構** (`activity_drop_head_adjust.xml`):
```
ConstraintLayout
├─ Toolbar (toolbar_two_action, 固定)
├─ ConstraintLayout (Main Content, layout_height="0dp", 固定高度，不可捲動)
│  ├─ Description + Step (說明文字)
│  ├─ Rotating Speed Section
│  ├─ Drop Volume Section (visibility=gone)
│  ├─ img_adjust (調整圖片, Expanded)
│  └─ Bottom Buttons (Prev + Next + Complete)
└─ Progress + Loading (Overlay, visibility=gone)
```

**Flutter 實作**:
```dart
Scaffold
└─ Stack
   ├─ Column
   │  ├─ _ToolbarTwoAction (固定)
   │  └─ Expanded(Padding(Column( // 固定高度，不可捲動
   │       ├─ Description + Step
   │       ├─ Rotating Speed Section
   │       ├─ Drop Volume Section (Visibility gone)
   │       ├─ Expanded(Image) (調整圖片)
   │       └─ Bottom Buttons
   │     )))
   ├─ _ProgressOverlay
   └─ _LoadingOverlay
```

**✅ L1 結構對齊度：100%**
- ✅ Scroll 範圍：**不可捲動** ↔ **Expanded + Column（無 ScrollView）**
- ✅ 區塊順序：Toolbar → Content → Buttons → Overlays

---

## 🎯 總結與建議

### ✅ 做得好的地方

1. **Root 結構正確**: 所有頁面都使用 `Stack > Column` 正確對應 Android `ConstraintLayout`
2. **Scroll 範圍精準**: 8/9 頁面完全對齊 Android scroll 行為
3. **區塊順序一致**: 所有頁面的 Toolbar, Content, Overlay 順序都與 Android 一致
4. **無常見錯誤**: 沒有出現 "固定 header + 整頁 ListView" 的經典錯誤

### ⚠️ 需要注意的地方

**PumpHeadDetailPage (DropHeadMainActivity)** - 實用妥協:
- Android: 固定高度（內容過多會被裁切）
- Flutter: `SingleChildScrollView`（確保內容可見）
- **建議**: 這是一個**合理的實用妥協**。Android 的固定高度設計在實際使用中可能導致內容被裁切，Flutter 的可捲動設計更符合實際需求。如需嚴格 100% Parity，可移除 `SingleChildScrollView`，但要接受內容可能被裁切的風險。

### 📊 L1 結構對齊統計

| 結構項目 | 對齊率 |
|---------|-------|
| Root 結構 (Stack/Column vs ConstraintLayout) | 100% (9/9) |
| Toolbar 位置 (固定 vs 可捲動) | 100% (9/9) |
| Scroll 範圍 (整頁 vs 局部 vs 不可捲) | 89% (8/9) |
| 區塊順序 (Toolbar, Content, Overlay) | 100% (9/9) |
| **總體 L1 結構對齊度** | **97%** |

---

## 📝 檢查清單（給未來參考）

在檢查頁面 L1 結構時，請依序確認：

### 1. Root 結構
- [ ] Flutter 是否使用 `Scaffold > Stack > Column`？
- [ ] 是否正確對應 Android `ConstraintLayout`？
- [ ] 是否有不必要的 flatten（簡化成單一 Column）？

### 2. Scroll 範圍
- [ ] Android 是整頁 ScrollView？還是只有 RecyclerView 可捲？還是不可捲？
- [ ] Flutter 的 `SingleChildScrollView` / `ListView` 範圍是否對應？
- [ ] 固定元素（Toolbar, FAB, Overlay）是否在 Scroll 區域外？

### 3. 區塊順序
- [ ] Toolbar 是否固定在最上方？
- [ ] 主功能區（List, Form）是否在中間？
- [ ] Overlay（Progress, Loading, Dialog）是否在最上層？

### 4. 常見錯誤
- [ ] 是否有 "固定 header + 整頁 ListView"（應該是 "固定 header + Expanded(ListView)"）？
- [ ] 是否有 Android 固定高度，Flutter 卻用 ScrollView（反之亦然）？
- [ ] RecyclerView 是否正確對應到 `Expanded(ListView)` 而非 `SingleChildScrollView(ListView)`？

---

## 🎉 結論

**Dosing 模組的 L1 結構層檢查完成！**

- ✅ **9 個頁面中，8 個 100% 對齊，1 個實用妥協（95%）**
- ✅ **總體 L1 結構對齊度：97%**
- ✅ **無重大結構性錯誤**
- ✅ **所有頁面都正確區分了 "固定區域" vs "可捲動區域"**

可以繼續進行 **L2｜組件層** 檢查。

---

**檢查完成日期**: 2026-01-03
