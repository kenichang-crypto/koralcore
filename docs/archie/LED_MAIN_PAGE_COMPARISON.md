# LED 操作主頁對照分析

## 1. 整體布局結構

### reef-b-app: `activity_led_main.xml`

```
ConstraintLayout (根容器)
├── include toolbar_device (toolbar_led_main)
├── TextView (tv_name) - 設備名稱
├── ImageView (btn_ble) - BLE 連接狀態圖標
├── TextView (tv_position) - 位置信息
├── TextView (tv_group) - 群組信息（可隱藏）
├── TextView (tv_record_title) - "Record" 標題
├── ImageView (btn_record_more) - Record 更多按鈕
├── CardView (layout_record_background) - Record 卡片
│   ├── TextView (tv_record_state) - 未連接狀態提示
│   └── ConstraintLayout (layout_record) - Record 內容
│       ├── LineChart (line_chart) - 圖表
│       ├── ImageView (btn_expand) - 展開按鈕（橫屏切換）
│       ├── ImageView (btn_preview) - 預覽按鈕
│       └── ConstraintLayout (layout_record_pause) - 暫停覆蓋層
│           └── MaterialButton (btn_continue_record) - 繼續記錄按鈕
├── TextView (tv_scene_title) - "LED Scene" 標題
├── ImageView (btn_scene_more) - Scene 更多按鈕
├── RecyclerView (rv_favorite_scene) - 喜愛場景列表
└── include progress - 加載指示器
```

### koralcore: `led_main_page.dart`

```
Scaffold
├── ReefAppBar (AppBar)
│   ├── leading (返回按鈕)
│   ├── title (設備名稱)
│   └── actions (喜愛、展開、菜單按鈕)
└── ReefMainBackground
    └── SafeArea
        └── ListView
            ├── _DeviceInfoSection (設備信息區域)
            ├── _LedRecordCard (記錄卡片)
            └── _FavoriteSceneSection (場景列表)
```

---

## 2. Toolbar 對照

### reef-b-app: `toolbar_device.xml`

| 組件 ID | 類型 | 位置 | 圖標 | 尺寸 | 功能 |
|---------|------|------|------|------|------|
| `btn_back` | ImageView | 左側 | `ic_back` | 56×44dp | 返回按鈕 |
| `toolbar_title` | TextView | 居中 | - | maxWidth 200dp | 設備名稱（居中顯示） |
| `btn_menu` | ImageView | 右側 | `ic_menu` | 56×44dp | 菜單按鈕（編輯/刪除/重置） |
| `btn_favorite` | ImageView | 右側（btn_menu 左側） | `ic_favorite_select` / `ic_favorite_unselect` | 56×44dp | 喜愛按鈕 |
| `divider` | MaterialDivider | Toolbar 下方 | - | 高度 2dp | 分隔線 |

**圖標資源**：
- `ic_back` - 返回箭頭圖標
- `ic_menu` - 三點菜單圖標
- `ic_favorite_select` - 已選中的喜愛圖標（紅色）
- `ic_favorite_unselect` - 未選中的喜愛圖標（灰色）

### koralcore: `ReefAppBar`

| 組件 | 類型 | 位置 | 圖標 | 尺寸 | 功能 | 狀態 |
|------|------|------|------|------|------|------|
| `leading` | IconButton | 左側 | `Icons.arrow_back` | 標準 | 返回按鈕 | ✅ 已實現 |
| `title` | Text | 居中 | - | - | 設備名稱（居中顯示） | ✅ 已實現 |
| `actions[0]` | IconButton | 右側 | `Icons.favorite` / `Icons.favorite_border` | 標準 | 喜愛按鈕 | ✅ 已實現 |
| `actions[1]` | IconButton | 右側 | `Icons.fullscreen` / `Icons.fullscreen_exit` | 標準 | 橫屏切換按鈕 | ✅ 已實現 |
| `actions[2]` | PopupMenuButton | 右側 | `Icons.more_vert` | 標準 | 菜單按鈕（編輯/刪除/重置） | ✅ 已實現 |
| `divider` | - | - | - | - | 分隔線 | ❌ **缺失** |

