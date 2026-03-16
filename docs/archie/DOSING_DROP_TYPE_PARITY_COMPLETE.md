# ✅ Dosing DropTypePage Parity 完成報告

**執行日期**: 2026-01-03  
**模式**: 路徑 B：完全 Parity 化  
**對應 Android**: `DropTypeActivity` → `activity_drop_type.xml`

---

## 📋 修改範圍

本次修改**僅限於以下檔案**：

1. ✅ `lib/features/doser/presentation/pages/drop_type_page.dart`

**嚴格遵守**：
- ✅ 不修改其他 Page / Widget / Controller / Domain / Data
- ✅ 不修改 Theme / l10n / Shared 元件

---

## 🚨 移除的非 Parity 元素（路徑 B）

### 1. 移除所有業務邏輯
- ❌ `ChangeNotifierProvider<DropTypeController>`
- ❌ `DropTypeController` 依賴注入
- ❌ `AppContext`, `AppSession` 依賴
- ❌ `_DropTypeViewState` (StatefulWidget → StatelessWidget)
- ❌ `_selectedId` state 管理
- ❌ `controller.isLoading` / `controller.dropTypes`
- ❌ `controller.addDropType()` / `editDropType()` / `deleteDropType()`
- ❌ `controller.isDropTypeUsed()`
- ❌ `_maybeShowError()` 錯誤處理

### 2. 移除所有互動邏輯
- ❌ `_showAddDropTypeDialog()`
- ❌ `_showEditDropTypeDialog()`
- ❌ `_showDeleteDropTypeDialog()`
- ❌ `onTap` / `onLongPress` 事件處理
- ❌ `Radio.onChanged` 選擇邏輯
- ❌ `Navigator.of(context).pop(_selectedId)` 回傳邏輯

### 3. 移除非 Android 元件
- ❌ `ReefAppBar` (改用 `_ToolbarTwoAction`)
- ❌ `BleGuardBanner` (Android 無此)

---

## ✅ 新增的 Android 對應元素

### 1. Toolbar Parity
- ✅ `_ToolbarTwoAction`: 精確對應 `toolbar_two_action.xml`
  - Left: `btn_back` (ic_close)
  - Title: `activity_drop_type_title`
  - Right: `btn_right` (activity_sink_position_toolbar_right_btn = "完成")

### 2. RecyclerView Parity
- ✅ `ListView` (對應 `rv_drop_type`)
  - `layout_height="0dp"` → `Expanded`
  - `padding: EdgeInsets.zero`

### 3. Adapter Item Parity
- ✅ `_DropTypeItem`: 精確對應 `adapter_drop_type.xml`
  - `RadioButton`
  - `tv_name` (body, text_aaaa)
  - `btn_edit` (24x24dp, 僅對非「無」項目顯示)
  - `Divider` (bg_press)
  - Padding: `16/0/16/0dp`

### 4. FloatingActionButton Parity
- ✅ 固定於右下角 (`Positioned`)
- ✅ Margin: `16dp`
- ✅ Icon: `ic_add_white`

### 5. Progress Overlay Parity
- ✅ `_ProgressOverlay`: 對應 `include progress`
  - `visibility="gone"` → `visible: false`
  - Full-screen overlay

---

## 🎯 結構變更（100% 對齊 Android）

### Android XML 結構
```
Root: ConstraintLayout
├─ toolbar_two_action (固定於頂部)
├─ RecyclerView: rv_drop_type (layout_height="0dp", 填滿剩餘空間)
├─ FloatingActionButton: fab_add_drop_type (固定右下)
└─ Progress: include progress (visibility="gone")
```

### Flutter 實作結構
```dart
Scaffold(
  body: Stack(
    children: [
      Column(
        children: [
          _ToolbarTwoAction(),        // toolbar_two_action
          Expanded(
            child: ListView(...),     // rv_drop_type
          ),
        ],
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton(...), // fab_add_drop_type
      ),
      _ProgressOverlay(visible: false),   // progress (visibility=gone)
    ],
  ),
)
```

---

## 🔒 禁用所有互動（Parity Mode）

### 1. 所有按鈕 onPressed = null
- ✅ `btn_back` (Toolbar close button)
- ✅ `btn_right` (Toolbar "完成" button)
- ✅ `fab_add_drop_type` (FloatingActionButton)
- ✅ `btn_edit` (每個 item 的編輯按鈕)
- ✅ `Radio.onChanged` = null

