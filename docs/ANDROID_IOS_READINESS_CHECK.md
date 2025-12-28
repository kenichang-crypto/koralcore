# Android 和 iOS 運行準備檢查

## 檢查日期
2024-12-28

---

## ✅ Android 配置檢查

### 1. 基本配置 ✅
- ✅ `android/app/build.gradle.kts` 存在
- ✅ `AndroidManifest.xml` 存在
- ✅ `MainActivity.kt` 存在
- ✅ 應用圖標資源已配置（所有分辨率）

### 2. 權限配置 ✅
**AndroidManifest.xml 中已配置的權限**：
- ✅ `BLUETOOTH` - 藍牙基本權限
- ✅ `BLUETOOTH_ADMIN` - 藍牙管理權限
- ✅ `BLUETOOTH_CONNECT` - 藍牙連接權限（Android 12+）
- ✅ `BLUETOOTH_SCAN` - 藍牙掃描權限（Android 12+）
- ✅ `BLUETOOTH_ADVERTISE` - 藍牙廣播權限
- ✅ `ACCESS_FINE_LOCATION` - 精確位置權限（BLE 掃描需要）
- ✅ `ACCESS_COARSE_LOCATION` - 粗略位置權限

### 3. 應用配置 ⚠️
- ⚠️ `applicationId = "com.example.koralcore"` - **需要更改為實際的包名**
- ✅ `minSdk` 和 `targetSdk` 由 Flutter 自動配置
- ✅ `compileSdk` 由 Flutter 自動配置

### 4. 簽名配置 ⚠️
- ⚠️ Release 版本使用 debug 簽名（`signingConfig = signingConfigs.getByName("debug")`）
- ⚠️ **發布前需要配置正式的簽名**

### 5. 依賴 ✅
- ✅ `flutter_blue_plus` - BLE 功能
- ✅ `permission_handler` - 權限處理
- ✅ `sqflite` - 本地數據庫
- ✅ 其他依賴都已配置

---

## ✅ iOS 配置檢查

### 1. 基本配置 ✅
- ✅ `Info.plist` 存在
- ✅ `AppDelegate.swift` 存在
- ✅ `Podfile` 存在
- ✅ `Podfile.lock` 存在（依賴已安裝）
- ✅ 應用圖標資源已配置（所有尺寸）

### 2. 權限配置 ✅
**Info.plist 中已配置的權限描述**：
- ✅ `NSBluetoothAlwaysUsageDescription` - 藍牙使用說明
- ✅ `NSBluetoothPeripheralUsageDescription` - 藍牙外設使用說明
- ✅ `NSLocationWhenInUseUsageDescription` - 位置使用說明（BLE 掃描需要）

### 3. 應用配置 ✅
- ✅ `CFBundleDisplayName = "Koralcore"`
- ✅ `CFBundleIdentifier` 由 Xcode 配置
- ✅ 支持的方向已配置（Portrait, Landscape）

### 4. 依賴 ✅
- ✅ `flutter_blue_plus_darwin` - iOS BLE 功能
- ✅ `permission_handler_apple` - iOS 權限處理
- ✅ Pods 已安裝

---

## ⚠️ 發布前需要處理的事項

### Android

1. **更改應用包名**：
   ```kotlin
   // android/app/build.gradle.kts
   applicationId = "com.yourcompany.koralcore"  // 改為實際包名
   ```

2. **配置正式簽名**：
   ```kotlin
   // android/app/build.gradle.kts
   signingConfigs {
       create("release") {
           storeFile = file("path/to/keystore.jks")
           storePassword = "your-password"
           keyAlias = "your-key-alias"
           keyPassword = "your-key-password"
       }
   }
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

3. **更新應用名稱**（可選）：
   ```xml
   <!-- android/app/src/main/res/values/strings.xml -->
   <string name="app_name">KoralCore</string>
   ```

### iOS

1. **配置 Bundle Identifier**：
   - 在 Xcode 中設置實際的 Bundle Identifier
   - 例如：`com.yourcompany.koralcore`

2. **配置簽名和證書**：
   - 在 Xcode 中配置開發者帳號和證書
   - 設置 Provisioning Profile

3. **更新應用名稱**（可選）：
   ```xml
   <!-- ios/Runner/Info.plist -->
   <key>CFBundleDisplayName</key>
   <string>KoralCore</string>
   ```

---

## ✅ 當前可以做的事情

### 開發和測試

1. **Android**：
   ```bash
   # 連接 Android 設備或啟動模擬器
   flutter run
   ```
   - ✅ 可以使用 debug 簽名運行
   - ✅ 可以進行開發和測試

2. **iOS**：
   ```bash
   # 連接 iOS 設備或啟動模擬器
   flutter run
   ```
   - ✅ 可以使用開發者證書運行
   - ✅ 可以進行開發和測試

### 功能測試

- ✅ BLE 掃描和連接
- ✅ 權限請求
- ✅ UI 功能
- ✅ 數據持久化
- ✅ 多語言切換

---

## 📋 運行前檢查清單

### Android
- [x] AndroidManifest.xml 權限配置
- [x] build.gradle.kts 配置
- [x] MainActivity.kt 存在
- [x] 應用圖標資源
- [ ] 更改應用包名（發布前）
- [ ] 配置正式簽名（發布前）

### iOS
- [x] Info.plist 權限配置
- [x] AppDelegate.swift 存在
- [x] Pods 已安裝
- [x] 應用圖標資源
- [ ] 配置 Bundle Identifier（發布前）
- [ ] 配置簽名和證書（發布前）

---

## 🚀 運行命令

### Android
```bash
# 檢查設備
flutter devices

# 運行
flutter run

# 構建 APK
flutter build apk

# 構建 App Bundle（發布用）
flutter build appbundle
```

### iOS
```bash
# 檢查設備
flutter devices

# 運行
flutter run

# 構建 IPA（需要 Xcode）
flutter build ios

# 在 Xcode 中構建和發布
open ios/Runner.xcworkspace
```

---

## ✅ 結論

### 可以直接使用

**開發和測試**：
- ✅ **Android**：可以直接運行和測試
- ✅ **iOS**：可以直接運行和測試（需要 Xcode 和開發者帳號）

**功能完整性**：
- ✅ 所有必要的權限已配置
- ✅ 所有必要的依賴已安裝
- ✅ 應用圖標已配置
- ✅ 多語言支持已配置

**發布前需要**：
- ⚠️ 更改應用包名（Android）
- ⚠️ 配置正式簽名（Android）
- ⚠️ 配置 Bundle Identifier（iOS）
- ⚠️ 配置簽名和證書（iOS）

---

## 📝 注意事項

1. **Android 12+ 權限**：
   - 已配置 `BLUETOOTH_CONNECT` 和 `BLUETOOTH_SCAN`
   - 這些權限在運行時需要請求

2. **iOS 權限**：
   - 權限描述已配置
   - 首次使用時會自動彈出權限請求

3. **BLE 功能**：
   - 需要實際的 BLE 設備進行測試
   - 模擬器可能無法測試 BLE 功能

4. **數據庫**：
   - 使用 SQLite，數據會持久化到設備
   - 首次運行會自動創建數據庫

---

## 🎯 總結

**當前狀態**：✅ **可以直接在 Android 和 iOS 上運行和測試**

**發布狀態**：⚠️ **需要完成發布前的配置（包名、簽名等）**

**建議**：
1. 先進行開發和測試
2. 確認功能正常後，再配置發布相關的設置
3. 使用實際設備測試 BLE 功能

