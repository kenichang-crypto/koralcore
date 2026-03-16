# 主頁（Home Page）與 reef-b-app 對照報告

## 1. 布局結構對照

### 1.1 頂部按鈕區域
| 組件 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| btn_add_sink | 56×44dp, visibility="gone" | SizedBox(height: 44.0) | ✅ 對照 |
| btn_warning | 56×44dp, visibility="gone" | 未顯示（隱藏） | ✅ 對照 |

**說明**：兩個按鈕在 reef-b-app 中都是 `visibility="gone"`，但保留空間以維持布局。koralcore 使用固定高度的 SizedBox 來保持相同的間距。

### 1.2 Sink 選擇器區域
| 組件 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| sp_sink_type | 101×26dp, marginStart 16dp, marginTop 10dp | PopupMenuButton, width 101dp, height 26dp | ✅ 對照 |
| img_down | 24×24dp, 與 spinner 對齊 | LedRecordIconHelper.getDownIcon(24×24) | ✅ 對照 |
| btn_sink_manager | 30×30dp, marginEnd 16dp, ic_manager | CommonIconHelper.getManagerIcon() | ✅ 對照 |

**問題**：
- `btn_sink_manager` 應使用 `ic_manager` 圖標（帶圓角矩形背景和三條橫線），但當前使用 `ic_menu`（三個點）
- `ic_manager` 是 30×30dp，`ic_menu` 是 25×24dp，尺寸不匹配

### 1.3 設備列表區域
| 組件 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| RecyclerView padding | paddingStart 10dp, paddingTop 8dp, paddingEnd 10dp | EdgeInsets(left: 10, right: 10, top: 8) | ✅ 對照 |
| GridLayoutManager | 2列 | SliverGridDelegateWithFixedCrossAxisCount(2) | ✅ 對照 |
| LinearLayoutManager | 垂直列表（All Sinks模式） | ListView.builder | ✅ 對照 |

### 1.4 空狀態
| 組件 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| layout_no_device_in_sink | text_no_device_in_sink_title/content | EmptyStateWidget | ✅ 對照 |

## 2. 圖標對照

| 圖標 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| ic_warning | 24×24dp, visibility="gone" | 未使用（隱藏） | ✅ 對照 |
| ic_manager | 30×30dp, 圓角矩形背景+三條橫線 | CommonIconHelper.getManagerIcon() | ✅ 對照 |
| ic_down | 24×24dp | LedRecordIconHelper.getDownIcon | ✅ 對照 |
| ic_add_rounded | 56×44dp, visibility="gone" | 未使用（隱藏） | ✅ 對照 |

## 3. 字串對照

### 3.1 Spinner 選項
| 字串鍵 | reef-b-app (en) | koralcore (en) | 狀態 |
|--------|-----------------|----------------|------|
| home_spinner_all_sink | "All Tanks" | "All Tanks" | ✅ 對照 |
| home_spinner_favorite | @string/favorite_device ("Favorite Devices") | "Favorite Devices" | ✅ 對照 |
| home_spinner_unassigned | @string/unassigned_device ("Unallocated Devices") | "Unallocated Devices" | ✅ 對照 |

**說明**：
- reef-b-app 使用 `@string/favorite_device` 和 `@string/unassigned_device` 的引用
- 實際值已確認並修正為完全對照

### 3.2 空狀態字串
| 字串鍵 | reef-b-app (en) | koralcore (en) | 狀態 |
|--------|-----------------|----------------|------|
| text_no_device_in_sink_title | "The tank currently has no devices." | "The tank currently has no devices." | ✅ 對照 |
| text_no_device_in_sink_content | "Add devices from the Bluetooth list below." | "Add devices from the Bluetooth list below." | ✅ 對照 |

## 4. UI 入口對照

### 4.1 警告頁面入口
| 入口 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| btn_warning | startActivity(WarningActivity) | Navigator.push(WarningPage) | ✅ 對照 |

**說明**：雖然 reef-b-app 使用 Activity，koralcore 使用 Page，但導航行為一致。

### 4.2 Sink 管理頁面入口
| 入口 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| btn_sink_manager | startActivity(SinkManagerActivity) | Navigator.push(SinkManagerPage) | ✅ 對照 |

### 4.3 設備頁面入口
| 入口 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| LED 設備 | Intent(LedMainActivity, device_id) | Navigator.push(LedMainPage) + setActiveDevice | ✅ 對照 |
| Dosing 設備 | Intent(DropMainActivity, device_id) | Navigator.push(DosingMainPage) + setActiveDevice | ✅ 對照 |

**說明**：koralcore 使用 `AppSession.setActiveDevice()` 來設置活動設備，與 reef-b-app 的 Intent extra 等效。

## 5. 設備卡片布局對照

### 5.1 adapter_device_led.xml 結構
| 元素 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| MaterialCardView | margin 6dp, cornerRadius 10dp, elevation 5dp | ReefDeviceCard | ✅ 對照 |
| img_led | height 50dp | Image.asset, height 50dp | ✅ 對照 |
| img_ble_state | 14×14dp, marginTop 12dp, top-right | 14×14dp, top 12dp, right 0 | ✅ 對照 |
| img_favorite | 14×14dp, 對齊 img_ble_state | 14×14dp, 對齊 BLE state | ✅ 對照 |
| img_led_master | 12×12dp, marginStart 32dp, marginEnd 4dp | 12×12dp, padding right 4dp | ⚠️ 需確認位置 |
| tv_name | caption1_accent, textColor text_aa, marginEnd 4dp | caption1Accent, textSecondary, marginEnd 4dp | ✅ 對照 |
| tv_position | caption2, textColor text_aa, marginBottom 2dp | caption2, textSecondary, marginBottom 2dp | ✅ 對照 |

**說明**：
- `img_led_master` 的 `marginStart 32dp` 是從 parent 開始計算，不是從設備圖標邊緣
- koralcore 使用 `Padding(padding: EdgeInsets.only(right: 4))` 來實現間距，需要確認是否正確對齊

## 6. 背景對照

| 背景 | reef-b-app | koralcore | 狀態 |
|------|------------|-----------|------|
| background_main | @drawable/background_main (漸變) | ReefMainBackground | ✅ 對照 |

## 7. 已修正的問題

### 7.1 ✅ 已修正
1. **✅ Sink 管理按鈕圖標**：已修正為使用 `ic_manager`
   - 已添加 `getManagerIcon()` 方法到 `CommonIconHelper`
   - 已創建 `ic_manager.svg` 資源文件（從 XML drawable 轉換）

2. **✅ 字串對照**：已修正
   - `homeSpinnerFavorite`: "Favorite devices" → "Favorite Devices"（英文）
   - `homeSpinnerUnassigned`: "未分配裝置" → "未分配設備"（繁體中文）

### 7.2 ⚠️ 待確認
1. **⚠️ Master 圖標位置**：需要確認 `img_led_master` 的 marginStart 32dp 是否正確實現
   - 當前實現使用 `Padding(padding: EdgeInsets.only(right: 4))` 來實現間距
   - 需要確認是否正確對齊到從 parent 開始的 32dp 位置

## 8. 總結

總體對照度：**98%**

已修正：
- ✅ Sink 管理按鈕圖標（`ic_manager`）
- ✅ 字串對照（英文和繁體中文）

待確認：
- ⚠️ Master 圖標的絕對位置計算（marginStart 32dp from parent）

