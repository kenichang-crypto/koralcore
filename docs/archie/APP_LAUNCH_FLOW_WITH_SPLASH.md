# App 啟動流程（含 Splash 頁面）對照

## 概述

本文檔詳細對照 `reef-b-app` 和 `koralcore` 從點擊 app 圖標到主界面顯示的完整流程，**確認是否有經過 Splash 頁面**。

---

## 答案：是的，有經過 Splash 頁面

**兩者都經過 Splash 頁面後才進入主頁**。

---

## 1. reef-b-app 啟動流程

### 完整流程

```
1. 用戶點擊 App 圖標
   ↓
2. Android 系統啟動 SplashActivity（LAUNCHER intent）
   ↓
3. MyApplication.onCreate()
   - BleContainer 初始化
   - 數據庫初始化（InitPoolDb.init）
   - Activity 生命週期追蹤註冊
   ↓
4. SplashActivity.onCreate()
   - 設置全屏模式（SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | SYSTEM_UI_FLAG_IMMERSIVE_STICKY）
   - 顯示 Splash 畫面
   - 延遲 1.5 秒
   ↓
5. MainActivity.start()
   - 創建 Intent
   - 啟動 MainActivity
   ↓
6. SplashActivity.finish()
   - 關閉 SplashActivity
   ↓
7. MainActivity.onCreate()
   - 設置 Navigation
   - 設置 View/Listener/Observer
   - checkBlePermission() → 啟動 BLE 掃描
   ↓
8. 主界面顯示（HomeFragment/BluetoothFragment/DeviceFragment）
```

### 關鍵代碼

#### AndroidManifest.xml
```xml
<activity
    android:name=".ui.activity.splash.SplashActivity"
    android:exported="true"
    android:screenOrientation="portrait"
    android:theme="@style/AppTheme.FullScreen">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

**關鍵點**: LAUNCHER intent 指向 `SplashActivity`，不是 `MainActivity`。

#### SplashActivity.kt
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    window.decorView.systemUiVisibility = 
        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or 
        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY

    super.onCreate(savedInstanceState)
    setContentView(binding.root)

    lifecycleScope.launch {
        delay(1500)  // 延遲 1.5 秒
        MainActivity.start(this@SplashActivity)  // 跳轉到 MainActivity
        finish()  // 關閉 SplashActivity
    }
}
```

**關鍵點**: 
- 顯示 Splash 畫面 1.5 秒
- 然後跳轉到 `MainActivity`
- 關閉 `SplashActivity`

---

## 2. koralcore 啟動流程

### 完整流程

```
1. 用戶點擊 App 圖標
   ↓
2. Android 系統啟動 MainActivity（LAUNCHER intent，Flutter 入口）
   ↓
3. Flutter Engine 初始化
   ↓
4. main() → KoralCoreApp.build()
   - AppContext.bootstrap()
     - Repository 初始化
     - BLE Adapter 初始化
     - UseCase 初始化
   - MultiProvider 設置
   ↓
5. MaterialApp 構建
   - home: SplashPage（設置為初始頁面）
   ↓
6. SplashPage.initState()
   - 設置全屏模式（SystemUiMode.immersiveSticky）
   - 顯示 Splash 畫面
   - 延遲 1.5 秒
   ↓
7. Navigator.pushReplacement(MainScaffold)
   - 跳轉到 MainScaffold
   ↓
8. MainScaffold.initState()
   - addPostFrameCallback()
     - _initializeAndRequestPermissions()
       - requestPermissions() → 啟動 BLE 掃描
   ↓
9. 主界面顯示（HomePage/BluetoothPage/DevicePage）
```

### 關鍵代碼

#### AndroidManifest.xml
```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    ...>
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

**關鍵點**: LAUNCHER intent 指向 `MainActivity`（Flutter 入口），但 `MaterialApp` 的 `home` 設置為 `SplashPage`。

#### main.dart
```dart
MaterialApp(
  // ... 其他配置
  home: const SplashPage(),  // 初始頁面是 SplashPage
)
```

#### SplashPage.dart
```dart
@override
void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,  // 全屏模式
    );
    _navigateToMain();
}

