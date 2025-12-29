# Phase 4: 子頁面精細化計劃

## 目標

檢查並調整所有子頁面（設置頁面、編輯頁面等）的背景和樣式，確保它們也遵循 `reef-b-app` 的設計規範。

---

## 當前狀態

### ✅ 已完成的主要頁面

1. ✅ Home 頁面
2. ✅ Device 頁面
3. ✅ Bluetooth 頁面
4. ✅ LED 主頁
5. ✅ Dosing 主頁

### ⏳ 需要檢查的子頁面

根據 `reef-b-app` 的設計，子頁面（設置、編輯等）通常可以使用：
- `ReefMainBackground`（如果是主要功能頁面）
- `backgroundColor: ReefColors.surfaceMuted`（如果是設置/編輯頁面）

需要檢查的頁面類型：
1. **設置頁面**（Device Settings, LED Settings, Dosing Settings 等）
2. **編輯頁面**（Scene Edit, Schedule Edit, Record Edit 等）
3. **列表頁面**（Scene List, Schedule List, Record List 等）
4. **其他功能頁面**（Warning, Sink Manager, Sink Position 等）

---

## 實現步驟

### Step 1: 檢查子頁面背景使用情況

對每個子頁面檢查：
- [ ] 是否使用 `backgroundColor`？
- [ ] 使用的顏色是什麼？
- [ ] 是否應該改為 `ReefMainBackground` 或 `surfaceMuted`？

### Step 2: 更新子頁面背景

根據頁面類型決定使用：
- **主要功能頁面**（如 Scene List, Schedule List）→ 使用 `ReefMainBackground`
- **設置/編輯頁面**（如 Device Settings, Scene Edit）→ 使用 `backgroundColor: ReefColors.surfaceMuted`

### Step 3: 檢查文字顏色

- [ ] 確認所有文字顏色適配當前背景
- [ ] 修復任何在淺色背景上不可見的文字

### Step 4: 最終驗證

- [ ] 檢查所有頁面的視覺一致性
- [ ] 確認沒有編譯錯誤
- [ ] 確認所有組件正確使用 Theme

---

## 實現模式

### 主要功能子頁面（使用 ReefMainBackground）

```dart
Scaffold(
  appBar: AppBar(
    backgroundColor: ReefColors.primary,
    foregroundColor: ReefColors.onPrimary,
    elevation: 0,
    // ...
  ),
  body: ReefMainBackground(
    child: SafeArea(...),
  ),
)
```

### 設置/編輯子頁面（使用淺色背景）

```dart
Scaffold(
  backgroundColor: ReefColors.surfaceMuted,
  appBar: AppBar(
    backgroundColor: ReefColors.primary,
    foregroundColor: ReefColors.onPrimary,
    elevation: 0,
    // ...
  ),
  body: SafeArea(...),
)
```

---

## 預期效果

所有子頁面將具有統一且符合 `reef-b-app` 設計規範的背景和樣式。

