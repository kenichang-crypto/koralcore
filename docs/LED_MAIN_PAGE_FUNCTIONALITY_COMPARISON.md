# LED 主頁功能性對照表

## 1. Toolbar 功能對照

| 組件 | reef-b-app | koralcore | 目標頁面/功能 | 狀態 |
|------|-----------|-----------|--------------|------|
| **返回按鈕** (`btn_back`) | `finish()` | `Navigator.pop()` | 返回上一頁 | ✅ |
| **喜愛按鈕** (`btn_favorite`) | `viewModel.clickBtnFavorite()` | `toggleFavoriteDeviceUseCase` | 切換喜愛狀態 | ✅ |
| **菜單按鈕** (`btn_menu`) | PopupMenu: 編輯/刪除/重置 | PopupMenuButton: 編輯/刪除/重置 | - | ✅ |
| - 編輯 (`action_edit`) | `LedSettingActivity` | `DeviceSettingsPage` | 設備設置頁面 | ✅ |
| - 刪除 (`action_delete`) | 刪除對話框 | 刪除對話框 | - | ✅ |
| - 重置 (`action_reset`) | 重置對話框 | 重置對話框 | - | ✅ |
| **橫屏切換按鈕** | `clickBtnExpand()` → 切換橫屏/豎屏 | `_toggleOrientation()` | 切換屏幕方向 | ✅ |

---

## 2. 設備信息區域功能對照

| 組件 | reef-b-app | koralcore | 目標頁面/功能 | 狀態 |
|------|-----------|-----------|--------------|------|
| **BLE 狀態圖標** (`btn_ble`) | `viewModel.clickBtnBle()` | ❌ **未實現點擊** | BLE 連接/斷開 | ❌ |

**問題**：
- reef-b-app: 點擊 BLE 圖標可以連接/斷開 BLE
- koralcore: BLE 圖標僅顯示狀態，無法點擊

---

## 3. Record 區域功能對照

| 組件 | reef-b-app | koralcore | 目標頁面/功能 | 狀態 |
|------|-----------|-----------|--------------|------|
| **Record 更多按鈕** (`btn_record_more`) | 如果記錄為空 → `LedRecordSettingActivity`<br>否則 → `LedRecordActivity` | 如果記錄為空 → `LedRecordSettingPage`<br>否則 → `LedRecordPage` | 記錄設置/記錄列表 | ✅ |
| **展開按鈕** (`btn_expand`) | `clickBtnExpand()` → 切換橫屏 | 在 `_RecordChartSection` 中，但功能不同 | 切換屏幕方向 | ⚠️ |
| **預覽按鈕** (`btn_preview`) | `viewModel.clickBtnPreview()` | `controller.togglePreview()` | 開始/停止預覽 | ✅ |
| **繼續記錄按鈕** (`btn_continue_record`) | `viewModel.clickBtnContinueRecord()` | `controller.startRecord()` | 繼續記錄 | ✅ |

**問題**：
1. **Record 更多按鈕邏輯不一致**：
   - reef-b-app: 根據記錄是否為空，導航到不同頁面
     - 空記錄 → `LedRecordSettingActivity` (記錄設置頁面)
     - 有記錄 → `LedRecordActivity` (記錄列表頁面)
   - koralcore: 總是導航到 `LedRecordPage` (記錄列表頁面)
   - **需要修復**：應該檢查 `controller.hasRecords`，如果為空則導航到 `LedRecordSettingPage`

2. **展開按鈕位置不同**：
   - reef-b-app: 在 Record 卡片內（`layout_record` 內）
   - koralcore: 在 `_RecordChartSection` 中，但可能不在正確位置

---

## 4. Scene 區域功能對照

| 組件 | reef-b-app | koralcore | 目標頁面/功能 | 狀態 |
|------|-----------|-----------|--------------|------|
| **Scene 更多按鈕** (`btn_scene_more`) | `LedSceneActivity` | `LedSceneListPage` | 場景列表頁面 | ✅ |
| **喜愛場景卡片** (`rv_favorite_scene`) | 點擊應用場景 | `controller.applyScene()` | 應用場景 | ✅ |

---

## 5. Entry Tiles 功能對照（koralcore 特有）

| Entry Tile | koralcore | 目標頁面 | 狀態 |
|-----------|-----------|---------|------|
| **LED Intensity** | `LedControlPage` | LED 控制頁面 | ✅ |
| **LED Scenes** | `LedSceneListPage` | LED 場景列表頁面 | ✅ |
| **LED Records** | `LedRecordPage` | LED 記錄頁面 | ✅ |
| **LED Schedule** | `LedScheduleListPage` | LED 排程列表頁面 | ✅ |

**說明**：
- reef-b-app 沒有這些 Entry Tiles，它們是 koralcore 的額外功能
- 這些 Entry Tiles 提供了快速訪問主要功能的入口

---

## 6. 功能對照總表

