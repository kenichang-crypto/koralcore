import 'package:flutter/material.dart';

import '../widgets/reef_device_card.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_text.dart';
import '../theme/reef_theme.dart';

/// Widget preview for ReefDeviceCard component.
// @Preview()  // TODO: Add flutter_preview package or use IDE preview feature
Widget reefDeviceCardPreview() {
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
              // Device card with tap handler
              ReefDeviceCard(
                onTap: () {
                  debugPrint('Device card tapped');
                },
                child: Row(
                  children: [
                    // Device icon placeholder
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ReefColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.devices,
                        color: ReefColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'coralLED Pro',
                            style: ReefTextStyles.subheaderAccent.copyWith(
                              color: ReefColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sink 1 • Position 1',
                            style: ReefTextStyles.caption2.copyWith(
                              color: ReefColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Device card without tap handler
              ReefDeviceCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ReefColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: ReefColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'koralDOSE 4H',
                            style: ReefTextStyles.subheaderAccent.copyWith(
                              color: ReefColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sink 2 • Position 3',
                            style: ReefTextStyles.caption2.copyWith(
                              color: ReefColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Multiple cards in a list
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ReefDeviceCard(
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ReefColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            index == 0 ? Icons.devices : Icons.water_drop,
                            color: ReefColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index == 0
                                    ? 'coralLED EX'
                                    : 'koralDOSE ${2 * (index + 1)}H',
                                style: ReefTextStyles.subheaderAccent.copyWith(
                                  color: ReefColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sink ${index + 1} • Position ${index + 1}',
                                style: ReefTextStyles.caption2.copyWith(
                                  color: ReefColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
}
