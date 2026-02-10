import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/features/led/domain/models/spectrum/spectrum_wave_point.dart';
import 'package:koralcore/features/led/domain/services/spectrum_calculator.dart';
import 'package:koralcore/features/led/data/spectrum/spectrum_data_source.dart';

void main() {
  group('Spectrum Domain Logic', () {
    test('SpectrumWavePoint model should hold correct values', () {
      final point = SpectrumWavePoint(
        waveLength: 450,
        strength25: 10,
        strength50: 20,
        strength75: 30,
        strength100: 40,
      );
      expect(point.waveLength, 450);
      expect(point.strength100, 40);
    });

    test('SpectrumCalculator interpolation logic', () {
      final point = SpectrumWavePoint(
        waveLength: 450,
        strength25: 10, // at 25%
        strength50: 20, // at 50%
        strength75: 30, // at 75%
        strength100: 40, // at 100%
      );

      // Case 0: 0% -> 0
      expect(SpectrumCalculator.calculateIntensity(point, 0), 0.0);

      // Case 1: 25% -> 10
      expect(SpectrumCalculator.calculateIntensity(point, 25), 10.0);

      // Case 2: 50% -> 20
      expect(SpectrumCalculator.calculateIntensity(point, 50), 20.0);

      // Case 3: 75% -> 30
      expect(SpectrumCalculator.calculateIntensity(point, 75), 30.0);

      // Case 4: 100% -> 40
      expect(SpectrumCalculator.calculateIntensity(point, 100), 40.0);

      // Case 5: 12.5% (Midway 0-25) -> 5.0
      // 0 + (12.5 - 0)/(25-0) * (10 - 0) = 0.5 * 10 = 5.0
      expect(SpectrumCalculator.calculateIntensity(point, 12.5), 5.0);

      // Case 6: 37.5% (Midway 25-50) -> 15.0
      // 10 + (37.5 - 25)/(50-25) * (20 - 10) = 10 + 0.5 * 10 = 15.0
      expect(SpectrumCalculator.calculateIntensity(point, 37.5), 15.0);
    });

    test('SpectrumDataSource should parse UV channel correctly', () {
      // Accessing the static getter triggers parsing
      final points = SpectrumDataSource.uv;
      expect(points, isNotEmpty);
      expect(points.first.waveLength, 380);

      // Verify a known value from the file (first point in UV)
      // { "wave": 380, "strength25": 0, "strength50": 0, "strength75": 5.970067477416278, "strength100": 16.435470000000002 }
      final first = points.first;
      expect(first.strength25, 0);
      expect(first.strength75, closeTo(5.97, 0.001));
      expect(first.strength100, closeTo(16.435, 0.001));
    });
  });
}
