# Phase 3: 背景統一化計劃

## 目標

將所有主要頁面的背景統一為使用 `ReefMainBackground`，以匹配 `reef-b-app` 的設計（淺色漸變背景 #EFEFEF → 透明）。

---

## 當前狀態

### ✅ 已使用 ReefMainBackground 的頁面
- `home/home_page.dart` - ✅ 已使用

### ❌ 需要更新的頁面

根據 `reef-b-app` 的設計，以下主要頁面應該使用 `ReefMainBackground`：

1. **Bluetooth 頁面** (`bluetooth/bluetooth_page.dart`)
2. **Device 頁面** (`device/device_page.dart`)
3. **LED 主頁** (`led/pages/led_main_page.dart`)
4. **Dosing 主頁** (`dosing/pages/dosing_main_page.dart`)
5. **Sink Manager 頁面** (`sink/pages/sink_manager_page.dart`)
6. **Warning 頁面** (`warning/pages/warning_page.dart`)

其他子頁面（如設置頁面、編輯頁面）可以使用 `backgroundColor: ReefColors.surfaceMuted`。

---

## 實現步驟

### Step 1: 檢查當前背景使用情況

對每個頁面檢查：
- [ ] 是否使用 `backgroundColor`？
- [ ] 使用的顏色是什麼？
- [ ] 是否應該改為 `ReefMainBackground`？

### Step 2: 更新主要頁面背景

對每個主要頁面：
1. 移除 `Scaffold` 的 `backgroundColor` 參數
2. 用 `ReefMainBackground` 包裹 `body`
3. 確保 `SafeArea` 正確使用

### Step 3: 調整 AppBar 樣式

- [ ] 確認 AppBar 在淺色背景上顯示正確
- [ ] 調整 AppBar 的 `backgroundColor` 和 `foregroundColor`（如果需要）
- [ ] 確認 AppBar 的 `elevation` 設置正確

### Step 4: 檢查子頁面

對於子頁面（設置、編輯等）：
- [ ] 確認使用 `backgroundColor: ReefColors.surfaceMuted`（如果合適）
- [ ] 或者使用 `ReefMainBackground`（如果需要）

---

## 實現模式

### 主要頁面模式（使用 ReefMainBackground）

```dart
Scaffold(
  appBar: AppBar(...),
  body: ReefMainBackground(
    child: SafeArea(
      child: ListView(...),
    ),
  ),
)
```

### 子頁面模式（使用淺色背景）

```dart
Scaffold(
  backgroundColor: ReefColors.surfaceMuted,
  appBar: AppBar(...),
  body: SafeArea(...),
)
```

---

## 預期效果

所有主要頁面將具有統一的淺色漸變背景，與 `reef-b-app` 的設計完全一致。

