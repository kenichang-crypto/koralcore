# 資源導入記錄

## 已導入的資源

### 啟動頁面圖片
- ✅ `ic_splash_logo.png` → `assets/images/splash/ic_splash_logo.png`
- ✅ `img_splash_logo.png` → `assets/images/splash/img_splash_logo.png`

### 功能圖標
- ✅ `img_adjust.png` → `assets/images/img_adjust.png`

### 應用圖標（Android）
- ✅ `ic_launcher.webp` → `android/app/src/main/res/mipmap-*/ic_launcher.webp`（所有分辨率：hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi）
- ✅ `ic_launcher_foreground.webp` → `android/app/src/main/res/mipmap-*/ic_launcher_foreground.webp`（所有分辨率）
- ✅ `ic_launcher_round.webp` → `android/app/src/main/res/mipmap-*/ic_launcher_round.webp`（所有分辨率）
- ✅ `ic_launcher_background.xml` → `android/app/src/main/res/drawable/ic_launcher_background.xml`
- ✅ `ic_launcher_foreground.xml` → `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- ✅ 自適應圖標配置 → `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- ✅ 自適應圖標配置（圓形）→ `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`

### 已更新的文件
- ✅ `pubspec.yaml` - 添加了 `assets/images/splash/` 路徑
- ✅ `lib/ui/features/splash/pages/splash_page.dart` - 更新為使用實際圖片
- ✅ `lib/ui/assets/reef_icons.dart` - 添加了新的圖標常量
- ✅ `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` - 自適應圖標配置
- ✅ `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` - 自適應圖標配置（圓形）

## 使用方式

### 啟動頁面
```dart
Image.asset('assets/images/splash/img_splash_logo.png')
```

### 調整圖標
```dart
Image.asset(kAdjustIcon)
```

## 圖標配置詳情

### Android 圖標
- **標準圖標**: `ic_launcher.webp`（所有分辨率：hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi）
- **前景圖標**: `ic_launcher_foreground.webp`（所有分辨率）
- **圓形圖標**: `ic_launcher_round.webp`（所有分辨率）
- **自適應圖標**: 配置在 `mipmap-anydpi-v26/` 文件夾中

### iOS 圖標
- ⚠️ **待配置**: iOS 圖標需要從 Android 圖標轉換或使用設計工具生成
- 位置：`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 下一步

1. ⚠️ 配置 iOS 圖標（需要從 Android 圖標轉換或使用設計工具）
2. 轉換常用 XML drawable 為 SVG 或 Flutter Widget
3. 實現響應式設計配置

## 注意事項

- Android 圖標已完整配置，包括自適應圖標支持（Android 8.0+）
- 所有圖標文件已複製到對應的分辨率文件夾
- 自適應圖標配置已創建，使用背景和前景圖標組合
