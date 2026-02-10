# 全專案 UI 狀態模型對照表

## 1. 狀態模型定義

| 等級 | 定義 | 說明 |
|:---:|:---|:---|
| **[A]** | **Strict Parity** | 視覺、交互、資源完全對齊 Android XML/Style |
| **[B]** | **Functional Parity** | 功能一致，但視覺或實現方式有微小差異 (Workaround) |
| **[C]** | **Mismatch** | 顯著差異或使用 Flutter 原生預設值 |

---

## 2. 全域 UI 狀態對照 (Global UI States)

| 類別 | 項目 | Android 參考 | Flutter 實作 | Parity | 備註 |
|---|---|---|---|:---:|---|
| **Interaction** | **Button Disabled State** | `selector/btn_color_primary.xml` <br> `bg_aaa_60` (disabled) | `AppTheme.filledButtonTheme` <br> `disabledBackgroundColor: AppColors.surfaceMutedOverlay` | **[A]** | 已修正為 `bg_aaa_60` (0x99F7F7F7) |
| **Interaction** | **Global Busy / Blocking Overlay** | `layout/progress.xml` <br> Full screen, blocking, dim | `ReefBlockingOverlay` <br> `Stack` + `AbsorbPointer` (implicit) + Dimmer | **[A]** | 實作於 `ReefBlockingOverlay`，已在 `LedSceneListPage` 驗證 |
| **Feedback** | **Toast / SnackBar** | `Toast.makeText` | `ScaffoldMessenger.showSnackBar` | **[B]** | 位置與樣式略有不同，但功能對齊 |
| **Navigation** | **Page Transition** | Default Activity Transition | `MaterialPageRoute` (Platform default) | **[B]** | 使用平台預設動畫 |

---

## 3. 模組狀態對照 (Module States)

### 3.1 LED Module

| 頁面/功能 | 狀態項目 | Android 參考 | Flutter 實作 | Parity | 備註 |
|---|---|---|---|:---:|---|
| **Scene List** | **Busy State** | `progress.xml` overlay | `ReefBlockingOverlay` | **[A]** | 替代原有的 LinearProgressIndicator |
| **Scene List** | **Pull to Refresh** | `SwipeRefreshLayout` | `RefreshIndicator` | **[A]** | 行為一致 |
| **Connection** | **BLE Disconnected** | Disable interaction | `BleGuardBanner` + Disable buttons | **[B]** | Android 使用全頁遮罩或 Toast，Flutter 使用 Banner |

---

## 4. 結論與 Gate Review

### UI Parity Gate 狀態：PASS ✅

**通過條件核對**：
- [x] **Global Button Disabled parity completed**
  - 確認 `AppTheme` 中 `disabledBackgroundColor` 設定正確。
- [x] **Global Blocking Overlay implemented (progress.xml equivalent)**
  - 確認 `ReefBlockingOverlay` 實作完成並可阻擋互動。

**註記**：
- 相關變更已提交至 codebase。
- `LedSceneListPage` 已作為 Pilot Page 完成驗證。

**後續建議**：
- 將 `ReefBlockingOverlay` 推廣至其他 Feature Pages (Dosing, Settings 等)。
- 持續監控新的 UI 元件是否符合 [A] 級標準。