**差異**：
- ✅ koralcore 使用 Flutter 標準圖標（Material Icons）
- ❌ koralcore 缺少 Toolbar 下方的 2dp 分隔線
- ✅ koralcore 的喜愛按鈕功能完整（支持切換狀態）
- ✅ koralcore 的菜單功能完整（編輯/刪除/重置）

---

## 3. 設備信息區域對照

### reef-b-app: 設備信息區域

| 組件 ID | 類型 | 位置 | 尺寸/樣式 | 內容 | 功能 |
|---------|------|------|-----------|------|------|
| `tv_name` | TextView | Toolbar 下方 | marginStart 16dp, marginTop 8dp, marginEnd 4dp | 設備名稱 | 顯示設備名稱 |
| `btn_ble` | ImageView | tv_name 右側 | 48×32dp, marginEnd 16dp | `ic_disconnect_background` / `ic_connect_background` | BLE 連接狀態圖標 |
| `tv_position` | TextView | tv_name 下方 | caption2 樣式 | 水槽位置或"未分配裝置" | 顯示設備位置 |
| `tv_group` | TextView | tv_position 右側 | caption2 樣式, marginStart 4dp, visibility="gone" | "群組A" 等 | 顯示群組信息（可隱藏） |

**圖標資源**：
- `ic_disconnect_background` - 未連接狀態圖標（灰色背景）
- `ic_connect_background` - 已連接狀態圖標（綠色背景）

**邏輯**：
- `tv_position`: 如果 `device.sinkId` 不為 null，顯示水槽名稱；否則顯示 "未分配裝置"
- `tv_group`: 如果 `device.group` 不為 null，顯示 "群組${group}"；否則隱藏（visibility="gone"）
- `btn_ble`: 根據 `viewModel.isConnectNowDevice()` 切換圖標

### koralcore: `_DeviceInfoSection`

| 組件 | 類型 | 位置 | 尺寸/樣式 | 內容 | 功能 | 狀態 |
|------|------|------|-----------|------|------|------|
| 設備名稱 | Text | 頂部 | bodyAccent 樣式 | 設備名稱 | 顯示設備名稱 | ✅ 已實現 |
| BLE 狀態 | Image.asset | 設備名稱右側 | 48×32dp | `ic_connect_background` / `ic_disconnect_background` | BLE 連接狀態 | ⚠️ **已實現但需確認圖標文件** |
| 位置信息 | Text | 設備名稱下方 | caption2 樣式 | 水槽名稱或"未分配裝置" | 水槽位置 | ⚠️ **已實現但需從 repository 獲取數據** |
| 群組信息 | Text | 位置信息右側 | caption2 樣式 | "｜群組A" 等 | 群組信息 | ⚠️ **已實現但需從 repository 獲取數據** |

**差異**：
- ⚠️ koralcore 已實現 BLE 連接狀態圖標，但需要確認圖標文件是否存在（`assets/icons/bluetooth/ic_connect_background.png` 和 `ic_disconnect_background.png`）
- ⚠️ koralcore 已實現位置信息顯示，但當前為 TODO（需要從 `deviceRepository` 獲取 `sinkId`，然後從 `sinkRepository` 獲取水槽名稱）
- ⚠️ koralcore 已實現群組信息顯示，但當前為 TODO（需要從 `deviceRepository` 獲取 `device_group`）

---

## 4. Record 區域對照

### reef-b-app: Record 卡片