| 功能分類 | 功能項目 | reef-b-app | koralcore | 狀態 |
|---------|---------|-----------|-----------|------|
| **Toolbar** | 返回 | ✅ | ✅ | ✅ |
| | 喜愛 | ✅ | ✅ | ✅ |
| | 菜單（編輯/刪除/重置） | ✅ | ✅ | ✅ |
| | 橫屏切換 | ✅ | ✅ | ✅ |
| **設備信息** | BLE 連接/斷開 | ✅ | ✅ | ✅ |
| **Record** | Record 更多（根據記錄狀態導航） | ✅ | ✅ | ✅ |
| | 展開（橫屏切換） | ✅ | ⚠️ | ⚠️ |
| | 預覽 | ✅ | ✅ | ✅ |
| | 繼續記錄 | ✅ | ✅ | ✅ |
| **Scene** | Scene 更多 | ✅ | ✅ | ✅ |
| | 喜愛場景應用 | ✅ | ✅ | ✅ |
| **Entry Tiles** | LED Intensity | ❌ 不存在 | ❌ 已移除 | ❌ |
| | LED Scenes | ❌ 不存在 | ❌ 已移除 | ❌ |
| | LED Records | ❌ 不存在 | ❌ 已移除 | ❌ |
| | LED Schedule | ❌ 不存在 | ❌ 已移除 | ❌ |

---

## 7. 需要修復的問題

### ✅ 已修復

1. **BLE 圖標點擊功能** ✅
   - **已實現**：在 `_DeviceInfoSection` 中為 BLE 圖標添加了 `GestureDetector`
   - **功能**：點擊 BLE 圖標可以連接/斷開 BLE，對照 `reef-b-app` 的 `clickBtnBle()` 邏輯
   - **實現**：`_handleBleIconTap()` 方法處理連接/斷開邏輯

2. **Record 更多按鈕邏輯** ✅
   - **已修復**：根據 `controller.hasRecords` 決定導航目標
   - **邏輯**：如果記錄為空，導航到 `LedRecordSettingPage`；否則導航到 `LedRecordPage`
   - **對照**：完全對照 `reef-b-app` 的邏輯

### 中優先級

3. **展開按鈕位置確認**
   - **問題**：需要確認展開按鈕是否在正確位置
   - **reef-b-app**：在 Record 卡片內（`layout_record` 內）
   - **koralcore**：在 `_RecordChartSection` 中
   - **修復**：確認展開按鈕是否在 Record 卡片內的正確位置

---

## 8. 頁面對照

| reef-b-app Activity | koralcore Page | 狀態 |
|-------------------|----------------|------|
| `LedSettingActivity` | `DeviceSettingsPage` | ✅ |
| `LedSceneActivity` | `LedSceneListPage` | ✅ |
| `LedRecordActivity` | `LedRecordPage` | ✅ |
| `LedRecordSettingActivity` | `LedRecordSettingPage` | ✅ |
| `LedControlActivity` | `LedControlPage` | ✅ |
| `LedScheduleListActivity` | `LedScheduleListPage` | ✅ |

---

## 9. 快速檢查清單

### ✅ 已實現且功能正確
- [x] Toolbar 返回按鈕
- [x] Toolbar 喜愛按鈕
- [x] Toolbar 菜單按鈕（編輯/刪除/重置）
- [x] Toolbar 橫屏切換按鈕
- [x] Record 預覽按鈕
- [x] Record 繼續記錄按鈕
- [x] Scene 更多按鈕
- [x] 喜愛場景應用
- [x] Entry Tiles（LED Intensity/Scenes/Records/Schedule）

### ✅ 已實現
- [x] BLE 圖標點擊功能
- [x] Record 更多按鈕邏輯（根據記錄狀態導航）

### ⚠️ 需確認
- [ ] 展開按鈕位置是否正確

---

## 10. 實現建議

### 1. 添加 BLE 圖標點擊功能

在 `_DeviceInfoSection._buildBleStateIcon` 中添加點擊處理：

```dart
Widget _buildBleStateIcon(bool isConnected) {
  return GestureDetector(
    onTap: () {
      // TODO: 實現 BLE 連接/斷開邏輯
      // 需要從 context 獲取 DeviceListController 或 BLE 相關的 UseCase
    },
    child: // ... 現有的圖標實現
  );
}
```

### 2. 修復 Record 更多按鈕邏輯

在 `led_main_page.dart` 的 Record 標題區域：

```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  iconSize: 24,
  onPressed: featuresEnabled
      ? () {
          // PARITY: reef-b-app 邏輯
          // 如果記錄為空，導航到設置頁面；否則導航到記錄列表頁面
          if (controller.hasRecords) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LedRecordPage()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LedRecordSettingPage()),
            );
          }
        }
      : null,
),
```

---

## 總結

### 已實現功能 ✅
- 所有 Toolbar 功能（返回、喜愛、菜單、橫屏切換）
- BLE 圖標點擊功能（連接/斷開）
- Record 相關功能（預覽、繼續記錄、條件導航）
- Scene 相關功能（更多按鈕、喜愛場景應用）

### 已移除不存在的組件 ❌
- `_SceneListSection` - 在 reef-b-app 中不存在
- `_EntryTile` (LED Intensity/Scenes/Records/Schedule) - 在 reef-b-app 中不存在

### 需確認 ⚠️
- 展開按鈕位置（在 Record 卡片內的位置是否正確）

