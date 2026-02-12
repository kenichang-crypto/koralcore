# UX Assets Parity 分析：Icon、文字、顏色

檢視 koralcore 的 icon / 文字 / 顏色是否依 **Flutter 結構** 建立，並與 reef-b-app 忠實對照。

---

## 一、Icon（圖示）

### 1.1 Flutter 結構

| 層級 | koralcore 實作 | 說明 |
|------|----------------|------|
| **資產來源** | `assets/icons/*.svg` | 由 reef-b-app `res/drawable/*.xml` 轉為 SVG |
| **存取層** | `CommonIconHelper` | 靜態方法，封裝 path + `SvgPicture.asset` |
| **語意對照** | 註解標註 reef drawable id | 例：`// ic_add_black` |
| **顏色覆寫** | `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)` | 支援動態 tint |

### 1.2 與 reef-b-app 對照

| reef drawable | koralcore | 對齊 |
|---------------|-----------|------|
| ic_add_black.xml | ic_add_black.svg | ✅ |
| ic_back.xml | ic_back.svg | ✅ |
| ic_delete.xml | ic_delete.svg | ✅ |
| ic_edit.xml | ic_edit.svg | ✅ |
| ic_check.xml | ic_check.svg | ✅ |
| ic_play_enabled.xml | ic_play_enabled.svg | ✅ |
| ic_reset.xml | ic_reset.svg | ✅ |
| ic_connect_background.xml | ic_connect_background.svg | ✅ |
| ic_disconnect_background.xml | ic_disconnect_background.svg | ✅ |
| ic_favorite_select / unselect | ic_favorite_select/unselect.svg | ✅ |
| ic_menu.xml | ic_menu.svg | ✅ |
| ic_more_enable.xml | ic_more_enable.svg | ✅ |
| ic_next.xml | ic_next.svg | ✅ |
| ...（其餘約 50+ drawable） | 皆有對應 SVG | ✅ |

### 1.3 Icon 對照完成（已修正）

| 檔案 | reef 對應 | 修正內容 |
|------|-----------|----------|
| dosing_main_page.dart | ic_delete | `CommonIconHelper.getDeleteIcon` |
| pump_head_schedule_page.dart | ic_delete | `CommonIconHelper.getDeleteIcon` |
| pump_head_calibration_page.dart | ic_strength_thumb | `CommonIconHelper.getStrengthThumbIcon` |
| led_scene_list_page.dart | - | 移除 Icons.auto_awesome overlay（reef 無）；fallback 改為 `SceneIconHelper` ic_none |
| scene_icon_helper.dart | ic_none | fallback 改為 `SvgPicture.asset('assets/icons/ic_none.svg')` |
| ble_guard.dart (core/ble) | ic_menu, ic_warning, ic_bluetooth, ic_none, ic_device | 全部改用 CommonIconHelper |
| error_state_widget.dart | ic_warning | `CommonIconHelper.getWarningIcon` |

### 1.4 reef_material_icons.dart

- `reef_material_icons.dart` 為 **Material Icons 別名**，非 reef drawable
- 使用方式：`ReefMaterialIcons.delete` = `Icons.delete`
- **與 A1 衝突**：應優先使用 `CommonIconHelper` 提供的 reef SVG

---

## 二、文字（Text / l10n）

### 2.1 Flutter 結構

| 層級 | koralcore 實作 | 說明 |
|------|----------------|------|
| **來源** | `lib/l10n/intl_*.arb` | Flutter 標準 ARB |
| **生成** | `flutter gen-l10n` → `AppLocalizations` | 符合官方流程 |
| **模板** | `intl_en.arb` | `template-arb-file` |
| **語系** | 14 語（en, zh, zh_Hant, de, es, fr, ar, id, ja, ko, pt, ru, th, vi） | 對齊 reef values-* |

### 2.2 與 reef strings.xml 對照

