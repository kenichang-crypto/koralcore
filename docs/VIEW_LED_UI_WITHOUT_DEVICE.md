# 如何在没有设备的情况下查看 LED UI 界面

## 方法 1: 临时修改 main.dart（推荐用于开发测试）

如果你只是想查看 LED 界面，可以临时修改 `lib/main.dart`：

```dart
// 在 main.dart 中，临时将 home 改为 LedMainPage
import 'package:koralcore/ui/features/led/pages/led_main_page.dart';

// 在 KoralCoreApp 的 build 方法中：
home: const LedMainPage(),  // 临时替换 SplashPage
```

**记得查看完后改回来！**

## 方法 2: 临时修改 SplashPage

在 `lib/ui/features/splash/pages/splash_page.dart` 中，临时修改导航逻辑：

```dart
Future<void> _navigateToMain() async {
  // 临时：直接跳转到 LED 页面（用于查看 UI）
  await Future.delayed(const Duration(milliseconds: 500));
  
  if (!mounted) return;
  
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const LedMainPage(),  // 临时替换 MainScaffold
    ),
  );
}
```

**记得查看完后改回来！**

## 方法 3: 使用模拟器/真机运行

即使没有实际的 BLE 设备，你也可以：
1. 在模拟器中运行应用
2. 通过蓝牙页面添加一个模拟设备（如果数据库允许）
3. 然后进入 LED 页面

## 方法 4: 创建一个开发模式开关

可以在代码中添加一个开发模式标志：

```dart
// 在某个配置文件中
const bool kDebugMode = true;  // 开发时设为 true

// 在 home_page.dart 中
void _openGuarded(BuildContext context, bool isConnected, Widget page) {
  if (!isConnected && !kDebugMode) {  // 开发模式下允许进入
    showBleGuardDialog(context);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
```

## 注意事项

- LED 页面即使没有设备连接也会显示 UI
- 页面顶部会显示 `BleGuardBanner` 警告横幅
- 需要 BLE 连接的功能会被禁用
- 但所有 UI 元素都可以看到

## 推荐做法

**开发/测试时**：使用方法 1 或 2 临时修改代码查看 UI  
**正常使用时**：保持原有逻辑，确保用户体验一致