| 組件 ID | 類型 | 位置 | 尺寸/樣式 | 圖標 | 功能 |
|---------|------|------|-----------|------|------|
| `tv_record_title` | TextView | 位置信息下方 | marginTop 20dp, bodyAccent 樣式 | - | "Record" 標題 |
| `btn_record_more` | ImageView | tv_record_title 右側 | 24×24dp, marginStart 16dp, marginEnd 16dp | `ic_more_disable` / `ic_more` | 更多按鈕（跳轉到記錄設置） |
| `layout_record_background` | CardView | tv_record_title 下方 | marginTop 4dp, cornerRadius 10dp, elevation 5dp | - | 記錄卡片容器 |
| `tv_record_state` | TextView | CardView 內（未連接時顯示） | margin 12dp, bodyAccent 樣式 | - | "裝置未連線" 提示 |
| `layout_record` | ConstraintLayout | CardView 內（連接時顯示） | visibility="gone"（未連接時） | - | 記錄內容容器 |
| `line_chart` | LineChart | layout_record 內 | height 242dp, margin 8dp | - | 光譜圖表 |
| `btn_expand` | ImageView | line_chart 下方左側 | 24×24dp, marginStart 16dp, marginTop 4dp, marginBottom 16dp | `ic_zoom_in` | 展開按鈕（切換橫屏） |
| `btn_preview` | ImageView | line_chart 下方右側 | 24×24dp, marginEnd 16dp | `ic_preview` / `ic_stop` | 預覽按鈕（開始/停止預覽） |
| `layout_record_pause` | ConstraintLayout | layout_record 覆蓋層 | visibility="gone"（記錄模式時） | - | 暫停覆蓋層 |
| `btn_continue_record` | MaterialButton | layout_record_pause 內 | RoundedButton 樣式 | - | 繼續記錄按鈕 |

**圖標資源**：
- `ic_more_disable` - 禁用狀態的更多按鈕（灰色）
- `ic_more` - 啟用狀態的更多按鈕（藍色）
- `ic_zoom_in` - 展開圖標
- `ic_preview` - 預覽圖標
- `ic_stop` - 停止圖標（預覽時顯示）

**邏輯**：
- `btn_record_more`: 初始狀態為禁用（`isEnabled = false`），連接後啟用
- `layout_record`: 未連接時隱藏，連接後顯示
- `tv_record_state`: 未連接時顯示，連接後隱藏
- `btn_preview`: 預覽狀態時圖標切換為 `ic_stop`
- `layout_record_pause`: 記錄模式時隱藏，場景模式時顯示

### koralcore: `_LedRecordCard`

| 組件 | 類型 | 位置 | 尺寸/樣式 | 圖標 | 功能 | 狀態 |
|------|------|------|-----------|------|------|------|
| Record 標題 | Text | 頂部 | bodyAccent 樣式 | - | "Record" 標題 | ✅ 已實現 |
| 更多按鈕 | IconButton | 標題右側 | 24×24dp | `Icons.more_horiz` | 更多按鈕 | ✅ 已實現 |
| 記錄卡片 | Card | 標題下方 | cornerRadius 10dp, elevation 5dp | - | 記錄卡片容器 | ✅ 已實現 |
| 未連接提示 | Text | Card 內（未連接時） | bodyAccent 樣式 | - | "裝置未連線" 提示 | ✅ 已實現 |
| 圖表 | LedRecordLineChart | Card 內（連接時） | height 242dp | - | 光譜圖表 | ✅ 已實現 |
| 展開按鈕 | IconButton | 圖表下方左側 | 24×24dp | `Icons.fullscreen` | 展開按鈕 | ✅ 已實現 |
| 預覽按鈕 | IconButton | 圖表下方右側 | 24×24dp | `Icons.play_arrow` / `Icons.stop` | 預覽按鈕 | ✅ 已實現 |
| 暫停覆蓋層 | - | - | - | - | 暫停覆蓋層 | ⚠️ **部分實現** |
| 繼續記錄按鈕 | - | - | - | - | 繼續記錄按鈕 | ❌ **缺失** |

