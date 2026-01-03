import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/main_scaffold.dart';

/// Splash page.
///
/// PARITY: Mirrors reef-b-app's SplashActivity.
/// Displays a splash screen for 1.5 seconds, then navigates to MainScaffold.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // PARITY: SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | SYSTEM_UI_FLAG_IMMERSIVE_STICKY
    // Hide system UI for full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _navigateToMain();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Restore system UI when leaving splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _navigateToMain() async {
    if (_hasNavigated) {
      return;
    }
    // Wait 1.5 seconds (matching reef-b-app's delay)
    final completer = Completer<void>();
    _timer = Timer(
      const Duration(milliseconds: 1500),
      () => completer.complete(),
    );
    await completer.future;

    if (!mounted) {
      return;
    }
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;

    // Navigate to MainScaffold, and ensure Splash is not kept in back stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // PARITY: activity_splash.xml
    // - Background: @color/app_color (#008000)
    // - Only ImageView with app_icon, no text
    // - Full screen mode (SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
    // - ImageView: wrap_content, margin 20dp, scaleType fitCenter
    // - Position: constraintVertical_bias=".4" (slightly above center)
    return Scaffold(
      backgroundColor: const Color(0xFF008000), // app_color (#008000)
      body: Padding(
        // PARITY: ImageView layout_margin="@dimen/dp_20"
        padding: const EdgeInsets.all(20.0),
        child: Align(
          // PARITY: constraintVertical_bias=".4"
          alignment: const Alignment(0, -0.2),
          child: Image.asset(
            // PARITY: @drawable/app_icon
            'assets/images/splash/ic_splash_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
