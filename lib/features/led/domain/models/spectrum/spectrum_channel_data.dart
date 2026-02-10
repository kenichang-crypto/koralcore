import 'spectrum_wave_point.dart';
import '../../services/spectrum_calculator.dart';

class SpectrumChannelData {
  final List<SpectrumWavePoint> points;

  // Cache points by wavelength for O(1) lookup
  late final Map<int, SpectrumWavePoint> _pointMap;

  SpectrumChannelData(this.points) {
    _pointMap = {for (var p in points) p.waveLength: p};
  }

  /// Calculates intensity for a specific wavelength at a given channel intensity level (0-100).
  double getIntensityAt(int waveLength, int level) {
    final point = _pointMap[waveLength];
    if (point == null) return 0.0;

    return SpectrumCalculator.calculateIntensity(point, level.toDouble());
  }
}
