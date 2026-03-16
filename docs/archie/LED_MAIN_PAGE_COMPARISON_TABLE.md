# LED 操作主頁對照表

## 1. Toolbar 組件對照表

| 序號 | reef-b-app | koralcore | 圖標 | 位置 | 尺寸 | 功能 | 狀態 |
|------|-----------|-----------|------|------|------|------|------|
| 1 | `btn_back` | `leading` (IconButton) | `ic_back` / `Icons.arrow_back` | 左側 | 56×44dp / 標準 | 返回按鈕 | ✅ |
| 2 | `toolbar_title` | `title` (Text) | - | 居中 | maxWidth 200dp / - | 設備名稱 | ✅ |
| 3 | `btn_favorite` | `actions[0]` (IconButton) | `ic_favorite_select/unselect` / `Icons.favorite/border` | 右側 | 56×44dp / 標準 | 喜愛切換 | ✅ |
| 4 | `btn_menu` | `actions[2]` (PopupMenuButton) | `ic_menu` / `Icons.more_vert` | 右側 | 56×44dp / 標準 | 菜單（編輯/刪除/重置） | ✅ |
| 5 | - | `actions[1]` (IconButton) | - / `Icons.fullscreen/exit` | 右側 | - / 標準 | 橫屏切換 | ✅ |
| 6 | `divider` | - | - | Toolbar 下方 | 高度 2dp | 分隔線 | ❌ |

---

## 2. 設備信息區域對照表

| 序號 | reef-b-app | koralcore | 圖標 | 位置 | 尺寸/樣式 | 內容 | 狀態 |
|------|-----------|-----------|------|------|-----------|------|------|
| 1 | `tv_name` | `Text` (設備名稱) | - | Toolbar 下方 | marginStart 16dp, marginTop 8dp, bodyAccent | 設備名稱 | ✅ |
| 2 | `btn_ble` | `Image.asset` (BLE 狀態) | `ic_connect/disconnect_background` | tv_name 右側 | 48×32dp, marginEnd 16dp | BLE 連接狀態圖標 | ⚠️ |
| 3 | `tv_position` | `Text` (位置信息) | - | tv_name 下方 | caption2, text_aaa | 水槽名稱或"未分配裝置" | ⚠️ |
| 4 | `tv_group` | `Text` (群組信息) | - | tv_position 右側 | caption2, text_aa, marginStart 4dp | "群組A" 等（可隱藏） | ⚠️ |

**狀態說明**：
- ✅ 已完全實現
- ⚠️ UI 已實現，需完善數據獲取或確認資源文件
- ❌ 未實現

---

## 3. Record 區域對照表

| 序號 | reef-b-app | koralcore | 圖標 | 位置 | 尺寸/樣式 | 功能 | 狀態 |
|------|-----------|-----------|------|------|-----------|------|------|
| 1 | `tv_record_title` | `Text` ("Record") | - | 位置信息下方 | marginTop 20dp, bodyAccent | Record 標題 | ✅ |
| 2 | `btn_record_more` | `IconButton` | `ic_more_disable/more` / `Icons.more_horiz` | 標題右側 | 24×24dp, marginStart 16dp | 更多按鈕（跳轉記錄設置） | ✅ |
| 3 | `layout_record_background` | `Card` | - | 標題下方 | marginTop 4dp, cornerRadius 10dp, elevation 5dp | 記錄卡片容器 | ✅ |
| 4 | `tv_record_state` | `Text` (未連接提示) | - | Card 內（未連接時） | margin 12dp, bodyAccent | "裝置未連線" 提示 | ✅ |
| 5 | `layout_record` | `ConstraintLayout` (記錄內容) | - | Card 內（連接時） | visibility="gone"（未連接時） | 記錄內容容器 | ✅ |
| 6 | `line_chart` | `LedRecordLineChart` | - | layout_record 內 | height 242dp, margin 8dp | 光譜圖表 | ✅ |
| 7 | `btn_expand` | `IconButton` | `ic_zoom_in` / `Icons.fullscreen` | 圖表下方左側 | 24×24dp, marginStart 16dp | 展開按鈕（橫屏切換） | ✅ |
| 8 | `btn_preview` | `IconButton` | `ic_preview/stop` / `Icons.play_arrow/stop` | 圖表下方右側 | 24×24dp, marginEnd 16dp | 預覽按鈕（開始/停止） | ✅ |
| 9 | `layout_record_pause` | `Container` (暫停覆蓋層) | - | layout_record 覆蓋層 | visibility="gone"（記錄模式時） | 暫停覆蓋層 | ⚠️ |
| 10 | `btn_continue_record` | - | - | layout_record_pause 內 | RoundedButton 樣式 | 繼續記錄按鈕 | ❌ |