| 類型 | reef | koralcore | 對齊方式 |
|------|------|-----------|----------|
| 動詞 | confirm, cancel, save, delete, skip, complete | actionConfirm, actionCancel, actionSave, actionDelete, actionSkip, actionDone | ✅ 語意對應 |
| 區塊標題 | device_name, sink_position, delay_time | deviceName, sinkPosition, delayTime | ✅ |
| 錯誤/成功 | toast_* | toastDeleteDeviceSuccessful 等 | ✅ |
| 設備狀態 | device_is_not_connect | homeStatusDisconnected | ✅ |
| 轉速 | low_rotating_speed, middle_rotating_speed, high_rotating_speed | dosingRotatingSpeedLow/Medium/High | ✅ |

### 2.3 多語言必要字串（已修正）

| 項目 | reef key | koralcore 狀態 |
|------|----------|----------------|
| drop | drop / 滴液泵 | ✅ 已補 ARB `drop`，14 語系對照 reef |
| delay fallback | _15sec~_5min | ✅ `delaySecondsFallback` 已補，移除 hardcoded `'$seconds sec'` |
| 部分 pump_head_record_setting | drop_record_time 等 | 僅對照 reef，不補 ARB（依需求） |

---

## 三、顏色（Color）

### 3.1 Flutter 結構

| 層級 | koralcore 實作 | 說明 |
|------|----------------|------|
| **集中定義** | `AppColors`（靜態 const） | 單一來源 |
| **語意命名** | primary, surface, textPrimary 等 | 語意化 |
| **reef 對照** | 註解標註 colors.xml 名稱 | 例：`// bg_primary` |

### 3.2 與 reef colors.xml 數值對照

| reef | koralcore | 數值 | 對齊 |
|------|-----------|------|------|
| bg_primary | primary | #6F916F | ✅ |
| bg_secondary | primaryStrong | #517651 | ✅ |
| bg_primary_38 | primaryOverlay | #616F916F | ✅ |
| bg_aaaa | surface | #FFFFFF | ✅ |
| bg_aaa | surfaceMuted | #F7F7F7 | ✅ |
| text_aaaa | textPrimary | #000000 | ✅ |
| text_aaaa_40 | textDisabled | #66000000 | ✅ |
| text_aaa | textSecondary | #BF000000 | ✅ |
| text_aa | textTertiary | #80000000 | ✅ |
| text_a | divider | #33000000 | ✅ |
| bg_press | surfacePressed | #0D000000 | ✅ |
| text_success | success | #52D175 | ✅ |
| text_info | info | #47A9FF | ✅ |
| text_waring | warning | #FFC10A | ✅ |
| text_danger | danger | #FF7D4F | ✅ |
| ripple_color | outline | #808080 | ✅ |
| moon_light_color | moonLight | #FF9955 | ✅ |
| warm_white / cold_white | warmWhite, coldWhite | ✅ | ✅ |
| dashboard_track / progress | dashboardTrack, dashboardProgress | ✅ | ✅ |
| grey | grey (= textSecondary) | reef #A6A6A6 | ⚠️ koralcore 用 textSecondary (#BF000000)，語意不同 |

### 3.3 差異說明

- **grey**：reef `#A6A6A6` 為獨立灰階；koralcore 以 `textSecondary` 作為 `grey` 別名，數值不同
- 其餘主要語意色與 reef 對齊

---

## 四、總結

| 類別 | Flutter 結構 | 對照 reef | 缺口 |
|------|--------------|-----------|------|
| **Icon** | ✅ CommonIconHelper + assets/icons/*.svg | ✅ 多數 drawable 有對應 | 仍有 Icons.* 用於 delete、ble_guard、scene fallback 等 |
| **文字** | ✅ ARB + AppLocalizations | ✅ 主要 key 已對應 | 部分 TODO 字串、drop 等 key 待補 |
| **顏色** | ✅ AppColors 集中定義 | ✅ 主要色值對齊 | grey 數值與 reef 不同 |

### 建議修正優先序

1. **Icon**：將 `Icons.delete`、`Icons.delete_outline` 改為 `CommonIconHelper.getDeleteIcon`
2. **文字**：將剩餘 TODO 字串補齊 ARB，並對照 reef strings.xml
3. **顏色**：若需完全一致，可新增 `AppColors.grey = Color(0xFFA6A6A6)`，與 reef `grey` 分離
