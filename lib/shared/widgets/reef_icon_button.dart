// PARITY: 100% Android Toolbar Button size (44x44dp)
// Shared Widget for consistent toolbar icon buttons
//
// Android 對應：
// - toolbar_app.xml: android:layout_height="@dimen/dp_44"
// - toolbar_device.xml: android:layout_height="@dimen/dp_44"
// - toolbar_two_action.xml: android:layout_height="@dimen/dp_44"
//
// 用途：
// - 所有 Toolbar 內的 IconButton（返回、關閉、選單、動作按鈕）
// - 固定尺寸 44x44dp，完全對齊 Android

import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// ReefIconButton (Shared Widget)
///
/// 用於 Toolbar 的 IconButton，固定尺寸 44x44dp，完全對齊 Android。
///
/// PARITY:
/// - Android: `@dimen/dp_44` (toolbar_*.xml)
/// - Flutter: `AppSpacing.toolbarButtonSize` (44dp)
///
/// 特點:
/// - ✅ 固定尺寸 44x44dp（Android Toolbar Button 標準）
/// - ✅ 移除 Material IconButton 預設的 48x48dp 約束
/// - ✅ 支援自訂 padding（預設為 zero）
/// - ✅ 完全可點擊（onPressed 為 null 時自動禁用）
///
/// 使用場景:
/// - Toolbar 返回按鈕（btnBack）
/// - Toolbar 關閉按鈕（btnClose）
/// - Toolbar 選單按鈕（btnMenu）
/// - Toolbar 動作按鈕（btnRight, btnFavorite）
class ReefIconButton extends StatelessWidget {
  /// Icon widget to display
  final Widget icon;

  /// Callback when button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Padding inside the button. Defaults to zero for toolbar usage.
  final EdgeInsetsGeometry padding;

  /// Tooltip message (optional)
  final String? tooltip;

  /// Icon color (optional, usually handled by icon widget itself)
  final Color? color;

  const ReefIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.padding = EdgeInsets.zero,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // PARITY: Android toolbar_*.xml button size
      width: AppSpacing.toolbarButtonSize, // dp_44
      height: AppSpacing.toolbarButtonSize, // dp_44
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        padding: padding,
        tooltip: tooltip,
        color: color,
        // Remove Material default constraints (48x48dp)
        constraints: const BoxConstraints(),
        // Ensure button fills the 44x44 container
        iconSize: 24, // Standard icon size
      ),
    );
  }
}

/// ReefTextButton (Shared Widget for text-based toolbar buttons)
///
/// 用於 Toolbar 的 TextButton（如「儲存」、「完成」按鈕），高度 44dp。
///
/// PARITY:
/// - Android: `@dimen/dp_44` (toolbar_two_action.xml btnRight)
/// - Flutter: `AppSpacing.toolbarButtonSize` (44dp)
///
/// 特點:
/// - ✅ 固定高度 44dp，寬度自適應
/// - ✅ 移除 Material TextButton 預設的 48dp 最小高度
/// - ✅ 支援自訂 padding
///
/// 使用場景:
/// - Toolbar 右側文字按鈕（「儲存」、「完成」、「取消」）
class ReefTextButton extends StatelessWidget {
  /// Text or widget to display
  final Widget child;

  /// Callback when button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Padding inside the button
  final EdgeInsetsGeometry? padding;

  /// Text style (optional)
  final TextStyle? style;

  const ReefTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // PARITY: Android toolbar button height
      height: AppSpacing.toolbarButtonSize, // dp_44
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          textStyle: style,
          minimumSize: Size.zero, // Remove default minimumSize
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Remove extra padding
        ),
        child: child,
      ),
    );
  }
}