---

## 4. Scene 區域對照表

| 序號 | reef-b-app | koralcore | 圖標 | 位置 | 尺寸/樣式 | 功能 | 狀態 |
|------|-----------|-----------|------|------|-----------|------|------|
| 1 | `tv_scene_title` | `Text` ("LED Scene") | - | Record 卡片下方 | marginTop 24dp, bodyAccent | Scene 標題 | ✅ |
| 2 | `btn_scene_more` | `IconButton` | `ic_more_disable/more` / `Icons.more_horiz` | 標題右側 | 24×24dp, marginStart 16dp | 更多按鈕（跳轉場景列表） | ✅ |
| 3 | `rv_favorite_scene` | `ListView` (horizontal) | - | 標題下方 | marginTop 4dp, paddingStart 8dp | 喜愛場景列表（水平滾動） | ✅ |

---

## 5. 圖標資源對照表

| 用途 | reef-b-app 圖標 | koralcore 圖標 | 狀態 |
|------|----------------|----------------|------|
| 返回按鈕 | `ic_back` | `Icons.arrow_back` | ✅ |
| 菜單按鈕 | `ic_menu` | `Icons.more_vert` | ✅ |
| 喜愛（已選中） | `ic_favorite_select` | `Icons.favorite` | ✅ |
| 喜愛（未選中） | `ic_favorite_unselect` | `Icons.favorite_border` | ✅ |
| BLE 已連接 | `ic_connect_background` | `Image.asset('assets/icons/bluetooth/ic_connect_background.png')` | ⚠️ |
| BLE 未連接 | `ic_disconnect_background` | `Image.asset('assets/icons/bluetooth/ic_disconnect_background.png')` | ⚠️ |
| 更多按鈕（啟用） | `ic_more` / `ic_more_enable` | `Icons.more_horiz` | ✅ |
| 更多按鈕（禁用） | `ic_more_disable` | `Icons.more_horiz` (disabled) | ✅ |
| 展開按鈕 | `ic_zoom_in` | `Icons.fullscreen` | ✅ |
| 預覽按鈕 | `ic_preview` | `Icons.play_arrow` | ✅ |
| 停止按鈕 | `ic_stop` | `Icons.stop` | ✅ |

**狀態說明**：
- ✅ 已實現（使用 Material Icons 或自定義圖標）
- ⚠️ 需確認圖標文件是否存在

---

## 6. 功能對照總表

| 功能分類 | 功能項目 | reef-b-app | koralcore | 狀態 |
|---------|---------|-----------|-----------|------|
| **Toolbar** | 返回按鈕 | ✅ | ✅ | ✅ |
| | 設備名稱顯示 | ✅ | ✅ | ✅ |
| | 喜愛按鈕 | ✅ | ✅ | ✅ |
| | 菜單按鈕（編輯/刪除/重置） | ✅ | ✅ | ✅ |
| | 橫屏切換按鈕 | ✅ | ✅ | ✅ |
| | Toolbar 分隔線 | ✅ | ❌ | ❌ |
| **設備信息** | 設備名稱顯示 | ✅ | ✅ | ✅ |
| | BLE 連接狀態圖標 | ✅ | ⚠️ | ⚠️ |
| | 位置信息顯示 | ✅ | ⚠️ | ⚠️ |
| | 群組信息顯示 | ✅ | ⚠️ | ⚠️ |
| **Record 區域** | Record 標題 | ✅ | ✅ | ✅ |
| | Record 更多按鈕 | ✅ | ✅ | ✅ |
| | 記錄卡片 | ✅ | ✅ | ✅ |
| | 未連接提示 | ✅ | ✅ | ✅ |
| | 光譜圖表 | ✅ | ✅ | ✅ |
| | 展開按鈕 | ✅ | ✅ | ✅ |
| | 預覽按鈕 | ✅ | ✅ | ✅ |
| | 暫停覆蓋層 | ✅ | ⚠️ | ⚠️ |
| | 繼續記錄按鈕 | ✅ | ❌ | ❌ |
| **Scene 區域** | Scene 標題 | ✅ | ✅ | ✅ |
| | Scene 更多按鈕 | ✅ | ✅ | ✅ |
| | 喜愛場景列表 | ✅ | ✅ | ✅ |
| **其他** | 進度指示器 | ✅ | ⚠️ | ⚠️ |

