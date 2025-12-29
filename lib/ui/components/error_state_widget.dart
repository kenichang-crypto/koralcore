import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../application/common/app_error_code.dart';
import '../theme/reef_colors.dart';
import '../theme/reef_spacing.dart';
import '../theme/reef_text.dart';
import '../theme/reef_radius.dart';
import 'app_error_presenter.dart';

/// 統一的錯誤狀態顯示組件
/// 
/// 用於在頁面內容區域顯示錯誤信息，通常包含：
/// - 錯誤圖標
/// - 錯誤信息
/// - 重試按鈕（可選）
class ErrorStateWidget extends StatelessWidget {
  /// 錯誤代碼（用於顯示標準錯誤信息）
  final AppErrorCode? errorCode;
  
  /// 自定義錯誤信息（如果提供，將優先於 errorCode）
  final String? customMessage;
  
  /// 是否顯示重試按鈕
  final bool showRetry;
  
  /// 重試回調
  final VoidCallback? onRetry;
  
  /// 自定義重試按鈕文字
  final String? retryLabel;

  const ErrorStateWidget({
    super.key,
    this.errorCode,
    this.customMessage,
    this.showRetry = true,
    this.onRetry,
    this.retryLabel,
  }) : assert(errorCode != null || customMessage != null, 'errorCode or customMessage must be provided');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    String message;
    if (customMessage != null) {
      message = customMessage!;
    } else if (errorCode != null) {
      message = describeAppError(l10n, errorCode!);
    } else {
      message = l10n.errorGeneric;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(ReefSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ReefColors.danger,
                ),
                const SizedBox(height: ReefSpacing.md),
                Text(
                  message,
                  style: ReefTextStyles.body.copyWith(
                    color: ReefColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showRetry && onRetry != null) ...[
                  const SizedBox(height: ReefSpacing.lg),
                  FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: ReefColors.primary,
                    ),
                    child: Text(retryLabel ?? l10n.actionRetry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 顯示錯誤 SnackBar 的工具函數
/// 
/// 用於快速顯示錯誤提示（不會阻塞用戶操作）
void showErrorSnackBar(
  BuildContext context,
  AppErrorCode? errorCode, {
  String? customMessage,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final l10n = AppLocalizations.of(context);
  
  String message;
  if (customMessage != null) {
    message = customMessage;
  } else if (errorCode != null) {
    message = describeAppError(l10n, errorCode);
  } else {
    message = l10n.errorGeneric;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: ReefColors.danger,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: ReefColors.onError,
              onPressed: onAction,
            )
          : null,
    ),
  );
}

/// 顯示成功 SnackBar 的工具函數
void showSuccessSnackBar(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: ReefColors.success,
    ),
  );
}

/// 內聯錯誤消息組件（用於在列表或表單中顯示錯誤）
class InlineErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReefSpacing.md),
      decoration: BoxDecoration(
        color: ReefColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ReefRadius.md),
        border: Border.all(color: ReefColors.danger, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: ReefColors.danger,
            size: 20,
          ),
          const SizedBox(width: ReefSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.danger,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: ReefSpacing.sm),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: ReefColors.danger,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

