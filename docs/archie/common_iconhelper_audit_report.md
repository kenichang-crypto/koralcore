# CommonIconHelper Audit Report

**日期**: 2026-02-11  
**範圍**: koralcore lib，對照 reef-b-app（僅參考，不修改）  
**目標**: 修正 CommonIconHelper 誤用（IconData vs SvgPicture）、const 錯誤、語法錯誤

---

## 1) CommonIconHelper 方法型別與位置表

全部 45 個公開靜態方法，回傳型別皆為 `SvgPicture`。

| Method | Return type | Location |
|--------|-------------|----------|
| `getAddIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:12` |
| `getBackIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:24` |
| `getDeleteIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:36` |
| `getEditIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:48` |
| `getCloseIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:60` |
| `getMinusIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:72` |
| `getCheckIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:84` |
| `getPlayIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:96` |
| `getStopIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:108` |
| `getPauseIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:120` |
| `getNextIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:132` |
| `getMenuIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:144` |
| `getManagerIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:157` |
| `getBluetoothIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:169` |
| `getConnectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:182` |
| `getDisconnectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:195` |
| `getDeviceIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:207` |
| `getHomeIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:219` |
| `getWarningIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:231` |
| `getResetIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:243` |
| `getConnectBackgroundIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:255` |
| `getDisconnectBackgroundIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:264` |
| `getMasterIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:276` |
| `getMasterBigIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:288` |
| `getZoomInIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:300` |
| `getZoomOutIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:312` |
| `getCalendarIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:324` |
| `getPreviewIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:336` |
| `getMoreEnableIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:348` |
| `getFavoriteSelectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:360` |
| `getFavoriteUnselectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:372` |
| `getPlaySelectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:384` |
| `getPlayUnselectIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:396` |
| `getAddBtnIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:409` |
| `getAddRoundedIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:422` |
| `getAddWhiteIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:435` |
| `getGreenCheckIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:448` |
| `getMoreDisableIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:461` |
| `getPlayDisableIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:474` |
| `getDownIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:487` |
| `getDropIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:500` |
| `getMoonRoundIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:513` |
| `getLedIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:526` |
| `getDosingIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:539` |
| `getSlowStartIcon` | `SvgPicture` | `lib/shared/assets/common_icon_helper.dart:551` |

---

## 2) 呼叫點與分類

總掃描 125 個呼叫點。需修正：`Icon(...)` 包裝 15 處、錯誤 `const` 4 處。

### 錯誤分類：wrapped_in_Icon（需改為直接 Widget）

| File | Line | Method | 原始片段 |
|------|------|--------|----------|
| `device_card.dart` | 85-86 | getLedIcon, getDropIcon | `Icon(...) ? CommonIconHelper.getLedIcon() : CommonIconHelper.getDropIcon()` |
| `device_card.dart` | 126, 130 | getConnectIcon, getDisconnectIcon | `Icon(CommonIconHelper.getConnectIcon/getDisconnectIcon)` |
| `home_tab_page.dart` | 494, 499 | getConnectIcon, getDisconnectIcon | `Icon(CommonIconHelper.getConnectIcon/getDisconnectIcon)` |
| `led_record_page.dart` | 322 | getMoreEnableIcon | `const Icon(CommonIconHelper.getMoreEnableIcon(), size: 24, ...)` |
| `led_record_setting_page.dart` | 488 | getMoonRoundIcon | `const Icon(CommonIconHelper.getMoonRoundIcon(), size: 20, ...)` |
| `led_scene_delete_page.dart` | 201 | getCheckIcon | `const Icon(CommonIconHelper.getCheckIcon(), size: 16, ...)` |
| `led_scene_list_page.dart` | 453-454 | getPlaySelectIcon, getPlayUnselectIcon | `Icon(...CommonIconHelper.getPlaySelectIcon/getPlayUnselectIcon)` |
| `led_scene_list_page.dart` | 472-473 | getFavoriteSelectIcon, getFavoriteUnselectIcon | `Icon(...CommonIconHelper.getFavoriteSelectIcon/getFavoriteUnselectIcon)` |
| `led_schedule_list_page.dart` | 282-283 | getCheckIcon, getPlayIcon | `Icon(...CommonIconHelper.getCheckIcon/getPlayIcon)` |
| `led_main_record_chart_section.dart` | 78-79 | getStopIcon, getPreviewIcon | `Icon(...CommonIconHelper.getStopIcon/getPreviewIcon)` |

