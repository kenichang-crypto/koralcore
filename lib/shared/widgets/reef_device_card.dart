import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Device card matching reef-b-app's adapter_device_led.xml design.
///
/// PARITY: Mirrors MaterialCardView with:
/// - cardCornerRadius: 10dp
/// - cardElevation: 5dp
/// - layout_margin: 6dp (all sides)
class ReefDeviceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const ReefDeviceCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0, // dp_5
      margin: const EdgeInsets.all(6.0), // dp_6
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // dp_10
      ),
      color: backgroundColor ?? AppColors.surface,
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: onTap,
              child: Padding(
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 12.0, // dp_12
                      vertical: 10.0, // dp_10
                    ),
                child: child,
              ),
            )
          : Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 12.0, // dp_12
                    vertical: 10.0, // dp_10
                  ),
              child: child,
            ),
    );
  }
}

