import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// AppBar with divider below, matching reef-b-app's toolbar design.
///
/// PARITY: Mirrors reef-b-app's toolbar_app.xml and toolbar_device.xml
/// which include a MaterialDivider (2dp, color bg_press) below the Toolbar.
class ReefAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final bool showDivider;
  final double dividerHeight;
  final Color dividerColor;

  const ReefAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.showDivider = true,
    this.dividerHeight = 2.0,
    this.dividerColor = AppColors.surfacePressed, // bg_press
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          leading: leading,
          title: title,
          actions: actions,
          backgroundColor: backgroundColor ?? AppColors.surface, // white
          foregroundColor: foregroundColor ?? AppColors.textPrimary,
          elevation: elevation ?? 0,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
        if (showDivider)
          Divider(
            height: dividerHeight,
            thickness: dividerHeight,
            color: dividerColor,
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final appBarHeight = kToolbarHeight;
    final dividerHeight = showDivider ? this.dividerHeight : 0.0;
    return Size.fromHeight(appBarHeight + dividerHeight);
  }
}

