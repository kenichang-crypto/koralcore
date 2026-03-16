# 圖標資源需求清單

**日期**: 2024-12-28  
**狀態**: 需要添加圖標資源文件

---

## 📋 缺失的圖標資源

以下圖標資源需要從 `reef-b-app` 複製或重新創建：

### 1. LED Master Setting Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_master_big.png` | `assets/icons/ic_master_big.png` | 20×20dp | Master 設備圖標（大） | `@drawable/ic_master_big` |
| `ic_menu.png` | `assets/icons/ic_menu.png` | 24×24dp | 菜單按鈕 | `@drawable/ic_menu` |

**位置**: `lib/ui/features/led/pages/led_master_setting_page.dart`
- Line 238: `ic_master_big.png`
- Line 251: `ic_menu.png`

---

### 2. Dosing Record Setting Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_drop.png` | `assets/icons/ic_drop.png` | 待確認 | Drop 圖標 | 需確認 |

**位置**: `lib/ui/features/dosing/pages/pump_head_record_setting_page.dart`
- Line 780: `ic_drop.png`

---

### 3. Drop Type Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_edit.png` | `assets/icons/ic_edit.png` | 待確認 | 編輯按鈕 | `@drawable/ic_edit` |

**位置**: `lib/ui/features/dosing/pages/drop_type_page.dart`
- Line 199: `ic_edit.png`

---

### 4. Dosing Main Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `img_drop_head_*.png` | `assets/icons/dosing/img_drop_head_a.png` 等 | 待確認 | Pump Head 圖標 | 需確認 |
| `ic_play_enabled.png` | `assets/icons/ic_play_enabled.png` | 待確認 | 播放按鈕（啟用） | `@drawable/ic_play_enabled` |

**位置**: `lib/ui/features/dosing/pages/dosing_main_page.dart`
- Line 444: `img_drop_head_${summary.headId.toLowerCase()}.png`
- Line 494: `ic_play_enabled.png`

---

### 5. LED Scene List Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_play_select.png` | `assets/icons/ic_play_select.png` | 20×20dp | 播放按鈕（選中） | 需確認 |
| `ic_play_unselect.png` | `assets/icons/ic_play_unselect.png` | 20×20dp | 播放按鈕（未選中） | 需確認 |
| `ic_favorite_select.png` | `assets/icons/ic_favorite_select.png` | 20×20dp | 喜愛按鈕（選中） | `@drawable/ic_favorite_select` |
| `ic_favorite_unselect.png` | `assets/icons/ic_favorite_unselect.png` | 20×20dp | 喜愛按鈕（未選中） | `@drawable/ic_favorite_unselect` |

**位置**: `lib/ui/features/led/pages/led_scene_list_page.dart`
- Line 389-390: `ic_play_*.png`
- Line 412-413: `ic_favorite_*.png`

---

### 6. LED Record Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_more_enable.png` | `assets/icons/ic_more_enable.png` | 24×24dp | 更多按鈕（啟用） | 需確認 |

**位置**: `lib/ui/features/led/pages/led_record_page.dart`
- Line 652: `ic_more_enable.png`

---

### 7. Sink Manager Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_edit.png` | `assets/icons/ic_edit.png` | 待確認 | 編輯按鈕 | `@drawable/ic_edit` |

**位置**: `lib/ui/features/sink/pages/sink_manager_page.dart`
- Line 301: `ic_edit.png`

---

### 8. Bluetooth Page

| 圖標 | 路徑 | 尺寸 | 用途 | reef-b-app 資源 |
|------|------|------|------|----------------|
| `ic_master.png` | `assets/icons/ic_master.png` | 待確認 | Master 設備圖標 | `@drawable/ic_master` |
| `ic_connect_background.png` | `assets/icons/ic_connect_background.png` | 待確認 | 已連接狀態背景 | `@drawable/ic_connect_background` |
| `ic_disconnect_background.png` | `assets/icons/ic_disconnect_background.png` | 待確認 | 未連接狀態背景 | `@drawable/ic_disconnect_background` |

**位置**: `lib/ui/features/bluetooth/bluetooth_page.dart`
- Line 514: `ic_master.png`
- Line 532-533: `ic_connect_background.png` / `ic_disconnect_background.png`

---

## 🔍 從 reef-b-app 提取圖標

### 步驟

1. **定位圖標文件**:
   - reef-b-app 的圖標位於 `android/ReefB_Android/app/src/main/res/drawable/` 或 `drawable-*/` 目錄
   - 查找對應的 `.png` 或 `.xml` 文件

2. **複製到 koralcore**:
   - 將圖標文件複製到 `koralcore/assets/icons/` 目錄
   - 保持文件名一致

3. **更新 pubspec.yaml**:
   - 確保 `pubspec.yaml` 中的 `assets` 部分包含圖標路徑

---

## ✅ 當前狀態

- **已標記**: 所有缺失的圖標資源已在代碼中標記 `TODO: Add icon asset`
- **待添加**: 需要從 reef-b-app 提取或重新創建 8 個圖標資源
- **臨時方案**: 代碼中使用 `errorBuilder` 提供 fallback 圖標（Material Icons）

---

## 📝 注意事項

1. **圖標尺寸**: 確保圖標尺寸與 reef-b-app 一致
2. **顏色**: 某些圖標可能需要根據狀態改變顏色（選中/未選中）
3. **分辨率**: 提供多種分辨率版本（1x, 2x, 3x）以支持不同設備

---

**報告生成時間**: 2024-12-28  
**狀態**: 待添加圖標資源