**差異**：
- ✅ koralcore 使用 Flutter 標準圖標（Material Icons）
- ⚠️ koralcore 的暫停覆蓋層邏輯可能不完整
- ❌ koralcore 缺少 "繼續記錄" 按鈕（`btn_continue_record`）

---

## 5. Scene 區域對照

### reef-b-app: Scene 區域

| 組件 ID | 類型 | 位置 | 尺寸/樣式 | 圖標 | 功能 |
|---------|------|------|-----------|------|------|
| `tv_scene_title` | TextView | Record 卡片下方 | marginTop 24dp, bodyAccent 樣式 | - | "LED Scene" 標題 |
| `btn_scene_more` | ImageView | tv_scene_title 右側 | 24×24dp, marginStart 16dp, marginEnd 16dp | `ic_more_disable` / `ic_more` | 更多按鈕（跳轉到場景列表） |
| `rv_favorite_scene` | RecyclerView | tv_scene_title 下方 | marginTop 4dp, paddingStart 8dp, paddingEnd 8dp, horizontal LinearLayoutManager | - | 喜愛場景列表（水平滾動） |

**圖標資源**：
- `ic_more_disable` - 禁用狀態的更多按鈕（灰色）
- `ic_more` - 啟用狀態的更多按鈕（藍色）

**邏輯**：
- `btn_scene_more`: 初始狀態為禁用（`isEnabled = false`），連接後啟用
- `rv_favorite_scene`: 使用 `FavoriteSceneAdapter`，水平滾動顯示喜愛場景

### koralcore: `_FavoriteSceneSection`

| 組件 | 類型 | 位置 | 尺寸/樣式 | 圖標 | 功能 | 狀態 |
|------|------|------|-----------|------|------|------|
| Scene 標題 | Text | Record 卡片下方 | marginTop 24dp, bodyAccent 樣式 | - | "LED Scene" 標題 | ✅ 已實現 |
| 更多按鈕 | IconButton | 標題右側 | 24×24dp | `Icons.more_horiz` | 更多按鈕 | ✅ 已實現 |
| 場景列表 | ListView | 標題下方 | horizontal, paddingStart 8dp, paddingEnd 8dp | - | 喜愛場景列表（水平滾動） | ✅ 已實現 |

**差異**：
- ✅ koralcore 使用 Flutter 標準圖標（Material Icons）
- ✅ koralcore 的場景列表功能完整

---

## 6. 進度指示器對照

### reef-b-app: `progress.xml`

| 組件 ID | 類型 | 位置 | 功能 |
|---------|------|------|------|
| `progress` | include | 覆蓋整個頁面 | 加載指示器（visibility="gone" 默認隱藏） |

### koralcore: 加載狀態

| 組件 | 類型 | 位置 | 功能 | 狀態 |
|------|------|------|------|------|
| 加載指示器 | - | - | 加載指示器 | ⚠️ **需確認** |

---

## 7. 圖標對照表

### reef-b-app 圖標資源

| 圖標名稱 | 用途 | 狀態 |
|---------|------|------|
| `ic_back` | 返回按鈕 | ✅ |
| `ic_menu` | 菜單按鈕 | ✅ |
| `ic_favorite_select` | 已選中喜愛 | ✅ |
| `ic_favorite_unselect` | 未選中喜愛 | ✅ |
| `ic_disconnect_background` | 未連接狀態 | ✅ |
| `ic_connect_background` | 已連接狀態 | ✅ |
| `ic_more_disable` | 禁用更多按鈕 | ✅ |
| `ic_more` | 啟用更多按鈕 | ✅ |
| `ic_zoom_in` | 展開按鈕 | ✅ |
| `ic_preview` | 預覽按鈕 | ✅ |
| `ic_stop` | 停止按鈕 | ✅ |

### koralcore 圖標（Material Icons）

