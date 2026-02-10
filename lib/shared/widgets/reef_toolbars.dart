// PARITY: 100% Android Toolbar Widgets
// Shared Toolbar Widgets for consistent layout across all pages
//
// Android 對應：
// - toolbar_device.xml: Back + Title(center) + Menu + BLE
// - toolbar_two_action.xml: Close + Title(center) + TextButton(right)
//
// 用途：
// - 替代所有頁面內的 _ToolbarDevice / _ToolbarTwoAction
// - 確保所有 Toolbar 按鈕都使用 44dp (ReefIconButton)

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../assets/common_icon_helper.dart';
import 'reef_icon_button.dart';

/// ToolbarDevice (Shared Widget)
///
/// 對應 Android `toolbar_device.xml`:
/// - 左側：返回按鈕 (btnBack)
/// - 中央：標題 (toolbarTitle)
/// - 右側：選單按鈕 (btnMenu)
/// - 右側：BLE 按鈕 (btnBle, 可選)
/// - 底部：Divider (2dp)
///
/// PARITY: 100% Android toolbar_device.xml
class ToolbarDevice extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onBle;
  final bool showBle;
  final Color backgroundColor;
  final Color foregroundColor;

  const ToolbarDevice({
    super.key,
    required this.title,
    this.onBack,
    this.onMenu,
    this.onBle,
    this.showBle = true,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: backgroundColor,
            height: AppSpacing.toolbarHeight, // dp_56
            child: Row(
              children: [
                // btnBack (dp_44)
                ReefIconButton(
                  icon: CommonIconHelper.getBackIcon(
                    size: 24,
                    color: foregroundColor,
                  ),
                  onPressed: onBack,
                ),
                // toolbarTitle (center)
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.title2.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // btnMenu (dp_44)
                ReefIconButton(
                  icon: CommonIconHelper.getMenuIcon(
                    size: 24,
                    color: foregroundColor,
                  ),
                  onPressed: onMenu,
                ),
                // btnBle (dp_44, optional)
                if (showBle)
                  ReefIconButton(
                    icon: CommonIconHelper.getBluetoothIcon(
                      size: 24,
                      color: foregroundColor,
                    ),
                    onPressed: onBle,
                  ),
              ],
            ),
          ),
          // Divider (dp_2)
          Container(
            height: 2,
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

/// ToolbarTwoAction (Shared Widget)
///
/// 對應 Android `toolbar_two_action.xml`:
/// - 左側：關閉按鈕 (btnBack, ic_close)
/// - 中央：標題 (toolbarTitle)
/// - 右側：文字按鈕 (btnRight, "儲存"/"完成"等)
/// - 底部：Divider (2dp)
///
/// PARITY: 100% Android toolbar_two_action.xml
class ToolbarTwoAction extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final VoidCallback? onRight;
  final String? rightText;
  final Widget? rightWidget; // 支援自訂右側按鈕
  final Color backgroundColor;
  final Color foregroundColor;

  const ToolbarTwoAction({
    super.key,
    required this.title,
    this.onClose,
    this.onRight,
    this.rightText,
    this.rightWidget,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: backgroundColor,
            height: AppSpacing.toolbarHeight, // dp_56
            padding: const EdgeInsets.symmetric(horizontal: 4), // dp_4
            child: Row(
              children: [
                // btnBack / btnClose (dp_44, ic_close)
                ReefIconButton(
                  icon: CommonIconHelper.getCloseIcon(
                    size: 24,
                    color: foregroundColor,
                  ),
                  onPressed: onClose,
                ),
                // toolbarTitle (center)
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.title2.copyWith(
                      color: foregroundColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // btnRight (dp_44, TextButton)
                if (rightWidget != null)
                  rightWidget!
                else if (rightText != null)
                  ReefTextButton(
                    onPressed: onRight,
                    child: Text(
                      rightText!,
                      style: AppTextStyles.body.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  )
                else
                  // Placeholder to maintain layout symmetry
                  const SizedBox(width: AppSpacing.toolbarButtonSize), // dp_44
              ],
            ),
          ),
          // Divider (dp_2)
          Container(
            height: 2,
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}
