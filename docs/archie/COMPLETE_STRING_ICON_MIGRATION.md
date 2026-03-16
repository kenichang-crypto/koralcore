# 完整的字符串和圖標遷移計劃

## 目標
1. 一次性將 reef-b-app 中所有未轉換到 koralcore 的字串和多語系轉換過來
2. 一次性將 reef-b-app 的圖標轉換到 koralcore，替換自創的圖標
3. 全部掃描，不遺漏

## 階段 1: 字符串遷移

### 1.1 提取 reef-b-app 所有字符串

需要讀取的語言文件：
- values/strings.xml (英文)
- values-ar/strings.xml (阿拉伯語)
- values-de/strings.xml (德語)
- values-es/strings.xml (西班牙語)
- values-fr/strings.xml (法語)
- values-in/strings.xml (印尼語)
- values-ja/strings.xml (日語)
- values-ko/strings.xml (韓語)
- values-pt/strings.xml (葡萄牙語)
- values-ru/strings.xml (俄語)
- values-th/strings.xml (泰語)
- values-vi/strings.xml (越南語)
- values-zh-rTW/strings.xml (繁體中文)

### 1.2 對照 koralcore ARB 文件

需要對照的 ARB 文件：
- intl_en.arb
- intl_ar.arb
- intl_de.arb
- intl_es.arb
- intl_fr.arb
- intl_id.arb (對應 values-in)
- intl_ja.arb
- intl_ko.arb
- intl_pt.arb
- intl_ru.arb
- intl_th.arb
- intl_vi.arb
- intl_zh_Hant.arb (對應 values-zh-rTW)

### 1.3 缺失字符串列表（待補充）

需要從 strings.xml 提取所有字符串 key，然後對照 ARB 文件。

## 階段 2: 圖標遷移

### 2.1 reef-b-app 圖標列表（105 個 XML drawable）

#### 已轉換的圖標（18 個）
- ✅ 場景圖標（11 個）：ic_thunder, ic_cloudy, ic_sunny, ic_rainy, ic_dizzle, ic_none, ic_moon, ic_sunrise, ic_sunset, ic_mist, ic_light_off
- ✅ LED Record 圖標（7 個）：ic_sun, ic_slow_start, ic_moon_round, ic_down, ic_strength_thumb, ic_default_thumb, ic_moon_light_thumb

#### 待轉換的圖標（87 個）

**基本動作圖標（15 個）**
- ic_add_black.xml
- ic_add_btn.xml
- ic_add_rounded.xml
- ic_add_white.xml
- ic_back.xml
- ic_check.xml
- ic_close.xml
- ic_delete.xml
- ic_edit.xml
- ic_down.xml (已轉換)
- ic_menu.xml
- ic_minus.xml
- ic_next.xml
- ic_pause.xml
- ic_stop.xml

**播放控制圖標（5 個）**
- ic_play_disable.xml
- ic_play_enabled.xml
- ic_play_select.xml
- ic_play_unselect.xml
- ic_preview.xml

**設備和設置圖標（8 個）**
- ic_bluetooth.xml
- ic_device.xml
- ic_home.xml
- ic_warning.xml
- ic_warning_robot.xml
- ic_reset.xml
- ic_manager.xml
- ic_calendar.xml

**主從設置圖標（2 個）**
- ic_master.xml
- ic_master_big.xml

**最愛圖標（2 個）**
- ic_favorite_select.xml (已轉換為 SVG)
- ic_favorite_unselect.xml (已轉換為 SVG)

**縮放圖標（2 個）**
- ic_zoom_in.xml
- ic_zoom_out.xml

**其他圖標（3 個）**
- ic_solid_add.xml
- ic_green_check.xml
- ic_none.xml (場景圖標，已轉換)

**光通道拇指圖標（9 個）**
- ic_blue_light_thumb.xml
- ic_cold_white_light_thumb.xml
- ic_green_light_thumb.xml
- ic_moon_light_thumb.xml (已轉換)
- ic_purple_light_thumb.xml
- ic_red_light_thumb.xml
- ic_royal_blue_light_thumb.xml
- ic_strength_thumb.xml (已轉換)
- ic_uv_light_thumb.xml
- ic_warm_white_light_thumb.xml
- ic_default_thumb.xml (已轉換)

**週選擇圖標（14 個）**
- ic_monday_select.xml
- ic_monday_unselect.xml
- ic_tuesday_select.xml
- ic_tuesday_unselect.xml
- ic_wednesday_select.xml
- ic_wednesday_unselect.xml
- ic_thursday_select.xml
- ic_thursday_unselect.xml
- ic_friday_select.xml
- ic_friday_unselect.xml
- ic_saturday_select.xml
- ic_saturday_unselect.xml
- ic_sunday_select.xml
- ic_sunday_unselect.xml

**連接狀態圖標（4 個）**
- ic_connect.xml
- ic_connect_background.xml
- ic_disconnect.xml
- ic_disconnect_background.xml

**更多選項圖標（2 個）**
- ic_more_disable.xml
- ic_more_enable.xml

**其他圖標（背景、漸變等，暫不處理）**
- background_*.xml
- dialog_background.xml
- rainbow_gradient.xml
- img_*.xml

### 2.2 koralcore 中使用的圖標

需要掃描所有使用 Material Icons 的地方：
- Icons.add → ic_add_black.xml
- Icons.arrow_back → ic_back.xml
- Icons.delete → ic_delete.xml
- Icons.edit → ic_edit.xml
- Icons.close → ic_close.xml
- Icons.remove → ic_minus.xml
- Icons.play_arrow → ic_play_enabled.xml
- Icons.stop → ic_stop.xml
- Icons.favorite → ic_favorite_select.xml
- Icons.favorite_border → ic_favorite_unselect.xml
- 等等...

## 執行計劃

### 步驟 1: 字符串遷移
1. 讀取所有語言的 strings.xml
2. 提取所有字符串 key
3. 對照 ARB 文件，找出缺失的
4. 添加缺失的字符串到所有語言的 ARB 文件
5. 重新生成本地化文件

### 步驟 2: 圖標遷移
1. 將 XML drawable 轉換為 SVG
2. 添加到 assets/icons/ 目錄
3. 創建 IconHelper 類來管理圖標
4. 替換所有使用 Material Icons 的地方
5. 更新 pubspec.yaml

## 注意事項

1. **字符串命名對照**：
   - reef-b-app: `toast_xxx` → koralcore: `ledRecordsSnackXxx` 或對應的命名
   - 需要建立命名映射表

2. **圖標轉換**：
   - XML drawable 需要手動轉換為 SVG
   - 保持相同的視覺效果
   - 注意顏色和尺寸

3. **多語系**：
   - 確保所有語言都有對應的翻譯
   - 不要自行創造翻譯

4. **完整性**：
   - 必須全部掃描，不遺漏
   - 建立檢查清單