### 2. 所有手勢禁用
- ✅ `InkWell.onTap` = null
- ✅ `InkWell.onLongPress` = null

### 3. 無 State / Controller
- ✅ 改為 `StatelessWidget`
- ✅ 移除所有 `ChangeNotifierProvider`
- ✅ 移除所有 `context.watch<...>()`

---

## 📊 UI 細節對齊

### Toolbar (`_ToolbarTwoAction`)
| Android XML | Flutter 實作 |
|------------|-------------|
| `toolbar_two_action` | `_ToolbarTwoAction` |
| `btn_back` (ic_close) | `CommonIconHelper.getCloseIcon()` |
| `toolbar_title` (center) | `Text(..., textAlign: TextAlign.center)` |
| `btn_right` ("完成") | `TextButton(onPressed: null)` |
| Primary color | `AppColors.primary` |

### RecyclerView Item (`_DropTypeItem`)
| Android XML | Flutter 實作 | 行號 |
|------------|-------------|------|
| ConstraintLayout | `InkWell > Column` | - |
| padding 16/0/16/0 | `padding: EdgeInsets.symmetric(horizontal: 16)` | - |
| RadioButton | `Radio<bool>(onChanged: null)` | - |
| tv_name (body, text_aaaa) | `Text(..., style: AppTextStyles.body)` | - |
| btn_edit (24x24, optional) | `IconButton(..., constraints: BoxConstraints(24, 24))` | - |
| Divider (bg_press) | `Divider(color: AppColors.surfacePressed)` | - |

### FloatingActionButton
| Android XML | Flutter 實作 |
|------------|-------------|
| layout_margin 16dp | `Positioned(right: 16, bottom: 16)` |
| src ic_add_white | `CommonIconHelper.getAddIcon()` |
| onPressed | `null` (disabled) |

### Progress Overlay
| Android XML | Flutter 實作 |
|------------|-------------|
| visibility="gone" | `Visibility(visible: false)` |
| match_parent | `Container(full screen)` |
| CircularProgressIndicator | `const CircularProgressIndicator()` |

---

## 🧪 Linter 檢查

```bash
flutter analyze lib/features/doser/presentation/pages/drop_type_page.dart
```

**結果**: ✅ No linter errors found.

---

## 📝 TODO 標註

所有缺少的 Android 字串資源已標註：

1. ✅ `TODO(android @string/no)`
2. ✅ `TODO(android @string/activity_drop_type_title)`
3. ✅ `TODO(android @string/activity_sink_position_toolbar_right_btn)`

---

## ✅ Gate 條件確認

根據 `docs/MANDATORY_PARITY_RULES.md` 檢查：

| Gate 條件 | 狀態 |
|----------|------|
| RULE 0: XML 為唯一事實來源 | ✅ 完全遵守 `activity_drop_type.xml` |
| RULE 1: 1:1 節點映射 | ✅ Toolbar / RecyclerView / FAB / Progress 完全對應 |
| RULE 2: 捲動行為對齊 | ✅ 僅 RecyclerView 可捲動 |
| RULE 3: visibility 語意對齊 | ✅ `visibility="gone"` → `visible: false` |
| RULE 4: 禁止業務邏輯 | ✅ 所有 Controller / State / Dialog 已移除 |
| RULE 5: 視覺對齊 | ✅ padding / margin / size 精確對齊 |

---

## 📦 產出文件

- ✅ `lib/features/doser/presentation/pages/drop_type_page.dart` (路徑 B 完成)
- ✅ `docs/DOSING_DROP_TYPE_PARITY_COMPLETE.md` (本報告)

---

## 🎉 結論

**DropTypePage 已 100% 對齊 Android `activity_drop_type.xml`**。

- ✅ 路徑 B：完全 Parity 化
- ✅ 移除所有業務邏輯與 State
- ✅ 改為 StatelessWidget (pure)
- ✅ UI 結構 100% 對齊 Android XML
- ✅ 所有互動設為 null/disabled
- ✅ 無 linter 錯誤
- ✅ 符合 `docs/MANDATORY_PARITY_RULES.md`

---

## 📌 後續建議

若需處理其他 Dosing 頁面，建議依照相同流程：
1. 稽核 Android XML / Activity
2. 移除所有業務邏輯（路徑 B）
3. 精確對齊 UI 結構
4. 產出完成報告

