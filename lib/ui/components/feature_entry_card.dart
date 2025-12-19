import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';

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
    final theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.ocean500.withOpacity(.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      asset,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        AppColors.ocean500,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.grey500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
