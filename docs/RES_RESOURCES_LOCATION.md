# res 資源在 koralcore 中的位置

## 概述

`reef-b-app` 的 `res` 資源已經被轉換和導入到 `koralcore` 的不同位置，因為 Flutter 使用不同的資源管理系統。

---

## 資源對照表

### 1. 圖片資源（PNG/WebP）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/
├── drawable-xxxhdpi/
│   ├── ic_splash_logo.png
│   ├── img_splash_logo.png
│   ├── img_adjust.png
│   ├── img_drop.png
│   └── img_led.png
└── mipmap-xxxhdpi/
    ├── ic_launcher.webp
    ├── ic_launcher_foreground.webp
    └── ic_launcher_round.webp
```

#### koralcore 位置
```
koralcore/
├── assets/
│   ├── images/
│   │   ├── splash/
│   │   │   ├── ic_splash_logo.png          ← drawable-xxxhdpi/ic_splash_logo.png
│   │   │   └── img_splash_logo.png         ← drawable-xxxhdpi/img_splash_logo.png
│   │   └── img_adjust.png                  ← drawable-xxxhdpi/img_adjust.png
│   └── icons/
│       ├── led/
│       │   └── led_main.png                ← img_led.png (已轉換)
│       ├── dosing/
│       │   └── dosing_main.png             ← img_drop.png (已轉換)
│       ├── device/
│       │   ├── device_led.png
│       │   ├── device_doser.png
│       │   └── device_empty.png
│       ├── bluetooth/
│       │   └── bluetooth_main.png
│       └── home/
│           ├── home_header.png
│           ├── home_led.png
│           └── home_dosing.png
```

---

### 2. 應用圖標（Android）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/
├── mipmap-hdpi/
│   ├── ic_launcher.webp
│   ├── ic_launcher_foreground.webp
│   └── ic_launcher_round.webp
├── mipmap-mdpi/
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
├── mipmap-xxxhdpi/
└── mipmap-anydpi-v26/
    ├── ic_launcher.xml
    └── ic_launcher_round.xml
```

#### koralcore 位置
```
koralcore/android/app/src/main/res/
├── mipmap-hdpi/
│   ├── ic_launcher.webp                   ← 已複製
│   ├── ic_launcher_foreground.webp       ← 已複製
│   └── ic_launcher_round.webp             ← 已複製
├── mipmap-mdpi/                          ← 所有分辨率已複製
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
├── mipmap-xxxhdpi/
├── mipmap-anydpi-v26/
│   ├── ic_launcher.xml                    ← 已配置
│   └── ic_launcher_round.xml              ← 已配置
└── drawable/
    ├── ic_launcher_background.xml         ← 已配置
    └── ic_launcher_foreground.xml         ← 已配置
```

---

### 3. 應用圖標（iOS）

#### reef-b-app 位置
```
reef-b-app/ios/ReefB_iOS/Reefb/Assets.xcassets/AppIcon.appiconset/
```

#### koralcore 位置
```
koralcore/ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png                  ← 已生成
├── Icon-App-20x20@2x.png                  ← 已生成
├── Icon-App-20x20@3x.png                  ← 已生成
├── Icon-App-29x29@1x.png                  ← 已生成
├── Icon-App-29x29@2x.png                  ← 已生成
├── Icon-App-29x29@3x.png                  ← 已生成
├── Icon-App-40x40@1x.png                  ← 已生成
├── Icon-App-40x40@2x.png                  ← 已生成
├── Icon-App-40x40@3x.png                  ← 已生成
├── Icon-App-60x60@2x.png                  ← 已生成
├── Icon-App-60x60@3x.png                  ← 已生成
├── Icon-App-76x76@1x.png                  ← 已生成
├── Icon-App-76x76@2x.png                  ← 已生成
├── Icon-App-83.5x83.5@2x.png             ← 已生成
├── Icon-App-1024x1024@1x.png             ← 已生成
└── Contents.json                          ← 已配置
```

---

### 4. 顏色資源（colors.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/colors.xml
```

#### koralcore 位置
```
koralcore/lib/ui/theme/reef_colors.dart    ← 已轉換為 Flutter Color 常量
```

**對照方式**：
- XML 顏色值 → Dart `Color` 常量
- 例如：`<color name="primary">#0175C2</color>` → `static const Color primary = Color(0xFF0175C2);`

---

### 5. 尺寸資源（dimens.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/dimens.xml
```

#### koralcore 位置
```
koralcore/lib/ui/theme/
├── reef_spacing.dart                      ← 間距常量
└── reef_radius.dart                       ← 圓角半徑常量
```

**對照方式**：
- XML 尺寸值 → Dart `double` 常量
- 例如：`<dimen name="dp_8">8dp</dimen>` → `static const double xs = 8.0;`

---

### 6. 字符串資源（strings.xml）

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/values/strings.xml
reef-b-app/android/ReefB_Android/app/src/main/res/values-*/strings.xml
```

#### koralcore 位置
```
koralcore/lib/l10n/
├── app_localizations.dart                 ← 主類
├── app_localizations_*.dart               ← 各語言實現
└── intl_*.arb                            ← ARB 文件（多語言）
```

