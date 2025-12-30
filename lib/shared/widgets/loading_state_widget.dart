import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// 統一的加載狀態顯示組件
/// 
/// 提供多種加載狀態顯示方式：
/// - 居中加載指示器（用於全頁加載）
/// - 內聯加載指示器（用於列表中的加載）
/// - 線性進度條（用於操作進度）
class LoadingStateWidget extends StatelessWidget {
  /// 是否使用線性進度條（而非圓形進度指示器）
  final bool isLinear;
  
  /// 自定義消息（可選）
  final String? message;
  
  /// 是否使用完整的卡片樣式（用於全頁加載）
  final bool useCard;

  const LoadingStateWidget({
    super.key,
    this.isLinear = false,
    this.message,
    this.useCard = false,
  });

  /// 創建一個居中的加載指示器（用於全頁加載）
  const LoadingStateWidget.center({
    super.key,
    this.isLinear = false,
    this.message,
    this.useCard = false,
  });

  /// 創建一個內聯的加載指示器（用於列表中的加載）
  const LoadingStateWidget.inline({
    super.key,
    this.message,
  }) : isLinear = false,
       useCard = false;

  /// 創建一個線性進度條（用於操作進度）
  const LoadingStateWidget.linear({
    super.key,
    this.message,
  }) : isLinear = true,
       useCard = false;

  @override
  Widget build(BuildContext context) {
    if (isLinear) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const LinearProgressIndicator(),
        ],
      );
    }

    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    if (useCard) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: loadingWidget,
            ),
          ),
        ),
      );
    }

    if (message != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: loadingWidget,
        ),
      );
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// 包裝器，用於在加載時顯示加載狀態，否則顯示內容
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final bool useLinear;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.useLinear = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          (useLinear
              ? const LoadingStateWidget.linear()
              : const LoadingStateWidget.center());
    }
    return child;
  }
}

