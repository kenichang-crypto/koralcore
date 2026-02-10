import '../models/spectrum/spectrum_wave_point.dart';

class SpectrumCalculator {
  /// Calculates the intensity for a specific wave point at a given channel intensity percentage (0-100).
  /// Implements Piecewise Linear Interpolation based on 0, 25, 50, 75, 100 anchor points.
  static double calculateIntensity(SpectrumWavePoint point, double intensityPercent) {
    if (intensityPercent <= 0) return 0.0;
    if (intensityPercent >= 100) return point.strength100;

    double x1, y1; // Start point
    double x3, y3; // End point (using x3 to match Android naming convention for the range end)
    
    // Target X is intensityPercent

    if (intensityPercent < 25) {
      x1 = 0; y1 = 0;
      x3 = 25; y3 = point.strength25;
    } else if (intensityPercent < 50) {
      x1 = 25; y1 = point.strength25;
      x3 = 50; y3 = point.strength50;
    } else if (intensityPercent < 75) {
      x1 = 50; y1 = point.strength50;
      x3 = 75; y3 = point.strength75;
    } else {
      x1 = 75; y1 = point.strength75;
      x3 = 100; y3 = point.strength100;
    }

    // Formula: y = y1 + (x - x1) / (x3 - x1) * (y3 - y1)
    // where x is intensityPercent
    return y1 + (intensityPercent - x1) / (x3 - x1) * (y3 - y1);
  }
}
