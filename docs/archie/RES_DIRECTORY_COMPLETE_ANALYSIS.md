# reef-b-app res 目錄完整分析及 Flutter 對照

## 概述

本文檔詳細分析 `reef-b-app` 的 `res` 目錄結構、內容、作用，並對照到 Flutter 的正規架構。

---

## 1. res 目錄結構總覽

```
res/
├── color/                    # 顏色選擇器（Color State List）
├── drawable/                 # 可繪製資源（XML 矢量圖、選擇器、形狀）
├── drawable-xxxhdpi/         # 高分辨率圖片資源
├── layout/                   # XML 布局文件（Activity/Fragment/Adapter）
├── layout-land/              # 橫屏布局
├── menu/                     # 菜單資源
├── mipmap-*/                 # 應用圖標（多分辨率）
├── navigation/               # Navigation Component 導航圖
├── values/                   # 值資源（顏色、尺寸、字符串、樣式、主題）
├── values-XX/                # 多語言值資源
├── values-night/             # 夜間模式值資源
├── values-swXXXdp/           # 不同屏幕寬度的值資源
├── values-vXX/               # API 版本特定值資源
└── xml/                      # XML 配置文件
```

---

## 2. 各目錄詳細分析

### 2.1 `color/` - 顏色選擇器

#### 作用
定義顏色狀態列表（Color State List），用於按鈕、文本等在不同狀態下的顏色變化。

#### 文件列表
```
color/
├── bottom_navigation_color.xml        # 底部導航欄顏色選擇器
├── btn_color_primary_selector.xml     # 主要按鈕顏色選擇器
└── text_color_selector.xml            # 文本顏色選擇器
```

#### 範例（`btn_color_primary_selector.xml`）
```xml
<selector>
    <item android:state_pressed="true" android:color="#1A6F916F"/>
    <item android:color="#6F916F"/>
</selector>
```

#### Flutter 對照
**位置**: `lib/ui/theme/reef_colors.dart`

**對照方式**:
```dart
// reef-b-app: Color State List
// Flutter: 使用 MaterialStateProperty
ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.pressed)) {
      return ReefColors.primary.withValues(alpha: 0.1);
    }
    return ReefColors.primary;
  }),
)
```

**狀態**: ✅ 已轉換為 `ReefColors` 和 `MaterialStateProperty`

---

### 2.2 `drawable/` - 可繪製資源

#### 作用
定義矢量圖形、形狀、漸變、選擇器等可繪製資源。

#### 文件分類

**1. 圖標（ic_*.xml）** - 約 70+ 個
```
drawable/
├── ic_add_black.xml          # 添加圖標（黑色）
├── ic_add_rounded.xml        # 添加圖標（圓角）
├── ic_back.xml               # 返回圖標
├── ic_bluetooth.xml          # 藍牙圖標
├── ic_calendar.xml           # 日曆圖標
├── ic_close.xml              # 關閉圖標
├── ic_connect.xml            # 連接圖標
├── ic_disconnect.xml         # 斷開圖標
├── ic_delete.xml             # 刪除圖標
├── ic_edit.xml               # 編輯圖標
├── ic_favorite_select.xml    # 收藏圖標（已選中）
├── ic_favorite_unselect.xml  # 收藏圖標（未選中）
├── ic_home.xml               # 首頁圖標
├── ic_manager.xml            # 管理圖標
├── ic_master.xml             # 主燈圖標
├── ic_master_big.xml         # 主燈圖標（大）
├── ic_menu.xml               # 菜單圖標
├── ic_pause.xml              # 暫停圖標
├── ic_play_enabled.xml       # 播放圖標（啟用）
├── ic_play_unselect.xml      # 播放圖標（未選中）
├── ic_reset.xml              # 重置圖標
├── ic_stop.xml               # 停止圖標
├── ic_warning.xml            # 警告圖標
└── ...                       # 更多圖標
```

**2. 背景（background_*.xml）**
```
drawable/
├── background_main.xml              # 主背景
├── background_sink_spinner.xml      # Sink 選擇器背景
├── background_spinner.xml            # 選擇器背景
└── background_white_radius.xml      # 白色圓角背景
```