Future<void> _navigateToMain() async {
    await Future.delayed(const Duration(milliseconds: 1500));  // 延遲 1.5 秒
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold())  // 跳轉到 MainScaffold
    );
}
```

**關鍵點**: 
- 顯示 Splash 畫面 1.5 秒
- 然後跳轉到 `MainScaffold`
- 使用 `pushReplacement` 替換當前頁面

---

## 3. 流程對照表

| 步驟 | reef-b-app | koralcore | 對照狀態 |
|------|-----------|-----------|---------|
| 1. 點擊 App 圖標 | ✅ | ✅ | ✅ 相同 |
| 2. 系統啟動 Activity | `SplashActivity` | `MainActivity`（Flutter） | ⚠️ 不同（但效果相同） |
| 3. Application 初始化 | `MyApplication.onCreate()` | `AppContext.bootstrap()` | ✅ 對照 |
| 4. **Splash 頁面顯示** | ✅ `SplashActivity` | ✅ `SplashPage` | ✅ **100% 對照** |
| 5. Splash 延遲時間 | 1.5 秒 | 1.5 秒 | ✅ 相同 |
| 6. 跳轉到主頁 | `MainActivity.start()` | `Navigator.pushReplacement(MainScaffold)` | ✅ 對照 |
| 7. 主頁初始化 | `MainActivity.onCreate()` | `MainScaffold.initState()` | ✅ 對照 |
| 8. 權限檢查和 BLE 掃描 | `checkBlePermission()` | `_initializeAndRequestPermissions()` | ✅ 對照 |

---

## 4. Splash 頁面對照

### 4.1 顯示內容

| 項目 | reef-b-app | koralcore | 對照狀態 |
|------|-----------|-----------|---------|
| 背景色 | `#008000` (app_color) | `#008000` (app_color) | ✅ 相同 |
| Logo 圖片 | `img_splash_logo.png` | `img_splash_logo.png` | ✅ 相同 |
| Logo 位置 | 40% 高度（constraintVertical_bias=".4"） | 40% 高度（Alignment(0, -0.2)） | ✅ 相同 |
| Logo margin | 20dp | 20dp | ✅ 相同 |
| Logo scaleType | fitCenter | BoxFit.contain | ✅ 相同 |
| 全屏模式 | `SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN \| SYSTEM_UI_FLAG_IMMERSIVE_STICKY` | `SystemUiMode.immersiveSticky` | ✅ 對照 |
| 顯示時間 | 1.5 秒 | 1.5 秒 | ✅ 相同 |

### 4.2 跳轉邏輯

| 項目 | reef-b-app | koralcore | 對照狀態 |
|------|-----------|-----------|---------|
| 跳轉方式 | `MainActivity.start()` + `finish()` | `Navigator.pushReplacement()` | ✅ 對照 |
| 目標頁面 | `MainActivity` | `MainScaffold` | ✅ 對照 |
| 是否關閉 Splash | ✅ `finish()` | ✅ `pushReplacement`（自動替換） | ✅ 對照 |

---

## 5. 關鍵差異說明

### 5.1 Activity 啟動方式

**reef-b-app**:
- LAUNCHER intent 直接指向 `SplashActivity`
- `SplashActivity` 是原生 Android Activity

**koralcore**:
- LAUNCHER intent 指向 `MainActivity`（Flutter 入口）
- `SplashPage` 是 Flutter Widget，在 `MaterialApp` 中設置為 `home`

**影響**: 無（最終效果相同，都先顯示 Splash 再進入主頁）

### 5.2 跳轉方式

**reef-b-app**:
- 使用 Android Intent 啟動新 Activity
- 手動調用 `finish()` 關閉 SplashActivity

**koralcore**:
- 使用 Flutter Navigator 進行頁面跳轉
- `pushReplacement` 自動替換當前頁面

**影響**: 無（最終效果相同）

---

## 6. 完整流程圖

### reef-b-app
```
點擊 App 圖標
    ↓
SplashActivity（1.5 秒）
    ├─ 顯示 Splash 畫面
    ├─ 全屏模式
    └─ 延遲 1.5 秒
    ↓
MainActivity.start()
    ↓
MainActivity.onCreate()
    ├─ 設置 Navigation
    ├─ 設置 View/Listener/Observer
    └─ checkBlePermission() → 啟動 BLE 掃描
    ↓
主界面顯示
```

### koralcore
```
點擊 App 圖標
    ↓
MainActivity（Flutter 入口）
    ↓
MaterialApp（home: SplashPage）
    ↓
SplashPage（1.5 秒）
    ├─ 顯示 Splash 畫面
    ├─ 全屏模式
    └─ 延遲 1.5 秒
    ↓
Navigator.pushReplacement(MainScaffold)
    ↓
MainScaffold.initState()
    ├─ 設置 Navigation
    └─ _initializeAndRequestPermissions() → 啟動 BLE 掃描
    ↓
主界面顯示
```

---

## 7. 結論

### ✅ 確認：有經過 Splash 頁面

**兩者都經過 Splash 頁面後才進入主頁**：

1. **reef-b-app**: 
   - 點擊 App 圖標 → `SplashActivity`（1.5 秒）→ `MainActivity`（主頁）

2. **koralcore**: 
   - 點擊 App 圖標 → `SplashPage`（1.5 秒）→ `MainScaffold`（主頁）

### 對照狀態

| 項目 | 對照狀態 |
|------|---------|
| 是否有 Splash 頁面 | ✅ **100% 對照** |
| Splash 顯示時間 | ✅ **100% 對照**（1.5 秒） |
| Splash 顯示內容 | ✅ **100% 對照**（背景色、Logo、位置） |
| Splash 全屏模式 | ✅ **100% 對照** |
| 跳轉到主頁 | ✅ **100% 對照** |
| 整體流程 | ✅ **100% 對照** |

**結論**: koralcore 的啟動流程已 100% 對照 reef-b-app，都經過 Splash 頁面後才進入主頁。

