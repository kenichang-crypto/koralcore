import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A full-screen blocking overlay that prevents user interaction and shows a loading indicator.
///
/// PARITY: Maps to reef-b-app's res/layout/progress.xml behavior.
/// Usage: Place this widget at the top of a Stack to block interaction.
class ReefBlockingOverlay extends StatelessWidget {
  const ReefBlockingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Android progress.xml background is typically #4D000000 (30% black)
    // We use a similar semi-transparent black to dim the content and block interactions.
    // The Container with color automatically blocks hit tests.
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.3), // Matches Android typical dim amount
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