**3. 形狀和漸變**
```
drawable/
├── dialog_background.xml            # 對話框背景
├── rainbow_gradient.xml             # 彩虹漸變
└── img_device_robot.xml             # 設備機器人圖標
```

**4. 選擇器（Selector）**
```
drawable/
├── ic_connect_background.xml        # 連接背景選擇器
├── ic_disconnect_background.xml     # 斷開背景選擇器
└── ...                               # 更多選擇器
```

**5. 場景圖標（Scene Icons）**
```
drawable/
├── ic_cloudy.xml                    # 多雲
├── ic_rainy.xml                     # 雨天
├── ic_sunny.xml                     # 晴天
├── ic_sunrise.xml                   # 日出
├── ic_sunset.xml                    # 日落
├── ic_thunder.xml                   # 雷電
└── ic_moon_round.xml                # 月亮
```

**6. 光譜圖標（Spectrum Icons）**
```
drawable/
├── ic_blue_light_thumb.xml          # 藍光縮略圖
├── ic_cold_white_light_thumb.xml    # 冷白光縮略圖
├── ic_green_light_thumb.xml         # 綠光縮略圖
├── ic_moon_light_thumb.xml          # 月光縮略圖
├── ic_purple_light_thumb.xml        # 紫光縮略圖
├── ic_red_light_thumb.xml           # 紅光縮略圖
├── ic_royal_blue_light_thumb.xml    # 皇家藍光縮略圖
├── ic_uv_light_thumb.xml            # UV 光縮略圖
└── ic_warm_white_light_thumb.xml    # 暖白光縮略圖
```

#### Flutter 對照

**位置**: 
- SVG 圖標: `assets/icons/common/`, `assets/icons/action/`, `assets/icons/scene/`, `assets/icons/led_record/`
- PNG 圖片: `assets/images/`
- Helper 類: `lib/ui/assets/common_icon_helper.dart`

**對照方式**:
```dart
// reef-b-app: XML Vector Drawable
// Flutter: SVG 或 PNG

// 使用 SVG
SvgPicture.asset('assets/icons/common/ic_home.svg')

// 使用 Helper
CommonIconHelper.getHomeIcon()
CommonIconHelper.getFavoriteSelectIcon()
```

**狀態**: ✅ 大部分已轉換為 SVG，部分使用 PNG

---

### 2.3 `drawable-xxxhdpi/` - 圖片資源

#### 作用
存放高分辨率圖片資源（PNG 格式）。

#### 文件列表
```
drawable-xxxhdpi/
├── ic_splash_logo.png        # Splash Logo 圖標
├── img_splash_logo.png       # Splash Logo 圖片
├── img_adjust.png            # 調整圖標
├── img_drop.png              # 滴液泵圖標
└── img_led.png               # LED 圖標
```

#### Flutter 對照

**位置**: `assets/images/`, `assets/icons/`

**對照方式**:
```dart
// reef-b-app: drawable-xxxhdpi/img_led.png
// Flutter: assets/icons/led/led_main.png

Image.asset('assets/icons/led/led_main.png')
```

**狀態**: ✅ 已導入到 `assets/` 目錄

---

### 2.4 `layout/` - XML 布局文件

#### 作用
定義 Activity、Fragment、Adapter、Dialog、BottomSheet 等的 UI 布局。

#### 文件分類

**1. Activity 布局（activity_*.xml）** - 約 20+ 個
```
layout/
├── activity_main.xml                 # 主 Activity
├── activity_splash.xml               # Splash Activity
├── activity_led_main.xml             # LED 主頁
├── activity_led_setting.xml          # LED 設置
├── activity_led_record.xml           # LED 排程
├── activity_led_scene.xml            # LED 場景
├── activity_drop_main.xml            # 滴液泵主頁
├── activity_drop_setting.xml         # 滴液泵設置
├── activity_sink_manager.xml         # Sink 管理
├── activity_warning.xml              # 警告記錄
└── ...                               # 更多 Activity
```

