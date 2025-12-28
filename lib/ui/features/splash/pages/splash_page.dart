import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../theme/reef_colors.dart';
import '../../../theme/reef_text.dart';
import '../../app/main_scaffold.dart';

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
    _navigateToMain();
  }

  Future<void> _navigateToMain() async {
    // Wait 1.5 seconds (matching reef-b-app's delay)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    // Navigate to MainScaffold
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainScaffold(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ReefColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Image.asset(
                'assets/images/splash/img_splash_logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ReefColors.onPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 64,
                      color: ReefColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // App Name
              Text(
                'KoralCore',
                style: ReefTextStyles.title1.copyWith(
                  color: ReefColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // App Tagline (optional)
              Text(
                l10n.splashTagline ?? 'Reef Aquarium Control System',
                style: ReefTextStyles.body1.copyWith(
                  color: ReefColors.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