**狀態說明**：
- ✅ 已完全實現
- ⚠️ 部分實現（UI 已實現但需完善數據/邏輯/資源）
- ❌ 未實現

---

## 7. 尺寸對照表

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| Toolbar 按鈕 | 56×44dp | 標準 IconButton | ✅ |
| BLE 狀態圖標 | 48×32dp | 48×32dp | ✅ |
| 更多按鈕 | 24×24dp | 24×24dp | ✅ |
| 圖表高度 | 242dp | 242dp | ✅ |
| Record 卡片圓角 | 10dp | 10dp | ✅ |
| Record 卡片 elevation | 5dp | 5dp | ✅ |
| Toolbar 分隔線高度 | 2dp | - | ❌ |

---

## 8. 間距對照表

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| tv_name marginStart | 16dp | 16dp | ✅ |
| tv_name marginTop | 8dp | 8dp | ✅ |
| tv_name marginEnd | 4dp | 4dp | ✅ |
| btn_ble marginEnd | 16dp | 16dp | ✅ |
| tv_record_title marginTop | 20dp | 20dp | ✅ |
| tv_scene_title marginTop | 24dp | 24dp | ✅ |
| Record 卡片 marginTop | 4dp | 4dp | ✅ |
| Scene 列表 marginTop | 4dp | 4dp | ✅ |
| tv_group marginStart | 4dp | 4dp | ✅ |

---

## 9. 需要完善的功能清單

### 高優先級

1. **確認 BLE 圖標文件**
   - 文件路徑：`assets/icons/bluetooth/ic_connect_background.png`
   - 文件路徑：`assets/icons/bluetooth/ic_disconnect_background.png`
   - 狀態：代碼已實現，需確認文件是否存在

2. **實現位置信息數據獲取**
   - 位置：`_DeviceInfoSection.build()` 方法
   - 需要：從 `deviceRepository` 獲取 `sinkId`，從 `sinkRepository` 獲取水槽名稱
   - 狀態：UI 已實現，需實現數據獲取邏輯

3. **實現群組信息數據獲取**
   - 位置：`_DeviceInfoSection.build()` 方法
   - 需要：從 `deviceRepository` 獲取 `device_group`
   - 狀態：UI 已實現，需實現數據獲取邏輯

4. **添加 Toolbar 分隔線**
   - 位置：`ReefAppBar` 下方
   - 尺寸：高度 2dp
   - 顏色：`ReefColors.bgPress` 或對應顏色

### 中優先級

5. **完善暫停覆蓋層**
   - 確保顯示/隱藏邏輯完整
   - 添加繼續記錄按鈕

6. **確認進度指示器**
   - 確認加載狀態的顯示邏輯

---

## 10. 快速檢查清單

### ✅ 已實現（可直接使用）
- [x] Toolbar 所有按鈕
- [x] Record 區域基本功能
- [x] Scene 區域基本功能
- [x] 設備名稱顯示

### ⚠️ 需完善（UI 已實現，需完善數據/資源）
- [ ] BLE 連接狀態圖標（需確認圖標文件）
- [ ] 位置信息顯示（需實現數據獲取）
- [ ] 群組信息顯示（需實現數據獲取）
- [ ] 暫停覆蓋層（需完善邏輯）
- [ ] 進度指示器（需確認實現）

### ❌ 未實現（需新增）
- [ ] Toolbar 分隔線
- [ ] 繼續記錄按鈕

---

## 11. 實現優先級建議

### P0（必須實現）
1. 確認 BLE 圖標文件是否存在，如不存在則使用 Material Icons 替代
2. 實現位置信息數據獲取邏輯
3. 實現群組信息數據獲取邏輯

### P1（建議實現）
4. 添加 Toolbar 分隔線
5. 完善暫停覆蓋層邏輯
6. 添加繼續記錄按鈕

### P2（可選）
7. 確認進度指示器實現

---

## 12. 代碼位置參考

### reef-b-app
- XML 布局：`android/ReefB_Android/app/src/main/res/layout/activity_led_main.xml`
- Activity：`android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/ui/activity/led_main/LedMainActivity.kt`
- Toolbar：`android/ReefB_Android/app/src/main/res/layout/toolbar_device.xml`

### koralcore
- 主頁面：`lib/ui/features/led/pages/led_main_page.dart`
- 設備信息區域：`_DeviceInfoSection` (line 472-601)
- Record 卡片：`_LedRecordCard` (需查找)
- Scene 區域：`_FavoriteSceneSection` (line 605+)