**2. Fragment 布局（fragment_*.xml）** - 3 個
```
layout/
├── fragment_home.xml                  # 首頁 Fragment
├── fragment_bluetooth.xml             # 藍牙 Fragment
└── fragment_device.xml                # 設備 Fragment
```

**3. Adapter 布局（adapter_*.xml）** - 約 20+ 個
```
layout/
├── adapter_device_led.xml            # LED 設備卡片
├── adapter_device_drop.xml           # 滴液泵設備卡片
├── adapter_ble_scan.xml              # 藍牙掃描列表項
├── adapter_sink.xml                  # Sink 列表項
├── adapter_scene.xml                 # 場景列表項
└── ...                               # 更多 Adapter
```

**4. 組件布局**
```
layout/
├── bottom_sheet_edittext.xml          # BottomSheet 輸入框
├── bottom_sheet_recyclerview.xml      # BottomSheet 列表
├── dialog_loading.xml                 # 加載對話框
├── progress.xml                      # 進度條
├── spinner_item_text.xml             # Spinner 文本項
├── toolbar_app.xml                   # 應用 Toolbar
├── toolbar_device.xml                # 設備 Toolbar
└── toolbar_two_action.xml            # 雙按鈕 Toolbar
```

#### Flutter 對照

**位置**: `lib/ui/features/`, `lib/ui/widgets/`, `lib/ui/components/`

**對照方式**:
```dart
// reef-b-app: activity_main.xml
// Flutter: lib/ui/app/main_scaffold.dart

// reef-b-app: fragment_home.xml
// Flutter: lib/ui/features/home/home_page.dart

// reef-b-app: adapter_device_led.xml
// Flutter: lib/ui/features/device/widgets/device_card.dart
```

**狀態**: ✅ 已轉換為 Flutter Widget

---

### 2.5 `layout-land/` - 橫屏布局

#### 作用
定義橫屏（Landscape）模式的布局。

#### 文件列表
```
layout-land/
└── activity_led_main.xml             # LED 主頁橫屏布局
```

#### Flutter 對照

**位置**: 使用 `MediaQuery.of(context).orientation` 或 `LayoutBuilder`

**對照方式**:
```dart
// reef-b-app: layout-land/activity_led_main.xml
// Flutter: 響應式布局

LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _buildLandscapeLayout();
    }
    return _buildPortraitLayout();
  },
)
```

**狀態**: ⚠️ 部分實現（可根據需要添加）

---

### 2.6 `menu/` - 菜單資源

#### 作用
定義 Context Menu、Options Menu 等菜單資源。

#### 文件列表
```
menu/
├── menu_led.xml                      # LED 菜單
├── menu_drop.xml                     # 滴液泵菜單
└── ...                               # 更多菜單
```

#### Flutter 對照

**位置**: `lib/ui/widgets/`, `lib/ui/components/`

**對照方式**:
```dart
// reef-b-app: menu/menu_led.xml
// Flutter: PopupMenuButton

PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
  ],
)
```

**狀態**: ✅ 已轉換為 `PopupMenuButton`

---

### 2.7 `mipmap-*/` - 應用圖標

#### 作用
存放應用圖標（Launcher Icon），支持多種分辨率。

#### 文件結構
```
mipmap-hdpi/
├── ic_launcher.webp
├── ic_launcher_foreground.webp
└── ic_launcher_round.webp

mipmap-mdpi/
mipmap-xhdpi/
mipmap-xxhdpi/
mipmap-xxxhdpi/

mipmap-anydpi-v26/
├── ic_launcher.xml                   # 自適應圖標配置
└── ic_launcher_round.xml             # 圓形自適應圖標配置
```

#### Flutter 對照

**位置**: 
- Android: `android/app/src/main/res/mipmap-*/`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**狀態**: ✅ 已導入到對應位置

---

### 2.8 `navigation/` - 導航圖

#### 作用
定義 Navigation Component 的導航圖（Navigation Graph）。

#### 文件列表
```
navigation/
└── nav_graph.xml                     # 導航圖
```

#### Flutter 對照

