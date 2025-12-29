import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/reef_colors.dart';
import '../theme/reef_radius.dart';
import '../theme/reef_spacing.dart';
import '../theme/reef_text.dart';

class FeatureEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback? onTap;
  final bool enabled;

  const FeatureEntryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.asset,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(ReefRadius.lg),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(ReefSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ReefColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ReefRadius.md),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      asset,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        ReefColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ReefSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ReefTextStyles.subheaderAccent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.sm),
                      Text(
                        subtitle,
                        style: ReefTextStyles.body.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: ReefColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
