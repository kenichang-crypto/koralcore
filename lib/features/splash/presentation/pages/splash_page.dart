import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/app_radius.dart';
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
    // Restore system UI when leaving splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _navigateToMain() async {
    // Wait 1.5 seconds (matching reef-b-app's delay)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    // Navigate to MainScaffold
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScaffold()));
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
      body: Stack(
        children: [
          // Full screen background
          Positioned.fill(child: Container(color: const Color(0xFF008000))),
          // App Icon (PARITY: ImageView with app_icon)
          // Position: constraintVertical_bias=".4" means 40% from top (slightly above center)
          // margin 20dp, scaleType fitCenter
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20.0), // dp_20 margin
              child: Align(
                // bias 0.4 means 40% from top, so we use Alignment(0, -0.2) to position at 40% from top
                // Alignment.y = -1.0 (top) to 1.0 (bottom), so 0.4 bias = -0.2 in Alignment
                alignment: const Alignment(
                  0,
                  -0.2,
                ), // 0.4 bias = 40% from top = -0.2 in Alignment
                // PARITY: reef-b-app activity_splash.xml uses @drawable/app_icon
                // app_icon.xml is a vector drawable with green background and white logo
                // We use ic_splash_logo.png which should match app_icon
                child: Image.asset(
                  'assets/images/splash/ic_splash_logo.png', // PARITY: @drawable/app_icon
                  fit: BoxFit.contain, // scaleType fitCenter
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback: try img_splash_logo.png
                    return Image.asset(
                      'assets/images/splash/img_splash_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Final fallback: simple icon matching app_icon.xml design
                        return Container(
                          width:
                              193.6, // PARITY: app_icon.xml width="1936dp" scaled to 1/10
                          height:
                              193.6, // PARITY: app_icon.xml height="1936dp" scaled to 1/10
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF008000,
                            ), // PARITY: app_icon.xml fillColor="#008000"
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(
                            Icons.water_drop,
                            size: 96,
                            color: Colors
                                .white, // PARITY: app_icon.xml fillColor="#ffffff"
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