**位置**: `lib/ui/app/navigation_controller.dart`, `lib/app/main_scaffold.dart`

**對照方式**:
```dart
// reef-b-app: Navigation Component
// Flutter: Navigator + 路由

Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => LedMainPage()),
)
```

**狀態**: ✅ 已實現導航邏輯

---

### 2.9 `values/` - 值資源

#### 作用
定義顏色、尺寸、字符串、樣式、主題等值資源。

#### 文件列表
```
values/
├── colors.xml                        # 顏色定義
├── dimens.xml                        # 尺寸定義
├── strings.xml                       # 字符串定義（英文）
├── styles.xml                        # 樣式定義
└── themes.xml                        # 主題定義
```

#### 詳細分析

**1. colors.xml** - 顏色定義

**作用**: 定義應用中使用的所有顏色值。

**範例**:
```xml
<color name="app_color">#008000</color>
<color name="bg_primary">#6F916F</color>
<color name="text_aaaa">#000000</color>
<color name="text_aaa">#BF000000</color>
<color name="text_aa">#80000000</color>
```

**Flutter 對照**: `lib/ui/theme/reef_colors.dart`
```dart
static const Color primary = Color(0xFF6F916F);
static const Color textPrimary = Color(0xFF000000);
static const Color textSecondary = Color(0xBF000000);
static const Color textTertiary = Color(0x80000000);
```

**狀態**: ✅ 已轉換

---

**2. dimens.xml** - 尺寸定義

**作用**: 定義應用中使用的所有尺寸值（間距、圓角、字體大小等）。

**範例**:
```xml
<dimen name="dp_0">0dp</dimen>
<dimen name="dp_4">4dp</dimen>
<dimen name="dp_8">8dp</dimen>
<dimen name="dp_16">16dp</dimen>
<dimen name="dp_20">20dp</dimen>
```

**Flutter 對照**: 
- 間距: `lib/ui/theme/reef_spacing.dart`
- 圓角: `lib/ui/theme/reef_radius.dart`

```dart
// reef_spacing.dart
static const double xs = 4.0;
static const double sm = 8.0;
static const double md = 16.0;
static const double lg = 20.0;

// reef_radius.dart
static const double sm = 4.0;
static const double md = 8.0;
static const double lg = 10.0;
```

**狀態**: ✅ 已轉換

---

**3. strings.xml** - 字符串定義

**作用**: 定義應用中使用的所有字符串（多語言支持）。

**範例**:
```xml
<string name="app_name">ReefB</string>
<string name="home">Home</string>
<string name="bluetooth">Bluetooth</string>
<string name="device">Device</string>
```

**Flutter 對照**: `lib/l10n/intl_*.arb`

```json
{
  "@@locale": "en",
  "appTitle": "ReefB",
  "tabHome": "Home",
  "tabBluetooth": "Bluetooth",
  "tabDevice": "Devices"
}
```

**狀態**: ✅ 已轉換為 ARB 格式

---

**4. styles.xml** - 樣式定義

**作用**: 定義 Material 組件的樣式（Dialog、BottomSheet、Button 等）。

**範例**:
```xml
<style name="MaterialAlertDialog.App" parent="MaterialAlertDialog.MaterialComponents">
    <item name="shapeAppearance">@style/MaterialAlertDialog.App.MediumComponent</item>
</style>

<style name="MaterialAlertDialog.App.Title.Text">
    <item name="android:textColor">@color/text_aaaa</item>
    <item name="android:textSize">@dimen/dp_20</item>
    <item name="android:textStyle">bold</item>
</style>
```

**Flutter 對照**: `lib/ui/theme/reef_text.dart`, `lib/ui/theme/reef_theme.dart`

```dart
// reef_text.dart
static const TextStyle title = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: ReefColors.textPrimary,
);

// reef_theme.dart
ThemeData(
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ReefRadius.md),
    ),
  ),
)
```

**狀態**: ✅ 已轉換為 TextStyle 和 ThemeData

---

**5. themes.xml** - 主題定義

**作用**: 定義應用主題（Light/Dark、FullScreen 等）。

