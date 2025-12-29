import 'package:flutter/material.dart';

import '../widgets/reef_backgrounds.dart';
import '../widgets/reef_device_card.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_text.dart';
import '../theme/reef_spacing.dart';
import '../theme/reef_theme.dart';

/// Widget preview for HomePage layout structure.
///
/// This preview shows the main layout components without actual data/logic.
// @Preview()  // TODO: Add flutter_preview package or use IDE preview feature
Widget homePageLayoutPreview() {
  return MaterialApp(
    theme: ReefTheme.base(),
    home: Scaffold(
      body: ReefMainBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top button bar (matching _TopButtonBar)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ReefSpacing.md,
                  vertical: ReefSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left button (usually hidden, placeholder)
                    SizedBox(width: 56, height: 44),
                    // Right warning button
                    IconButton(
                      icon: Icon(Icons.warning_amber_rounded),
                      iconSize: 24,
                      color: ReefColors.textPrimary,
                      onPressed: () {},
                      constraints: BoxConstraints(minWidth: 56, minHeight: 44),
                    ),
                  ],
                ),
              ),

              // Sink selector bar (matching _SinkSelectorBar)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ReefSpacing.md,
                  vertical: ReefSpacing.xs,
                ),
                child: Row(
                  children: [
                    // Sink selector placeholder (should be a Spinner/DropdownButton)
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ReefSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: ReefColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ReefColors.outline, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sink 1',
                            style: ReefTextStyles.caption1.copyWith(
                              color: ReefColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: ReefSpacing.xs),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: ReefColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Manager button
                    IconButton(
                      icon: Icon(Icons.settings),
                      iconSize: 24,
                      color: ReefColors.textPrimary,
                      onPressed: () {},
                      constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                    ),
                  ],
                ),
              ),

              // Device list area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.md,
                    vertical: ReefSpacing.xs,
                  ),
                  children: [
                    // Device card example 1 - LED
                    ReefDeviceCard(
                      onTap: () {},
                      child: SizedBox(
                        height: 88,
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
                                Icons.lightbulb,
                                color: ReefColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: ReefSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'coralLED Pro',
                                    style: ReefTextStyles.subheaderAccent
                                        .copyWith(
                                          color: ReefColors.textPrimary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: ReefSpacing.xs),
                                  Text(
                                    'Connected',
                                    style: ReefTextStyles.caption1.copyWith(
                                      color: ReefColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: ReefColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: ReefSpacing.md),

                    // Device card example 2 - Doser
                    ReefDeviceCard(
                      onTap: () {},
                      child: SizedBox(
                        height: 88,
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
                            const SizedBox(width: ReefSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'koralDOSE 4H',
                                    style: ReefTextStyles.subheaderAccent
                                        .copyWith(
                                          color: ReefColors.textPrimary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: ReefSpacing.xs),
                                  Text(
                                    'Disconnected',
                                    style: ReefTextStyles.caption1.copyWith(
                                      color: ReefColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: ReefColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: ReefSpacing.md),

                    // Device card example 3 - Another LED
                    ReefDeviceCard(
                      onTap: () {},
                      child: SizedBox(
                        height: 88,
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
                                Icons.lightbulb_outline,
                                color: ReefColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: ReefSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'coralLED EX',
                                    style: ReefTextStyles.subheaderAccent
                                        .copyWith(
                                          color: ReefColors.textPrimary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: ReefSpacing.xs),
                                  Text(
                                    'Connected',
                                    style: ReefTextStyles.caption1.copyWith(
                                      color: ReefColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: ReefColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
