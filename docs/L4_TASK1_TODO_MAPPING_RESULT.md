# L4 任務 1 - TODO 字串對照結果

**日期**: 2026-01-03  
**任務**: 處理 92 處 TODO 字串

---

## 📊 對照統計

| 項目 | 數量 | 百分比 |
|------|------|--------|
| **唯一 TODO Key** | 65 個 | - |
| **✅ 已找到** | 61 個 | **93.8%** |
| **❌ 未找到** | 4 個 | **6.2%** |

---

## ✅ 已找到的字串 (61 個)

詳見完整對照表: `/tmp/todo_android_mapping.md`

**範例**:
| TODO Key | Android Value (EN) |
|----------|-------------------|
| `cancel` | Cancel |
| `next` | Next |
| `save` | Save |
| `drop_volume` | Dosing Volume (ml) |
| `drop_start_time` | Dosing Start Time |
| `drop_end_time` | Dosing End Time |
| `adjust_description` | Calibration Instructions |
| `complete_adjust` | Complete Calibration |

---

## ❌ 未找到的字串 (4 個)

需要進一步調查：

| TODO Key | 使用位置 | 可能原因 |
|----------|---------|---------|
| `date` | `pump_head_adjust_list_page.dart:183` | Key 可能不同 |
| `led_master_setting_title` | `led_master_setting_page.dart:95` | Key 可能不同 |
| `led_record` | `led_record_page.dart:105` | Key 可能不同 |
| `led_setting_title` | `led_setting_page.dart:102` | Key 可能不同 |
| `volume` | `pump_head_adjust_list_page.dart:207` | Key 可能不同 |

**行動**: 需要在 Android strings.xml 手動查找或使用相似字串

---

## 📋 下一步: Step 1.3 補充到 Flutter ARB

### 需要補充的字串

根據對照結果，需要補充約 **61 個字串**到 Flutter ARB。

**補充策略**:
1. 優先補充高頻字串（出現在多個檔案）
2. 按模組分組補充（Dosing → LED → 其他）
3. 為每個字串添加 Android 來源標註

**預計時間**: 45 分鐘

---

**完成日期**: 2026-01-03  
**狀態**: Step 1.1 ✅ 完成, Step 1.2 ✅ 完成, Step 1.3 ⏳ 準備中

