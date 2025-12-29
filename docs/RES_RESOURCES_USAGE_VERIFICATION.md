# res 資源使用驗證報告

## 檢查日期
2024-12-28

---

## 一、資源對照狀態

### ✅ 已正確轉換和使用的資源

#### 1. **顏色資源（colors.xml）**

**reef-b-app**: `res/values/colors.xml`
**koralcore**: `lib/ui/theme/reef_colors.dart`

**狀態**: ✅ **已正確轉換和使用**

**對照示例**:
- `main_activity_background_start_color: #EFEFEF` → `ReefColors.backgroundGradientStart = Color(0xFFEFEFEF)` ✅
- `main_activity_background_end_color: #00FFFFFF` → `ReefColors.backgroundGradientEnd = Color(0x00000000)` ✅
- 所有顏色值已正確轉換 ✅

**使用位置**:
- `lib/ui/widgets/reef_backgrounds.dart` - 使用 `ReefColors.backgroundGradientStart/End` ✅
- `lib/ui/theme/reef_theme.dart` - 使用 `ReefColors` ✅

---

#### 2. **尺寸資源（dimens.xml）**

**reef-b-app**: `res/values/dimens.xml`
**koralcore**: 
- `lib/ui/theme/reef_spacing.dart` (間距)
- `lib/ui/theme/reef_radius.dart` (圓角)

**狀態**: ✅ **已正確轉換和使用**

**對照示例**:
- `dp_8` → `ReefSpacing.xs = 8.0` ✅
- `dp_16` → `ReefSpacing.md = 16.0` ✅
- 所有尺寸值已正確轉換 ✅

**使用位置**:
- 所有 UI 頁面都使用 `ReefSpacing` 和 `ReefRadius` ✅

---

#### 3. **字符串資源（strings.xml）**

**reef-b-app**: `res/values/strings.xml` + 多語言版本
**koralcore**: `lib/l10n/intl_*.arb`

**狀態**: ✅ **已正確轉換和使用**

**對照方式**:
- XML 字符串 → Flutter l10n ARB 格式 ✅
- 使用 `AppLocalizations.of(context)` 訪問 ✅

**使用位置**:
- 所有 UI 頁面都使用 `l10n.xxx` 訪問本地化字符串 ✅

---

#### 4. **背景資源（drawable/background_*.xml）**

**reef-b-app**: `res/drawable/background_main.xml`
**koralcore**: `lib/ui/widgets/reef_backgrounds.dart`

**狀態**: ✅ **已正確轉換**

**轉換內容**:
- `background_main.xml` → `ReefMainBackground` Widget ✅
- `dialog_background.xml` → `ReefDialogBackground` Widget ✅
- `background_white_radius.xml` → `ReefWhiteRoundedBackground` Widget ✅

**顏色值對照**:
- 起始色: `#EFEFEF` ✅
- 結束色: `#00FFFFFF` (透明) ✅
- 角度: 225度 ✅

**使用狀態**: ⚠️ **需要確認是否在首頁使用**

---

#### 5. **圖片資源（PNG）**

**reef-b-app**: `res/drawable-xxxhdpi/*.png`
**koralcore**: `assets/images/` 和 `assets/icons/`

**狀態**: ✅ **已導入**

**已導入的圖片**:
- ✅ `ic_splash_logo.png` → `assets/images/splash/ic_splash_logo.png`
- ✅ `img_splash_logo.png` → `assets/images/splash/img_splash_logo.png`
- ✅ `img_adjust.png` → `assets/images/img_adjust.png`
- ✅ `img_led.png` → `assets/icons/led/led_main.png` (已轉換)
- ✅ `img_drop.png` → `assets/icons/dosing/dosing_main.png` (已轉換)

**使用狀態**: ✅ **已在對應頁面使用**

---

### ⚠️ 需要檢查的資源

#### 1. **首頁相關圖標（XML Drawable）**

**reef-b-app 首頁使用的圖標**:
- `ic_add_rounded.xml` - 添加 Sink 按鈕
- `ic_warning.xml` - 警告按鈕
- `ic_down.xml` - 下拉箭頭
- `ic_manager.xml` - Sink 管理按鈕

**koralcore 狀態**: ⚠️ **需要檢查**

**檢查項目**:
1. 這些圖標是否已轉換為 Material Icons？
2. 是否在 `reef_material_icons.dart` 中定義？
3. 是否在首頁代碼中使用？

**當前首頁代碼** (`lib/ui/features/home/home_page.dart`):
- 警告按鈕使用: `Icon(Icons.warning)` ✅
- 其他圖標: ❓ **需要確認**

---

#### 2. **設備卡片圖標**

**reef-b-app**: `adapter_device_led.xml` 中使用的圖標:
- `img_led` - LED 設備圖片
- `ic_disconnect` / `ic_connect` - BLE 連接狀態
- `ic_favorite_unselect` / `ic_favorite_select` - 喜愛圖標
- `ic_master` - Master 圖標
- `ic_check` - 勾選圖標

**koralcore 狀態**: ⚠️ **需要檢查**

