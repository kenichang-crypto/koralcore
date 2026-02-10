// PARITY: 100% Android PopupMenu for rotating speed selection
// Shared Widget for speed/option selection with radio-style selection
//
// Android 對應：
// - reef-b-app 使用 PopupMenu (R.menu.rotating_speed_menu)
// - Flutter 使用 BottomSheet 呈現（更符合 Material Design）
//
// 用途：
// 1. Dosing: 旋轉速度選擇（低速/中速/高速）
// 2. LED: 任何單選選項（可泛用）

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../assets/common_icon_helper.dart';

/// OptionPickerBottomSheet (Shared Widget)
///
/// 通用的單選選擇器 BottomSheet，用於替代 Android PopupMenu。
///
/// 特點：
/// - 支援泛型 `<T>`（任意選項類型）
/// - 顯示當前選中項（check icon）
/// - 點擊後自動關閉並返回選中值
///
/// 使用場景：
/// - Dosing: 旋轉速度選擇（1=低速, 2=中速, 3=高速）
/// - LED: 任何需要單選的場景
class OptionPickerBottomSheet<T> {
  /// 顯示選項選擇器 BottomSheet
  ///
  /// [context]: BuildContext
  /// [title]: 標題文字
  /// [options]: 選項列表
  /// [currentValue]: 當前選中的值
  ///
  /// 返回: 用戶選中的值，如果取消則返回 `null`
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<OptionItem<T>> options,
    T? currentValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                title,
                style: AppTextStyles.subheader1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Options
            ...options.map((option) {
              final isSelected = currentValue == option.value;
              return ListTile(
                title: Text(option.label),
                trailing: isSelected
                    ? CommonIconHelper.getCheckIcon(
                        size: 24,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop(option.value);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 選項項目資料結構
class OptionItem<T> {
  final T value;
  final String label;

  const OptionItem({required this.value, required this.label});
}