| Material Icon | 用途 | 對應 reef-b-app | 狀態 |
|---------------|------|----------------|------|
| `Icons.arrow_back` | 返回按鈕 | `ic_back` | ✅ |
| `Icons.more_vert` | 菜單按鈕 | `ic_menu` | ✅ |
| `Icons.favorite` | 已選中喜愛 | `ic_favorite_select` | ✅ |
| `Icons.favorite_border` | 未選中喜愛 | `ic_favorite_unselect` | ✅ |
| `Icons.fullscreen` | 展開按鈕 | `ic_zoom_in` | ✅ |
| `Icons.fullscreen_exit` | 收起按鈕 | - | ✅ |
| `Icons.more_horiz` | 更多按鈕 | `ic_more` | ✅ |
| `Icons.play_arrow` | 預覽按鈕 | `ic_preview` | ✅ |
| `Icons.stop` | 停止按鈕 | `ic_stop` | ✅ |
| - | BLE 連接狀態 | `ic_connect_background` / `ic_disconnect_background` | ❌ **缺失** |

---

## 8. 功能對照表

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **Toolbar** | | | |
| 返回按鈕 | ✅ | ✅ | ✅ 已實現 |
| 設備名稱顯示 | ✅ | ✅ | ✅ 已實現 |
| 喜愛按鈕 | ✅ | ✅ | ✅ 已實現 |
| 菜單按鈕（編輯/刪除/重置） | ✅ | ✅ | ✅ 已實現 |
| 橫屏切換按鈕 | ✅ | ✅ | ✅ 已實現 |
| Toolbar 分隔線 | ✅ | ❌ | ❌ **缺失** |
| **設備信息** | | | |
| 設備名稱顯示 | ✅ | ✅ | ✅ 已實現 |
| BLE 連接狀態圖標 | ✅ | ⚠️ | ⚠️ **已實現但需確認圖標文件** |
| 位置信息顯示 | ✅ | ⚠️ | ⚠️ **已實現但需從 repository 獲取數據** |
| 群組信息顯示 | ✅ | ⚠️ | ⚠️ **已實現但需從 repository 獲取數據** |
| **Record 區域** | | | |
| Record 標題 | ✅ | ✅ | ✅ 已實現 |
| Record 更多按鈕 | ✅ | ✅ | ✅ 已實現 |
| 記錄卡片 | ✅ | ✅ | ✅ 已實現 |
| 未連接提示 | ✅ | ✅ | ✅ 已實現 |
| 光譜圖表 | ✅ | ✅ | ✅ 已實現 |
| 展開按鈕 | ✅ | ✅ | ✅ 已實現 |
| 預覽按鈕 | ✅ | ✅ | ✅ 已實現 |
| 暫停覆蓋層 | ✅ | ⚠️ | ⚠️ **部分實現** |
| 繼續記錄按鈕 | ✅ | ❌ | ❌ **缺失** |
| **Scene 區域** | | | |
| Scene 標題 | ✅ | ✅ | ✅ 已實現 |
| Scene 更多按鈕 | ✅ | ✅ | ✅ 已實現 |
| 喜愛場景列表 | ✅ | ✅ | ✅ 已實現 |
| **其他** | | | |
| 進度指示器 | ✅ | ⚠️ | ⚠️ **需確認** |

---

## 9. 缺失功能清單

### 高優先級

1. **確認 BLE 連接狀態圖標文件**
   - 位置：`assets/icons/bluetooth/`
   - 文件：`ic_connect_background.png`（已連接）、`ic_disconnect_background.png`（未連接）
   - 狀態：代碼已實現，需確認圖標文件是否存在

2. **實現位置信息數據獲取**
   - 位置：`_DeviceInfoSection.build()` 方法
   - 邏輯：從 `deviceRepository.getDevice(deviceId)` 獲取 `sinkId`，然後從 `sinkRepository` 獲取水槽名稱
   - 狀態：UI 已實現，需實現數據獲取邏輯

3. **實現群組信息數據獲取**
   - 位置：`_DeviceInfoSection.build()` 方法
   - 邏輯：從 `deviceRepository.getDevice(deviceId)` 獲取 `device_group`
   - 狀態：UI 已實現，需實現數據獲取邏輯