**檢查項目**:
1. 設備卡片是否使用對應的圖標？
2. 圖標路徑是否正確？

---

#### 3. **布局文件（layout/*.xml）**

**reef-b-app**: `res/layout/fragment_home.xml`
**koralcore**: `lib/ui/features/home/home_page.dart`

**狀態**: ⚠️ **布局結構不完全匹配**

**對照檢查**:

| reef-b-app (XML) | koralcore (Dart) | 狀態 |
|------------------|------------------|------|
| `background_main` | `ReefColors.primaryStrong` | ❌ **不匹配** - 應該是 `ReefMainBackground` |
| `btn_add_sink` (隱藏) | 無 | ❌ **缺失** |
| `btn_warning` | `AppBar.actions[IconButton]` | ⚠️ **位置不同** - 應該在頂部，不在 AppBar |
| `sp_sink_type` (Spinner) | 無 | ❌ **缺失** |
| `img_down` | 無 | ❌ **缺失** |
| `btn_sink_manager` | 無 | ❌ **缺失** |
| `rv_user_device` (RecyclerView) | `_DeviceSection` | ⚠️ **結構不同** |
| `layout_no_device_in_sink` | 無 | ❌ **缺失** |

---

## 二、資源使用問題總結

### ❌ 主要問題

1. **背景資源未正確使用**
   - 當前: 使用 `ReefColors.primaryStrong` (深色)
   - 應該: 使用 `ReefMainBackground` (淺色漸變)
   - 位置: `lib/ui/features/home/home_page.dart` line 28

2. **首頁圖標缺失**
   - `ic_add_rounded` - 添加 Sink 按鈕圖標
   - `ic_down` - 下拉箭頭圖標
   - `ic_manager` - Sink 管理按鈕圖標
   - 需要確認是否在 `reef_material_icons.dart` 中定義

3. **布局結構不匹配**
   - 缺少 Sink 選擇器（Spinner）
   - 缺少頂部按鈕區域（應該移除 AppBar）
   - 缺少空狀態顯示

4. **設備卡片圖標**
   - 需要確認設備卡片使用的圖標是否正確
   - 需要確認 BLE 連接狀態圖標
   - 需要確認喜愛圖標

---

## 三、建議修復步驟

### 步驟 1: 檢查圖標資源

1. 檢查 `lib/ui/assets/reef_material_icons.dart` 是否包含首頁需要的圖標
2. 如果沒有，添加對應的 Material Icons 映射

### 步驟 2: 修復背景資源

1. 在 `home_page.dart` 中使用 `ReefMainBackground` 替換 `ReefColors.primaryStrong`
2. 調整文字顏色以適應淺色背景

### 步驟 3: 修復布局結構

1. 移除 AppBar
2. 添加頂部按鈕區域
3. 添加 Sink 選擇器
4. 實現動態設備列表
5. 添加空狀態顯示

---

## 四、資源對照表

### 首頁相關資源

| reef-b-app 資源 | koralcore 位置 | 狀態 | 備註 |
|----------------|---------------|------|------|
| `background_main.xml` | `reef_backgrounds.dart` | ✅ 已轉換 | ⚠️ 未在首頁使用 |
| `ic_add_rounded.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |
| `ic_warning.xml` | `Icons.warning` | ✅ 已使用 | 位置不對（在 AppBar） |
| `ic_down.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |
| `ic_manager.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |
| `fragment_home.xml` | `home_page.dart` | ⚠️ 部分匹配 | 結構不同 |

### 設備卡片相關資源

| reef-b-app 資源 | koralcore 位置 | 狀態 | 備註 |
|----------------|---------------|------|------|
| `adapter_device_led.xml` | `_HomeDeviceTile` | ⚠️ 部分匹配 | 結構不同 |
| `img_led.png` | `assets/icons/device/device_led.png` | ✅ 已導入 | 需要確認使用 |
| `ic_disconnect.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |
| `ic_favorite_*.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |
| `ic_master.xml` | `reef_material_icons.dart` | ❓ 待確認 | 需要檢查 |

---

## 五、結論

### ✅ 已正確使用的資源

1. **顏色資源** - 完全正確 ✅
2. **尺寸資源** - 完全正確 ✅
3. **字符串資源** - 完全正確 ✅
4. **背景 Widget** - 已轉換，但未在首頁使用 ⚠️
5. **圖片資源** - 已導入並使用 ✅

### ❌ 需要修復的問題

1. **首頁背景** - 應該使用 `ReefMainBackground`，而不是深色背景
2. **首頁圖標** - 需要確認所有圖標是否已定義
3. **布局結構** - 需要完全匹配 reef-b-app 的布局
4. **設備卡片** - 需要確認圖標使用是否正確

---

## 六、下一步行動

1. ✅ 檢查 `reef_material_icons.dart` 是否包含所有需要的圖標
2. ✅ 修復首頁背景（使用 `ReefMainBackground`）
3. ✅ 修復首頁布局結構（移除 AppBar，添加 Sink 選擇器等）
4. ✅ 確認設備卡片圖標使用是否正確

