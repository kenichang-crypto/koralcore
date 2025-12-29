import 'package:flutter/material.dart';

import '../components/feature_entry_card.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_theme.dart';

/// Widget preview for FeatureEntryCard component.
// @Preview()  // TODO: Add flutter_preview package or use IDE preview feature
Widget featureEntryCardPreview() {
  return MaterialApp(
    theme: ReefTheme.base(),
    home: Scaffold(
      backgroundColor: ReefColors.surfaceMuted,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Enabled state
              FeatureEntryCard(
                title: 'LED Lighting',
                subtitle: 'Control your LED lights',
                asset: 'assets/icons/icon_led.svg',
                enabled: true,
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Disabled state
              FeatureEntryCard(
                title: 'Dosing System',
                subtitle: 'Manage dosing schedules',
                asset: 'assets/icons/icon_dosing.svg',
                enabled: false,
                onTap: null,
              ),
              const SizedBox(height: 16),

              // Another enabled example
              FeatureEntryCard(
                title: 'Device Management',
                subtitle: 'Add and configure devices',
                asset: 'assets/icons/icon_device.svg',
                enabled: true,
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Home feature example
              FeatureEntryCard(
                title: 'Home',
                subtitle: 'View all your devices',
                asset: 'assets/icons/icon_home.svg',
                enabled: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