4. **Toolbar 分隔線** (`divider`)
   - 位置：Toolbar 下方
   - 尺寸：高度 2dp
   - 顏色：`bg_press`
   - 狀態：❌ **缺失**

### 中優先級

5. **繼續記錄按鈕** (`btn_continue_record`)
   - 位置：記錄暫停覆蓋層內
   - 功能：當記錄暫停時，點擊繼續記錄

---

## 10. 實現建議

### 1. 完善設備信息區域

在 `_DeviceInfoSection` 中：
- ✅ BLE 連接狀態圖標已實現，需確認圖標文件是否存在
- ⚠️ 位置信息顯示 UI 已實現，需實現數據獲取邏輯：
  ```dart
  final appContext = context.read<AppContext>();
  final device = await appContext.deviceRepository.getDevice(deviceId);
  if (device != null && device['sinkId'] != null) {
    final sinks = appContext.sinkRepository.getCurrentSinks();
    final sink = sinks.firstWhere(
      (s) => s.id == device['sinkId'],
      orElse: () => null,
    );
    positionName = sink?.name;
  }
  ```
- ⚠️ 群組信息顯示 UI 已實現，需實現數據獲取邏輯：
  ```dart
  groupName = device?['group']?.toString();
  if (groupName != null) {
    groupName = '${l10n.group}$groupName'; // "群組A"
  }
  ```

### 2. 添加 Toolbar 分隔線

在 `ReefAppBar` 下方添加 `Divider`：
```dart
Divider(
  height: 2,
  thickness: 2,
  color: ReefColors.bgPress, // 或對應的顏色
)
```

### 3. 完善暫停覆蓋層

確保 `_LedRecordCard` 中的暫停覆蓋層邏輯完整，包括：
- 顯示/隱藏邏輯
- 繼續記錄按鈕

---

## 11. 尺寸對照

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| Toolbar 按鈕 | 56×44dp | 標準 IconButton | ✅ |
| BLE 狀態圖標 | 48×32dp | - | ❌ **缺失** |
| 更多按鈕 | 24×24dp | 24×24dp | ✅ |
| 圖表高度 | 242dp | 242dp | ✅ |
| Record 卡片圓角 | 10dp | 10dp | ✅ |
| Record 卡片 elevation | 5dp | 5dp | ✅ |
| Toolbar 分隔線 | 2dp | - | ❌ **缺失** |

---

## 12. 間距對照

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| tv_name marginStart | 16dp | 16dp | ✅ |
| tv_name marginTop | 8dp | 8dp | ✅ |
| tv_name marginEnd | 4dp | 4dp | ✅ |
| tv_record_title marginTop | 20dp | 20dp | ✅ |
| tv_scene_title marginTop | 24dp | 24dp | ✅ |
| Record 卡片 marginTop | 4dp | 4dp | ✅ |
| Scene 列表 marginTop | 4dp | 4dp | ✅ |

---

## 總結

### 已實現功能 ✅
- Toolbar（返回、標題、喜愛、菜單、橫屏切換）
- Record 區域（標題、更多按鈕、卡片、圖表、展開、預覽）
- Scene 區域（標題、更多按鈕、場景列表）
- BLE 連接狀態圖標（UI 已實現，需確認圖標文件）
- 位置信息顯示（UI 已實現，需實現數據獲取）
- 群組信息顯示（UI 已實現，需實現數據獲取）

### 缺失功能 ❌
- Toolbar 分隔線
- 繼續記錄按鈕

### 部分實現 ⚠️
- BLE 連接狀態圖標（需確認圖標文件是否存在）
- 位置信息顯示（需實現數據獲取邏輯）
- 群組信息顯示（需實現數據獲取邏輯）
- 暫停覆蓋層（邏輯可能不完整）
- 進度指示器（需確認）