### 錯誤分類：const 問題（4 處）

| File | Line | 原始片段 |
|------|------|----------|
| `led_record_page.dart` | 273 | `icon: const CommonIconHelper.getAddBtnIcon(), size: 24)` |
| `led_record_setting_page.dart` | 296 | `const CommonIconHelper.getDownIcon(), size: 24)` |
| `led_record_setting_page.dart` | 350 | `const CommonIconHelper.getDownIcon(), size: 24)` |
| `led_record_time_setting_page.dart` | 168 | `const CommonIconHelper.getDownIcon(), size: 24)` |

### 錯誤分類：_ControlButton 期待 IconData

| File | Line | 說明 |
|------|------|------|
| `led_record_page.dart` | 191, 195, 200, 205, 210 | `_ControlButton(icon: CommonIconHelper.getXxxIcon())` 傳入 SvgPicture，但 `_ControlButton` 宣告 `IconData icon` |

---

## 3) reef-b-app icon 對照

### Android drawable 對應

- `ic_add_btn`, `ic_down`, `ic_moon_round`, `ic_add_black`, `ic_check` 等：✅ 已有 svg
- `app_icon`, `img_adjust`, `img_device_robot`：⚠️ missing svg（需人工確認是否在本次遷移範圍）

### Icons.xxx 例外（暫不改動）

- `dosing_main_page.dart`: Icons.edit, Icons.delete, Icons.refresh
- `drop_setting_page.dart`, `pump_head_settings_page.dart`: Icons.check
- `scene_icon_helper.dart`, `led_scene_*.dart`: Icons.circle_outlined, Icons.image, Icons.auto_awesome 等 fallback

---

## 4) 修正建議

### 原則

- ✅ 正確：`CommonIconHelper.getXxxIcon(size: 24, color: ...)` 直接當 Widget
- ❌ 錯誤：`Icon(CommonIconHelper.getXxxIcon(), size: 24, ...)`
- ❌ 錯誤：`const CommonIconHelper.getXxxIcon()`（方法呼叫非 const）

### 本次修正清單

1. 將 `Icon(CommonIconHelper.getXxxIcon())` 改為 `CommonIconHelper.getXxxIcon(size: n, color: ...)`
2. 移除 `const CommonIconHelper.getXxxIcon()` 的 `const`，修復語法 `, size: 24)`
3. `_ControlButton` 改為接受 `Widget icon` 而非 `IconData icon`
4. `led_record_time_setting_page.dart`、`led_scene_delete_page.dart` 補上 `common_icon_helper` import

---

## 5) 修正完成記錄（2026-02-11）

| 檔案 | 修正內容 |
|------|----------|
| `device_card.dart` | errorBuilder 內 `Icon(CommonIconHelper.getLedIcon/getDropIcon)` → 直接使用 `CommonIconHelper.getLedIcon/getDropIcon(size: 32, color: ...)` |
| `led_record_page.dart` | `_ControlButton` 改為 `Widget icon`；5 處按鈕傳入 `getXxxIcon(size: 24)`；L273 移除 const、修復語法；L321 Icon 包裝改為直接 `getMoreEnableIcon(size: 24, color: ...)` |
| `led_record_setting_page.dart` | 2 處 `const CommonIconHelper.getDownIcon(), size: 24)` → `CommonIconHelper.getDownIcon(size: 24)`；1 處 `Icon(getMoonRoundIcon)` → `getMoonRoundIcon(size: 20, color: ...)` |
| `led_record_time_setting_page.dart` | 新增 import；`const CommonIconHelper.getDownIcon(), size: 24)` → `CommonIconHelper.getDownIcon(size: 24)` |
| `led_scene_delete_page.dart` | 新增 import；`Icon(CommonIconHelper.getCheckIcon)` → `Center(child: CommonIconHelper.getCheckIcon(size: 16, color: Colors.white))` |

**Linter 結果**：`ReadLints` 於上述檔案無錯誤。
