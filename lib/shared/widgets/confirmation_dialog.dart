// PARITY: 100% Android AlertDialog for confirmation
// Shared Widget for confirmation dialogs (delete, clear, etc.)
//
// Android 對應：
// - reef-b-app 使用 AlertDialog + MaterialAlertDialogBuilder
// - Flutter 使用 AlertDialog + showDialog
//
// 用途：
// 1. 刪除確認（Delete confirmation）
// 2. 清除全部確認（Clear all confirmation）
// 3. 任何需要確認的危險操作

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ConfirmationDialog (Shared Widget)
///
/// 通用的確認對話框，用於危險操作的二次確認。
///
/// 特點：
/// - 支援自訂標題、內容、按鈕文字
/// - 支援自訂按鈕顏色（預設為 error 紅色）
/// - 返回 `true` / `false` / `null`
///
/// 使用場景：
/// - 刪除確認
/// - 清除全部確認
/// - 任何不可逆操作的確認
class ConfirmationDialog {
  /// 顯示確認對話框
  ///
  /// [context]: BuildContext
  /// [title]: 標題文字
  /// [content]: 內容文字
  /// [confirmText]: 確認按鈕文字（預設 "確認"）
  /// [cancelText]: 取消按鈕文字（預設 "取消"）
  /// [confirmColor]: 確認按鈕顏色（預設 error 紅色）
  ///
  /// 返回: `true` 表示確認，`false` 表示取消，`null` 表示點擊外部關閉
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          // Confirm button (dangerous action)
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.error,
            ),
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  /// 刪除確認對話框（預設配置）
  ///
  /// [context]: BuildContext
  /// [title]: 標題文字（預設 "確認刪除？"）
  /// [content]: 內容文字（預設 "此操作無法復原"）
  /// [confirmText]: 確認按鈕文字（預設 "刪除"）
  /// [cancelText]: 取消按鈕文字（預設 "取消"）
  static Future<bool?> showDelete({
    required BuildContext context,
    String? title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) {
    return show(
      context: context,
      title: title ?? 'Delete?',
      content: content ?? 'This action cannot be undone.',
      confirmText: confirmText ?? 'Delete',
      cancelText: cancelText ?? 'Cancel',
      confirmColor: AppColors.error,
    );
  }

  /// 清除全部確認對話框（預設配置）
  ///
  /// [context]: BuildContext
  /// [title]: 標題文字（預設 "清除全部？"）
  /// [content]: 內容文字（預設 "所有資料將被清除"）
  /// [confirmText]: 確認按鈕文字（預設 "清除"）
  /// [cancelText]: 取消按鈕文字（預設 "取消"）
  static Future<bool?> showClearAll({
    required BuildContext context,
    String? title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) {
    return show(
      context: context,
      title: title ?? 'Clear All?',
      content: content ?? 'All data will be cleared.',
      confirmText: confirmText ?? 'Clear',
      cancelText: cancelText ?? 'Cancel',
      confirmColor: AppColors.error,
    );
  }
}
