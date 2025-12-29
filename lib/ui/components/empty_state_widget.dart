import 'package:flutter/material.dart';

import '../theme/reef_colors.dart';
import '../theme/reef_spacing.dart';
import '../theme/reef_text.dart';

/// 統一的空狀態顯示組件
/// 
/// 用於在列表為空時顯示友好的空狀態信息
class EmptyStateWidget extends StatelessWidget {
  /// 標題文字
  final String title;
  
  /// 副標題文字（可選）
  final String? subtitle;
  
  /// 圖標（可選，可以是 IconData 或 ImageAsset）
  final IconData? icon;
  
  /// 圖片資源路徑（可選，如果提供，優先於 icon）
  final String? imageAsset;
  
  /// 圖標/圖片大小
  final double iconSize;
  
  /// 圖標顏色（僅當使用 icon 時有效）
  final Color? iconColor;
  
  /// 是否使用卡片樣式
  final bool useCard;
  
  /// 操作按鈕（可選）
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imageAsset,
    this.iconSize = 64,
    this.iconColor,
    this.useCard = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset!,
            width: iconSize,
            height: iconSize,
          )
        else if (icon != null)
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? ReefColors.textTertiary,
          ),
        if (imageAsset != null || icon != null) const SizedBox(height: ReefSpacing.md),
        Text(
          title,
          style: ReefTextStyles.subheaderAccent.copyWith(
            color: ReefColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ReefSpacing.xs),
          Text(
            subtitle!,
            style: ReefTextStyles.body.copyWith(
              color: ReefColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: ReefSpacing.lg),
          action!,
        ],
      ],
    );

    if (useCard) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(ReefSpacing.xl),
              child: content,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: content,
      ),
    );
  }
}

/// 卡片樣式的空狀態（用於列表中的空狀態）
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? imageAsset;
  final double iconSize;
  final Color? iconColor;

  const EmptyStateCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imageAsset,
    this.iconSize = 32,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: iconSize,
                height: iconSize,
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? ReefColors.textTertiary,
              ),
            if (imageAsset != null || icon != null) const SizedBox(height: ReefSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ReefColors.textPrimary,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: ReefSpacing.xs),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ReefColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