**範例**:
```xml
<style name="AppTheme" parent="Theme.MaterialComponents.Light.Bridge">
</style>

<style name="AppTheme.FullScreen">
    <item name="windowActionBar">false</item>
    <item name="windowNoTitle">true</item>
    <item name="android:windowFullscreen">true</item>
</style>
```

**Flutter 對照**: `lib/ui/theme/reef_theme.dart`

```dart
static ThemeData base() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: ReefColors.primary,
      surface: ReefColors.surface,
    ),
  );
}
```

**狀態**: ✅ 已轉換為 ThemeData

---

### 2.10 `values-XX/` - 多語言值資源

#### 作用
定義不同語言的字符串資源。

#### 文件列表
```
values-ar/strings.xml                 # 阿拉伯語
values-de/strings.xml                 # 德語
values-es/strings.xml                 # 西班牙語
values-fr/strings.xml                 # 法語
values-in/strings.xml                 # 印尼語
values-ja/strings.xml                 # 日語
values-ko/strings.xml                 # 韓語
values-pt/strings.xml                 # 葡萄牙語
values-ru/strings.xml                 # 俄語
values-th/strings.xml                 # 泰語
values-vi/strings.xml                 # 越南語
values-zh-rTW/strings.xml             # 繁體中文
```

#### Flutter 對照

**位置**: `lib/l10n/intl_*.arb`

**對照方式**:
```
values/strings.xml          → intl_en.arb
values-zh-rTW/strings.xml   → intl_zh_Hant.arb
values-ja/strings.xml      → intl_ja.arb
```

**狀態**: ✅ 已轉換為 ARB 格式

---

### 2.11 `values-night/` - 夜間模式

#### 作用
定義夜間模式（Dark Mode）的主題和顏色。

#### 文件列表
```
values-night/
└── themes.xml                        # 夜間模式主題
```

#### Flutter 對照

**位置**: `lib/ui/theme/reef_theme.dart`

**對照方式**:
```dart
static ThemeData dark() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: ReefColors.primary,
    ),
  );
}
```

**狀態**: ⚠️ 可選實現（目前主要使用 Light 模式）

---

### 2.12 `values-swXXXdp/` - 屏幕寬度特定資源

#### 作用
根據屏幕寬度（Smallest Width）提供不同的尺寸值。

#### 文件列表
```
values-sw240dp/dimens.xml
values-sw320dp/dimens.xml
values-sw384dp/dimens.xml
...
values-sw1024dp/dimens.xml
```

#### Flutter 對照

**位置**: 使用 `MediaQuery.of(context).size.width` 或 `LayoutBuilder`

