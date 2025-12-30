/// Border radius values derived from reef-b styles.xml.
///
/// PARITY: Maps to reef-b-app's res/values/styles.xml cornerSize
class AppRadius {
  const AppRadius._();

  static const double none = 0;
  static const double xs = 4; // dp_4
  static const double sm = 8; // dp_8
  static const double md = 10; // dp_10 (MaterialAlertDialog, BottomSheet)
  static const double lg = 12; // dp_12
  static const double xl = 16; // dp_16
  static const double xxl = 20; // dp_20
  static const double xxxl = 24; // dp_24
  static const double pill = 999; // Full pill / round surfaces
}

/// Legacy alias for backward compatibility
@Deprecated('Use AppRadius instead')
typedef ReefRadius = AppRadius;

