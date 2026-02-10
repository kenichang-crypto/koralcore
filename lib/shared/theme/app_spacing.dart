/// Spacing scale derived from reef-b dimens.xml.
/// Values are expressed in logical pixels for Flutter layouts.
///
/// PARITY: Maps to reef-b-app's res/values/dimens.xml
class AppSpacing {
  const AppSpacing._();

  // Standard spacing scale (常用間距)
  static const double none = 0;
  static const double xxxs = 4; // dp_4
  static const double xxs = 6; // dp_6
  static const double xs = 8; // dp_8
  static const double sm = 12; // dp_12
  static const double md = 16; // dp_16
  static const double lg = 20; // dp_20
  static const double xl = 24; // dp_24
  static const double xxl = 32; // dp_32
  static const double xxxl = 40; // dp_40

  // Component-specific dimensions (元件專用尺寸)
  static const double toolbarHeight = 56; // dp_56 (actionBarSize)
  static const double toolbarButtonSize =
      44; // dp_44 (toolbar button height/width)
  static const double minTouchArea =
      48; // dp_48 (Material Design min touch target)
  static const double largeButton = 60; // dp_60
  static const double largeImage = 80; // dp_80

  // Legacy alias for toolbar height
  static const double gutter = 56; // dp_56 (deprecated, use toolbarHeight)
}

/// Legacy alias for backward compatibility
@Deprecated('Use AppSpacing instead')
typedef ReefSpacing = AppSpacing;