**對照方式**：
- XML 字符串 → Flutter l10n 系統
- 使用 `AppLocalizations.of(context)` 訪問

---

### 7. XML Drawable 資源

#### reef-b-app 位置
```
reef-b-app/android/ReefB_Android/app/src/main/res/drawable/
├── ic_*.xml                               ← 圖標（約 70+ 個）
├── background_*.xml                       ← 背景（約 5 個）
├── dialog_background.xml
└── rainbow_gradient.xml
```

#### koralcore 位置
```
koralcore/lib/ui/
├── assets/
│   └── reef_material_icons.dart           ← Material Icons 映射（常用圖標）
└── widgets/
    ├── reef_backgrounds.dart              ← 背景 Widget
    └── reef_gradients.dart                ← 漸變 Widget
```

**對照方式**：
- XML 圖標 → Flutter Material Icons 或自定義 Widget
- XML 背景 → Flutter `Container` + `BoxDecoration`
- XML 漸變 → Flutter `LinearGradient`

---

### 8. 參考資源（保留在 docs）

#### koralcore 位置
```
koralcore/docs/reef_b_app_res/
├── drawable/                              ← 原始 XML drawable（參考用）
├── drawable-xxxhdpi/                      ← 原始 PNG 圖片（參考用）
├── mipmap-xxxhdpi/                        ← 原始圖標（參考用）
├── values/                                ← 原始 XML 資源（參考用）
└── ...                                    ← 其他參考資源
```

**用途**：作為參考，不直接使用

---

## 資源使用方式

### 在代碼中使用圖片

```dart
// 使用圖片資源
Image.asset('assets/images/splash/img_splash_logo.png')
Image.asset('assets/icons/led/led_main.png')

// 或使用常量
import 'package:koralcore/ui/assets/reef_icons.dart';
Image.asset(kSplashLogo)
Image.asset(kAdjustIcon)
```

### 在代碼中使用顏色

```dart
import 'package:koralcore/ui/theme/reef_colors.dart';

Container(
  color: ReefColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: ReefColors.textPrimary),
  ),
)
```

### 在代碼中使用尺寸

```dart
import 'package:koralcore/ui/theme/reef_spacing.dart';
import 'package:koralcore/ui/theme/reef_radius.dart';

Container(
  padding: EdgeInsets.all(ReefSpacing.md),
  margin: EdgeInsets.symmetric(horizontal: ReefSpacing.lg),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(ReefRadius.md),
  ),
)
```

### 在代碼中使用字符串

```dart
import 'package:koralcore/l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context);
Text(l10n.tabHome)
```

---

## 資源註冊

### pubspec.yaml

```yaml
flutter:
  assets:
    - assets/icons/
    - assets/icons/home/
    - assets/icons/device/
    - assets/icons/dosing/
    - assets/icons/led/
    - assets/icons/bluetooth/
    - assets/images/
    - assets/images/splash/
```

---

## 總結

### 資源位置對照

| reef-b-app res | koralcore 位置 | 狀態 |
|---------------|---------------|------|
| `drawable-xxxhdpi/*.png` | `assets/images/` 或 `assets/icons/` | ✅ 已導入 |
| `mipmap-*/ic_launcher.webp` | `android/app/src/main/res/mipmap-*/` | ✅ 已導入 |
| `mipmap-anydpi-v26/*.xml` | `android/app/src/main/res/mipmap-anydpi-v26/` | ✅ 已配置 |
| iOS 圖標 | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | ✅ 已配置 |
| `values/colors.xml` | `lib/ui/theme/reef_colors.dart` | ✅ 已轉換 |
| `values/dimens.xml` | `lib/ui/theme/reef_spacing.dart` + `reef_radius.dart` | ✅ 已轉換 |
| `values/strings.xml` | `lib/l10n/` | ✅ 已轉換 |
| `drawable/*.xml` | `lib/ui/assets/reef_material_icons.dart` + `lib/ui/widgets/` | ✅ 已轉換 |
| 參考資源 | `docs/reef_b_app_res/` | ✅ 已保留 |

---

## 快速查找

### 查找圖片資源
```bash
# 查看所有圖片
find assets -name "*.png" -o -name "*.webp"

# 查看特定圖片
ls assets/images/splash/
ls assets/icons/led/
```

### 查找顏色定義
```bash
# 查看顏色文件
cat lib/ui/theme/reef_colors.dart
```

### 查找尺寸定義
```bash
# 查看間距文件
cat lib/ui/theme/reef_spacing.dart

# 查看半徑文件
cat lib/ui/theme/reef_radius.dart
```

### 查找字符串定義
```bash
# 查看 l10n 文件
ls lib/l10n/
cat lib/l10n/intl_en.arb
```

---

## 注意事項

1. **圖片資源**：放在 `assets/` 目錄下，需要在 `pubspec.yaml` 中註冊
2. **平台特定資源**：Android 圖標放在 `android/app/src/main/res/`，iOS 圖標放在 `ios/Runner/Assets.xcassets/`
3. **代碼資源**：顏色、尺寸、字符串已轉換為 Dart 代碼，直接 import 使用
4. **參考資源**：`docs/reef_b_app_res/` 中的文件僅供參考，不會被打包到應用中

