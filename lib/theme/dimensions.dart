import '../ui/theme/reef_radius.dart';
import '../ui/theme/reef_spacing.dart';

/// Legacy dimension aliases backed by Reef spacing / radius tokens.
class AppDimensions {
  AppDimensions._();

  static const double spacingXS = ReefSpacing.xxxs;
  static const double spacingS = ReefSpacing.xs;
  static const double spacingM = ReefSpacing.sm;
  static const double spacingL = ReefSpacing.md;
  static const double spacingXL = ReefSpacing.xl;
  static const double spacingXXL = ReefSpacing.xxl;

  static const double radiusS = ReefRadius.sm;
  static const double radiusM = ReefRadius.md;
  static const double radiusL = ReefRadius.lg;
}