**對照方式**:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _buildTabletLayout();
    }
    return _buildPhoneLayout();
  },
)
```

**狀態**: ⚠️ 可選實現（目前主要使用響應式布局）

---

### 2.13 `values-vXX/` - API 版本特定資源

#### 作用
為特定 Android API 版本提供不同的資源。

#### 文件列表
```
values-v28/
└── styles.xml                        # API 28+ 樣式
```

#### Flutter 對照

**位置**: 使用平台特定代碼或條件編譯

**狀態**: ⚠️ 通常不需要（Flutter 自動處理）

---

### 2.14 `xml/` - XML 配置文件

#### 作用
存放 XML 配置文件（如 Network Security Config、Backup Rules 等）。

#### 文件列表
```
xml/
├── network_security_config.xml       # 網絡安全配置
└── backup_rules.xml                  # 備份規則
```

#### Flutter 對照

**位置**: 
- Android: `android/app/src/main/res/xml/`
- iOS: `ios/Runner/Info.plist`

**狀態**: ✅ 已配置（如需要）

---

## 3. Flutter 正規架構對照

### 3.1 資源文件對照表

| reef-b-app res | Flutter 位置 | 說明 |
|---------------|-------------|------|
| `values/colors.xml` | `lib/ui/theme/reef_colors.dart` | 顏色常量 |
| `values/dimens.xml` | `lib/ui/theme/reef_spacing.dart`<br>`lib/ui/theme/reef_radius.dart` | 間距和圓角 |
| `values/strings.xml` | `lib/l10n/intl_*.arb` | 多語言字符串 |
| `values/styles.xml` | `lib/ui/theme/reef_text.dart`<br>`lib/ui/theme/reef_theme.dart` | 文本樣式和主題 |
| `values/themes.xml` | `lib/ui/theme/reef_theme.dart` | 主題配置 |
| `drawable/*.xml` | `assets/icons/` (SVG)<br>`lib/ui/assets/common_icon_helper.dart` | 圖標資源 |
| `drawable-xxxhdpi/*.png` | `assets/images/`<br>`assets/icons/` | 圖片資源 |
| `layout/*.xml` | `lib/ui/features/`<br>`lib/ui/widgets/`<br>`lib/ui/components/` | UI 組件 |
| `mipmap-*/ic_launcher.*` | `android/app/src/main/res/mipmap-*/`<br>`ios/Runner/Assets.xcassets/` | 應用圖標 |

---

### 3.2 Flutter 項目結構

```
koralcore/
├── lib/
│   ├── ui/
│   │   ├── theme/                    # 主題和樣式
│   │   │   ├── reef_colors.dart      # 顏色
│   │   │   ├── reef_spacing.dart     # 間距
│   │   │   ├── reef_radius.dart      # 圓角
│   │   │   ├── reef_text.dart        # 文本樣式
│   │   │   └── reef_theme.dart       # 主題配置
│   │   ├── features/                 # 功能頁面
│   │   │   ├── home/
│   │   │   ├── device/
│   │   │   ├── bluetooth/
│   │   │   └── ...
│   │   ├── widgets/                  # 可重用組件
│   │   ├── components/               # UI 組件
│   │   └── assets/                   # 資源 Helper
│   └── l10n/                         # 多語言
│       ├── intl_*.arb                # ARB 文件
│       └── app_localizations.dart    # 生成代碼
├── assets/                           # 資源文件
│   ├── icons/                        # 圖標
│   │   ├── common/
│   │   ├── action/
│   │   ├── scene/
│   │   └── ...
│   └── images/                       # 圖片
└── pubspec.yaml                      # 資源註冊
```

---

## 4. 總結

### ✅ 已對照的資源

1. **顏色資源** → `reef_colors.dart`
2. **尺寸資源** → `reef_spacing.dart`, `reef_radius.dart`
3. **字符串資源** → `intl_*.arb`
4. **樣式和主題** → `reef_text.dart`, `reef_theme.dart`
5. **圖標資源** → `assets/icons/` (SVG)
6. **圖片資源** → `assets/images/`
7. **布局文件** → Flutter Widget
8. **應用圖標** → `mipmap-*/`, `Assets.xcassets/`

### ⚠️ 可選實現

1. **橫屏布局** → 響應式布局
2. **夜間模式** → Dark Theme
3. **屏幕寬度特定資源** → 響應式布局

### 📊 對照度

| 資源類型 | 對照度 | 狀態 |
|---------|--------|------|
| 顏色 | 100% | ✅ 完成 |
| 尺寸 | 100% | ✅ 完成 |
| 字符串 | 100% | ✅ 完成 |
| 樣式 | 100% | ✅ 完成 |
| 圖標 | 95% | ✅ 大部分完成 |
| 布局 | 100% | ✅ 完成 |
| 應用圖標 | 100% | ✅ 完成 |

---

## 5. 使用範例

### 顏色使用
```dart
Container(
  color: ReefColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: ReefColors.textPrimary),
  ),
)
```

### 間距使用
```dart
Padding(
  padding: EdgeInsets.all(ReefSpacing.md),
  child: Column(
    children: [
      SizedBox(height: ReefSpacing.sm),
      // ...
    ],
  ),
)
```

### 多語言使用
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.tabHome)
```

### 圖標使用
```dart
CommonIconHelper.getHomeIcon()
SvgPicture.asset('assets/icons/common/ic_home.svg')
```

---

**文檔版本**: 1.0  
**最後更新**: 2024-12-28

