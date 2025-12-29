# 按鈕標籤硬編碼審計報告

## 審計日期
2024-12-28

## 審計範圍
- `lib/ui/features/` 目錄下的所有 Dart 文件
- 重點檢查：按鈕（Button）、工具提示（tooltip）、標籤（label）中的硬編碼字符串

---

## 發現的硬編碼按鈕標籤 🔍

### 1. Tooltip 文本（工具提示）

#### 1.1 `led_main_page.dart`

**Line 144**: `tooltip: isFavorite ? 'Unfavorite' : 'Favorite'`
- **狀態**: ⚠️ 硬編碼
- **已有本地化鍵**: `ledScenesActionFavorite` = "Add Favorite", `ledScenesActionUnfavorite` = "Remove Favorite"
- **需要修復**: ✅ 是

**Line 156**: `'Device unfavorited'` / `'Device favorited'`
- **狀態**: ⚠️ 硬編碼（在 SnackBar 中）
- **需要添加本地化鍵**: `deviceFavorited`, `deviceUnfavorited`

**Line 184**: `tooltip: _isLandscape ? 'Portrait' : 'Landscape'`
- **狀態**: ⚠️ 硬編碼
- **需要添加本地化鍵**: `ledOrientationPortrait`, `ledOrientationLandscape`

**Line 676**: `title: 'Favorite Scenes'`
- **狀態**: ⚠️ 硬編碼
- **需要添加本地化鍵**: `ledFavoriteScenesTitle`

**Line 677**: `subtitle: 'Your favorite scenes'`
- **狀態**: ⚠️ 硬編碼
- **需要添加本地化鍵**: `ledFavoriteScenesSubtitle`

**Line 1300**: `tooltip: 'Continue Record'`
- **狀態**: ⚠️ 硬編碼
- **需要添加本地化鍵**: `ledContinueRecord`

#### 1.2 `dosing_main_page.dart`

**Line 70**: `tooltip: isFavorite ? 'Unfavorite' : 'Favorite'`
- **狀態**: ⚠️ 硬編碼
- **已有本地化鍵**: `ledScenesActionFavorite`, `ledScenesActionUnfavorite`（但這些是 LED 場景相關的）
- **需要添加本地化鍵**: `dosingFavorite`, `dosingUnfavorite` 或重用 LED 的鍵

**Line 82**: `'Device unfavorited'` / `'Device favorited'`
- **狀態**: ⚠️ 硬編碼（在 SnackBar 中）
- **需要添加本地化鍵**: `deviceFavorited`, `deviceUnfavorited`

**Line 170**: `tooltip: isConnected ? 'Disconnect' : 'Connect'`
- **狀態**: ⚠️ 硬編碼
- **已有本地化鍵**: `deviceActionConnect` = "Connect", `deviceActionDisconnect` = "Disconnect"
- **需要修復**: ✅ 是

**Line 455**: `tooltip: 'Play'`
- **狀態**: ⚠️ 硬編碼
- **需要添加本地化鍵**: `dosingPlay` 或 `actionPlay`

---

## 需要添加的本地化鍵

### 1. 設備收藏相關
- `deviceFavorited`: "Device favorited"
- `deviceUnfavorited`: "Device unfavorited"

### 2. LED 方向相關
- `ledOrientationPortrait`: "Portrait"
- `ledOrientationLandscape`: "Landscape"

### 3. LED 收藏場景相關
- `ledFavoriteScenesTitle`: "Favorite Scenes"
- `ledFavoriteScenesSubtitle`: "Your favorite scenes"

### 4. LED 記錄相關
- `ledContinueRecord`: "Continue Record"

### 5. Dosing 播放相關
- `dosingPlay`: "Play" 或 `actionPlay`: "Play"

---

## 已存在的本地化鍵（可重用）

### LED 場景收藏
- `ledScenesActionFavorite`: "Add Favorite"
- `ledScenesActionUnfavorite`: "Remove Favorite"

### 設備連接
- `deviceActionConnect`: "Connect"
- `deviceActionDisconnect`: "Disconnect"

---

## 修復優先級

### 高優先級
1. **設備連接按鈕** (`dosing_main_page.dart` line 170) - 已有本地化鍵，只需替換
2. **收藏/取消收藏工具提示** (`led_main_page.dart`, `dosing_main_page.dart`) - 部分已有本地化鍵

### 中優先級
3. **設備收藏狀態消息** - 需要添加本地化鍵
4. **LED 方向工具提示** - 需要添加本地化鍵
5. **收藏場景標題/副標題** - 需要添加本地化鍵

### 低優先級
6. **繼續記錄工具提示** - 需要添加本地化鍵
7. **播放按鈕工具提示** - 需要添加本地化鍵

---

## 下一步行動

1. ⏳ **修復設備連接按鈕** - 使用已有的 `deviceActionConnect` / `deviceActionDisconnect`
2. ⏳ **修復收藏工具提示** - 使用已有的 `ledScenesActionFavorite` / `ledScenesActionUnfavorite` 或添加新的鍵
3. ⏳ **添加缺失的本地化鍵** - 設備收藏狀態、LED 方向、收藏場景等
4. ⏳ **修復所有硬編碼按鈕標籤** - 確保所有按鈕文本都使用本地化

